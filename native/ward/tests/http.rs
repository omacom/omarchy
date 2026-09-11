use omarchy_ward::{
  channel::Channel,
  controller::Approval,
  grants::{Access, FileSystemGrant, Grants, Target},
  http::{Method, Request, Scope},
  requests::Broker,
  revision::Revision,
  store::Store,
  supervisor::{self, Limits},
  worker,
};
use std::{
  ffi::OsStr,
  fs::{self, OpenOptions},
  io::{Read, Write},
  net::{TcpListener, TcpStream},
  os::unix::{
    fs::{OpenOptionsExt, PermissionsExt},
    net::{UnixListener, UnixStream},
  },
  path::Path,
  process::{Command, Stdio},
  sync::{
    Arc, Mutex,
    atomic::{AtomicBool, Ordering},
  },
  thread,
  time::{Duration, Instant},
};

fn connect(path: &Path) -> Channel {
  let deadline = Instant::now() + Duration::from_secs(2);
  loop {
    match Channel::connect(path) {
      Ok(channel) => return channel,
      Err(error) if error.kind() == std::io::ErrorKind::WouldBlock && Instant::now() < deadline => {
        thread::sleep(Duration::from_millis(5))
      }
      Err(error) => panic!("HTTP connection failed: {error}"),
    }
  }
}

fn send(origin: &str, scope: &str, path: &str) -> Channel {
  let channel = connect(Path::new("/run/plugin/http"));
  Request {
    scope: scope.into(),
    method: Method::Get,
    url: format!("{origin}{path}"),
    body: None,
  }
  .send(&channel)
  .unwrap();
  channel
}

#[test]
fn http_worker_child() {
  if !Path::new("/bootstrap").exists() {
    return;
  }
  worker::restrict_bootstrap().unwrap();
  let mut display = UnixStream::connect("/run/plugin/wayland").unwrap();
  let mode = fs::read_to_string("/plugin/mode").unwrap();
  let origin = fs::read_to_string("/plugin/origin").unwrap();
  let cli = |scope: &str, path: &str, json: bool| {
    let mut command = Command::new("/grants/cli");
    if json {
      command.arg("--json");
    }
    let mut child = command
      .arg("--http")
      .stdin(Stdio::piped())
      .stdout(Stdio::piped())
      .stderr(Stdio::piped())
      .spawn()
      .unwrap();
    serde_json::to_writer(
      child.stdin.take().unwrap(),
      &serde_json::json!({
        "scope": scope, "method": "GET", "url": format!("{origin}{path}")
      }),
    )
    .unwrap();
    let output = child.wait_with_output().unwrap();
    let result: serde_json::Value = if json {
      assert!(output.stderr.is_empty());
      serde_json::from_slice(&output.stdout).unwrap()
    } else {
      serde_json::Value::Null
    };
    (output, result)
  };
  assert!(
    TcpStream::connect_timeout(
      &origin.strip_prefix("http://").unwrap().parse().unwrap(),
      Duration::from_millis(100)
    )
    .is_err()
  );
  assert!(
    TcpStream::connect_timeout(&"1.1.1.1:443".parse().unwrap(), Duration::from_millis(100))
      .is_err()
  );
  if mode == "denied" {
    assert!(!Path::new("/run/plugin/http").exists());
    let (output, result) = cli("large", "/large", true);
    assert_eq!(output.status.code(), Some(1));
    assert_eq!(result, serde_json::json!({"version":1,"status":"denied"}));
    let channel = connect(Path::new("/run/plugin/notify"));
    Request {
      scope: "large".into(),
      method: Method::Get,
      url: format!("{origin}/large"),
      body: None,
    }
    .send(&channel)
    .unwrap();
    assert!(omarchy_ward::http::receive(&channel).is_err());
  } else if mode == "allowed" {
    let (output, result) = cli("error", "/error", true);
    assert_eq!(output.status.code(), Some(0));
    assert_eq!(
      result,
      serde_json::json!({"version":1,"status":"completed","httpStatus":403,"headers":{},
        "body":{"base64":"YXBwbGljYXRpb24gcmVmdXNlZAD/"}})
    );
    let (output, _) = cli("error", "/error", false);
    assert_eq!(output.status.code(), Some(1));
    assert_eq!(output.stdout, b"application refused\0\xff");
    let (output, result) = cli("error", "/other", true);
    assert_eq!(output.status.code(), Some(1));
    assert_eq!(result, serde_json::json!({"version":1,"status":"denied"}));
    let (head, body) = omarchy_ward::http::receive(&send(&origin, "large", "/large")).unwrap();
    assert_eq!(head.status, 200);
    assert_eq!(
      body,
      (0..131072).map(|i| (i % 256) as u8).collect::<Vec<_>>()
    );
    assert_eq!(head.headers["link"], "</other>; rel=\"next\"");
    assert!(!head.headers.contains_key("set-cookie"));
    for (scope, path) in [("large", "/other"), ("missing", "/large")] {
      assert!(omarchy_ward::http::receive(&send(&origin, scope, path)).is_err());
    }
    let channel = connect(Path::new("/run/plugin/http"));
    channel
      .send(br#"{"version":1,"title":"cross grant","body":""}"#, &[])
      .unwrap();
    assert!(omarchy_ward::http::receive(&channel).is_err());
    let channel = connect(Path::new("/run/plugin/http"));
    let request: Request = serde_json::from_slice(&fs::read("/plugin/post.json").unwrap()).unwrap();
    request.send(&channel).unwrap();
    let (head, body) = omarchy_ward::http::receive(&channel).unwrap();
    assert_eq!(head.status, 200);
    assert_eq!(body.len(), 131072);
    let (head, body) =
      omarchy_ward::http::receive(&send(&origin, "redirect", "/redirect")).unwrap();
    assert_eq!(head.status, 302);
    assert_eq!(body, b"redirect");
    assert!(head.headers["location"].ends_with("/other"));
    assert!(omarchy_ward::http::receive(&send(&origin, "oversize", "/oversize")).is_err());
    let requests: Vec<_> = (0..12).map(|_| send(&origin, "slow", "/slow")).collect();
    assert!(omarchy_ward::http::receive(&send(&origin, "slow", "/slow")).is_err());
    for channel in requests {
      assert_eq!(omarchy_ward::http::receive(&channel).unwrap().0.status, 200);
    }
  } else {
    let started = Instant::now();
    assert!(omarchy_ward::http::receive(&send(&origin, "slow", "/slow")).is_err());
    assert!(started.elapsed() < Duration::from_secs(12));
    assert_ne!(mode, "revoke", "revocation left the worker alive");
  }
  display.write_all(b"PASS").unwrap();
}

#[test]
fn http_controller_child() {
  let Some(root) = std::env::var_os("OMARCHY_HTTP_TEST_ROOT") else {
    return;
  };
  let root = Path::new(&root);
  let store = Store::open(&root.join("state")).unwrap();
  let epoch = std::env::var("OMARCHY_HTTP_TEST_EPOCH")
    .unwrap()
    .parse()
    .unwrap();
  let approval = Approval::open(&root.join("state"), "test.http", epoch).unwrap();
  let record = store.read("test.http").unwrap();
  fs::write(
    root.join("grants.json"),
    serde_json::to_vec(&record.grants.worker_view()).unwrap(),
  )
  .unwrap();
  let grants_json = fs::File::open(root.join("grants.json")).unwrap();
  let mut broker =
    Broker::start(root, Path::new(env!("CARGO_BIN_EXE_omarchy-ward")), vec![]).unwrap();
  let listener = UnixListener::bind(root.join("wayland")).unwrap();
  listener.set_nonblocking(true).unwrap();
  let fd = |path: &Path| {
    OpenOptions::new()
      .read(true)
      .custom_flags(libc::O_PATH | libc::O_NOFOLLOW)
      .open(path)
      .unwrap()
  };
  let mut child = worker::spawn(
    &fd(&std::env::current_exe().unwrap()),
    &fd(&store.revisions().join(record.revision)),
    &fd(&root.join("wayland")),
    &[
      OsStr::new("--exact"),
      OsStr::new("http_worker_child"),
      OsStr::new("--nocapture"),
    ],
    Limits::default(),
    &record.grants,
    worker::Resources {
      requests: Some(&broker),
      grants_json: Some(&grants_json),
      ..Default::default()
    },
  )
  .unwrap();
  let mut display = None;
  let deadline = Instant::now() + Duration::from_secs(18);
  loop {
    broker.dispatch(&approval).unwrap();
    if display.is_none()
      && let Ok((stream, _)) = listener.accept()
    {
      stream.set_nonblocking(true).unwrap();
      display = Some(stream);
    }
    let mut bytes = [0; 4];
    if display
      .as_mut()
      .is_some_and(|s| s.read(&mut bytes).is_ok_and(|n| n == 4))
    {
      assert_eq!(&bytes, b"PASS");
      fs::write(root.join("passed"), bytes).unwrap();
      break;
    }
    if let Some(status) = child.try_wait().unwrap() {
      let mut log = String::new();
      child
        .stderr
        .take()
        .unwrap()
        .read_to_string(&mut log)
        .unwrap();
      panic!("HTTP worker exited {status}: {log}");
    }
    assert!(
      Instant::now() < deadline,
      "HTTP controller fixture timed out"
    );
    supervisor::watchdog().unwrap();
    thread::sleep(Duration::from_millis(5));
  }
}

fn quote(value: &str) -> String {
  format!("'{}'", value.replace('\'', "'\\''"))
}

#[test]
fn admitted_http_is_scoped_bounded_and_revocable_in_a_real_worker() {
  if std::env::var("OMARCHY_TEST_SYSTEMD").as_deref() != Ok("1") {
    return;
  }
  for mode in ["denied", "allowed", "timeout", "revoke"] {
    let root = tempfile::Builder::new()
      .permissions(fs::Permissions::from_mode(0o700))
      .tempdir()
      .unwrap();
    let source = root.path().join("source");
    fs::create_dir(&source).unwrap();
    fs::create_dir(root.path().join("bin")).unwrap();
    let api = TcpListener::bind("127.0.0.1:0").unwrap();
    api.set_nonblocking(true).unwrap();
    let origin = format!("http://{}", api.local_addr().unwrap());
    let query = format!("query {{ viewer {{ login }} }} #{}", "x".repeat(8192));
    let scopes: serde_json::Map<String, serde_json::Value> = ["large", "slow", "redirect", "oversize", "error"].into_iter()
      .map(|name| (name.into(), serde_json::json!({"scope":{"origin":origin, "method":"GET", "path":format!("/{name}")}})))
      .chain([("post".into(), serde_json::json!({"scope":{"origin":origin, "method":"POST", "path":"/graphql", "body":{"query":{"kind":"exact","value":query}}}}))]).collect();
    fs::write(source.join("manifest.json"), serde_json::to_vec(&serde_json::json!({
      "schemaVersion":1, "id":"test.http", "name":"HTTP test", "version":"1", "kinds":["panel"], "entryPoints":{"panel":"worker.qml"},
      "sandbox":{"version":1, "entryPoint":"worker.qml", "requests":{"http":scopes,"notifications":true,"filesystem":[{"name":"cli","path":env!("CARGO_BIN_EXE_omarchy-ward"),"target":"file","access":"read"}]}}
    })).unwrap()).unwrap();
    fs::write(
      source.join("worker.qml"),
      "import Quickshell\nShellRoot {}\n",
    )
    .unwrap();
    fs::write(source.join("mode"), mode).unwrap();
    fs::write(source.join("origin"), &origin).unwrap();
    fs::write(source.join("post.json"), serde_json::to_vec(&serde_json::json!({"scope":"post", "method":"POST", "url":format!("{origin}/graphql"), "body":{"query":query}})).unwrap()).unwrap();
    let store = Store::initialize(&root.path().join("state")).unwrap();
    let revision = Revision::import(&source, &store.revisions()).unwrap();
    let http = if mode == "denied" {
      Default::default()
    } else {
      scopes
        .iter()
        .map(|(name, ask)| {
          (
            name.clone(),
            serde_json::from_value::<Scope>(ask["scope"].clone()).unwrap(),
          )
        })
        .collect()
    };
    store
      .approve(
        &revision.digest,
        Grants {
          http,
          filesystem: [(
            "cli".into(),
            FileSystemGrant::select(
              Path::new(env!("CARGO_BIN_EXE_omarchy-ward")),
              Access::Read,
              Target::File,
            )
            .unwrap(),
          )]
          .into(),
          notifications: mode == "denied",
          ..Default::default()
        },
      )
      .unwrap();
    let stop = Arc::new(AtomicBool::new(false));
    let stopping = stop.clone();
    let calls = Arc::new(Mutex::new(Vec::<String>::new()));
    let observed = calls.clone();
    let selected_origin = origin.clone();
    let server = thread::spawn(move || {
      let mut clients = Vec::new();
      while !stopping.load(Ordering::SeqCst) {
        match api.accept() {
          Ok((mut stream, _)) => {
            let stopping = stopping.clone();
            let observed = observed.clone();
            let origin = selected_origin.clone();
            let query = query.clone();
            clients.push(thread::spawn(move || {
              stream
                .set_read_timeout(Some(Duration::from_secs(2)))
                .unwrap();
              stream
                .set_write_timeout(Some(Duration::from_secs(2)))
                .unwrap();
              let mut headers = Vec::new();
              let mut byte = [0];
              while !headers.ends_with(b"\r\n\r\n") && headers.len() < 16384 {
                stream.read_exact(&mut byte).unwrap();
                headers.push(byte[0]);
              }
              let headers = String::from_utf8(headers).unwrap();
              let path = headers.split_whitespace().nth(1).unwrap().to_owned();
              let length: usize = headers
                .lines()
                .find_map(|line| {
                  line
                    .to_ascii_lowercase()
                    .strip_prefix("content-length:")
                    .map(|value| value.trim().parse().unwrap())
                })
                .unwrap_or(0);
              assert!(length < 65536);
              let mut request = vec![0; length];
              stream.read_exact(&mut request).unwrap();
              if path == "/graphql" {
                assert_eq!(
                  serde_json::from_slice::<serde_json::Value>(&request).unwrap(),
                  serde_json::json!({"query":query})
                );
              }
              observed.lock().unwrap().push(path.clone());
              if path == "/slow" {
                let deadline =
                  Instant::now() + Duration::from_secs(if mode == "allowed" { 2 } else { 20 });
                while Instant::now() < deadline && !stopping.load(Ordering::SeqCst) {
                  thread::sleep(Duration::from_millis(10));
                }
              }
              if stopping.load(Ordering::SeqCst) {
                return;
              }
              let (status, extra, body) = if path == "/redirect" {
                (
                  "302 Found",
                  format!("Location: {origin}/other\r\n"),
                  b"redirect".to_vec(),
                )
              } else if path == "/error" {
                (
                  "403 Forbidden",
                  String::new(),
                  b"application refused\0\xff".to_vec(),
                )
              } else {
                (
                  "200 OK",
                  "Link: </other>; rel=\"next\"\r\nSet-Cookie: ignored=secret\r\n".into(),
                  (0..if path == "/oversize" {
                    2 * 1024 * 1024 + 1
                  } else {
                    131072
                  })
                    .map(|i| (i % 256) as u8)
                    .collect(),
                )
              };
              let _ = write!(
                stream,
                "HTTP/1.1 {status}\r\n{extra}Content-Length: {}\r\nConnection: close\r\n\r\n",
                body.len()
              );
              let _ = stream.write_all(&body);
            }));
          }
          Err(error) if error.kind() == std::io::ErrorKind::WouldBlock => {
            thread::sleep(Duration::from_millis(5))
          }
          Err(error) => panic!("API fixture failed: {error}"),
        }
      }
      for client in clients {
        client.join().unwrap();
      }
    });
    let controller = root.path().join("controller");
    fs::write(&controller, format!("#!/bin/bash\nexport OMARCHY_PATH={}\nexport OMARCHY_HTTP_TEST_ROOT={}\nexport OMARCHY_HTTP_TEST_EPOCH=\"$5\"\nexec {} --exact http_controller_child --nocapture\n",
      quote(root.path().to_str().unwrap()), quote(root.path().to_str().unwrap()), quote(std::env::current_exe().unwrap().to_str().unwrap()))).unwrap();
    fs::set_permissions(&controller, fs::Permissions::from_mode(0o700)).unwrap();
    let (mut unit, _) = store
      .launch("test.http", &controller, &root.path().join("unused"))
      .unwrap();
    let deadline = Instant::now() + Duration::from_secs(20);
    let mut spoofed = false;
    while unit.running().unwrap() && Instant::now() < deadline {
      if mode == "allowed"
        && !spoofed
        && let Ok(channel) = Channel::connect(&root.path().join("notify"))
      {
        Request {
          scope: "large".into(),
          method: Method::Get,
          url: format!("{origin}/large"),
          body: None,
        }
        .send(&channel)
        .unwrap();
        spoofed = true;
      }
      if mode == "revoke" && !calls.lock().unwrap().is_empty() {
        store.revoke("test.http").unwrap();
        break;
      }
      thread::sleep(Duration::from_millis(5));
    }
    unit.stop().unwrap();
    stop.store(true, Ordering::SeqCst);
    server.join().unwrap();
    assert!(!unit.running().unwrap());
    let paths = calls.lock().unwrap();
    if mode == "revoke" {
      assert_eq!(&*paths, &["/slow"]);
      assert!(!root.path().join("passed").exists());
      assert!(!store.read("test.http").unwrap().enabled);
    } else {
      assert!(
        root.path().join("passed").exists(),
        "HTTP mode {mode} failed: {}",
        String::from_utf8_lossy(
          &Command::new("journalctl")
            .args(["--user", "--no-pager", "-n", "50", "-u", unit.name()])
            .output()
            .unwrap()
            .stdout
        )
      );
      if mode == "allowed" {
        assert!(spoofed);
        assert_eq!(paths.iter().filter(|p| *p == "/large").count(), 1);
        assert_eq!(paths.iter().filter(|p| *p == "/error").count(), 2);
        assert_eq!(paths.iter().filter(|p| *p == "/slow").count(), 12);
        assert!(!paths.contains(&"/other".into()));
      }
      if mode == "denied" {
        assert!(paths.is_empty());
      }
    }
  }
}
