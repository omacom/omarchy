#[path = "../../../../../native/ward/tests/support/desktop.rs"]
mod desktop;
#[path = "support/operator.rs"]
mod operator;
use desktop::{Desktop, Host};
use omarchy_ward::{grants::Grants, presentation::Viewport, revision::Revision, store::Store};
use std::{
  fs,
  path::PathBuf,
  process::Command,
  sync::mpsc,
  time::{Duration, Instant},
};

struct Admission(Store);
impl Drop for Admission {
  fn drop(&mut self) {
    for id in ["test.failed-start", "test.no-frame"] {
      let _ = self.0.revoke(id);
    }
  }
}

#[test]
fn failed_and_never_presenting_startups_preserve_config_and_allow_retry() {
  if std::env::var("OMARCHY_TEST_GRAPHICS").as_deref() != Ok("1")
    || std::env::var("OMARCHY_TEST_SYSTEMD").as_deref() != Ok("1")
  {
    return;
  }
  let Some(module) = std::env::var_os("OMARCHY_TEST_QT_BRIDGE") else {
    return;
  };
  let root = desktop::runtime();
  let repo = PathBuf::from(env!("CARGO_MANIFEST_DIR"))
    .join("../../../..")
    .canonicalize()
    .unwrap();
  let source = root.path().join("omarchy");
  fs::create_dir_all(source.join("shell/plugins")).unwrap();
  fs::create_dir_all(source.join("config/omarchy")).unwrap();
  fs::copy(repo.join("shell/shell.qml"), source.join("shell/shell.qml")).unwrap();
  for name in ["Commons", "Ui", "services", "plugins/bar"] {
    std::os::unix::fs::symlink(
      repo.join("shell").join(name),
      source.join("shell").join(name),
    )
    .unwrap();
  }
  std::os::unix::fs::symlink(repo.join("bin"), source.join("bin")).unwrap();
  std::os::unix::fs::symlink(repo.join("default"), source.join("default")).unwrap();
  let config = root.path().join("home/.config/omarchy/shell.json");
  fs::create_dir_all(config.parent().unwrap()).unwrap();
  let initial = serde_json::to_vec(&serde_json::json!({
    "version":1, "bar":{"position":"top", "layout":{"left":[{"id":"test.anchor"}],"center":[],"right":[]}},
    "plugins":[], "unrelated":{"keep":42}
  }))
  .unwrap();
  fs::write(&config, &initial).unwrap();
  fs::write(source.join("config/omarchy/shell.json"), &initial).unwrap();
  let plugins = config.parent().unwrap().join("plugins");
  let anchor = plugins.join("test.anchor");
  fs::create_dir_all(&anchor).unwrap();
  fs::write(
    anchor.join("manifest.json"),
    serde_json::to_vec(&serde_json::json!({
      "schemaVersion":1,"id":"test.anchor","name":"Host anchor","version":"1",
      "kinds":["bar-widget"],"entryPoints":{"barWidget":"Widget.qml"}
    }))
    .unwrap(),
  )
  .unwrap();
  fs::write(anchor.join("Widget.qml"), "import QtQuick\nItem { implicitWidth: 40; implicitHeight: 26; Rectangle { anchors.fill: parent; color: \"#aabbcc\" } }\n").unwrap();
  let admission = Admission(Store::initialize(&root.path().join("state")).unwrap());
  for (id, custom, qml) in [
    (
      "test.failed-start",
      false,
      "import QtQuick\nItem { MissingStartupType {} }\n",
    ),
    ("test.no-frame", true, "import Quickshell\nShellRoot {}\n"),
  ] {
    let plugin = plugins.join(id);
    fs::create_dir_all(&plugin).unwrap();
    let mut manifest = serde_json::json!({
      "schemaVersion":1,"id":id,"name":id,"version":"1","kinds":["bar-widget"],
      "entryPoints":{"barWidget":"Widget.qml"},"sandbox":{"version":1,"requests":{}}
    });
    if custom {
      manifest["kinds"] = serde_json::json!(["panel"]);
      manifest["entryPoints"] = serde_json::json!({"panel":"Widget.qml"});
      manifest["sandbox"]["entryPoint"] = "Widget.qml".into();
    }
    fs::write(
      plugin.join("manifest.json"),
      serde_json::to_vec(&manifest).unwrap(),
    )
    .unwrap();
    fs::write(plugin.join("Widget.qml"), qml).unwrap();
    let revision = Revision::import(&plugin, &admission.0.revisions()).unwrap();
    admission
      .0
      .approve(&revision.digest, Grants::default())
      .unwrap();
  }
  let host_qml = source.join("shell/shell.qml");
  let env = operator::environment(root.path(), &source, &host_qml, &module);
  let log = root.path().join("host.log");
  let mut display = Desktop::new(
    root.path(),
    Viewport {
      width: 800,
      height: 500,
      scale_fixed: 120,
    },
  );
  let _host = Host(
    desktop::command(root.path(), &host_qml, &module)
      .envs(env.iter().cloned())
      .env_remove("HYPRLAND_INSTANCE_SIGNATURE")
      .stdout(fs::File::create(&log).unwrap())
      .stderr(fs::File::options().append(true).open(&log).unwrap())
      .spawn()
      .unwrap(),
  );
  let (send, receive) = mpsc::channel();
  let (ack, wait) = mpsc::channel();
  let operator = std::thread::spawn(move || {
    let run = |name, args: &[&str]| operator::run(&env, name, args);
    let deadline = Instant::now() + Duration::from_secs(8);
    loop {
      let result = Command::new("/usr/bin/timeout")
        .args(["1s", "omarchy-shell", "shell", "listPlugins"])
        .envs(env.iter().cloned())
        .output()
        .unwrap();
      if result.status.success()
        && String::from_utf8_lossy(&result.stdout).contains("test.no-frame")
      {
        break;
      }
      assert!(
        Instant::now() < deadline,
        "private shell did not scan startup fixtures"
      );
      std::thread::sleep(Duration::from_millis(25));
    }
    let stage = |name| {
      send.send(name).unwrap();
      wait.recv_timeout(Duration::from_secs(5)).unwrap();
    };
    for id in ["test.failed-start", "test.no-frame"] {
      assert_eq!(
        run("omarchy-shell", &["shell", "enablePlugin", id, "{}"]).trim(),
        "starting"
      );
      assert_eq!(
        fs::read(&config).unwrap(),
        initial,
        "pending startup changed saved config"
      );
      let deadline = Instant::now() + Duration::from_secs(12);
      loop {
        let status: serde_json::Value =
          serde_json::from_str(&run("omarchy-shell", &["shell", "pluginStatus", id])).unwrap();
        assert_ne!(status["state"], "running", "failed worker became enabled");
        if status["state"] == "error" {
          assert!(!status["error"].as_str().unwrap().is_empty());
          if id == "test.no-frame" {
            assert!(status["error"].as_str().unwrap().contains("timed out"));
          }
          break;
        }
        assert!(
          Instant::now() < deadline,
          "failed startup never settled: {status}"
        );
        std::thread::sleep(Duration::from_millis(30));
      }
      assert_eq!(
        fs::read(&config).unwrap(),
        initial,
        "failed startup changed saved config"
      );
      let deadline = Instant::now() + Duration::from_secs(3);
      loop {
        let record = admission.0.read(id).unwrap();
        assert!(
          record.enabled,
          "startup failure revoked an unrelated approval"
        );
        if record.active_unit.is_none() {
          break;
        }
        assert!(
          Instant::now() < deadline,
          "failed startup retained its active unit"
        );
        std::thread::sleep(Duration::from_millis(20));
      }
      stage(if id == "test.no-frame" {
        "startup-timeout"
      } else {
        "startup-failed"
      });
    }
    // Repair and review the same identity. A prior failure is not permanent,
    // and retry must still use the immutable reviewed revision.
    let plugin = plugins.join("test.failed-start");
    fs::write(
      plugin.join("Widget.qml"),
      r##"import QtQuick
Item {
  property var bar
  property var settings
  implicitWidth: 40; implicitHeight: 26
  Rectangle { anchors.fill: parent; color: "#44ee22" }
}
"##,
    )
    .unwrap();
    let revision = Revision::import(&plugin, &admission.0.revisions()).unwrap();
    admission
      .0
      .approve(&revision.digest, Grants::default())
      .unwrap();
    run(
      "omarchy-plugin-enable",
      &["test.failed-start", "--section", "right"],
    );
    let deadline = Instant::now() + Duration::from_secs(3);
    loop {
      let saved: serde_json::Value = serde_json::from_slice(&fs::read(&config).unwrap()).unwrap();
      if saved["bar"]["layout"]["right"]
        == serde_json::json!([{"id":"test.failed-start","sandbox":true}])
      {
        assert_eq!(saved["unrelated"]["keep"], 42);
        assert_eq!(saved["plugins"], serde_json::json!([]));
        break;
      }
      assert!(
        Instant::now() < deadline,
        "successful startup was not saved: {saved}"
      );
      std::thread::sleep(Duration::from_millis(20));
    }
    stage("startup-retried");
    run("omarchy-plugin-disable", &["test.failed-start"]);
    stage("startup-disabled");
  });
  let start = Instant::now();
  let mut stage = None;
  let mut last_frame = None;
  while !operator.is_finished() || stage.is_some() {
    if let Ok(next) = receive.try_recv() {
      stage = Some(next);
    }
    for frame in display.step(start.elapsed().as_millis() as u32) {
      last_frame = Some(frame);
    }
    if let (Some(name), Some(frame)) = (stage, &last_frame) {
      let green = frame.count([0x44, 0xee, 0x22]);
      if (name == "startup-retried" && green >= 100) || (name != "startup-retried" && green == 0) {
        if let Some(directory) = std::env::var_os("OMARCHY_TEST_SURFACE_FRAMES") {
          frame.save(PathBuf::from(directory).join(format!("{name}.ppm")));
        }
        stage = None;
        ack.send(()).unwrap();
      }
    }
    assert!(
      start.elapsed() < Duration::from_secs(45),
      "startup fixture timed out: {}",
      fs::read_to_string(&log).unwrap()
    );
    std::thread::sleep(Duration::from_millis(5));
  }
  if operator.join().is_err() {
    if let (Some(frame), Some(directory)) =
      (last_frame, std::env::var_os("OMARCHY_TEST_SURFACE_FRAMES"))
    {
      frame.save(PathBuf::from(directory).join("startup-failure.ppm"));
    }
    panic!(
      "startup operator failed: {}",
      fs::read_to_string(&log).unwrap()
    );
  }
}
