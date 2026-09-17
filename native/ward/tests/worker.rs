use omarchy_ward::{
  grants::{Access, FileSystemGrant, Grants, Target},
  supervisor::{Limits, Unit, watchdog},
  worker,
};
use std::{
  ffi::{OsStr, OsString},
  fs::{self, File, OpenOptions},
  io::{Read, Write},
  net::{TcpListener, TcpStream},
  os::{
    fd::AsRawFd,
    unix::{
      fs::{OpenOptionsExt, PermissionsExt},
      net::{UnixListener, UnixStream},
    },
  },
  path::Path,
  process::Command,
  time::{Duration, Instant},
};

fn limits() -> Limits {
  Limits {
    memory_bytes: 128 * 1024 * 1024,
    tasks: 32,
    cpu_percent: 50,
  }
}

fn path_fd(path: &Path) -> File {
  OpenOptions::new()
    .read(true)
    .custom_flags(libc::O_PATH | libc::O_NOFOLLOW)
    .open(path)
    .unwrap()
}

#[test]
fn worker_child() {
  if !Path::new("/bootstrap").exists() {
    return;
  }
  worker::restrict_bootstrap().unwrap();
  let mut stream = UnixStream::connect("/run/plugin/wayland").unwrap();
  // Failure reports travel over the only authorized private socket.
  let result = std::panic::catch_unwind(|| {
    assert!(!Path::new("/home/jacob").exists());
    assert!(!Path::new("/run/user").exists());
    assert!(!Path::new("/sys/fs/cgroup").exists());
    assert!(!Path::new("/dev/dri").exists());
    assert!(std::env::var_os("DBUS_SESSION_BUS_ADDRESS").is_none());
    assert!(std::env::var_os("NOTIFY_SOCKET").is_none());
    assert!(std::env::var_os("OMARCHY_WORKER_TEST_ROOT").is_none());
    assert_eq!(fs::read_to_string("/plugin/marker").unwrap(), "approved");
    assert!(std::env::var_os("OMARCHY_PATH").is_none());
    assert_eq!(std::env::var("OMARCHY_PLUGIN_CONTEXT").unwrap(), "1");
    for directory in ["/runtime", "/context"] {
      assert_eq!(
        fs::read_to_string(format!("{directory}/marker")).unwrap(),
        "runtime"
      );
      assert!(fs::write(format!("{directory}/marker"), "changed").is_err());
      assert_eq!(
        UnixStream::connect(format!("{directory}/denied"))
          .unwrap_err()
          .raw_os_error(),
        Some(libc::EACCES)
      );
    }
    assert!(fs::write("/plugin/marker", "changed").is_err());
    assert!(fs::write("/escape", "changed").is_err());
    fs::write("/home/plugin/private", "private").unwrap();
    assert_eq!(
      fs::read_dir("/sys/class/net").err().unwrap().kind(),
      std::io::ErrorKind::NotFound
    );
    let routes = fs::read_to_string("/proc/net/route").unwrap();
    assert_eq!(
      routes.lines().count(),
      1,
      "network namespace has an external route"
    );
    let port = fs::read_to_string("/plugin/port").unwrap();
    let address = format!("127.0.0.1:{port}").parse().unwrap();
    assert!(
      TcpStream::connect_timeout(&address, Duration::from_millis(100)).is_err(),
      "ungranted worker reached the host listener"
    );
    assert_eq!(unsafe { libc::unshare(libc::CLONE_NEWUSER) }, -1);
    assert_eq!(
      std::io::Error::last_os_error().raw_os_error(),
      Some(libc::EPERM)
    );
    let status = fs::read_to_string("/proc/self/status").unwrap();
    assert!(status.contains("NoNewPrivs:\t1"));
    assert!(status.contains("Seccomp:\t2"));
    assert!(status.contains("CapEff:\t0000000000000000"));
    for entry in fs::read_dir("/proc/self/fd").unwrap() {
      let target = fs::read_link(entry.unwrap().path()).unwrap();
      assert!(
        !target.to_string_lossy().contains("host-secret"),
        "inherited a host file descriptor"
      );
    }
    // A socket hidden inside even a read-only bundle is not an IPC grant.
    assert_eq!(
      UnixStream::connect("/plugin/denied")
        .unwrap_err()
        .raw_os_error(),
      Some(libc::EACCES)
    );
    std::os::unix::fs::symlink("/plugin/denied", "/tmp/not-a-grant").unwrap();
    assert_eq!(
      UnixStream::connect("/tmp/not-a-grant")
        .unwrap_err()
        .raw_os_error(),
      Some(libc::EACCES)
    );
    let local = UnixListener::bind("/tmp/own-socket").unwrap();
    local.set_nonblocking(true).unwrap();
    let mut helper = Command::new("/bootstrap")
      .args(["--exact", "private_ipc_child"])
      .spawn()
      .unwrap();
    assert!(helper.wait().unwrap().success());
    assert!(
      local.accept().is_ok(),
      "helper could not reach its own private socket"
    );
    let output = Command::new("/usr/bin/sh")
      .args([
        "-c",
        "test -f /home/plugin/private && test ! -d /home/jacob && printf helper",
      ])
      .output()
      .unwrap();
    assert!(output.status.success());
    assert_eq!(output.stdout, b"helper");
    let mut data = File::create("/tmp/space").unwrap();
    let block = [0u8; 65536];
    let mut written = 0;
    loop {
      match data.write_all(&block) {
        Ok(()) => {
          written += block.len();
          assert!(written <= 16 * 1024 * 1024);
        }
        Err(error) => {
          assert_eq!(error.raw_os_error(), Some(libc::ENOSPC));
          break;
        }
      }
    }
  });
  stream
    .write_all(if result.is_ok() { b"PASS" } else { b"FAIL" })
    .unwrap();
  assert!(result.is_ok());
}

#[test]
fn private_ipc_child() {
  if !Path::new("/bootstrap").exists() {
    return;
  }
  UnixStream::connect("/tmp/own-socket").unwrap();
}

#[test]
fn granted_worker_child() {
  if !Path::new("/bootstrap").exists() {
    return;
  }
  worker::restrict_bootstrap().unwrap();
  let mut display = UnixStream::connect("/run/plugin/wayland").unwrap();
  assert_eq!(
    fs::read_to_string("/grants/files/allowed").unwrap(),
    "selected data"
  );
  assert!(fs::write("/grants/files/allowed", "changed").is_err());
  assert_eq!(
    UnixStream::connect("/grants/files/denied")
      .unwrap_err()
      .raw_os_error(),
    Some(libc::EACCES)
  );
  std::os::unix::fs::symlink("/grants/files/denied", "/tmp/denied-link").unwrap();
  assert_eq!(
    UnixStream::connect("/tmp/denied-link")
      .unwrap_err()
      .raw_os_error(),
    Some(libc::EACCES)
  );
  let port = fs::read_to_string("/plugin/port").unwrap();
  let address = format!("127.0.0.1:{port}").parse().unwrap();
  let mut network = TcpStream::connect_timeout(&address, Duration::from_millis(100)).unwrap();
  network.write_all(b"NETWORK").unwrap();
  display.write_all(b"PASS").unwrap();
}

#[test]
fn filesystem_grants_child() {
  if !Path::new("/bootstrap").exists() {
    return;
  }
  worker::restrict_bootstrap().unwrap();
  // The writable grant may create and overwrite; writes land on real host data.
  fs::write("/grants/scratch/note", "written").unwrap();
  assert_eq!(
    fs::read_to_string("/grants/scratch/note").unwrap(),
    "written"
  );
  // The read-only grant from the same run still refuses writes.
  assert_eq!(
    fs::read_to_string("/grants/files/allowed").unwrap(),
    "selected data"
  );
  assert!(fs::write("/grants/files/allowed", "nope").is_err());
  // Controller-authored introspection: what was actually admitted, not the
  // plugin's desires.
  let granted: serde_json::Value =
    serde_json::from_slice(&fs::read("/run/plugin/grants.json").unwrap()).unwrap();
  let directories = granted["filesystem"].as_object().unwrap();
  assert_eq!(directories["scratch"]["access"], "readwrite");
  assert_eq!(directories["files"]["access"], "read");
  let mut display = UnixStream::connect("/run/plugin/wayland").unwrap();
  display.write_all(b"PASS").unwrap();
}

#[test]
fn controller_child() {
  let Some(root) = std::env::var_os("OMARCHY_WORKER_TEST_ROOT") else {
    return;
  };
  let root = Path::new(&root);
  let network = std::env::var("OMARCHY_WORKER_TEST_NETWORK").as_deref() == Ok("1");
  let write_grant = std::env::var("OMARCHY_WORKER_TEST_WRITE").as_deref() == Ok("1");
  let tcp = TcpListener::bind("127.0.0.1:0").unwrap();
  tcp.set_nonblocking(true).unwrap();
  fs::write(
    root.join("bundle/port"),
    tcp.local_addr().unwrap().port().to_string(),
  )
  .unwrap();
  let mut grants = Grants::default();
  if network {
    grants.network = true;
  }
  if network || write_grant {
    grants.filesystem.insert(
      "files".into(),
      FileSystemGrant::select(&root.join("selected"), Access::Read, Target::Directory).unwrap(),
    );
  }
  if write_grant {
    grants.filesystem.insert(
      "scratch".into(),
      FileSystemGrant::select(
        &root.join("scratch-write"),
        Access::ReadWrite,
        Target::Directory,
      )
      .unwrap(),
    );
  }
  let grants_json = if write_grant {
    // Controller-authored, exactly as controller.rs builds it: the granted
    // record, not plugin metadata, so introspection reflects what was admitted.
    let path = root.join("grants-state.json");
    fs::write(&path, serde_json::to_vec(&grants).unwrap()).unwrap();
    Some(path_fd(&path))
  } else {
    None
  };
  let listener = UnixListener::bind(root.join("wayland")).unwrap();
  listener.set_nonblocking(true).unwrap();
  let bundle = path_fd(&root.join("bundle"));
  let runtime = path_fd(&root.join("runtime"));
  fs::rename(root.join("runtime"), root.join("original-runtime")).unwrap();
  fs::create_dir(root.join("runtime")).unwrap();
  fs::write(root.join("runtime/marker"), "replacement").unwrap();
  // Substitute the name after opening: the original approved inode must remain
  // the mounted bundle, not this replacement directory.
  fs::rename(root.join("bundle"), root.join("original")).unwrap();
  fs::create_dir(root.join("bundle")).unwrap();
  fs::write(root.join("bundle/marker"), "replacement").unwrap();
  let bootstrap = path_fd(&std::env::current_exe().unwrap());
  let display = path_fd(&root.join("wayland"));
  fs::write(root.join("host-secret"), "not for the worker").unwrap();
  let leaked = File::open(root.join("host-secret")).unwrap();
  assert_eq!(
    unsafe { libc::fcntl(leaked.as_raw_fd(), libc::F_SETFD, 0) },
    0
  );
  let descriptors = [&bootstrap, &bundle, &display, &runtime];
  let before = descriptors.map(|file| unsafe { libc::fcntl(file.as_raw_fd(), libc::F_GETFD) });
  // Shared runtimes have an authenticated own-panel state channel even when
  // all host-effect grants are denied, matching the production controller.
  let request_root = tempfile::Builder::new()
    .permissions(fs::Permissions::from_mode(0o700))
    .tempdir_in(root)
    .unwrap();
  let requests = omarchy_ward::requests::Broker::start(
    request_root.path(),
    &std::env::current_exe().unwrap(),
    vec![],
  )
  .unwrap();
  // Bubblewrap consumes each mount descriptor. Even when two resources use
  // the same directory, they must receive distinct inherited descriptors.
  let context = runtime.try_clone().unwrap();
  let mut child = worker::spawn(
    &bootstrap,
    &bundle,
    &display,
    &[
      OsStr::new("--exact"),
      OsStr::new(if write_grant {
        "filesystem_grants_child"
      } else if network {
        "granted_worker_child"
      } else {
        "worker_child"
      }),
      OsStr::new("--nocapture"),
    ],
    limits(),
    &grants,
    worker::Resources {
      requests: Some(&requests),
      runtime: Some(&runtime),
      context: Some(&context),
      grants_json: grants_json.as_ref(),
      ..Default::default()
    },
  )
  .unwrap();
  assert_eq!(
    before,
    descriptors.map(|file| unsafe { libc::fcntl(file.as_raw_fd(), libc::F_GETFD) })
  );
  let deadline = Instant::now() + Duration::from_secs(3);
  let mut stream = loop {
    watchdog().unwrap();
    if let Ok((stream, _)) = listener.accept() {
      break stream;
    }
    if child.try_wait().unwrap().is_some() || Instant::now() >= deadline {
      let _ = child.kill();
      let _ = child.wait();
      let mut error = String::new();
      child
        .stderr
        .take()
        .unwrap()
        .take(4096)
        .read_to_string(&mut error)
        .unwrap();
      panic!("worker did not connect: {error}");
    }
    std::thread::sleep(Duration::from_millis(10));
  };
  stream
    .set_read_timeout(Some(Duration::from_secs(2)))
    .unwrap();
  let mut reply = [0u8; 4];
  stream.read_exact(&mut reply).unwrap();
  assert_eq!(&reply, b"PASS");
  assert!(child.wait().unwrap().success());
  if network {
    let (mut connection, _) = tcp.accept().unwrap();
    connection
      .set_read_timeout(Some(Duration::from_secs(1)))
      .unwrap();
    let mut message = [0u8; 7];
    connection.read_exact(&mut message).unwrap();
    assert_eq!(&message, b"NETWORK");
  } else {
    assert!(tcp.accept().is_err());
  }
  fs::write(root.join("passed"), reply).unwrap();
}

#[test]
fn supervised_worker_isolation() {
  if std::env::var("OMARCHY_TEST_SYSTEMD").as_deref() != Ok("1") {
    eprintln!("set OMARCHY_TEST_SYSTEMD=1 for temporary sandboxed user-service tests");
    return;
  }
  for network in [false, true] {
    let root = tempfile::tempdir().unwrap();
    fs::create_dir(root.path().join("bundle")).unwrap();
    fs::write(root.path().join("bundle/marker"), "approved").unwrap();
    let _denied = UnixListener::bind(root.path().join("bundle/denied")).unwrap();
    fs::create_dir(root.path().join("runtime")).unwrap();
    fs::write(root.path().join("runtime/marker"), "runtime").unwrap();
    let _runtime_denied = UnixListener::bind(root.path().join("runtime/denied")).unwrap();
    fs::create_dir(root.path().join("selected")).unwrap();
    fs::write(root.path().join("selected/allowed"), "selected data").unwrap();
    let _selected_denied = UnixListener::bind(root.path().join("selected/denied")).unwrap();
    let args = [
      OsString::from(format!(
        "OMARCHY_WORKER_TEST_ROOT={}",
        root.path().display()
      )),
      OsString::from(format!("OMARCHY_WORKER_TEST_NETWORK={}", u8::from(network))),
      std::env::current_exe().unwrap().into_os_string(),
      "--exact".into(),
      "controller_child".into(),
      "--nocapture".into(),
    ];
    let mut unit = Unit::start(
      Path::new("/usr/bin/env"),
      &args.iter().map(OsString::as_os_str).collect::<Vec<_>>(),
      limits(),
    )
    .unwrap();
    let deadline = Instant::now() + Duration::from_secs(8);
    while unit.running().unwrap() && Instant::now() < deadline {
      std::thread::sleep(Duration::from_millis(20));
    }
    unit.stop().unwrap();
    assert_eq!(fs::read(root.path().join("passed")).unwrap(), b"PASS");
    assert_eq!(
      fs::read_to_string(root.path().join("original/marker")).unwrap(),
      "approved"
    );
    assert_eq!(
      fs::read_to_string(root.path().join("selected/allowed")).unwrap(),
      "selected data"
    );
  }
}

#[test]
fn filesystem_grant_isolation() {
  if std::env::var("OMARCHY_TEST_SYSTEMD").as_deref() != Ok("1") {
    eprintln!("set OMARCHY_TEST_SYSTEMD=1 for temporary sandboxed user-service tests");
    return;
  }
  let root = tempfile::tempdir().unwrap();
  fs::create_dir(root.path().join("bundle")).unwrap();
  fs::write(root.path().join("bundle/marker"), "approved").unwrap();
  fs::create_dir(root.path().join("runtime")).unwrap();
  fs::create_dir(root.path().join("selected")).unwrap();
  fs::write(root.path().join("selected/allowed"), "selected data").unwrap();
  fs::create_dir(root.path().join("scratch-write")).unwrap();
  let args = [
    OsString::from(format!(
      "OMARCHY_WORKER_TEST_ROOT={}",
      root.path().display()
    )),
    OsString::from("OMARCHY_WORKER_TEST_NETWORK=0"),
    OsString::from("OMARCHY_WORKER_TEST_WRITE=1"),
    std::env::current_exe().unwrap().into_os_string(),
    "--exact".into(),
    "controller_child".into(),
    "--nocapture".into(),
  ];
  let mut unit = Unit::start(
    Path::new("/usr/bin/env"),
    &args.iter().map(OsString::as_os_str).collect::<Vec<_>>(),
    limits(),
  )
  .unwrap();
  let deadline = Instant::now() + Duration::from_secs(8);
  while unit.running().unwrap() && Instant::now() < deadline {
    std::thread::sleep(Duration::from_millis(20));
  }
  unit.stop().unwrap();
  assert_eq!(fs::read(root.path().join("passed")).unwrap(), b"PASS");
  // Host-side proof the writable grant's write landed on real host data.
  assert_eq!(
    fs::read_to_string(root.path().join("scratch-write/note")).unwrap(),
    "written"
  );
  // The read-only grant was never modified from the host side.
  assert_eq!(
    fs::read_to_string(root.path().join("selected/allowed")).unwrap(),
    "selected data"
  );
}
