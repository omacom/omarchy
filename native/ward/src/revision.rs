//! Content-addressed copies, not live source-directory grants. Approval refers
//! to the returned digest; later source edits do not modify that revision.
use rustix::fs::{Mode, OFlags};
use sha2::{Digest, Sha256};
use std::{
  fs::{self, File, OpenOptions},
  io::{self, Read, Write},
  os::{
    fd::AsRawFd,
    unix::{
      ffi::OsStrExt,
      fs::{DirBuilderExt, MetadataExt, OpenOptionsExt, PermissionsExt},
    },
  },
  path::{Path, PathBuf},
};

const MAX_BYTES: u64 = 64 * 1024 * 1024;
const MAX_ENTRIES: usize = 4096;

pub struct Revision {
  pub digest: String,
  pub path: PathBuf,
}

impl Revision {
  /// `snapshots` must be inside controller-owned private state. Symlinks,
  /// hardlinked files, special files, and over-budget bundles are rejected.
  /// Git administrative data is omitted; plugin code cannot access it either.
  pub fn import(source: &Path, snapshots: &Path) -> io::Result<Self> {
    require_private_directory(snapshots)?;
    let source = path_file(source)?;
    if !source.metadata()?.is_dir() {
      return Err(invalid("plugin source must be a directory"));
    }
    let temporary = tempfile::Builder::new()
      .prefix(".revision-")
      .permissions(fs::Permissions::from_mode(0o700))
      .tempdir_in(snapshots)?;
    let mut tree = Tree::new();
    tree.walk(&source, Path::new(""), Some(temporary.path()), 0)?;
    let digest = tree.digest();
    let path = snapshots.join(&digest);
    match rustix::fs::renameat_with(
      rustix::fs::CWD,
      temporary.path(),
      rustix::fs::CWD,
      &path,
      rustix::fs::RenameFlags::NOREPLACE,
    ) {
      Ok(()) => File::open(snapshots)?.sync_all()?,
      Err(rustix::io::Errno::EXIST) => Self::verify(snapshots, &digest)?,
      Err(error) => return Err(error.into()),
    }
    Ok(Self { digest, path })
  }

  pub fn verify(snapshots: &Path, digest: &str) -> io::Result<()> {
    require_private_directory(snapshots)?;
    if digest.len() != 64
      || !digest
        .bytes()
        .all(|byte| byte.is_ascii_digit() || (b'a'..=b'f').contains(&byte))
    {
      return Err(invalid("invalid revision digest"));
    }
    let root = path_file(&snapshots.join(digest))?;
    let mut tree = Tree::new();
    tree.walk(&root, Path::new(""), None, 0)?;
    if tree.digest() != digest {
      return Err(invalid("approved revision was modified"));
    }
    Ok(())
  }
}

struct Tree {
  hash: Sha256,
  bytes: u64,
  entries: usize,
}
impl Tree {
  fn new() -> Self {
    let mut hash = Sha256::new();
    hash.update(b"omarchy-plugin-revision-v1\0");
    Self {
      hash,
      bytes: 0,
      entries: 0,
    }
  }
  fn digest(self) -> String {
    format!("{:x}", self.hash.finalize())
  }

  fn walk(
    &mut self,
    source: &File,
    relative: &Path,
    destination: Option<&Path>,
    depth: usize,
  ) -> io::Result<()> {
    self.entries += 1;
    if self.entries > MAX_ENTRIES || depth > 16 || relative.as_os_str().len() > 4096 {
      return Err(invalid("plugin tree exceeds limits"));
    }
    let metadata = source.metadata()?;
    let fd_path = PathBuf::from(format!("/proc/self/fd/{}", source.as_raw_fd()));
    let path_bytes = relative.as_os_str().as_bytes();
    self.hash.update((path_bytes.len() as u32).to_le_bytes());
    self.hash.update(path_bytes);
    if metadata.is_dir() {
      self.hash.update(b"d");
      let mut entries = fs::read_dir(&fd_path)?
        .take(MAX_ENTRIES - self.entries + 1)
        .map(|entry| entry.map(|entry| entry.file_name()))
        .collect::<io::Result<Vec<_>>>()?;
      // Bound before sorting, not merely while visiting descendants.
      if entries.len() > MAX_ENTRIES - self.entries {
        return Err(invalid("too many plugin entries"));
      }
      entries.sort();
      for name in entries {
        if depth == 0 && name == ".git" {
          continue;
        }
        let child = File::from(rustix::fs::openat(
          source,
          &name,
          OFlags::PATH | OFlags::CLOEXEC | OFlags::NOFOLLOW,
          Mode::empty(),
        )?);
        let child_destination = destination.map(|path| path.join(&name));
        if child.metadata()?.is_dir()
          && let Some(path) = &child_destination
        {
          fs::DirBuilder::new().mode(0o700).create(path)?;
        }
        self.walk(
          &child,
          &relative.join(name),
          child_destination.as_deref(),
          depth + 1,
        )?;
      }
      if let Some(destination) = destination {
        File::open(destination)?.sync_all()?;
      }
    } else if metadata.is_file() && metadata.nlink() == 1 {
      self.hash.update(b"f");
      let executable = metadata.mode() & 0o111 != 0;
      self.hash.update([u8::from(executable)]);
      self.hash.update(metadata.len().to_le_bytes());
      if metadata.len() > MAX_BYTES - self.bytes {
        return Err(invalid("plugin files exceed size limit"));
      }
      let mut input = File::open(fd_path)?;
      let mut output = destination
        .map(|path| {
          OpenOptions::new()
            .write(true)
            .create_new(true)
            .mode(0o600)
            .open(path)
        })
        .transpose()?;
      let mut copied = 0;
      let mut buffer = [0u8; 64 * 1024];
      loop {
        let count = input.read(&mut buffer)?;
        if count == 0 {
          break;
        }
        copied += count as u64;
        self.bytes += count as u64;
        if copied > metadata.len() || self.bytes > MAX_BYTES {
          return Err(invalid("plugin changed during snapshot"));
        }
        self.hash.update(&buffer[..count]);
        if let Some(output) = &mut output {
          output.write_all(&buffer[..count])?;
        }
      }
      if copied != metadata.len() {
        return Err(invalid("plugin changed during snapshot"));
      }
      if let Some(output) = output {
        output.set_permissions(fs::Permissions::from_mode(if executable {
          0o755
        } else {
          0o644
        }))?;
        output.sync_all()?;
      }
    } else {
      return Err(invalid(
        "plugin bundles cannot contain links or special files",
      ));
    }
    Ok(())
  }
}

fn path_file(path: &Path) -> io::Result<File> {
  OpenOptions::new()
    .read(true)
    .custom_flags(libc::O_PATH | libc::O_NOFOLLOW)
    .open(path)
}
pub(crate) fn require_private_directory(path: &Path) -> io::Result<()> {
  let metadata = path.symlink_metadata()?;
  if !path.is_absolute()
    || !metadata.is_dir()
    || metadata.mode() & 0o077 != 0
    || metadata.uid() != unsafe { libc::geteuid() }
  {
    return Err(invalid("plugin state requires an owned private directory"));
  }
  Ok(())
}
fn invalid(message: &str) -> io::Error {
  io::Error::new(io::ErrorKind::InvalidData, message)
}

#[cfg(test)]
mod tests {
  use super::*;
  use std::os::unix::fs::symlink;
  fn private_tempdir() -> tempfile::TempDir {
    tempfile::Builder::new()
      .permissions(fs::Permissions::from_mode(0o700))
      .tempdir()
      .unwrap()
  }
  #[test]
  fn snapshots_bind_exact_bytes_and_executable_modes() {
    let source = tempfile::tempdir().unwrap();
    let store = private_tempdir();
    fs::write(source.path().join("shell.qml"), "first").unwrap();
    fs::create_dir(source.path().join(".git")).unwrap();
    fs::write(source.path().join(".git/config"), "not part of the bundle").unwrap();
    let first = Revision::import(source.path(), store.path()).unwrap();
    Revision::verify(store.path(), &first.digest).unwrap();
    assert!(!first.path.join(".git").exists());
    assert_eq!(
      Revision::import(source.path(), store.path())
        .unwrap()
        .digest,
      first.digest
    );
    fs::write(source.path().join("shell.qml"), "second").unwrap();
    let second = Revision::import(source.path(), store.path()).unwrap();
    assert_ne!(second.digest, first.digest);
    assert_eq!(
      fs::read_to_string(first.path.join("shell.qml")).unwrap(),
      "first"
    );
    fs::set_permissions(
      source.path().join("shell.qml"),
      fs::Permissions::from_mode(0o755),
    )
    .unwrap();
    assert_ne!(
      Revision::import(source.path(), store.path())
        .unwrap()
        .digest,
      second.digest
    );
    fs::write(first.path.join("shell.qml"), "modified").unwrap();
    assert!(Revision::verify(store.path(), &first.digest).is_err());
    assert!(Revision::verify(store.path(), "../escape").is_err());
  }

  #[test]
  fn rejects_symlinks_hardlinks_and_large_files() {
    let source = tempfile::tempdir().unwrap();
    let store = private_tempdir();
    let outside = tempfile::NamedTempFile::new().unwrap();
    symlink(outside.path(), source.path().join("link")).unwrap();
    assert!(Revision::import(source.path(), store.path()).is_err());
    fs::remove_file(source.path().join("link")).unwrap();
    fs::hard_link(outside.path(), source.path().join("hardlink")).unwrap();
    assert!(Revision::import(source.path(), store.path()).is_err());
    fs::remove_file(source.path().join("hardlink")).unwrap();
    File::create(source.path().join("large"))
      .unwrap()
      .set_len(MAX_BYTES + 1)
      .unwrap();
    assert!(Revision::import(source.path(), store.path()).is_err());
    assert_eq!(
      fs::read_dir(store.path()).unwrap().count(),
      0,
      "failed imports must not publish snapshots"
    );
  }
}
