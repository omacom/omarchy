//! Existing plugin commands redirected to a private Qt host, never the desktop.
use std::{
  ffi::{OsStr, OsString},
  fs,
  os::unix::fs::PermissionsExt,
  path::Path,
  process::Command,
};

pub fn environment(
  root: &Path,
  repo: &Path,
  qml: &Path,
  module: &OsStr,
) -> Vec<(&'static str, OsString)> {
  let stubs = root.join("bin");
  fs::create_dir(&stubs).unwrap();
  let transport = stubs.join("omarchy-shell");
  fs::write(&transport, "#!/bin/bash\nquiet=0\nif [[ $1 == \"-q\" ]]; then quiet=1; shift; fi\nresult=$(/usr/bin/qs ipc -n -p \"$TEST_HOST_QML\" call -- \"$@\") || exit 1\nif (( !quiet )); then echo \"$result\"; fi\n").unwrap();
  fs::set_permissions(&transport, fs::Permissions::from_mode(0o755)).unwrap();
  // systemd inherits the user manager's environment, not this Qt host's.
  // Pin fixture state in the executed controller too, never the user's data.
  let controller = stubs.join("controller");
  let binary = std::env::var_os("OMARCHY_TEST_WARD_HOST")
    .expect("OMARCHY_TEST_WARD_HOST must select the built or staged Ward executable");
  let quote = |value: &OsStr| format!("'{}'", value.to_str().unwrap().replace('\'', "'\\''"));
  fs::write(
    &controller,
    format!(
      "#!/bin/bash\nexport XDG_STATE_HOME={}\nexec {} \"$@\"\n",
      quote(root.join("data").as_os_str()),
      quote(&binary)
    ),
  )
  .unwrap();
  fs::set_permissions(&controller, fs::Permissions::from_mode(0o755)).unwrap();
  vec![
    ("HOME", root.join("home").into_os_string()),
    ("OMARCHY_PATH", repo.as_os_str().to_owned()),
    ("OMARCHY_WARD_STORE", root.join("state").into_os_string()),
    ("OMARCHY_WARD_HOST", controller.into_os_string()),
    (
      "OMARCHY_WARD_RUNTIME",
      std::env::var_os("OMARCHY_TEST_WARD_RUNTIME")
        .expect("select the separately staged Omarchy adapter"),
    ),
    ("XDG_RUNTIME_DIR", root.as_os_str().to_owned()),
    ("XDG_CONFIG_HOME", root.join("config").into_os_string()),
    ("XDG_CACHE_HOME", root.join("cache").into_os_string()),
    ("XDG_STATE_HOME", root.join("data").into_os_string()),
    ("WAYLAND_DISPLAY", "wayland".into()),
    ("QT_QPA_PLATFORM", "wayland".into()),
    ("QT_QPA_PLATFORMTHEME", "none".into()),
    ("QSG_RHI_BACKEND", "opengl".into()),
    ("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1".into()),
    ("QML_IMPORT_PATH", module.to_owned()),
    ("TEST_HOST_QML", qml.as_os_str().to_owned()),
    (
      "PATH",
      format!(
        "{}:{}:/usr/bin",
        stubs.display(),
        repo.join("bin").display()
      )
      .into(),
    ),
  ]
}

pub fn run(env: &[(&str, OsString)], name: &str, args: &[&str]) -> String {
  let result = Command::new("/usr/bin/timeout")
    .arg("15s")
    .arg(name)
    .args(args)
    .env_remove("DISPLAY")
    .envs(env.iter().cloned())
    .output()
    .unwrap();
  assert!(
    result.status.success(),
    "{name} ({}): {} {}",
    result.status,
    String::from_utf8_lossy(&result.stderr),
    String::from_utf8_lossy(&result.stdout)
  );
  String::from_utf8(result.stdout).unwrap()
}
