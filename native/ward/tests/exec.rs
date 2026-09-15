use omarchy_ward::{
  channel::Channel,
  controller::Approval,
  exec::{Ask, Grant, Request, receive},
  grants::{Access, FileSystemGrant, Grants, Target},
  requests::Broker,
  revision::Revision,
  store::Store,
  supervisor::{self, Limits},
  worker,
};
use std::{
  ffi::OsStr,
  fs::{self, OpenOptions},
  io::{Read, Write},
  os::{
    fd::{AsRawFd, FromRawFd, OwnedFd},
    unix::{
      fs::{OpenOptionsExt, PermissionsExt},
      net::{UnixListener, UnixStream},
    },
  },
  path::Path,
  process::Command,
  thread,
  time::{Duration, Instant},
};

fn send(path: &str, argv: Vec<String>) -> Channel {
  let channel = Channel::connect(Path::new(path)).unwrap();
  Request {
    name: "fixture".into(),
    argv,
  }
  .send(&channel)
  .unwrap();
  channel
}

#[test]
fn exec_worker_child() {
  if !Path::new("/bootstrap").exists() {
    return;
  }
  worker::restrict_bootstrap().unwrap();
  let mut display = UnixStream::connect("/run/plugin/wayland").unwrap();
  let mode = fs::read_to_string("/plugin/mode").unwrap();
  let home = fs::read_to_string("/plugin/home").unwrap();
  let hold: Vec<String> = serde_json::from_slice(&fs::read("/plugin/hold.json").unwrap()).unwrap();
  assert!(fs::read(Path::new(&home).join("host-only")).is_err());
  let cli = |argv: &[&str]| {
    let output = Command::new("/grants/cli")
      .args(["--json", "--exec", "fixture"])
      .args(argv)
      .output()
      .unwrap();
    assert!(output.stderr.is_empty());
    let result: serde_json::Value = serde_json::from_slice(&output.stdout).unwrap();
    (output, result)
  };
  if mode == "denied" {
    assert!(!Path::new("/run/plugin/exec").exists());
    assert!(
      receive(&send(
        "/run/plugin/notify",
        vec!["echo".into(), "literal".into()]
      ))
      .is_err()
    );
    let (output, result) = cli(&["echo", "literal"]);
    assert_eq!(output.status.code(), Some(1));
    assert_eq!(result, serde_json::json!({"version":1,"status":"denied"}));
  } else if mode == "failed" {
    let (output, result) = cli(&["echo", "literal"]);
    assert_eq!(output.status.code(), Some(1));
    assert_eq!(result, serde_json::json!({"version":1,"status":"failed"}));
  } else if mode == "prepare" || mode == "prepare-abandon" {
    if mode == "prepare-abandon" {
      drop(send("/run/plugin/exec", hold));
      display.write_all(b"CANC").unwrap();
      let mut ack = [0; 4];
      display.read_exact(&mut ack).unwrap();
      assert_eq!(&ack, b"OKAY");
    }
    let output = receive(&send(
      "/run/plugin/exec",
      vec!["echo".into(), "prepared".into()],
    ))
    .unwrap();
    assert_eq!(output.status.code(), Some(7));
  } else if matches!(mode.as_str(), "request-long" | "long" | "abandon" | "abandon-request") {
    let mut cli = Command::new("/grants/cli")
      .args(["--json", "--exec", "fixture"])
      .args(&hold)
      .stdout(std::process::Stdio::piped())
      .spawn()
      .unwrap();
    if mode == "long" || mode == "request-long" {
      thread::sleep(Duration::from_secs(13));
      assert!(
        cli.try_wait().unwrap().is_none(),
        "host command forwarder ended at the former execution deadline"
      );
      display.write_all(b"GATE").unwrap();
      let output = cli.wait_with_output().unwrap();
      let result: serde_json::Value = serde_json::from_slice(&output.stdout).unwrap();
      assert!(output.status.success());
      assert_eq!(result["status"], "completed");
      assert_eq!(result["exitCode"], 17);
    } else {
      thread::sleep(Duration::from_millis(250));
      cli.kill().unwrap();
      cli.wait().unwrap();
      thread::sleep(Duration::from_millis(250));
      display.write_all(b"CANC").unwrap();
      let mut ack = [0; 4];
      display.read_exact(&mut ack).unwrap();
      assert_eq!(&ack, b"OKAY");
    }
  } else if mode == "allowed" {
    let (output, result) = cli(&["failure"]);
    assert_eq!(output.status.code(), Some(0));
    assert_eq!(
      result,
      serde_json::json!({"version":1,"status":"completed","exitCode":1,
        "stdout":{"base64":"ZG9tYWluIGZhaWx1cmUA/w=="},"stderr":"fixture failed\n"})
    );
    let raw = Command::new("/grants/cli")
      .args(["--exec", "fixture", "failure"])
      .output()
      .unwrap();
    assert_eq!(raw.status.code(), Some(1));
    assert_eq!(raw.stdout, b"domain failure\0\xff");
    assert_eq!(raw.stderr, b"fixture failed\n");
    let (output, result) = cli(&["unselected"]);
    assert_eq!(output.status.code(), Some(1));
    assert_eq!(result, serde_json::json!({"version":1,"status":"denied"}));
    let literal = "a b; $(touch /must-not-exist)\n--literal";
    let output = receive(&send(
      "/run/plugin/exec",
      vec!["echo".into(), literal.into()],
    ))
    .unwrap();
    assert_eq!(
      output.status.code(),
      Some(7),
      "{}",
      String::from_utf8_lossy(&output.stderr)
    );
    assert_eq!(
      output.stdout,
      format!("{literal}\0cwd=/\0HOME={home}\0PATH=/usr/bin\0UNSELECTED=unset\0NOTIFY=unset\0")
        .as_bytes()
    );
    assert_eq!(output.stderr, b"fixture stderr\0\xff");
    assert!(
      receive(&send(
        "/run/plugin/exec",
        vec!["echo".into(), "literal".into(), "extra".into()]
      ))
      .is_err()
    );
    assert!(receive(&send("/run/plugin/exec", vec!["flood-out".into()])).is_err());
    assert!(receive(&send("/run/plugin/exec", vec!["unselected".into()])).is_err());
    // Two live jobs fill the fixed memory budget; a third is explicitly not started.
    let _a = send("/run/plugin/exec", hold.clone());
    thread::sleep(Duration::from_millis(150));
    let _b = send("/run/plugin/exec", hold.clone());
    thread::sleep(Duration::from_millis(150));
    let busy = send("/run/plugin/exec", hold);
    assert_eq!(
      receive(&busy).unwrap_err().kind(),
      std::io::ErrorKind::WouldBlock
    );
  } else {
    assert!(mode.starts_with("revoke"));
    let _ = receive(&send("/run/plugin/exec", hold));
    panic!("revocation left the worker alive");
  }
  display.write_all(b"PASS").unwrap();
}

#[test]
fn exec_controller_child() {
  let Some(root) = std::env::var_os("OMARCHY_EXEC_TEST_ROOT") else {
    return;
  };
  let root = Path::new(&root);
  let store = Store::open(&root.join("state")).unwrap();
  let epoch = std::env::var("OMARCHY_EXEC_TEST_EPOCH")
    .unwrap()
    .parse()
    .unwrap();
  let approval = Approval::open(&root.join("state"), "test.exec", epoch).unwrap();
  let record = store.read("test.exec").unwrap();
  fs::write(
    root.join("grants.json"),
    serde_json::to_vec(&record.grants.worker_view()).unwrap(),
  )
  .unwrap();
  let grants_json = fs::File::open(root.join("grants.json")).unwrap();
  let mut broker =
    Broker::start(root, Path::new(env!("CARGO_BIN_EXE_omarchy-ward")), vec![]).unwrap();
  let listener = UnixListener::bind(root.join("wayland")).unwrap();
  listener.set_nonblocking(true).unwrap();
  let fd = |path: &Path| {
    OpenOptions::new()
      .read(true)
      .custom_flags(libc::O_PATH | libc::O_NOFOLLOW)
      .open(path)
      .unwrap()
  };
  let mut child = worker::spawn(
    &fd(&std::env::current_exe().unwrap()),
    &fd(&store.revisions().join(record.revision)),
    &fd(&root.join("wayland")),
    &[
      OsStr::new("--exact"),
      OsStr::new("exec_worker_child"),
      OsStr::new("--nocapture"),
    ],
    Limits::default(),
    &record.grants,
    worker::Resources {
      requests: Some(&broker),
      grants_json: Some(&grants_json),
      ..Default::default()
    },
  )
  .unwrap();
  let mut display = None;
  let preparation_test = fs::read_to_string(root.join("source/mode"))
    .unwrap()
    .starts_with("prepare");
  let mut maximum_dispatch = Duration::ZERO;
  let deadline = Instant::now() + Duration::from_secs(18);
  loop {
    let dispatch_started = Instant::now();
    broker.dispatch(&approval).unwrap();
    maximum_dispatch = maximum_dispatch.max(dispatch_started.elapsed());
    if display.is_none()
      && let Ok((stream, _)) = listener.accept()
    {
      stream.set_nonblocking(true).unwrap();
      display = Some(stream);
    }
    let mut bytes = [0; 4];
    if display
      .as_mut()
      .is_some_and(|s| s.read(&mut bytes).is_ok_and(|n| n == 4))
    {
      if &bytes == b"GATE" {
        fs::write(root.join("never-exit"), "finish long job").unwrap();
        continue;
      }
      if &bytes == b"CANC" {
        let membership = fs::read_to_string("/proc/self/cgroup").unwrap();
        let relative = membership.trim().strip_prefix("0::/").unwrap();
        assert!(
          !fs::read_dir(Path::new("/sys/fs/cgroup").join(relative))
            .unwrap()
            .any(|entry| entry
              .unwrap()
              .file_name()
              .as_encoded_bytes()
              .starts_with(b"job-")),
          "forwarder cancellation left a job group alive"
        );
        display.as_mut().unwrap().write_all(b"OKAY").unwrap();
        continue;
      }
      assert_eq!(&bytes, b"PASS");
      if preparation_test {
        assert!(
          maximum_dispatch < Duration::from_millis(200),
          "executable preparation blocked input dispatch for {maximum_dispatch:?}"
        );
        println!("large executable maximum broker dispatch: {maximum_dispatch:?}");
      }
      fs::write(root.join("passed"), bytes).unwrap();
      break;
    }
    if let Some(status) = child.try_wait().unwrap() {
      let mut log = String::new();
      child
        .stderr
        .take()
        .unwrap()
        .read_to_string(&mut log)
        .unwrap();
      panic!("exec worker exited {status}: {log}");
    }
    assert!(Instant::now() < deadline, "exec fixture timed out");
    supervisor::watchdog().unwrap();
    thread::sleep(Duration::from_millis(5));
  }
}

fn quote(value: &Path) -> String {
  format!("'{}'", value.to_str().unwrap().replace('\'', "'\\''"))
}

#[test]
fn selected_exec_crosses_only_the_broker_and_revocation_stops_owned_jobs() {
  if std::env::var("OMARCHY_TEST_SYSTEMD").as_deref() != Ok("1") {
    return;
  }
  for mode in [
    "denied",
    "allowed",
    "failed",
    "request-long",
    "revoke",
    "long",
    "abandon",
    "abandon-request",
    "revoke-long",
    "prepare",
    "prepare-abandon",
  ] {
    let root = tempfile::Builder::new()
      .prefix("omarchy-exec-")
      .permissions(fs::Permissions::from_mode(0o700))
      .tempdir()
      .unwrap();
    let root = root.path();
    for dir in ["source", "home", "bin"] {
      fs::create_dir(root.join(dir)).unwrap();
    }
    fs::write(root.join("home/host-only"), "private fixture").unwrap();
    let fixture = root.join("fixture");
    assert!(
      Command::new("/usr/bin/rustc")
        .args([
          "--edition=2024",
          "-Copt-level=2",
          "-Cstrip=debuginfo",
          "-Dwarnings"
        ])
        .arg(Path::new(env!("CARGO_MANIFEST_DIR")).join("tests/support/host-job.rs"))
        .arg("-o")
        .arg(&fixture)
        .status()
        .unwrap()
        .success()
    );
    if mode.starts_with("prepare") {
      // ELF ignores trailing bytes. Make verification substantial without
      // changing the synthetic executable's behavior or requiring a real CLI.
      OpenOptions::new()
        .write(true)
        .open(&fixture)
        .unwrap()
        .set_len(64 * 1024 * 1024)
        .unwrap();
    }
    let socket = root.join("owned.socket");
    let listener = UnixListener::bind(&socket).unwrap();
    listener.set_nonblocking(true).unwrap();
    let hold = vec![
      "tree".to_owned(),
      socket.to_str().unwrap().into(),
      root.join("never-exit").to_str().unwrap().into(),
    ];
    let branch = |name: &str, argv: &[String]| {
      let mut tree = serde_json::json!({"end":name});
      for value in argv.iter().rev() {
        tree = serde_json::json!({"next":[{"arg":{"kind":"exact","value":value},"then":tree}]});
      }
      tree["next"][0].clone()
    };
    let ask: Ask = serde_json::from_value(serde_json::json!({"executable":fixture,
      "lifetime":if matches!(mode, "long" | "abandon" | "revoke-long" | "prepare-abandon") {"plugin"} else {"request"},"tree":{"next":[
      {"arg":{"kind":"exact","value":"echo"},"then":{"next":[{"arg":{"kind":"text","prefix":"","min":0,"max":8192},"then":{"end":"echo"}}]}},
      branch("hold", &hold), branch("flood", &["flood-out".into()]), branch("failure", &["failure".into()]), branch("unselected", &["unselected".into()])
    ]}})).unwrap();
    fs::write(root.join("source/manifest.json"), serde_json::to_vec(&serde_json::json!({
      "schemaVersion":1,"id":"test.exec","name":"Exec fixture","version":"1","kinds":["panel"],"entryPoints":{"panel":"worker.qml"},
      "sandbox":{"version":1,"entryPoint":"worker.qml","requests":{"exec":{"fixture":ask},"notifications":true,"filesystem":[{"name":"cli","path":env!("CARGO_BIN_EXE_omarchy-ward"),"target":"file"}]}}
    })).unwrap()).unwrap();
    fs::write(
      root.join("source/worker.qml"),
      "import Quickshell\nShellRoot {}\n",
    )
    .unwrap();
    fs::write(root.join("source/mode"), mode).unwrap();
    fs::write(
      root.join("source/home"),
      root.join("home").to_str().unwrap(),
    )
    .unwrap();
    fs::write(
      root.join("source/hold.json"),
      serde_json::to_vec(&hold).unwrap(),
    )
    .unwrap();
    let store = Store::initialize(&root.join("state")).unwrap();
    let revision = Revision::import(&root.join("source"), &store.revisions()).unwrap();
    let exec = if mode == "denied" {
      Default::default()
    } else {
      [(
        "fixture".into(),
        Grant::select(
          &ask,
          [
            "echo".into(),
            "hold".into(),
            "flood".into(),
            "failure".into(),
          ]
          .into(),
        )
        .unwrap(),
      )]
      .into()
    };
    store
      .approve(
        &revision.digest,
        Grants {
          exec,
          filesystem: [(
            "cli".into(),
            FileSystemGrant::select(
              Path::new(env!("CARGO_BIN_EXE_omarchy-ward")),
              Access::Read,
              Target::File,
            )
            .unwrap(),
          )]
          .into(),
          notifications: mode == "denied",
          ..Default::default()
        },
      )
      .unwrap();
    if mode == "failed" {
      fs::write(&fixture, "changed executable bytes").unwrap();
    }
    let controller = root.join("controller");
    fs::write(&controller, format!("#!/bin/bash\nexport OMARCHY_PATH={}\nexport OMARCHY_EXEC_TEST_ROOT={}\nexport OMARCHY_EXEC_TEST_EPOCH=\"$5\"\nexport HOME={}\nexport XDG_CONFIG_HOME={}\nexport XDG_RUNTIME_DIR={}\nexport DBUS_SESSION_BUS_ADDRESS=unix:path=/nonexistent-exec-test-bus\nexec {} --exact exec_controller_child --nocapture\n",
      quote(root), quote(root), quote(&root.join("home")), quote(&root.join("home")), quote(root), quote(&std::env::current_exe().unwrap()))).unwrap();
    fs::set_permissions(&controller, fs::Permissions::from_mode(0o700)).unwrap();
    let (mut unit, _) = store
      .launch("test.exec", &controller, &root.join("unused"))
      .unwrap();
    let deadline = Instant::now() + Duration::from_secs(20);
    let mut peers = Vec::new();
    while unit.running().unwrap() && Instant::now() < deadline {
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
        let pidfd = unsafe { libc::syscall(libc::SYS_pidfd_open, credentials.pid, 0) } as i32;
        assert!(pidfd >= 0);
        peers.push(unsafe { OwnedFd::from_raw_fd(pidfd) });
        if mode.starts_with("revoke") {
          store.revoke("test.exec").unwrap();
          break;
        }
      }
      thread::sleep(Duration::from_millis(5));
    }
    unit.stop().unwrap();
    for peer in &peers {
      let mut poll = libc::pollfd {
        fd: peer.as_raw_fd(),
        events: libc::POLLIN,
        revents: 0,
      };
      assert_eq!(
        unsafe { libc::poll(&mut poll, 1, 1000) },
        1,
        "revocation left a host descendant alive"
      );
    }
    assert_eq!(
      peers.len(),
      match mode {
        "allowed" => 2,
        "denied" | "failed" | "prepare" | "prepare-abandon" => 0,
        _ => 1,
      }
    );
    if mode.starts_with("revoke") {
      assert!(!root.join("passed").exists());
      assert!(!store.read("test.exec").unwrap().enabled);
    } else {
      assert!(
        root.join("passed").exists(),
        "exec mode {mode} failed: {}",
        String::from_utf8_lossy(
          &Command::new("journalctl")
            .args(["--user", "--no-pager", "-n", "45", "-u", unit.name()])
            .output()
            .unwrap()
            .stdout
        )
      );
    }
  }
}
