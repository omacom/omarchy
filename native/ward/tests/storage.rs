use omarchy_ward::{
  exec_policy::PluginDir,
  grants::Grants,
  supervisor::{Limits, Unit, watchdog},
  worker,
};
use std::{
  ffi::{OsStr, OsString},
  fs::{self, File, OpenOptions},
  io::{Read, Write},
  os::{
    fd::AsRawFd,
    unix::{
      fs::{OpenOptionsExt, PermissionsExt},
      net::{UnixListener, UnixStream},
    },
  },
  path::Path,
  time::{Duration, Instant},
};

fn descriptor(path: &Path) -> File {
  OpenOptions::new()
    .read(true)
    .custom_flags(libc::O_PATH | libc::O_NOFOLLOW)
    .open(path)
    .unwrap()
}

#[test]
fn storage_worker_child() {
  if !Path::new("/bootstrap").exists() {
    return;
  }
  worker::restrict_bootstrap().unwrap();
  let phase = fs::read_to_string("/plugin/phase").unwrap();
  let save = Path::new("/home/plugin/.local/state/omarchy/save.json");
  assert!(!Path::new("/home/jacob").exists());
  match phase.as_str() {
    "write" => {
      assert!(!save.exists());
      fs::create_dir_all(save.parent().unwrap()).unwrap();
      fs::write(save.with_extension("next"), "first generation").unwrap();
      fs::rename(save.with_extension("next"), save).unwrap();
    }
    "read" => {
      assert_eq!(fs::read_to_string(save).unwrap(), "first generation");
      fs::write(save.with_extension("next"), "second generation").unwrap();
      fs::rename(save.with_extension("next"), save).unwrap();
    }
    "denied" => {
      assert!(!save.exists());
      assert!(std::env::var_os("OMARCHY_PLUGIN_DATA").is_none());
      fs::create_dir_all(save.parent().unwrap()).unwrap();
      fs::write(save, "ephemeral only").unwrap();
    }
    "restored" => assert_eq!(fs::read_to_string(save).unwrap(), "second generation"),
    _ => panic!("invalid fixture phase"),
  }
  if phase != "denied" {
    assert_eq!(
      UnixStream::connect(format!("/home/plugin/host-{phase}.socket"))
        .unwrap_err()
        .kind(),
      std::io::ErrorKind::PermissionDenied,
      "persistent data must not confer host IPC access"
    );
    let host_path = std::env::var("OMARCHY_PLUGIN_DATA").unwrap();
    assert!(host_path.ends_with("/omarchy/plugins/test.storage"));
    assert!(
      !Path::new(&host_path).exists(),
      "host spelling is not a second mount"
    );
  }
  UnixStream::connect("/run/plugin/wayland")
    .unwrap()
    .write_all(b"PASS")
    .unwrap();
}

#[test]
fn storage_controller_child() {
  let Some(root) = std::env::var_os("OMARCHY_STORAGE_TEST_ROOT") else {
    return;
  };
  let root = Path::new(&root);
  let phase = std::env::var("OMARCHY_STORAGE_TEST_PHASE").unwrap();
  let current = root.join(&phase);
  let granted = phase != "denied";
  let storage = granted.then(|| worker::storage_directory("test.storage").unwrap());
  let _host_socket = storage.as_ref().map(|directory| {
    // Use the pinned descriptor to stay below sockaddr_un's path limit.
    UnixListener::bind(format!(
      "/proc/self/fd/{}/host-{phase}.socket",
      directory.as_raw_fd()
    ))
    .unwrap()
  });
  if let Some(storage) = &storage {
    assert_eq!(
      storage.metadata().unwrap().permissions().mode() & 0o777,
      0o700
    );
  }
  let listener = UnixListener::bind(current.join("wayland")).unwrap();
  listener.set_nonblocking(true).unwrap();
  let mut child = worker::spawn(
    &descriptor(&std::env::current_exe().unwrap()),
    &descriptor(&current.join("bundle")),
    &descriptor(&current.join("wayland")),
    &[OsStr::new("--exact"), OsStr::new("storage_worker_child")],
    Limits::default(),
    &Grants {
      storage: granted,
      ..Default::default()
    },
    worker::Resources {
      storage: storage.as_ref(),
      paths: if granted {
        vec![PluginDir::data(
          worker::storage_directory_path("test.storage")
            .unwrap()
            .to_str()
            .unwrap()
            .into(),
        )]
      } else {
        vec![]
      },
      ..Default::default()
    },
  )
  .unwrap();
  let deadline = Instant::now() + Duration::from_secs(4);
  loop {
    watchdog().unwrap();
    if let Ok((mut stream, _)) = listener.accept() {
      stream
        .set_read_timeout(Some(Duration::from_secs(1)))
        .unwrap();
      let mut reply = [0; 4];
      stream.read_exact(&mut reply).unwrap();
      assert_eq!(&reply, b"PASS");
      assert!(child.wait().unwrap().success());
      fs::write(current.join("passed"), reply).unwrap();
      break;
    }
    if child.try_wait().unwrap().is_some() || Instant::now() > deadline {
      let _ = child.kill();
      let _ = child.wait();
      let mut log = String::new();
      child
        .stderr
        .take()
        .unwrap()
        .take(4096)
        .read_to_string(&mut log)
        .unwrap();
      panic!("storage worker did not finish: {log}");
    }
    std::thread::sleep(Duration::from_millis(10));
  }
}

#[test]
fn storage_survives_worker_and_controller_restarts_without_leaking_to_denied_home() {
  if std::env::var("OMARCHY_TEST_SYSTEMD").as_deref() != Ok("1") {
    return;
  }
  // Exercise disk-backed storage as well as the tmpfs-backed private fixtures.
  let data = tempfile::tempdir_in(env!("CARGO_MANIFEST_DIR")).unwrap();
  let root = tempfile::tempdir().unwrap();
  for phase in ["write", "read", "denied", "restored"] {
    let current = root.path().join(phase);
    fs::create_dir_all(current.join("bundle")).unwrap();
    fs::write(current.join("bundle/phase"), phase).unwrap();
    let args = [
      OsString::from(format!(
        "OMARCHY_STORAGE_TEST_ROOT={}",
        root.path().display()
      )),
      OsString::from(format!("XDG_STATE_HOME={}", data.path().display())),
      OsString::from(format!("OMARCHY_STORAGE_TEST_PHASE={phase}")),
      std::env::current_exe().unwrap().into_os_string(),
      "--exact".into(),
      "storage_controller_child".into(),
      "--nocapture".into(),
    ];
    let mut unit = Unit::start(
      Path::new("/usr/bin/env"),
      &args.iter().map(OsString::as_os_str).collect::<Vec<_>>(),
      Limits::default(),
    )
    .unwrap();
    let deadline = Instant::now() + Duration::from_secs(6);
    while unit.running().unwrap() && Instant::now() < deadline {
      std::thread::sleep(Duration::from_millis(20));
    }
    unit.stop().unwrap();
    assert_eq!(
      fs::read(current.join("passed")).unwrap(),
      b"PASS",
      "phase {phase}"
    );
  }
  assert_eq!(
    fs::read_to_string(
      data
        .path()
        .join("omarchy/plugins/test.storage/.local/state/omarchy/save.json")
    )
    .unwrap(),
    "second generation"
  );
}
