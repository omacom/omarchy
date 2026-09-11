//! Host authority paths cannot become ordinary worker filesystem grants.
//! These are trusted host settings, never fields accepted from a manifest.
use crate::grants::{FileSystemGrant, invalid};
use std::{
  fs, io,
  os::unix::fs::MetadataExt,
  path::{Path, PathBuf},
};

pub(crate) struct ProtectedPaths {
  private: Vec<PathBuf>,
  executable: Vec<PathBuf>,
}

impl ProtectedPaths {
  pub(crate) fn for_store(store: &Path) -> io::Result<Self> {
    let mut policy = Self {
      private: vec![
        store.into(),
        store.join("secrets/signing.key"),
        store.join("secrets/signing.pub"),
      ],
      executable: vec![std::env::current_exe()?],
    };
    for key in [&policy.private[1], &policy.private[2]] {
      let metadata = fs::symlink_metadata(key)?;
      if !metadata.is_file() || metadata.nlink() != 1 {
        return Err(invalid("authority key must be a single-link regular file"));
      }
    }
    if let Some(home) = std::env::var_os("HOME").map(PathBuf::from) {
      policy.executable.extend([
        home.join(".config"),
        home.join(".local"),
        home.join(".bashrc"),
        home.join(".bash_profile"),
        home.join(".profile"),
        home.join(".zshrc"),
      ]);
      policy.private.push(home.join(".ssh"));
      policy.private.push(home.join(".gnupg"));
    }
    for variable in [
      "XDG_CONFIG_HOME",
      "XDG_DATA_HOME",
      "XDG_STATE_HOME",
      "XDG_CACHE_HOME",
      "OMARCHY_PATH",
      "OMARCHY_WARD_HOST",
      "OMARCHY_WARD_RUNTIME",
    ] {
      if let Some(path) = std::env::var_os(variable).filter(|value| !value.is_empty()) {
        policy.executable.push(path.into());
      }
    }
    policy.private.push(
      std::env::var_os("XDG_RUNTIME_DIR")
        .filter(|value| !value.is_empty())
        .map(PathBuf::from)
        .unwrap_or_else(|| PathBuf::from(format!("/run/user/{}", unsafe { libc::geteuid() }))),
    );
    for path in policy
      .private
      .iter_mut()
      .chain(policy.executable.iter_mut())
    {
      *path = canonical_allow_missing(path)?;
    }
    Ok(policy)
  }

  pub(crate) fn check(&self, grant: &FileSystemGrant) -> io::Result<()> {
    let selected = grant.path.canonicalize()?;
    for protected in self
      .private
      .iter()
      .chain(self.executable.iter().filter(|_| grant.access.writable()))
    {
      if overlaps(&selected, protected)? {
        return Err(invalid(
          "filesystem grant overlaps host authority; select a separate data directory",
        ));
      }
    }
    Ok(())
  }
}

// Include roots that have not been created yet, resolving existing ancestor
// symlinks. Recompute at admission so later host configuration cannot widen a
// previously approved grant. Unexpected filesystem errors fail closed.
fn canonical_allow_missing(path: &Path) -> io::Result<PathBuf> {
  if !path.is_absolute() {
    return Err(invalid("host authority path must be absolute"));
  }
  match path.canonicalize() {
    Ok(path) => Ok(path),
    Err(error) if error.kind() == io::ErrorKind::NotFound => {
      let parent = path
        .parent()
        .ok_or_else(|| invalid("invalid authority path"))?;
      let name = path
        .file_name()
        .ok_or_else(|| invalid("invalid authority path"))?;
      Ok(canonical_allow_missing(parent)?.join(name))
    }
    Err(error) => Err(error),
  }
}

fn overlaps(selected: &Path, protected: &Path) -> io::Result<bool> {
  if selected.starts_with(protected) || protected.starts_with(selected) {
    return Ok(true);
  }
  // Exact inode comparisons also catch hardlinked files and bind aliases of
  // the selected/protected root or an ancestor, not just symlink spellings.
  for (target, tree) in [(selected, protected), (protected, selected)] {
    let target = match fs::metadata(target) {
      Ok(metadata) => metadata,
      Err(error) if error.kind() == io::ErrorKind::NotFound => continue,
      Err(error) => return Err(error),
    };
    for ancestor in tree.ancestors() {
      match fs::metadata(ancestor) {
        Ok(metadata) if metadata.dev() == target.dev() && metadata.ino() == target.ino() => {
          return Ok(true);
        }
        Ok(_) => (),
        Err(error) if error.kind() == io::ErrorKind::NotFound => (),
        Err(error) => return Err(error),
      }
    }
  }
  Ok(false)
}
