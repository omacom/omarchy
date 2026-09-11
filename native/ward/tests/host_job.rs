use omarchy_ward::{
  exec_policy::{Argument, PluginDir, Step, Tree},
  host_job::{Environment, Executable, Job, Lifetime},
  revision::Revision,
  supervisor::{Limits, Unit, watchdog},
  worker,
};
use std::{
  ffi::OsStr,
  fs, io,
  os::{
    fd::{AsRawFd, FromRawFd, OwnedFd},
    unix::{fs::PermissionsExt, net::UnixListener},
  },
  path::{Path, PathBuf},
  process::Command,
  time::{Duration, Instant},
};

fn policy(argv: &[String]) -> Tree {
  let mut tree = Tree {
    end: Some("fixture".into()),
    next: vec![],
  };
  for value in argv.iter().rev() {
    tree = Tree {
      end: None,
      next: vec![Step {
        arg: Argument::Exact {
          value: value.clone(),
        },
        then: tree,
      }],
    };
  }
  tree
}

fn start(executable: &Executable, argv: &[String], environment: &Environment) -> Job {
  Job::start(
    executable,
    &policy(argv),
    &["fixture".into()].into(),
    argv,
    environment,
    &[],
    Lifetime::Request,
  )
  .unwrap()
}

fn finish(job: &mut Job) -> io::Result<std::process::Output> {
  let deadline = Instant::now() + Duration::from_secs(12);
  loop {
    watchdog().unwrap();
    if let Some(output) = job.poll()? {
      return Ok(output);
    }
    assert!(
      Instant::now() < deadline,
      "job observation exceeded its deadline"
    );
    std::thread::sleep(Duration::from_millis(2));
  }
}

fn peer(listener: &UnixListener, mut pending: impl FnMut() -> bool) -> OwnedFd {
  let deadline = Instant::now() + Duration::from_secs(2);
  loop {
    if let Ok((stream, _)) = listener.accept() {
      let mut credentials: libc::ucred = unsafe { std::mem::zeroed() };
      let mut length = std::mem::size_of_val(&credentials) as libc::socklen_t;
      assert_eq!(
        unsafe {
          libc::getsockopt(
            stream.as_raw_fd(),
            libc::SOL_SOCKET,
            libc::SO_PEERCRED,
            (&mut credentials as *mut libc::ucred).cast(),
            &mut length,
          )
        },
        0
      );
      let fd = unsafe { libc::syscall(libc::SYS_pidfd_open, credentials.pid, 0) } as i32;
      assert!(
        fd >= 0,
        "fixture peer died before its pidfd could be opened"
      );
      return unsafe { OwnedFd::from_raw_fd(fd) };
    }
    assert!(pending(), "fixture exited before connecting");
    assert!(Instant::now() < deadline, "fixture never connected");
    watchdog().unwrap();
    std::thread::sleep(Duration::from_millis(2));
  }
}

fn assert_dead(process: OwnedFd) {
  let mut poll = libc::pollfd {
    fd: process.as_raw_fd(),
    events: libc::POLLIN,
    revents: 0,
  };
  assert_eq!(
    unsafe { libc::poll(&mut poll, 1, 1000) },
    1,
    "detached descendant survived the host job"
  );
  assert_ne!(poll.revents & libc::POLLIN, 0);
}

fn job_groups() -> Vec<PathBuf> {
  let membership = fs::read_to_string("/proc/self/cgroup").unwrap();
  let relative = membership.trim().strip_prefix("0::/").unwrap();
  fs::read_dir(Path::new("/sys/fs/cgroup").join(relative))
    .unwrap()
    .map(|entry| entry.unwrap().path())
    .filter(|path| {
      path
        .file_name()
        .unwrap()
        .as_encoded_bytes()
        .starts_with(b"job-")
    })
    .collect()
}

#[test]
fn job_controller_child() {
  let Some(root) = std::env::var_os("OMARCHY_HOST_JOB_TEST_ROOT") else {
    return;
  };
  let root = PathBuf::from(root);
  let executable = Executable::select(&root.join("fixture")).unwrap();
  let alias = root.join("alias");
  std::os::unix::fs::symlink(&executable.path, &alias).unwrap();
  let selected_alias = Executable::select(&alias).unwrap();
  let identity = vec!["identity".into()];
  let environment = Environment::capture().unwrap();
  let mut aliased_job = start(&selected_alias, &identity, &environment);
  let replacement = root.join("replacement");
  fs::write(&replacement, "#!/bin/bash\nexit 1\n").unwrap();
  fs::set_permissions(&replacement, fs::Permissions::from_mode(0o700)).unwrap();
  let changed_alias = root.join("changed-alias");
  std::os::unix::fs::symlink(&replacement, &changed_alias).unwrap();
  fs::rename(changed_alias, &alias).unwrap();
  let output = finish(&mut aliased_job).unwrap();
  assert!(output.status.success());
  assert_eq!(output.stdout, format!("{}\n", alias.display()).as_bytes());
  assert!(
    Job::start(
      &selected_alias,
      &policy(&identity),
      &["fixture".into()].into(),
      &identity,
      &environment,
      &[],
      Lifetime::Request,
    )
    .is_err(),
    "a retargeted alias accepted different executable bytes"
  );
  drop(aliased_job);
  // Host jobs must retain the controller's user/group namespace. Creating a
  // fresh map breaks real CLI helpers which refer to another host user ID.
  let maps: Vec<String> = ["/proc/self/uid_map", "/proc/self/gid_map"]
    .map(String::from)
    .into();
  let expected_maps = maps
    .iter()
    .flat_map(|path| fs::read(path).unwrap())
    .collect::<Vec<_>>();
  let mut job = start(
    &Executable::select(Path::new("/usr/bin/cat")).unwrap(),
    &maps,
    &Environment::capture().unwrap(),
  );
  assert_eq!(finish(&mut job).unwrap().stdout, expected_maps);
  drop(job);
  let script = root.join("literal-script");
  fs::write(&script, "#!/bin/bash\nprintf '%s\\0' \"$@\"\nexit 9\n").unwrap();
  fs::set_permissions(&script, fs::Permissions::from_mode(0o700)).unwrap();
  let mut job = start(
    &Executable::select(&script).unwrap(),
    &["$HOME/a b".into(), "--literal".into()],
    &Environment::capture().unwrap(),
  );
  let output = finish(&mut job).unwrap();
  assert_eq!(output.status.code(), Some(9));
  assert_eq!(output.stdout, b"$HOME/a b\0--literal\0");
  drop(job);
  let environment = Environment::capture().unwrap();
  // Exercise the host-visible asset stage and both symbolic roots through a
  // real job. Matching a resolved copy alone does not rewrite the CLI's argv.
  let private = || {
    tempfile::Builder::new()
      .permissions(fs::Permissions::from_mode(0o700))
      .tempdir()
      .unwrap()
  };
  let source = private();
  let revisions = private();
  let runtime = private();
  let data = private();
  fs::write(source.path().join("asset.txt"), "reviewed asset\n").unwrap();
  fs::write(data.path().join("save.txt"), "saved data\n").unwrap();
  let revision = Revision::import(source.path(), revisions.path()).unwrap();
  let stage =
    worker::stage_plugin_assets(&revision.path, &revision.digest, runtime.path()).unwrap();
  let paths = [
    PluginDir::assets(stage.to_str().unwrap().into()),
    PluginDir::data(data.path().to_str().unwrap().into()),
  ];
  let cat = Executable::select(Path::new("/usr/bin/cat")).unwrap();
  let symbolic = vec![
    "$OMARCHY_PLUGIN_PATH/asset.txt".into(),
    "$OMARCHY_PLUGIN_DATA/save.txt".into(),
  ];
  let mut read = Job::start(
    &cat,
    &policy(&symbolic),
    &["fixture".into()].into(),
    &symbolic,
    &environment,
    &paths,
    Lifetime::Request,
  )
  .unwrap();
  let output = finish(&mut read).unwrap();
  assert!(
    output.status.success(),
    "{}",
    String::from_utf8_lossy(&output.stderr)
  );
  assert_eq!(output.stdout, b"reviewed asset\nsaved data\n");
  drop(read);
  // The real host job must reject a mutable DATA alias before any process or
  // cgroup is created, for both token and environment-expanded spellings.
  let secret = root.join("data-host-secret");
  fs::write(&secret, "host-only secret").unwrap();
  std::os::unix::fs::symlink(&secret, data.path().join("escape")).unwrap();
  for argument in ["$OMARCHY_PLUGIN_DATA/escape".to_owned(), data.path().join("escape").to_str().unwrap().to_owned()] {
    let argv = vec![argument];
    let groups = job_groups();
    assert!(Job::start(&cat, &policy(&argv), &["fixture".into()].into(), &argv, &environment, &paths, Lifetime::Request).is_err());
    assert_eq!(job_groups(), groups);
  }

  let extra = fs::File::create(root.join("host-secret-fixture")).unwrap();
  assert_eq!(
    unsafe { libc::fcntl(extra.as_raw_fd(), libc::F_SETFD, 0) },
    0
  );
  let marker = root.join("must-not-exist");
  let args = vec![
    "echo".into(),
    "one argument with spaces".into(),
    "".into(),
    format!("$(touch {})", marker.display()),
    "--literal-looking-option".into(),
  ];
  let mut job = start(&executable, &args, &environment);
  let original = fs::read(&executable.path).unwrap();
  fs::write(
    &executable.path,
    "changed after the job captured its executable",
  )
  .unwrap();
  let output = finish(&mut job).unwrap();
  assert_eq!(
    output.status.code(),
    Some(7),
    "{}",
    String::from_utf8_lossy(&output.stderr)
  );
  let mut expected = Vec::new();
  for argument in &args[1..] {
    expected.extend_from_slice(argument.as_bytes());
    expected.push(0);
  }
  expected.extend_from_slice(
    format!(
      "cwd=/\0HOME={}\0PATH=/usr/bin\0UNSELECTED=unset\0NOTIFY=unset\0",
      root.join("home").display()
    )
    .as_bytes(),
  );
  assert_eq!(output.stdout, expected);
  assert_eq!(output.stderr, b"fixture stderr\0\xff");
  assert!(!marker.exists());
  assert!(
    Job::start(
      &executable,
      &policy(&args),
      &["fixture".into()].into(),
      &args,
      &environment,
      &[],
      Lifetime::Request,
    )
    .is_err(),
    "a later invocation accepted changed executable bytes"
  );
  fs::write(&executable.path, original).unwrap();
  assert!(
    job.poll().is_err(),
    "a completed result was delivered twice"
  );
  let mut changed = args.clone();
  changed.push("extra".into());
  assert!(
    Job::start(
      &executable,
      &policy(&args),
      &["fixture".into()].into(),
      &changed,
      &environment,
      &[],
      Lifetime::Request,
    )
    .is_err()
  );
  assert!(
    Job::start(
      &executable,
      &policy(&args),
      &Default::default(),
      &args,
      &environment,
      &[],
      Lifetime::Request,
    )
    .is_err()
  );
  for mode in ["flood-out", "flood-err"] {
    let mut job = start(&executable, &[mode.into()], &environment);
    assert!(
      finish(&mut job)
        .unwrap_err()
        .to_string()
        .contains("output exceeds")
    );
  }
  for mode in ["cancel", "drop", "exit", "request", "plugin"] {
    let socket = root.join(format!("{mode}.socket"));
    let gate = root.join(format!("{mode}.exit"));
    let listener = UnixListener::bind(&socket).unwrap();
    listener.set_nonblocking(true).unwrap();
    let args = vec![
      "tree".into(),
      socket.to_str().unwrap().into(),
      gate.to_str().unwrap().into(),
    ];
    let mut job = Job::start(
      &executable,
      &policy(&args),
      &["fixture".into()].into(),
      &args,
      &environment,
      &[],
      if mode == "plugin" {
        Lifetime::Plugin
      } else {
        Lifetime::Request
      },
    )
    .unwrap();
    let process = peer(&listener, || job.poll().unwrap().is_none());
    match mode {
      "cancel" => job.cancel().unwrap(),
      "drop" => {
        drop(job);
        assert_dead(process);
        assert!(job_groups().is_empty(), "drop left a job group behind");
        continue;
      }
      "exit" => {
        fs::write(&gate, "exit").unwrap();
        assert_eq!(finish(&mut job).unwrap().status.code(), Some(17));
      }
      "request" | "plugin" => {
        let until = Instant::now() + Duration::from_secs(11);
        while Instant::now() < until {
          watchdog().unwrap();
          assert!(
            job.poll().unwrap().is_none(),
            "host job ended at the former execution deadline"
          );
          std::thread::sleep(Duration::from_millis(10));
        }
        fs::write(&gate, "exit").unwrap();
        assert_eq!(finish(&mut job).unwrap().status.code(), Some(17));
      }
      _ => unreachable!(),
    }
    assert_dead(process);
    assert!(job_groups().is_empty(), "{mode} left a job group behind");
  }
  let listener = UnixListener::bind(root.join("owner.socket")).unwrap();
  listener.set_nonblocking(true).unwrap();
  let mut owner = Command::new(std::env::current_exe().unwrap())
    .args(["--exact", "job_owner_child", "--nocapture"])
    .spawn()
    .unwrap();
  let process = peer(&listener, || owner.try_wait().unwrap().is_none());
  fs::write(root.join("owner.exit"), "exit without destructors").unwrap();
  assert!(owner.wait().unwrap().success());
  assert_dead(process); // The controller service is still alive here.
  let deadline = Instant::now() + Duration::from_secs(1);
  while !job_groups().is_empty() {
    assert!(
      Instant::now() < deadline,
      "owner death left a job group behind"
    );
    std::thread::sleep(Duration::from_millis(2));
  }
  fs::write(root.join("result"), "PASS").unwrap();
}

#[test]
fn job_owner_child() {
  let Some(root) = std::env::var_os("OMARCHY_HOST_JOB_TEST_ROOT") else {
    return;
  };
  let root = PathBuf::from(root);
  let executable = Executable::select(&root.join("fixture")).unwrap();
  let args = vec![
    "tree".into(),
    root.join("owner.socket").to_str().unwrap().into(),
    root.join("never-exit").to_str().unwrap().into(),
  ];
  let job = Job::start(
    &executable,
    &policy(&args),
    &["fixture".into()].into(),
    &args,
    &Environment::capture().unwrap(),
    &[],
    Lifetime::Plugin,
  )
  .unwrap();
  std::mem::forget(job);
  let deadline = Instant::now() + Duration::from_secs(2);
  while !root.join("owner.exit").exists() {
    assert!(Instant::now() < deadline, "owner fixture was not released");
    std::thread::sleep(Duration::from_millis(2));
  }
  std::process::exit(0); // Deliberately bypass Job::drop to test parent death.
}

#[test]
fn executable_approval_binds_bytes_not_a_later_path_lookup() {
  let root = tempfile::tempdir().unwrap();
  let path = root.path().join("fixture");
  fs::write(&path, "#!/bin/bash\nexit 0\n").unwrap();
  fs::set_permissions(&path, fs::Permissions::from_mode(0o700)).unwrap();
  let original = Executable::select(&path).unwrap();
  let restored: Executable =
    serde_json::from_slice(&serde_json::to_vec(&original).unwrap()).unwrap();
  assert_eq!(restored, original);
  fs::write(&path, "#!/bin/bash\nexit 1\n").unwrap();
  assert_ne!(Executable::select(&path).unwrap().digest, original.digest);
  assert!(Executable::select(Path::new("relative")).is_err());
  assert!(Executable::select(root.path()).is_err());
  fs::set_permissions(&path, fs::Permissions::from_mode(0o600)).unwrap();
  assert!(Executable::select(&path).is_err());
}

#[test]
fn real_jobs_preserve_argv_bound_output_and_stop_detached_descendants() {
  if std::env::var("OMARCHY_TEST_SYSTEMD").as_deref() != Ok("1") {
    return;
  }
  let root = tempfile::Builder::new()
    .prefix("omarchy-host-job-")
    .permissions(fs::Permissions::from_mode(0o700))
    .tempdir()
    .unwrap();
  fs::create_dir(root.path().join("home")).unwrap();
  let compiled = Command::new("/usr/bin/rustc")
    .args([
      "--edition=2024",
      "-Copt-level=2",
      "-Cstrip=debuginfo",
      "-Dwarnings",
    ])
    .arg(Path::new(env!("CARGO_MANIFEST_DIR")).join("tests/support/host-job.rs"))
    .arg("-o")
    .arg(root.path().join("fixture"))
    .status()
    .unwrap();
  assert!(compiled.success());
  let wrapper = root.path().join("controller");
  fs::write(&wrapper, format!("#!/bin/bash\nexport OMARCHY_HOST_JOB_TEST_ROOT={}\nexport HOME={}/home\nexport XDG_CONFIG_HOME={}/home\nexport XDG_DATA_HOME={}/home\nexport XDG_CACHE_HOME={}/home\nexport XDG_STATE_HOME={}/home\nexport XDG_RUNTIME_DIR={}\nexport DBUS_SESSION_BUS_ADDRESS=unix:path=/nonexistent-host-job-fixture-bus\nexport PRIVATE_MARKER=disposable-unselected\nexec {} --exact job_controller_child --nocapture\n",
    root.path().display(), root.path().display(), root.path().display(), root.path().display(),
    root.path().display(), root.path().display(), root.path().display(), std::env::current_exe().unwrap().display())).unwrap();
  fs::set_permissions(&wrapper, fs::Permissions::from_mode(0o700)).unwrap();
  let mut unit = Unit::start(&wrapper, &[] as &[&OsStr], Limits::default()).unwrap();
  let deadline = Instant::now() + Duration::from_secs(25);
  while unit.running().unwrap() {
    assert!(
      Instant::now() < deadline,
      "host-job controller did not finish"
    );
    std::thread::sleep(Duration::from_millis(20));
  }
  unit.stop().unwrap();
  assert_eq!(
    fs::read_to_string(root.path().join("result"))
      .as_deref()
      .unwrap_or("missing"),
    "PASS",
    "controller {} failed; inspect its private fixture journal",
    unit.name()
  );
}
