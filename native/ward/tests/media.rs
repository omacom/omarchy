mod support;
use omarchy_ward::{
  grants::{Access, FileSystemGrant, Grants, Target},
  media::MediaProxy,
  supervisor::{Limits, Unit},
  worker,
};
use std::{
  ffi::{OsStr, OsString},
  fs,
  io::{Read, Write},
  os::unix::{
    fs::PermissionsExt,
    net::{UnixListener, UnixStream},
  },
  path::Path,
  time::{Duration, Instant},
};
use support::{ALIAS, OBJECT, OTHER, SELECTED, call, path_fd};

#[test]
fn media_worker_child() {
  if !Path::new("/bootstrap").exists() {
    return;
  }
  worker::restrict_bootstrap().unwrap();
  let address = std::env::var("DBUS_SESSION_BUS_ADDRESS").unwrap();
  assert_eq!(address, "unix:path=/run/plugin/media");
  let mut display = UnixStream::connect("/run/plugin/wayland").unwrap();
  display
    .set_read_timeout(Some(Duration::from_secs(2)))
    .unwrap();
  let result = std::panic::catch_unwind(|| {
    let selected_owner = fs::read_to_string("/plugin/selected").unwrap();
    let other_owner = fs::read_to_string("/plugin/other").unwrap();
    let player = "org.mpris.MediaPlayer2.Player";
    for name in [SELECTED, selected_owner.as_str()] {
      assert!(
        call(&address, name, OBJECT, player, "PlayPause", &[])
          .status
          .success()
      );
      let properties = call(
        &address,
        name,
        OBJECT,
        "org.freedesktop.DBus.Properties",
        "GetAll",
        &["s", player],
      );
      assert!(
        properties.status.success(),
        "property read denied: {}",
        String::from_utf8_lossy(&properties.stderr)
      );
      assert!(String::from_utf8_lossy(&properties.stdout).contains("Sandbox track"));
      // Check after allowed calls too: acquiring visibility must not turn a
      // method-filtered unique owner into an unrestricted service connection.
      for (path, interface, method) in [
        (OBJECT, player, "OpenUri"),
        (OBJECT, "org.mpris.MediaPlayer2", "Quit"),
        (OBJECT, "org.mpris.MediaPlayer2", "Raise"),
        (OBJECT, "org.freedesktop.DBus.Properties", "Set"),
        (OBJECT, "org.example.Unrelated", "Unsafe"),
        ("/different", player, "PlayPause"),
      ] {
        assert!(
          !call(&address, name, path, interface, method, &[])
            .status
            .success(),
          "unexpected authority: {name} {interface}.{method}"
        );
      }
    }
    for name in [
      OTHER,
      ALIAS,
      other_owner.as_str(),
      "org.freedesktop.Notifications",
    ] {
      assert!(
        !call(&address, name, OBJECT, player, "PlayPause", &[])
          .status
          .success(),
        "unselected name accessible: {name}"
      );
    }
    let names = call(
      &address,
      "org.freedesktop.DBus",
      "/org/freedesktop/DBus",
      "org.freedesktop.DBus",
      "ListNames",
      &[],
    );
    assert!(names.status.success());
    let names = String::from_utf8(names.stdout).unwrap();
    assert!(names.contains(SELECTED) && !names.contains(OTHER) && !names.contains(ALIAS));
    assert!(
      !call(
        &address,
        "org.freedesktop.DBus",
        "/org/freedesktop/DBus",
        "org.freedesktop.DBus",
        "RequestName",
        &["su", "org.mpris.MediaPlayer2.Impostor", "0"]
      )
      .status
      .success()
    );
    assert!(
      !call(
        &address,
        "org.freedesktop.DBus",
        "/org/freedesktop/DBus",
        "org.freedesktop.DBus.Monitoring",
        "BecomeMonitor",
        &["asu", "0", "0"]
      )
      .status
      .success()
    );
    assert_eq!(
      UnixStream::connect("/grants/bus/bus")
        .unwrap_err()
        .raw_os_error(),
      Some(libc::EACCES)
    );
    std::os::unix::fs::symlink("/grants/bus/bus", "/tmp/bus").unwrap();
    assert_eq!(
      UnixStream::connect("/tmp/bus").unwrap_err().raw_os_error(),
      Some(libc::EACCES)
    );
  });
  if result.is_err() {
    display.write_all(b"FAIL").unwrap();
    return;
  }
  let mut connected = UnixStream::connect("/run/plugin/media").unwrap();
  connected
    .set_read_timeout(Some(Duration::from_secs(1)))
    .unwrap();
  display.write_all(b"PASS").unwrap();
  let mut byte = [0];
  display.read_exact(&mut byte).unwrap();
  assert_eq!(byte, [b'R']);
  assert_eq!(
    connected.read(&mut byte).unwrap(),
    0,
    "old proxy connection survived shutdown"
  );
  assert!(
    !call(
      &address,
      SELECTED,
      OBJECT,
      "org.mpris.MediaPlayer2.Player",
      "PlayPause",
      &[]
    )
    .status
    .success()
  );
  display.write_all(b"GONE").unwrap();
}

#[test]
fn media_controller_child() {
  let Some(root) = std::env::var_os("OMARCHY_MEDIA_TEST_ROOT") else {
    return;
  };
  let root = Path::new(&root);
  let address = std::env::var("OMARCHY_MEDIA_TEST_BUS").unwrap();
  let proxy = MediaProxy::start(&address, root, SELECTED, Limits::default()).unwrap();
  let listener = UnixListener::bind(root.join("wayland")).unwrap();
  listener.set_nonblocking(true).unwrap();
  let mut grants = Grants {
    media: Some(SELECTED.into()),
    ..Grants::default()
  };
  grants.filesystem.insert(
    "bus".into(),
    FileSystemGrant::select(
      Path::new(address.strip_prefix("unix:path=").unwrap())
        .parent()
        .unwrap(),
      Access::Read,
      Target::Directory,
    )
    .unwrap(),
  );
  let mut child = support::Process(
    worker::spawn(
      &path_fd(&std::env::current_exe().unwrap()),
      &path_fd(&root.join("bundle")),
      &path_fd(&root.join("wayland")),
      &[
        OsStr::new("--exact"),
        OsStr::new("media_worker_child"),
        OsStr::new("--nocapture"),
      ],
      Limits::default(),
      &grants,
      worker::Resources {
            audio: None,
            network_proxy: None,
        render_node: None,
        media: Some(&proxy),
        requests: None,
        runtime: None,
        context: None,
        grants_json: None,
        storage: None,
        paths: vec![],
      },
    )
    .unwrap(),
  );
  let deadline = Instant::now() + Duration::from_secs(3);
  let mut connection = loop {
    if let Ok((stream, _)) = listener.accept() {
      break stream;
    }
    assert!(
      Instant::now() < deadline && child.0.try_wait().unwrap().is_none(),
      "media worker did not connect"
    );
    std::thread::sleep(Duration::from_millis(5));
  };
  connection
    .set_read_timeout(Some(Duration::from_secs(3)))
    .unwrap();
  let mut result = [0; 4];
  connection.read_exact(&mut result).unwrap();
  if &result != b"PASS" {
    let _ = child.0.wait();
    let mut log = String::new();
    if let Some(stderr) = &mut child.0.stderr {
      stderr.read_to_string(&mut log).unwrap();
    }
    panic!("media worker failed: {log}");
  }
  drop(proxy);
  connection.write_all(b"R").unwrap();
  connection.read_exact(&mut result).unwrap();
  assert_eq!(&result, b"GONE");
  fs::write(root.join("passed"), result).unwrap();
}

#[test]
fn selected_media_is_filtered_inside_the_worker_and_disconnects_on_shutdown() {
  let Some(player) = std::env::var_os("OMARCHY_TEST_MEDIA_PLAYER") else {
    eprintln!("set OMARCHY_TEST_MEDIA_PLAYER to the built private player fixture");
    return;
  };
  if std::env::var("OMARCHY_TEST_SYSTEMD").as_deref() != Ok("1") {
    return;
  }
  let bus = support::Bus::new(&player);
  // The trusted fake service accepts these. Rejection in the worker therefore
  // proves filtering rather than missing methods or absent destinations.
  for name in [SELECTED, OTHER, ALIAS] {
    assert!(
      call(
        &bus.address,
        name,
        OBJECT,
        "org.mpris.MediaPlayer2.Player",
        "OpenUri",
        &[]
      )
      .status
      .success()
    );
  }
  let root = tempfile::Builder::new()
    .permissions(fs::Permissions::from_mode(0o700))
    .tempdir()
    .unwrap();
  fs::create_dir(root.path().join("bundle")).unwrap();
  fs::write(root.path().join("bundle/selected"), &bus.selected_owner).unwrap();
  fs::write(root.path().join("bundle/other"), &bus.other_owner).unwrap();
  let args = [
    OsString::from(format!("OMARCHY_MEDIA_TEST_ROOT={}", root.path().display())),
    OsString::from(format!("OMARCHY_MEDIA_TEST_BUS={}", bus.address)),
    std::env::current_exe().unwrap().into_os_string(),
    "--exact".into(),
    "media_controller_child".into(),
    "--nocapture".into(),
  ];
  let mut unit = Unit::start(
    Path::new("/usr/bin/env"),
    &args.iter().map(OsString::as_os_str).collect::<Vec<_>>(),
    Limits::default(),
  )
  .unwrap();
  let deadline = Instant::now() + Duration::from_secs(7);
  while unit.running().unwrap() && Instant::now() < deadline {
    std::thread::sleep(Duration::from_millis(10));
  }
  unit.stop().unwrap();
  let result = fs::read(root.path().join("passed")).unwrap_or_else(|error| {
    let log = std::process::Command::new("journalctl")
      .args(["--user", "--no-pager", "-n", "40", "-u", unit.name()])
      .output()
      .unwrap();
    panic!(
      "media controller failed: {error}\n{}",
      String::from_utf8_lossy(&log.stdout)
    );
  });
  assert_eq!(result, b"GONE");
  // Proxy teardown cannot stop the selected service or unrelated bus clients.
  assert!(
    call(
      &bus.address,
      OTHER,
      OBJECT,
      "org.mpris.MediaPlayer2.Player",
      "PlayPause",
      &[]
    )
    .status
    .success()
  );
}
