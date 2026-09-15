//! Trusted host-selected worker code, separate from the reviewed plugin bundle.
//! The directory descriptor travels only over the authenticated host channel.
use crate::channel::Channel;
#[cfg(any(feature = "graphics", test))]
use crate::channel::Packet;
use std::{
  fs::{File, OpenOptions},
  io::{self, Read},
  os::{
    fd::AsFd,
    unix::fs::{OpenOptionsExt, PermissionsExt},
  },
  path::Path,
};

const RECORD: &[u8] = b"OPH\x01\x16\0\0\0\0\0\0\0\0\0\0\0";

pub struct Runtime {
  pub(crate) directory: File,
  #[cfg(any(feature = "graphics", test))]
  pub(crate) entry: String,
}

#[derive(serde::Deserialize)]
#[serde(rename_all = "camelCase", deny_unknown_fields)]
struct Manifest {
  version: u32,
  entry_point: String,
}

impl Runtime {
  pub fn open(path: &Path) -> io::Result<Self> {
    if !path.is_absolute() {
      return Err(invalid("worker runtime path must be absolute"));
    }
    OpenOptions::new()
      .read(true)
      .custom_flags(libc::O_DIRECTORY | libc::O_NOFOLLOW)
      .open(path)
      .and_then(Self::from_directory)
      .map_err(|error| {
        io::Error::new(
          error.kind(),
          format!("worker runtime {}: {error}", path.display()),
        )
      })
  }

  fn from_directory(directory: File) -> io::Result<Self> {
    if !directory.metadata()?.is_dir() {
      return Err(invalid("worker runtime must be a directory"));
    }
    let mut bytes = Vec::new();
    open_file(&directory, "runtime.json")?
      .take(4097)
      .read_to_end(&mut bytes)?;
    if bytes.len() > 4096 {
      return Err(invalid("worker runtime manifest exceeds limit"));
    }
    let manifest: Manifest = serde_json::from_slice(&bytes)?;
    if manifest.version != 1 || !valid_entry(&manifest.entry_point) {
      return Err(invalid("unsupported worker runtime version or entry point"));
    }
    let metadata = open_file(&directory, &manifest.entry_point)?.metadata()?;
    if metadata.permissions().mode() & 0o111 == 0 {
      return Err(invalid("worker runtime entry point must be executable"));
    }
    Ok(Self {
      directory,
      #[cfg(any(feature = "graphics", test))]
      entry: manifest.entry_point,
    })
  }

  pub(crate) fn send(&self, channel: &Channel) -> io::Result<()> {
    channel.send(RECORD, &[self.directory.as_fd()])
  }

  #[cfg(any(feature = "graphics", test))]
  pub(crate) fn is_record(packet: &Packet) -> bool {
    packet.bytes.get(..8) == Some(&RECORD[..8])
  }

  #[cfg(any(feature = "graphics", test))]
  pub(crate) fn receive(mut packet: Packet) -> io::Result<Self> {
    if packet.bytes != RECORD || packet.fds.len() != 1 {
      return Err(invalid("invalid worker runtime record"));
    }
    Self::from_directory(File::from(packet.fds.pop().unwrap()))
  }
}

// A deliberately small entry contract: one executable at the runtime root.
// No interpreter, arguments, environment or host path comes from plugin code.
pub fn valid_entry(entry: &str) -> bool {
  !entry.is_empty()
    && entry.len() <= 128
    && entry != "."
    && entry != ".."
    && entry
      .bytes()
      .all(|c| c.is_ascii_alphanumeric() || b"._-".contains(&c))
}

fn open_file(directory: &File, name: &str) -> io::Result<File> {
  use rustix::fs::{Mode, OFlags, openat};
  let file = File::from(openat(
    directory,
    name,
    OFlags::RDONLY | OFlags::CLOEXEC | OFlags::NOFOLLOW | OFlags::NONBLOCK,
    Mode::empty(),
  )?);
  if !file.metadata()?.is_file() {
    return Err(invalid("worker runtime asset must be a regular file"));
  }
  Ok(file)
}

fn invalid(message: &str) -> io::Error {
  io::Error::new(io::ErrorKind::InvalidData, message)
}

#[cfg(test)]
mod tests {
  use super::*;
  fn fixture() -> tempfile::TempDir {
    let root = tempfile::tempdir().unwrap();
    std::fs::write(
      root.path().join("runtime.json"),
      r#"{"version":1,"entryPoint":"worker"}"#,
    )
    .unwrap();
    std::fs::write(root.path().join("worker"), "#!/bin/bash\nexit 0\n").unwrap();
    std::fs::set_permissions(
      root.path().join("worker"),
      std::fs::Permissions::from_mode(0o755),
    )
    .unwrap();
    root
  }
  #[test]
  fn runtime_descriptor_round_trip_and_directory_identity() {
    let root = fixture();
    let runtime = Runtime::open(root.path()).unwrap();
    let (host, controller) = Channel::pair().unwrap();
    runtime.send(&host).unwrap();
    let packet = controller.receive().unwrap();
    assert!(Runtime::is_record(&packet));
    let received = Runtime::receive(packet).unwrap();
    assert_eq!(received.entry, "worker");
    // The directory descriptor, not a fresh lookup of its original name, wins.
    let holder = tempfile::tempdir().unwrap();
    std::fs::rename(root.path(), holder.path().join("selected")).unwrap();
    std::fs::create_dir(root.path()).unwrap();
    std::fs::write(root.path().join("runtime.json"), "{}").unwrap();
    assert!(Runtime::open(root.path()).is_err());
    assert!(Runtime::from_directory(received.directory).is_ok());
  }
  #[test]
  fn invalid_layouts_and_records_fail_closed() {
    let root = fixture();
    for json in [
      r#"{"version":2,"entryPoint":"worker"}"#,
      r#"{"version":1,"entryPoint":"../worker"}"#,
      r#"{"version":1,"entryPoint":"/usr/bin/bash"}"#,
      r#"{"version":1,"entryPoint":"worker","env":{}}"#,
      r#"{"version":1,"entryPoint":"missing"}"#,
      "{}",
      "not json",
    ] {
      std::fs::write(root.path().join("runtime.json"), json).unwrap();
      assert!(Runtime::open(root.path()).is_err(), "{json}");
    }
    let root = fixture();
    std::fs::set_permissions(
      root.path().join("worker"),
      std::fs::Permissions::from_mode(0o644),
    )
    .unwrap();
    assert!(Runtime::open(root.path()).is_err());
    std::fs::remove_file(root.path().join("worker")).unwrap();
    std::os::unix::fs::symlink("/usr/bin/true", root.path().join("worker")).unwrap();
    assert!(Runtime::open(root.path()).is_err());
    assert!(Runtime::open(Path::new("relative")).is_err());
    let root = fixture();
    std::fs::write(root.path().join("runtime.json"), vec![b' '; 4097]).unwrap();
    assert!(Runtime::open(root.path()).is_err());
    std::fs::remove_file(root.path().join("runtime.json")).unwrap();
    std::os::unix::fs::symlink("worker", root.path().join("runtime.json")).unwrap();
    assert!(Runtime::open(root.path()).is_err());
    for count in [0, 2] {
      let fds = (0..count)
        .map(|_| File::open(root.path()).unwrap().into())
        .collect();
      assert!(
        Runtime::receive(Packet {
          bytes: RECORD.to_vec(),
          fds
        })
        .is_err()
      );
    }
    let mut bytes = RECORD.to_vec();
    bytes[15] = 1;
    assert!(
      Runtime::receive(Packet {
        bytes,
        fds: vec![File::open(root.path()).unwrap().into()]
      })
      .is_err()
    );
    assert!(
      Runtime::receive(Packet {
        bytes: RECORD.to_vec(),
        fds: vec![File::open("/dev/null").unwrap().into()]
      })
      .is_err()
    );
    let root = fixture();
    let runtime = Runtime::open(root.path()).unwrap();
    let (host, controller) = Channel::pair().unwrap();
    runtime.send(&host).unwrap();
    // Runtime selection is not an ordinary control reply/queued command.
    assert!(crate::controller::Control::decode(controller.receive().unwrap()).is_err());
  }
}
