//! Host CLI job mechanics, not an exposed worker capability. The caller must
//! admit an exact reviewed tree and selections under the store's authority lock.
//! A delegated child cgroup owns descendants without changing host user IDs.
//! External effects (including requests to other daemons) are not undone.
use crate::{exec_policy::Tree, grants::invalid, payload, supervisor};
use serde::{Deserialize, Serialize};
use sha2::{Digest, Sha256};
use std::{
  collections::{BTreeMap, BTreeSet},
  ffi::{CString, OsString},
  fs::{self, File, OpenOptions},
  io::{self, Read, Seek, SeekFrom, Write},
  os::{
    fd::AsRawFd,
    unix::{
      fs::{FileExt, OpenOptionsExt, PermissionsExt},
      process::CommandExt,
    },
  },
  path::{Component, Path, PathBuf},
  process::{Child, ChildStderr, ChildStdout, Command, ExitStatus, Output, Stdio},
  time::{Duration, Instant},
};

const MAX_EXECUTABLE: u64 = 64 * 1024 * 1024;
pub const MAX_OUTPUT: usize = 2 * 1024 * 1024; // Independently for stdout and stderr.
pub const PREPARATION_TIMEOUT: Duration = Duration::from_secs(10);

#[derive(Clone, Copy, Debug, Default, Deserialize, Serialize, PartialEq, Eq)]
#[serde(rename_all = "lowercase")]
pub enum Lifetime {
  // Retained for existing manifest/grant serialization. Neither value limits
  // execution time; every job is owned by its caller and controller.
  #[default]
  Request,
  Plugin,
}

impl Lifetime {
  pub fn is_request(&self) -> bool {
    *self == Self::Request
  }
}

#[derive(Clone, Debug, Deserialize, Serialize, PartialEq, Eq)]
#[serde(deny_unknown_fields)]
pub struct Executable {
  pub path: PathBuf,
  pub digest: String,
}

impl Executable {
  pub fn select(path: &Path) -> io::Result<Self> {
    if !path.is_absolute()
      || path
        .components()
        .any(|part| !matches!(part, Component::RootDir | Component::Normal(_)))
    {
      return Err(invalid(
        "host executable requires an absolute path without traversal",
      ));
    }
    let (_, digest) = snapshot(path)?;
    // Keep the requested invocation name: installed aliases may select a
    // different mode in the same executable through argv[0].
    Ok(Self {
      path: path.to_owned(),
      digest,
    })
  }

  fn open(&self) -> io::Result<File> {
    let (file, digest) = snapshot(&self.path)?;
    if digest != self.digest {
      return Err(invalid("host executable changed; review it again"));
    }
    Ok(file)
  }

  pub(crate) fn prepare(self, started: Instant) -> io::Result<PreparedExecutable> {
    let file = self.open()?;
    Ok(PreparedExecutable {
      executable: self,
      file,
      started,
    })
  }
}

/// A controller-created, verified snapshot; never supplied by a worker.
pub(crate) struct PreparedExecutable {
  executable: Executable,
  file: File,
  started: Instant,
}

impl PreparedExecutable {
  pub(crate) fn check(&self, executable: &Executable) -> io::Result<()> {
    if self.executable != *executable {
      return Err(invalid("prepared executable differs from current approval"));
    }
    Ok(())
  }
}

// Execute a sealed copy through its descriptor. Unlike a pathname or
// inode check followed by exec, this binds the actual executed bytes even if
// the installed file is replaced or edited concurrently. Shared libraries,
// interpreters, configuration and child executables remain host dependencies.
fn snapshot(path: &Path) -> io::Result<(File, String)> {
  if !path.is_absolute() {
    return Err(invalid("host executable requires an absolute path"));
  }
  let path = path.canonicalize()?;
  let mut source = OpenOptions::new()
    .read(true)
    .custom_flags(libc::O_NOFOLLOW | libc::O_NONBLOCK)
    .open(path)?;
  let metadata = source.metadata()?;
  if !metadata.is_file()
    || metadata.permissions().mode() & 0o111 == 0
    || metadata.len() > MAX_EXECUTABLE
  {
    return Err(invalid(
      "host executable must be a bounded regular executable file",
    ));
  }
  // rustix 1.1.4 rejects EMPTY_PATH before issuing faccessat2. Check the
  // already-open file directly, including effective credentials and noexec.
  if unsafe {
    libc::syscall(
      libc::SYS_faccessat2,
      source.as_raw_fd(),
      c"".as_ptr(),
      libc::X_OK,
      libc::AT_EMPTY_PATH | libc::AT_EACCESS,
    )
  } != 0
  {
    return Err(io::Error::last_os_error());
  }
  let mut copy = payload::create()?;
  copy.set_permissions(std::fs::Permissions::from_mode(0o555))?;
  let mut hash = Sha256::new();
  let mut total = 0u64;
  let mut buffer = [0u8; 65536];
  loop {
    let count = source.read(&mut buffer)?;
    if count == 0 {
      break;
    }
    total += count as u64;
    if total > MAX_EXECUTABLE {
      return Err(invalid("host executable exceeds its limit"));
    }
    hash.update(&buffer[..count]);
    copy.write_all(&buffer[..count])?;
  }
  payload::finish(&copy, MAX_EXECUTABLE as usize)?;
  copy.seek(SeekFrom::Start(0))?;
  Ok((copy, format!("{:x}", hash.finalize())))
}

/// Constructed by trusted host code, never deserialized from worker requests.
/// Only standard session/config locations are inherited. Provider-specific
/// environment support, if needed, must be a separately reviewed generic rule.
pub struct Environment(BTreeMap<OsString, OsString>);
impl Environment {
  pub fn capture() -> io::Result<Self> {
    let mut values: BTreeMap<OsString, OsString> = [("PATH".into(), "/usr/bin".into())].into();
    for key in [
      "HOME",
      "XDG_CONFIG_HOME",
      "XDG_DATA_HOME",
      "XDG_CACHE_HOME",
      "XDG_STATE_HOME",
      "XDG_RUNTIME_DIR",
      "DBUS_SESSION_BUS_ADDRESS",
      "LANG",
      "LC_ALL",
    ] {
      if let Some(value) = std::env::var_os(key) {
        if value.len() > 8192 {
          return Err(invalid("host environment value exceeds its limit"));
        }
        values.insert(key.into(), value);
      }
    }
    Ok(Self(values))
  }
}

struct Group {
  path: PathBuf,
  kill: File,
}

impl Group {
  fn create() -> io::Result<Self> {
    let mut random = [0u8; 16];
    File::open("/dev/urandom")?.read_exact(&mut random)?;
    let name: String = random.iter().map(|byte| format!("{byte:02x}")).collect();
    let path = supervisor::controller_group()?.join(format!("job-{name}"));
    fs::create_dir(&path)?;
    match OpenOptions::new()
      .write(true)
      .open(path.join("cgroup.kill"))
    {
      Ok(kill) => Ok(Self { path, kill }),
      Err(error) => {
        let _ = fs::remove_dir(path);
        Err(error)
      }
    }
  }

  fn stop(&self) -> io::Result<()> {
    if unsafe { libc::write(self.kill.as_raw_fd(), b"1".as_ptr().cast(), 1) } == 1 {
      return Ok(());
    }
    let error = io::Error::last_os_error();
    if error.raw_os_error() == Some(libc::ENODEV) {
      Ok(())
    } else {
      Err(error)
    }
  }

  fn finished(&self) -> io::Result<()> {
    if self.path.try_exists()? {
      Err(io::Error::other("host job group cleanup did not finish"))
    } else {
      Ok(())
    }
  }
}

impl Drop for Group {
  fn drop(&mut self) {
    let _ = self.stop();
    let _ = fs::remove_dir(&self.path);
  }
}

// Called only after fork. Use only async-signal-safe libc operations: the
// controller may have other threads holding allocator or library locks.
unsafe fn guard(
  owner: i32,
  kill: i32,
  events: i32,
  path: &CString,
) -> io::Result<()> {
  unsafe {
    if libc::prctl(libc::PR_SET_CHILD_SUBREAPER, 1) != 0 {
      return Err(io::Error::last_os_error());
    }
    libc::signal(libc::SIGCHLD, libc::SIG_DFL);
    let target = libc::fork();
    if target < 0 {
      return Err(io::Error::last_os_error());
    }
    if target == 0 {
      return Ok(());
    }
    // The target retains the spawn-error pipe until exec. The guardian must
    // close its copy, otherwise Command::spawn would wait for the job to end.
    for fd in 3..512 {
      if fd != owner && fd != kill && fd != events {
        libc::close(fd);
      }
    }
    let target_fd = libc::syscall(libc::SYS_pidfd_open, target, 0) as i32;
    let mut status = 0;
    let mut watched = [owner, target_fd].map(|fd| libc::pollfd {
      fd,
      events: libc::POLLIN,
      revents: 0,
    });
    if target_fd >= 0 {
      libc::poll(watched.as_mut_ptr(), 2, -1);
    }
    let completed = libc::waitpid(target, &mut status, libc::WNOHANG) == target;
    if !completed {
      libc::kill(target, libc::SIGKILL);
    }
    libc::write(kill, b"1".as_ptr().cast(), 1);
    // Wait for the kernel's empty-group event, not a guessed number of
    // rmdir retries. Zombies do not keep a cgroup populated. This also bounds
    // cleanup if a task is stuck in uninterruptible kernel I/O.
    let mut began: libc::timespec = std::mem::zeroed();
    libc::clock_gettime(libc::CLOCK_MONOTONIC, &mut began);
    let mut event = libc::pollfd {
      fd: events,
      events: libc::POLLPRI,
      revents: 0,
    };
    loop {
      let mut buffer = [0u8; 256];
      let count = libc::pread(events, buffer.as_mut_ptr().cast(), buffer.len(), 0);
      if count <= 0 {
        libc::_exit(125);
      }
      if buffer[..count as usize]
        .split(|byte| *byte == b'\n')
        .any(|line| line == b"populated 0")
      {
        break;
      }
      let mut now: libc::timespec = std::mem::zeroed();
      libc::clock_gettime(libc::CLOCK_MONOTONIC, &mut now);
      let remaining =
        1000 - (now.tv_sec - began.tv_sec) * 1000 - (now.tv_nsec - began.tv_nsec) / 1_000_000;
      if remaining <= 0 || libc::poll(&mut event, 1, remaining as i32) <= 0 {
        libc::_exit(125);
      }
    }
    while libc::waitpid(-1, std::ptr::null_mut(), libc::WNOHANG) > 0 {}
    if libc::rmdir(path.as_ptr()) != 0 {
      libc::_exit(125);
    }
    libc::_exit(if !completed {
      1
    } else if libc::WIFEXITED(status) {
      libc::WEXITSTATUS(status)
    } else {
      128 + libc::WTERMSIG(status)
    });
  }
}

pub struct Job {
  group: Group,
  child: Child,
  stdout: ChildStdout,
  stderr: ChildStderr,
  out: Vec<u8>,
  err: Vec<u8>,
  out_eof: bool,
  err_eof: bool,
  status: Option<ExitStatus>,
  finished: bool,
}

impl Job {
  pub fn start(
    executable: &Executable,
    tree: &Tree,
    selected: &BTreeSet<String>,
    argv: &[String],
    environment: &Environment,
    paths: &[crate::exec_policy::PluginDir],
    _lifetime: Lifetime,
  ) -> io::Result<Self> {
    tree.check_with(paths, selected, argv)?;
    let started = Instant::now();
    Self::start_prepared(
      executable.clone().prepare(started)?,
      crate::exec_files::Arguments::prepare(argv, paths, started)?,
      tree,
      selected,
      argv,
      environment,
      paths,
    )
  }

  pub(crate) fn start_prepared(
    prepared: PreparedExecutable,
    arguments: crate::exec_files::Arguments,
    tree: &Tree,
    selected: &BTreeSet<String>,
    argv: &[String],
    environment: &Environment,
    paths: &[crate::exec_policy::PluginDir],
  ) -> io::Result<Self> {
    let PreparedExecutable {
      executable,
      file,
      started,
    } = prepared;
    tree.check_with(paths, selected, argv)?;
    arguments.check(argv, paths)?;
    let input_fds: Vec<_> = arguments.files.iter().map(AsRawFd::as_raw_fd).collect();
    supervisor::verify_controller_limits(supervisor::Limits::default())?;
    if started.elapsed() >= PREPARATION_TIMEOUT {
      return Err(invalid("host executable preparation timed out"));
    }
    let fd = file.as_raw_fd();
    if fd < 3 {
      return Err(invalid("host executable requires a private descriptor"));
    }
    let group = Group::create()?;
    let membership = OpenOptions::new()
      .write(true)
      .open(group.path.join("cgroup.procs"))?;
    let member_fd = membership.as_raw_fd();
    let kill_fd = group.kill.as_raw_fd();
    let events = File::open(group.path.join("cgroup.events"))?;
    let events_fd = events.as_raw_fd();
    let group_path = CString::new(group.path.as_os_str().as_encoded_bytes())?;
    let owner = rustix::process::pidfd_open(
      rustix::process::getpid(),
      rustix::process::PidfdFlags::empty(),
    )?;
    let owner_fd = owner.as_raw_fd();
    let mut signature = [0u8; 2];
    let script = file.read_at(&mut signature, 0)? == 2 && signature == *b"#!";
    let mut command = Command::new(format!("/proc/self/fd/{fd}"));
    command
      .arg0(&executable.path)
      .current_dir("/")
      .env_clear()
      .envs(&environment.0)
      .args(&arguments.argv)
      .stdin(Stdio::null())
      .stdout(Stdio::piped())
      .stderr(Stdio::piped());
    unsafe {
      command.pre_exec(move || {
        guard(owner_fd, kill_fd, events_fd, &group_path)?;
        if libc::write(member_fd, b"0".as_ptr().cast(), 1) != 1
          // Preserve the spawn error pipe until exec, but inherit only the
          // explicitly selected payload descriptor through that exec.
          || libc::syscall(libc::SYS_close_range, 3u32, u32::MAX, libc::CLOSE_RANGE_CLOEXEC) != 0
          || (script && libc::fcntl(fd, libc::F_SETFD, 0) != 0)
        {
          return Err(io::Error::other(
            "host job descriptor or parent is unavailable",
          ));
        }
        for input in &input_fds {
          if *input < 3 || libc::fcntl(*input, libc::F_SETFD, 0) != 0 {
            return Err(io::Error::other("host input descriptor is unavailable"));
          }
        }
        Ok(())
      });
    }
    let mut child = command.spawn()?;
    let stdout = child.stdout.take().unwrap();
    let stderr = child.stderr.take().unwrap();
    let mut job = Self {
      group,
      child,
      stdout,
      stderr,
      out: Vec::new(),
      err: Vec::new(),
      out_eof: false,
      err_eof: false,
      status: None,
      finished: false,
    };
    for fd in [job.stdout.as_raw_fd(), job.stderr.as_raw_fd()] {
      let flags = unsafe { libc::fcntl(fd, libc::F_GETFL) };
      if flags == -1 || unsafe { libc::fcntl(fd, libc::F_SETFL, flags | libc::O_NONBLOCK) } == -1 {
        job.cancel()?;
        return Err(io::Error::other("host job output setup failed"));
      }
    }
    Ok(job)
  }

  pub fn poll(&mut self) -> io::Result<Option<Output>> {
    if self.finished {
      return Err(invalid("host job has already finished"));
    }
    let result = self.poll_inner();
    if result.is_err() {
      self.cancel()?;
    }
    result
  }

  fn poll_inner(&mut self) -> io::Result<Option<Output>> {
    self.status = self.child.try_wait()?;
    self.out_eof |= drain(&mut self.stdout, &mut self.out)?;
    self.err_eof |= drain(&mut self.stderr, &mut self.err)?;
    if let Some(status) = self.status
      && self.out_eof
      && self.err_eof
    {
      self.group.finished()?;
      self.finished = true;
      return Ok(Some(Output {
        status,
        stdout: std::mem::take(&mut self.out),
        stderr: std::mem::take(&mut self.err),
      }));
    }
    Ok(None)
  }

  pub fn cancel(&mut self) -> io::Result<()> {
    self.group.stop()?;
    // The guardian observes target termination and finishes group cleanup.
    // Killing it here would race that cleanup and orphan detached children.
    self.child.wait()?;
    self.group.finished()?;
    self.finished = true;
    Ok(())
  }
}

impl Drop for Job {
  fn drop(&mut self) {
    let _ = self.cancel();
  }
}

fn drain(stream: &mut impl Read, output: &mut Vec<u8>) -> io::Result<bool> {
  let mut budget = 65536;
  let mut buffer = [0u8; 8192];
  while budget > 0 {
    let limit = buffer.len().min(budget).min(MAX_OUTPUT + 1 - output.len());
    match stream.read(&mut buffer[..limit]) {
      Ok(0) => return Ok(true),
      Ok(count) => {
        output.extend_from_slice(&buffer[..count]);
        if output.len() > MAX_OUTPUT {
          return Err(invalid("host job output exceeds its limit"));
        }
        budget -= count;
      }
      Err(error) if error.kind() == io::ErrorKind::WouldBlock => break,
      Err(error) if error.kind() == io::ErrorKind::Interrupted => continue,
      Err(error) => return Err(error),
    }
  }
  Ok(false)
}
