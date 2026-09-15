use std::os::unix::fs::PermissionsExt;
use std::{
  ffi::OsStr,
  fs,
  path::Path,
  process::{Child, Command, Output, Stdio},
  time::{Duration, Instant},
};

pub const SELECTED: &str = "org.mpris.MediaPlayer2.Selected";
pub const OTHER: &str = "org.mpris.MediaPlayer2.Other";
pub const ALIAS: &str = "org.example.Unrelated";
pub const OBJECT: &str = "/org/mpris/MediaPlayer2";

pub struct Process(pub Child);
impl Drop for Process {
  fn drop(&mut self) {
    let _ = self.0.kill();
    let _ = self.0.wait();
  }
}

pub struct Bus {
  pub address: String,
  pub selected_owner: String,
  pub other_owner: String,
  _players: Vec<Process>,
  _daemon: Process,
  _runtime: tempfile::TempDir,
}
impl Bus {
  pub fn new(player: &OsStr) -> Self {
    let runtime = tempfile::Builder::new()
      .permissions(fs::Permissions::from_mode(0o700))
      .tempdir()
      .unwrap();
    let path = runtime.path().join("bus");
    let config = runtime.path().join("bus.conf");
    // No service directories: this private test bus cannot activate host apps.
    fs::write(&config, format!(r#"<busconfig><type>session</type><listen>unix:path={}</listen><auth>EXTERNAL</auth>
      <policy context="default"><allow user="*"/><allow own="*"/><allow send_destination="*"/><allow receive_sender="*"/></policy>
      <limit name="max_connections_per_user">64</limit></busconfig>"#, path.display())).unwrap();
    let daemon = Process(
      Command::new("/usr/bin/dbus-daemon")
        .env_clear()
        .arg("--nofork")
        .arg("--config-file")
        .arg(&config)
        .stdin(Stdio::null())
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .spawn()
        .unwrap(),
    );
    let deadline = Instant::now() + Duration::from_secs(2);
    while !path.exists() {
      assert!(Instant::now() < deadline, "private bus did not start");
      std::thread::sleep(Duration::from_millis(5));
    }
    let address = format!("unix:path={}", path.display());
    let players = [vec![SELECTED, ALIAS], vec![OTHER]]
      .into_iter()
      .map(|names| {
        Process(
          Command::new(player)
            .env_clear()
            .env("DBUS_SESSION_BUS_ADDRESS", &address)
            .args(names)
            .stdin(Stdio::null())
            .stdout(Stdio::null())
            .stderr(Stdio::null())
            .spawn()
            .unwrap(),
        )
      })
      .collect();
    let selected_owner = owner(&address, SELECTED);
    let other_owner = owner(&address, OTHER);
    Self {
      address,
      selected_owner,
      other_owner,
      _players: players,
      _daemon: daemon,
      _runtime: runtime,
    }
  }
}

pub fn call(
  address: &str,
  name: &str,
  path: &str,
  interface: &str,
  member: &str,
  args: &[&str],
) -> Output {
  Command::new("/usr/bin/timeout")
    .env_clear()
    .args([
      "--signal=KILL",
      "2s",
      "/usr/bin/busctl",
      "--timeout=1",
      "--auto-start=no",
      "--allow-interactive-authorization=no",
    ])
    .arg(format!("--address={address}"))
    .args(["call", name, path, interface, member])
    .args(args)
    .output()
    .unwrap()
}

fn owner(address: &str, name: &str) -> String {
  let deadline = Instant::now() + Duration::from_secs(2);
  loop {
    let output = call(
      address,
      "org.freedesktop.DBus",
      "/org/freedesktop/DBus",
      "org.freedesktop.DBus",
      "GetNameOwner",
      &["s", name],
    );
    if output.status.success() {
      return String::from_utf8(output.stdout)
        .unwrap()
        .trim()
        .strip_prefix("s \"")
        .unwrap()
        .strip_suffix('"')
        .unwrap()
        .into();
    }
    assert!(
      Instant::now() < deadline,
      "private player did not register: {}",
      String::from_utf8_lossy(&output.stderr)
    );
    std::thread::sleep(Duration::from_millis(5));
  }
}

pub fn path_fd(path: &Path) -> fs::File {
  use std::os::unix::fs::OpenOptionsExt;
  fs::OpenOptions::new()
    .read(true)
    .custom_flags(libc::O_PATH | libc::O_NOFOLLOW)
    .open(path)
    .unwrap()
}
