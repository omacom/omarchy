//! Explicit installed-CLI grants. Names and argument trees are manifest data;
//! the host never extracts credentials or implements provider-specific calls.
use crate::{
  channel::{Channel, Packet},
  exec_policy::{Tree, validate_argv},
  grants::{invalid, validate_id},
  host_job::{Environment, Executable, Job, Lifetime, MAX_OUTPUT},
  operation::Status,
  payload,
};
use serde::{Deserialize, Serialize};
use std::{
  collections::{BTreeMap, BTreeSet},
  fs::File,
  io::{self, Write},
  os::{fd::AsFd, unix::process::ExitStatusExt},
  path::{Component, PathBuf},
  process::Output,
  time::{Duration, Instant},
};

pub(crate) const TAG: &[u8] = b"OPEXEC\x01";
const MAX_REQUEST: usize = 65536;
const MAX_RESPONSE: usize = MAX_OUTPUT * 2 + 12;

#[derive(Clone, Debug, Deserialize, Serialize, PartialEq, Eq)]
#[serde(deny_unknown_fields)]
pub struct Ask {
  pub executable: PathBuf,
  pub tree: Tree,
  /// Independently required terminal names, never implicit selection.
  #[serde(default)]
  pub required: BTreeSet<String>,
  #[serde(default, skip_serializing_if = "Lifetime::is_request")]
  pub lifetime: Lifetime,
}

#[derive(Clone, Debug, Deserialize, Serialize, PartialEq, Eq)]
#[serde(deny_unknown_fields)]
pub struct Grant {
  pub executable: Executable,
  pub tree: Tree,
  pub selected: BTreeSet<String>,
  #[serde(default, skip_serializing_if = "Lifetime::is_request")]
  pub lifetime: Lifetime,
}

impl Ask {
  pub fn validate(&self) -> io::Result<()> {
    if !self.executable.is_absolute()
      || self.executable.as_os_str().len() > 4096
      || self
        .executable
        .components()
        .any(|c| !matches!(c, Component::RootDir | Component::Normal(_)))
      || !self.required.is_subset(&self.tree.leaves()?)
    {
      return Err(invalid(
        "invalid executable request or required command leaves",
      ));
    }
    Ok(())
  }
}

impl Grant {
  pub fn select(ask: &Ask, selected: BTreeSet<String>) -> io::Result<Self> {
    ask.validate()?;
    let grant = Self {
      executable: Executable::select(&ask.executable)?,
      tree: ask.tree.clone(),
      selected,
      lifetime: ask.lifetime,
    };
    grant.validate(ask)?;
    Ok(grant)
  }

  pub fn validate(&self, ask: &Ask) -> io::Result<()> {
    ask.validate()?;
    if self.executable.path != ask.executable
      || self.executable.digest.len() != 64
      || !self
        .executable
        .digest
        .bytes()
        .all(|b| b.is_ascii_digit() || (b'a'..=b'f').contains(&b))
      || self.tree != ask.tree
      || self.lifetime != ask.lifetime
      || self.selected.is_empty()
      || !self.selected.is_subset(&ask.tree.leaves()?)
    {
      return Err(invalid(
        "exec grant differs from the reviewed executable or command tree",
      ));
    }
    Ok(())
  }
}

#[derive(Debug, Deserialize, Serialize)]
#[serde(deny_unknown_fields)]
pub struct Request {
  pub name: String,
  pub argv: Vec<String>,
}

impl Request {
  fn validate(&self) -> io::Result<()> {
    validate_id(&self.name)?;
    validate_argv(&self.argv)
  }

  pub fn decode(mut packet: Packet) -> io::Result<Self> {
    if packet.bytes != TAG || packet.fds.len() != 1 {
      return Err(invalid("invalid exec record"));
    }
    let request: Self = serde_json::from_slice(&payload::read(packet.fds.remove(0), MAX_REQUEST)?)?;
    request.validate()?;
    Ok(request)
  }

  pub fn send(&self, channel: &Channel) -> io::Result<()> {
    self.validate()?;
    let file = payload::seal(&serde_json::to_vec(self)?, MAX_REQUEST)?;
    channel.send(TAG, &[file.as_fd()])
  }

  pub(crate) fn prepare(
    self,
    grants: &BTreeMap<String, Grant>,
    paths: &[crate::exec_policy::PluginDir],
  ) -> io::Result<Preparation> {
    self.validate()?;
    let grant = grants
      .get(&self.name)
      .ok_or_else(|| Status::Denied.error())?;
    grant
      .tree
      .check_with(paths, &grant.selected, &self.argv)
      .map_err(|_| Status::Denied.error())?;
    let executable = grant.executable.clone();
    let started = Instant::now();
    let argv = self.argv.clone();
    let paths = paths.to_vec();
    Ok(Preparation {
      request: self,
      started,
      task: std::thread::Builder::new()
        .name("ward-exec-verify".into())
        .spawn(move || Ok((executable.prepare(started)?, crate::exec_files::Arguments::prepare(&argv, &paths, started)?)))?,
    })
  }
}

/// Verification does no execution and holds no authority lock. The broker
/// retains its slot until the thread finishes, even after caller cancellation.
pub(crate) struct Preparation {
  request: Request,
  pub(crate) started: Instant,
  task: std::thread::JoinHandle<io::Result<(crate::host_job::PreparedExecutable, crate::exec_files::Arguments)>>,
}

impl Preparation {
  pub(crate) fn is_finished(&self) -> bool {
    self.task.is_finished()
  }

  pub(crate) fn start(
    self,
    grants: &BTreeMap<String, Grant>,
    env: &Environment,
    paths: &[crate::exec_policy::PluginDir],
  ) -> io::Result<Job> {
    if !self.is_finished() {
      return Err(Status::Busy.error());
    }
    let (prepared, arguments) = self.task.join().map_err(|_| Status::Failed.error())??;
    let grant = grants
      .get(&self.request.name)
      .ok_or_else(|| Status::Denied.error())?;
    grant
      .tree
      .check_with(paths, &grant.selected, &self.request.argv)
      .map_err(|_| Status::Denied.error())?;
    prepared.check(&grant.executable)?;
    Job::start_prepared(
      prepared,
      arguments,
      &grant.tree,
      &grant.selected,
      &self.request.argv,
      env,
      paths,
    )
  }
}

pub(crate) fn response(output: Output) -> io::Result<File> {
  if output.stdout.len() > MAX_OUTPUT || output.stderr.len() > MAX_OUTPUT {
    return Err(invalid("exec response exceeds output limits"));
  }
  let mut file = payload::create()?;
  file.write_all(&output.status.into_raw().to_le_bytes())?;
  file.write_all(&(output.stdout.len() as u32).to_le_bytes())?;
  file.write_all(&(output.stderr.len() as u32).to_le_bytes())?;
  file.write_all(&output.stdout)?;
  file.write_all(&output.stderr)?;
  payload::finish(&file, MAX_RESPONSE)?;
  Ok(file)
}

fn decode_response(mut packet: Packet) -> io::Result<Output> {
  if packet.fds.is_empty() {
    let status = crate::operation::decode(packet)?;
    return Err(
      if status == Status::Completed {
        Status::Unavailable
      } else {
        status
      }
      .error(),
    );
  }
  if packet.bytes != TAG || packet.fds.len() != 1 {
    return Err(Status::Unavailable.error());
  }
  let bytes =
    payload::read(packet.fds.remove(0), MAX_RESPONSE).map_err(|_| Status::Unavailable.error())?;
  if bytes.len() < 12 {
    return Err(Status::Unavailable.error());
  }
  let status = i32::from_le_bytes(bytes[..4].try_into().unwrap());
  let out = u32::from_le_bytes(bytes[4..8].try_into().unwrap()) as usize;
  let err = u32::from_le_bytes(bytes[8..12].try_into().unwrap()) as usize;
  if out > MAX_OUTPUT || err > MAX_OUTPUT || bytes.len() != 12 + out + err {
    return Err(Status::Unavailable.error());
  }
  Ok(Output {
    status: std::process::ExitStatus::from_raw(status),
    stdout: bytes[12..12 + out].to_vec(),
    stderr: bytes[12 + out..].to_vec(),
  })
}

pub fn receive(channel: &Channel) -> io::Result<Output> {
  loop {
    match channel.receive() {
      Ok(packet) => return decode_response(packet),
      Err(e) if e.kind() == io::ErrorKind::WouldBlock => {
        std::thread::sleep(Duration::from_millis(5));
      }
      Err(_) => return Err(Status::Unavailable.error()),
    }
  }
}

/// Original helpers keep literal argv and receive the installed CLI's output
/// and exit status. No shell string, host cwd, env or stdin is worker-selected.
pub fn request(name: String, argv: Vec<String>) -> io::Result<Output> {
  let request = Request { name, argv };
  request.validate().map_err(|_| Status::Invalid.error())?;
  let deadline = Instant::now() + Duration::from_secs(120);
  let backoff = Duration::from_millis(500 + u64::from(std::process::id() % 251));
  let output = loop {
    let channel = match crate::operation::connect(crate::requests::Kind::Exec) {
      Ok(channel) => channel,
      Err(e) if e.kind() == io::ErrorKind::WouldBlock && Instant::now() < deadline => {
        // A full listen backlog means this request has not been sent.
        std::thread::sleep(backoff);
        continue;
      }
      Err(e) => return Err(e),
    };
    request.send(&channel)?;
    match receive(&channel) {
      Ok(output) => break output,
      // These replies explicitly mean no job started. Never retry a failed
      // job or lost reply: it could duplicate an already accepted mutation.
      Err(e) if e.kind() == io::ErrorKind::WouldBlock && Instant::now() < deadline => {
        std::thread::sleep(backoff);
      }
      Err(e) => return Err(e),
    }
  };
  Ok(output)
}

#[cfg(test)]
mod tests {
  use super::*;
  use crate::grants::{Grants, Requests};
  use serde_json::json;
  use std::os::unix::fs::PermissionsExt;

  #[test]
  fn plugin_lifetime_is_explicit_and_bound_to_the_review() {
    let value = json!({"executable":"/usr/bin/sleep","tree":{"end":"run"}});
    let bounded: Ask = serde_json::from_value(value.clone()).unwrap();
    let selected = Grant::select(&bounded, ["run".into()].into()).unwrap();
    assert!(
      serde_json::to_value(&selected)
        .unwrap()
        .get("lifetime")
        .is_none()
    );
    let mut long = value;
    long["lifetime"] = json!("plugin");
    let plugin: Ask = serde_json::from_value(long.clone()).unwrap();
    let selected = Grant::select(&plugin, ["run".into()].into()).unwrap();
    assert_eq!(
      serde_json::to_value(&selected).unwrap()["lifetime"],
      "plugin"
    );
    selected.validate(&plugin).unwrap();
    assert!(selected.validate(&bounded).is_err());
    assert!(
      Grant::select(&bounded, ["run".into()].into())
        .unwrap()
        .validate(&plugin)
        .is_err()
    );
    long["lifetime"] = json!("detached");
    assert!(serde_json::from_value::<Ask>(long).is_err());
  }

  #[test]
  fn selections_bind_requested_tree_executable_and_individual_required_leaves() {
    let root = tempfile::tempdir().unwrap();
    let path = root.path().join("executable");
    std::fs::write(&path, "fixture").unwrap();
    std::fs::set_permissions(&path, std::fs::Permissions::from_mode(0o700)).unwrap();
    let ask: Ask = serde_json::from_value(
      json!({"executable":path,"required":["read"],"tree":{"next":[
        {"arg":{"kind":"exact","value":"read"},"then":{"end":"read"}},
        {"arg":{"kind":"exact","value":"write"},"then":{"end":"write"}}
      ]}}),
    )
    .unwrap();
    let requests = Requests {
      exec: [("fixture".into(), ask.clone())].into(),
      ..Default::default()
    };
    let mut grants = Grants::default();
    assert_eq!(grants.required_gap(&requests), ["exec:fixture:read"]);
    assert!(Grant::select(&ask, ["unknown".into()].into()).is_err());
    assert!(Grant::select(&ask, BTreeSet::new()).is_err());
    let selected = Grant::select(&ask, ["read".into()].into()).unwrap();
    grants.exec.insert("fixture".into(), selected.clone());
    grants.validate(&requests).unwrap();
    assert!(grants.required_gap(&requests).is_empty());
    let restored: Grants = serde_json::from_slice(&serde_json::to_vec(&grants).unwrap()).unwrap();
    assert_eq!(restored, grants);
    grants
      .exec
      .get_mut("fixture")
      .unwrap()
      .selected
      .insert("other".into());
    assert!(grants.validate(&requests).is_err());
    grants.exec.insert("fixture".into(), selected.clone());
    grants.exec.get_mut("fixture").unwrap().tree.next[0].arg =
      crate::exec_policy::Argument::Exact {
        value: "delete".into(),
      };
    assert!(grants.validate(&requests).is_err());
    grants.exec.insert("fixture".into(), selected);
    grants.exec.get_mut("fixture").unwrap().executable.path = "/usr/bin/bash".into();
    assert!(grants.validate(&requests).is_err());
  }

  #[test]
  fn prepared_requests_recheck_selection_and_executable_identity_before_launch() {
    let root = tempfile::tempdir().unwrap();
    let path = root.path().join("fixture");
    std::fs::write(&path, "#!/bin/bash\nexit 7\n").unwrap();
    std::fs::set_permissions(&path, std::fs::Permissions::from_mode(0o700)).unwrap();
    let ask: Ask = serde_json::from_value(json!({"executable":path,"tree":{"end":"run"}})).unwrap();
    let grants: BTreeMap<_, _> = [(
      "fixture".into(),
      Grant::select(&ask, ["run".into()].into()).unwrap(),
    )]
    .into();
    let prepare = || {
      let preparation = Request {
        name: "fixture".into(),
        argv: vec![],
      }
      .prepare(&grants, &[])
      .unwrap();
      let deadline = Instant::now() + Duration::from_secs(2);
      while !preparation.is_finished() {
        assert!(Instant::now() < deadline);
        std::thread::sleep(Duration::from_millis(1));
      }
      preparation
    };
    let env = Environment::capture().unwrap();
    let mut declined = grants.clone();
    declined.get_mut("fixture").unwrap().selected.clear();
    let error = prepare().start(&declined, &env, &[]).err().unwrap();
    assert_eq!(Status::from_error(&error), Status::Denied);
    let error = prepare().start(&BTreeMap::new(), &env, &[]).err().unwrap();
    assert_eq!(Status::from_error(&error), Status::Denied);
    let prepared = prepare();
    std::fs::write(&path, "#!/bin/bash\nexit 8\n").unwrap();
    let mut changed = grants.clone();
    changed.get_mut("fixture").unwrap().executable = Executable::select(&path).unwrap();
    let error = prepared.start(&changed, &env, &[]).err().unwrap();
    assert_eq!(
      error.to_string(),
      "prepared executable differs from current approval"
    );
    let invalid = Request {
      name: "fixture".into(),
      argv: vec!["extra".into()],
    }
    .prepare(&grants, &[])
    .err()
    .unwrap();
    assert_eq!(Status::from_error(&invalid), Status::Denied);
  }

  #[test]
  fn selections_preserve_the_requested_alias_and_bind_its_resolved_bytes() {
    let root = tempfile::tempdir().unwrap();
    let target = root.path().join("executable");
    let alias = root.path().join("alias");
    std::fs::write(&target, "fixture").unwrap();
    std::fs::set_permissions(&target, std::fs::Permissions::from_mode(0o700)).unwrap();
    std::os::unix::fs::symlink(&target, &alias).unwrap();
    let ask: Ask =
      serde_json::from_value(json!({"executable":alias,"tree":{"end":"read"}})).unwrap();
    let selected = Grant::select(&ask, ["read".into()].into()).unwrap();
    assert_eq!(selected.executable.path, alias);
    assert_eq!(
      selected.executable.digest,
      Executable::select(&target).unwrap().digest
    );
    let restored: Grant = serde_json::from_slice(&serde_json::to_vec(&selected).unwrap()).unwrap();
    restored.validate(&ask).unwrap();
    let mut different = ask.clone();
    different.executable = target;
    assert!(restored.validate(&different).is_err());
  }

  #[test]
  fn exec_transport_requires_sealed_bounded_records_and_preserves_binary_output() {
    let request = Request {
      name: "fixture".into(),
      argv: vec!["".into(), "a b".into(), "$(touch /no)".into()],
    };
    let (a, b) = Channel::pair().unwrap();
    request.send(&a).unwrap();
    let decoded = Request::decode(b.receive().unwrap()).unwrap();
    assert_eq!(decoded.argv, request.argv);
    for json in [
      json!({"name":"fixture","argv":[],"env":{"HOME":"/host"}}),
      json!({"name":"fixture","argv":[],"cwd":"/host"}),
      json!({"name":"fixture","argv":["bad\u{0}argument"]}),
    ] {
      let file = payload::seal(&serde_json::to_vec(&json).unwrap(), MAX_REQUEST).unwrap();
      assert!(
        Request::decode(Packet {
          bytes: TAG.to_vec(),
          fds: vec![file.into()]
        })
        .is_err()
      );
    }
    let unsealed = payload::create().unwrap();
    assert!(
      Request::decode(Packet {
        bytes: TAG.to_vec(),
        fds: vec![unsealed.into()]
      })
      .is_err()
    );
    assert!(
      Request::decode(Packet {
        bytes: TAG.to_vec(),
        fds: vec![]
      })
      .is_err()
    );
    let stdout: Vec<u8> = (0..131072).map(|i| (i % 256) as u8).collect();
    let file = response(Output {
      status: std::process::ExitStatus::from_raw(7 << 8),
      stdout: stdout.clone(),
      stderr: b"err\0\xff".to_vec(),
    })
    .unwrap();
    a.send(TAG, &[file.as_fd()]).unwrap();
    let output = receive(&b).unwrap();
    assert_eq!(output.status.code(), Some(7));
    assert_eq!(output.stdout, stdout);
    assert_eq!(output.stderr, b"err\0\xff");
    for status in [Status::Busy, Status::RateLimited] {
      crate::operation::reply(&a, status).unwrap();
      assert_eq!(receive(&b).unwrap_err().kind(), io::ErrorKind::WouldBlock);
    }
    crate::operation::reply(&a, Status::Failed).unwrap();
    assert_ne!(receive(&b).unwrap_err().kind(), io::ErrorKind::WouldBlock);
  }
}
