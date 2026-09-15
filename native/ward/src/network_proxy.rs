//! Public-destination streaming transport. This is deliberately not an HTTP
//! scope: CONNECT grants an opaque TCP tunnel, including client-owned TLS.
use crate::{controller::Approval, grants::invalid};
use std::{
  fs::{File, OpenOptions},
  io::{self, Read, Write},
  net::{IpAddr, Shutdown, TcpListener, TcpStream, ToSocketAddrs},
  os::{
    fd::{AsRawFd, FromRawFd, OwnedFd},
    unix::{
      fs::OpenOptionsExt,
      net::{UnixListener, UnixStream},
      process::CommandExt,
    },
  },
  path::Path,
  process::{Child, Command, Stdio},
  sync::{
    Arc,
    atomic::{AtomicUsize, Ordering},
  },
  time::{Duration, Instant},
};
use url::{Host, Url};

pub const PATH: &str = "/run/plugin/network-proxy";
pub const URL: &str = "http://127.0.0.1:18765";
const MAX_CONNECTIONS: usize = 8;
const MAX_HEADER: usize = 16_384;
const IDLE: Duration = Duration::from_secs(60);
const SETUP: Duration = Duration::from_secs(10);

pub struct Broker {
  listener: UnixListener,
  socket: File,
  jobs: Vec<Job>,
  window: Instant,
  starts: usize,
}

struct Job {
  child: Child,
  peer: UnixStream,
}
impl Drop for Job {
  fn drop(&mut self) {
    let _ = self.peer.shutdown(Shutdown::Both);
    let _ = self.child.kill();
    let _ = self.child.wait();
  }
}

impl Broker {
  pub fn prepare(directory: &Path) -> io::Result<Self> {
    crate::revision::require_private_directory(directory)?;
    let path = directory.join("network-proxy");
    let listener = UnixListener::bind(&path)?;
    listener.set_nonblocking(true)?;
    let socket = OpenOptions::new()
      .read(true)
      .custom_flags(libc::O_PATH | libc::O_NOFOLLOW)
      .open(path)?;
    Ok(Self {
      listener,
      socket,
      jobs: Vec::new(),
      window: Instant::now(),
      starts: 0,
    })
  }
  pub(crate) fn socket(&self) -> &File {
    &self.socket
  }

  pub fn dispatch(&mut self, approval: &Approval) -> io::Result<()> {
    if let Err(error) = approval.check() {
      self.jobs.clear();
      return Err(error);
    }
    self.jobs.retain_mut(|job| {
      let mut poll = libc::pollfd {
        fd: job.peer.as_raw_fd(),
        events: 0,
        revents: 0,
      };
      unsafe {
        libc::poll(&mut poll, 1, 0);
      }
      poll.revents & (libc::POLLHUP | libc::POLLERR) == 0
        && matches!(job.child.try_wait(), Ok(None))
    });
    if self.window.elapsed() >= Duration::from_secs(1) {
      self.window = Instant::now();
      self.starts = 0;
    }
    for _ in 0..4 {
      let (mut peer, _) = match self.listener.accept() {
        Ok(pair) => pair,
        Err(error) if error.kind() == io::ErrorKind::WouldBlock => break,
        Err(error) => return Err(error),
      };
      if self.jobs.len() >= MAX_CONNECTIONS || self.starts >= 8 {
        peer.set_nonblocking(true)?;
        let _ = peer.write_all(b"HTTP/1.1 503 Service Unavailable\r\nConnection: close\r\n\r\n");
        continue;
      }
      self.starts += 1;
      if crate::supervisor::authenticate_member(&peer).is_err() {
        continue;
      }
      let child = approval.with_network_proxy(|| {
        let mut command = Command::new(std::env::current_exe()?);
        command
          .arg("--network-proxy-execute")
          .env_clear()
          .stdin(Stdio::from(OwnedFd::from(peer.try_clone()?)))
          .stdout(Stdio::null())
          .stderr(Stdio::null());
        die_with_parent(&mut command);
        command.spawn()
      })?;
      self.jobs.push(Job { child, peer });
    }
    Ok(())
  }
}

fn die_with_parent(command: &mut Command) {
  let parent = unsafe { libc::getpid() };
  unsafe {
    command.pre_exec(move || {
      if libc::prctl(libc::PR_SET_PDEATHSIG, libc::SIGKILL) < 0 || libc::getppid() != parent {
        return Err(io::Error::other("proxy owner disappeared"));
      }
      Ok(())
    });
  }
}

/// Invoked only after the normal worker restriction. The listener and every
/// bridge thread remain in that worker's private network namespace and cgroup.
pub fn start_bridge() -> io::Result<()> {
  if !Path::new(PATH).exists() {
    return Ok(());
  }
  let listener = TcpListener::bind("127.0.0.1:18765")?;
  let mut command = Command::new("/bootstrap");
  command
    .arg("--network-proxy-bridge")
    .env_clear()
    .stdin(Stdio::from(OwnedFd::from(listener)))
    .stdout(Stdio::null())
    .stderr(Stdio::null());
  die_with_parent(&mut command);
  command.spawn()?;
  Ok(())
}

pub fn bridge() -> io::Result<()> {
  // fd 0 was created by the trusted, already-restricted worker bootstrap.
  let listener = unsafe { TcpListener::from_raw_fd(0) };
  let active = Arc::new(AtomicUsize::new(0));
  for client in listener.incoming() {
    let mut client = client?;
    if active.load(Ordering::Relaxed) >= MAX_CONNECTIONS {
      continue;
    }
    let mut peer = UnixStream::connect(PATH)?;
    let active = active.clone();
    active.fetch_add(1, Ordering::Relaxed);
    std::thread::spawn(move || {
      let _ = relay(&mut client, &mut peer, true);
      active.fetch_sub(1, Ordering::Relaxed);
    });
  }
  Ok(())
}

struct Request {
  host: String,
  port: u16,
  connect: bool,
  forwarded: Vec<u8>,
}

fn parse(header: &[u8]) -> io::Result<Request> {
  if header.len() > MAX_HEADER || !header.ends_with(b"\r\n\r\n") || !header.is_ascii() {
    return Err(invalid("invalid proxy header"));
  }
  let text = std::str::from_utf8(header).map_err(|_| invalid("invalid proxy header"))?;
  let mut lines = text[..text.len() - 4].split("\r\n");
  let parts: Vec<_> = lines.next().unwrap_or("").split(' ').collect();
  if parts.len() != 3 || !matches!(parts[2], "HTTP/1.0" | "HTTP/1.1") {
    return Err(invalid("invalid proxy request line"));
  }
  let (method, target, version) = (parts[0], parts[1], parts[2]);
  if !matches!(method, "GET" | "HEAD" | "CONNECT")
    || target.bytes().any(|b| b <= 32 || b == 127 || b == b'\\')
  {
    return Err(invalid("unsupported proxy method or target"));
  }
  let connect = method == "CONNECT";
  let url = Url::parse(&if connect {
    format!("http://{target}/")
  } else {
    target.into()
  })
  .map_err(|_| invalid("invalid proxy target"))?;
  if url.scheme() != "http"
    || !url.username().is_empty()
    || url.password().is_some()
    || url.fragment().is_some()
    || (connect
      && (target.contains(['/', '?', '#', '@'])
        || url.port().is_none() && !target.ends_with(":80")))
  {
    return Err(invalid(
      "proxy requires an HTTP URL or explicit CONNECT authority",
    ));
  }
  let host = match url.host().ok_or_else(|| invalid("missing proxy host"))? {
    Host::Domain(host) => host.to_owned(),
    Host::Ipv4(ip) => ip.to_string(),
    Host::Ipv6(ip) => ip.to_string(),
  };
  let port = url
    .port_or_known_default()
    .filter(|port| *port != 0)
    .ok_or_else(|| invalid("invalid proxy port"))?;
  let mut fields = Vec::new();
  for line in lines {
    let (name, value) = line
      .split_once(':')
      .ok_or_else(|| invalid("invalid proxy field"))?;
    if name.is_empty()
      || !name
        .bytes()
        .all(|b| b.is_ascii_alphanumeric() || b"!#$%&'*+-.^_`|~".contains(&b))
      || value.bytes().any(|b| (b < 32 && b != b'\t') || b == 127)
    {
      return Err(invalid("invalid proxy field"));
    }
    let name = name.to_ascii_lowercase();
    if matches!(
      name.as_str(),
      "content-length" | "transfer-encoding" | "upgrade" | "expect"
    ) {
      return Err(invalid("proxy request bodies and upgrades are unsupported"));
    }
    if !matches!(
      name.as_str(),
      "host"
        | "connection"
        | "proxy-connection"
        | "proxy-authorization"
        | "proxy-authenticate"
        | "keep-alive"
        | "te"
        | "trailer"
    ) {
      fields.push(line);
    }
  }
  let mut forwarded = Vec::new();
  if !connect {
    let path = &url[url::Position::BeforePath..url::Position::AfterQuery];
    let authority = &url[url::Position::BeforeHost..url::Position::AfterPort];
    write!(
      forwarded,
      "{method} {path} {version}\r\nHost: {authority}\r\nConnection: close\r\n"
    )?;
    for field in fields {
      write!(forwarded, "{field}\r\n")?;
    }
    forwarded.extend_from_slice(b"\r\n");
  }
  Ok(Request {
    host,
    port,
    connect,
    forwarded,
  })
}

fn public_endpoints(host: &str, port: u16) -> io::Result<Vec<std::net::SocketAddr>> {
  let mut addresses = Vec::new();
  for address in (host, port).to_socket_addrs()? {
    if addresses.contains(&address) {
      continue;
    }
    if addresses.len() >= 16 || !crate::http::public(address.ip()) {
      return Err(io::Error::new(
        io::ErrorKind::PermissionDenied,
        "non-public proxy destination",
      ));
    }
    addresses.push(address);
  }
  if addresses.is_empty() {
    return Err(io::Error::other("empty proxy resolution"));
  }
  let mut routed = Vec::new();
  for address in addresses {
    match route_is_local(address.ip()) {
      Ok(true) => {
        return Err(io::Error::new(
          io::ErrorKind::PermissionDenied,
          "host-local proxy route",
        ));
      }
      Ok(false) => routed.push(address),
      // A missing IPv6 route must not suppress validated IPv4 results. Never
      // connect to the unvalidated/unroutable address itself.
      Err(_) => (),
    }
  }
  if routed.is_empty() {
    return Err(io::Error::other("no validated proxy route"));
  }
  Ok(routed)
}

fn route_is_local(ip: IpAddr) -> io::Result<bool> {
  // Fixed trusted argv, no shell and no worker-supplied route options. This
  // catches public-looking addresses routed back to this host, not only RFC1918.
  let mut command = Command::new("/usr/bin/ip");
  command
    .env_clear()
    .args(["-j", "route", "get", &ip.to_string()])
    .stdin(Stdio::null())
    .stdout(Stdio::piped())
    .stderr(Stdio::null());
  die_with_parent(&mut command);
  let mut child = command.spawn()?;
  let mut bytes = Vec::new();
  child
    .stdout
    .take()
    .unwrap()
    .take(8193)
    .read_to_end(&mut bytes)?;
  let status = child.wait()?;
  if !status.success() || bytes.len() > 8192 {
    return Err(io::Error::other("proxy route unavailable"));
  }
  let routes: Vec<serde_json::Value> = serde_json::from_slice(&bytes)?;
  if routes.is_empty() {
    return Err(io::Error::other("proxy route unavailable"));
  }
  Ok(
    routes
      .iter()
      .any(|route| route["type"] == "local" || route["dev"] == "lo"),
  )
}

/// One bounded host job per peer. A setup watchdog includes libc DNS and route
/// lookup; streaming then uses a bounded nonblocking relay with an idle timeout.
pub fn execute() -> io::Result<()> {
  let mut peer = unsafe { UnixStream::from_raw_fd(0) };
  let setup_done = Arc::new(AtomicUsize::new(0));
  let watchdog = setup_done.clone();
  std::thread::spawn(move || {
    std::thread::sleep(SETUP);
    if watchdog.load(Ordering::Acquire) == 0 {
      std::process::exit(1);
    }
  });
  let result = (|| {
    peer.set_read_timeout(Some(SETUP))?;
    peer.set_write_timeout(Some(SETUP))?;
    let mut header = Vec::new();
    // Never overread body/tunnel bytes into the header parser.
    while !header.ends_with(b"\r\n\r\n") {
      if header.len() == MAX_HEADER {
        return Err(invalid("proxy header too large"));
      }
      let mut byte = [0];
      peer.read_exact(&mut byte)?;
      header.push(byte[0]);
    }
    let request = parse(&header)?;
    let endpoints = public_endpoints(&request.host, request.port)?;
    let mut upstream = None;
    for address in endpoints {
      if let Ok(stream) = TcpStream::connect_timeout(&address, Duration::from_secs(3)) {
        upstream = Some(stream);
        break;
      }
    }
    let mut upstream = upstream.ok_or_else(|| io::Error::other("proxy connect failed"))?;
    upstream.set_write_timeout(Some(SETUP))?;
    if request.connect {
      peer.write_all(b"HTTP/1.1 200 Connection Established\r\n\r\n")?;
    } else {
      upstream.write_all(&request.forwarded)?;
    }
    setup_done.store(1, Ordering::Release);
    relay(&mut peer, &mut upstream, request.connect)
  })();
  if result.is_err() && setup_done.load(Ordering::Acquire) == 0 {
    let status = if result.as_ref().unwrap_err().kind() == io::ErrorKind::PermissionDenied {
      "403 Forbidden"
    } else {
      "502 Bad Gateway"
    };
    let _ = write!(peer, "HTTP/1.1 {status}\r\nConnection: close\r\n\r\n");
  }
  result
}

struct Buffer {
  data: [u8; 16_384],
  start: usize,
  end: usize,
  eof: bool,
  closed: bool,
}
impl Buffer {
  fn new() -> Self {
    Self {
      data: [0; 16_384],
      start: 0,
      end: 0,
      eof: false,
      closed: false,
    }
  }
  fn pump(&mut self, source: &mut impl Read, target: &mut impl Write) -> io::Result<bool> {
    let mut progress = false;
    if !self.eof && self.start == self.end {
      match source.read(&mut self.data) {
        Ok(0) => self.eof = true,
        Ok(n) => {
          self.start = 0;
          self.end = n;
          progress = true;
        }
        Err(e)
          if matches!(
            e.kind(),
            io::ErrorKind::WouldBlock | io::ErrorKind::Interrupted
          ) =>
        {
          ()
        }
        Err(e) => return Err(e),
      }
    }
    if self.start < self.end {
      match target.write(&self.data[self.start..self.end]) {
        Ok(0) => return Err(io::ErrorKind::WriteZero.into()),
        Ok(n) => {
          self.start += n;
          progress = true;
        }
        Err(e)
          if matches!(
            e.kind(),
            io::ErrorKind::WouldBlock | io::ErrorKind::Interrupted
          ) =>
        {
          ()
        }
        Err(e) => return Err(e),
      }
    }
    Ok(progress)
  }
  fn done(&self) -> bool {
    self.eof && self.start == self.end
  }
}

fn relay(
  left: &mut (impl Read + Write + AsRawFd),
  right: &mut (impl Read + Write + AsRawFd),
  bidirectional: bool,
) -> io::Result<()> {
  for fd in [left.as_raw_fd(), right.as_raw_fd()] {
    let flags = unsafe { libc::fcntl(fd, libc::F_GETFL) };
    if flags < 0 || unsafe { libc::fcntl(fd, libc::F_SETFL, flags | libc::O_NONBLOCK) } < 0 {
      return Err(io::Error::last_os_error());
    }
  }
  let mut outbound = Buffer::new();
  let mut inbound = Buffer::new();
  let mut last = Instant::now();
  loop {
    let mut progress = inbound.pump(right, left)?;
    if bidirectional {
      progress |= outbound.pump(left, right)?;
    } else {
      // HTTP GET/HEAD has exactly one bodyless request per connection. Never
      // relay a second, potentially differently addressed request upstream.
      let mut byte = [0];
      match left.read(&mut byte) {
        Ok(0) => outbound.eof = true,
        Ok(_) => return Err(invalid("pipelined proxy request")),
        Err(e)
          if matches!(
            e.kind(),
            io::ErrorKind::WouldBlock | io::ErrorKind::Interrupted
          ) =>
        {
          ()
        }
        Err(e) => return Err(e),
      }
    }
    if inbound.done() {
      return Ok(());
    }
    if outbound.done() && !outbound.closed {
      unsafe {
        libc::shutdown(right.as_raw_fd(), libc::SHUT_WR);
      }
      outbound.closed = true;
    }
    if progress {
      last = Instant::now();
    }
    if last.elapsed() >= IDLE {
      return Err(io::ErrorKind::TimedOut.into());
    }
    let events = |input: &Buffer, output: &Buffer, read: bool| {
      (if read && !input.eof && input.start == input.end {
        libc::POLLIN
      } else {
        0
      }) | (if output.start < output.end {
        libc::POLLOUT
      } else {
        0
      })
    };
    let mut polls = [
      libc::pollfd {
        fd: left.as_raw_fd(),
        events: events(&outbound, &inbound, bidirectional || !outbound.eof),
        revents: 0,
      },
      libc::pollfd {
        fd: right.as_raw_fd(),
        events: events(&inbound, &outbound, true),
        revents: 0,
      },
    ];
    // poll reports HUP even with events=0. An upstream that has closed while
    // downstream is backpressured must not create a busy loop.
    for poll in &mut polls {
      if poll.events == 0 {
        poll.fd = -1;
      }
    }
    if unsafe { libc::poll(polls.as_mut_ptr(), 2, 1000) } < 0 {
      return Err(io::Error::last_os_error());
    }
    if polls[0].revents & (libc::POLLHUP | libc::POLLERR) != 0 {
      return Ok(());
    }
  }
}

#[cfg(test)]
mod tests {
  use super::*;
  use crate::grants::{Grants, Requests};

  #[test]
  fn proxy_is_explicit_and_cannot_be_bypassed_by_raw_network() {
    let ask: Requests =
      serde_json::from_value(serde_json::json!({"networkProxy":{"required":true},"network":true}))
        .unwrap();
    assert_eq!(Grants::default().required_gap(&ask), ["networkProxy"]);
    let mut grants = Grants {
      network_proxy: true,
      ..Default::default()
    };
    grants.validate(&ask).unwrap();
    assert!(grants.required_gap(&ask).is_empty());
    assert!(grants.validate(&Requests::default()).is_err());
    assert_eq!(grants.unrequested(&Requests::default()), ["networkProxy"]);
    grants.network = true;
    assert!(grants.validate(&ask).is_err());
  }

  #[test]
  fn parser_rewrites_the_destination_and_removes_proxy_credentials() {
    let request = parse(b"GET http://example.com:8000/live?q=a%20b HTTP/1.1\r\nHost: 127.0.0.1\r\nProxy-Authorization: secret\r\nIcy-MetaData: 1\r\n\r\n").unwrap();
    assert_eq!(request.host, "example.com");
    assert_eq!(request.port, 8000);
    assert_eq!(
      String::from_utf8(request.forwarded).unwrap(),
      "GET /live?q=a%20b HTTP/1.1\r\nHost: example.com:8000\r\nConnection: close\r\nIcy-MetaData: 1\r\n\r\n"
    );
    for authority in [
      "example.com:443",
      "example.com:8443",
      "example.com:80",
      "[2606:4700::1111]:443",
    ] {
      let request = parse(format!("CONNECT {authority} HTTP/1.1\r\n\r\n").as_bytes()).unwrap();
      assert!(request.connect);
      assert!(request.forwarded.is_empty());
    }
  }

  #[test]
  fn ambiguous_requests_and_body_smuggling_are_rejected() {
    for line in [
      "GET /relative",
      "POST http://example.com/",
      "GET https://example.com/",
      "GET http://user:password@example.com/",
      "GET http://example.com/#fragment",
      "GET http://example.com\\@127.0.0.1/",
      "CONNECT example.com",
      "CONNECT example.com:0",
      "CONNECT example.com:443/path",
      "CONNECT example.com:443?x=y",
      "CONNECT user@example.com:443",
    ] {
      assert!(
        parse(format!("{line} HTTP/1.1\r\n\r\n").as_bytes()).is_err(),
        "{line}"
      );
    }
    for field in [
      "Content-Length: 0",
      "Transfer-Encoding: chunked",
      "Upgrade: websocket",
      "Expect: 100-continue",
      " bad: folded",
      "Bad Name: x",
      "X: a\nb",
      "X: a\0b",
    ] {
      assert!(
        parse(format!("GET http://example.com/ HTTP/1.1\r\n{field}\r\n\r\n").as_bytes()).is_err(),
        "{field}"
      );
    }
    assert!(parse(&vec![b'a'; MAX_HEADER + 1]).is_err());
  }

  #[test]
  fn literal_local_reserved_and_transition_destinations_fail_closed() {
    for host in [
      "127.0.0.1",
      "0.0.0.0",
      "10.0.0.1",
      "172.16.1.1",
      "192.168.1.1",
      "169.254.169.254",
      "100.64.0.1",
      "198.18.0.1",
      "192.0.2.1",
      "224.0.0.1",
      "255.255.255.255",
      "::1",
      "::",
      "fe80::1",
      "fc00::1",
      "ff02::1",
      "::ffff:127.0.0.1",
      "64:ff9b::7f00:1",
      "2002:7f00:1::",
      "2001:db8::1",
      "2001:0::1",
    ] {
      assert!(!crate::http::public(host.parse().unwrap()), "{host}");
      assert!(public_endpoints(host, 80).is_err(), "{host}");
    }
  }

  #[test]
  fn relay_streams_beyond_http_body_limit_with_backpressure() {
    let (mut client, mut left) = UnixStream::pair().unwrap();
    let (mut server, mut right) = UnixStream::pair().unwrap();
    client
      .set_read_timeout(Some(Duration::from_secs(5)))
      .unwrap();
    let relay = std::thread::spawn(move || relay(&mut left, &mut right, true).unwrap());
    let expected = vec![0x5a; 3 * 1024 * 1024 + 7];
    let data = expected.clone();
    let server = std::thread::spawn(move || {
      let mut request = [0; 5];
      server.read_exact(&mut request).unwrap();
      assert_eq!(&request, b"hello");
      server.write_all(&data).unwrap();
      server.shutdown(Shutdown::Write).unwrap();
    });
    client.write_all(b"hello").unwrap();
    client.shutdown(Shutdown::Write).unwrap();
    let mut received = Vec::new();
    client.read_to_end(&mut received).unwrap();
    assert_eq!(received, expected);
    server.join().unwrap();
    relay.join().unwrap();
  }

  #[test]
  fn actual_worker_has_only_selected_stream_sockets_and_private_loopback() {
    let Some(executable) = std::env::var_os("OMARCHY_TEST_WARD_HOST") else {
      return;
    };
    if std::env::var("OMARCHY_TEST_SYSTEMD").as_deref() != Ok("1") {
      return;
    }
    use std::{ffi::OsStr, fs, os::unix::fs::PermissionsExt};
    if std::env::var_os("OMARCHY_TEST_PROXY_RESULT").is_none() {
      let result = tempfile::tempdir().unwrap();
      let marker = result.path().join("passed");
      let args = [
        format!(
          "OMARCHY_TEST_WARD_HOST={}",
          Path::new(&executable).display()
        ),
        "OMARCHY_TEST_SYSTEMD=1".into(),
        format!("OMARCHY_TEST_PROXY_RESULT={}", marker.display()),
        std::env::current_exe().unwrap().to_str().unwrap().into(),
        "--exact".into(),
        "network_proxy::tests::actual_worker_has_only_selected_stream_sockets_and_private_loopback"
          .into(),
        "--nocapture".into(),
        "--test-threads=1".into(),
      ];
      let mut unit = crate::supervisor::Unit::start(
        Path::new("/usr/bin/env"),
        &args.iter().map(OsStr::new).collect::<Vec<_>>(),
        crate::supervisor::Limits::default(),
      )
      .unwrap();
      let deadline = Instant::now() + Duration::from_secs(8);
      while unit.running().unwrap() && Instant::now() < deadline {
        std::thread::sleep(Duration::from_millis(20));
      }
      unit.stop().unwrap();
      assert!(
        marker.exists(),
        "{}",
        String::from_utf8_lossy(
          &Command::new("journalctl")
            .args(["--user", "--no-pager", "-n", "30", "-u", unit.name()])
            .output()
            .unwrap()
            .stdout
        )
      );
      return;
    }
    let root = tempfile::Builder::new()
      .permissions(fs::Permissions::from_mode(0o700))
      .tempdir()
      .unwrap();
    let runtime_dir = root.path().join("runtime");
    fs::create_dir(&runtime_dir).unwrap();
    fs::write(
      runtime_dir.join("runtime.json"),
      r#"{"version":1,"entryPoint":"worker"}"#,
    )
    .unwrap();
    fs::write(
      runtime_dir.join("worker"),
      "#!/bin/bash\nexec /usr/bin/python3 /plugin/check.py\n",
    )
    .unwrap();
    fs::set_permissions(
      runtime_dir.join("worker"),
      fs::Permissions::from_mode(0o755),
    )
    .unwrap();
    let runtime = crate::runtime::Runtime::open(&runtime_dir).unwrap();
    let bootstrap = File::open(&executable).unwrap();
    for selected in [false, true] {
      let directory = root
        .path()
        .join(if selected { "selected" } else { "denied" });
      fs::create_dir(&directory).unwrap();
      fs::set_permissions(&directory, fs::Permissions::from_mode(0o700)).unwrap();
      let plugin = directory.join("plugin");
      fs::create_dir(&plugin).unwrap();
      fs::write(plugin.join("check.py"), format!(r#"
import os, socket, subprocess
selected = {selected}
assert not os.path.exists('/dev/snd')
assert not os.path.exists('/run/plugin/pipewire-0')
assert not os.path.exists('/run/plugin/pulse/native')
for name in ['audio-playback', 'network-proxy']:
  assert os.path.exists('/run/plugin/' + name) == selected, name
for name in ['microphone', 'audio-capture']:
  assert not os.path.exists('/run/plugin/' + name), name
assert subprocess.run(['/usr/bin/unshare', '-n', '/usr/bin/true'], capture_output=True).returncode != 0
with open('/proc/self/status') as stream:
  status = stream.read()
assert 'CapEff:\t0000000000000000' in status, status
assert 'CapBnd:\t0000000000000000' in status, status
assert 'Seccomp:\t2' in status, status
for host, port in [('1.1.1.1', 443), ('127.0.0.1', {host_port})]:
  with socket.socket() as stream:
    stream.settimeout(0.2)
    assert stream.connect_ex((host, port)) != 0, host
if selected:
  assert os.environ['https_proxy'] == 'http://127.0.0.1:18765'
  with socket.create_connection(('127.0.0.1', 18765), 2) as stream:
    stream.sendall(b'fixture bridge bytes')
    assert stream.recv(100) == b'fixture reply'
else:
  assert 'https_proxy' not in os.environ
  with socket.socket() as stream:
    assert stream.connect_ex(('127.0.0.1', 18765)) != 0
with socket.socket(socket.AF_UNIX) as stream:
  stream.connect('/run/plugin/wayland')
  stream.sendall(b'PASS')
"#, selected = if selected { "True" } else { "False" }, host_port = {
        // Keep a host listener alive to distinguish namespace separation from
        // merely getting ECONNREFUSED on an unused host port.
        18766
      })).unwrap();
      let host = TcpListener::bind("127.0.0.1:18766").unwrap();
      let display = UnixListener::bind(directory.join("wayland")).unwrap();
      display.set_nonblocking(true).unwrap();
      let grants = Grants {
        network_proxy: selected,
        audio_playback: selected,
        ..Default::default()
      };
      let proxy = selected.then(|| Broker::prepare(&directory).unwrap());
      let audio = crate::audio::Broker::prepare(&directory, &grants).unwrap();
      let requests =
        crate::requests::Broker::start(&directory, Path::new(&executable), vec![]).unwrap();
      let display_path = OpenOptions::new()
        .read(true)
        .custom_flags(libc::O_PATH)
        .open(directory.join("wayland"))
        .unwrap();
      let plugin = File::open(&plugin).unwrap();
      let mut child = crate::worker::spawn(
        &bootstrap,
        &plugin,
        &display_path,
        &[OsStr::new("--runtime-worker"), OsStr::new("worker")],
        crate::supervisor::Limits::default(),
        &grants,
        crate::worker::Resources {
          runtime: Some(&runtime.directory),
          network_proxy: proxy.as_ref(),
          audio: audio.as_ref(),
          requests: Some(&requests),
          ..Default::default()
        },
      )
      .unwrap();
      let deadline = Instant::now() + Duration::from_secs(5);
      let mut passed = false;
      while Instant::now() < deadline {
        crate::supervisor::watchdog().unwrap();
        if let Some(proxy) = &proxy {
          if let Ok((mut peer, _)) = proxy.listener.accept() {
            crate::supervisor::authenticate_member(&peer).unwrap();
            peer.set_read_timeout(Some(Duration::from_secs(1))).unwrap();
            let mut bytes = [0; 20];
            peer.read_exact(&mut bytes).unwrap();
            assert_eq!(&bytes, b"fixture bridge bytes");
            peer.write_all(b"fixture reply").unwrap();
          }
        }
        if let Ok((mut peer, _)) = display.accept() {
          let mut bytes = [0; 4];
          peer.read_exact(&mut bytes).unwrap();
          assert_eq!(&bytes, b"PASS");
          passed = true;
          break;
        }
        if child.try_wait().unwrap().is_some() {
          break;
        }
        std::thread::sleep(Duration::from_millis(5));
      }
      let _ = child.kill();
      let _ = child.wait();
      let mut log = String::new();
      child
        .stderr
        .take()
        .unwrap()
        .read_to_string(&mut log)
        .unwrap();
      assert!(passed, "selected={selected}: {log}");
      drop(host);
    }
    fs::write(
      std::env::var_os("OMARCHY_TEST_PROXY_RESULT").unwrap(),
      "PASS",
    )
    .unwrap();
  }
}
