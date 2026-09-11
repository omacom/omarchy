#![cfg(feature = "graphics")]
#[path = "support/desktop.rs"]
mod desktop;
use desktop::{Desktop, Frame, Host};
use omarchy_ward::presentation::Viewport;
use std::{
  ffi::OsStr,
  fs,
  time::{Duration, Instant},
};

fn has(frame: &Frame, rgb: [u8; 3]) -> bool {
  frame.count(rgb) == 400
}
fn focused(frame: &Frame) -> bool {
  has(frame, [0xaa, 0xff, 0xcc])
}

fn wait_frame(display: &mut Desktop, start: Instant, label: &str, ready: impl Fn(&Frame) -> bool) {
  let deadline = Instant::now() + Duration::from_secs(2);
  while Instant::now() < deadline {
    for frame in display.step(start.elapsed().as_millis() as u32) {
      if let Some(path) = std::env::var_os("OMARCHY_TEST_FOCUS_CAPTURE") {
        frame.save(path);
      }
      if ready(&frame) {
        return;
      }
    }
    std::thread::sleep(Duration::from_millis(5));
  }
  panic!("private layer focus did not reach {label}");
}

fn stays_unfocused(display: &mut Desktop, start: Instant, expected: [u8; 3]) {
  let deadline = Instant::now() + Duration::from_millis(300);
  let mut frames = 0;
  while Instant::now() < deadline {
    for kind in [3, 4] {
      display
        .graphics
        .input(kind, 26, 0, 0, start.elapsed().as_millis() as u32)
        .unwrap();
    }
    for frame in display.step(start.elapsed().as_millis() as u32) {
      assert!(!focused(&frame), "inactive layer reclaimed keyboard focus");
      assert!(has(&frame, expected), "inactive layer received a key");
      frames += 1;
    }
    std::thread::sleep(Duration::from_millis(5));
  }
  assert!(
    frames >= 2,
    "client heartbeat stopped during unfocused check"
  );
}

#[test]
fn private_layer_focus_obeys_activation_mode_and_unmapping() {
  if std::env::var("OMARCHY_TEST_GRAPHICS").as_deref() != Ok("1") {
    eprintln!("set OMARCHY_TEST_GRAPHICS=1 for private layer keyboard focus");
    return;
  }
  let root = desktop::runtime();
  let qml = root.path().join("focus.qml");
  fs::write(&qml, include_str!("support/focus.qml")).unwrap();
  let log = root.path().join("focus.log");
  let mut display = Desktop::new(
    root.path(),
    Viewport {
      width: 400,
      height: 200,
      scale_fixed: 120,
    },
  );
  let mut client = Host(
    desktop::command(root.path(), &qml, OsStr::new(""))
      .env("HOME", root.path().join("home"))
      .stdout(fs::File::create(&log).unwrap())
      .stderr(fs::File::options().append(true).open(&log).unwrap())
      .spawn()
      .unwrap(),
  );
  let start = Instant::now();
  let click = |display: &mut Desktop, x| {
    for kind in [0, 1] {
      display
        .graphics
        .input(kind, 0x110, x, 15, start.elapsed().as_millis() as u32)
        .unwrap();
    }
  };
  let key = |display: &mut Desktop| {
    for kind in [3, 4] {
      display
        .graphics
        .input(kind, 26, 0, 0, start.elapsed().as_millis() as u32)
        .unwrap();
    }
  };
  wait_frame(&mut display, start, "bar ready", |frame| {
    has(frame, [0xee, 0x44, 0x22])
  });
  display
    .graphics
    .input(2, 0, 20, 15, start.elapsed().as_millis() as u32)
    .unwrap();
  wait_frame(&mut display, start, "pointer entered", |_| true);
  click(&mut display, 20);
  wait_frame(
    &mut display,
    start,
    "exclusive prime retaining focus as on-demand",
    |frame| focused(frame) && has(frame, [0x22, 0xcc, 0xdd]),
  );
  key(&mut display);
  wait_frame(
    &mut display,
    start,
    "first panel key without another click",
    |frame| has(frame, [0x44, 0xee, 0x22]),
  );

  click(&mut display, 80);
  wait_frame(&mut display, start, "persistent exclusive focus", |frame| {
    focused(frame) && !has(frame, [0x22, 0xcc, 0xdd])
  });
  key(&mut display);
  wait_frame(&mut display, start, "second key", |frame| {
    has(frame, [0x33, 0x88, 0xff])
  });
  display
    .graphics
    .input(5, 0, 0, 0, start.elapsed().as_millis() as u32)
    .unwrap();
  wait_frame(&mut display, start, "host dismissal", |frame| {
    !focused(frame)
  });
  stays_unfocused(&mut display, start, [0x33, 0x88, 0xff]);

  click(&mut display, 80);
  wait_frame(&mut display, start, "host reactivation", focused);
  key(&mut display);
  wait_frame(&mut display, start, "third key", |frame| {
    has(frame, [0xff, 0xee, 0x44])
  });
  click(&mut display, 140);
  wait_frame(&mut display, start, "keyboard-none mode", |frame| {
    !focused(frame)
  });
  stays_unfocused(&mut display, start, [0xff, 0xee, 0x44]);

  click(&mut display, 80);
  wait_frame(&mut display, start, "exclusive focus restored", focused);
  key(&mut display);
  wait_frame(&mut display, start, "fourth key", |frame| {
    has(frame, [0xff, 0x44, 0xdd])
  });
  click(&mut display, 200);
  wait_frame(&mut display, start, "unmapped panel", |frame| {
    frame.count([0x30, 0x40, 0x50]) == 0 && !focused(frame)
  });
  stays_unfocused(&mut display, start, [0xff, 0x44, 0xdd]);
  assert!(
    client.0.try_wait().unwrap().is_none(),
    "{}",
    fs::read_to_string(&log).unwrap()
  );
}

#[test]
fn clicked_layer_may_enable_on_demand_focus_after_handling_the_click() {
  if std::env::var("OMARCHY_TEST_GRAPHICS").as_deref() != Ok("1") {
    return;
  }
  for canceled in [false, true] {
    let root = desktop::runtime();
    let qml = root.path().join("demand.qml");
    fs::write(&qml, r##"
import QtQuick
import Quickshell
import Quickshell.Wayland
ShellRoot {
  PanelWindow {
    id: panel
    anchors { top: true; left: true }
    implicitWidth: 400; implicitHeight: 200
    property bool ready: false
    property bool received: false
    property int beat: 0
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: ready ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    color: "#304050"
    Timer { id: admit; interval: 150; onTriggered: panel.ready = true }
    Timer { interval: 75; repeat: true; running: true; onTriggered: panel.beat++ }
    MouseArea { anchors.fill: parent; onClicked: admit.restart() }
    Item { id: editor; focus: true; Keys.onPressed: event => { panel.received = true; event.accepted = true } }
    Rectangle { x: 10; y: 10; width: 20; height: 20; color: editor.Window.active ? "#aaffcc" : "#111122" }
    Rectangle { x: 40; y: 10; width: 20; height: 20; color: panel.received ? "#44ee22" : "#ee4422" }
    Rectangle { x: 70; y: 10; width: 20; height: 20; color: panel.ready ? "#22ccdd" : "#111122" }
    Rectangle { x: 100; y: 10; width: 20; height: 20; color: panel.beat % 2 ? "#667788" : "#8899aa" }
  }
}
"##).unwrap();
    let mut display = Desktop::new(
      root.path(),
      Viewport {
        width: 400,
        height: 200,
        scale_fixed: 120,
      },
    );
    let _client = Host(
      desktop::command(root.path(), &qml, OsStr::new(""))
        .stdout(std::process::Stdio::null())
        .stderr(std::process::Stdio::null())
        .spawn()
        .unwrap(),
    );
    let start = Instant::now();
    wait_frame(&mut display, start, "inert layer", |frame| {
      has(frame, [0xee, 0x44, 0x22]) && !focused(frame)
    });
    for kind in [0, 1] {
      display
        .graphics
        .input(kind, 0x110, 200, 100, start.elapsed().as_millis() as u32)
        .unwrap();
    }
    if canceled {
      display
        .graphics
        .input(5, 0, 0, 0, start.elapsed().as_millis() as u32)
        .unwrap();
      wait_frame(
        &mut display,
        start,
        "late on-demand request after dismissal",
        |frame| has(frame, [0x22, 0xcc, 0xdd]),
      );
      stays_unfocused(&mut display, start, [0xee, 0x44, 0x22]);
    } else {
      wait_frame(
        &mut display,
        start,
        "delayed on-demand focus from one click",
        focused,
      );
      for kind in [3, 4] {
        display
          .graphics
          .input(kind, 26, 0, 0, start.elapsed().as_millis() as u32)
          .unwrap();
      }
      wait_frame(&mut display, start, "key after one click", |frame| {
        has(frame, [0x44, 0xee, 0x22])
      });
    }
  }
}
