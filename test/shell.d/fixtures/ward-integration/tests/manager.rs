#[path = "../../../../../native/ward/tests/support/desktop.rs"]
mod desktop;
#[path = "support/operator.rs"]
mod operator;
use desktop::{Desktop, Host};
use omarchy_ward::presentation::Viewport;
use std::{
  fs,
  path::PathBuf,
  process::Command,
  sync::mpsc,
  time::{Duration, Instant},
};

enum Stage {
  Click(i32, i32),
  Capture(&'static str),
}

#[test]
fn graphical_installer_survives_real_shell_rescans_and_hands_off_to_review() {
  if std::env::var("OMARCHY_TEST_GRAPHICS").as_deref() != Ok("1")
    || std::env::var("OMARCHY_TEST_SYSTEMD").as_deref() != Ok("1")
  {
    return;
  }
  let module = std::env::var_os("OMARCHY_TEST_QT_BRIDGE").expect("select Qt module");
  let root = desktop::runtime();
  let repo = PathBuf::from(env!("CARGO_MANIFEST_DIR"))
    .join("../../../..")
    .canonicalize()
    .unwrap();
  let source = root.path().join("omarchy");
  fs::create_dir_all(source.join("shell/plugins/panels")).unwrap();
  fs::create_dir_all(source.join("config/omarchy")).unwrap();
  for name in ["Commons", "Ui", "services", "plugins/bar"] {
    std::os::unix::fs::symlink(
      repo.join("shell").join(name),
      source.join("shell").join(name),
    )
    .unwrap();
  }
  for name in ["bin", "default"] {
    std::os::unix::fs::symlink(repo.join(name), source.join(name)).unwrap();
  }
  // Real built-in panels, discovery, file watcher and reload lifecycle. Do not
  // stub rescanPlugins: that hid the destruction of an in-flight installer.
  for name in ["plugins", "plugin-review"] {
    assert!(
      Command::new("cp")
        .arg("-a")
        .arg(repo.join("shell/plugins/panels").join(name))
        .arg(source.join("shell/plugins/panels").join(name))
        .status()
        .unwrap()
        .success()
    );
  }
  let config = root.path().join("home/.config/omarchy/shell.json");
  fs::create_dir_all(config.parent().unwrap()).unwrap();
  let initial = r#"{"version":1,"bar":{"layout":{"left":[],"center":[],"right":[]}},"plugins":[]}"#;
  fs::write(&config, initial).unwrap();
  fs::write(source.join("config/omarchy/shell.json"), initial).unwrap();
  let host_qml = source.join("shell/shell.qml");
  let mut host = fs::read_to_string(repo.join("shell/shell.qml")).unwrap();
  let end = host.rfind('}').unwrap();
  host.insert_str(end, r##"
  IpcHandler {
    target: "manager-test"
    function setSource(source: string): string {
      shell.panelLoaders["omarchy.plugins"].item.model.source = source; return "ok"
    }
    function reviewState(): string {
      const reviewer = shell.panelLoaders["omarchy.plugin-review"]?.item
      if (!reviewer || !reviewer.opened) return JSON.stringify({visible:false, error:""})
      function find(items, name) {
        for (const item of items) {
          if (item.objectName === name) return item
          const found = find(item.children || [], name)
          if (found) return found
        }
        return null
      }
      const window = find(reviewer.data, "plugin-review-window")
      function point(name) {
        const item = find(window.contentItem, name)
        const p = item.mapToItem(null, item.width / 2, item.height / 2)
        return [Math.round(p.x), Math.round(p.y)]
      }
      return JSON.stringify({visible:true, stage:reviewer.review.stage, busy:reviewer.review.busy,
        error:reviewer.review.error, revision:reviewer.review.revision,
        close:point("review-close"), enable:point("review-approve")})
    }
    function managerState(): string {
      const reviewer = shell.panelLoaders["omarchy.plugin-review"]?.item
      const review = reviewer && reviewer.opened ? reviewer.review : null
      const manager = shell.panelLoaders["omarchy.plugins"]?.item
      if (!manager) return JSON.stringify({error:"", gone:true, reviewId:review ? review.pluginId : ""})
      function find(items, name) {
        for (const item of items) {
          if (item.objectName === name) return item
          const found = find(item.children || [], name)
          if (found) return found
        }
        return null
      }
      const window = find(manager.data, "plugin-manager-window")
      function point(name) {
        const item = find(window.contentItem, name)
        if (!item) return null
        const p = item.mapToItem(null, item.width / 2, item.height / 2)
        return [Math.round(p.x), Math.round(p.y)]
      }
      const model = manager.model
      const add = find(window.contentItem, "plugin-add")
      return JSON.stringify({gone:false, visible:manager.opened, reviewId:review ? review.pluginId : "",
        busy:model.busy, error:model.error, inspected:model.inspected, adding:model.adding,
        yolo:model.yolo, confirmed:model.trustConfirmed, confirmation:manager.confirmYolo, selected:model.selectedId,
        plugins:model.plugins, confirmRemove:model.confirmRemove,
        wardRow:point("plugin-row-test.manager-ward"), yoloRow:point("plugin-row-test.manager-yolo"),
        disable:point("plugin-disable"), remove:point("plugin-remove"),
        addEnabled:add.enabled, hasValidate:!!find(window.contentItem, "plugin-validate"), add:point("plugin-add"),
        mode:point("plugin-yolo"), trust:point("plugin-trust-confirm"), cancelTrust:point("plugin-trust-cancel")})
    }
  }
"##);
  fs::write(&host_qml, host).unwrap();
  let env = operator::environment(root.path(), &source, &host_qml, &module);
  let mut sources = vec![];
  for (id, ward) in [("test.manager-ward", true), ("test.manager-yolo", false)] {
    let source = root.path().join(id);
    fs::create_dir(&source).unwrap();
    let mut manifest = serde_json::json!({"schemaVersion":1,"id":id,"name":if ward {"Ward example"} else {"YOLO example"},"version":"1","kinds":["bar-widget"],"entryPoints":{"barWidget":"Widget.qml"}});
    if ward {
      manifest["sandbox"] = serde_json::json!({"version":1,"requests":{}});
    }
    fs::write(
      source.join("manifest.json"),
      serde_json::to_vec(&manifest).unwrap(),
    )
    .unwrap();
    fs::write(source.join("Widget.qml"), "import QtQuick\nItem {}\n").unwrap();
    for args in [
      vec!["init", "--template=", "-q"],
      vec!["add", "."],
      vec![
        "-c",
        "core.hooksPath=/dev/null",
        "-c",
        "commit.gpgsign=false",
        "-c",
        "user.name=Test",
        "-c",
        "user.email=test@example.com",
        "commit",
        "-qm",
        "fixture",
      ],
    ] {
      assert!(
        Command::new("git")
          .arg("-C")
          .arg(&source)
          .args(args)
          .envs(env.iter().cloned())
          .status()
          .unwrap()
          .success()
      );
    }
    sources.push(source);
  }
  let mut display = Desktop::new(
    root.path(),
    Viewport {
      width: 900,
      height: 800,
      scale_fixed: 120,
    },
  );
  let log = root.path().join("host.log");
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
  let (ack, wait_ack) = mpsc::channel();
  let installed_ward = config.parent().unwrap().join("plugins/test.manager-ward");
  let operator = std::thread::spawn(move || {
    let run = |args: &[&str]| operator::run(&env, "omarchy-shell", args);
    let start = Instant::now();
    loop {
      let ready = Command::new("timeout")
        .args(["1s", "omarchy-shell", "shell", "ping"])
        .envs(env.iter().cloned())
        .output()
        .unwrap()
        .status
        .success();
      if ready && run(&["shell", "listPlugins"]).contains("omarchy.plugins") {
        break;
      }
      assert!(
        start.elapsed() < Duration::from_secs(10),
        "manager host did not start"
      );
      std::thread::sleep(Duration::from_millis(25));
    }
    let state = || {
      serde_json::from_str::<serde_json::Value>(&run(&["manager-test", "managerState"])).unwrap()
    };
    let wait = |predicate: &dyn Fn(&serde_json::Value) -> bool| {
      let start = Instant::now();
      loop {
        let value = state();
        assert_eq!(value["error"], "", "manager command failed: {value}");
        if predicate(&value) {
          return value;
        }
        assert!(
          start.elapsed() < Duration::from_secs(10),
          "manager stalled: {value}"
        );
        std::thread::sleep(Duration::from_millis(30));
      }
    };
    let click = |value: &serde_json::Value, name: &str| {
      let point = value[name].as_array().unwrap();
      send
        .send(Stage::Click(
          point[0].as_i64().unwrap() as i32,
          point[1].as_i64().unwrap() as i32,
        ))
        .unwrap();
    };
    let capture = |name| {
      send.send(Stage::Capture(name)).unwrap();
      wait_ack.recv_timeout(Duration::from_secs(5)).unwrap();
    };
    let review_state = || serde_json::from_str::<serde_json::Value>(&run(&["manager-test", "reviewState"])).unwrap();
    let wait_review = |visible: bool| {
      let started = Instant::now();
      loop {
        let state = review_state();
        assert_eq!(state["error"], "", "review failed: {state}");
        if state["visible"] == visible && (!visible || state["busy"] == false) { return state; }
        assert!(started.elapsed() < Duration::from_secs(15), "review stalled: {state}");
        std::thread::sleep(Duration::from_millis(30));
      }
    };
    for (index, source) in sources.iter().enumerate() {
      assert_eq!(
        run(&["shell", "summon", "omarchy.plugins", "{\"add\":true}"]).trim(),
        "ok"
      );
      wait(&|state| state["busy"] == false);
      run(&["manager-test", "setSource", source.to_str().unwrap()]);
      if index == 1 {
        click(&state(), "mode");
        wait(&|state| state["yolo"] == true);
      }
      let ready = wait(&|state| state["addEnabled"] == true);
      assert_eq!(ready["hasValidate"], false, "separate validation control remains");
      assert_eq!(ready["inspected"], serde_json::Value::Null);
      capture(if index == 0 {
        "manager-ward-add"
      } else {
        "manager-yolo-warning"
      });
      if index == 1 {
        assert_eq!(ready["confirmed"], false);
        click(&ready, "add");
        let confirmation = wait(&|state| state["confirmation"] == true);
        assert_eq!(confirmation["busy"], false, "YOLO must not clone before final confirmation");
        assert_eq!(confirmation["inspected"], serde_json::Value::Null);
        capture("manager-yolo-unconfirmed");
        click(&confirmation, "cancelTrust");
        let canceled = wait(&|state| state["confirmation"] == false);
        assert_eq!(canceled["confirmed"], false);
        assert_eq!(canceled["busy"], false);
        click(&canceled, "add");
        let confirmation = wait(&|state| state["confirmation"] == true);
        capture("manager-yolo-confirmation");
        click(&confirmation, "trust");
      } else {
        capture("manager-ward-ready");
        click(&state(), "add");
      }
      if index == 0 {
        wait(&|state| state["reviewId"] == "test.manager-ward");
      } else {
        wait(&|state| {
          state["visible"] == true
            && state["adding"] == false
            && state["busy"] == false
            && state["selected"] == "test.manager-yolo"
        });
      }
      capture(if index == 0 {
        "manager-ward-staged"
      } else {
        "manager-yolo-installed"
      });
      // Exercise a second explicit scan after the watcher/CLI races settle.
      // Built-in review and manager state must remain visible throughout.
      run(&["shell", "rescanPlugins"]);
      std::thread::sleep(Duration::from_millis(500));
      if index == 0 {
        assert_eq!(
          state()["reviewId"],
          "test.manager-ward",
          "rescan lost review handoff"
        );
        let staged = wait_review(true);
        assert!(!installed_ward.exists(), "review prematurely installed the plugin");
        let first_stage = staged["stage"].as_str().unwrap().to_owned();
        let first_path = installed_ward.parent().unwrap().join(&first_stage);
        assert!(first_path.is_dir());
        click(&staged, "close");
        wait_review(false);
        run(&["shell", "summon", "omarchy.plugins", "{\"add\":true}"]);
        wait(&|state| state["busy"] == false);
        run(&["manager-test", "setSource", source.to_str().unwrap()]);
        click(&wait(&|state| state["addEnabled"] == true), "add");
        wait(&|state| state["reviewId"] == "test.manager-ward");
        let retried = wait_review(true);
        assert_ne!(retried["stage"].as_str().unwrap(), first_stage);
        assert!(!first_path.exists(), "closing review did not discard its own temporary checkout");
        assert!(!installed_ward.exists(), "retry prematurely installed the plugin");
        capture("manager-ward-retried");
        click(&retried, "enable");
        wait_review(false);
        assert!(installed_ward.join("manifest.json").is_file(), "Enable did not publish the reviewed checkout");
      } else {
        assert_eq!(
          state()["selected"],
          "test.manager-yolo",
          "rescan lost installed selection"
        );
      }
    }
    let records: serde_json::Value = serde_json::from_str(&operator::run(
      &env,
      "omarchy-plugin-installation",
      &["list"],
    ))
    .unwrap();
    assert!(
      records
        .as_array()
        .unwrap()
        .iter()
        .any(|row| row["id"] == "test.manager-yolo" && row["mode"] == "yolo")
    );
    assert!(
      records
        .as_array()
        .unwrap()
        .iter()
        .any(|row| row["id"] == "test.manager-ward" && row["mode"] == "ward")
    );
    // Exercise the actual manager buttons, including the user's two-action
    // Ward workflow. CLI-only removal missed retained identities in this list.
    for (id, row) in [("test.manager-ward", "wardRow"), ("test.manager-yolo", "yoloRow")] {
      let data_root = PathBuf::from(&env.iter().find(|(name, _)| *name == "XDG_STATE_HOME").unwrap().1).join("omarchy");
      let store = PathBuf::from(&env.iter().find(|(name, _)| *name == "OMARCHY_WARD_STORE").unwrap().1);
      let data = data_root.join("plugins").join(id);
      fs::create_dir_all(&data).unwrap();
      fs::write(data.join("saved.json"), "saved state").unwrap();
      click(&wait(&|state| state["busy"] == false), row);
      let selected = wait(&|state| state["selected"] == id && state["busy"] == false);
      if id == "test.manager-ward" {
        assert!(selected["plugins"].as_array().unwrap().iter().any(|plugin| plugin["id"] == id && plugin["enabled"] == true && plugin["approved"] == true));
        click(&selected, "disable");
        wait(&|state| state["busy"] == false && state["plugins"].as_array().unwrap().iter().any(|plugin| plugin["id"] == id && plugin["enabled"] == false && plugin["approved"] == false));
        assert!(data.join("saved.json").exists() && store.join(format!("{id}.json")).exists(), "disable must retain saved data and permission history");
        capture("manager-ward-disabled");
      }
      click(&state(), "remove");
      let confirmation = wait(&|state| state["confirmRemove"] == true && state["busy"] == false);
      capture(if id == "test.manager-ward" { "manager-ward-remove-confirmation" } else { "manager-yolo-remove-confirmation" });
      assert!(confirmation["plugins"].as_array().unwrap().iter().any(|plugin| plugin["id"] == id));
      click(&confirmation, "remove");
      let removed = wait(&|state| state["busy"] == false && state["selected"] == "" && state["plugins"].as_array().unwrap().iter().all(|plugin| plugin["id"] != id));
      assert_eq!(removed["visible"], true, "removal destroyed the manager");
      assert!(!installed_ward.parent().unwrap().join(id).exists());
      let catalog: serde_json::Value = serde_json::from_str(&operator::run(&env, "omarchy-plugin-list", &["--json"])).unwrap();
      assert!(catalog.as_array().unwrap().iter().all(|plugin| plugin["id"] != id), "removal retained a security or installation record");
      assert!(!data.exists());
      assert!(!data_root.join("plugin-installations").join(id).exists());
      assert!(!data_root.join("plugin-isolation").join(id).exists());
      assert!(!store.join("identities").join(id).exists());
      assert!(!store.join(format!("{id}.json")).exists());
      capture(if id == "test.manager-ward" { "manager-ward-removed" } else { "manager-empty" });
    }
    run(&["shell", "rescanPlugins"]);
    run(&["shell", "hide", "omarchy.plugins"]);
    run(&["shell", "summon", "omarchy.plugins", "{}"]);
    wait(&|state| state["busy"] == false && state["plugins"].as_array().unwrap().is_empty());
  });
  let start = Instant::now();
  let mut capture = None;
  let mut frame = None;
  while !operator.is_finished() || capture.is_some() {
    let time = start.elapsed().as_millis() as u32;
    while let Ok(stage) = receive.try_recv() {
      match stage {
        Stage::Click(x, y) => {
          for kind in [0, 1] {
            display.graphics.input(kind, 0x110, x, y, time).unwrap();
          }
        }
        Stage::Capture(name) => capture = Some((name, Instant::now())),
      }
    }
    for next in display.step(time) {
      frame = Some(next);
    }
    if let (Some((name, requested)), Some(frame)) = (capture, &frame) {
      if requested.elapsed() > Duration::from_millis(350) {
        if let Some(directory) = std::env::var_os("OMARCHY_TEST_SURFACE_FRAMES") {
          frame.save(PathBuf::from(directory).join(format!("{name}.ppm")));
        }
        capture = None;
        ack.send(()).unwrap();
      }
    }
    assert!(
      start.elapsed() < Duration::from_secs(60),
      "manager fixture timed out: {}",
      fs::read_to_string(&log).unwrap()
    );
    std::thread::sleep(Duration::from_millis(5));
  }
  assert!(
    operator.join().is_ok(),
    "manager operator failed: {}",
    fs::read_to_string(&log).unwrap()
  );
}
