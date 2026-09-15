use std::{
  ffi::OsStr,
  fs::{self, File},
  io::{self, Read},
  os::linux::net::SocketAddrExt,
  os::unix::net::{SocketAddr, UnixDatagram},
  path::{Path, PathBuf},
  process::{Command, Output},
};

#[derive(Clone, Copy)]
pub struct Limits {
  pub memory_bytes: u64,
  pub tasks: u16,
  pub cpu_percent: u8,
}

impl Default for Limits {
  fn default() -> Self {
    Self {
      memory_bytes: 512 * 1024 * 1024,
      tasks: 128,
      cpu_percent: 50,
    }
  }
}

impl Limits {
  fn validate(self) -> io::Result<Self> {
    if !(16 * 1024 * 1024..=512 * 1024 * 1024).contains(&self.memory_bytes)
      || !(4..=128).contains(&self.tasks)
      || !(1..=100).contains(&self.cpu_percent)
    {
      Err(io::Error::new(
        io::ErrorKind::InvalidInput,
        "invalid worker resource limits",
      ))
    } else {
      Ok(self)
    }
  }
}

/// Owns one generated transient service, never an arbitrary caller-named unit.
/// This supervises trusted controller code; it does not authorize plugin code.
/// The controller must establish the sandbox before starting a worker, maintain
/// its host-connection lease, and call `watchdog()` from its healthy event loop.
pub struct Unit {
  name: String,
  cgroup: Option<PathBuf>,
  observed: bool,
  started: bool,
  stopped: bool,
}

impl Unit {
  pub fn start(program: &Path, args: &[&OsStr], limits: Limits) -> io::Result<Self> {
    Self::prepare()?.launch(program, args, limits)
  }

  /// Reserve the identity so it can be durably recorded before asking systemd
  /// to launch anything. Dropping an unlaunched reservation has no side effects.
  pub fn prepare() -> io::Result<Self> {
    let mut random = [0u8; 16];
    File::open("/dev/urandom")?.read_exact(&mut random)?;
    let id = random
      .iter()
      .map(|byte| format!("{byte:02x}"))
      .collect::<String>();
    Ok(Self {
      name: format!("omarchy-ward-{id}.service"),
      cgroup: None,
      observed: false,
      started: false,
      stopped: false,
    })
  }

  pub fn launch(mut self, program: &Path, args: &[&OsStr], limits: Limits) -> io::Result<Self> {
    let limits = limits.validate()?;
    if !program.is_absolute() {
      return Err(io::Error::new(
        io::ErrorKind::InvalidInput,
        "controller path must be absolute",
      ));
    }
    let mut command = timed("systemd-run");
    command.args([
      "--user",
      "--collect",
      "--quiet",
      "--service-type=exec",
      "--expand-environment=no",
      "--slice=app.slice",
      "--description=Omarchy Ward plugin host",
      "--property=KillMode=control-group",
      "--property=TimeoutStopSec=1s",
      "--property=SendSIGKILL=yes",
      "--property=Restart=no",
      "--property=OOMPolicy=kill",
      "--property=Delegate=yes",
      "--property=MemorySwapMax=0",
      "--property=RuntimeDirectoryMode=0700",
      "--property=RuntimeDirectoryPreserve=no",
      "--property=LimitCORE=0",
      "--property=LimitNOFILE=512",
      "--property=NoNewPrivileges=yes",
      "--property=WatchdogSec=5s",
      "--property=WatchdogSignal=SIGKILL",
      "--property=NotifyAccess=main",
      "--property=LogRateLimitIntervalSec=5s",
      "--property=LogRateLimitBurst=20",
    ]);
    command.arg(format!("--unit={}", self.name));
    // The service manager owns cleanup, including OOM/watchdog/SIGKILL exits
    // where neither the controller nor its TempDirs can run destructors.
    command.arg(format!(
      "--property=RuntimeDirectory={}",
      self.name.strip_suffix(".service").unwrap()
    ));
    command.arg(format!("--property=MemoryMax={}", limits.memory_bytes));
    command.arg(format!("--property=TasksMax={}", limits.tasks));
    command.arg(format!("--property=CPUQuota={}%", limits.cpu_percent));
    command.arg("--").arg(program).args(args);
    self.started = true;
    successful(command.output()?)?;
    self.observe()?;
    if self.running()? {
      self.verify_limits(limits)?;
    }
    Ok(self)
  }

  /// Recover only an identity read from controller-owned state. A worker must
  /// never be allowed to choose which host unit is inspected or stopped.
  pub(crate) fn recover(name: &str) -> io::Result<Self> {
    validate_name(name)?;
    let mut unit = Self {
      name: name.into(),
      cgroup: None,
      observed: false,
      started: true,
      stopped: false,
    };
    unit.observe()?;
    Ok(unit)
  }

  /// Emergency teardown when the signed grant record cannot be read. Discover
  /// only generated services whose live main process names this exact store
  /// and plugin. No paths or unit names from the damaged record are trusted.
  pub(crate) fn stop_matching(store: &Path, id: &str) -> io::Result<()> {
    use std::os::unix::fs::MetadataExt;
    let output = successful(
      timed("systemctl")
        .args([
          "--user",
          "list-units",
          "--all",
          "--plain",
          "--no-legend",
          "--no-pager",
          "--full",
          "omarchy-ward-*.service",
        ])
        .output()?,
    )?;
    let listing = std::str::from_utf8(&output.stdout)
      .map_err(|_| io::Error::other("invalid controller service listing"))?;
    if listing.len() > 256 * 1024 || listing.lines().count() > 256 {
      return Err(io::Error::other("too many controller services to recover"));
    }
    let mut failure = None;
    let deadline = std::time::Instant::now() + std::time::Duration::from_secs(10);
    for name in listing
      .lines()
      .filter_map(|line| line.split_whitespace().next())
    {
      if validate_name(name).is_err() {
        continue;
      }
      if std::time::Instant::now() >= deadline {
        failure = Some(io::Error::other("controller recovery discovery timed out"));
        break;
      }
      let stopped = (|| -> io::Result<()> {
        let output = successful(
          timed("systemctl")
            .args(["--user", "show", "--property=MainPID", "--value", name])
            .output()?,
        )?;
        let pid: u32 = std::str::from_utf8(&output.stdout)
          .ok()
          .and_then(|value| value.trim().parse().ok())
          .ok_or_else(|| io::Error::other("invalid controller main PID"))?;
        if pid == 0 {
          return Ok(());
        }
        let process = PathBuf::from(format!("/proc/{pid}"));
        if fs::metadata(&process)?.uid() != unsafe { libc::geteuid() } {
          return Ok(());
        }
        let mut command = Vec::new();
        File::open(process.join("cmdline"))?
          .take(65537)
          .read_to_end(&mut command)?;
        if !controller_matches(&command, store, id) {
          return Ok(());
        }
        let membership = fs::read_to_string(process.join("cgroup"))?;
        if !membership
          .lines()
          .any(|line| line.starts_with("0::/") && line.ends_with(&format!("/{name}")))
        {
          return Err(io::Error::other(
            "controller main process has unexpected cgroup",
          ));
        }
        // Stop the unguessable service identity, not the reusable numeric PID.
        // Recover is deliberately after matching: Unit's Drop also stops it.
        Self::recover(name)?.stop()
      })();
      if let Err(error) = stopped {
        // A disappearing process needs no signal. Still inspect other services
        // when one observation fails, but never claim a complete teardown.
        if error.kind() != io::ErrorKind::NotFound {
          failure = Some(error);
        }
      }
    }
    match failure {
      Some(error) => Err(error),
      None => Ok(()),
    }
  }

  fn observe(&mut self) -> io::Result<()> {
    let output = successful(
      timed("systemctl")
        .args([
          "--user",
          "show",
          "--property=ControlGroup",
          "--value",
          &self.name,
        ])
        .output()?,
    )?;
    let group = std::str::from_utf8(&output.stdout)
      .map_err(|_| io::Error::other("invalid cgroup path"))?
      .trim();
    if !group.is_empty() {
      let relative = group
        .strip_prefix('/')
        .ok_or_else(|| io::Error::other("invalid cgroup path"))?;
      if !group.ends_with(&format!("/{}", self.name))
        || Path::new(relative)
          .components()
          .any(|part| !matches!(part, std::path::Component::Normal(_)))
      {
        return Err(io::Error::other("unexpected controller cgroup"));
      }
      self.cgroup = Some(Path::new("/sys/fs/cgroup").join(relative));
    }
    self.observed = true;
    Ok(())
  }

  pub fn name(&self) -> &str {
    &self.name
  }

  pub fn cgroup(&self) -> Option<&Path> {
    self.cgroup.as_deref()
  }

  /// Admit only a live peer from this generated service, before sending it any
  /// grants. The pidfd is obtained from the socket itself, not a reusable PID.
  pub fn authenticate(&self, peer: &crate::channel::Channel) -> io::Result<()> {
    Self::authenticate_peer(
      peer,
      self
        .cgroup
        .as_deref()
        .ok_or_else(|| io::Error::other("controller cgroup unavailable"))?,
    )
  }

  fn authenticate_peer(peer: &impl std::os::fd::AsFd, group: &Path) -> io::Result<()> {
    use std::os::fd::{AsRawFd, FromRawFd, OwnedFd};
    let credentials = rustix::net::sockopt::socket_peercred(peer)?;
    if credentials.uid.as_raw() != unsafe { libc::geteuid() } {
      return Err(io::Error::other("controller has unexpected uid"));
    }
    let mut fd: i32 = -1;
    let mut length = std::mem::size_of_val(&fd) as libc::socklen_t;
    if unsafe {
      libc::getsockopt(
        peer.as_fd().as_raw_fd(),
        libc::SOL_SOCKET,
        libc::SO_PEERPIDFD,
        (&mut fd as *mut i32).cast(),
        &mut length,
      )
    } < 0
    {
      return Err(io::Error::last_os_error());
    }
    let process = unsafe { OwnedFd::from_raw_fd(fd) };
    let expected = group
      .strip_prefix("/sys/fs/cgroup")
      .ok()
      .map(|group| Path::new("/").join(group))
      .ok_or_else(|| io::Error::other("controller cgroup unavailable"))?;
    let membership =
      fs::read_to_string(format!("/proc/{}/cgroup", credentials.pid.as_raw_nonzero()))?;
    if !membership.lines().any(|line| {
      line
        .strip_prefix("0::")
        .is_some_and(|group| Path::new(group) == expected)
    }) {
      return Err(io::Error::other("peer is not the launched controller"));
    }
    let mut poll = libc::pollfd {
      fd: process.as_raw_fd(),
      events: libc::POLLIN,
      revents: 0,
    };
    if unsafe { libc::poll(&mut poll, 1, 0) } != 0 {
      return Err(io::Error::other("controller peer is no longer alive"));
    }
    Ok(())
  }

  /// Kernel population is authoritative even if systemd reports a failed unit.
  pub fn running(&self) -> io::Result<bool> {
    if !self.observed {
      return Err(io::Error::other("controller cgroup has not been observed"));
    }
    let Some(group) = &self.cgroup else {
      return Ok(false);
    };
    population(|| fs::read_to_string(group.join("cgroup.events")))
  }

  fn verify_limits(&self, limits: Limits) -> io::Result<()> {
    let group = self
      .cgroup
      .as_ref()
      .ok_or_else(|| io::Error::other("missing controller cgroup"))?;
    verify_limits_at(group, limits)
  }

  /// A revocation caller must check this result; Drop is only best-effort cleanup.
  pub fn stop(&mut self) -> io::Result<()> {
    if self.stopped || !self.started {
      return Ok(());
    }
    let result = timed("systemctl")
      .args(["--user", "stop", &self.name])
      .output();
    if self.running()? {
      if let Ok(output) = result {
        successful(output)?;
      }
      return Err(io::Error::other("controller process group has not exited"));
    }
    self.stopped = true;
    Ok(())
  }
}

fn controller_matches(command: &[u8], store: &Path, id: &str) -> bool {
  use std::os::unix::ffi::OsStrExt;
  let args = command.split(|byte| *byte == 0).collect::<Vec<_>>();
  command.len() <= 65536
    && args.len() == 7
    && args[6].is_empty()
    && !args[0].is_empty()
    && args[1] == b"--controller"
    && !args[2].is_empty()
    && args[3] == store.as_os_str().as_bytes()
    && args[4] == id.as_bytes()
    && !args[5].is_empty()
    && args[5].iter().all(u8::is_ascii_digit)
}

fn population(mut read: impl FnMut() -> io::Result<String>) -> io::Result<bool> {
  let mut events = read();
  // kernfs can deactivate this node between open and read during cgroup
  // removal (kernfs_seq_start returns ENODEV). Reopen once for fresh evidence;
  // an observation error alone never establishes that the worker has stopped.
  if events
    .as_ref()
    .is_err_and(|error| error.raw_os_error() == Some(libc::ENODEV))
  {
    events = read();
  }
  match events {
    Ok(events) => match events.lines().find(|line| line.starts_with("populated ")) {
      Some("populated 0") => Ok(false),
      Some("populated 1") => Ok(true),
      _ => Err(io::Error::other("invalid cgroup population state")),
    },
    Err(error) if error.kind() == io::ErrorKind::NotFound => Ok(false),
    Err(error) => Err(error),
  }
}

pub(crate) fn validate_name(name: &str) -> io::Result<()> {
  let id = name
    .strip_prefix("omarchy-ward-")
    .and_then(|id| id.strip_suffix(".service"))
    .ok_or_else(|| io::Error::other("invalid plugin service identity"))?;
  if id.len() != 32
    || !id
      .bytes()
      .all(|byte| byte.is_ascii_digit() || (b'a'..=b'f').contains(&byte))
  {
    return Err(io::Error::other("invalid plugin service identity"));
  }
  Ok(())
}

impl Drop for Unit {
  fn drop(&mut self) {
    let _ = self.stop();
  }
}

/// The controller must call this before starting any untrusted process; checking
/// only from the launcher would leave a startup race on unsupported cgroup setups.
pub fn verify_controller_limits(limits: Limits) -> io::Result<()> {
  let limits = limits.validate()?;
  let mut files: libc::rlimit = unsafe { std::mem::zeroed() };
  if unsafe { libc::getrlimit(libc::RLIMIT_NOFILE, &mut files) } != 0 {
    return Err(io::Error::last_os_error());
  }
  if files.rlim_max > 512 || files.rlim_cur > 512 {
    return Err(io::Error::other("file descriptor ceiling is not enforced"));
  }
  verify_limits_at(&controller_group()?, limits)
}

pub fn controller_identity() -> io::Result<String> {
  Ok(
    controller_group()?
      .file_name()
      .and_then(OsStr::to_str)
      .ok_or_else(|| io::Error::other("invalid controller identity"))?
      .into(),
  )
}

/// A broker endpoint belongs to this controller's service. Admit live workers
/// and helpers from that service, not a caller-supplied plugin identifier.
pub(crate) fn authenticate_member(peer: &impl std::os::fd::AsFd) -> io::Result<()> {
  Unit::authenticate_peer(peer, &controller_group()?)
}

pub(crate) fn controller_group() -> io::Result<PathBuf> {
  let membership = fs::read_to_string("/proc/self/cgroup")?;
  let group = membership
    .lines()
    .find_map(|line| line.strip_prefix("0::/"))
    .ok_or_else(|| io::Error::other("controller requires unified cgroups"))?;
  let name = group
    .rsplit('/')
    .next()
    .ok_or_else(|| io::Error::other("controller is not in a plugin service"))?;
  validate_name(name)?;
  if Path::new(group)
    .components()
    .any(|part| !matches!(part, std::path::Component::Normal(_)))
  {
    return Err(io::Error::other("invalid controller cgroup"));
  }
  Ok(Path::new("/sys/fs/cgroup").join(group))
}

fn verify_limits_at(group: &Path, limits: Limits) -> io::Result<()> {
  let number = |name: &str| -> io::Result<u64> {
    fs::read_to_string(group.join(name))?
      .trim()
      .parse()
      .map_err(|_| io::Error::other("resource ceiling is not enforced"))
  };
  let cpu = fs::read_to_string(group.join("cpu.max"))?;
  let cpu = cpu
    .split_whitespace()
    .map(str::parse::<u64>)
    .collect::<Result<Vec<_>, _>>()
    .map_err(|_| io::Error::other("CPU ceiling is not enforced"))?;
  if number("memory.max")? > limits.memory_bytes
    || number("memory.swap.max")? != 0
    || number("pids.max")? > u64::from(limits.tasks)
    || number("memory.oom.group")? != 1
    || cpu.len() != 2
    || u128::from(cpu[0]) * 100 > u128::from(cpu[1]) * u128::from(limits.cpu_percent)
  {
    return Err(io::Error::other(
      "controller resource ceilings are not enforced",
    ));
  }
  Ok(())
}

fn timed(program: &str) -> Command {
  let mut command = Command::new("timeout");
  command.args(["--signal=KILL", "5s", program]);
  command
}

fn successful(output: Output) -> io::Result<Output> {
  if output.status.success() {
    Ok(output)
  } else {
    Err(io::Error::other(format!(
      "user service manager failed: {}",
      String::from_utf8_lossy(&output.stderr).trim()
    )))
  }
}

/// Do not send this from an independent heartbeat thread: a stalled controller
/// must lose its unit and its worker tree, not remain alive behind a heartbeat.
pub fn watchdog() -> io::Result<()> {
  let path = std::env::var_os("NOTIFY_SOCKET")
    .ok_or_else(|| io::Error::other("controller is not supervised"))?;
  use std::os::unix::ffi::OsStrExt;
  let address = if let Some(name) = path.as_bytes().strip_prefix(b"@") {
    SocketAddr::from_abstract_name(name)?
  } else {
    SocketAddr::from_pathname(&path)?
  };
  UnixDatagram::unbound()?.send_to_addr(b"WATCHDOG=1", &address)?;
  Ok(())
}

#[cfg(test)]
mod tests {
  #[test]
  fn emergency_discovery_matches_exact_controller_identity() {
    let command = b"/usr/bin/omarchy-ward\0--controller\0/tmp/socket\0/tmp/store\0test.widget\01\0";
    assert!(super::controller_matches(
      command,
      std::path::Path::new("/tmp/store"),
      "test.widget"
    ));
    assert!(!super::controller_matches(
      command,
      std::path::Path::new("/tmp/other"),
      "test.widget"
    ));
    assert!(!super::controller_matches(
      command,
      std::path::Path::new("/tmp/store"),
      "test.other"
    ));
    assert!(!super::controller_matches(
      &command[..command.len() - 1],
      std::path::Path::new("/tmp/store"),
      "test.widget"
    ));
    let mut extra = command.to_vec();
    extra.extend_from_slice(b"extra\0");
    assert!(!super::controller_matches(
      &extra,
      std::path::Path::new("/tmp/store"),
      "test.widget"
    ));
  }
  use super::*;

  #[test]
  fn cgroup_removal_race_requires_a_fresh_observation() {
    for (next, expected) in [
      (Ok("populated 1\n".into()), true),
      (Ok("populated 0\n".into()), false),
      (Err(io::Error::from_raw_os_error(libc::ENOENT)), false),
    ] {
      let mut reads = [Err(io::Error::from_raw_os_error(libc::ENODEV)), next].into_iter();
      assert_eq!(population(|| reads.next().unwrap()).unwrap(), expected);
      assert!(reads.next().is_none());
    }
    let mut calls = 0;
    assert!(
      population(|| {
        calls += 1;
        Err(io::Error::from_raw_os_error(libc::ENODEV))
      })
      .is_err()
    );
    assert_eq!(calls, 2);
    let mut calls = 0;
    assert!(
      population(|| {
        calls += 1;
        Err(io::Error::from_raw_os_error(libc::EACCES))
      })
      .is_err()
    );
    assert_eq!(calls, 1);
    assert!(population(|| Ok("populated unknown\n".into())).is_err());
  }

  #[test]
  fn limits_cannot_remove_resource_ceilings() {
    assert!(Limits::default().validate().is_ok());
    for limits in [
      Limits {
        memory_bytes: 0,
        ..Limits::default()
      },
      Limits {
        memory_bytes: u64::MAX,
        ..Limits::default()
      },
      Limits {
        tasks: 0,
        ..Limits::default()
      },
      Limits {
        tasks: u16::MAX,
        ..Limits::default()
      },
      Limits {
        cpu_percent: 0,
        ..Limits::default()
      },
      Limits {
        cpu_percent: u8::MAX,
        ..Limits::default()
      },
    ] {
      assert!(limits.validate().is_err());
    }
  }
}
