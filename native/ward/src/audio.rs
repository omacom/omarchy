//! One-way PCM streams, never a PipeWire protocol proxy. Decoders and encoders
//! stay in the worker. Only fixed-format samples cross this boundary.
use crate::{controller::Approval, grants::Grants, operation::Status};
use std::{
  fs::{File, OpenOptions},
  io::{self, Read, Write},
  net::Shutdown,
  os::{
    fd::AsRawFd,
    unix::{
      fs::OpenOptionsExt,
      net::{UnixListener, UnixStream},
      process::CommandExt,
    },
  },
  path::Path,
  process::{Child, Command, Stdio},
  time::{Duration, Instant},
};

const BUFFER_BYTES: usize = 16_384;
const MAX_STREAMS: usize = 4;
const STARTS_PER_SECOND: usize = 8;
const READY: u8 = 0;
const BUSY: u8 = 1;
const FAILED: u8 = 2;

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Mode {
  Playback,
  Microphone,
  Capture,
}

impl Mode {
  pub const ALL: [Self; 3] = [Self::Playback, Self::Microphone, Self::Capture];

  pub fn granted(self, grants: &Grants) -> bool {
    match self {
      Self::Playback => grants.audio_playback,
      Self::Microphone => grants.microphone,
      Self::Capture => grants.audio_capture,
    }
  }

  fn name(self) -> &'static str {
    match self {
      Self::Playback => "audio-playback",
      Self::Microphone => "microphone",
      Self::Capture => "audio-capture",
    }
  }

  pub fn path(self) -> &'static str {
    match self {
      Self::Playback => "/run/plugin/audio-playback",
      Self::Microphone => "/run/plugin/microphone",
      Self::Capture => "/run/plugin/audio-capture",
    }
  }

  fn limit(self) -> usize {
    if self == Self::Playback { 2 } else { 1 }
  }
}

struct Endpoint {
  mode: Mode,
  listener: UnixListener,
  socket: File,
}

pub struct Broker {
  endpoints: Vec<Endpoint>,
  jobs: Vec<Job>,
  window: Instant,
  starts: usize,
}

impl Broker {
  pub fn prepare(directory: &Path, grants: &Grants) -> io::Result<Option<Self>> {
    if !Mode::ALL.iter().any(|mode| mode.granted(grants)) {
      return Ok(None);
    }
    crate::revision::require_private_directory(directory)?;
    let mut endpoints = Vec::new();
    for mode in Mode::ALL.into_iter().filter(|mode| mode.granted(grants)) {
      let path = directory.join(mode.name());
      let listener = UnixListener::bind(&path)?;
      listener.set_nonblocking(true)?;
      let socket = OpenOptions::new()
        .read(true)
        .custom_flags(libc::O_PATH | libc::O_NOFOLLOW)
        .open(path)?;
      endpoints.push(Endpoint {
        mode,
        listener,
        socket,
      });
    }
    Ok(Some(Self {
      endpoints,
      jobs: Vec::new(),
      window: Instant::now(),
      starts: 0,
    }))
  }

  pub(crate) fn sockets(&self, grants: &Grants) -> io::Result<Vec<(&File, &'static str)>> {
    if Mode::ALL.iter().any(|mode| {
      mode.granted(grants) != self.endpoints.iter().any(|endpoint| endpoint.mode == *mode)
    }) {
      return Err(io::Error::other(
        "audio endpoint selection disagrees with grants",
      ));
    }
    Ok(
      self
        .endpoints
        .iter()
        .map(|endpoint| (&endpoint.socket, endpoint.mode.path()))
        .collect(),
    )
  }

  pub fn dispatch(&mut self, approval: &Approval) -> io::Result<()> {
    // Recheck before moving even an existing stream's samples. Revocation
    // tears down all jobs; the enclosing controller also stops its worker.
    if let Err(error) = approval.check() {
      self.jobs.clear();
      return Err(error);
    }
    self.dispatch_ready(|mode, peer| {
      crate::supervisor::authenticate_member(&peer)?;
      approval.with_audio(mode, |id| Job::start(mode, peer, command(mode, id)?))
    })
  }

  fn dispatch_ready(
    &mut self,
    mut start: impl FnMut(Mode, UnixStream) -> io::Result<Job>,
  ) -> io::Result<()> {
    self.jobs.retain_mut(|job| job.pump().unwrap_or(false));
    if self.window.elapsed() >= Duration::from_secs(1) {
      self.window = Instant::now();
      self.starts = 0;
    }
    // Bounded accepts and work per compositor tick. The kernel backlog and
    // fixed job limits also bound peers that never send/consume a sample.
    for endpoint in &self.endpoints {
      for _ in 0..4 {
        let (mut peer, _) = match endpoint.listener.accept() {
          Ok(peer) => peer,
          Err(error) if error.kind() == io::ErrorKind::WouldBlock => break,
          Err(error) => return Err(error),
        };
        peer.set_nonblocking(true)?;
        if self.starts >= STARTS_PER_SECOND
          || self.jobs.len() >= MAX_STREAMS
          || self
            .jobs
            .iter()
            .filter(|job| job.mode == endpoint.mode)
            .count()
            >= endpoint.mode.limit()
        {
          let _ = peer.write_all(&[1, BUSY]);
          continue;
        }
        self.starts += 1;
        let result = start(endpoint.mode, peer.try_clone()?);
        match result {
          Ok(job) => {
            // No samples are relayed until the versioned handshake is sent.
            if peer.write_all(&[1, READY]).is_ok() {
              self.jobs.push(job);
            }
          }
          Err(_) => {
            let _ = peer.write_all(&[1, FAILED]);
          }
        }
      }
    }
    Ok(())
  }
}

fn command(mode: Mode, id: &str) -> io::Result<Command> {
  crate::grants::validate_id(id)?;
  let runtime = std::env::var_os("XDG_RUNTIME_DIR")
    .ok_or_else(|| io::Error::other("audio requires the host runtime directory"))?;
  if !Path::new(&runtime).is_absolute() {
    return Err(io::Error::other("invalid audio runtime directory"));
  }
  let mut command = Command::new("/usr/bin/pw-cat");
  command
    .env_clear()
    .env("XDG_RUNTIME_DIR", runtime)
    .env("LANG", "C.UTF-8")
    .env("PATH", "/usr/bin")
    .args(arguments(mode, id));
  Ok(command)
}

fn arguments(mode: Mode, id: &str) -> Vec<String> {
  // Only trusted constants and a validated identity enter host argv. In
  // particular there is no worker-controlled device, path, property or format.
  // Capture sinks and sources are distinct WirePlumber target directions.
  let properties = serde_json::json!({
    "node.name": format!("ward.{id}.{}", mode.name()),
    "media.name": format!("Ward {id}: {}", mode.name()),
    "application.name": format!("Ward {id}"),
    "stream.capture.sink": mode == Mode::Capture,
    "node.stream.restore-props": false,
  });
  vec![
    if mode == Mode::Playback {
      "--playback"
    } else {
      "--record"
    }
    .into(),
    "--raw".into(),
    "--format=s16".into(),
    "--rate=48000".into(),
    "--channels=2".into(),
    "--channel-map=stereo".into(),
    "--latency=100ms".into(),
    "--target=auto".into(),
    "--properties".into(),
    properties.to_string(),
    "-".into(),
  ]
}

struct Transfer {
  bytes: [u8; BUFFER_BYTES],
  start: usize,
  end: usize,
  eof: bool,
}
impl Transfer {
  fn new() -> Self {
    Self {
      bytes: [0; BUFFER_BYTES],
      start: 0,
      end: 0,
      eof: false,
    }
  }
  fn pump(&mut self, source: &mut impl Read, destination: &mut impl Write) -> io::Result<bool> {
    if self.start == self.end && !self.eof {
      match source.read(&mut self.bytes) {
        Ok(0) => self.eof = true,
        Ok(count) => {
          self.start = 0;
          self.end = count;
        }
        Err(error)
          if matches!(
            error.kind(),
            io::ErrorKind::WouldBlock | io::ErrorKind::Interrupted
          ) =>
        {
          ()
        }
        Err(error) => return Err(error),
      }
    }
    if self.start < self.end {
      match destination.write(&self.bytes[self.start..self.end]) {
        Ok(0) => return Err(io::ErrorKind::WriteZero.into()),
        Ok(count) => self.start += count,
        Err(error)
          if matches!(
            error.kind(),
            io::ErrorKind::WouldBlock | io::ErrorKind::Interrupted
          ) =>
        {
          ()
        }
        Err(error) => return Err(error),
      }
    }
    Ok(self.eof && self.start == self.end)
  }
}

struct Job {
  mode: Mode,
  peer: UnixStream,
  child: Child,
  transfer: Transfer,
  draining: Option<Instant>,
}

impl Job {
  fn start(mode: Mode, peer: UnixStream, mut command: Command) -> io::Result<Self> {
    command
      .stdin(if mode == Mode::Playback {
        Stdio::piped()
      } else {
        Stdio::null()
      })
      .stdout(if mode == Mode::Playback {
        Stdio::null()
      } else {
        Stdio::piped()
      })
      .stderr(Stdio::null());
    let parent = unsafe { libc::getpid() };
    unsafe {
      command.pre_exec(move || {
        if libc::prctl(libc::PR_SET_PDEATHSIG, libc::SIGKILL) < 0 || libc::getppid() != parent {
          return Err(io::Error::other("audio owner disappeared"));
        }
        Ok(())
      });
    }
    let child = command.spawn()?;
    let job = Self {
      mode,
      peer,
      child,
      transfer: Transfer::new(),
      draining: None,
    };
    for fd in job
      .child
      .stdin
      .as_ref()
      .map(AsRawFd::as_raw_fd)
      .into_iter()
      .chain(job.child.stdout.as_ref().map(AsRawFd::as_raw_fd))
    {
      let flags = unsafe { libc::fcntl(fd, libc::F_GETFL) };
      if flags < 0 || unsafe { libc::fcntl(fd, libc::F_SETFL, flags | libc::O_NONBLOCK) } < 0 {
        return Err(io::Error::last_os_error());
      }
    }
    Ok(job)
  }

  fn pump(&mut self) -> io::Result<bool> {
    let mut poll = libc::pollfd {
      fd: self.peer.as_raw_fd(),
      events: libc::POLLRDHUP,
      revents: 0,
    };
    if unsafe { libc::poll(&mut poll, 1, 0) } < 0 {
      return Err(io::Error::last_os_error());
    }
    if poll.revents & (libc::POLLHUP | libc::POLLERR) != 0
      || (self.mode != Mode::Playback && poll.revents & libc::POLLRDHUP != 0)
    {
      return Ok(false);
    }
    if self.mode == Mode::Playback {
      if let Some(input) = self.child.stdin.as_mut() {
        if self.transfer.pump(&mut self.peer, input)? {
          self.child.stdin.take();
          self.draining = Some(Instant::now());
        }
      }
      if let Some(status) = self.child.try_wait()? {
        let _ = self
          .peer
          .write_all(&[if status.success() { READY } else { FAILED }]);
        return Ok(false);
      }
      // A finite clip must finish draining; indefinite streaming itself has no
      // duration deadline. Pausing a radio stream therefore remains valid.
      if self
        .draining
        .is_some_and(|since| since.elapsed() > Duration::from_secs(3))
      {
        return Ok(false);
      }
    } else {
      // Capture carries no commands or input data. A send/half-close cancels it.
      let mut byte = [0];
      match self.peer.read(&mut byte) {
        Err(error) if error.kind() == io::ErrorKind::WouldBlock => (),
        _ => return Ok(false),
      }
      if self
        .transfer
        .pump(self.child.stdout.as_mut().unwrap(), &mut self.peer)?
      {
        return Ok(false);
      }
    }
    Ok(true)
  }
}

impl Drop for Job {
  fn drop(&mut self) {
    let _ = self.peer.shutdown(Shutdown::Both);
    let _ = self.child.kill();
    // A fixed trusted pw-cat has no descendants; the controller cgroup remains
    // the outer lifetime/resource boundary, including on abrupt controller exit.
    let _ = self.child.wait();
  }
}

/// Raw S16 native-endian, 48 kHz stereo. Ward's supported targets are LE.
/// There are no filenames/URLs/options: file decoding remains sandboxed.
pub fn request(mode: Mode) -> io::Result<()> {
  let mut peer = UnixStream::connect(mode.path()).map_err(|error| {
    if error.kind() == io::ErrorKind::NotFound {
      Status::Denied.error()
    } else {
      error
    }
  })?;
  peer.set_read_timeout(Some(Duration::from_secs(3)))?;
  let mut header = [0; 2];
  peer.read_exact(&mut header)?;
  if header[0] != 1 {
    return Err(Status::Unavailable.error());
  }
  match header[1] {
    READY => (),
    BUSY => return Err(Status::Busy.error()),
    _ => return Err(Status::Failed.error()),
  }
  peer.set_read_timeout(None)?;
  if mode == Mode::Playback {
    forward_playback(&mut io::stdin().lock(), &mut peer)?;
    peer.shutdown(Shutdown::Write)?;
    peer.set_read_timeout(Some(Duration::from_secs(4)))?;
    let mut status = [0];
    peer.read_exact(&mut status)?;
    if status != [READY] {
      return Err(Status::Failed.error());
    }
    Ok(())
  } else {
    io::copy(&mut peer, &mut io::stdout().lock())?;
    // Capture is caller-lifetime work, not a finite successful recording.
    Err(Status::Unavailable.error())
  }
}

// Watch the backend even when a decoder is paused with stdin still open.
// Poll before each bounded read/write; never block forever on either side.
fn forward_playback(source: &mut (impl Read + AsRawFd), peer: &mut UnixStream) -> io::Result<()> {
  peer.set_nonblocking(true)?;
  let mut bytes = [0; BUFFER_BYTES];
  let mut start = 0;
  let mut end = 0;
  loop {
    let mut polls = [
      libc::pollfd {
        fd: source.as_raw_fd(),
        events: if start == end { libc::POLLIN } else { 0 },
        revents: 0,
      },
      libc::pollfd {
        fd: peer.as_raw_fd(),
        events: libc::POLLIN | if start < end { libc::POLLOUT } else { 0 },
        revents: 0,
      },
    ];
    // Ignore a source with pending buffered bytes: POLLHUP otherwise spins.
    if start < end {
      polls[0].fd = -1;
    }
    if unsafe { libc::poll(polls.as_mut_ptr(), 2, -1) } < 0 {
      let error = io::Error::last_os_error();
      if error.kind() == io::ErrorKind::Interrupted {
        continue;
      }
      return Err(error);
    }
    if polls[1].revents & (libc::POLLIN | libc::POLLHUP | libc::POLLERR | libc::POLLNVAL) != 0 {
      return Err(Status::Unavailable.error());
    }
    if polls[0].revents & (libc::POLLIN | libc::POLLHUP) != 0 {
      match source.read(&mut bytes) {
        Ok(0) => {
          peer.set_nonblocking(false)?;
          return Ok(());
        }
        Ok(count) => {
          start = 0;
          end = count;
        }
        Err(error)
          if matches!(
            error.kind(),
            io::ErrorKind::Interrupted | io::ErrorKind::WouldBlock
          ) =>
        {
          ()
        }
        Err(error) => return Err(error),
      }
    }
    if start < end && polls[1].revents & libc::POLLOUT != 0 {
      match peer.write(&bytes[start..end]) {
        Ok(0) => return Err(io::ErrorKind::WriteZero.into()),
        Ok(count) => start += count,
        Err(error)
          if matches!(
            error.kind(),
            io::ErrorKind::Interrupted | io::ErrorKind::WouldBlock
          ) =>
        {
          ()
        }
        Err(error) => return Err(error),
      }
    }
  }
}

#[cfg(test)]
mod tests {
  use super::*;
  use std::os::unix::fs::PermissionsExt;

  #[test]
  fn paused_decoder_notices_backend_loss() {
    let (_writer, mut source) = UnixStream::pair().unwrap();
    let (mut peer, backend) = UnixStream::pair().unwrap();
    let (done, result) = std::sync::mpsc::channel();
    let thread = std::thread::spawn(move || {
      done
        .send(forward_playback(&mut source, &mut peer).is_err())
        .unwrap()
    });
    drop(backend);
    assert!(result.recv_timeout(Duration::from_secs(1)).unwrap());
    thread.join().unwrap();
  }

  #[test]
  fn playback_frontend_delivers_all_bytes_before_eof() {
    let (mut writer, mut source) = UnixStream::pair().unwrap();
    let (mut peer, mut backend) = UnixStream::pair().unwrap();
    let expected = vec![0x5a; BUFFER_BYTES * 4 + 7];
    let bytes = expected.clone();
    let writer = std::thread::spawn(move || writer.write_all(&bytes).unwrap());
    let forwarder = std::thread::spawn(move || forward_playback(&mut source, &mut peer).unwrap());
    backend
      .set_read_timeout(Some(Duration::from_secs(2)))
      .unwrap();
    let mut received = Vec::new();
    backend.read_to_end(&mut received).unwrap();
    assert_eq!(received, expected);
    writer.join().unwrap();
    forwarder.join().unwrap();
  }

  #[test]
  fn grants_and_endpoints_are_independent() {
    for mode in Mode::ALL {
      let mut grants = Grants::default();
      match mode {
        Mode::Playback => grants.audio_playback = true,
        Mode::Microphone => grants.microphone = true,
        Mode::Capture => grants.audio_capture = true,
      }
      let temp = tempfile::Builder::new()
        .permissions(std::fs::Permissions::from_mode(0o700))
        .tempdir()
        .unwrap();
      let broker = Broker::prepare(temp.path(), &grants).unwrap().unwrap();
      assert_eq!(broker.sockets(&grants).unwrap().len(), 1);
      assert_eq!(broker.sockets(&grants).unwrap()[0].1, mode.path());
      assert!(broker.sockets(&Grants::default()).is_err());
      for other in Mode::ALL {
        assert_eq!(other.granted(&grants), other == mode);
      }
    }
    let temp = tempfile::tempdir().unwrap();
    assert!(
      Broker::prepare(temp.path(), &Grants::default())
        .unwrap()
        .is_none()
    );
  }

  #[test]
  fn host_argv_is_raw_and_capture_direction_is_fixed() {
    for mode in Mode::ALL {
      let args = arguments(mode, "test.audio");
      assert!(args.contains(&"--raw".into()));
      assert!(args.contains(&"--format=s16".into()));
      assert_eq!(args.last().unwrap(), "-");
      let properties: serde_json::Value = serde_json::from_str(&args[9]).unwrap();
      assert_eq!(properties["stream.capture.sink"], mode == Mode::Capture);
      assert_eq!(
        args[0],
        if mode == Mode::Playback {
          "--playback"
        } else {
          "--record"
        }
      );
    }
  }

  #[test]
  fn partial_writes_keep_exact_samples_and_memory_is_bounded() {
    struct Partial(Vec<u8>);
    impl Write for Partial {
      fn write(&mut self, bytes: &[u8]) -> io::Result<usize> {
        let count = bytes.len().min(7);
        self.0.extend_from_slice(&bytes[..count]);
        Ok(count)
      }
      fn flush(&mut self) -> io::Result<()> {
        Ok(())
      }
    }
    let bytes = vec![93; BUFFER_BYTES * 3 + 13];
    let mut source = io::Cursor::new(&bytes);
    let mut destination = Partial(Vec::new());
    let mut transfer = Transfer::new();
    while !transfer.pump(&mut source, &mut destination).unwrap() {}
    assert_eq!(destination.0, bytes);
    assert_eq!(transfer.bytes.len(), BUFFER_BYTES);
  }

  #[test]
  fn permissions_require_review_and_preserve_old_signed_bytes_when_denied() {
    use crate::grants::Requests;
    let old = r#"{"filesystem":{},"network":false,"http":{},"exec":{},"media":null,"notifications":false,"settings":{"read":[],"write":[]},"openUrls":false,"storage":false,"desktopGeometry":false}"#;
    let grants: Grants = serde_json::from_str(old).unwrap();
    assert_eq!(serde_json::to_string(&grants).unwrap(), old);
    for key in ["audioPlayback", "microphone", "audioCapture"] {
      let requests: Requests =
        serde_json::from_value(serde_json::json!({key: {"required": true}})).unwrap();
      assert_eq!(grants.required_gap(&requests), [key]);
      let selected: Grants = serde_json::from_value(serde_json::json!({key: true})).unwrap();
      selected.validate(&requests).unwrap();
      assert!(selected.required_gap(&requests).is_empty());
      assert!(selected.validate(&Requests::default()).is_err());
      assert_eq!(selected.unrequested(&Requests::default()), [key]);
      assert_ne!(serde_json::to_string(&selected).unwrap(), old);
    }
  }

  fn fake_job(mode: Mode, peer: UnixStream) -> io::Result<Job> {
    Job::start(
      mode,
      peer,
      Command::new(if mode == Mode::Playback {
        "/usr/bin/cat"
      } else {
        "/usr/bin/yes"
      }),
    )
  }

  #[test]
  fn finite_playback_drains_and_disconnected_capture_stops_its_process() {
    for mode in Mode::ALL {
      let (mut client, peer) = UnixStream::pair().unwrap();
      peer.set_nonblocking(true).unwrap();
      let mut job = fake_job(mode, peer).unwrap();
      let pid = job.child.id();
      if mode == Mode::Playback {
        client.write_all(&[0x55; 64_000]).unwrap();
        client.shutdown(Shutdown::Write).unwrap();
        let deadline = Instant::now() + Duration::from_secs(2);
        while job.pump().unwrap() {
          assert!(Instant::now() < deadline);
          std::thread::sleep(Duration::from_millis(1));
        }
        let mut status = [255];
        client.read_exact(&mut status).unwrap();
        assert_eq!(status, [READY]);
      } else {
        // Even a reader that never consumes audio cannot grow the relay.
        for _ in 0..40 {
          assert!(job.pump().unwrap());
        }
        assert_eq!(job.transfer.bytes.len(), BUFFER_BYTES);
        drop(client);
        assert!(!job.pump().unwrap());
      }
      drop(job);
      assert_eq!(unsafe { libc::kill(pid as i32, 0) }, -1);
    }
  }

  #[test]
  fn stream_capacity_is_independent_and_broker_drop_closes_every_peer() {
    let temp = tempfile::Builder::new()
      .permissions(std::fs::Permissions::from_mode(0o700))
      .tempdir()
      .unwrap();
    let grants = Grants {
      audio_playback: true,
      microphone: true,
      audio_capture: true,
      ..Default::default()
    };
    let mut broker = Broker::prepare(temp.path(), &grants).unwrap().unwrap();
    let mut peers = Vec::new();
    for mode in Mode::ALL {
      for index in 0..=mode.limit() {
        let mut peer = UnixStream::connect(temp.path().join(mode.name())).unwrap();
        peer.set_read_timeout(Some(Duration::from_secs(1))).unwrap();
        broker.dispatch_ready(fake_job).unwrap();
        let mut response = [255; 2];
        peer.read_exact(&mut response).unwrap();
        assert_eq!(
          response,
          [1, if index < mode.limit() { READY } else { BUSY }]
        );
        peers.push(peer);
      }
    }
    assert_eq!(broker.jobs.len(), MAX_STREAMS);
    let pids: Vec<_> = broker.jobs.iter().map(|job| job.child.id()).collect();
    drop(broker);
    assert!(
      pids
        .into_iter()
        .all(|pid| unsafe { libc::kill(pid as i32, 0) } == -1)
    );
    for mut peer in peers {
      let mut bytes = Vec::new();
      peer.read_to_end(&mut bytes).unwrap();
    }
  }

  #[test]
  fn private_pipewire_routes_playback_microphone_and_output_capture_separately() {
    if std::env::var("OMARCHY_TEST_AUDIO").as_deref() != Ok("1") {
      return;
    }
    use std::fs;
    // This server has no ALSA, Bluetooth, camera, portal, or host session-bus
    // module. Both its devices are synthetic; no desktop audio is recorded.
    let root = tempfile::Builder::new()
      .permissions(fs::Permissions::from_mode(0o700))
      .tempdir()
      .unwrap();
    let config = root.path().join("pipewire.conf");
    fs::write(&config, r#"
context.properties = { core.daemon = true core.name = pipewire-0 default.clock.rate = 48000 }
context.spa-libs = {
  audio.convert.* = audioconvert/libspa-audioconvert
  support.* = support/libspa-support
  audiotestsrc = audiotestsrc/libspa-audiotestsrc
}
context.modules = [
  { name = libpipewire-module-protocol-native }
  { name = libpipewire-module-metadata }
  { name = libpipewire-module-spa-node-factory }
  { name = libpipewire-module-client-node }
  { name = libpipewire-module-access args = { access.force = unrestricted } }
  { name = libpipewire-module-adapter }
  { name = libpipewire-module-link-factory }
]
context.objects = [
  { factory = metadata args = { metadata.name = default } }
  { factory = spa-node-factory args = { factory.name = support.node.driver node.name = Dummy-Driver priority.driver = 20000 } }
  { factory = adapter args = {
    factory.name = support.null-audio-sink node.name = fixture.sink
    media.class = Audio/Sink audio.position = [ FL FR ]
    adapter.auto-port-config = { mode = dsp monitor = true position = preserve }
  } }
  { factory = adapter args = {
    factory.name = audiotestsrc node.name = fixture.source
    media.class = Audio/Source audio.position = [ FL FR ]
    adapter.auto-port-config = { mode = dsp position = preserve }
  } }
]
"#).unwrap();
    let mut wp_config = fs::read_to_string("/usr/share/wireplumber/wireplumber.conf").unwrap();
    wp_config.push_str(
      r#"
wireplumber.profiles = {
  fixture = {
    inherits = [ policy, mixin.systemwide-session, mixin.stateless ]
    hardware.audio = disabled
    hardware.bluetooth = disabled
    hardware.video-capture = disabled
  }
}
"#,
    );
    fs::write(root.path().join("wireplumber.conf"), wp_config).unwrap();
    let private_command = |name: &str| {
      let mut command = Command::new(name);
      command
        .env_clear()
        .env("PATH", "/usr/bin")
        .env("LANG", "C.UTF-8")
        .env("HOME", root.path())
        .env("XDG_CONFIG_HOME", root.path())
        .env("XDG_RUNTIME_DIR", root.path())
        .env("XDG_STATE_HOME", root.path())
        .env("WIREPLUMBER_CONFIG_DIR", root.path());
      command
    };
    struct Owned(Child);
    impl Drop for Owned {
      fn drop(&mut self) {
        let _ = self.0.kill();
        let _ = self.0.wait();
      }
    }
    let mut server = Owned(
      private_command("/usr/bin/pipewire")
        .args(["-c", config.to_str().unwrap()])
        .stdout(Stdio::null())
        .stderr(File::create(root.path().join("pipewire.log")).unwrap())
        .spawn()
        .unwrap(),
    );
    let deadline = Instant::now() + Duration::from_secs(3);
    while !root.path().join("pipewire-0").exists() {
      assert!(
        server.0.try_wait().unwrap().is_none(),
        "{}",
        fs::read_to_string(root.path().join("pipewire.log")).unwrap()
      );
      assert!(Instant::now() < deadline);
      std::thread::sleep(Duration::from_millis(10));
    }
    let mut policy = Owned(
      private_command("/usr/bin/wireplumber")
        .args(["-c", "wireplumber.conf", "-p", "fixture"])
        .stdout(Stdio::null())
        .stderr(File::create(root.path().join("policy.log")).unwrap())
        .spawn()
        .unwrap(),
    );
    let mut jobs = Vec::new();
    let mut clients = Vec::new();
    for mode in Mode::ALL {
      let (client, peer) = UnixStream::pair().unwrap();
      peer.set_nonblocking(true).unwrap();
      client.set_nonblocking(true).unwrap();
      let mut backend = command(mode, "test.audio").unwrap();
      backend.env("XDG_RUNTIME_DIR", root.path());
      jobs.push(Job::start(mode, peer, backend).unwrap());
      clients.push(client);
    }
    let mut received = [Vec::new(), Vec::new()];
    let deadline = Instant::now() + Duration::from_secs(5);
    // DC samples make output capture distinguishable from the synthetic sine
    // source. Keep feeding with backpressure while both capture jobs consume.
    let samples: Vec<u8> = [1000i16, -1000i16]
      .into_iter()
      .flat_map(i16::to_le_bytes)
      .cycle()
      .take(16_384)
      .collect();
    while Instant::now() < deadline && received.iter().any(|bytes| bytes.len() < 48_000) {
      assert!(
        policy.0.try_wait().unwrap().is_none(),
        "{}",
        fs::read_to_string(root.path().join("policy.log")).unwrap()
      );
      let _ = clients[0].write(&samples);
      for job in &mut jobs {
        assert!(job.pump().unwrap(), "audio backend exited");
      }
      for i in 0..2 {
        let mut bytes = [0; 16_384];
        if let Ok(count) = clients[i + 1].read(&mut bytes) {
          received[i].extend_from_slice(&bytes[..count]);
        }
      }
      std::thread::sleep(Duration::from_millis(2));
    }
    let graph = private_command("/usr/bin/pw-dump").output().unwrap();
    let graph_text = String::from_utf8_lossy(&graph.stdout);
    assert!(
      received.iter().all(|bytes| bytes.len() >= 48_000),
      "capture lengths {:?}; policy {}; graph {graph_text}",
      received.iter().map(Vec::len).collect::<Vec<_>>(),
      fs::read_to_string(root.path().join("policy.log")).unwrap()
    );
    let graph: Vec<serde_json::Value> = serde_json::from_slice(&graph.stdout).unwrap();
    let node = |name: &str| {
      graph
        .iter()
        .find(|row| row["info"]["props"]["node.name"] == name)
        .unwrap()["id"]
        .as_u64()
        .unwrap()
    };
    let linked = |output, input| {
      graph.iter().any(|row| {
        row["type"] == "PipeWire:Interface:Link"
          && row["info"]["output-node-id"] == output
          && row["info"]["input-node-id"] == input
      })
    };
    assert!(linked(
      node("ward.test.audio.audio-playback"),
      node("fixture.sink")
    ));
    assert!(linked(
      node("fixture.source"),
      node("ward.test.audio.microphone")
    ));
    assert!(linked(
      node("fixture.sink"),
      node("ward.test.audio.audio-capture")
    ));
    assert_ne!(
      received[0], received[1],
      "input and output capture were conflated"
    );
    drop(clients);
    drop(jobs);
  }
}
