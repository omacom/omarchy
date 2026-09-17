#[path = "../../../../../native/ward/tests/support/desktop.rs"]
mod desktop;
#[path = "support/operator.rs"]
mod operator;
use desktop::{Desktop, Host};
use omarchy_ward::{controller::Scroll, presentation::Viewport};
use std::{
  fs,
  path::PathBuf,
  process::Command,
  sync::mpsc,
  time::{Duration, Instant},
};

#[test]
fn commands_activate_the_shell_host_with_click_through_and_revocation() {
  activation(false);
}

#[test]
fn graphical_review_approves_only_selected_access_before_enabling() {
  activation(true);
}

enum Stage {
  Click(i32, i32),
  Scroll(i32),
  Capture(&'static str),
  Enabled,
  Disabled,
}

fn activation(review_ui: bool) {
  let Some(module) = std::env::var_os("OMARCHY_TEST_QT_BRIDGE") else {
    return;
  };
  if std::env::var("OMARCHY_TEST_GRAPHICS").as_deref() != Ok("1")
    || std::env::var("OMARCHY_TEST_SYSTEMD").as_deref() != Ok("1")
  {
    return;
  }
  let root = desktop::runtime();
  let repo = PathBuf::from(env!("CARGO_MANIFEST_DIR"))
    .join("../../../..")
    .canonicalize()
    .unwrap();
  let home = root.path().join("home");
  let plugin = home.join(".config/omarchy/plugins/test.activation");
  fs::create_dir_all(&plugin).unwrap();
  // Host runtime and credentials live under root; grants must be outside it.
  let data_root = tempfile::tempdir().unwrap();
  let requested = data_root.path().join("requested folder");
  fs::create_dir(&requested).unwrap();
  for module in ["Commons", "Ui"] {
    std::os::unix::fs::symlink(repo.join("shell").join(module), root.path().join(module)).unwrap();
  }
  fs::write(plugin.join("manifest.json"), serde_json::to_vec(&serde_json::json!({
    "schemaVersion": 1, "id": "test.activation", "name": "Activation", "version": "1", "kinds": ["panel"],
    "entryPoints": {"panel": "worker.qml"}, "sandbox": {
      "version": 1, "entryPoint": "worker.qml", "requests": {
        "network": true, "notifications": {"required": true}, "storage": true, "desktopGeometry": true, "settings": {"write": ["width"]}, "filesystem": [{"name": "notes", "path": requested, "target": "directory", "required": true}],
        "networkProxy": true, "audioPlayback": true, "microphone": true, "audioCapture": true,
        "exec": {"helper": {"executable": "/usr/bin/printf", "lifetime": "plugin", "tree": {
          "next": [{"arg": {"kind": "exact", "value": "fixture"}, "then": {"end": "session"}}]
        }}},
        "http": {"catalog": {"scope": {
          "origin": "https://example.test", "method": "GET", "path": "/catalog",
          "query": {"limit": {"required": true, "value": {"kind": "exact", "value": "10"}}}
        }}}
      }
    }
  })).unwrap()).unwrap();
  fs::write(
    plugin.join("worker.qml"),
    r##"
import QtQuick
import Quickshell
ShellRoot {
  FloatingWindow {
    implicitWidth: 240; implicitHeight: 160; color: "#304050"
    Text { x: 20; y: 15; text: "Approved Quickshell"; color: "white" }
    Rectangle {
      id: button; x: 20; y: 60; width: 100; height: 50; color: "#bb6633"
      Text { anchors.centerIn: parent; text: "Click me"; color: "white" }
      MouseArea { anchors.fill: parent; onClicked: button.color = "#44ee22" }
    }
    Rectangle { x: 170; y: 72; width: 28; height: 28; color: "#ffb13b"
      NumberAnimation on rotation { from: 0; to: 360; duration: 1800; loops: Animation.Infinite }
    }
  }
}
"##,
  )
  .unwrap();
  let host_qml = root.path().join("host.qml");
  fs::write(&host_qml, format!(r##"
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "file://{}/shell/services" as Services
import "file://{}/shell/plugins/panels/plugin-review" as Review
ShellRoot {{
  Services.SandboxedPlugins {{ id: plugins }}
  Review.Panel {{ id: reviewer }}
  PanelWindow {{
    anchors {{ top: true; bottom: true; left: true; right: true }}
    color: "#171c25"
    WlrLayershell.layer: WlrLayer.Bottom
    Rectangle {{ id: underneath; width: 60; height: 60; color: "#445566"
      MouseArea {{ anchors.fill: parent; onClicked: underneath.color = "#eeaa22" }}
    }}
  }}
  IpcHandler {{
    target: "shell"
    function ping(): string {{ return "ok" }}
    // This legacy custom surface has no shared bar slot. The fixture host
    // explicitly selects pointer roaming; defaults must remain closed/slot-only.
    function enablePlugin(id: string, placement: string): string {{ return plugins.enable(id, {{sandboxPresentation: {{overlayMode: "pointer"}}}}) }}
    function pluginStatus(id: string): string {{ return JSON.stringify(plugins.status(id)) }}
    function setPluginEnabled(id: string, enabled: string): string {{ plugins.disable(id); return "ok" }}
    function summon(id: string, payload: string): string {{ reviewer.open(payload); return "ok" }}
    function listPlugins(): string {{ return JSON.stringify([{{id: "test.activation", enabled: plugins.status("test.activation").state === "running"}}]) }}
    function reviewState(): string {{
      function find(items, name) {{
        for (var i = 0; i < items.length; i++) {{
          var item = items[i]
          if (item.objectName === name) return item
          var found = find(item.children || [], name)
          if (found) return found
        }}
        return null
      }}
      var window = find(reviewer.data, "plugin-review-window")
      function point(name) {{
        var item = find(window.contentItem, name)
        if (!item) return null
        var p = item.mapToItem(null, item.width / 2, item.height / 2)
        return [Math.round(p.x), Math.round(p.y)]
      }}
      var review = reviewer.review
      var scroll = find(window.contentItem, "review-scroll")
      var execChoice = find(window.contentItem, "review-exec-helper-session")
      var notificationChoice = find(window.contentItem, "review-notifications")
      var scrollTop = scroll.mapToItem(null, 0, 0).y
      return JSON.stringify({{visible: window.visible, busy: review.busy, error: review.error, revision: review.revision,
        scrollY: scroll.contentItem.contentY, scrollMoving: scroll.contentItem.moving,
        scrollTop: scrollTop, scrollBottom: scrollTop + scroll.height,
        folders: review.folders, folderField: point("review-folder-notes"),
        enableAvailable: find(window.contentItem, "review-approve").enabled, current: review.current, network: review.network, notifications: review.notifications, settings: review.settings,
        networkProxy: review.networkProxy, proxyButton: point("review-network-proxy"),
        audioPlayback: review.audioPlayback, playbackButton: point("review-audio-playback"),
        microphone: review.microphone, microphoneButton: point("review-microphone"),
        audioCapture: review.audioCapture, captureButton: point("review-audio-capture"),
        settingsButton: point("review-setting-write-width"),
        storage: review.storage, storageButton: point("review-storage"),
        desktopGeometry: review.desktopGeometry, geometryButton: point("review-desktop-geometry"),
        http: review.http, httpButton: point("review-http-catalog"), httpDisclosure: point("review-http-details-catalog"),
        exec: review.exec, execButton: point("review-exec-helper-session"), execDisclosure: point("review-exec-details-helper-session"),
        execDescription: execChoice ? execChoice.description : "",
        notificationsStatic: !!find(notificationChoice ? notificationChoice.children : [], "permission-required"),
        notificationsToggle: !!find(notificationChoice ? notificationChoice.children : [], "permission-toggle"),
        execToggle: !!find(execChoice ? execChoice.children : [], "permission-toggle"),
        httpDetails: point("review-http-scope-catalog"),
        notificationButton: point("review-notifications"), approvalButton: point("review-approve"), removeButton: point("review-remove"), closeButton: point("review-close")}})
    }}
  }}
}}
"##, repo.display(), repo.display())).unwrap();
  let env = operator::environment(root.path(), &repo, &host_qml, &module);
  let mut outer = Desktop::new(
    root.path(),
    Viewport {
      width: 800,
      height: 480,
      scale_fixed: 120,
    },
  );
  let log = root.path().join("host.log");
  let mut host = Host(
    desktop::command(root.path(), &host_qml, &module)
      .envs(env.iter().cloned())
      .env_remove("HYPRLAND_INSTANCE_SIGNATURE")
      .stdout(fs::File::create(&log).unwrap())
      .stderr(fs::File::options().append(true).open(&log).unwrap())
      .spawn()
      .unwrap(),
  );
  let (progress, stages) = mpsc::channel();
  let (resume, proceed) = mpsc::channel();
  let commands = std::thread::spawn(move || {
    let run = |name: &str, args: &[&str]| operator::run(&env, name, args);
    let review: serde_json::Value = serde_json::from_str(&run(
      "omarchy-plugin-review",
      &["test.activation", "--json"],
    ))
    .unwrap();
    if !review_ui {
      run(
        "omarchy-plugin-approve",
        &[
          "test.activation",
          "--revision",
          review["revision"].as_str().unwrap(),
          "--allow-notifications",
          "--read", "notes",
          "--yes",
        ],
      );
    }
    // The review/approval work gives the private IPC endpoint time to start;
    // still explicitly wait for it, without touching a desktop socket.
    let deadline = Instant::now() + Duration::from_secs(3);
    loop {
      let result = Command::new("/usr/bin/timeout")
        .args(["1s", "omarchy-shell", "shell", "ping"])
        .envs(env.iter().cloned())
        .output()
        .unwrap();
      if result.status.success() && String::from_utf8_lossy(&result.stdout).trim() == "ok" {
        break;
      }
      assert!(Instant::now() < deadline, "private IPC host did not start");
      std::thread::sleep(Duration::from_millis(25));
    }
    let wait = |predicate: &dyn Fn(&serde_json::Value) -> bool| {
      let deadline = Instant::now() + Duration::from_secs(8);
      loop {
        let state: serde_json::Value =
          serde_json::from_str(&run("omarchy-shell", &["shell", "reviewState"])).unwrap();
        if predicate(&state) {
          break state;
        }
        assert!(Instant::now() < deadline, "review state timed out: {state}");
        std::thread::sleep(Duration::from_millis(25));
      }
    };
    let click = |state: &serde_json::Value, key: &str| {
      let point = state[key].as_array().unwrap();
      std::thread::sleep(Duration::from_millis(100));
      progress
        .send(Stage::Click(
          point[0].as_i64().unwrap() as i32,
          point[1].as_i64().unwrap() as i32,
        ))
        .unwrap();
    };
    let reveal = |key: &str| {
      for _ in 0..40 {
        let state = wait(&|state| state["scrollMoving"] == false);
        let y = state[key][1].as_f64().unwrap();
        if y > state["scrollTop"].as_f64().unwrap() + 12.0
          && y < state["scrollBottom"].as_f64().unwrap() - 12.0
        {
          return state;
        }
        progress
          .send(Stage::Scroll(
            if y < state["scrollTop"].as_f64().unwrap() + 12.0 {
              120
            } else {
              -120
            },
          ))
          .unwrap();
        std::thread::sleep(Duration::from_millis(150));
      }
      panic!("could not scroll {key} into view");
    };
    if review_ui {
      run("omarchy-plugin-review", &["test.activation", "--ui"]);
      let state = wait(&|state| state["busy"] == false && state["revision"].is_object());
      assert_eq!(state["error"], "");
      assert_eq!(state["network"], false);
      assert_eq!(state["notifications"], true);
      assert_eq!(state["settings"]["write"], serde_json::json!([]));
      assert_eq!(state["http"], serde_json::json!([]));
      assert_eq!(state["current"]["approved"], false);
      assert_eq!(state["enableAvailable"], true, "required permissions start on in the draft");
      click(&reveal("notificationButton"), "notificationButton");
      wait(&|state| state["notifications"] == true);
      let capture = |label| {
        progress.send(Stage::Capture(label)).unwrap();
        proceed.recv_timeout(Duration::from_secs(8)).unwrap();
      };
      capture("selection");
      for key in ["networkProxy", "audioPlayback", "microphone", "audioCapture"] {
        assert_eq!(state[key], false, "new access was selected by default: {key}");
      }
      click(&reveal("playbackButton"), "playbackButton");
      let selected = wait(&|state| state["audioPlayback"] == true);
      assert_eq!(selected["microphone"], false);
      assert_eq!(selected["audioCapture"], false);
      click(&reveal("microphoneButton"), "microphoneButton");
      wait(&|state| state["microphone"] == true);
      click(&reveal("captureButton"), "captureButton");
      wait(&|state| state["audioCapture"] == true);
      capture("audio-independent-selections");
      // Review only: never approve recording authority in this graphics test.
      click(&reveal("microphoneButton"), "microphoneButton");
      wait(&|state| state["microphone"] == false);
      click(&reveal("captureButton"), "captureButton");
      wait(&|state| state["audioCapture"] == false);
      click(&reveal("proxyButton"), "proxyButton");
      let selected = wait(&|state| state["networkProxy"] == true);
      assert_eq!(selected["network"], false);
      capture("proxy-selected");
      assert_eq!(state["desktopGeometry"], false);
      click(&reveal("geometryButton"), "geometryButton");
      wait(&|state| state["desktopGeometry"] == true);
      capture("geometry-selected");
      click(&reveal("geometryButton"), "geometryButton");
      wait(&|state| state["desktopGeometry"] == false);
      capture("geometry-denied");
      click(&reveal("geometryButton"), "geometryButton");
      wait(&|state| state["desktopGeometry"] == true);
      assert_eq!(state["storage"], false);
      click(&reveal("storageButton"), "storageButton");
      wait(&|state| state["storage"] == true);
      capture("storage-selected");
      click(&reveal("storageButton"), "storageButton");
      wait(&|state| state["storage"] == false);
      capture("storage-denied");
      click(&reveal("storageButton"), "storageButton");
      wait(&|state| state["storage"] == true);
      assert_eq!(state["execDescription"], "/usr/bin/printf");
      assert_eq!(state["notificationsStatic"], true);
      assert_eq!(state["notificationsToggle"], false);
      assert_eq!(state["execToggle"], true);
      click(&reveal("execButton"), "execButton");
      wait(&|state| state["exec"]["helper"] == serde_json::json!(["session"]));
      click(&reveal("execDisclosure"), "execDisclosure");
      capture("exec-lifetime");
      click(&reveal("settingsButton"), "settingsButton");
      wait(&|state| state["settings"]["write"] == serde_json::json!(["width"]));
      click(&reveal("httpButton"), "httpButton");
      wait(&|state| state["http"] == serde_json::json!(["catalog"]));
      click(&reveal("httpDisclosure"), "httpDisclosure");
      capture("http");
      reveal("httpDetails");
      capture("http-scope");
      click(&reveal("folderField"), "folderField");
      let state = wait(&|state| state["folders"]["notes"] == true);
      assert_eq!(state["current"]["approved"], false);
      assert_eq!(state["revision"]["paths"]["notes"], state["revision"]["requests"]["filesystem"][0]["path"]);
      capture("folder-allowed");
      click(&reveal("folderField"), "folderField");
      let state = wait(&|state| state["folders"]["notes"] == true);
      assert_eq!(state["enableAvailable"], true, "required folders cannot be deselected");
      capture("folder-required");
      click(&reveal("folderField"), "folderField");
      let state = wait(&|state| state["folders"]["notes"] == true);
      assert_eq!(state["enableAvailable"], true);
      click(&state, "approvalButton");
      wait(&|state| state["visible"] == false && state["busy"] == false);
      run("omarchy-plugin-review", &["test.activation", "--ui"]);
      let state = wait(&|state| state["current"]["enabled"] == true && state["busy"] == false);
      assert_eq!(state["error"], "");
      assert_eq!(
        state["current"]["enabled"], true,
        "one Enable action must approve and enable the plugin"
      );
      assert_eq!(state["current"]["grants"]["network"], false);
      assert_eq!(state["current"]["grants"]["networkProxy"], true);
      assert_eq!(state["current"]["grants"]["audioPlayback"], true);
      assert_ne!(state["current"]["grants"]["microphone"], true);
      assert_ne!(state["current"]["grants"]["audioCapture"], true);
      assert_eq!(
        state["current"]["grants"]["http"]["catalog"],
        state["revision"]["requests"]["http"]["catalog"]["scope"]
      );
      assert_eq!(state["current"]["grants"]["notifications"], true);
      assert_eq!(state["current"]["grants"]["storage"], true);
      assert_eq!(state["current"]["grants"]["exec"]["helper"]["lifetime"], "plugin");
      assert_eq!(state["current"]["grants"]["desktopGeometry"], true);
      assert_eq!(
        state["current"]["grants"]["settings"],
        serde_json::json!({"read": [], "write": ["width"]})
      );
      assert_eq!(state["current"]["grants"]["filesystem"]["notes"]["path"], state["revision"]["paths"]["notes"]);
      assert_eq!(state["current"]["grants"]["filesystem"]["notes"]["access"], "read");
      capture("enabled");
      click(&state, "closeButton");
      wait(&|state| state["visible"] == false);
    } else {
      let enabled = run("omarchy-plugin-enable", &["test.activation"]);
      assert!(enabled.contains("Enabled test.activation"));
    }
    progress.send(Stage::Enabled).unwrap();
    proceed.recv_timeout(Duration::from_secs(8)).unwrap();
    if review_ui {
      run("omarchy-plugin-review", &["test.activation", "--ui"]);
      let state = wait(&|state| state["current"]["enabled"] == true && state["busy"] == false);
      assert_eq!(state["storage"], false, "reopen silently selected storage");
      for key in ["networkProxy", "audioPlayback", "microphone", "audioCapture"] {
        assert_eq!(state[key], false, "reopen silently selected {key}");
      }
      assert_eq!(state["current"]["grants"]["networkProxy"], true);
      assert_eq!(state["current"]["grants"]["audioPlayback"], true);
      assert_eq!(state["exec"], serde_json::json!({}), "reopen silently selected execution");
      assert_eq!(state["current"]["grants"]["exec"]["helper"]["lifetime"], "plugin");
      assert_eq!(
        state["desktopGeometry"], false,
        "reopen silently selected geometry"
      );
      assert_eq!(state["current"]["grants"]["desktopGeometry"], true);
      assert_eq!(state["current"]["grants"]["storage"], true);
      assert_eq!(
        state["notifications"], true,
        "reopen must select the required notification permission"
      );
      assert_eq!(
        state["http"],
        serde_json::json!([]),
        "reopen silently selected HTTP access"
      );
      assert!(
        state["current"]["grants"]["http"]["catalog"].is_object(),
        "reopen changed saved HTTP access"
      );
      assert_eq!(
        state["settings"]["write"],
        serde_json::json!([]),
        "reopen silently selected settings access"
      );
      assert_eq!(
        state["current"]["grants"]["settings"],
        serde_json::json!({"read": [], "write": ["width"]}),
        "reopen changed saved settings access"
      );
      assert_eq!(
        state["current"]["grants"]["notifications"], true,
        "reopen changed the saved grant"
      );
      click(&state, "removeButton");
      wait(&|state| state["visible"] == false && state["busy"] == false);
      assert!(!plugin.exists(), "Deny & Remove must remove the installed checkout");
      let catalog: serde_json::Value = serde_json::from_str(&run("omarchy-plugin-list", &["--json"])).unwrap();
      assert!(!catalog.as_array().unwrap().iter().any(|row| row["id"] == "test.activation"), "Deny & Remove must purge the security identity, not only revoke approval");
    } else {
      run("omarchy-plugin-disable", &["test.activation"]);
    }
    progress.send(Stage::Disabled).unwrap();
  });
  let start = Instant::now();
  let mut enabled = false;
  let mut enabled_at = 0;
  let mut clicked = false;
  let mut clicked_underneath = false;
  let mut verified = false;
  let mut disabled = false;
  let mut withdrawn = false;
  let mut latest_frame: Option<desktop::Frame> = None;
  let mut pending_capture = None;
  while start.elapsed() < Duration::from_secs(if review_ui { 65 } else { 40 }) {
    let time = start.elapsed().as_millis() as u32;
    while let Ok(stage) = stages.try_recv() {
      match stage {
        Stage::Enabled => {
          enabled = true;
          enabled_at = time;
        }
        Stage::Disabled => disabled = true,
        Stage::Click(x, y) => {
          for kind in [0, 1] {
            outer.graphics.input(kind, 0x110, x, y, time).unwrap();
          }
        }
        Stage::Scroll(vertical) => outer
          .graphics
          .scroll(
            Scroll {
              source: 0,
              x: 200,
              y: 290,
              horizontal: 0,
              vertical,
            },
            time,
          )
          .unwrap(),
        Stage::Capture(label) => {
          pending_capture = Some((label, Instant::now()));
        }
      }
    }
    if enabled && !clicked && time > enabled_at + 150 {
      for kind in [0, 1] {
        outer.graphics.input(kind, 0x110, 320, 245, time).unwrap();
      }
      clicked = true;
    }
    for frame in outer.step(time) {
      let count = |rgb| frame.count(rgb);
      if !clicked_underneath && count([0x44, 0xee, 0x22]) > 1000 {
        for kind in [0, 1] {
          outer.graphics.input(kind, 0x110, 20, 20, time).unwrap();
        }
        clicked_underneath = true;
      }
      if !verified && count([0x44, 0xee, 0x22]) > 1000 && count([0xee, 0xaa, 0x22]) > 1000 {
        if let Some(path) = std::env::var_os("OMARCHY_TEST_ACTIVATION_CAPTURE") {
          frame.save(path);
        }
        verified = true;
        resume.send(()).unwrap();
      }
      withdrawn = count([0x30, 0x40, 0x50]) == 0 && count([0xee, 0xaa, 0x22]) > 1000;
      latest_frame = Some(frame);
    }
    // Do not let the command thread click the next state before the animated
    // switch has rendered. An IPC property reply is not a presentation fence.
    if let Some((label, requested)) = pending_capture {
      if requested.elapsed() >= Duration::from_millis(350) {
        if let (Some(frame), Some(path)) = (
          &latest_frame,
          std::env::var_os("OMARCHY_TEST_REVIEW_CAPTURE"),
        ) {
          frame.save(PathBuf::from(path).with_extension(format!("{label}.ppm")));
        }
        pending_capture = None;
        resume.send(()).unwrap();
      }
    }
    if (disabled && withdrawn) || host.0.try_wait().unwrap().is_some() {
      break;
    }
    std::thread::sleep(Duration::from_millis(5));
  }
  eprintln!(
    "host exit: {:?}\n{}",
    host.0.try_wait().unwrap(),
    fs::read_to_string(log).unwrap()
  );
  commands.join().unwrap();
  assert!(
    enabled && verified && disabled && withdrawn,
    "enabled={enabled}, input+click-through={verified}, disabled={disabled}, withdrawn={withdrawn}"
  );
}
