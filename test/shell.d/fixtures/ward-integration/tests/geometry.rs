#[path = "../../../../../native/ward/tests/support/desktop.rs"]
mod desktop;
use desktop::{Desktop, Host};
use omarchy_ward::{geometry::Snapshot, presentation::Viewport};
use serde_json::{Value, json};
use std::{
  fs,
  io::{Read, Write},
  os::unix::net::{UnixListener, UnixStream},
  path::PathBuf,
  time::{Duration, Instant},
};

// Real Quickshell models fed by private synthetic Hyprland sockets. This
// exercises QObject identities and QScreen mapping, not JavaScript stand-ins.
#[test]
fn desktop_geometry_tracks_models_without_exporting_compositor_identifiers() {
  if std::env::var("OMARCHY_TEST_GRAPHICS").as_deref() != Ok("1") {
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
  let sockets = root.path().join("hypr/geometry-fixture");
  fs::create_dir_all(&sockets).unwrap();
  let requests = UnixListener::bind(sockets.join(".socket.sock")).unwrap();
  let events = UnixListener::bind(sockets.join(".socket2.sock")).unwrap();
  requests.set_nonblocking(true).unwrap();
  events.set_nonblocking(true).unwrap();
  let qml = root.path().join("host.qml");
  fs::write(
    &qml,
    format!(
      r#"
import QtQuick
import Quickshell
import Quickshell.Io
import "file://{}/shell/services" as Services
ShellRoot {{
  Services.PluginDesktopGeometry {{ id: geometry; active: true }}
  FileView {{ id: result; path: Quickshell.env("TEST_SNAPSHOT") }}
  Timer {{ interval: 100; running: true; repeat: true
    onTriggered: {{ gc(); result.setText(JSON.stringify(geometry.forScreen(Quickshell.screens[0]))) }}
  }}
  FloatingWindow {{ implicitWidth: 400; implicitHeight: 240 }}
}}
"#,
      repo.display()
    ),
  )
  .unwrap();
  let output = root.path().join("snapshot.json");
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
    desktop::command(root.path(), &qml, &module)
      .env("HYPRLAND_INSTANCE_SIGNATURE", "geometry-fixture")
      .env("TEST_SNAPSHOT", &output)
      .stdout(fs::File::create(&log).unwrap())
      .stderr(fs::File::options().append(true).open(&log).unwrap())
      .spawn()
      .unwrap(),
  );
  let monitors = json!([{
    "id": 41, "name": "plugin-0", "description": "PRIVATE OUTPUT",
    "x": -400, "y": 20, "width": 500, "height": 300, "scale": 1.25,
    "activeWorkspace": {"id": 71, "name": "PRIVATE NORMAL"},
    "specialWorkspace": {"id": -99, "name": "special:PRIVATE"},
    "reserved": [2, 26, 3, 4], "focused": true
  }]);
  let workspaces = json!([
    {"id": 71, "name": "PRIVATE NORMAL", "monitor": "plugin-0", "monitorID": 41},
    {"id": -99, "name": "special:PRIVATE", "monitor": "plugin-0", "monitorID": 41}
  ]);
  let mut clients = json!([{
    "address": "0xdeadbeef", "title": "PRIVATE TITLE", "class": "PRIVATE APP", "pid": 987654,
    "workspace": {"id": 71, "name": "PRIVATE NORMAL"}, "at": [-350.5, 52.25], "size": [180, 90],
    "mapped": true, "hidden": false, "fullscreen": 0
  }]);
  let start = Instant::now();
  let mut event: Option<UnixStream> = None;
  let mut wait = |clients: &Value, message: Option<&[u8]>, ready: &dyn Fn(&Snapshot) -> bool| {
    let mut message = message;
    let deadline = Instant::now() + Duration::from_secs(4);
    while Instant::now() < deadline {
      if event.is_none() {
        if let Ok((stream, _)) = events.accept() {
          event = Some(stream);
        }
      }
      while let Ok((mut stream, _)) = requests.accept() {
        stream
          .set_read_timeout(Some(Duration::from_millis(100)))
          .unwrap();
        let mut bytes = [0; 128];
        let length = stream.read(&mut bytes).unwrap();
        let response = match &bytes[..length] {
          b"j/status" => json!({"configProvider": "lua"}),
          b"j/monitors" => monitors.clone(),
          b"j/workspaces" => workspaces.clone(),
          b"j/clients" => clients.clone(),
          request => panic!(
            "unexpected geometry request: {:?}",
            String::from_utf8_lossy(request)
          ),
        };
        stream
          .write_all(&serde_json::to_vec(&response).unwrap())
          .unwrap();
        // An earlier creating query may still be in flight. Publish the new
        // client list before its removal event so it cannot recreate a stale
        // object after that event during rapid model churn.
        if &bytes[..length] == b"j/clients" {
          if let Some(message) = message.take() {
            event.as_mut().unwrap().write_all(message).unwrap();
          }
        }
      }
      display.step(start.elapsed().as_millis() as u32);
      if let Ok(bytes) = fs::read(&output) {
        if let Ok(snapshot) = serde_json::from_slice::<Snapshot>(&bytes) {
          snapshot.validate().unwrap();
          assert!(!String::from_utf8(bytes).unwrap().contains("PRIVATE"));
          if ready(&snapshot) {
            return snapshot;
          }
        }
      }
      std::thread::sleep(Duration::from_millis(5));
    }
    panic!(
      "geometry did not converge: {} / snapshot: {:?}",
      fs::read_to_string(&log).unwrap(),
      fs::read_to_string(&output)
    );
  };
  let initial = wait(&clients, None, &|snapshot| {
    snapshot.windows.len() == 1 && snapshot.outputs[0].active_workspaces.len() == 2
  });
  assert_eq!(
    initial.outputs[0].rect.width, 400.0,
    "output extents must use QScreen logical dimensions"
  );
  assert_eq!(initial.outputs[0].rect.x, -400.0);
  assert_eq!(initial.outputs[0].scale, 1.25);
  assert_eq!(initial.outputs[0].reserved, [2.0, 26.0, 3.0, 4.0]);
  assert_eq!(initial.windows[0].rect.x, -350.5);
  assert_ne!(initial.windows[0].id, 0xdeadbeef);
  clients[0]["at"] = json!([-200.25, 72.5]);
  clients[0]["workspace"] = json!({"id": -99, "name": "special:PRIVATE"});
  let moved = wait(&clients, None, &|snapshot| {
    snapshot.windows[0].rect.x == -200.25
  });
  assert_eq!(moved.windows[0].id, initial.windows[0].id);
  assert_ne!(moved.windows[0].workspace, initial.windows[0].workspace);
  assert_eq!(moved.viewport, initial.viewport);
  // Hyprland's close event removes the actual QObject. Reusing the compositor
  // address for a newly created window must not reuse our opaque identity.
  wait(&json!([]), Some(b"closewindow>>deadbeef\n"), &|snapshot| {
    snapshot.windows.is_empty()
  });
  let reopened = wait(&clients, None, &|snapshot| snapshot.windows.len() == 1);
  assert_ne!(reopened.windows[0].id, initial.windows[0].id);
  let mut previous = reopened.windows[0].id;
  for _ in 0..30 {
    wait(&json!([]), Some(b"closewindow>>deadbeef\n"), &|snapshot| {
      snapshot.windows.is_empty()
    });
    let next = wait(&clients, None, &|snapshot| snapshot.windows.len() == 1);
    assert_ne!(next.windows[0].id, previous);
    previous = next.windows[0].id;
  }
}
