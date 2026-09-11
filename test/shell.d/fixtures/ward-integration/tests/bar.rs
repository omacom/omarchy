#[path = "../../../../../native/ward/tests/support/desktop.rs"]
mod desktop;
#[path = "support/operator.rs"]
mod operator;
use desktop::{Desktop, Frame, Host};
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
    for id in ["test.slot-one", "test.slot-two"] {
      let _ = self.0.revoke(id);
    }
  }
}

#[test]
fn native_slots_share_real_and_replacement_bars_without_loading_plugin_qml() {
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
    "version":1, "bar":{"position":"top", "layout":{"left":[{"id":"test.anchor"}],"center":[],"right":[]}}, "plugins":[]
  })).unwrap();
  fs::write(&config, &initial).unwrap();
  fs::write(source.join("config/omarchy/shell.json"), initial).unwrap();
  let plugins = config.parent().unwrap().join("plugins");
  let admission = Admission(Store::initialize(&root.path().join("state")).unwrap());
  for (id, color, panel_color) in [
    ("test.slot-one", "#eeaa22", "#44ee22"),
    ("test.slot-two", "#3388ee", "#cc44ee"),
  ] {
    let plugin = plugins.join(id);
    fs::create_dir_all(&plugin).unwrap();
    fs::write(
      plugin.join("manifest.json"),
      serde_json::to_vec(&serde_json::json!({
        "schemaVersion":1,"id":id,"name":id,"version":"1","kinds":["bar-widget"],
        "entryPoints":{"barWidget":"Widget.qml"}, "barWidget":{"defaultSection":"right"},
        "sandbox":{"version":1,"requests":{}}
      }))
      .unwrap(),
    )
    .unwrap();
    fs::write(plugin.join("Widget.qml"), format!(r##"
import QtQuick
import Quickshell
import Quickshell.Io
import qs.Ui
Panel {{
  id: root
  moduleName: "{id}"
  implicitWidth: 40; implicitHeight: bar ? bar.barSize : 26
  Rectangle {{ anchors.centerIn: parent; width: 40; height: 20; color: "{color}" }}
  MouseArea {{ anchors.fill: parent; onClicked: root.toggle() }}
  property bool forgedDone: false
  property bool requestAccepted: false
  property int negativeMode: 0
  property bool dragged: false
  Process {{
    id: forged
    command: ["/bootstrap", "--switch-panel", "1"]
    onExited: (exitCode, exitStatus) => {{ root.requestAccepted = exitCode === 0; settled.start() }}
  }}
  Timer {{ id: settled; interval: 300; onTriggered: {{ root.forgedDone = root.requestAccepted; root.negativeMode = 0 }} }}
  Timer {{ id: delayed; interval: 1400; onTriggered: forged.running = true }}
  KeyboardPanel {{
    id: panel
    anchorItem: root; bar: root.bar; owner: root; open: root.opened
    contentWidth: 160; contentHeight: 100
    // Deliberately omit private outside-click coverage: programmatic opening
    // must retain keyboard focus and the host must own outside dismissal.
    mask: Region {{ x: panel.cardOrigin.x; y: panel.cardOrigin.y; width: panel.contentWidth; height: panel.contentHeight }}
    Rectangle {{
      anchors.fill: parent; color: "{panel_color}"; focus: true
      Rectangle {{ width: 10; height: 10; color: root.forgedDone ? "#ffee11" : root.negativeMode === 1 ? "#aa1177" : root.negativeMode === 2 ? "#11ccee" : "{panel_color}" }}
      Rectangle {{ anchors.right: parent.right; width: 10; height: 10; color: root.dragged ? "#22ccdd" : "{panel_color}" }}
      MouseArea {{
        anchors.fill: parent
        property real lastX: 0
        property real travel: 0
        onPressed: mouse => {{ lastX = mouse.x; travel = 0; root.dragged = false }}
        onPositionChanged: mouse => {{ if (pressed) {{ travel += Math.abs(mouse.x - lastX); lastX = mouse.x }} }}
        onReleased: root.dragged = travel > 30
      }}
      Keys.onEscapePressed: root.close()
      Keys.onPressed: event => {{
        if (event.key === Qt.Key_A) {{ forged.running = true; event.accepted = true }}
        else if (event.key === Qt.Key_W || event.key === Qt.Key_L) {{
          root.forgedDone = false
          root.negativeMode = event.key === Qt.Key_W ? 1 : 2
          event.accepted = true
        }}
        else if (event.key === Qt.Key_Tab || event.key === Qt.Key_Backtab) {{
          const direction = event.key === Qt.Key_Backtab || (event.modifiers & Qt.ShiftModifier) ? -1 : 1
          if (root.negativeMode) {{
            forged.command = ["/bootstrap", "--switch-panel", String(root.negativeMode === 1 ? -direction : direction)]
            if (root.negativeMode === 2) delayed.start()
            else forged.running = true
          }} else root.switchPanel(direction)
          event.accepted = true
        }}
      }}
    }}
  }}
}}
"##)).unwrap();
    let revision = Revision::import(&plugin, &admission.0.revisions()).unwrap();
    admission
      .0
      .approve(&revision.digest, Grants::default())
      .unwrap();
  }
  // A trusted user's widget and a full-bar clone stay in-process. Only native
  // slots get the host spacer; no first-party plugin is a sandbox-port target.
  for (id, kind, entry) in [
    ("test.anchor", "bar-widget", "barWidget"),
    ("test.bar", "bar", "bar"),
  ] {
    let plugin = plugins.join(id);
    fs::create_dir_all(&plugin).unwrap();
    fs::write(plugin.join("manifest.json"), serde_json::to_vec(&serde_json::json!({
      "schemaVersion":1,"id":id,"name":id,"version":"1","kinds":[kind],"entryPoints":{entry:"Widget.qml"}
    })).unwrap()).unwrap();
    if kind == "bar" {
      fs::copy(
        repo.join("shell/plugins/bar/Bar.qml"),
        plugin.join("Widget.qml"),
      )
      .unwrap();
      fs::copy(
        repo.join("shell/plugins/bar/BarModel.js"),
        plugin.join("BarModel.js"),
      )
      .unwrap();
    } else {
      fs::write(plugin.join("Widget.qml"), "import QtQuick\nItem { implicitWidth: 40; implicitHeight: 26; Rectangle { anchors.centerIn: parent; width: 40; height: 20; color: \"#aabbcc\" } }\n").unwrap();
    }
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
        && String::from_utf8_lossy(&result.stdout).contains("test.slot-two")
      {
        break;
      }
      assert!(
        Instant::now() < deadline,
        "private shell did not scan plugins"
      );
      std::thread::sleep(Duration::from_millis(25));
    }
    let stage = |name| {
      send.send(name).unwrap();
      wait.recv_timeout(Duration::from_secs(12)).unwrap();
    };
    run(
      "omarchy-plugin-enable",
      &["test.slot-one", "--section", "right"],
    );
    run(
      "omarchy-plugin-enable",
      &["test.slot-two", "--section", "right"],
    );
    stage("two-slots");
    stage("click-first");
    stage("cross-gap");
    stage("drag-panel");
    stage("forged-switch");
    stage("arm-wrong-direction");
    stage("wrong-direction");
    stage("arm-expired-switch");
    stage("expired-switch");
    stage("tab-second");
    stage("backtab-first");
    stage("click-second");
    stage("click-first");
    stage("outside");
    stage("click-first");
    stage("escape");
    assert_eq!(
      run("omarchy-shell", &["shell", "togglePanelAt", "right", "1"]).trim(),
      "test.slot-one"
    );
    stage("summoned-first");
    stage("escape");
    assert_eq!(
      run("omarchy-shell", &["shell", "summon", "test.slot-one", ""]).trim(),
      "ok"
    );
    stage("reopened-first");
    stage("outside");
    run("omarchy-plugin-enable", &["test.bar"]);
    stage("replacement-bar");
    run(
      "omarchy-shell",
      &[
        "shell",
        "moveBarWidget",
        "test.slot-one",
        r#"{"section":"left","after":"test.anchor"}"#,
      ],
    );
    stage("moved-slot");
    stage("click-first");
    stage("cross-gap");
    stage("click-second");
    stage("click-first");
    stage("escape");
    run("omarchy-toggle-bar", &["on"]);
    stage("hidden-bar");
    run("omarchy-toggle-bar", &["off"]);
    stage("visible-bar");
    run("omarchy-plugin-disable", &["test.slot-one"]);
    run("omarchy-plugin-disable", &["test.slot-two"]);
    stage("disabled");
  });
  let start = Instant::now();
  let mut current = None;
  let mut phase = None;
  let mut deadline = start + Duration::from_secs(15);
  let center = |frame: &Frame, color: [u8; 3]| {
    let points: Vec<_> = frame
      .pixels()
      .chunks_exact(4)
      .enumerate()
      .filter(|(_, p)| p[..3] == color)
      .map(|(i, _)| (i % 800, i / 800))
      .collect();
    assert!(!points.is_empty(), "missing widget before click");
    (
      (points.iter().map(|p| p.0).sum::<usize>() / points.len()) as i32,
      (points.iter().map(|p| p.1).sum::<usize>() / points.len()) as i32,
    )
  };
  while !operator.is_finished() || phase.is_some() {
    if let Ok(next) = receive.try_recv() {
      phase = Some(next);
      deadline = Instant::now() + Duration::from_secs(10);
      if next == "click-first" || next == "click-second" {
        let color = if next == "click-first" {
          [0xee, 0xaa, 0x22]
        } else {
          [0x33, 0x88, 0xee]
        };
        let (x, y) = center(current.as_ref().unwrap(), color);
        display
          .graphics
          .input(2, 0, x, y, start.elapsed().as_millis() as u32)
          .unwrap();
        display
          .graphics
          .input(0, 0x110, x, y, start.elapsed().as_millis() as u32)
          .unwrap();
        display.step(start.elapsed().as_millis() as u32);
        std::thread::sleep(Duration::from_millis(10));
        display
          .graphics
          .input(1, 0x110, x, y, start.elapsed().as_millis() as u32)
          .unwrap();
      } else if next == "cross-gap" {
        // A user-opened panel owns outside dismissal even where its worker
        // has no surface. Pointer transit must not fall into the application
        // beneath it and trigger sloppy-focus dismissal on the real desktop.
        display
          .graphics
          .input(2, 0, 400, 400, start.elapsed().as_millis() as u32)
          .unwrap();
      } else if next == "drag-panel" {
        let (x, y) = center(current.as_ref().unwrap(), [0x44, 0xee, 0x22]);
        display
          .graphics
          .input(0, 0x110, x - 25, y, start.elapsed().as_millis() as u32)
          .unwrap();
        // Hold through host focus priming, then move while the button remains down.
        for offset in 0..80 {
          if offset >= 20 {
            display
              .graphics
              .input(
                2,
                0,
                x - 25 + offset - 20,
                y,
                start.elapsed().as_millis() as u32,
              )
              .unwrap();
          }
          for frame in display.step(start.elapsed().as_millis() as u32) {
            current = Some(frame);
          }
          std::thread::sleep(Duration::from_millis(10));
        }
        display
          .graphics
          .input(1, 0x110, x + 34, y, start.elapsed().as_millis() as u32)
          .unwrap();
      } else if matches!(
        next,
        "forged-switch"
          | "arm-wrong-direction"
          | "wrong-direction"
          | "arm-expired-switch"
          | "expired-switch"
          | "tab-second"
          | "backtab-first"
      ) {
        let (code, symbol) = match next {
          "forged-switch" => (38, u32::from('a')),
          "arm-wrong-direction" => (25, u32::from('w')),
          "arm-expired-switch" => (46, u32::from('l')),
          "backtab-first" => (23, 0xfe20),
          _ => (23, 0xff09),
        };
        for pressed in [true, false] {
          display
            .graphics
            .key(
              omarchy_ward::controller::Key {
                code,
                symbol,
                pressed,
              },
              start.elapsed().as_millis() as u32,
            )
            .unwrap();
        }
      } else if next == "outside" {
        for kind in [0, 1] {
          display
            .graphics
            .input(kind, 0x110, 400, 400, start.elapsed().as_millis() as u32)
            .unwrap();
        }
      } else if next == "escape" {
        for pressed in [true, false] {
          display
            .graphics
            .key(
              omarchy_ward::controller::Key {
                code: 9,
                symbol: 0xff1b,
                pressed,
              },
              start.elapsed().as_millis() as u32,
            )
            .unwrap();
        }
      }
    }
    for frame in display.step(start.elapsed().as_millis() as u32) {
      if let Some(name) = phase {
        let one = frame.count([0xee, 0xaa, 0x22]);
        let two = frame.count([0x33, 0x88, 0xee]);
        let first_panel = frame.count([0x44, 0xee, 0x22]);
        let second_panel = frame.count([0xcc, 0x44, 0xee]);
        let ready = frame.count([0xaa, 0xbb, 0xcc]) == if name == "hidden-bar" { 0 } else { 800 }
          && match name {
            "click-first" | "summoned-first" | "reopened-first" | "backtab-first" => {
              first_panel > 5000 && second_panel == 0
            }
            "click-second" | "tab-second" => second_panel > 5000 && first_panel == 0,
            "cross-gap" => {
              first_panel > 5000
                && second_panel == 0
                && display.mask().iter().any(|region| {
                  region.operation == 1
                    && region.x <= 400
                    && 400 < region.x + region.width
                    && region.y <= 400
                    && 400 < region.y + region.height
                })
            }
            "drag-panel" => first_panel > 5000 && frame.count([0x22, 0xcc, 0xdd]) == 100,
            "forged-switch" | "wrong-direction" | "expired-switch" => {
              first_panel > 5000 && second_panel == 0 && frame.count([0xff, 0xee, 0x11]) == 100
            }
            "arm-wrong-direction" => {
              first_panel > 5000 && second_panel == 0 && frame.count([0xaa, 0x11, 0x77]) == 100
            }
            "arm-expired-switch" => {
              first_panel > 5000 && second_panel == 0 && frame.count([0x11, 0xcc, 0xee]) == 100
            }
            "disabled" | "hidden-bar" => {
              one == 0 && two == 0 && first_panel == 0 && second_panel == 0
            }
            "moved-slot" => {
              one == 800
                && two == 800
                && center(&frame, [0xee, 0xaa, 0x22]).0 < 200
                && center(&frame, [0x33, 0x88, 0xee]).0 > 600
            }
            _ => one == 800 && two == 800 && first_panel == 0 && second_panel == 0,
          };
        if ready {
          if let Some(directory) = std::env::var_os("OMARCHY_TEST_SURFACE_FRAMES") {
            frame.save(PathBuf::from(directory).join(format!("bar-{name}.ppm")));
          }
          phase = None;
          ack.send(()).unwrap();
        }
      }
      current = Some(frame);
    }
    if Instant::now() >= deadline {
      if let (Some(frame), Some(directory)) =
        (&current, std::env::var_os("OMARCHY_TEST_SURFACE_FRAMES"))
      {
        frame.save(PathBuf::from(directory).join("bar-failed.ppm"));
      }
    }
    assert!(
      Instant::now() < deadline,
      "bar phase {phase:?} timed out: {}",
      fs::read_to_string(&log).unwrap()
    );
    std::thread::sleep(Duration::from_millis(5));
  }
  operator.join().unwrap();
  let config: serde_json::Value = serde_json::from_slice(&fs::read(config).unwrap()).unwrap();
  assert_eq!(config["bar"]["id"], "test.bar");
  assert_eq!(
    config["bar"]["layout"]["left"],
    serde_json::json!([{"id":"test.anchor"}])
  );
}
