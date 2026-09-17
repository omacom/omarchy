use omarchy_ward::supervisor::{Limits, Unit, verify_controller_limits, watchdog};
use std::{
  ffi::OsString,
  fs,
  io::{self, BufRead, BufReader, Read, Write},
  os::{
    fd::{AsRawFd, FromRawFd, OwnedFd},
    unix::{
      fs::PermissionsExt,
      net::{UnixListener, UnixStream},
    },
  },
  path::Path,
  process::Command,
  time::{Duration, Instant},
};

// A trusted test controller, only executed inside a generated transient unit.
#[test]
fn controller_child() {
  let Some(path) = std::env::var_os("OMARCHY_UNIT_TEST_SOCKET") else {
    return;
  };
  verify_controller_limits(Limits {
    memory_bytes: 64 * 1024 * 1024,
    tasks: 16,
    cpu_percent: 25,
  })
  .unwrap();
  unsafe {
    libc::signal(libc::SIGTERM, libc::SIG_IGN);
  }
  let mut stream = UnixStream::connect(path).unwrap();
  stream
    .set_read_timeout(Some(Duration::from_millis(200)))
    .unwrap();
  let mut children = vec![Command::new("/usr/bin/sleep").arg("30").spawn().unwrap()];
  let runtime = std::env::var_os("RUNTIME_DIRECTORY").unwrap();
  let assets = Path::new(&runtime).join("assets");
  fs::create_dir(&assets).unwrap();
  fs::write(assets.join("fixture"), "session asset").unwrap();
  writeln!(stream, "READY").unwrap();
  let deadline = Instant::now() + Duration::from_secs(15);
  while Instant::now() < deadline {
    watchdog().unwrap();
    let mut input = [0];
    match stream.read(&mut input) {
      Ok(0) => break, // Host lease ended; systemd must reap the helper too.
      Ok(_) => match input[0] {
        b'C' => unsafe {
          libc::_exit(17);
        }, // No Rust destructors on controller loss.
        b'H' => std::thread::sleep(Duration::from_secs(12)), // No watchdog heartbeat.
        b'F' => {
          loop {
            match Command::new("/usr/bin/sleep").arg("30").spawn() {
              Ok(child) => {
                children.push(child);
                assert!(children.len() < 128);
              }
              Err(error) => {
                assert_eq!(error.raw_os_error(), Some(libc::EAGAIN));
                break;
              }
            }
          }
          writeln!(stream, "TASK_LIMIT").unwrap();
        }
        b'M' => {
          let memory = vec![1u8; 128 * 1024 * 1024];
          std::hint::black_box(&memory);
          panic!("memory allocation exceeded the enforced limit");
        }
        _ => panic!("invalid test command"),
      },
      Err(error)
        if matches!(
          error.kind(),
          io::ErrorKind::WouldBlock | io::ErrorKind::TimedOut
        ) => {}
      Err(error) => panic!("test channel failed: {error}"),
    }
  }
}

fn wait_gone(unit: &Unit, timeout: Duration) {
  let deadline = Instant::now() + timeout;
  while unit.running().unwrap() && Instant::now() < deadline {
    std::thread::sleep(Duration::from_millis(20));
  }
  assert!(
    !unit.running().unwrap(),
    "{} retained processes",
    unit.name()
  );
}

fn process_handles(unit: &Unit) -> Vec<OwnedFd> {
  fs::read_to_string(unit.cgroup().unwrap().join("cgroup.procs"))
    .unwrap()
    .lines()
    .map(|pid| {
      let pid: i32 = pid.parse().unwrap();
      let fd = unsafe { libc::syscall(libc::SYS_pidfd_open, pid, 0) };
      assert!(fd >= 0, "could not observe test process");
      unsafe { OwnedFd::from_raw_fd(fd as i32) }
    })
    .collect()
}

#[test]
fn transient_units_enforce_limits_and_reap_descendants() {
  if std::env::var("OMARCHY_TEST_SYSTEMD").as_deref() != Ok("1") {
    eprintln!("set OMARCHY_TEST_SYSTEMD=1 to run temporary user-service lifecycle tests");
    return;
  }
  for mode in [b'S', b'C', b'H', b'F', b'M', b'E'] {
    let root = tempfile::tempdir().unwrap();
    let path = root.path().join("control");
    let listener = UnixListener::bind(&path).unwrap();
    listener.set_nonblocking(true).unwrap();
    let args = [
      OsString::from(format!("OMARCHY_UNIT_TEST_SOCKET={}", path.display())),
      std::env::current_exe().unwrap().into_os_string(),
      "--exact".into(),
      "controller_child".into(),
      "--nocapture".into(),
    ];
    let mut unit = Unit::start(
      Path::new("/usr/bin/env"),
      &args.iter().map(OsString::as_os_str).collect::<Vec<_>>(),
      Limits {
        memory_bytes: 64 * 1024 * 1024,
        tasks: 16,
        cpu_percent: 25,
      },
    )
    .unwrap();
    let deadline = Instant::now() + Duration::from_secs(3);
    let stream = loop {
      match listener.accept() {
        Ok((stream, _)) => break stream,
        Err(error) if error.kind() == io::ErrorKind::WouldBlock && Instant::now() < deadline => {
          std::thread::sleep(Duration::from_millis(10))
        }
        Err(error) => panic!("controller did not connect: {error}"),
      }
    };
    stream
      .set_read_timeout(Some(Duration::from_secs(3)))
      .unwrap();
    let mut stream = BufReader::new(stream);
    let mut ready = String::new();
    stream.read_line(&mut ready).unwrap();
    assert_eq!(ready, "READY\n");
    let runtime = Path::new(&std::env::var_os("XDG_RUNTIME_DIR").unwrap())
      .join(unit.name().strip_suffix(".service").unwrap());
    assert_eq!(
      fs::metadata(&runtime).unwrap().permissions().mode() & 0o777,
      0o700
    );
    assert_eq!(
      fs::read(runtime.join("assets/fixture")).unwrap(),
      b"session asset"
    );
    let processes = process_handles(&unit);
    assert!(processes.len() >= 2, "test must include a descendant");
    match mode {
      b'S' => unit.stop().unwrap(),
      b'E' => {
        drop(stream);
        wait_gone(&unit, Duration::from_secs(3));
      }
      _ => {
        stream.get_mut().write_all(&[mode]).unwrap();
        if mode == b'F' {
          let mut reply = String::new();
          stream.read_line(&mut reply).unwrap();
          assert_eq!(reply, "TASK_LIMIT\n");
          assert!(
            fs::read_to_string(unit.cgroup().unwrap().join("pids.current"))
              .unwrap()
              .trim()
              .parse::<u64>()
              .unwrap()
              <= 16
          );
          unit.stop().unwrap();
        } else {
          wait_gone(&unit, Duration::from_secs(if mode == b'H' { 8 } else { 3 }));
        }
      }
    }
    for process in processes {
      let mut poll = libc::pollfd {
        fd: process.as_raw_fd(),
        events: libc::POLLIN,
        revents: 0,
      };
      assert_eq!(
        unsafe { libc::poll(&mut poll, 1, 0) },
        1,
        "test process survived teardown"
      );
    }
    unit.stop().unwrap();
    assert!(!runtime.exists(), "service teardown retained staged assets");
    println!("verified lifecycle mode {}", char::from(mode));
  }
}
