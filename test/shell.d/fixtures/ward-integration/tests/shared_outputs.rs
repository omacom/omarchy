//! Real Qt host: per-output bar views, one service and one active own panel.
#[path = "../../../../../native/ward/tests/support/desktop.rs"]
mod desktop;
use desktop::{Desktop, Frame, Host};
use omarchy_ward::{
  grants::Grants, graphics::OutputSpec, presentation::Viewport, revision::Revision, store::Store,
};
use std::{
  fs,
  path::PathBuf,
  time::{Duration, Instant},
};

struct Admission(Store);
impl Drop for Admission {
  fn drop(&mut self) {
    let _ = self.0.revoke("test.outputs");
  }
}
fn wait(
  display: &mut Desktop,
  start: Instant,
  log: &PathBuf,
  name: &str,
  ready: impl Fn(&Frame) -> bool,
) {
  let deadline = Instant::now() + Duration::from_secs(8);
  let mut last = None;
  while Instant::now() < deadline {
    for frame in display.step(start.elapsed().as_millis() as u32) {
      if ready(&frame) {
        if let Some(directory) = std::env::var_os("OMARCHY_TEST_SURFACE_FRAMES") {
          frame.save(PathBuf::from(directory).join(format!("outputs-{name}.ppm")));
        }
        return;
      }
      last = Some(frame);
    }
    std::thread::sleep(Duration::from_millis(5));
  }
  if let (Some(frame), Some(directory)) = (last, std::env::var_os("OMARCHY_TEST_SURFACE_FRAMES")) {
    frame.save(PathBuf::from(directory).join(format!("outputs-{name}-failed.ppm")));
  }
  if let Some(directory) = std::env::var_os("OMARCHY_TEST_SURFACE_FRAMES") {
    fs::copy(log, PathBuf::from(directory).join("outputs-host.log")).unwrap();
  }
  panic!(
    "did not reach {name}: {}\nSTATE {}",
    fs::read_to_string(log).unwrap(),
    fs::read_to_string(log.parent().unwrap().join("state.json")).unwrap_or_default()
  );
}
fn pixel(frame: &Frame, x: usize, y: usize, rgb: [u8; 3]) -> bool {
  let offset = (y * frame.size().0 as usize + x) * 4;
  frame.pixels()[offset..offset + 3] == rgb
}
#[test]
fn shared_host_places_widgets_transfers_panels_and_limits_roaming() {
  if std::env::var("OMARCHY_TEST_GRAPHICS").as_deref() != Ok("1")
    || std::env::var("OMARCHY_TEST_SYSTEMD").as_deref() != Ok("1")
  {
    return;
  }
  let Some(module) = std::env::var_os("OMARCHY_TEST_QT_BRIDGE") else {
    return;
  };
  let Some(controller) = std::env::var_os("OMARCHY_TEST_WARD_HOST") else {
    return;
  };
  let root = desktop::runtime();
  let source = root.path().join("source");
  fs::create_dir(&source).unwrap();
  fs::write(source.join("manifest.json"), serde_json::to_vec(&serde_json::json!({
    "schemaVersion":1,"id":"test.outputs","name":"Shared outputs","version":"1","kinds":["bar-widget","service"],
    "entryPoints":{"barWidget":"Widget.qml","service":"Service.qml"},"sandbox":{"version":1,"requests":{}}
  })).unwrap()).unwrap();
  fs::write(
    source.join("Service.qml"),
    r##"
import QtQuick
import Quickshell
import Quickshell.Wayland
Item {
  property int presses: 0
  // A compromised worker may publish this without ever opening its own panel.
  Variants {
    model: Quickshell.screens
    PanelWindow {
      required property var modelData
      screen: modelData
      anchors { top: true; bottom: true; left: true; right: true }
      color: "#334455"
      exclusionMode: ExclusionMode.Ignore
      WlrLayershell.layer: WlrLayer.Bottom
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
      Rectangle {
        id: witness
        x: 280; y: 150; width: 10; height: 10; color: "#bb1122"
        focus: true
        Keys.onPressed: color = "#ff0000"
      }
      MouseArea { anchors.fill: parent; onClicked: witness.color = "#11bb22" }
    }
  }
}
"##,
  )
  .unwrap();
  fs::write(source.join("Widget.qml"), r##"
import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Ui
BarWidget {
  id: root
  moduleName: "test.outputs"
  implicitWidth: 40; implicitHeight: 26
  property bool opened: false
  readonly property var own: bar.shell.serviceFor(moduleName)
  function open() { opened = true }
  function close() { opened = false }
  Rectangle { anchors.fill: parent; color: !root.own ? "#ee1122" : root.own.presses === 0 ? "#eeaa22" : "#2288ee" }
  MouseArea { anchors.fill: parent; onClicked: { root.own.presses++; root.open() } }
  PanelWindow {
    // Leave the output unspecified: the private compositor must choose the
    // activated output, including for a shared standalone overlay entry point.
    visible: root.opened
    anchors { top: true; left: true }
    margins { top: 40; left: root.mapToItem(root.QsWindow.window.contentItem, 0, 0).x }
    implicitWidth: 100; implicitHeight: 60; color: "#44ee22"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    Item { anchors.fill: parent; focus: true; Keys.onEscapePressed: root.close() }
  }
  // Deliberately request a small roaming surface on every private output.
  // Host policy must independently clip pixels and input on non-owner outputs.
  Variants {
    model: Quickshell.screens
    PanelWindow {
      required property var modelData
      screen: modelData
      visible: root.opened
      anchors { bottom: true; right: true }
      margins { bottom: 20; right: 20 }
      implicitWidth: 20; implicitHeight: 20; color: "#cc44dd"
      exclusionMode: ExclusionMode.Ignore
      WlrLayershell.layer: WlrLayer.Overlay
    }
  }
}
"##).unwrap();
  let admission = Admission(Store::initialize(&root.path().join("store")).unwrap());
  let revision = Revision::import(&source, &admission.0.revisions()).unwrap();
  admission
    .0
    .approve(&revision.digest, Grants::default())
    .unwrap();
  let shell = root.path().join("shell");
  fs::create_dir(&shell).unwrap();
  let repo = PathBuf::from(env!("CARGO_MANIFEST_DIR"))
    .join("../../../..")
    .canonicalize()
    .unwrap();
  for (from, to) in [
    ("Commons", "Commons"),
    ("Ui", "Ui"),
    ("services", "Services"),
  ] {
    std::os::unix::fs::symlink(repo.join("shell").join(from), shell.join(to)).unwrap();
  }
  let settings = root.path().join("settings.json");
  fs::write(&settings, r#"{"id":"test.outputs","sandbox":true}"#).unwrap();
  let qml = shell.join("shell.qml");
  fs::write(&qml, r##"
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "Services"
ShellRoot {
  id: hostRoot
  property int witnessClicks: 0
  property int witnessKeys: 0
  FileView {
    path: Quickshell.env("TEST_STATE")
    atomicWrites: true
    readonly property var instance: plugins.instances["test.outputs"] || null
    readonly property string stateJson: JSON.stringify({
      epoch: instance ? instance.epoch : 0,
      outputs: instance ? instance.screenRows.length : 0,
      ready: instance && instance.screenRows.every(row => row.surface.contentItem.children.some(child => "resizing" in child && child.ready && !child.resizing)),
      command: instance ? instance.panelCommand : null,
      panelOpen: instance && instance.nativeSession.panelOpen,
      opened: instance && instance.opened,
      authorized: instance && instance.panelAuthorized,
      focusHeld: instance && instance.focusHeld,
      witnessClicks: hostRoot.witnessClicks,
      witnessKeys: hostRoot.witnessKeys,
      surfaceFocus: instance ? instance.screenRows.map(row => ({
        output: row.id, policy: row.surface.policy, held: row.surface.focusHeld,
        active: row.surface.contentItem.children.some(child => child.activeFocus)
      })) : [],
      panelSerial: instance ? instance.nativeSession.panelSerial : 0,
      panelSettled: instance && (!instance.panelCommand || instance.panelCommand.serial === instance.nativeSession.panelSerial)
    })
    onStateJsonChanged: setText(stateJson)
    Component.onCompleted: setText(stateJson)
  }
  SandboxedPlugins {
    id: plugins
    onChanged: console.log("OUTPUTS", JSON.stringify(status("test.outputs")))
    geometrySource: null
  }
  FileView {
    path: Quickshell.env("TEST_SETTINGS")
    watchChanges: true
    onFileChanged: reload()
    onLoaded: {
      const entry = JSON.parse(text())
      plugins.sync([], [entry])
      if (entry.fixtureAction === "summon") plugins.show("test.outputs", "")
      if (entry.fixtureAction === "restart") plugins.enable("test.outputs", entry)
    }
  }
  Variants {
    model: Quickshell.screens
    PanelWindow {
      required property var modelData
      screen: modelData
      anchors { top: true; bottom: true; left: true; right: true }
      color: "#112233"
      exclusionMode: ExclusionMode.Ignore
      WlrLayershell.layer: WlrLayer.Bottom
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
      Item { anchors.fill: parent; focus: true; Keys.onPressed: hostRoot.witnessKeys++ }
      MouseArea { anchors.fill: parent; onClicked: hostRoot.witnessClicks++ }
    }
  }
  Variants {
    model: Quickshell.screens
    PanelWindow {
      required property var modelData
      screen: modelData
      anchors { top: true; left: true; right: true }
      implicitHeight: 26; color: "transparent"
      exclusionMode: ExclusionMode.Ignore
      WlrLayershell.layer: WlrLayer.Top
      mask: Region {}
      SandboxedBarWidget {
        manager: plugins; moduleName: "test.outputs"
        bar: QtObject { property int barSize: 26; property string position: "top" }
        x: 40; width: implicitWidth; height: implicitHeight
      }
      SandboxedBarWidget {
        manager: plugins; moduleName: "test.outputs"
        bar: QtObject { property int barSize: 26; property string position: "top" }
        x: 140; width: implicitWidth; height: implicitHeight
      }
    }
  }
}
"##).unwrap();
  let mut display = Desktop::new(
    root.path(),
    Viewport {
      width: 800,
      height: 240,
      scale_fixed: 120,
    },
  );
  let outputs = [
    OutputSpec {
      x: 0,
      y: 0,
      width: 400,
      height: 240,
      scale_fixed: 120,
    },
    OutputSpec {
      x: 400,
      y: 0,
      width: 400,
      height: 240,
      scale_fixed: 120,
    },
  ];
  display.graphics.configure_outputs(&outputs, 0).unwrap();
  let log = root.path().join("host.log");
  let _host = Host(
    desktop::command(root.path(), &qml, &module)
      .env("OMARCHY_PATH", &repo)
      .env("OMARCHY_WARD_HOST", controller)
      .env(
        "OMARCHY_WARD_RUNTIME",
        std::env::var_os("OMARCHY_TEST_WARD_RUNTIME")
          .expect("select the separately staged Omarchy adapter"),
      )
      .env("OMARCHY_WARD_STORE", root.path().join("store"))
      .env("TEST_SETTINGS", &settings)
      .env("TEST_STATE", root.path().join("state.json"))
      .stdout(fs::File::create(&log).unwrap())
      .stderr(fs::File::options().append(true).open(&log).unwrap())
      .spawn()
      .unwrap(),
  );
  let start = Instant::now();
  wait(&mut display, start, &log, "both-bars", |frame| {
    frame.count([0xee, 0xaa, 0x22]) == 4160
      && [50, 150, 450, 550]
        .iter()
        .all(|x| pixel(frame, *x, 13, [0xee, 0xaa, 0x22]))
  });
  let click = |display: &mut Desktop, x, y| {
    for kind in [2, 0, 1] {
      display
        .graphics
        .input(
          kind,
          if kind == 2 { 0 } else { 0x110 },
          x,
          y,
          start.elapsed().as_millis() as u32,
        )
        .unwrap();
      display.step(start.elapsed().as_millis() as u32);
      std::thread::sleep(Duration::from_millis(10));
    }
  };
  let key = |display: &mut Desktop| {
    for kind in [3, 4] {
      display.graphics.input(kind, 38, 0, 0, start.elapsed().as_millis() as u32).unwrap();
      display.step(start.elapsed().as_millis() as u32);
    }
  };
  let witness = |display: &mut Desktop, clicks: u64, keys: u64| {
    let deadline = Instant::now() + Duration::from_secs(3);
    loop {
      display.step(start.elapsed().as_millis() as u32);
      let state: serde_json::Value = fs::read(root.path().join("state.json")).ok()
        .and_then(|bytes| serde_json::from_slice(&bytes).ok()).unwrap_or_default();
      if state["witnessClicks"] == clicks && state["witnessKeys"] == keys { break; }
      assert!(Instant::now() < deadline, "host input witness: {state}");
      std::thread::sleep(Duration::from_millis(5));
    }
  };
  // Full-output worker input and exclusive focus requests have no host authority.
  click(&mut display, 285, 155);
  key(&mut display);
  witness(&mut display, 1, 1);
  click(&mut display, 50, 13);
  wait(&mut display, start, &log, "first-owner", |frame| {
    frame.count([0x22, 0x88, 0xee]) == 4160
      && frame.count([0x44, 0xee, 0x22]) == 6000
      && frame.count([0xcc, 0x44, 0xdd]) == 400
      && pixel(frame, 50, 60, [0x44, 0xee, 0x22])
  });
  click(&mut display, 150, 13);
  wait(&mut display, start, &log, "same-output-owner", |frame| {
    frame.count([0x22, 0x88, 0xee]) == 4160
      && frame.count([0x44, 0xee, 0x22]) == 6000
      && frame.count([0xcc, 0x44, 0xdd]) == 400
      && pixel(frame, 150, 60, [0x44, 0xee, 0x22])
      && !pixel(frame, 50, 60, [0x44, 0xee, 0x22])
  });
  click(&mut display, 450, 13);
  wait(&mut display, start, &log, "second-owner", |frame| {
    frame.count([0x44, 0xee, 0x22]) == 6000
      && frame.count([0xcc, 0x44, 0xdd]) == 400
      && pixel(frame, 450, 60, [0x44, 0xee, 0x22])
  });
  fs::write(
    &settings,
    r#"{"id":"test.outputs","sandbox":true,"sandboxPresentation":{"overlayMode":"visual","overlayOutputs":"all"}}"#,
  )
  .unwrap();
  wait(&mut display, start, &log, "roaming-approved", |frame| {
    frame.count([0x44, 0xee, 0x22]) == 6000 && frame.count([0xcc, 0x44, 0xdd]) == 800
  });
  fs::write(&settings, r#"{"id":"test.outputs","sandbox":true}"#).unwrap();
  wait(&mut display, start, &log, "roaming-restricted", |frame| {
    frame.count([0xcc, 0x44, 0xdd]) == 400
  });
  display
    .graphics
    .configure_outputs(&outputs[..1], start.elapsed().as_millis() as u32)
    .unwrap();
  wait(&mut display, start, &log, "owner-unplugged", |frame| {
    frame.count([0x22, 0x88, 0xee]) == 2080
      && frame.count([0x44, 0xee, 0x22]) == 0
      && frame.count([0xcc, 0x44, 0xdd]) == 0
  });
  // Pixels can outlive an output reconfiguration. Input becomes available only
  // after the new generation has completed its Qt presentation fence.
  let deadline = Instant::now() + Duration::from_secs(3);
  loop {
    display.step(start.elapsed().as_millis() as u32);
    let state: serde_json::Value = fs::read(root.path().join("state.json"))
      .ok()
      .and_then(|bytes| serde_json::from_slice(&bytes).ok())
      .unwrap_or_default();
    if state["epoch"].as_u64().is_some_and(|epoch| epoch >= 2)
      && state["outputs"] == 1
      && state["ready"] == true
      && state["panelSettled"] == true
      && display.mask().iter().any(|region| {
        region.operation == 1
          && region.x <= 50
          && region.y <= 13
          && region.x + region.width > 50
          && region.y + region.height > 13
      })
    {
      break;
    }
    assert!(
      Instant::now() < deadline,
      "surviving view did not regain input"
    );
    std::thread::sleep(Duration::from_millis(5));
  }
  // The underlying witness also contributes a full-output mask. Drain the
  // host's deferred Region polish/Wayland commit after readiness is published.
  let settled = Instant::now() + Duration::from_millis(150);
  while Instant::now() < settled {
    display.step(start.elapsed().as_millis() as u32);
    std::thread::sleep(Duration::from_millis(5));
  }
  click(&mut display, 50, 13);
  wait(&mut display, start, &log, "surviving-view", |frame| {
    frame.count([0x22, 0x88, 0xee]) == 2080 && frame.count([0x44, 0xee, 0x22]) == 6000
  });
  for kind in [3, 4] {
    display
      .graphics
      .input(kind, 9, 0, 0, start.elapsed().as_millis() as u32)
      .unwrap();
  }
  wait(&mut display, start, &log, "escape", |frame| {
    frame.count([0x44, 0xee, 0x22]) == 0
      && frame.count([0xcc, 0x44, 0xdd]) == 0
      && frame.count([0x22, 0x88, 0xee]) == 2080
  });
  click(&mut display, 285, 155);
  key(&mut display);
  witness(&mut display, 2, 2);
  fs::write(&settings, r#"{"id":"test.outputs","sandbox":true,"sandboxPresentation":{"overlayMode":"visual","overlayOutputs":"all"}}"#).unwrap();
  wait(&mut display, start, &log, "closed-visual", |frame| pixel(frame, 285, 155, [0xbb, 0x11, 0x22]));
  click(&mut display, 285, 155);
  key(&mut display);
  witness(&mut display, 3, 3);
  fs::write(&settings, r#"{"id":"test.outputs","sandbox":true,"sandboxPresentation":{"overlayMode":"pointer","overlayOutputs":"all"}}"#).unwrap();
  // Pixels are identical between visual and pointer mode; wait for the host mask.
  let deadline = Instant::now() + Duration::from_secs(3);
  loop {
    display.step(start.elapsed().as_millis() as u32);
    let state: serde_json::Value = serde_json::from_slice(&fs::read(root.path().join("state.json")).unwrap()).unwrap();
    if state["surfaceFocus"][0]["policy"]["pointer"] == true { break; }
    assert!(Instant::now() < deadline, "pointer policy did not arrive");
    std::thread::sleep(Duration::from_millis(5));
  }
  click(&mut display, 285, 155);
  wait(&mut display, start, &log, "closed-pointer", |frame| pixel(frame, 285, 155, [0x11, 0xbb, 0x22]));
  key(&mut display);
  witness(&mut display, 3, 4);
  fs::write(
    &settings,
    r#"{"id":"test.outputs","sandbox":true,"fixtureAction":"summon"}"#,
  )
  .unwrap();
  wait(&mut display, start, &log, "unowned-summon", |frame| {
    frame.count([0x44, 0xee, 0x22]) == 6000 && pixel(frame, 50, 60, [0x44, 0xee, 0x22])
  });
  // Crash only the generated controller owned by this temporary fixture.
  let unit = admission
    .0
    .read("test.outputs")
    .unwrap()
    .active_unit
    .unwrap();
  assert!(
    std::process::Command::new("systemctl")
      .args(["--user", "kill", "--signal=SIGKILL", &unit])
      .status()
      .unwrap()
      .success()
  );
  wait(&mut display, start, &log, "crashed", |frame| {
    frame.count([0x44, 0xee, 0x22]) == 0 && frame.count([0x22, 0x88, 0xee]) == 0
  });
  fs::write(
    &settings,
    r#"{"id":"test.outputs","sandbox":true,"fixtureAction":"restart"}"#,
  )
  .unwrap();
  wait(&mut display, start, &log, "restarted", |frame| {
    frame.count([0xee, 0xaa, 0x22]) == 2080
  });
}
