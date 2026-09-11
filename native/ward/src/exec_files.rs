//! DATA arguments are read-only file inputs, never mutable host pathnames.
use crate::{
  exec_policy::{PLUGIN_DATA, PluginDir, resolve_plugin_path},
  grants::invalid,
  host_job::PREPARATION_TIMEOUT,
  payload,
};
use std::{
  fs::{File, OpenOptions},
  io::{self, Read, Seek, Write},
  os::{
    fd::AsRawFd,
    unix::fs::{MetadataExt, OpenOptionsExt},
  },
  time::Instant,
};

const MAX_DATA: usize = 64 * 1024 * 1024;

pub(crate) struct Arguments {
  original: Vec<String>,
  paths: Vec<PluginDir>,
  pub(crate) argv: Vec<String>,
  pub(crate) files: Vec<File>,
}

impl Arguments {
  // Runs on the existing bounded preparation thread, outside authority locks.
  pub(crate) fn prepare(
    argv: &[String],
    paths: &[PluginDir],
    started: Instant,
  ) -> io::Result<Self> {
    let mut result = Self {
      original: argv.to_vec(),
      paths: paths.to_vec(),
      argv: Vec::new(),
      files: Vec::new(),
    };
    let mut total = 0usize;
    for arg in argv {
      let resolved = resolve_plugin_path(arg, paths)?;
      let data = paths.iter().find(|dir| {
        dir.token == PLUGIN_DATA
          && (resolved == dir.value || resolved.starts_with(&format!("{}/", dir.value)))
      });
      if let Some(data) = data {
        let relative = resolved
          .strip_prefix(&format!("{}/", data.value))
          .filter(|value| !value.is_empty())
          .ok_or_else(|| invalid("DATA exec arguments require a regular input file"))?;
        let root = OpenOptions::new()
          .read(true)
          .custom_flags(libc::O_DIRECTORY | libc::O_NOFOLLOW)
          .open(&data.value)?;
        let mut source = File::from(rustix::fs::openat2(
          &root,
          relative,
          rustix::fs::OFlags::RDONLY | rustix::fs::OFlags::CLOEXEC | rustix::fs::OFlags::NONBLOCK,
          rustix::fs::Mode::empty(),
          rustix::fs::ResolveFlags::BENEATH
            | rustix::fs::ResolveFlags::NO_SYMLINKS
            | rustix::fs::ResolveFlags::NO_MAGICLINKS
            | rustix::fs::ResolveFlags::NO_XDEV,
        )?);
        let metadata = source.metadata()?;
        if !metadata.is_file()
          || metadata.nlink() != 1
          || metadata.len() > (MAX_DATA - total) as u64
        {
          return Err(invalid(
            "DATA exec inputs must be bounded regular files without hardlinks",
          ));
        }
        let mut file = payload::create()?;
        let mut buffer = [0u8; 65536];
        loop {
          if started.elapsed() >= PREPARATION_TIMEOUT {
            return Err(invalid("DATA input preparation timed out"));
          }
          let count = source.read(&mut buffer)?;
          if count == 0 {
            break;
          }
          total = total
            .checked_add(count)
            .filter(|total| *total <= MAX_DATA)
            .ok_or_else(|| invalid("DATA exec inputs exceed the total limit"))?;
          file.write_all(&buffer[..count])?;
        }
        payload::finish(&file, MAX_DATA)?;
        file.rewind()?;
        result
          .argv
          .push(format!("/proc/self/fd/{}", file.as_raw_fd()));
        result.files.push(file);
      } else {
        result.argv.push(resolved);
      }
    }
    Ok(result)
  }

  pub(crate) fn check(&self, argv: &[String], paths: &[PluginDir]) -> io::Result<()> {
    if self.original != argv || self.paths != paths {
      return Err(invalid(
        "prepared file inputs differ from current invocation",
      ));
    }
    Ok(())
  }
}

#[cfg(test)]
mod tests {
  use super::*;
  use std::{fs, os::unix::fs::symlink};

  #[test]
  fn data_inputs_reject_symlinks_hardlinks_directories_and_special_files() {
    let root = tempfile::tempdir().unwrap();
    let data = root.path().join("data");
    fs::create_dir(&data).unwrap();
    fs::write(root.path().join("secret"), "host secret").unwrap();
    symlink("../secret", data.join("relative")).unwrap();
    symlink(root.path().join("secret"), data.join("absolute")).unwrap();
    symlink("/proc/self/environ", data.join("magic")).unwrap();
    fs::hard_link(root.path().join("secret"), data.join("hard")).unwrap();
    fs::create_dir(data.join("dir")).unwrap();
    rustix::fs::mknodat(
      rustix::fs::CWD,
      data.join("fifo"),
      rustix::fs::FileType::Fifo,
      rustix::fs::Mode::RUSR,
      0,
    )
    .unwrap();
    let paths = [PluginDir::data(data.to_str().unwrap().into())];
    for name in [
      "relative",
      "absolute",
      "magic",
      "hard",
      "dir",
      "fifo",
      "../secret",
      "",
    ] {
      for arg in [
        format!("$OMARCHY_PLUGIN_DATA/{name}"),
        format!("{}/{name}", data.display()),
      ] {
        assert!(
          Arguments::prepare(&[arg.clone()], &paths, Instant::now()).is_err(),
          "{arg}"
        );
      }
    }
  }

  #[test]
  fn data_inputs_are_sealed_and_do_not_reopen_replaced_paths() {
    let root = tempfile::tempdir().unwrap();
    let path = root.path().join("input");
    fs::write(&path, "selected input").unwrap();
    let paths = [PluginDir::data(root.path().to_str().unwrap().into())];
    let argv = vec!["$OMARCHY_PLUGIN_DATA/input".into()];
    let prepared = Arguments::prepare(&argv, &paths, Instant::now()).unwrap();
    prepared.check(&argv, &paths).unwrap();
    assert!(prepared.check(&["different".into()], &paths).is_err());
    fs::remove_file(&path).unwrap();
    symlink("/etc/passwd", &path).unwrap();
    assert_eq!(
      fs::read_to_string(&prepared.argv[0]).unwrap(),
      "selected input"
    );
    assert!(fs::write(&prepared.argv[0], "replacement").is_err());
  }
}
