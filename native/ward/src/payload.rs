//! Bounded immutable payloads carried by one descriptor, never socket queues.
use std::{
  fs::File,
  io::{self, Write},
  os::{fd::OwnedFd, unix::fs::FileExt},
};

const SEALS: rustix::fs::SealFlags = rustix::fs::SealFlags::SEAL
  .union(rustix::fs::SealFlags::SHRINK)
  .union(rustix::fs::SealFlags::GROW)
  .union(rustix::fs::SealFlags::WRITE);

pub(crate) fn create() -> io::Result<File> {
  Ok(File::from(rustix::fs::memfd_create(
    "plugin-payload",
    rustix::fs::MemfdFlags::CLOEXEC | rustix::fs::MemfdFlags::ALLOW_SEALING,
  )?))
}

pub(crate) fn finish(file: &File, limit: usize) -> io::Result<()> {
  if file.metadata()?.len() > limit as u64 {
    return Err(io::Error::other("plugin payload exceeds its limit"));
  }
  rustix::fs::fcntl_add_seals(file, SEALS)?;
  Ok(())
}

pub(crate) fn seal(bytes: &[u8], limit: usize) -> io::Result<File> {
  if bytes.len() > limit {
    return Err(io::Error::other("plugin payload exceeds its limit"));
  }
  let mut file = create()?;
  file.write_all(bytes)?;
  finish(&file, limit)?;
  Ok(file)
}

pub(crate) fn read(fd: OwnedFd, limit: usize) -> io::Result<Vec<u8>> {
  let file = File::from(fd);
  let metadata = file.metadata()?;
  if !metadata.is_file()
    || metadata.len() > limit as u64
    || !rustix::fs::fcntl_get_seals(&file)?.contains(SEALS)
  {
    return Err(io::Error::other(
      "plugin payload requires a bounded sealed file",
    ));
  }
  let mut bytes = vec![0; metadata.len() as usize];
  file.read_exact_at(&mut bytes, 0)?;
  Ok(bytes)
}
