#[path = "../../../../../native/ward/tests/support/desktop.rs"]
mod desktop;
use desktop::{Desktop, Frame, Host};
use omarchy_ward::{grants::Grants, presentation::Viewport, revision::Revision, store::Store};
use std::{
  fs,
  os::unix::fs::PermissionsExt,
  path::PathBuf,
  time::{Duration, Instant},
};

struct Admission(Store);
impl Drop for Admission {
  fn drop(&mut self) {
    let _ = self.0.revoke("test.shared");
  }
}

#[test]
fn missing_or_invalid_shared_runtime_fails_without_presenting() {
  if std::env::var("OMARCHY_TEST_GRAPHICS").as_deref() != Ok("1")
    || std::env::var("OMARCHY_TEST_SYSTEMD").as_deref() != Ok("1")
  {
    return;
  }
  use omarchy_ward::session::{Session, Update};
  for invalid_directory in [false, true] {
    let root = desktop::runtime();
    let controller = root.path().join("omarchy-ward");
    fs::copy(
      std::env::var_os("OMARCHY_TEST_WARD_HOST").unwrap(),
      &controller,
    )
    .unwrap();
    if invalid_directory {
      fs::write(root.path().join("ward-runtime"), "not a directory").unwrap();
    }
    let source = root.path().join("source");
    fs::create_dir(&source).unwrap();
    fs::write(source.join("Widget.qml"), "import QtQuick\nItem {}\n").unwrap();
    fs::write(
      source.join("manifest.json"),
      serde_json::to_vec(&serde_json::json!({
        "schemaVersion": 1, "id": "test.shared", "name": "Shared runtime", "version": "1",
        "kinds": ["bar-widget"], "entryPoints": {"barWidget": "Widget.qml"},
        "sandbox": {"version": 1, "requests": {}}
      }))
      .unwrap(),
    )
    .unwrap();
    let store = root.path().join("store");
    let admission = Admission(Store::initialize(&store).unwrap());
    let revision = Revision::import(&source, &admission.0.revisions()).unwrap();
    admission
      .0
      .approve(&revision.digest, Grants::default())
      .unwrap();
    let session = Session::start_with_runtime(
      store,
      "test.shared".into(),
      controller,
      Viewport {
        width: 400,
        height: 240,
        scale_fixed: 120,
      },
      Default::default(),
      invalid_directory.then(|| root.path().join("ward-runtime")),
    )
    .unwrap();
    let deadline = Instant::now() + Duration::from_secs(5);
    loop {
      match session.poll().unwrap() {
        Some(Update::Blocked(_)) => panic!("invalid runtime issued a broker request"),
        Some(Update::Observation(selected)) => assert!(!selected, "unrequested observation was exposed"),
        Some(Update::Failed(error)) => {
          assert!(!error.is_empty());
          break;
        }
        Some(Update::Presentation(omarchy_ward::presentation::Event::Frame { .. }))
        | Some(Update::Stream(omarchy_ward::presentation::StreamEvent {
          event: omarchy_ward::presentation::Event::Frame { .. },
          ..
        })) => {
          panic!("invalid runtime produced a frame");
        }
        // Ready acknowledges controller admission, not worker content.
        Some(
          Update::Ready
          | Update::Presentation(_)
          | Update::Stream(_)
          | Update::TopologyReady(_)
          | Update::ViewSize { .. }
          | Update::PanelState { .. }
          | Update::WidgetSize { .. }
          | Update::PanelSwitch { .. },
        ) => (),
        None => {
          assert!(
            Instant::now() < deadline,
            "invalid runtime did not fail startup"
          );
          std::thread::sleep(Duration::from_millis(5));
        }
      }
    }
  }
}

fn wait_frame(
  display: &mut Desktop,
  start: Instant,
  log: &PathBuf,
  name: &str,
  ready: impl Fn(&Frame) -> bool,
) {
  let deadline = Instant::now()
    + Duration::from_secs(if name == "ready" || name == "restored" {
      8
    } else {
      3
    });
  let mut last_frame = None;
  while Instant::now() < deadline {
    for frame in display.step(start.elapsed().as_millis() as u32) {
      if ready(&frame) {
        if let Some(directory) = std::env::var_os("OMARCHY_TEST_SURFACE_FRAMES") {
          frame.save(PathBuf::from(directory).join(format!("shared-{name}.ppm")));
        }
        return;
      }
      last_frame = Some(frame);
    }
    std::thread::sleep(Duration::from_millis(5));
  }
  if let (Some(frame), Some(directory)) =
    (last_frame, std::env::var_os("OMARCHY_TEST_SURFACE_FRAMES"))
  {
    frame.save(PathBuf::from(directory).join(format!("shared-{name}-failed.ppm")));
  }
  panic!(
    "shared runtime did not reach {name}: {}\n{}",
    fs::read_to_string(log).unwrap(),
    fs::read_to_string(log.parent().unwrap().join("controller.log")).unwrap_or_default()
  );
}

#[test]
fn staged_shared_runtime_loads_original_contracts_without_bundled_host_modules() {
  for settings_granted in [false, true] {
    shared_runtime(settings_granted);
  }
}

fn shared_runtime(settings_granted: bool) {
  if std::env::var("OMARCHY_TEST_GRAPHICS").as_deref() != Ok("1")
    || std::env::var("OMARCHY_TEST_SYSTEMD").as_deref() != Ok("1")
  {
    return;
  }
  let Some(controller) = std::env::var_os("OMARCHY_TEST_WARD_HOST") else {
    eprintln!("set OMARCHY_TEST_WARD_HOST to the CMake-staged controller");
    return;
  };
  let Some(module) = std::env::var_os("OMARCHY_TEST_QT_BRIDGE") else {
    return;
  };
  let controller = PathBuf::from(controller);
  let runtime_root = PathBuf::from(
    std::env::var_os("OMARCHY_TEST_WARD_RUNTIME")
      .expect("select the separately staged Omarchy adapter"),
  );
  let runtime = runtime_root.join("shell");
  assert_eq!(
    fs::read(runtime.join("worker.qml")).unwrap(),
    include_bytes!("../../../../../shell/ward-runtime/worker.qml")
  );
  let root = desktop::runtime();
  let source = root.path().join("source");
  fs::create_dir(&source).unwrap();
  fs::write(source.join("manifest.json"), serde_json::to_vec(&serde_json::json!({
    "schemaVersion": 1, "id": "test.shared", "name": "Shared runtime", "version": "1",
    "kinds": ["bar-widget", "service", "overlay"],
    "entryPoints": {"barWidget": "Widget #.qml", "service": "Service.qml", "overlay": "Overlay.qml"},
    "barWidget": {"defaultSection": "right"}, "sandbox": {"version": 1, "requests": {"desktopGeometry": true, "settings": {"read": ["width", "fontSize", "nested"], "write": ["width", "fontSize", "nested"]}}}
  })).unwrap()).unwrap();
  fs::write(
    source.join("Service.qml"),
    r#"
import QtQuick
import Quickshell.Io
import qs.Ward
Item {
  id: service
  property var shell: null
  property var manifest: null
  property int presses: 0
  property bool jsonResult: false
  property bool geometryGranted: false
  property bool readOnlyContext: false
  property int geometryChanges: 0
  Connections { target: Desktop; function onChanged() { service.geometryChanges++ } }
  Process {
    command: ["/bin/bash", "-c", "! printf forbidden > /context/state.json && ! printf forbidden > /run/plugin/grants.json"]
    running: true
    onExited: function(code) { service.readOnlyContext = code === 0 }
  }
  FileView {
    path: "/run/plugin/grants.json"
    onLoaded: service.geometryGranted = JSON.parse(text()).desktopGeometry
  }
  Process {
    command: ["/bootstrap", "--json", "--exec", "unselected"]
    running: true
    stdout: StdioCollector {
      onStreamFinished: {
        const result = JSON.parse(text)
        service.jsonResult = result.version === 1 && result.status === "denied"
      }
    }
  }
}
"#,
  )
  .unwrap();
  fs::write(
    source.join("Widget #.qml"),
    r##"
import QtQuick
import Quickshell
import qs.Ui
import qs.Commons
import qs.Ward
BarWidget {
  id: root
  moduleName: "test.shared"
  implicitWidth: bar && bar.vertical ? barSize : settings.width
  implicitHeight: bar && bar.vertical ? settings.width : barSize
  readonly property bool tooltipHovered: hover.containsMouse
  readonly property var own: bar && bar.shell ? bar.shell.serviceFor(moduleName) : null
  readonly property var geometry: bar && bar.shell ? bar.shell.desktopGeometry : null
  readonly property bool expectGeometry: own && own.geometryGranted && settings.fontSize !== 16
  readonly property var monitor: Desktop.monitorFor(Quickshell.screens[0])
  readonly property bool adapterValid: own && Desktop.granted === own.geometryGranted
    && Desktop.monitorFor(null) === null && Desktop.monitorFor({}) === null
    && Desktop.dispatch === undefined && Desktop.request === undefined
    && (expectGeometry
      ? Desktop.available && monitor !== null && monitor.x === -400 && monitor.width === 400
        && monitor.scale === 1.25 && monitor.activeWorkspace.id === 2
        && monitor.lastIpcObject.reserved[1] === 26 && monitor.name === undefined
        && Desktop.toplevels.values.length === 1 && Desktop.toplevels.values[0].address === "3"
        && Desktop.toplevels.values[0].workspace.id === 2
        && Desktop.toplevels.values[0].lastIpcObject.at[0] === settings.fontSize * 5 - 20
        && Desktop.toplevels.values[0].lastIpcObject.at[1] === -12.5
        && Desktop.toplevels.values[0].lastIpcObject.size[0] === 200
        && Desktop.toplevels.values[0].lastIpcObject.mapped === true
        && Desktop.toplevels.values[0].lastIpcObject.hidden === false
        && Desktop.toplevels.values[0].lastIpcObject.fullscreen === false
        && Desktop.toplevels.values[0].lastIpcObject.title === undefined
      : !Desktop.available && monitor === null && Desktop.toplevels.values.length === 0)
  readonly property bool geometryValid: own && (expectGeometry
    ? geometry !== null && geometry.viewport === 1 && geometry.outputs.length === 1
      && geometry.workspaces[0].output === 1 && geometry.windows[0].id === 3
      && geometry.windows[0].rect.x === settings.fontSize * 5 - 20
      && geometry.windows[0].rect.y === -12.5 && geometry.windows[0].title === undefined
    : geometry === null)
  readonly property bool scoped: own && own.jsonResult && own.readOnlyContext
    && (!own.geometryGranted || settings.fontSize === 12 || own.geometryChanges > 0)
    && bar.shell.serviceFor("other.plugin") === null
    && bar.shell.summon("other.plugin", "") === false
    && bar.shell.updateEntryInline("other.plugin", {}) === false
    && settings.id === undefined && settings.sandbox === undefined
    && settings.hidden === undefined
    && settings.nested.text.length === 8192 && settings.nested.other === undefined
    && Style.fontBaseSize === settings.fontSize && Style.cornerRadius === 7 && Style.gapsOut === 4
    && Style.resolvedFontFamily === "monospace" && geometryValid && adapterValid
  Rectangle {
    anchors.centerIn: parent
    width: bar.vertical ? 20 : root.implicitWidth
    height: bar.vertical ? root.implicitHeight : 20
    color: !root.scoped ? "#ee1122" : root.own.presses === 0 ? Color.accent
      : root.own.presses === 1 ? Color.foreground : Color.urgent
  }
  MouseArea {
    id: hover
    anchors.fill: parent
    hoverEnabled: true
    onEntered: root.bar.showTooltip(root, "A deliberately long plain-text <b>tooltip</b> that wraps within the private output")
    onExited: root.bar.hideTooltip(root)
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    onClicked: mouse => {
      root.bar.hideTooltip(root)
      if (mouse.button === Qt.RightButton) {
        var entry = Object.assign({}, root.settings, { id: root.moduleName, width: 80 })
        root.settings = entry
        root.bar.shell.updateEntryInline(root.moduleName, entry)
        return
      }
      root.own.presses++
      root.bar.shell.summon(root.moduleName, JSON.stringify({ source: "button" }))
    }
  }
}
"##,
  )
  .unwrap();
  fs::write(source.join("Overlay.qml"), r##"
import QtQuick
import Quickshell
import Quickshell.Wayland
Item {
  id: root
  property var shell: null
  property var manifest: null
  property bool opened: false
  property bool payloadReceived: false
  function open(payload) { payloadReceived = JSON.parse(payload).source === "button"; opened = true }
  function close() { opened = false }
  PanelWindow {
    visible: root.opened
    implicitWidth: 200; implicitHeight: 120
    color: root.payloadReceived ? "#44ee22" : "#ee1122"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    Item {
      anchors.fill: parent
      focus: true
      Keys.onEscapePressed: root.shell.hide(root.manifest.id)
    }
  }
}
"##).unwrap();
  assert!(!source.join("Commons").exists() && !source.join("Ui").exists());
  let admission = Admission(Store::initialize(&root.path().join("store")).unwrap());
  let revision = Revision::import(&source, &admission.0.revisions()).unwrap();
  admission
    .0
    .approve(
      &revision.digest,
      Grants {
        desktop_geometry: settings_granted,
        settings: omarchy_ward::settings::Grant {
          read: ["width".into(), "fontSize".into(), "nested".into()].into(),
          write: if settings_granted {
            ["width".into(), "fontSize".into(), "nested".into()].into()
          } else {
            Default::default()
          },
        },
        ..Default::default()
      },
    )
    .unwrap();
  fs::create_dir(root.path().join("shell")).unwrap();
  let host_qml = root.path().join("shell/shell.qml");
  let repo = PathBuf::from(env!("CARGO_MANIFEST_DIR"))
    .join("../../../..")
    .canonicalize()
    .unwrap();
  for module in ["Commons", "Ui"] {
    std::os::unix::fs::symlink(
      repo.join("shell").join(module),
      root.path().join("shell").join(module),
    )
    .unwrap();
  }
  std::os::unix::fs::symlink(
    repo.join("shell/services"),
    root.path().join("shell/Services"),
  )
  .unwrap();
  fs::create_dir(root.path().join("bin")).unwrap();
  for name in ["omarchy-plugin-settings-apply", "omarchy-shell"] {
    fs::copy(
      repo.join("bin").join(name),
      root.path().join("bin").join(name),
    )
    .unwrap();
  }
  // systemd does not inherit the Qt caller's private IPC environment.
  let private_controller = root.path().join("controller");
  let quote =
    |path: &std::path::Path| format!("'{}'", path.display().to_string().replace('\'', "'\\''"));
  fs::write(&private_controller, format!(
    "#!/bin/bash\nexport OMARCHY_PATH={0} XDG_RUNTIME_DIR={0} WAYLAND_DISPLAY=wayland PATH={0}/bin:/usr/bin\nexec {1} \"$@\" 2>>{0}/controller.log\n",
    quote(root.path()), quote(&controller))).unwrap();
  fs::set_permissions(&private_controller, fs::Permissions::from_mode(0o700)).unwrap();
  let host_context = root.path().join("host-context.json");
  let context = |width, font_size, foreground| {
    serde_json::json!({
      "settings": {"id": "test.shared", "sandbox": true, "sandboxPresentation": {"overlayMode": "visual"}, "width": width, "fontSize": font_size,
        "nested": {"text": "x".repeat(8192)}, "hidden": "host-only"},
      "foreground": foreground, "fontSize": font_size, "enabled": true,
      "untouched": {"otherPlugin": "preserved"},
    })
  };
  fs::write(
    &host_context,
    serde_json::to_vec(&context(40, 12, "#22aadd")).unwrap(),
  )
  .unwrap();
  let shell_source = fs::read_to_string(repo.join("shell/shell.qml")).unwrap();
  let method = |signature: &str, closing: &str| {
    let start = shell_source.find(signature).unwrap();
    let end = start + shell_source[start..].find(closing).unwrap() + closing.len();
    &shell_source[start..end]
  };
  let host_source = r##"
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Commons
import "Services"
ShellRoot {
  id: shell
  property var shellConfig: ({plugins: []})
  property var builtinShellConfig: ({})
  property alias sandboxedPlugins: plugins
  property string barPosition: "top"
  property int barOffset: 4
  property bool barVisible: true
  function persistShellConfig(config) {
    shellConfig = config
    plugins.sync([], config.bar.layout.right)
    var context = JSON.parse(data.text())
    context.settings = config.bar.layout.right[0]
    data.setText(JSON.stringify(context))
  }
  IpcHandler {
    target: "shell"
    @SAVE_SETTINGS@
  }
  SandboxedPlugins {
    id: plugins
    onChanged: console.log("SHARED", JSON.stringify(status("test.shared")))
    geometrySource: QtObject {
      property var snapshot: null
      function forScreen(screen) { return snapshot }
    }
  }
  FileView {
    id: data
    path: Quickshell.env("TEST_CONTEXT")
    watchChanges: true
    onFileChanged: reload()
    onLoaded: {
      var context = JSON.parse(text())
      plugins.geometrySource.snapshot = context.fontSize === 16 ? null : {
        viewport: 1,
        outputs: [{id: 1, rect: {x: -400, y: 0, width: 400, height: 240}, scale: 1.25, reserved: [0, 26, 0, 0], activeWorkspaces: [2]}],
        workspaces: [{id: 2, output: 1}],
        windows: [{id: 3, workspace: 2, rect: {x: context.fontSize * 5 - 20, y: -12.5, width: 200, height: 100}, mapped: true, hidden: false, fullscreen: false}]
      }
      Color.accent = "#eeaa22"
      Color.foreground = context.foreground
      Color.urgent = "#aa44dd"
      Color.shellValues = { "font.base-size": String(context.fontSize), "bar.size-horizontal": "26", "bar.scale-with-font": "false", "tooltip.background": "#123456" }
      Style.applyShellValues(Color.shellValues)
      Style.cornerRadius = 7
      Style.gapsOut = 4
      Style.resolvedFontFamily = "monospace"
      shell.barPosition = context.position || "top"
      shell.barOffset = context.offset === undefined ? 4 : context.offset
      shell.barVisible = context.barVisible !== false
      shell.shellConfig = {plugins: [], bar: {layout: {right: [JSON.parse(JSON.stringify(context.settings))]}}}
      plugins.sync([], context.enabled ? [context.settings] : [])
      // Subsequent mutation of the caller's object must not mutate the copy.
      context.settings.nested.other = "not for the worker"
    }
  }
  PanelWindow {
    id: barWindow
    readonly property bool vertical: shell.barPosition === "left" || shell.barPosition === "right"
    anchors {
      top: shell.barPosition === "top" || vertical
      bottom: shell.barPosition === "bottom" || vertical
      left: shell.barPosition === "left" || !vertical
      right: shell.barPosition === "right" || !vertical
    }
    implicitWidth: vertical ? 26 : 0
    implicitHeight: vertical ? 0 : 26
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Top
    mask: Region {}
    SandboxedBarWidget {
      manager: plugins
      moduleName: "test.shared"
      visible: shell.barVisible
      bar: QtObject { property int barSize: 26; property string position: shell.barPosition }
      x: barWindow.vertical ? 0 : parent.width - width - shell.barOffset
      y: barWindow.vertical ? parent.height - height - shell.barOffset : 0
      width: implicitWidth; height: implicitHeight
    }
  }
  FloatingWindow {
    implicitWidth: 400; implicitHeight: 240; color: "#24303a"
    mask: Region { x: 15; y: 65; width: 30; height: 30 }
    Rectangle {
      x: 15; y: 65; width: 30; height: 30; color: "#bb6633"
      MouseArea { anchors.fill: parent; onClicked: parent.color = "#ee5599" }
    }
  }
}
"##;
  fs::write(
    &host_qml,
    host_source.replace(
      "@SAVE_SETTINGS@",
      method("function saveSandboxSettings(", "\n    }"),
    ),
  )
  .unwrap();
  let log = root.path().join("host.log");
  let mut display = Desktop::new(
    root.path(),
    Viewport {
      width: 400,
      height: 240,
      scale_fixed: 120,
    },
  );
  let _host = Host(
    desktop::command(root.path(), &host_qml, &module)
      .env("HOME", root.path().join("home"))
      .env("OMARCHY_WARD_STORE", root.path().join("store"))
      .env("OMARCHY_WARD_HOST", private_controller)
      .env("OMARCHY_WARD_RUNTIME", &runtime_root)
      .env("OMARCHY_PLUGIN_CONTEXT", "1")
      .env("TEST_CONTEXT", &host_context)
      .stdout(fs::File::create(&log).unwrap())
      .stderr(fs::File::options().append(true).open(&log).unwrap())
      .spawn()
      .unwrap(),
  );
  let start = Instant::now();
  wait_frame(&mut display, start, &log, "ready", |frame| {
    frame.count([0xee, 0xaa, 0x22]) == 800
  });
  let click = |display: &mut Desktop, x, y| {
    display
      .graphics
      .input(2, 0, x, y, start.elapsed().as_millis() as u32)
      .unwrap();
    for kind in [0, 1] {
      display
        .graphics
        .input(kind, 0x110, x, y, start.elapsed().as_millis() as u32)
        .unwrap();
      if kind == 0 {
        display.step(start.elapsed().as_millis() as u32);
        std::thread::sleep(Duration::from_millis(10));
      }
    }
  };
  click(&mut display, 30, 80);
  wait_frame(&mut display, start, &log, "click-through", |frame| {
    frame.count([0xee, 0x55, 0x99]) == 900
  });
  for (index, color) in [[0x22, 0xaa, 0xdd], [0xaa, 0x44, 0xdd]]
    .into_iter()
    .enumerate()
  {
    click(&mut display, 375, 13);
    wait_frame(&mut display, start, &log, "opened", |frame| {
      frame.count([0x44, 0xee, 0x22]) == 24000
    });
    for kind in [3, 4] {
      display
        .graphics
        .input(kind, 9, 0, 0, start.elapsed().as_millis() as u32)
        .unwrap();
    }
    wait_frame(
      &mut display,
      start,
      &log,
      &format!("closed-{index}"),
      |frame| {
        frame.count(color) == if index == 0 { 800 } else { 1200 }
          && frame.count([0x44, 0xee, 0x22]) == 0
      },
    );
    if index == 0 {
      fs::write(
        &host_context,
        serde_json::to_vec(&context(60, 14, "#11cc99")).unwrap(),
      )
      .unwrap();
      wait_frame(&mut display, start, &log, "live-context", |frame| {
        frame.count([0x11, 0xcc, 0x99]) == 1200
      });
      for (font_size, color, rgb, name) in [
        (16, "#33bb88", [0x33, 0xbb, 0x88], "geometry-unavailable"),
        (14, "#11cc99", [0x11, 0xcc, 0x99], "geometry-recovered"),
      ] {
        fs::write(
          &host_context,
          serde_json::to_vec(&context(60, font_size, color)).unwrap(),
        )
        .unwrap();
        wait_frame(&mut display, start, &log, name, |frame| {
          frame.count(rgb) == 1200
        });
      }
    }
  }
  for kind in [2, 0, 1] {
    display
      .graphics
      .input(
        kind,
        if kind == 2 { 0 } else { 0x111 },
        375,
        13,
        start.elapsed().as_millis() as u32,
      )
      .unwrap();
    display.step(start.elapsed().as_millis() as u32);
    std::thread::sleep(Duration::from_millis(10));
  }
  // Wait beyond the debounce and broker round trip, then assert the host's
  // persisted entry, not just the widget's optimistic local settings.
  let deadline = Instant::now() + Duration::from_secs(2);
  let mut saved_pixels = 0;
  while Instant::now() < deadline {
    for frame in display.step(start.elapsed().as_millis() as u32) {
      saved_pixels = frame.count([0xaa, 0x44, 0xdd]);
      if let Some(directory) = std::env::var_os("OMARCHY_TEST_SURFACE_FRAMES") {
        frame
          .save(PathBuf::from(directory).join(format!("shared-settings-{settings_granted}.ppm")));
      }
    }
    std::thread::sleep(Duration::from_millis(5));
  }
  assert_eq!(
    saved_pixels,
    if settings_granted { 1600 } else { 1200 },
    "settings callback did not reconcile with host state"
  );
  let mut saved: serde_json::Value =
    serde_json::from_slice(&fs::read(&host_context).unwrap()).unwrap();
  assert_eq!(
    saved["settings"]["width"],
    if settings_granted { 80 } else { 60 }
  );
  assert_eq!(saved["settings"]["id"], "test.shared");
  assert_eq!(saved["settings"]["sandbox"], true);
  assert_eq!(
    saved["settings"]["hidden"], "host-only",
    "saving selected keys must preserve unreadable settings"
  );
  assert_eq!(saved["untouched"]["otherPlugin"], "preserved");
  // The real host spacer receives worker size, then moves the existing worker
  // through every bar orientation. Settings and service state must survive.
  let width = if settings_granted { 80 } else { 60 };
  let pixel = |frame: &Frame, x: usize, y: usize, rgb: [u8; 3]| {
    let offset = (y * frame.size().0 as usize + x) * 4;
    frame.pixels()[offset..offset + 3] == rgb
  };
  for (position, x, y) in [
    ("top", 320 - width / 2, 13),
    ("bottom", 320 - width / 2, 227),
    ("left", 13, 160 - width / 2),
    ("right", 387, 160 - width / 2),
  ] {
    saved["position"] = position.into();
    saved["offset"] = 80.into();
    fs::write(&host_context, serde_json::to_vec(&saved).unwrap()).unwrap();
    wait_frame(&mut display, start, &log, position, |frame| {
      frame.count([0xaa, 0x44, 0xdd]) == width * 20 && pixel(frame, x, y, [0xaa, 0x44, 0xdd])
    });
    display
      .graphics
      .input(2, 0, x as i32, y as i32, start.elapsed().as_millis() as u32)
      .unwrap();
    let hovered_at = Instant::now();
    while hovered_at.elapsed() < Duration::from_millis(200) {
      for frame in display.step(start.elapsed().as_millis() as u32) {
        assert_eq!(
          frame.count([0x12, 0x34, 0x56]),
          0,
          "tooltip skipped its hover delay"
        );
      }
      std::thread::sleep(Duration::from_millis(5));
    }
    wait_frame(
      &mut display,
      start,
      &log,
      &format!("tooltip-{position}"),
      |frame| frame.count([0x12, 0x34, 0x56]) > 1000,
    );
    if position == "top" {
      // The first painted popup precedes Qt's queued mask polish and the
      // private-to-host input-region round trip.
      let mask_deadline = Instant::now() + Duration::from_millis(200);
      while Instant::now() < mask_deadline {
        display.step(start.elapsed().as_millis() as u32);
        std::thread::sleep(Duration::from_millis(5));
      }
      assert!(
        !display.mask().iter().any(|region| {
          region.operation == 1
            && region.x <= 30
            && 30 < region.x + region.width
            && region.y <= 50
            && 50 < region.y + region.height
        }),
        "the tooltip must not add an input region: {:?}",
        display.mask()
      );
    }
    display
      .graphics
      .input(2, 0, 30, 80, start.elapsed().as_millis() as u32)
      .unwrap();
    wait_frame(&mut display, start, &log, "tooltip-dismissed", |frame| {
      frame.count([0x12, 0x34, 0x56]) == 0
    });
    click(&mut display, x as i32, y as i32);
    wait_frame(&mut display, start, &log, "relocated-click", |frame| {
      frame.count([0x44, 0xee, 0x22]) == 24000
    });
    // Pointer departure must not dismiss or defocus the keyboard panel.
    display
      .graphics
      .input(2, 0, 30, 80, start.elapsed().as_millis() as u32)
      .unwrap();
    for kind in [3, 4] {
      display
        .graphics
        .input(kind, 9, 0, 0, start.elapsed().as_millis() as u32)
        .unwrap();
    }
    wait_frame(&mut display, start, &log, "relocated-close", |frame| {
      frame.count([0x44, 0xee, 0x22]) == 0 && frame.count([0xaa, 0x44, 0xdd]) == width * 20
    });
  }
  saved["barVisible"] = false.into();
  fs::write(&host_context, serde_json::to_vec(&saved).unwrap()).unwrap();
  wait_frame(&mut display, start, &log, "bar-hidden", |frame| {
    frame.count([0xaa, 0x44, 0xdd]) == 0
  });
  saved["barVisible"] = true.into();
  fs::write(&host_context, serde_json::to_vec(&saved).unwrap()).unwrap();
  wait_frame(&mut display, start, &log, "bar-visible", |frame| {
    frame.count([0xaa, 0x44, 0xdd]) == width * 20
  });
  saved["enabled"] = false.into();
  fs::write(&host_context, serde_json::to_vec(&saved).unwrap()).unwrap();
  wait_frame(&mut display, start, &log, "stopped", |frame| {
    frame.count([0xaa, 0x44, 0xdd]) == 0
  });
  saved["enabled"] = true.into();
  fs::write(&host_context, serde_json::to_vec(&saved).unwrap()).unwrap();
  wait_frame(&mut display, start, &log, "restored", |frame| {
    frame.count([0xee, 0xaa, 0x22]) == if settings_granted { 1600 } else { 1200 }
  });
  admission.0.revoke("test.shared").unwrap();
  wait_frame(&mut display, start, &log, "revoked", |frame| {
    frame.count([0xee, 0xaa, 0x22]) == 0
  });
}
