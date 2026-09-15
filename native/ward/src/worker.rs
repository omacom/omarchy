use crate::{
  grants::{Grants, MAX_GRANTED_DIRS, invalid, validate_id},
  media::MediaProxy,
  sandbox, supervisor,
};
use std::{
  ffi::OsStr,
  fs::{File, OpenOptions},
  io,
  os::{
    fd::{AsFd, AsRawFd},
    unix::{
      fs::{FileTypeExt, OpenOptionsExt},
      process::CommandExt,
    },
  },
  path::{Path, PathBuf},
  process::{Child, Command, Stdio},
};

/// Persistent per-plugin storage under the user's XDG state home. The
/// The persistent per-identity data directory behind the storage mount is
/// created 0700 (owned by the controller) and opened for the worker mount; the
/// plugin id names the directory so state survives revision changes.
/// Returns the host path of that directory, exposed as `\$OMARCHY_PLUGIN_DATA`.
pub fn storage_directory_path(id: &str) -> io::Result<PathBuf> {
  validate_id(id)?;
  let state_home = std::env::var_os("XDG_STATE_HOME")
    .map(PathBuf::from)
    .map(Ok)
    .unwrap_or_else(|| {
      std::env::var_os("HOME")
        .map(|home| PathBuf::from(home).join(".local/state"))
        .ok_or_else(|| {
          io::Error::new(
            io::ErrorKind::NotFound,
            "no HOME available for plugin storage",
          )
        })
    })?;
  if !state_home.is_absolute() {
    return Err(invalid("plugin storage requires an absolute state home"));
  }
  Ok(state_home.join("omarchy").join("plugins").join(id))
}

/// Create (0755 parent dirs as needed) and open the persistent per-identity
/// storage directory, restricted to the owner. Contents survive launches, so
/// changes of the same plugin across restarts are preserved.
pub fn storage_directory(id: &str) -> io::Result<File> {
  use std::os::unix::fs::PermissionsExt;
  let root = storage_directory_path(id)?;
  std::fs::create_dir_all(&root)?;
  std::fs::set_permissions(&root, std::fs::Permissions::from_mode(0o700))?;
  File::open(&root)
}

/// Copy only the reviewed revision into this controller's private temporary
/// directory. Reuse the bounded snapshot copier rather than merging into a
/// persistent per-id path. The runtime owner removes the stage on teardown.
pub fn stage_plugin_assets(bundle: &Path, revision: &str, runtime: &Path) -> io::Result<PathBuf> {
  let staged = crate::revision::Revision::import(bundle, runtime)?;
  if staged.digest != revision {
    return Err(invalid("plugin assets changed since review"));
  }
  Ok(staged.path)
}

#[derive(Default)]
pub struct Resources<'a> {
  pub render_node: Option<&'a Path>,
  pub media: Option<&'a MediaProxy>,
  pub audio: Option<&'a crate::audio::Broker>,
  pub network_proxy: Option<&'a crate::network_proxy::Broker>,
  pub requests: Option<&'a crate::requests::Broker>,
  pub runtime: Option<&'a File>,
  pub context: Option<&'a File>,
  /// Read-only view of the *admitted* grants, written by the controller from
  /// its own record (never from plugin-provided metadata), exposed so plugin
  /// code can adapt to actually-granted access at runtime.
  pub grants_json: Option<&'a File>,
  /// Persistent per-plugin storage directory. When the storage grant is
  /// admitted this is bind-mounted read-write over `/home/plugin`, so plugin
  /// writes under `$HOME` (and the default `$HOME/.local/state`) survive
  /// restarts; otherwise `/home/plugin` remains an ephemeral tmpfs.
  pub storage: Option<&'a File>,
  /// Admitted plugin-path directories: each exposes its host-chosen value as
  /// an environment variable (so source can build host-real absolute paths) and
  /// as a `$...` token for the exec broker, resolved symmetrically. Only the
  /// directories actually admitted are present (assets when exec is granted,
  /// data when storage is granted).
  pub paths: Vec<crate::exec_policy::PluginDir>,
}

/// Launch only from a resource-limited trusted controller. All arguments and
/// descriptors are controller-owned, never supplied by a worker RPC. The bundle
/// must already be an approved immutable revision: pinning a directory prevents
/// pathname substitution, not modification of its contents.
///
/// Grants must come from the controller's current admitted record. Read-only
/// directory slots, optional network access, a selected media proxy, and a GPU
/// render node and text notifications are implemented; storage and sound are
/// served through the grant pipeline. Sandboxed plugins remain unable to reach
/// the desktop's PipeWire or Wayland session directly.
/// `bootstrap` must restrict itself before loading any code from the bundle.
/// The caller must drain stderr with a bounded log budget and supervise child
/// exit; dropping the returned Child is not a substitute for stopping the Unit.
pub fn spawn(
  bootstrap: &File,
  bundle: &File,
  display: &File,
  args: &[&OsStr],
  limits: supervisor::Limits,
  grants: &Grants,
  resources: Resources<'_>,
) -> io::Result<Child> {
  supervisor::verify_controller_limits(limits)?;
  if !bootstrap.metadata()?.is_file()
    || !bundle.metadata()?.is_dir()
    || !display.metadata()?.file_type().is_socket()
  {
    return Err(io::Error::new(
      io::ErrorKind::InvalidInput,
      "invalid worker mount descriptors",
    ));
  }
  if grants.filesystem.len() > MAX_GRANTED_DIRS {
    return Err(invalid(
      "directory grants exceed the enforced sandbox descriptor budget",
    ));
  }
  let media = match (&grants.media, resources.media) {
    (Some(name), Some(proxy)) => Some(proxy.socket(name)?),
    (None, None) => None,
    _ => return Err(io::Error::other("media grant and prepared proxy disagree")),
  };
  let audio = match (
    crate::audio::Mode::ALL
      .iter()
      .any(|mode| mode.granted(grants)),
    resources.audio,
  ) {
    (true, Some(broker)) => broker.sockets(grants)?,
    (false, None) => Vec::new(),
    _ => {
      return Err(io::Error::other(
        "audio grants and prepared endpoints disagree",
      ));
    }
  };
  let network_proxy = match (grants.network_proxy, resources.network_proxy) {
    (true, Some(proxy)) if !grants.network => Some(proxy.socket()),
    (false, None) => None,
    _ => {
      return Err(io::Error::other(
        "network proxy grant and endpoint disagree",
      ));
    }
  };
  // The storage grant is only satisfiable when the controller prepared an
  // owned private directory; a grant without the directory (or vice versa) is
  // a host/controller disagreement, never a silent downgrade to tmpfs.
  let storage = match (&grants.storage, resources.storage) {
    (true, Some(directory)) => {
      if !directory.metadata()?.is_dir() {
        return Err(io::Error::other(
          "storage grant requires a directory resource",
        ));
      }
      Some(directory)
    }
    (false, None) => None,
    _ => {
      return Err(io::Error::other(
        "storage grant and prepared directory disagree",
      ));
    }
  };
  let requests = match (
    resources.runtime.is_some()
      || grants.notifications
      || !grants.http.is_empty()
      || !grants.exec.is_empty()
      || grants.settings.can_write()
      || grants.open_urls,
    resources.requests,
  ) {
    (true, Some(broker)) => Some(broker.socket()),
    (false, None) => None,
    _ => {
      return Err(io::Error::other(
        "host request grants and prepared broker disagree",
      ));
    }
  };
  // Each granted host entry consumes one descriptor that must stay open for
  // bubblewrap to consume; the count is bounded by MAX_GRANTED_DIRS, which is
  // itself derived from the persisted-record budget (see grants.rs).
  let mut directories: Vec<(&String, File, bool)> = Vec::new();
  for (name, directory) in &grants.filesystem {
    validate_id(name)?;
    directories.push((name, directory.open()?, directory.access.writable()));
  }
  let mut command = Command::new("/usr/bin/bwrap");
  command.env_clear().args([
    "--unshare-all",
    "--unshare-user",
    "--unshare-cgroup",
    "--disable-userns",
    "--assert-userns-disabled",
    "--die-with-parent",
    "--new-session",
    "--cap-drop",
    "ALL",
    "--clearenv",
    "--ro-bind",
    "/usr",
    "/usr",
    "--symlink",
    "usr/lib",
    "/lib",
    "--symlink",
    "usr/lib",
    "/lib64",
    "--symlink",
    "usr/bin",
    "/bin",
    "--symlink",
    "usr/bin",
    "/sbin",
    "--proc",
    "/proc",
    "--dev",
    "/dev",
    "--size",
    "16777216",
    "--tmpfs",
    "/tmp",
    "--size",
    "8388608",
    "--tmpfs",
    "/run/plugin",
    "--ro-bind",
    "/etc/fonts",
    "/etc/fonts",
  ]);
  if grants.network {
    command.args([
      "--share-net",
      "--ro-bind",
      "/etc/resolv.conf",
      "/etc/resolv.conf",
      "--ro-bind",
      "/etc/hosts",
      "/etc/hosts",
      "--ro-bind",
      "/etc/ssl",
      "/etc/ssl",
      "--ro-bind",
      "/etc/ca-certificates",
      "/etc/ca-certificates",
    ]);
  }
  if grants.network_proxy {
    // Client TLS stays inside the worker; no DNS configuration or shared net.
    command.args([
      "--ro-bind",
      "/etc/ssl",
      "/etc/ssl",
      "--ro-bind",
      "/etc/ca-certificates",
      "/etc/ca-certificates",
    ]);
    for name in [
      "http_proxy",
      "https_proxy",
      "HTTP_PROXY",
      "HTTPS_PROXY",
      "ALL_PROXY",
      "all_proxy",
    ] {
      command.args(["--setenv", name, crate::network_proxy::URL]);
    }
    for name in ["no_proxy", "NO_PROXY"] {
      command.args(["--setenv", name, ""]);
    }
  }
  if let Some(node) = resources.render_node {
    let metadata = node.metadata()?;
    let name = node
      .file_name()
      .and_then(OsStr::to_str)
      .ok_or_else(|| io::Error::other("invalid render node"))?;
    if node.parent() != Some(Path::new("/dev/dri"))
      || !metadata.file_type().is_char_device()
      || !name
        .strip_prefix("renderD")
        .is_some_and(|value| value.parse::<u32>().is_ok_and(|minor| minor >= 128))
    {
      return Err(io::Error::other("graphics requires a DRM render node"));
    }
    use std::os::unix::fs::MetadataExt;
    let device_number = format!(
      "{}:{}",
      libc::major(metadata.rdev()),
      libc::minor(metadata.rdev())
    );
    let render_sys = Path::new("/sys/dev/char")
      .join(&device_number)
      .canonicalize()?;
    let device_sys = render_sys.join("device").canonicalize()?;
    if !device_sys.starts_with("/sys/devices") || !render_sys.starts_with(&device_sys) {
      return Err(io::Error::other("unsupported render-device topology"));
    }
    command
      .arg("--dev-bind")
      .arg(node)
      .arg(node)
      .arg("--ro-bind")
      .arg(&device_sys)
      .arg(&device_sys)
      .arg("--symlink")
      .arg(&render_sys)
      .arg(format!("/sys/dev/char/{device_number}"))
      .arg("--symlink")
      .arg(&render_sys)
      .arg(format!("/sys/class/drm/{name}"))
      .args(["--setenv", "QSG_RHI_BACKEND", "opengl"]);
  }
  let mounts = [
    (bootstrap, "/bootstrap"),
    (bundle, "/plugin"),
    (display, "/run/plugin/wayland"),
  ];
  let mut descriptors = mounts.map(|(file, _)| file.as_raw_fd()).to_vec();
  // A persistent storage grant replaces the ephemeral home tmpfs with a
  // read-write bind of the controller-owned directory; otherwise HOME stays a
  // 32 MiB tmpfs. bwrap --size applies to the *following* --tmpfs, so keep
  // each home tmpfs paired with its own --size (the bind takes no size).
  if let Some(directory) = storage {
    let fd = directory.as_raw_fd();
    command.args(["--bind-fd", &fd.to_string(), "/home/plugin"]);
    descriptors.push(fd);
  } else {
    command.args(["--size", "33554432", "--tmpfs", "/home/plugin"]);
  }
  for (file, destination) in mounts {
    command.args(["--ro-bind-fd", &file.as_raw_fd().to_string(), destination]);
  }
  for (directory, destination) in [
    (resources.runtime, "/runtime"),
    (resources.context, "/context"),
  ] {
    if let Some(directory) = directory {
      if !directory.metadata()?.is_dir() {
        return Err(io::Error::other(
          "shared worker resource is not a directory",
        ));
      }
      command.args([
        "--ro-bind-fd",
        &directory.as_raw_fd().to_string(),
        destination,
      ]);
      descriptors.push(directory.as_raw_fd());
    }
  }
  if resources.context.is_some() {
    command.args(["--setenv", "OMARCHY_PLUGIN_CONTEXT", "1"]);
  }
  for (name, file, writable) in &directories {
    // A selected writable host directory is a read-write bind (writes affect
    // real host data); the read directory stays read-only.
    let option = if *writable {
      "--bind-fd"
    } else {
      "--ro-bind-fd"
    };
    command.args([
      option,
      &file.as_raw_fd().to_string(),
      &format!("/grants/{name}"),
    ]);
    descriptors.push(file.as_raw_fd());
  }
  if let Some(file) = media {
    command.args([
      "--ro-bind-fd",
      &file.as_raw_fd().to_string(),
      "/run/plugin/media",
      "--setenv",
      "DBUS_SESSION_BUS_ADDRESS",
      "unix:path=/run/plugin/media",
    ]);
    descriptors.push(file.as_raw_fd());
  }
  for (file, destination) in &audio {
    command.args(["--ro-bind-fd", &file.as_raw_fd().to_string(), destination]);
    descriptors.push(file.as_raw_fd());
  }
  if let Some(file) = network_proxy {
    command.args([
      "--ro-bind-fd",
      &file.as_raw_fd().to_string(),
      crate::network_proxy::PATH,
    ]);
    descriptors.push(file.as_raw_fd());
  }
  // Runtime-readable view of the actually-granted access, authored by the
  // controller from its admitted record. Read-only so plugin code can adapt to
  // declined optional access but cannot rewrite its own grants.
  if let Some(file) = resources.grants_json {
    command.args([
      "--ro-bind-fd",
      &file.as_raw_fd().to_string(),
      "/run/plugin/grants.json",
    ]);
    descriptors.push(file.as_raw_fd());
  }
  // Bubblewrap consumes each --ro-bind-fd descriptor, including aliases.
  let mut request_mounts = Vec::new();
  if let Some(socket) = requests {
    for (granted, destination) in [
      (resources.runtime.is_some(), "/run/plugin/ui"),
      (grants.notifications, "/run/plugin/notify"),
      (grants.settings.can_write(), "/run/plugin/settings"),
      (grants.open_urls, "/run/plugin/open-url"),
      (!grants.http.is_empty(), "/run/plugin/http"),
      (!grants.exec.is_empty(), "/run/plugin/exec"),
    ] {
      if granted {
        request_mounts.push((socket.try_clone()?, destination));
      }
    }
  }
  for (socket, destination) in &request_mounts {
    command.args(["--ro-bind-fd", &socket.as_raw_fd().to_string(), destination]);
    descriptors.push(socket.as_raw_fd());
  }
  for (name, value) in [
    ("HOME", "/home/plugin"),
    (
      "PATH",
      if resources.runtime.is_some() {
        "/runtime/bin:/usr/bin"
      } else {
        "/usr/bin"
      },
    ),
    ("LANG", "C.UTF-8"),
    ("XDG_RUNTIME_DIR", "/run/plugin"),
    ("WAYLAND_DISPLAY", "wayland"),
    ("QT_QPA_PLATFORM", "wayland"),
    ("QT_QPA_PLATFORMTHEME", "none"),
    ("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1"),
    ("QML_IMPORT_PATH", "/plugin/native"),
  ] {
    command.args(["--setenv", name, value]);
  }
  for dir in &resources.paths {
    command.args(["--setenv", dir.env, &dir.value]);
  }
  command
    .args([
      "--remount-ro",
      "/",
      "--chdir",
      "/plugin",
      "--",
      "/bootstrap",
    ])
    .args(args)
    .stdin(Stdio::null())
    .stdout(Stdio::null())
    .stderr(Stdio::piped());
  // Only the child clears CLOEXEC on these borrowed descriptors. The parent
  // retains its flags, including when other threads are concurrently spawning.
  // No allocation or non-async-signal-safe operation is used after fork.
  unsafe {
    command.pre_exec(move || {
      for &fd in &descriptors {
        if libc::fcntl(fd, libc::F_SETFD, 0) < 0 {
          return Err(io::Error::last_os_error());
        }
      }
      Ok(())
    });
  }
  command.spawn()
}

/// Call in the bootstrap, before loading QML, native modules, or helpers.
/// An error is terminal: the process must exit without running plugin code.
pub fn restrict_bootstrap() -> io::Result<()> {
  // Do not rely solely on Bubblewrap's descriptor cleanup. In particular, a
  // connected inherited socket bypasses pathname-based Landlock restrictions.
  if unsafe { libc::syscall(libc::SYS_close_range, 3u32, u32::MAX, 0) } < 0 {
    return Err(io::Error::last_os_error());
  }
  let socket = OpenOptions::new()
    .read(true)
    .custom_flags(libc::O_PATH | libc::O_NOFOLLOW)
    .open("/run/plugin/wayland")?;
  let mut sockets = vec![socket];
  for path in [
    "/run/plugin/media",
    "/run/plugin/notify",
    "/run/plugin/settings",
    "/run/plugin/exec",
    "/run/plugin/open-url",
    "/run/plugin/audio-playback",
    "/run/plugin/microphone",
    "/run/plugin/audio-capture",
    crate::network_proxy::PATH,
  ] {
    match OpenOptions::new()
      .read(true)
      .custom_flags(libc::O_PATH | libc::O_NOFOLLOW)
      .open(path)
    {
      Ok(socket) => sockets.push(socket),
      Err(error) if error.kind() == io::ErrorKind::NotFound => (),
      Err(error) => return Err(error),
    }
  }
  // Home can be persistent host-backed storage. File access must not also
  // grant access to host sockets there, even if its backing filesystem is tmpfs.
  let directories = ["/tmp", "/run/plugin"].map(|path| {
    OpenOptions::new()
      .read(true)
      .custom_flags(libc::O_PATH | libc::O_NOFOLLOW)
      .open(path)
  });
  let directories = directories.into_iter().collect::<io::Result<Vec<_>>>()?;
  sandbox::restrict_private_worker(
    &sockets.iter().map(AsFd::as_fd).collect::<Vec<_>>(),
    &directories.iter().map(AsFd::as_fd).collect::<Vec<_>>(),
  )
}

#[cfg(test)]
mod tests {
  use super::*;
  use crate::revision::Revision;
  use std::{fs, os::unix::fs::PermissionsExt};

  #[test]
  fn host_assets_are_revision_exact_and_owned_by_one_runtime() {
    let private = || {
      tempfile::Builder::new()
        .permissions(fs::Permissions::from_mode(0o700))
        .tempdir()
        .unwrap()
    };
    let source = private();
    let revisions = private();
    let first_runtime = private();
    let second_runtime = private();
    fs::write(source.path().join("sound.wav"), "first").unwrap();
    fs::write(source.path().join("removed.wav"), "old asset").unwrap();
    let first = Revision::import(source.path(), revisions.path()).unwrap();
    let first_stage =
      stage_plugin_assets(&first.path, &first.digest, first_runtime.path()).unwrap();
    fs::remove_file(source.path().join("removed.wav")).unwrap();
    fs::write(source.path().join("sound.wav"), "second").unwrap();
    let second = Revision::import(source.path(), revisions.path()).unwrap();
    let second_stage =
      stage_plugin_assets(&second.path, &second.digest, second_runtime.path()).unwrap();
    assert_eq!(fs::read(first_stage.join("sound.wav")).unwrap(), b"first");
    assert_eq!(fs::read(second_stage.join("sound.wav")).unwrap(), b"second");
    assert!(first_stage.join("removed.wav").exists());
    assert!(!second_stage.join("removed.wav").exists());
    assert!(stage_plugin_assets(&first.path, &second.digest, second_runtime.path()).is_err());

    // A pre-existing stage must not redirect a copy into an unrelated file.
    let outside = source.path().join("outside");
    fs::write(&outside, "untouched").unwrap();
    fs::remove_file(first_stage.join("sound.wav")).unwrap();
    std::os::unix::fs::symlink(&outside, first_stage.join("sound.wav")).unwrap();
    assert!(stage_plugin_assets(&first.path, &first.digest, first_runtime.path()).is_err());
    assert_eq!(fs::read(&outside).unwrap(), b"untouched");
    drop(first_runtime);
    assert!(!first_stage.exists());
    assert!(second_stage.exists());
    drop(second_runtime);
    assert!(!second_stage.exists());
  }
}
