#[path = "../../../../../native/ward/tests/support/desktop.rs"]
mod desktop;
#[path = "support/operator.rs"]
mod operator;
use desktop::{Desktop, Host};
use omarchy_ward::presentation::Viewport;
use std::{
  fs,
  os::unix::fs::PermissionsExt,
  path::PathBuf,
  sync::mpsc,
  time::{Duration, Instant},
};

#[test]
fn broker_denial_reaches_host_feedback_without_worker_notification_access() {
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
  for name in ["Commons", "Ui"] {
    std::os::unix::fs::symlink(repo.join("shell").join(name), root.path().join(name)).unwrap();
  }
  let plugin = root
    .path()
    .join("home/.config/omarchy/plugins/test.security");
  fs::create_dir_all(&plugin).unwrap();
  fs::write(plugin.join("manifest.json"), serde_json::to_vec(&serde_json::json!({
    "schemaVersion":1,"id":"test.security","name":"Security fixture","version":"1","kinds":["panel"],
    "entryPoints":{"panel":"worker.qml"},"sandbox":{"version":1,"entryPoint":"worker.qml","requests":{
      "exec":{"demo":{"executable":"/usr/bin/printf","tree":{"next":[{"arg":{"kind":"exact","value":"allowed"},"then":{"end":"allowed"}}]}}}
    }}
  })).unwrap()).unwrap();
  fs::write(plugin.join("worker.qml"), r##"
import QtQuick
import Quickshell
import Quickshell.Io
ShellRoot {
  FloatingWindow {
    implicitWidth: 300; implicitHeight: 180; color: "#304050"
    Rectangle {
      id: button; x: 20; y: 60; width: 260; height: 60; color: "#bb6633"
      Text { id: resultText; anchors.centerIn: parent; text: "Malicious Execution"; color: "white" }
      MouseArea { anchors.fill: parent; onClicked: attempt.running = true }
    }
    Process {
      id: attempt
      command: ["/bootstrap", "--json", "--exec", "demo", "unapproved"]
      stdout: StdioCollector { onStreamFinished: {
        const response = JSON.parse(text)
        resultText.text = text
        button.color = response.version === 1 && response.status === "denied" ? "#44ee22" : "#ff0000"
      } }
    }
  }
}
"##).unwrap();
  let qml = root.path().join("host.qml");
  fs::write(&qml, format!(r##"
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "file://{}/shell/services" as Services
ShellRoot {{
  Services.SandboxedPlugins {{ id: plugins }}
  Services.PluginSecurityFeedback {{ id: feedback; manager: plugins }}
  PanelWindow {{ anchors {{ top:true; bottom:true; left:true; right:true }} color:"#171c25"; WlrLayershell.layer: WlrLayer.Bottom }}
  IpcHandler {{
    target: "shell"
    function enablePlugin(id: string, placement: string): string {{ return plugins.enable(id, {{sandboxPresentation:{{overlayMode:"pointer"}}}}) }}
    function pluginStatus(id: string): string {{ return JSON.stringify(plugins.status(id)) }}
    function setPluginEnabled(id: string, enabled: string): string {{ plugins.disable(id); return "ok" }}
    function feedbackState(): string {{ return JSON.stringify(feedback.lastEvent) }}
  }}
}}
"##, repo.display())).unwrap();
  let env = operator::environment(root.path(), &repo, &qml, &module);
  // Observe the real host notification command without emitting a desktop toast.
  let notification = root.path().join("bin/omarchy-notification-send");
  fs::write(
    &notification,
    "#!/bin/bash\nprintf '%s\\n' \"$@\" >> \"$XDG_RUNTIME_DIR/notifications.log\"\n",
  )
  .unwrap();
  fs::set_permissions(notification, fs::Permissions::from_mode(0o755)).unwrap();
  let mut display = Desktop::new(
    root.path(),
    Viewport {
      width: 800,
      height: 480,
      scale_fixed: 120,
    },
  );
  let log = root.path().join("host.log");
  let _host = Host(
    desktop::command(root.path(), &qml, &module)
      .envs(env.iter().cloned())
      .env_remove("HYPRLAND_INSTANCE_SIGNATURE")
      .stdout(fs::File::create(&log).unwrap())
      .stderr(fs::File::options().append(true).open(&log).unwrap())
      .spawn()
      .unwrap(),
  );
  let (send, receive) = mpsc::channel();
  let (ack, wait) = mpsc::channel();
  let notification_log = root.path().join("notifications.log");
  let commands = std::thread::spawn(move || {
    let run = |name: &str, args: &[&str]| operator::run(&env, name, args);
    let review: serde_json::Value =
      serde_json::from_str(&run("omarchy-plugin-review", &["test.security", "--json"])).unwrap();
    run(
      "omarchy-plugin-approve",
      &[
        "test.security",
        "--revision",
        review["revision"].as_str().unwrap(),
        "--exec",
        "demo:allowed",
        "--yes",
      ],
    );
    // The review manifest requests no notification access; approval selects exec only.
    assert!(review["requests"]["notifications"] != true);
    run("omarchy-plugin-enable", &["test.security"]);
    send.send(()).unwrap();
    wait
      .recv_timeout(Duration::from_secs(15))
      .unwrap_or_else(|error| {
        panic!(
          "{error}: {}",
          run("omarchy-shell", &["shell", "feedbackState"])
        )
      });
    let started = Instant::now();
    loop {
      let event: serde_json::Value =
        serde_json::from_str(&run("omarchy-shell", &["shell", "feedbackState"])).unwrap();
      let notice = fs::read_to_string(&notification_log).unwrap_or_default();
      if event["id"] == "test.security"
        && event["action"] == 5
        && notice.contains("Ward blocked this plugin from executing an unapproved host command.")
      {
        assert!(notice.contains("Blocked test.security"));
        assert!(
          !notice.contains("unapproved\n"),
          "worker argv leaked to host prose"
        );
        break;
      }
      assert!(
        started.elapsed() < Duration::from_secs(5),
        "missing host denial: {event}, {notice}"
      );
      std::thread::sleep(Duration::from_millis(25));
    }
    run("omarchy-plugin-disable", &["test.security"]);
  });
  let start = Instant::now();
  let mut enabled = false;
  let mut clicked = false;
  let mut ready_at = None;
  let mut verified = false;
  while !commands.is_finished() {
    let time = start.elapsed().as_millis() as u32;
    if receive.try_recv().is_ok() {
      enabled = true;
    }
    if enabled && !clicked && ready_at.is_some_and(|ready| time > ready + 250) {
      for kind in [0, 1] {
        display.graphics.input(kind, 0x110, 400, 240, time).unwrap();
      }
      clicked = true;
    }
    for frame in display.step(time) {
      if !clicked && frame.count([0xbb, 0x66, 0x33]) > 1000 {
        if ready_at.is_none() {
          ready_at = Some(time);
        }
      }
      if let Some(directory) = std::env::var_os("OMARCHY_TEST_SURFACE_FRAMES") {
        frame.save(PathBuf::from(directory).join("security-latest.ppm"));
      }
      if !verified && frame.count([0x44, 0xee, 0x22]) > 1000 {
        verified = true;
        if let Some(directory) = std::env::var_os("OMARCHY_TEST_SURFACE_FRAMES") {
          frame.save(PathBuf::from(directory).join("security-denied.ppm"));
        }
        ack.send(()).unwrap();
      }
    }
    assert!(
      start.elapsed() < Duration::from_secs(35),
      "security fixture timed out: {}",
      fs::read_to_string(&log).unwrap()
    );
    std::thread::sleep(Duration::from_millis(5));
  }
  assert!(
    commands.join().is_ok(),
    "security operator failed: {}",
    fs::read_to_string(&log).unwrap()
  );
  assert!(verified, "worker did not receive a real policy denial");
}
