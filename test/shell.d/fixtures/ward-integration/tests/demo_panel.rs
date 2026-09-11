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

enum Stage {
  Click,
  Capture(&'static str),
}

// This is Omarchy's synthetic, harmless demonstration asset, not an external
// plugin port. The actual button/response UI runs through the shared worker.
#[test]
fn opt_in_demo_panel_reports_a_real_denied_execution() {
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
    .join("home/.config/omarchy/plugins/demo.ward-hostile");
  fs::create_dir_all(&plugin).unwrap();
  for name in ["manifest.json", "Widget.qml", "Panel.qml"] {
    fs::copy(
      repo.join("dev/plugin-demo/hostile").join(name),
      plugin.join(name),
    )
    .unwrap();
  }
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
  PanelWindow {{
    anchors {{ top:true; left:true; right:true }} implicitHeight:32; color:"#202630"; exclusionMode: ExclusionMode.Ignore
    Services.SandboxedBarWidget {{
      x:20; y:3; moduleName:"demo.ward-hostile"; manager:plugins
      bar: QtObject {{ property string position:"top"; property int barSize:32 }}
    }}
  }}
  IpcHandler {{
    target:"shell"
    function enablePlugin(id:string, placement:string):string {{ return plugins.enable(id, {{}}) }}
    function pluginStatus(id:string):string {{ return JSON.stringify(plugins.status(id)) }}
    function setPluginEnabled(id:string, enabled:string):string {{ plugins.disable(id); return "ok" }}
    function showPanel():string {{ return String(plugins.show("demo.ward-hostile", "{{}}")) }}
    function feedbackState():string {{ return JSON.stringify(feedback.lastEvent) }}
  }}
}}
"##, repo.display())).unwrap();
  let env = operator::environment(root.path(), &repo, &qml, &module);
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
      width: 900,
      height: 600,
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
    let review: serde_json::Value = serde_json::from_str(&run(
      "omarchy-plugin-review",
      &["demo.ward-hostile", "--json"],
    ))
    .unwrap();
    assert!(review["requests"]["notifications"] != true);
    run(
      "omarchy-plugin-approve",
      &[
        "demo.ward-hostile",
        "--revision",
        review["revision"].as_str().unwrap(),
        "--exec",
        "demo:allowed",
        "--yes",
      ],
    );
    run("omarchy-plugin-enable", &["demo.ward-hostile"]);
    assert_eq!(run("omarchy-shell", &["shell", "showPanel"]).trim(), "true");
    let capture = |name| {
      send.send(Stage::Capture(name)).unwrap();
      wait.recv_timeout(Duration::from_secs(5)).unwrap();
    };
    capture("demo-before");
    send.send(Stage::Click).unwrap();
    let started = Instant::now();
    loop {
      let event: serde_json::Value =
        serde_json::from_str(&run("omarchy-shell", &["shell", "feedbackState"])).unwrap();
      let notice = fs::read_to_string(&notification_log).unwrap_or_default();
      if event["id"] == "demo.ward-hostile"
        && event["action"] == 5
        && notice.contains("Ward blocked this plugin from executing an unapproved host command.")
      {
        break;
      }
      if started.elapsed() >= Duration::from_secs(8) {
        capture("demo-failed");
      }
      assert!(
        started.elapsed() < Duration::from_secs(8),
        "missing real demo denial: {event}, {notice}"
      );
      std::thread::sleep(Duration::from_millis(25));
    }
    capture("demo-denied");
    run("omarchy-plugin-disable", &["demo.ward-hostile"]);
  });
  let start = Instant::now();
  let mut capture = None;
  let mut frame = None;
  while !commands.is_finished() || capture.is_some() {
    let time = start.elapsed().as_millis() as u32;
    while let Ok(stage) = receive.try_recv() {
      match stage {
        Stage::Click => {
          for kind in [0, 1] {
            display.graphics.input(kind, 0x110, 130, 248, time).unwrap();
          }
        }
        Stage::Capture(name) => capture = Some((name, Instant::now())),
      }
    }
    for next in display.step(time) {
      frame = Some(next);
    }
    if let (Some((name, requested)), Some(frame)) = (capture, &frame) {
      if requested.elapsed() > Duration::from_millis(500) {
        if let Some(directory) = std::env::var_os("OMARCHY_TEST_SURFACE_FRAMES") {
          frame.save(PathBuf::from(directory).join(format!("{name}.ppm")));
        }
        capture = None;
        ack.send(()).unwrap();
      }
    }
    assert!(
      start.elapsed() < Duration::from_secs(35),
      "demo timed out: {}",
      fs::read_to_string(&log).unwrap()
    );
    std::thread::sleep(Duration::from_millis(5));
  }
  assert!(
    commands.join().is_ok(),
    "demo operator failed: {}",
    fs::read_to_string(&log).unwrap()
  );
}
