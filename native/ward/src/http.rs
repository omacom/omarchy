//! Named HTTP scopes. The host owns TLS and every request; a worker never gets
//! a network tunnel, cookie jar, ambient proxy, or credential-bearing headers.
use crate::{
  channel::{Channel, Packet},
  grants::{invalid, validate_id},
  payload,
};
use serde::{Deserialize, Serialize};
use serde_json::Value;
use std::{
  collections::{BTreeMap, BTreeSet},
  fs::File,
  io::{self, Read, Write},
  net::IpAddr,
  os::{fd::AsFd, unix::process::CommandExt},
  path::Path,
  process::{Child, Command, Stdio},
  time::{Duration, Instant},
};
use ureq::unversioned::{
  resolver::{DefaultResolver, ResolvedSocketAddrs, Resolver},
  transport::{DefaultConnector, NextTimeout},
};
use url::Url;

pub(crate) const TAG: &[u8] = b"OPHTTP\x01";
const MAX_REQUEST: usize = 65536;
pub(crate) const MAX_RESPONSE: usize = 2 * 1024 * 1024 + 4096;
pub(crate) const TIMEOUT: Duration = Duration::from_secs(10);

#[derive(Clone, Debug, Deserialize, Serialize, PartialEq, Eq)]
#[serde(deny_unknown_fields)]
pub struct Ask {
  pub scope: Scope,
  #[serde(default)]
  pub required: bool,
}

#[derive(Clone, Debug, Deserialize, Serialize, PartialEq, Eq)]
#[serde(deny_unknown_fields)]
pub struct Scope {
  pub origin: String,
  pub method: Method,
  /// A '*' is exactly one nonempty segment, not a glob or regular expression.
  pub path: String,
  /// A subtree must end in '/', cannot contain '*', and includes that root.
  #[serde(default)]
  pub subtree: bool,
  #[serde(default)]
  pub query: BTreeMap<String, QueryField>,
  /// None permits no body. JSON objects have exactly these fields.
  #[serde(default)]
  pub body: Option<BTreeMap<String, Field>>,
}

#[derive(Clone, Copy, Debug, Deserialize, Serialize, PartialEq, Eq)]
#[serde(rename_all = "UPPERCASE")]
pub enum Method {
  Get,
  Head,
  Post,
  Put,
  Patch,
  Delete,
  Options,
}

impl Method {
  fn name(self) -> &'static str {
    match self {
      Self::Get => "GET",
      Self::Head => "HEAD",
      Self::Post => "POST",
      Self::Put => "PUT",
      Self::Patch => "PATCH",
      Self::Delete => "DELETE",
      Self::Options => "OPTIONS",
    }
  }
}

#[derive(Clone, Debug, Deserialize, Serialize, PartialEq, Eq)]
#[serde(deny_unknown_fields)]
pub struct QueryField {
  #[serde(default)]
  pub required: bool,
  pub value: Field,
}

#[derive(Clone, Debug, Deserialize, Serialize, PartialEq, Eq)]
#[serde(tag = "kind", rename_all = "camelCase", deny_unknown_fields)]
pub enum Field {
  Exact { value: Value },
  String { max: usize },
  NullableString { max: usize },
  Object { fields: BTreeMap<String, Field> },
}

#[derive(Debug, Deserialize, Serialize)]
#[serde(deny_unknown_fields)]
pub struct Request {
  pub scope: String,
  pub method: Method,
  pub url: String,
  #[serde(default)]
  pub body: Option<Value>,
}

#[derive(Debug, Deserialize, Serialize)]
#[serde(deny_unknown_fields)]
pub struct ResponseHead {
  pub status: u16,
  pub headers: BTreeMap<String, String>,
}

impl Field {
  fn validate(&self, depth: usize) -> io::Result<()> {
    if depth > 4 {
      return Err(invalid("HTTP JSON scope is too deeply nested"));
    }
    match self {
      Self::Exact { value } if serde_json::to_vec(value)?.len() <= MAX_REQUEST => Ok(()),
      Self::String { max } | Self::NullableString { max } if *max <= MAX_REQUEST => Ok(()),
      Self::Object { fields } => validate_fields(fields, depth + 1),
      _ => Err(invalid("HTTP field exceeds the request bound")),
    }
  }
  fn accepts(&self, value: &Value) -> bool {
    match self {
      Self::Exact { value: expected } => expected == value,
      Self::String { max } => value.as_str().is_some_and(|v| v.len() <= *max),
      Self::NullableString { max } => {
        value.is_null() || value.as_str().is_some_and(|v| v.len() <= *max)
      }
      Self::Object { fields } => object_accepts(fields, value),
    }
  }
}

fn validate_fields(fields: &BTreeMap<String, Field>, depth: usize) -> io::Result<()> {
  if fields.len() > 256 {
    return Err(invalid("too many HTTP JSON fields"));
  }
  for (key, field) in fields {
    validate_id(key)?;
    field.validate(depth)?;
  }
  Ok(())
}

fn object_accepts(fields: &BTreeMap<String, Field>, value: &Value) -> bool {
  value.as_object().is_some_and(|object| {
    object.len() == fields.len()
      && object
        .iter()
        .all(|(key, value)| fields.get(key).is_some_and(|field| field.accepts(value)))
  })
}

fn parse_url(value: &str) -> io::Result<Url> {
  let url = Url::parse(value).map_err(|_| invalid("invalid HTTP URL"))?;
  // Reject ambiguous normalization rather than letting two parsers disagree.
  // Encoded path support is explicitly unavailable in this preview. Query
  // values can be encoded; matching below uses decoded names and values.
  if value.len() > 4096
    || url.as_str() != value
    || !matches!(url.scheme(), "http" | "https")
    || url.host_str().is_none()
    || !url.username().is_empty()
    || url.password().is_some()
    || url.fragment().is_some()
    || value
      .chars()
      .any(|c| c.is_control() || c.is_whitespace() || c == '\\')
    || url.path().contains(['%', ';'])
    || url.path().contains("//")
  {
    return Err(invalid(
      "HTTP requires an unambiguous canonical URL without credentials or fragments",
    ));
  }
  Ok(url)
}

impl Scope {
  pub fn validate(&self) -> io::Result<()> {
    let origin = parse_url(&format!("{}/", self.origin))?;
    if origin.origin().ascii_serialization() != self.origin
      || !self.path.starts_with('/')
      || self.path.len() > 2048
      || self.path.split('/').any(|s| s.contains('*') && s != "*")
      || self.subtree && (!self.path.ends_with('/') || self.path.contains('*'))
      || self.query.len() > 64
      || matches!(self.method, Method::Get | Method::Head) && self.body.is_some()
    {
      return Err(invalid("invalid HTTP scope"));
    }
    let path = self.path.replace('*', "segment");
    if parse_url(&format!("{}{path}", self.origin))?.path() != path {
      return Err(invalid("invalid HTTP path scope"));
    }
    for (key, field) in &self.query {
      validate_id(key)?;
      if !matches!(
        field.value,
        Field::String { .. }
          | Field::Exact {
            value: Value::String(_)
          }
      ) {
        return Err(invalid("query constraints must accept string values"));
      }
      field.value.validate(0)?;
    }
    if let Some(fields) = &self.body {
      validate_fields(fields, 0)?;
    }
    Ok(())
  }

  fn check(&self, request: &Request) -> io::Result<Url> {
    self.validate()?;
    request.validate()?;
    let url = parse_url(&request.url)?;
    let actual: Vec<_> = url.path().split('/').collect();
    let selected: Vec<_> = self.path.split('/').collect();
    let path_matches = if self.subtree {
      url.path().starts_with(&self.path)
    } else {
      actual.len() == selected.len()
        && selected.iter().zip(&actual).all(|(expected, actual)| {
          *expected == *actual || (*expected == "*" && !actual.is_empty())
        })
    };
    if url.origin().ascii_serialization() != self.origin
      || request.method != self.method
      || !path_matches
    {
      return Err(invalid(
        "HTTP request exceeds the selected origin, method or path",
      ));
    }
    let mut seen = BTreeSet::new();
    for (key, value) in url.query_pairs() {
      if !seen.insert(key.to_string())
        || !self
          .query
          .get(key.as_ref())
          .is_some_and(|field| field.value.accepts(&Value::String(value.into_owned())))
      {
        return Err(invalid("HTTP query exceeds the selected fields"));
      }
    }
    if self
      .query
      .iter()
      .any(|(key, field)| field.required && !seen.contains(key))
    {
      return Err(invalid("HTTP request omits a required query restriction"));
    }
    match (&self.body, &request.body) {
      (None, None) => (),
      (Some(fields), Some(body)) if object_accepts(fields, body) => (),
      _ => return Err(invalid("HTTP body exceeds the selected fields")),
    }
    Ok(url)
  }
}

impl Request {
  fn validate(&self) -> io::Result<()> {
    validate_id(&self.scope)?;
    if serde_json::to_vec(self)?.len() > MAX_REQUEST {
      return Err(invalid("HTTP request exceeds 64 KiB"));
    }
    parse_url(&self.url)?;
    Ok(())
  }
  pub(crate) fn decode(mut packet: Packet) -> io::Result<Self> {
    if packet.bytes != TAG || packet.fds.len() != 1 {
      return Err(invalid("invalid HTTP record"));
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
  pub(crate) fn spawn(
    &self,
    executable: &Path,
    grants: &BTreeMap<String, Scope>,
  ) -> io::Result<(Child, File)> {
    let scope = grants
      .get(&self.scope)
      .ok_or_else(|| crate::operation::Status::Denied.error())?;
    scope
      .check(self)
      .map_err(|_| crate::operation::Status::Denied.error())?;
    let input = payload::seal(&serde_json::to_vec(&(scope, self))?, MAX_REQUEST * 2)?;
    // seal() leaves the file offset at EOF; stdin starts from its beginning.
    use std::io::{Seek, SeekFrom};
    let mut input = input;
    input.seek(SeekFrom::Start(0))?;
    let output = payload::create()?;
    let mut command = Command::new(executable);
    command
      .arg("--http-execute")
      .env_clear()
      .stdin(input)
      .stdout(output.try_clone()?)
      .stderr(Stdio::null());
    unsafe {
      command.pre_exec(|| {
        let limit = libc::rlimit {
          rlim_cur: MAX_RESPONSE as _,
          rlim_max: MAX_RESPONSE as _,
        };
        if libc::setrlimit(libc::RLIMIT_FSIZE, &limit) != 0 {
          return Err(io::Error::last_os_error());
        }
        Ok(())
      });
    }
    Ok((command.spawn()?, output))
  }
}

#[derive(Debug)]
struct AddressPolicy {
  literal: Option<IpAddr>,
}

// Deliberately conservative address classes, not a claim of Internet
// reachability. Exact IP origins can explicitly select a local API.
pub(crate) fn public(ip: IpAddr) -> bool {
  match ip {
    IpAddr::V4(v) => {
      let [a, b, _, _] = v.octets();
      !(a == 0
        || a == 10
        || a == 127
        || a >= 224
        || (a == 100 && (64..=127).contains(&b))
        || (a == 169 && b == 254)
        || (a == 172 && (16..=31).contains(&b))
        || (a == 192 && (b == 0 || b == 168))
        || (a == 198 && (b == 18 || b == 19))
        || v.is_documentation()
        || v.is_broadcast())
    }
    IpAddr::V6(v) => {
      let s = v.segments();
      (s[0] & 0xe000) == 0x2000
        && !(s[0] == 0x2001 && s[1] <= 0x01ff)
        && !(s[0] == 0x2001 && s[1] == 0x0db8)
        && s[0] != 0x2002
        && !(s[0] == 0x3fff && (s[1] & 0xf000) == 0)
    }
  }
}

impl Resolver for AddressPolicy {
  fn resolve(
    &self,
    uri: &ureq::http::Uri,
    config: &ureq::config::Config,
    timeout: NextTimeout,
  ) -> Result<ResolvedSocketAddrs, ureq::Error> {
    let addresses = DefaultResolver::default().resolve(uri, config, timeout)?;
    if addresses
      .iter()
      .any(|a| self.literal != Some(a.ip()) && !public(a.ip()))
    {
      return Err(ureq::Error::HostNotFound);
    }
    Ok(addresses)
  }
}

/// Fixed native helper, run in the controller's owned unit. Process teardown
/// bounds even stalled DNS threads; no worker-controlled command or environment.
pub fn execute() -> io::Result<()> {
  let mut input = Vec::new();
  io::stdin()
    .take((MAX_REQUEST * 2 + 1) as u64)
    .read_to_end(&mut input)?;
  if input.len() > MAX_REQUEST * 2 {
    return Err(invalid("HTTP job exceeds its limit"));
  }
  let (scope, request): (Scope, Request) = serde_json::from_slice(&input)?;
  let url = scope.check(&request)?;
  let config = ureq::Agent::config_builder()
    .proxy(None)
    .max_redirects(0)
    .max_redirects_will_error(false)
    .http_status_as_error(false)
    .max_response_header_size(16384)
    .timeout_global(Some(TIMEOUT - Duration::from_secs(1)))
    .build();
  let agent = ureq::Agent::with_parts(
    config,
    DefaultConnector::default(),
    AddressPolicy {
      literal: url
        .host_str()
        .and_then(|host| host.trim_matches(['[', ']']).parse().ok()),
    },
  );
  let body = request
    .body
    .as_ref()
    .map(serde_json::to_vec)
    .transpose()?
    .unwrap_or_default();
  let mut outgoing = ureq::http::Request::builder()
    .method(request.method.name())
    .uri(url.as_str())
    .header("User-Agent", "omarchy-ward")
    .header("Accept", "application/json");
  if request.body.is_some() {
    outgoing = outgoing.header("Content-Type", "application/json");
  }
  let mut response = agent
    .run(
      outgoing
        .body(body)
        .map_err(|_| invalid("invalid HTTP request"))?,
    )
    .map_err(|_| io::Error::other("HTTP transport failed"))?;
  let head = ResponseHead {
    status: response.status().as_u16(),
    headers: [
      "link",
      "retry-after",
      "content-type",
      "location",
      "x-ratelimit-remaining",
      "x-ratelimit-reset",
    ]
    .iter()
    .filter_map(|name| {
      response
        .headers()
        .get(*name)
        .and_then(|v| v.to_str().ok())
        .map(|v| (name.to_string(), v.to_string()))
    })
    .collect(),
  };
  let head = serde_json::to_vec(&head)?;
  if head.len() > 4092 {
    return Err(invalid("HTTP response metadata exceeds 4 KiB"));
  }
  let mut body = Vec::new();
  response
    .body_mut()
    .as_reader()
    .take((MAX_RESPONSE - 4096 + 1) as u64)
    .read_to_end(&mut body)?;
  if body.len() > MAX_RESPONSE - 4096 {
    return Err(invalid("HTTP response exceeds 2 MiB"));
  }
  let mut output = io::stdout().lock();
  output.write_all(&(head.len() as u32).to_le_bytes())?;
  output.write_all(&head)?;
  output.write_all(&body)
}

pub fn receive(channel: &Channel) -> io::Result<(ResponseHead, Vec<u8>)> {
  let deadline = Instant::now() + TIMEOUT + Duration::from_secs(2);
  loop {
    match channel.receive() {
      Ok(mut packet) if packet.bytes == TAG && packet.fds.len() == 1 => {
        let bytes = payload::read(packet.fds.remove(0), MAX_RESPONSE)?;
        if bytes.len() < 4 {
          return Err(invalid("invalid HTTP response"));
        }
        let length = u32::from_le_bytes(bytes[..4].try_into().unwrap()) as usize;
        if length > 4092 || bytes.len() < length + 4 {
          return Err(invalid("invalid HTTP response metadata"));
        }
        let head = serde_json::from_slice(&bytes[4..length + 4])?;
        return Ok((head, bytes[length + 4..].to_vec()));
      }
      Ok(packet) => {
        let status = crate::operation::decode(packet)?;
        return Err(
          if status == crate::operation::Status::Completed {
            crate::operation::Status::Unavailable
          } else {
            status
          }
          .error(),
        );
      }
      Err(error) if error.kind() == io::ErrorKind::WouldBlock && Instant::now() < deadline => {
        std::thread::sleep(Duration::from_millis(5))
      }
      Err(error) if error.kind() == io::ErrorKind::WouldBlock => {
        return Err(crate::operation::Status::TimedOut.error());
      }
      Err(_) => return Err(crate::operation::Status::Unavailable.error()),
    }
  }
}

/// Worker CLI: one bounded JSON request on stdin, with a typed response for
/// either raw or structured presentation by the caller.
pub fn request() -> io::Result<(ResponseHead, Vec<u8>)> {
  let mut input = Vec::new();
  io::stdin()
    .take((MAX_REQUEST + 1) as u64)
    .read_to_end(&mut input)?;
  if input.len() > MAX_REQUEST {
    return Err(crate::operation::Status::Invalid.error());
  }
  let request: Request =
    serde_json::from_slice(&input).map_err(|_| crate::operation::Status::Invalid.error())?;
  request
    .validate()
    .map_err(|_| crate::operation::Status::Invalid.error())?;
  let channel = crate::operation::connect(crate::requests::Kind::Http)?;
  request.send(&channel)?;
  receive(&channel)
}

#[cfg(test)]
mod tests {
  use super::*;
  use crate::grants::{Grants, Requests};
  use serde_json::json;

  fn scope() -> Scope {
    serde_json::from_value(json!({
      "origin": "https://api.example.test", "method": "GET", "path": "/groups/*/*/jobs",
      "query": {
        "status": {"required": true, "value": {"kind": "exact", "value": "in_progress"}},
        "page": {"value": {"kind": "string", "max": 8}}
      }
    }))
    .unwrap()
  }

  #[test]
  fn unknown_account_authority_is_rejected_not_ignored() {
    assert!(serde_json::from_value::<Requests>(json!({"accounts": {}})).is_err());
    assert!(serde_json::from_value::<Grants>(json!({"accounts": {}})).is_err());
    let mut value = serde_json::to_value(scope()).unwrap();
    value["account"] = json!("unrecognized");
    assert!(serde_json::from_value::<Scope>(value).is_err());
  }
  fn request(url: &str) -> Request {
    Request {
      scope: "actions".into(),
      method: Method::Get,
      url: url.into(),
      body: None,
    }
  }

  #[test]
  fn http_grants_are_exact_reviewed_selections_not_network_authority() {
    let mut requests = Requests::default();
    requests.network.asked = true;
    requests.http.insert(
      "actions".into(),
      Ask {
        scope: scope(),
        required: true,
      },
    );
    let mut grants = Grants::default();
    grants.validate(&requests).unwrap();
    assert_eq!(grants.required_gap(&requests), ["http:actions"]);
    grants.http.insert("actions".into(), scope());
    grants.validate(&requests).unwrap();
    assert!(grants.required_gap(&requests).is_empty());
    assert!(!grants.network);
    grants.network = true;
    assert!(grants.validate(&requests).is_err());
    grants.network = false;
    grants.http.get_mut("actions").unwrap().query.clear();
    assert!(grants.validate(&requests).is_err());
    assert_eq!(grants.required_gap(&requests), ["http:actions"]);
    assert!(serde_json::from_str::<Requests>(r#"{"http":true}"#).is_err());
    assert!(serde_json::from_str::<Grants>(r#"{"http":["actions"]}"#).is_err());
  }

  #[test]
  fn methods_origins_paths_and_required_query_filters_cannot_be_widened() {
    let good = "https://api.example.test/groups/team/project/jobs?status=in_progress&page=2";
    let selected = scope();
    selected.check(&request(good)).unwrap();
    selected
      .check(&request(&good.replace("&page=2", "")))
      .unwrap();
    for bad in [
      good.replace("api.example.test", "api.example.test.evil.test"),
      good.replace("api.example.test", "api.example.test:444"),
      good.replace("api.example.test", "user@api.example.test"),
      good.replace("https:", "http:"),
      good.replace("/jobs", "/contents/secret"),
      good.replace("/team/project", "/team/nested/project"),
      good.replace("/team/project", "/team//project"),
      good.replace("/team/project", "/team/../project"),
      good.replace("/team/project", "/team/%2e%2e/project"),
      good.replace("/team/project", "/team/%252e%252e/project"),
      good.replace("/team/project", "/team%2fproject"),
      good.replace("/team/project", "/team\\project"),
      good.replace("in_progress", "completed"),
      good.replace("status=in_progress&", ""),
      format!("{good}&status=completed"),
      format!("{good}&%73tatus=in_progress"),
      format!("{good}&access_token=secret"),
      format!("{good}#fragment"),
      format!(" {good}"),
    ] {
      assert!(selected.check(&request(&bad)).is_err(), "accepted {bad}");
    }
    let mut bad = request(good);
    bad.method = Method::Post;
    assert!(selected.check(&bad).is_err());
    bad.method = Method::Get;
    bad.body = Some(json!({}));
    assert!(selected.check(&bad).is_err());
    let subtree: Scope = serde_json::from_value(
      json!({"origin":"https://example.test", "method":"GET", "path":"/allowed/", "subtree":true}),
    )
    .unwrap();
    subtree
      .check(&request("https://example.test/allowed/deep/file"))
      .unwrap();
    assert!(
      subtree
        .check(&request("https://example.test/allowed-sibling/file"))
        .is_err()
    );
    for path in ["/allowed", "/allowed/*/"] {
      let mut bad = subtree.clone();
      bad.path = path.into();
      assert!(bad.validate().is_err());
    }
  }

  #[test]
  fn exact_graphql_documents_cannot_be_replaced_appended_or_batched() {
    let query = "query($cursor:String) { catalog { records(first:100,after:$cursor) { pageInfo { hasNextPage endCursor } } } }";
    let selected: Scope = serde_json::from_value(json!({
      "origin":"https://api.example.test", "method":"POST", "path":"/graphql",
      "body": {"query":{"kind":"exact", "value":query}, "variables":{"kind":"object", "fields":{
        "cursor":{"kind":"nullableString", "max":1024}
      }}}
    }))
    .unwrap();
    let mut req = Request {
      scope: "records".into(),
      method: Method::Post,
      url: "https://api.example.test/graphql".into(),
      body: Some(json!({"query":query,"variables":{"cursor":null}})),
    };
    selected.check(&req).unwrap();
    req.body.as_mut().unwrap()["variables"]["cursor"] = json!("next-page");
    selected.check(&req).unwrap();
    let original = req.body.clone();
    for doc in [
      "mutation { deleteRecord(input:{recordId:\"x\"}) { clientMutationId } }".into(),
      format!("{query} mutation Evil {{ clearLabels {{ clientMutationId }} }}"),
      query.replace("first:100", "first:50"),
    ] {
      req.body.as_mut().unwrap()["query"] = json!(doc);
      assert!(selected.check(&req).is_err());
      req.body = original.clone();
    }
    req.body.as_mut().unwrap()["operationName"] = json!("Evil");
    assert!(selected.check(&req).is_err());
    req.body = original;
    req.body.as_mut().unwrap()["variables"]["extra"] = json!(true);
    assert!(selected.check(&req).is_err());
    req.body = Some(json!([{"query":query}]));
    assert!(selected.check(&req).is_err());
  }

  #[test]
  fn http_requests_require_bounded_immutable_descriptors() {
    let mut request =
      request("https://api.example.test/groups/team/project/jobs?status=in_progress");
    let (a, b) = Channel::pair().unwrap();
    request.send(&a).unwrap();
    assert_eq!(
      Request::decode(b.receive().unwrap()).unwrap().scope,
      "actions"
    );
    a.send(TAG, &[File::open("/dev/null").unwrap().as_fd()])
      .unwrap();
    assert!(Request::decode(b.receive().unwrap()).is_err());
    let mutable = payload::create().unwrap();
    a.send(TAG, &[mutable.as_fd()]).unwrap();
    assert!(Request::decode(b.receive().unwrap()).is_err());
    a.send(TAG, &[]).unwrap();
    assert!(Request::decode(b.receive().unwrap()).is_err());
    let extra = payload::seal(b"{}", 2).unwrap();
    a.send(TAG, &[extra.as_fd(), extra.as_fd()]).unwrap();
    assert!(Request::decode(b.receive().unwrap()).is_err());
    request.body = Some(json!("x".repeat(MAX_REQUEST)));
    assert!(request.send(&a).is_err());
    assert_eq!(b.receive().unwrap_err().kind(), io::ErrorKind::WouldBlock);
  }
}
