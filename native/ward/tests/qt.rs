#![cfg(feature = "graphics")]
#[path = "support/desktop.rs"]
mod desktop;
use desktop::{Desktop, Host};
use omarchy_ward::{
  controller::{Key, Scroll},
  grants::Grants,
  presentation::Viewport,
  revision::Revision,
  store::Store,
};
use std::{
  fs,
  process::Command,
  time::{Duration, Instant},
};

#[test]
fn qt_bridge_renders_resizes_and_withdraws_after_revocation() {
  let Some(module) = std::env::var_os("OMARCHY_TEST_QT_BRIDGE") else {
    eprintln!(
      "set OMARCHY_TEST_QT_BRIDGE to the built QML module directory for headless Qt integration"
    );
    return;
  };
  if std::env::var("OMARCHY_TEST_GRAPHICS").as_deref() != Ok("1")
    || std::env::var("OMARCHY_TEST_SYSTEMD").as_deref() != Ok("1")
  {
    eprintln!(
      "headless Qt integration also requires OMARCHY_TEST_GRAPHICS=1 and OMARCHY_TEST_SYSTEMD=1"
    );
    return;
  }
  let root = desktop::runtime();
  let source = root.path().join("source");
  fs::create_dir(&source).unwrap();
  fs::write(source.join("worker.qml"), r##"
import QtQuick
import QtQuick.Effects
import Quickshell
ShellRoot {
  PanelWindow {
    id: panel
    property int edgeClicks: 0
    property int scrollStage: 0
    anchors { top: true; left: true; right: true }
    implicitHeight: 36; color: "#20bfa5"
    Text { anchors.centerIn: parent; text: "Isolated Quickshell → Rust → Qt" }
    Rectangle {
      x: 8; y: 6; width: 32; height: 24
      color: ["#121212", "#33cc88", "#bb6633", "#7799cc", "#99bb55"][panel.scrollStage]
    }
    MouseArea { anchors.fill: parent; acceptedButtons: Qt.NoButton
      onWheel: event => {
        if (panel.scrollStage === 0 && event.angleDelta.x === 120 && event.angleDelta.y === -120) panel.scrollStage = 1;
        else if (panel.scrollStage === 1 && event.angleDelta.y === 60) panel.scrollStage = 2;
        else if (panel.scrollStage === 2 && event.pixelDelta.x === 7 && event.pixelDelta.y === -9) panel.scrollStage = 3;
        else if (panel.scrollStage === 3 && event.phase === Qt.ScrollEnd) panel.scrollStage = 4;
        console.log("SCROLL_STAGE", panel.scrollStage, event.angleDelta, event.pixelDelta, event.phase);
        event.accepted = true;
      }
    }
    Rectangle {
      x: parent.width - 36; y: 6; width: 24; height: 24
      color: panel.edgeClicks === 2 ? "#ee5599" : panel.edgeClicks === 1 ? "#ff7744" : panel.width === 640 ? "#dd44cc" : "#1199ee"
      MouseArea { anchors.fill: parent; onClicked: panel.edgeClicks += 1 }
    }
  }
  FloatingWindow {
    implicitWidth: 480; implicitHeight: 280; color: "#304050"
    Rectangle {
      x: 24; y: 24; width: 56; height: 56; radius: 12; color: "#ffb13b"
      layer.enabled: true
      layer.effect: MultiEffect { shadowEnabled: true; shadowBlur: 1; shadowVerticalOffset: 8 }
      NumberAnimation on rotation { from: 0; to: 360; duration: 1800; loops: Animation.Infinite }
    }
    TextInput {
      id: input; x: 24; y: 115; width: 200; height: 40; color: "white"; font.pixelSize: 20; text: "INPUT"
      property bool escapePressed: false
      property bool escapeReleased: false
      property bool shiftSeen: false
      property bool controlSeen: false
      Keys.onPressed: event => {
        if (event.key === Qt.Key_Z && (event.modifiers & Qt.ShiftModifier)) shiftSeen = true
        if (event.key === Qt.Key_Q && (event.modifiers & Qt.ControlModifier)) { controlSeen = true; event.accepted = true }
      }
      Keys.onEscapePressed: event => { escapePressed = true; event.accepted = true }
      Keys.onReleased: event => {
        if (event.key === Qt.Key_Escape) { escapeReleased = escapePressed; event.accepted = true }
      }
    }
    Rectangle { x: 250; y: 115; width: 32; height: 32; color: input.text.indexOf("e") >= 0 ? "#44ee22" : "#ff3300" }
    Rectangle { x: 294; y: 115; width: 32; height: 32; color: input.text.indexOf("r") >= 0 ? "#ffee44" : "#111122" }
    Rectangle { x: 338; y: 115; width: 16; height: 32; color: input.activeFocus ? "#aaeeff" : "#111122" }
    Rectangle { x: 360; y: 115; width: 32; height: 32; color: input.escapeReleased && input.activeFocus ? "#22ccdd" : "#111122" }
    Rectangle { x: 410; y: 115; width: 32; height: 32; color: input.text.indexOf("éλZ") >= 0 && input.shiftSeen && input.controlSeen ? "#cc4499" : "#111122" }
    Rectangle {
      id: button; x: 24; y: 180; width: 180; height: 48; color: "#607080"
      Text { anchors.centerIn: parent; text: "Open popup"; color: "white" }
      MouseArea { anchors.fill: parent; onClicked: popup.visible = true }
    }
    PopupWindow { id: popup; visible: false; anchor.item: button; anchor.rect.y: button.height
      implicitWidth: 200; implicitHeight: 70; color: "#8a2be2"
      Text { anchors.centerIn: parent; text: "Private popup"; color: "white" }
    }
  }
}
"##).unwrap();
  fs::write(source.join("manifest.json"), serde_json::to_vec(&serde_json::json!({
    "schemaVersion": 1, "id": "test.qt", "name": "Qt", "version": "1", "kinds": ["panel"],
    "entryPoints": {"panel": "worker.qml"}, "sandbox": {"version": 1, "entryPoint": "worker.qml", "requests": {}}
  })).unwrap()).unwrap();
  let state = root.path().join("state");
  let store = Store::initialize(&state).unwrap();
  let revision = Revision::import(&source, &store.revisions()).unwrap();
  store.approve(&revision.digest, Grants::default()).unwrap();
  let viewport = Viewport {
    width: 800,
    height: 480,
    scale_fixed: 120,
  };
  // This outer display is test-owned and never connects to the real compositor.
  let mut outer = Desktop::new(root.path(), viewport);
  let host_qml = root.path().join("host.qml");
  fs::write(&host_qml, r##"
import QtQuick
import Quickshell
import Omarchy.Ward
ShellRoot {
  FloatingWindow {
    implicitWidth: 800; implicitHeight: 480; color: "#171c25"
    PluginView {
      id: view; width: 800; height: 480
      onFocusRequested: forceActiveFocus()
      Component.onCompleted: start(Quickshell.env("TEST_STORE"), "test.qt", Quickshell.env("TEST_CONTROLLER"), 800, 480)
      onStateChanged: console.log("VIEW_STATE", ready, error)
      onActiveFocusChanged: console.log("VIEW_FOCUS", activeFocus)
    }
    Rectangle {
      id: resizeButton; x: 750; y: 8; width: 40; height: 24
      property int phase: 0
      color: phase === 2 && !view.resizing ? "#55dd99" : "#aa6677"
      MouseArea { anchors.fill: parent; onClicked: {
        resizeButton.phase += 1;
        view.configure(700, 420, 1);
        view.configure(640, 400, 2);
        view.x = 40; view.y = 40; view.width = 640; view.height = 400;
      } }
    }
    Rectangle {
      x: 760; y: 430; width: 20; height: 20; color: "#3388ff"
      NumberAnimation on rotation { from: 0; to: 360; duration: 700; loops: Animation.Infinite }
    }
  }
  Timer { interval: 9000; running: true; onTriggered: Qt.quit() }
}
"##).unwrap();
  let log_path = root.path().join("qt.log");
  let mut host = Host(
    desktop::command(root.path(), &host_qml, &module)
      .env("TEST_STORE", &state)
      .env("TEST_CONTROLLER", env!("CARGO_BIN_EXE_omarchy-ward"))
      .stdout(fs::File::create(&log_path).unwrap())
      .stderr(fs::File::options().append(true).open(&log_path).unwrap())
      .spawn()
      .unwrap(),
  );
  let start = Instant::now();
  let mut typed = false;
  let mut focused = false;
  let mut clicked = false;
  let mut verified = false;
  let mut resize_stage = 0;
  let mut resize_ready = false;
  let mut retyped = false;
  let mut escape_sent = false;
  let mut escaped = false;
  let mut resized_at = 0;
  let mut revoked = None;
  let mut withdrawn = false;
  let mut frames = 0;
  let mut next_capture = 2500;
  let mut maximum_colors = (0, 0);
  while start.elapsed() < Duration::from_secs(8) {
    let time = start.elapsed().as_millis() as u32;
    if !focused && time >= 1200 {
      for kind in [0, 1] {
        outer.graphics.input(kind, 0x110, 200, 230, time).unwrap();
      }
      focused = true;
    }
    if !typed && time >= 1400 {
      for kind in [3, 4] {
        outer.graphics.input(kind, 26, 0, 0, time).unwrap();
      }
      // Deliberately unlike US scan codes, as with another layout or a
      // Unicode virtual keyboard. Symbols must survive both compositor hops.
      for (code, symbol, pressed) in [
        (9, 0xe9, true),
        (9, 0, false),
        (10, 0x0100_03bb, true),
        (10, 0, false),
        (8, 0xffe1, true),
        (11, u32::from('Z'), true),
        (11, 0, false),
        (8, 0, false),
        (12, 0xffe3, true),
        (13, u32::from('q'), true),
        (13, 0, false),
        (12, 0, false),
      ] {
        outer
          .graphics
          .key(
            Key {
              code,
              symbol,
              pressed,
            },
            time,
          )
          .unwrap();
      }
      typed = true;
    }
    if !clicked && time >= 1800 {
      for kind in [0, 1] {
        outer.graphics.input(kind, 0x110, 210, 300, time).unwrap();
      }
      clicked = true;
    }
    for frame in outer.step(time) {
      frames += 1;
      let count = |rgb| frame.count(rgb);
      let green = count([0x44, 0xee, 0x22]);
      let purple = count([0x8a, 0x2b, 0xe2]);
      maximum_colors = (maximum_colors.0.max(green), maximum_colors.1.max(purple));
      if time > next_capture && !verified {
        next_capture += 2500;
        if let Some(path) = std::env::var_os("OMARCHY_TEST_QT_CAPTURE") {
          frame.save(path);
        }
      }
      if green > 500 && purple > 5000 && count([0xcc, 0x44, 0x99]) > 500 && !verified {
        verified = true;
        if let Some(path) = std::env::var_os("OMARCHY_TEST_QT_CAPTURE") {
          frame.save(path);
        }
      }
      if verified && resize_stage == 0 {
        for kind in [0, 1] {
          outer.graphics.input(kind, 0x110, 770, 20, time).unwrap();
        }
        resize_stage = 1;
        resized_at = time;
      }
      if resize_stage == 1
        && count([0xdd, 0x44, 0xcc]) > 300
        && purple == 0
        && time > resized_at + 150
      {
        // x=620 is valid in the new 640-wide canvas. A stale 800-wide
        // coordinate transform would send an out-of-bounds private click.
        for kind in [0, 1] {
          outer.graphics.input(kind, 0x110, 660, 56, time).unwrap();
        }
        resize_stage = 2;
      }
      if resize_stage == 2 && count([0xff, 0x77, 0x44]) > 300 {
        for kind in [0, 1] {
          outer.graphics.input(kind, 0x110, 160, 230, time).unwrap();
        }
        resize_stage = 3;
      }
      if resize_stage == 3 && !escape_sent && count([0xaa, 0xee, 0xff]) > 200 {
        // Escape belongs to the worker's focused control (clear search, close
        // a menu, etc.), not an unconditional host-side focus withdrawal.
        for pressed in [true, false] {
          outer
            .graphics
            .key(
              Key {
                code: 9,
                symbol: 0xff1b,
                pressed,
              },
              time,
            )
            .unwrap();
        }
        escape_sent = true;
      }
      if resize_stage == 3 && escape_sent && count([0x22, 0xcc, 0xdd]) > 500 {
        escaped = true;
        for pressed in [true, false] {
          outer
            .graphics
            .key(
              Key {
                code: 27,
                symbol: u32::from('r'),
                pressed,
              },
              time,
            )
            .unwrap();
        }
        retyped = true;
        resize_stage = 4;
      }
      if resize_stage == 4 && count([0xff, 0xee, 0x44]) > 500 {
        for kind in [0, 1] {
          outer.graphics.input(kind, 0x110, 770, 20, time).unwrap();
        }
        resize_stage = 5;
      }
      if resize_stage == 5 && count([0x55, 0xdd, 0x99]) > 500 {
        for kind in [0, 1] {
          outer.graphics.input(kind, 0x110, 660, 56, time).unwrap();
        }
        resize_stage = 6;
      }
      if resize_stage == 6 && count([0xee, 0x55, 0x99]) > 300 && count([0xff, 0xee, 0x44]) > 500 {
        outer
          .graphics
          .scroll(
            Scroll {
              source: 0,
              x: 100,
              y: 56,
              horizontal: 120,
              vertical: -120,
            },
            time,
          )
          .unwrap();
        resize_stage = 7;
      }
      if resize_stage == 7 && count([0x33, 0xcc, 0x88]) > 500 {
        outer
          .graphics
          .scroll(
            Scroll {
              source: 0,
              x: 100,
              y: 56,
              horizontal: 0,
              vertical: 60,
            },
            time,
          )
          .unwrap();
        resize_stage = 8;
      }
      if resize_stage == 8 && count([0xbb, 0x66, 0x33]) > 500 {
        outer
          .graphics
          .scroll(
            Scroll {
              source: 1,
              x: 100,
              y: 56,
              horizontal: 7,
              vertical: -9,
            },
            time,
          )
          .unwrap();
        resize_stage = 9;
      }
      if resize_stage == 9 && count([0x77, 0x99, 0xcc]) > 500 {
        outer
          .graphics
          .scroll(
            Scroll {
              source: 2,
              x: 100,
              y: 56,
              horizontal: 0,
              vertical: 0,
            },
            time,
          )
          .unwrap();
        resize_stage = 10;
      }
      if resize_stage == 10 && count([0x99, 0xbb, 0x55]) > 500 {
        resize_ready = true;
        if let Some(path) = std::env::var_os("OMARCHY_TEST_QT_RESIZE_CAPTURE") {
          frame.save(path);
        }
      }
      if let Some(directory) = std::env::var_os("OMARCHY_TEST_QT_FRAMES") {
        frame.save(std::path::Path::new(&directory).join(format!("{frames:04}.ppm")));
      }
      if revoked.is_some_and(|at: Instant| at.elapsed() > Duration::from_millis(150))
        && green == 0
        && purple == 0
        && count([0x17, 0x1c, 0x25]) > 300_000
      {
        withdrawn = true;
      }
    }
    if resize_ready && revoked.is_none() {
      store.revoke("test.qt").unwrap();
      revoked = Some(Instant::now());
    }
    if withdrawn {
      break;
    }
    if let Some(status) = host.0.try_wait().unwrap() {
      panic!(
        "Qt host exited {status}: {}",
        fs::read_to_string(&log_path).unwrap()
      );
    }
    std::thread::sleep(Duration::from_millis(5));
  }
  if !resize_ready && let Some(unit) = store.read("test.qt").unwrap().active_unit {
    let log = Command::new("journalctl")
      .args(["--user", "--no-pager", "-n", "100", "-u", &unit])
      .output()
      .unwrap();
    eprintln!("{}", String::from_utf8_lossy(&log.stdout));
  }
  store.revoke("test.qt").unwrap();
  assert!(
    verified && resize_ready && retyped && escaped && withdrawn,
    "Qt bridge verification failed: rendered={verified}, resize={resize_ready}/{resize_stage}, escape={escaped}, withdrawn={withdrawn}, frames={frames}, colors={maximum_colors:?}\n{}",
    fs::read_to_string(&log_path).unwrap()
  );
  assert!(
    host.0.try_wait().unwrap().is_none(),
    "revocation killed the Qt host"
  );
  println!(
    "Qt bridge verified rendering, keyboard/Escape, popup, resize/scale/roundtrip, wheel/finger scrolling and revocation after {frames} outer frames"
  );
}
