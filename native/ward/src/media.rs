//! One selected player's object, not general session-bus access. The external
//! proxy is in the controller's resource-limited service and dies with it.
use crate::{
  grants::validate_media,
  supervisor::{self, Limits},
};
use std::{
  fs::{File, OpenOptions},
  io::{self, Read},
  os::{
    fd::AsRawFd,
    unix::{
      fs::{FileTypeExt, MetadataExt, OpenOptionsExt},
      net::UnixStream,
      process::CommandExt,
    },
  },
  path::Path,
  process::{Child, Command, Stdio},
  time::{Duration, Instant},
};

pub struct MediaProxy {
  child: Child,
  _lease: UnixStream,
  socket: File,
  name: String,
}

impl MediaProxy {
  /// `address` is trusted host session configuration, never a manifest field.
  /// `name` must be the selected name from the controller's admitted grant.
  pub fn start(address: &str, directory: &Path, name: &str, limits: Limits) -> io::Result<Self> {
    supervisor::verify_controller_limits(limits)?;
    let arguments = policy(address, name)?;
    let metadata = directory.symlink_metadata()?;
    if !directory.is_absolute()
      || !metadata.is_dir()
      || metadata.mode() & 0o077 != 0
      || metadata.uid() != unsafe { libc::geteuid() }
    {
      return Err(io::Error::other(
        "media proxy requires an owned private directory",
      ));
    }
    let path = directory.join("media");
    match path.symlink_metadata() {
      Err(error) if error.kind() == io::ErrorKind::NotFound => (),
      _ => return Err(io::Error::other("media proxy path already exists")),
    }
    let (mut lease, child_lease) = UnixStream::pair()?;
    lease.set_nonblocking(true)?;
    let fd = child_lease.as_raw_fd();
    let mut command = Command::new("/usr/bin/xdg-dbus-proxy");
    command
      .env_clear()
      .arg(format!("--fd={fd}"))
      .arg(address)
      .arg(&path)
      .args(arguments)
      .stdin(Stdio::null())
      .stdout(Stdio::null())
      .stderr(Stdio::null());
    unsafe {
      command.pre_exec(move || {
        if libc::fcntl(fd, libc::F_SETFD, 0) < 0 {
          return Err(io::Error::last_os_error());
        }
        Ok(())
      });
    }
    let mut child = command.spawn()?;
    drop(child_lease);
    let ready = (|| {
      let deadline = Instant::now() + Duration::from_secs(1);
      let mut byte = [0];
      loop {
        match lease.read(&mut byte) {
          Ok(1) if byte == [b'x'] => break,
          Err(error) if error.kind() == io::ErrorKind::WouldBlock && Instant::now() < deadline => {
            if child.try_wait()?.is_some() {
              return Err(io::Error::other("media proxy exited during startup"));
            }
            std::thread::sleep(Duration::from_millis(5));
          }
          _ => return Err(io::Error::other("media proxy readiness failed")),
        }
      }
      let socket = OpenOptions::new()
        .read(true)
        .custom_flags(libc::O_PATH | libc::O_NOFOLLOW)
        .open(&path)?;
      if !socket.metadata()?.file_type().is_socket() {
        return Err(io::Error::other("media proxy endpoint is not a socket"));
      }
      Ok(socket)
    })();
    match ready {
      Ok(socket) => Ok(Self {
        child,
        _lease: lease,
        socket,
        name: name.into(),
      }),
      Err(error) => {
        let _ = child.kill();
        let _ = child.try_wait();
        Err(error)
      }
    }
  }

  pub(crate) fn socket(&self, name: &str) -> io::Result<&File> {
    if name != self.name {
      return Err(io::Error::other("media endpoint does not match the grant"));
    }
    Ok(&self.socket)
  }

  pub fn check(&mut self) -> io::Result<()> {
    if self.child.try_wait()?.is_some() {
      Err(io::Error::other("media proxy exited"))
    } else {
      Ok(())
    }
  }
}
impl Drop for MediaProxy {
  fn drop(&mut self) {
    let _ = self.child.kill();
    let _ = self.child.try_wait();
  }
}

fn policy(address: &str, name: &str) -> io::Result<Vec<String>> {
  validate_media(name)?;
  if address.len() > 4096
    || !address.starts_with("unix:path=/")
    || address.contains(';')
    || address.chars().any(char::is_control)
  {
    return Err(io::Error::other(
      "media proxy requires a pathname Unix bus address",
    ));
  }
  let mut args = vec!["--filter".into(), format!("--see={name}")];
  for method in [
    "org.freedesktop.DBus.Properties.Get",
    "org.freedesktop.DBus.Properties.GetAll",
    "org.freedesktop.DBus.Introspectable.Introspect",
    "org.mpris.MediaPlayer2.Player.Next",
    "org.mpris.MediaPlayer2.Player.Previous",
    "org.mpris.MediaPlayer2.Player.Pause",
    "org.mpris.MediaPlayer2.Player.PlayPause",
    "org.mpris.MediaPlayer2.Player.Stop",
    "org.mpris.MediaPlayer2.Player.Play",
    "org.mpris.MediaPlayer2.Player.Seek",
    "org.mpris.MediaPlayer2.Player.SetPosition",
  ] {
    args.push(format!("--call={name}={method}@/org/mpris/MediaPlayer2"));
  }
  for signal in [
    "org.freedesktop.DBus.Properties.PropertiesChanged",
    "org.mpris.MediaPlayer2.Player.Seeked",
  ] {
    args.push(format!(
      "--broadcast={name}={signal}@/org/mpris/MediaPlayer2"
    ));
  }
  Ok(args)
}

#[cfg(test)]
mod tests {
  use super::*;
  #[test]
  fn media_policy_has_no_wildcards_ownership_or_unrestricted_calls() {
    let policy = policy("unix:path=/run/test/bus", "org.mpris.MediaPlayer2.Test").unwrap();
    assert_eq!(policy[0], "--filter");
    assert!(
      policy
        .iter()
        .all(|arg| !arg.contains('*') && !arg.starts_with("--talk=") && !arg.starts_with("--own="))
    );
    for denied in ["OpenUri", "Raise", "Quit", "Properties.Set"] {
      assert!(!policy.iter().any(|arg| arg.contains(denied)));
    }
    for name in [
      "org.mpris.MediaPlayer2.*",
      "org.mpris.MediaPlayer2.Test=anything",
      "org.freedesktop.Notifications",
    ] {
      assert!(super::policy("unix:path=/run/test/bus", name).is_err());
    }
    for address in [
      "--filter",
      "tcp:host=example",
      "unix:path=/a;unix:path=/b",
      "unix:abstract=bus",
    ] {
      assert!(super::policy(address, "org.mpris.MediaPlayer2.Test").is_err());
    }
  }
}
