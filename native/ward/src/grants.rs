use serde::{
  Deserialize, Deserializer, Serialize, Serializer,
  de::{Error, MapAccess, Visitor},
  ser::SerializeStruct,
};
use std::{
  collections::{BTreeMap, BTreeSet},
  fmt,
  fs::{File, OpenOptions},
  io::{self, Read},
  os::{
    fd::AsRawFd,
    unix::fs::{MetadataExt, OpenOptionsExt},
  },
  path::{Component, Path, PathBuf},
};

/// Upper bound on granted host directories. Two independent constraints bound
/// the count, and the *lower* one wins:
///
/// - **Descriptors**: bubblewrap consumes one descriptor per granted directory
///   while passing mounts, and the controller unit inheriting them runs under
///   `LimitNOFILE=512` ([`crate::supervisor::Unit::launch`]) plus a small base
///   footprint (stdio, control channel, bundle/bootstrap/wayland/runtime/
///   context, mediated sockets). That alone would allow hundreds.
/// - **Persisted record**: the approval record (grant details, named
///   dev+inode pins) is written to disk and later re-read through [`read_json`],
///   which caps a file at [`MAX_PERSISTED_BYTES`] (64 KiB) to keep reviving
///   hostile on-disk data bounded. With maximum legal slot names (96 chars) and
///   a realistic path, each grant serializes to roughly 220 bytes, so 256
///   grants stay under 64 KiB including record overhead (measured ~57 KiB in
///   [`tests`]). The transport budget is not binding: each grant is two short
///   bubblewrap arguments (`--ro-bind-fd <fd> /grants/<name>`, ~40 bytes), so
///   256 grants are a few KiB of argv, far below `MAX_ARG_STRLEN`/`ARG_MAX`.
///
/// The persisted-record size is the concrete binding constraint, and it is
/// imposed twice: the approval is preflighted (serialized and capped) in
/// [`crate::store::Store::approve`] *before* any durable pending marker is
/// created, and again in `finish`, so an over-limit approval is rejected
/// without touching or poisoning the prior usable approval.
pub const MAX_GRANTED_DIRS: usize = 256;

/// Persisted configuration files (manifests and approval records) are bounded
/// so reviving hostile on-disk data stays cheap and never exhausts memory or
/// a single bounded read.
pub const MAX_PERSISTED_BYTES: usize = 65536;

/// One atomic capability ask in a plugin manifest. A boolean (for example
/// `storage: true`) means **optional**: if the approving user declines it the
/// plugin still starts with reduced access. Mandatory access must be
/// declared explicitly, for example `storage: { "required": true }`; a bare
/// `true` never becomes a required grant and `false` means not requested.
#[derive(Clone, Copy, Debug, Default, PartialEq, Eq)]
pub struct Request {
  pub asked: bool,
  pub required: bool,
}

impl Request {
  pub fn asked(self) -> bool {
    self.asked
  }
}

impl<'de> Deserialize<'de> for Request {
  fn deserialize<D>(deserializer: D) -> Result<Self, D::Error>
  where
    D: Deserializer<'de>,
  {
    struct RequestVisitor;
    impl<'de> Visitor<'de> for RequestVisitor {
      type Value = Request;
      fn expecting(&self, formatter: &mut fmt::Formatter<'_>) -> fmt::Result {
        formatter.write_str("a boolean, or an object with a required flag")
      }
      fn visit_bool<E>(self, value: bool) -> Result<Request, E> {
        Ok(Request {
          asked: value,
          required: false,
        })
      }
      fn visit_map<A>(self, mut map: A) -> Result<Request, A::Error>
      where
        A: MapAccess<'de>,
      {
        let mut required: Option<bool> = None;
        while let Some(key) = map.next_key::<String>()? {
          match key.as_str() {
            "required" => {
              if required.replace(map.next_value()?).is_some() {
                return Err(A::Error::duplicate_field("required"));
              }
            }
            _ => return Err(A::Error::unknown_field(&key, &["required"])),
          }
        }
        Ok(Request {
          asked: true,
          required: required.unwrap_or(false),
        })
      }
    }
    deserializer.deserialize_any(RequestVisitor)
  }
}

impl Serialize for Request {
  fn serialize<S>(&self, serializer: S) -> Result<S::Ok, S::Error>
  where
    S: Serializer,
  {
    match (self.asked, self.required) {
      // Booleans express optional atomic access; requiredness is explicit.
      (false, _) => serializer.serialize_bool(false),
      (true, false) => serializer.serialize_bool(true),
      (true, true) => {
        let mut state = serializer.serialize_struct("Request", 1)?;
        state.serialize_field("required", &self.required)?;
        state.end()
      }
    }
  }
}

/// One named filesystem request with explicit access and requiredness.
#[derive(Clone, Debug, Deserialize, Serialize, PartialEq, Eq)]
#[serde(deny_unknown_fields)]
pub struct FileSystemRequest {
  pub name: String,
  pub path: String,
  #[serde(default = "directory_target")]
  pub target: Target,
  #[serde(default)]
  pub access: Access,
  #[serde(default)]
  pub required: bool,
}

impl FileSystemRequest {
  pub fn optional(name: impl Into<String>, path: impl Into<String>) -> Self {
    Self {
      name: name.into(),
      path: path.into(),
      target: Target::Directory,
      access: Access::Read,
      required: false,
    }
  }
  pub fn required(name: impl Into<String>, path: impl Into<String>) -> Self {
    Self {
      name: name.into(),
      path: path.into(),
      target: Target::Directory,
      access: Access::Read,
      required: true,
    }
  }
  pub fn write(name: impl Into<String>, path: impl Into<String>, required: bool) -> Self {
    Self {
      name: name.into(),
      path: path.into(),
      target: Target::Directory,
      access: Access::ReadWrite,
      required,
    }
  }

  pub fn resolved_path(&self) -> io::Result<PathBuf> {
    requested_path(&self.path, |key| std::env::var_os(key).map(PathBuf::from))
  }
}

fn directory_target() -> Target { Target::Directory }

fn requested_path(value: &str, environment: impl Fn(&str) -> Option<PathBuf>) -> io::Result<PathBuf> {
  if value.is_empty() || value.len() > 4096 || value.chars().any(char::is_control) {
    return Err(invalid("filesystem request must declare a bounded path"));
  }
  let (root, relative) = if let Some(token) = value.strip_prefix('$') {
    let (name, relative) = token.split_once('/').ok_or_else(|| invalid("filesystem path token requires a relative path"))?;
    let suffix = match name {
      "HOME" => "",
      "XDG_CONFIG_HOME" => ".config",
      "XDG_DATA_HOME" => ".local/share",
      "XDG_STATE_HOME" => ".local/state",
      "XDG_CACHE_HOME" => ".cache",
      _ => return Err(invalid("unsupported filesystem path token")),
    };
    let root = environment(name).filter(|path| !path.as_os_str().is_empty())
      .or_else(|| environment("HOME").map(|home| home.join(suffix)))
      .ok_or_else(|| invalid("host home directory is unavailable"))?;
    if !safe_absolute(&root) { return Err(invalid("host filesystem path root must be absolute")); }
    (root, relative)
  } else {
    (PathBuf::from("/"), value.strip_prefix('/').ok_or_else(|| invalid("filesystem request must declare an absolute path or supported home token"))?)
  };
  if relative.split('/').any(|part| part.is_empty() || part == "." || part == ".." || part.contains('$')) {
    return Err(invalid("filesystem request path must be normalized"));
  }
  Ok(root.join(relative))
}

#[derive(Clone, Debug, Default, Deserialize, Serialize, PartialEq, Eq)]
#[serde(default, deny_unknown_fields)]
pub struct Requests {
  pub filesystem: Vec<FileSystemRequest>,
  pub network: Request,
  #[serde(rename = "networkProxy")]
  pub network_proxy: Request,
  pub http: BTreeMap<String, crate::http::Ask>,
  pub exec: BTreeMap<String, crate::exec::Ask>,
  pub media: Option<MediaRequest>,
  pub notifications: Request,
  #[serde(rename = "audioPlayback")]
  pub audio_playback: Request,
  pub microphone: Request,
  #[serde(rename = "audioCapture")]
  pub audio_capture: Request,
  pub settings: crate::settings::Ask,
  #[serde(rename = "openUrls")]
  pub open_urls: Request,
  pub storage: Request,
  #[serde(rename = "desktopGeometry")]
  pub desktop_geometry: Request,
}

#[derive(Clone, Debug, Deserialize, Serialize, PartialEq, Eq)]
#[serde(deny_unknown_fields)]
pub struct MediaRequest {
  pub service: String,
  #[serde(default)]
  pub required: bool,
}

#[derive(Clone, Debug, Default, Deserialize, Serialize, PartialEq, Eq)]
#[serde(default, deny_unknown_fields)]
pub struct Grants {
  pub filesystem: BTreeMap<String, FileSystemGrant>,
  pub network: bool,
  #[serde(rename = "networkProxy", skip_serializing_if = "is_false")]
  pub network_proxy: bool,
  pub http: BTreeMap<String, crate::http::Scope>,
  pub exec: BTreeMap<String, crate::exec::Grant>,
  pub media: Option<String>,
  pub notifications: bool,
  // Omit new denied fields to preserve the bytes signed by older releases.
  #[serde(rename = "audioPlayback", skip_serializing_if = "is_false")]
  pub audio_playback: bool,
  #[serde(skip_serializing_if = "is_false")]
  pub microphone: bool,
  #[serde(rename = "audioCapture", skip_serializing_if = "is_false")]
  pub audio_capture: bool,
  pub settings: crate::settings::Grant,
  #[serde(rename = "openUrls")]
  pub open_urls: bool,
  pub storage: bool,
  #[serde(rename = "desktopGeometry")]
  pub desktop_geometry: bool,
}

fn is_false(value: &bool) -> bool {
  !*value
}

/// How much of the selected host directory the plugin may change. A filesystem
/// bind exposes reads as well, so a writable grant is inherently **read-write**;
/// a write-only, read-excluded grant is not enforceable with a bind and is
/// rejected at admission as `Unsupported` rather than silently over-broadened.
#[derive(Clone, Copy, Debug, Default, PartialEq, Eq, Deserialize, Serialize)]
#[serde(rename_all = "lowercase")]
#[allow(clippy::upper_case_acronyms)]
pub enum Access {
  #[default]
  Read,
  Write,
  ReadWrite,
}

impl Access {
  /// A bind exposes the subtree with the requested write permission; there is
  /// no write-only subset.
  pub fn writable(self) -> bool {
    matches!(self, Access::ReadWrite)
  }
}

/// What the grant points at. A **file** is an exact single-file target and is
/// bind-mounted as a file (`--ro-bind-fd`/`--bind-fd`), exposing precisely that
/// file and nothing beside it. A **directory** is the whole subtree and is
/// bind-mounted recursively; a bind always exposes the tree, so there is no
/// non-recursive directory target that is enforceable, and exactness for
/// directories is not claimed.
#[derive(Clone, Copy, Debug, Default, PartialEq, Eq, Deserialize, Serialize)]
#[serde(rename_all = "lowercase")]
pub enum Target {
  #[default]
  File,
  Directory,
}

/// User approval pins the declared host entry's identity, access and target.
#[derive(Clone, Debug, Deserialize, Serialize, PartialEq, Eq)]
#[serde(deny_unknown_fields)]
pub struct FileSystemGrant {
  pub path: PathBuf,
  pub device: u64,
  pub inode: u64,
  pub access: Access,
  pub target: Target,
}

impl FileSystemGrant {
  pub fn select(path: &Path, access: Access, target: Target) -> io::Result<Self> {
    if access == Access::Write {
      return Err(io::Error::new(
        io::ErrorKind::Unsupported,
        "write-only host entries are unsupported: a bind also exposes reads",
      ));
    }
    let path = path.canonicalize()?;
    reject_unsafe_roots(&path)?;
    let file = match target {
      Target::File => open_regular_file(&path)?,
      Target::Directory => open_directory(&path)?,
    };
    let metadata = file.metadata()?;
    Ok(Self {
      path,
      device: metadata.dev(),
      inode: metadata.ino(),
      access,
      target,
    })
  }

  pub fn open(&self) -> io::Result<File> {
    // Admission is authorization-independent: a grant that was constructed or
    // deserialized with an unsupported write-only access must be refused here,
    // not only at select(), because open() runs again at approval and at
    // activation where the record is read back from disk.
    if self.access == Access::Write {
      return Err(io::Error::new(
        io::ErrorKind::Unsupported,
        "write-only host entries are unsupported: a bind also exposes reads",
      ));
    }
    reject_unsafe_roots(&self.path)?;
    let file = match self.target {
      Target::File => open_regular_file(&self.path)?,
      Target::Directory => open_directory(&self.path)?,
    };
    let metadata = file.metadata()?;
    if metadata.dev() != self.device || metadata.ino() != self.inode {
      return Err(invalid("approved grant was replaced"));
    }
    Ok(file)
  }
}

/// Refuse device, IPC, pseudo-filesystem and whole-tree roots that a directory
/// bind would otherwise expose or that would break isolation regardless of the
/// approving user's intent. Specific directories under these roots (for example
/// a selected `~/Music` under `/home`) remain valid because the grant names a
/// concrete non-special directory.
fn reject_unsafe_roots(path: &Path) -> io::Result<()> {
  // The grant path is already canonicalized and absolute; refuse device and
  // kernel pseudo-filesystem roots that a bind would expose and that would
  // break isolation (a render-device grant is the coercive exception, always
  // via a DRM render node, never a whole /dev). A concrete directory under
  // these roots such as a selected `~/Music` is unaffected because it does not
  // start with a special root. `/run` and `/tmp` are deliberately *not* denied
  // here: the selected-directory mount lands at `/grants/<name>` (never
  // colliding with the sandbox's own /run//tmp mounts), and approving them is
  // an explicit user choice the reviewer describes as affecting real host data.
  if path == Path::new("/") || path.parent().is_none() {
    return Err(invalid(
      "directory grant must name a specific host directory",
    ));
  }
  for special in ["/dev", "/proc", "/sys"] {
    if path == Path::new(special) || path.starts_with(Path::new(special)) {
      return Err(invalid(
        "directory grant would expose a device or kernel tree; choose a specific data directory",
      ));
    }
  }
  Ok(())
}

#[derive(Clone, Debug, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Manifest {
  pub schema_version: u32,
  pub id: String,
  pub name: String,
  pub version: String,
  pub kinds: Vec<String>,
  pub entry_points: BTreeMap<String, String>,
  pub sandbox: SandboxManifest,
}

#[derive(Clone, Debug, Deserialize)]
#[serde(rename_all = "camelCase", deny_unknown_fields)]
pub struct SandboxManifest {
  pub version: u32,
  pub entry_point: Option<String>,
  pub requests: Requests,
}

impl Manifest {
  pub fn read(revision: &Path) -> io::Result<Self> {
    let manifest: Self = read_json(&revision.join("manifest.json"))?;
    validate_id(&manifest.id)?;
    if manifest.schema_version != 1
      || manifest.sandbox.version != 1
      || manifest.name.is_empty()
      || manifest.name.len() > 128
      || manifest.name.chars().any(char::is_control)
      || manifest.version.is_empty()
      || manifest.version.len() > 64
      || manifest.version.chars().any(char::is_control)
      || manifest.kinds.is_empty()
      || manifest.kinds.len() > 6
      || manifest.entry_points.len() > 6
    {
      return Err(invalid("invalid sandbox plugin manifest"));
    }
    for kind in &manifest.kinds {
      validate_id(kind)?;
    }
    for entry in manifest
      .entry_points
      .values()
      .chain(manifest.sandbox.entry_point.iter())
    {
      if !safe_relative(entry) || !revision.join(entry).is_file() {
        return Err(invalid(
          "entry point is not a file in the approved revision",
        ));
      }
    }
    if manifest.sandbox.entry_point.is_none() {
      let entries = manifest
        .kinds
        .iter()
        .map(|kind| match kind.as_str() {
          "bar-widget" => Ok("barWidget"),
          "service" => Ok("service"),
          "overlay" => Ok("overlay"),
          _ => Err(invalid(
            "shared worker does not support this plugin kind yet",
          )),
        })
        .collect::<io::Result<BTreeSet<_>>>()?;
      if !entries.contains("barWidget")
        || entries.len() != manifest.kinds.len()
        || entries.len() != manifest.entry_points.len()
        || !entries
          .iter()
          .all(|key| manifest.entry_points.contains_key(*key))
      {
        return Err(invalid(
          "shared worker requires matching bar-widget entry points",
        ));
      }
    }
    validate_requests(&manifest.sandbox.requests)?;
    Ok(manifest)
  }
}

impl Grants {
  /// Worker adaptation data, not the signed host authority record. Do not leak
  /// host filesystem paths/inodes or executable identities through this view.
  pub fn worker_view(&self) -> serde_json::Value {
    let mut view = serde_json::to_value(self).expect("grant serialization is infallible");
    view["filesystem"] = self
      .filesystem
      .iter()
      .map(|(name, grant)| {
        (
          name.clone(),
          serde_json::json!({
            "access": grant.access, "target": grant.target
          }),
        )
      })
      .collect::<serde_json::Map<_, _>>()
      .into();
    view["exec"] = self
      .exec
      .iter()
      .map(|(name, grant)| {
        (
          name.clone(),
          serde_json::json!({
            "selected": grant.selected, "lifetime": grant.lifetime
          }),
        )
      })
      .collect::<serde_json::Map<_, _>>()
      .into();
    view
  }

  pub fn validate(&self, requests: &Requests) -> io::Result<()> {
    validate_requests(requests)?;
    if self.network && (!self.http.is_empty() || self.network_proxy) {
      return Err(invalid(
        "raw network access cannot be combined with scoped HTTP or public proxy grants",
      ));
    }
    for (name, scope) in &self.http {
      if requests
        .http
        .get(name)
        .is_none_or(|ask| ask.scope != *scope)
      {
        return Err(invalid("HTTP grant differs from the reviewed request"));
      }
    }
    self.settings.validate()?;
    for (name, grant) in &self.exec {
      let ask = requests
        .exec
        .get(name)
        .ok_or_else(|| invalid("host executable was not requested"))?;
      grant.validate(ask)?;
    }
    requests.settings.access().validate()?;
    if self.filesystem.len() > MAX_GRANTED_DIRS
      || self.network && !requests.network.asked()
      || self.network_proxy && !requests.network_proxy.asked()
      || self.notifications && !requests.notifications.asked()
      || self.audio_playback && !requests.audio_playback.asked()
      || self.microphone && !requests.microphone.asked()
      || self.audio_capture && !requests.audio_capture.asked()
      || !requests.settings.access().covers(&self.settings)
      || self.open_urls && !requests.open_urls.asked()
      || self.storage && !requests.storage.asked()
      || self.desktop_geometry && !requests.desktop_geometry.asked()
      || self.media.as_ref().is_some_and(|service| requests.media.as_ref().is_none_or(|ask| &ask.service != service))
    {
      return Err(invalid("grants exceed the reviewed request"));
    }
    for (name, directory) in &self.filesystem {
      validate_id(name)?;
      // A write-only grant is not enforceable (a bind exposes reads) and is
      // rejected rather than silently widened to read-write, whether it was
      // built by select() or reached this validation path from a constructed
      // or deserialized record.
      if directory.access == Access::Write {
        return Err(io::Error::new(
          io::ErrorKind::Unsupported,
          "write-only host entries are unsupported: a bind also exposes reads",
        ));
      }
      let asked = requests
        .filesystem
        .iter()
        .find(|ask| ask.name == *name && ask.access != Access::Write)
        .ok_or_else(|| invalid("filesystem permission was not requested"))?;
      if !safe_absolute(&directory.path)
        || directory.target != asked.target
        || directory.path != asked.resolved_path()?.canonicalize()?
      {
        return Err(invalid(
          "filesystem grant differs from the declared path or target",
        ));
      }
      // Each named permission is one allow/deny choice, including its access.
      if directory.access != asked.access {
        return Err(invalid("filesystem grant differs from the declared access"));
      }
    }
    if let Some(name) = &self.media {
      validate_media(name)?;
    }
    Ok(())
  }

  /// Grants that the manifest no longer requests. When a plugin updates to a
  /// newer revision that drops a previously-approved request, these grants can
  /// no longer be validated against the (newer) requests; returning them here
  /// lets activation report a re-review-required situation instead of a
  /// generic grants-validate failure.
  pub fn unrequested(&self, requests: &Requests) -> Vec<String> {
    let mut stale = Vec::new();
    for name in self.filesystem.keys() {
      if !requests
        .filesystem
        .iter()
        .any(|ask| ask.name == *name && ask.access != Access::Write)
      {
        stale.push(format!("filesystem:{name}"));
      }
    }
    for name in self.exec.keys() {
      if !requests.exec.contains_key(name) {
        stale.push(format!("exec:{name}"));
      }
    }
    for name in self.http.keys() {
      if !requests.http.contains_key(name) {
        stale.push(format!("http:{name}"));
      }
    }
    for (label, granted, asked) in [
      ("network", self.network, requests.network.asked()),
      (
        "networkProxy",
        self.network_proxy,
        requests.network_proxy.asked(),
      ),
      ("media", self.media.is_some(), requests.media.is_some()),
      (
        "notifications",
        self.notifications,
        requests.notifications.asked(),
      ),
      (
        "audioPlayback",
        self.audio_playback,
        requests.audio_playback.asked(),
      ),
      ("microphone", self.microphone, requests.microphone.asked()),
      (
        "audioCapture",
        self.audio_capture,
        requests.audio_capture.asked(),
      ),
      ("openUrls", self.open_urls, requests.open_urls.asked()),
      ("storage", self.storage, requests.storage.asked()),
      (
        "desktopGeometry",
        self.desktop_geometry,
        requests.desktop_geometry.asked(),
      ),
    ] {
      if granted && !asked {
        stale.push(label.into());
      }
    }
    if self.settings != crate::settings::Grant::default()
      && !requests.settings.access().covers(&self.settings)
    {
      stale.push("settings".into());
    }
    stale
  }

  /// Capabilities the plugin declared mandatory but that are not granted (or
  /// not granted to the requested access). Activation must refuse when this is
  /// non-empty, with an actionable explanation, and never treat a missing
  /// required grant as implicit approval.
  pub fn required_gap(&self, requests: &Requests) -> Vec<String> {
    let mut missing = Vec::new();
    for (name, ask) in &requests.exec {
      for leaf in &ask.required {
        if self
          .exec
          .get(name)
          .is_none_or(|grant| !grant.selected.contains(leaf))
        {
          missing.push(format!("exec:{name}:{leaf}"));
        }
      }
    }
    for (name, ask) in &requests.http {
      if ask.required && self.http.get(name) != Some(&ask.scope) {
        missing.push(format!("http:{name}"));
      }
    }
    for (label, required, granted) in [
      ("network", requests.network.required, self.network),
      (
        "networkProxy",
        requests.network_proxy.required,
        self.network_proxy,
      ),
      (
        "audioPlayback",
        requests.audio_playback.required,
        self.audio_playback,
      ),
      ("microphone", requests.microphone.required, self.microphone),
      (
        "audioCapture",
        requests.audio_capture.required,
        self.audio_capture,
      ),
      ("media", requests.media.as_ref().is_some_and(|ask| ask.required), self.media.is_some()),
      (
        "notifications",
        requests.notifications.required,
        self.notifications,
      ),
      (
        "settings",
        requests.settings.required,
        self.settings.covers(&requests.settings.access()),
      ),
      ("openUrls", requests.open_urls.required, self.open_urls),
      ("storage", requests.storage.required, self.storage),
      (
        "desktopGeometry",
        requests.desktop_geometry.required,
        self.desktop_geometry,
      ),
    ] {
      if required && !granted {
        missing.push(label.into());
      }
    }
    for ask in &requests.filesystem {
      if !ask.required {
        continue;
      }
      let satisfied = match self.filesystem.get(&ask.name) {
        // A required writable directory is only satisfied by a writable grant;
        // a read-only grant for it is still a gap.
        Some(directory) => ask.access != Access::ReadWrite || directory.access.writable(),
        None => false,
      };
      if !satisfied {
        missing.push(ask.name.clone());
      }
    }
    missing
  }
}

fn validate_requests(requests: &Requests) -> io::Result<()> {
  if let Some(ask) = &requests.media { validate_media(&ask.service)?; }
  if requests.exec.len() > 16 {
    return Err(invalid("too many host executable requests"));
  }
  for (name, ask) in &requests.exec {
    validate_id(name)?;
    ask.validate()?;
  }
  requests.settings.access().validate()?;
  if requests.http.len() > 32 {
    return Err(invalid("too many named HTTP scopes"));
  }
  for (name, ask) in &requests.http {
    validate_id(name)?;
    ask.scope.validate()?;
  }
  let names: BTreeSet<&str> = requests
    .filesystem
    .iter()
    .map(|ask| ask.name.as_str())
    .collect();
  if requests.filesystem.len() > MAX_GRANTED_DIRS || names.len() != requests.filesystem.len() {
    return Err(invalid("invalid requested directory slots"));
  }
  for ask in &requests.filesystem {
    validate_id(&ask.name)?;
    ask.resolved_path()?;
    // A write-only request is not enforceable (a bind exposes reads) and is
    // rejected rather than silently widened to read-write.
    if ask.access == Access::Write {
      return Err(io::Error::new(
        io::ErrorKind::Unsupported,
        "write-only host directories are unsupported: a filesystem bind also exposes reads",
      ));
    }
  }
  Ok(())
}

pub(crate) fn validate_media(name: &str) -> io::Result<()> {
  let Some(player) = name.strip_prefix("org.mpris.MediaPlayer2.") else {
    return Err(invalid("invalid media service scope"));
  };
  if player.is_empty()
    || name.len() > 255
    || !player.split('.').all(|part| {
      !part.is_empty()
        && part
          .bytes()
          .next()
          .is_some_and(|byte| byte.is_ascii_alphabetic() || byte == b'_')
        && part
          .bytes()
          .all(|byte| byte.is_ascii_alphanumeric() || byte == b'_' || byte == b'-')
    })
  {
    return Err(invalid("media grants require one exact service name"));
  }
  Ok(())
}

pub(crate) fn validate_id(id: &str) -> io::Result<()> {
  if id.is_empty()
    || id.len() > 96
    || id.contains("..")
    || !id
      .bytes()
      .next()
      .is_some_and(|byte| byte.is_ascii_alphanumeric())
    || !id
      .bytes()
      .all(|byte| byte.is_ascii_alphanumeric() || b"._-".contains(&byte))
  {
    return Err(invalid("invalid plugin or resource identifier"));
  }
  Ok(())
}

pub(crate) fn read_json<T: serde::de::DeserializeOwned>(path: &Path) -> io::Result<T> {
  let path_file = OpenOptions::new()
    .read(true)
    .custom_flags(libc::O_NOFOLLOW | libc::O_PATH)
    .open(path)?;
  if !path_file.metadata()?.is_file() {
    return Err(invalid("expected a regular JSON file"));
  }
  let mut file = File::open(format!("/proc/self/fd/{}", path_file.as_raw_fd()))?;
  let mut bytes = Vec::new();
  (&mut file)
    .take(MAX_PERSISTED_BYTES as u64 + 1)
    .read_to_end(&mut bytes)?;
  if bytes.len() > MAX_PERSISTED_BYTES {
    return Err(invalid("persisted JSON exceeds size limit"));
  }
  serde_json::from_slice(&bytes).map_err(|_| invalid("invalid plugin JSON"))
}

fn safe_relative(path: &str) -> bool {
  !path.is_empty()
    && path.len() <= 4096
    && Path::new(path)
      .components()
      .all(|part| matches!(part, Component::Normal(_)))
}
fn safe_absolute(path: &Path) -> bool {
  path.is_absolute()
    && path.as_os_str().len() <= 4096
    && path
      .components()
      .all(|part| matches!(part, Component::RootDir | Component::Normal(_)))
}
fn open_regular_file(path: &Path) -> io::Result<File> {
  // Validate the opened descriptor, not a prior path lookup that can race a
  // replacement. Nonblocking prevents a substituted FIFO hanging approval.
  let file = OpenOptions::new().read(true)
    .custom_flags(libc::O_NOFOLLOW | libc::O_NONBLOCK)
    .open(path)?;
  if !file.metadata()?.is_file() {
    return Err(invalid("file target is not a regular file"));
  }
  Ok(file)
}

fn open_directory(path: &Path) -> io::Result<File> {
  if !safe_absolute(path) {
    return Err(invalid(
      "directory grant must be an absolute normalized path",
    ));
  }
  let file = OpenOptions::new()
    .read(true)
    .custom_flags(libc::O_PATH | libc::O_NOFOLLOW)
    .open(path)?;
  if !file.metadata()?.is_dir() {
    return Err(invalid("read grant must name a directory"));
  }
  Ok(file)
}
pub(crate) fn invalid(message: &str) -> io::Error {
  io::Error::new(io::ErrorKind::InvalidData, message)
}

#[cfg(test)]
mod tests {
  use super::*;
  use std::fs;

  #[test]
  fn filesystem_paths_expand_only_declared_host_roots() {
    let environment = |name: &str| match name {
      "HOME" => Some(PathBuf::from("/home/example")),
      "XDG_STATE_HOME" => Some(PathBuf::from("/data/state")),
      _ => None,
    };
    assert_eq!(requested_path("$XDG_STATE_HOME/example", environment).unwrap(), PathBuf::from("/data/state/example"));
    assert_eq!(requested_path("$XDG_DATA_HOME/example", environment).unwrap(), PathBuf::from("/home/example/.local/share/example"));
    assert_eq!(requested_path("$HOME/My files", environment).unwrap(), PathBuf::from("/home/example/My files"));
    assert_eq!(requested_path("/data/example.txt", environment).unwrap(), PathBuf::from("/data/example.txt"));
    for value in ["", "/", "relative", "~/notes", "$HOME", "$HOME/../secret", "$HOME/./notes", "$HOME//notes", "$HOME/notes/", "$UNKNOWN/notes", "${HOME}/notes", "$(id)/notes", "/data/$HOME", "/data/notes\n"] {
      assert!(requested_path(value, environment).is_err(), "accepted {value:?}");
    }
    assert!(requested_path("$XDG_STATE_HOME/example", |_| Some(PathBuf::from("relative"))).is_err());
    assert!(requested_path("$HOME/example", |_| None).is_err());
    assert!(serde_json::from_str::<Requests>(r#"{"filesystem":[{"name":"notes"}]}"#).is_err());
  }

  #[test]
  fn exact_file_grants_validate_opened_type_and_refuse_replacement_links() {
    let root = tempfile::tempdir().unwrap();
    let path = root.path().join("file");
    fs::write(&path, "original").unwrap();
    let grant = FileSystemGrant::select(&path, Access::Read, Target::File).unwrap();
    grant.open().unwrap();
    let moved = root.path().join("moved");
    fs::rename(&path, &moved).unwrap();
    std::os::unix::fs::symlink(&moved, &path).unwrap();
    assert!(grant.open().is_err(), "even a link to the pinned inode must not replace a file");
    assert!(open_regular_file(root.path()).is_err());
    let fifo = root.path().join("pipe");
    let name = std::ffi::CString::new(fifo.as_os_str().as_encoded_bytes()).unwrap();
    assert_eq!(unsafe { libc::mkfifo(name.as_ptr(), 0o600) }, 0);
    assert!(open_regular_file(&fifo).is_err(), "a FIFO must be rejected without blocking");
  }

  #[test]
  fn grants_cannot_substitute_declared_paths_or_target_kinds() {
    let root = tempfile::tempdir().unwrap();
    let file = root.path().join("file");
    let other = root.path().join("other");
    fs::write(&file, "requested").unwrap();
    fs::write(&other, "not requested").unwrap();
    let requests: Requests = serde_json::from_value(serde_json::json!({"filesystem": [{
      "name": "data", "path": file, "target": "file", "access": "readwrite"
    }]})).unwrap();
    let mut grants = Grants::default();
    grants.filesystem.insert("data".into(), FileSystemGrant::select(&file, Access::ReadWrite, Target::File).unwrap());
    grants.validate(&requests).unwrap();
    grants.filesystem.insert("data".into(), FileSystemGrant::select(&file, Access::Read, Target::File).unwrap());
    assert!(grants.validate(&requests).is_err(), "a named permission cannot change its requested access");
    grants.filesystem.insert("data".into(), FileSystemGrant::select(&other, Access::Read, Target::File).unwrap());
    assert!(grants.validate(&requests).is_err());
    grants.filesystem.insert("data".into(), FileSystemGrant::select(root.path(), Access::Read, Target::Directory).unwrap());
    assert!(grants.validate(&requests).is_err());
    let mut grant = FileSystemGrant::select(&file, Access::Read, Target::File).unwrap();
    grant.target = Target::Directory;
    grants.filesystem.insert("data".into(), grant);
    assert!(grants.validate(&requests).is_err());
  }

  #[test]
  fn media_permissions_bind_one_declared_service() {
    let requests: Requests = serde_json::from_value(serde_json::json!({"media": {
      "service": "org.mpris.MediaPlayer2.fixture", "required": true
    }})).unwrap();
    validate_requests(&requests).unwrap();
    assert_eq!(Grants::default().required_gap(&requests), ["media"]);
    Grants { media: Some("org.mpris.MediaPlayer2.fixture".into()), ..Grants::default() }.validate(&requests).unwrap();
    assert!(Grants { media: Some("org.mpris.MediaPlayer2.other".into()), ..Grants::default() }.validate(&requests).is_err());
    for value in [serde_json::json!(true), serde_json::json!({}), serde_json::json!({"required": true})] {
      assert!(serde_json::from_value::<Requests>(serde_json::json!({"media":value})).is_err());
    }
    for service in ["*", "org.mpris.MediaPlayer2.*", "org.freedesktop.Notifications"] {
      let requests: Requests = serde_json::from_value(serde_json::json!({"media":{"service":service}})).unwrap();
      assert!(validate_requests(&requests).is_err());
    }
  }

  #[test]
  fn worker_view_exposes_slots_without_host_authority_metadata() {
    let root = tempfile::tempdir().unwrap();
    let mut grants = Grants::default();
    grants.filesystem.insert(
      "documents".into(),
      FileSystemGrant::select(root.path(), Access::Read, Target::Directory).unwrap(),
    );
    let ask: crate::exec::Ask = serde_json::from_value(serde_json::json!({
      "executable": "/usr/bin/true", "tree": {"end":"run", "next":[]}
    }))
    .unwrap();
    grants.exec.insert(
      "tool".into(),
      crate::exec::Grant::select(&ask, ["run".into()].into()).unwrap(),
    );
    let view = grants.worker_view();
    assert_eq!(
      view["filesystem"]["documents"],
      serde_json::json!({"access":"read", "target":"directory"})
    );
    assert_eq!(view["exec"]["tool"]["selected"], serde_json::json!(["run"]));
    for forbidden in ["path", "device", "inode"] {
      assert!(view["filesystem"]["documents"].get(forbidden).is_none());
    }
    for forbidden in ["executable", "tree"] {
      assert!(view["exec"]["tool"].get(forbidden).is_none());
    }
    assert!(
      !serde_json::to_string(&view)
        .unwrap()
        .contains(root.path().to_str().unwrap())
    );
  }
  #[test]
  fn shared_worker_requires_supported_matching_entry_points() {
    let root = tempfile::tempdir().unwrap();
    fs::write(root.path().join("Widget.qml"), "Item {}").unwrap();
    let mut value = serde_json::json!({
      "schemaVersion": 1, "id": "test.shared", "name": "Shared", "version": "1",
      "kinds": ["bar-widget"], "entryPoints": { "barWidget": "Widget.qml" },
      "sandbox": { "version": 1, "requests": {} }
    });
    let read = |value: &serde_json::Value| {
      fs::write(
        root.path().join("manifest.json"),
        serde_json::to_vec(value).unwrap(),
      )
      .unwrap();
      Manifest::read(root.path())
    };
    assert!(read(&value).unwrap().sandbox.entry_point.is_none());
    value["kinds"] = serde_json::json!(["bar-widget", "service", "overlay"]);
    value["entryPoints"]["service"] = "Widget.qml".into();
    value["entryPoints"]["overlay"] = "Widget.qml".into();
    assert!(read(&value).is_ok());
    value["entryPoints"]["extra"] = "Widget.qml".into();
    assert!(read(&value).is_err());
    value["entryPoints"]
      .as_object_mut()
      .unwrap()
      .remove("extra");
    for kinds in [
      serde_json::json!(["service", "overlay"]),
      serde_json::json!(["bar-widget", "bar"]),
      serde_json::json!(["bar-widget", "bar-widget"]),
    ] {
      value["kinds"] = kinds;
      assert!(read(&value).is_err());
    }
    value["sandbox"]["entryPoint"] = "Widget.qml".into();
    assert_eq!(
      read(&value).unwrap().sandbox.entry_point.as_deref(),
      Some("Widget.qml")
    );
    value["sandbox"]["entryPoint"] = "../Widget.qml".into();
    assert!(read(&value).is_err());
    value["sandbox"]["entryPoint"] = "missing.qml".into();
    assert!(read(&value).is_err());
  }

  #[test]
  fn requests_never_become_implicit_grants() {
    let requests = Requests {
      filesystem: vec![FileSystemRequest::optional("music", "/data/music")],
      http: BTreeMap::new(),
      exec: BTreeMap::new(),
      network: Request {
        asked: true,
        required: true,
      },
      media: Some(MediaRequest {
        service: "org.mpris.MediaPlayer2.firefox.instance1".into(),
        required: true,
      }),
      notifications: Request {
        asked: true,
        required: true,
      },
      settings: crate::settings::Ask {
        read: ["volume".into()].into(),
        write: ["volume".into()].into(),
        required: true,
      },
      open_urls: Request {
        asked: true,
        required: true,
      },
      storage: Request {
        asked: true,
        required: true,
      },
      desktop_geometry: Request {
        asked: true,
        required: true,
      },
      ..Default::default()
    };
    let grants = Grants::default();
    grants.validate(&requests).unwrap();
    assert!(!grants.network && grants.filesystem.is_empty() && grants.media.is_none());
    assert!(
      !grants.notifications && !grants.settings.can_write() && !grants.open_urls && !grants.storage
    );
    assert!(
      Grants {
        open_urls: true,
        ..Default::default()
      }
      .validate(&Requests::default())
      .is_err()
    );
    assert_eq!(
      serde_json::from_str::<Grants>("{}").unwrap().settings,
      crate::settings::Grant::default()
    );
    assert!(
      Grants {
        settings: crate::settings::Grant {
          write: ["volume".into()].into(),
          ..Default::default()
        },
        ..Default::default()
      }
      .validate(&Requests::default())
      .is_err()
    );
    assert!(
      Grants {
        network: true,
        ..Grants::default()
      }
      .validate(&Requests::default())
      .is_err()
    );
    for name in [
      "*",
      "org.mpris.MediaPlayer2.*",
      "org.mpris.MediaPlayer2.vlc --talk=*",
      "org.freedesktop.Notifications",
    ] {
      assert!(
        Grants {
          media: Some(name.into()),
          ..Grants::default()
        }
        .validate(&requests)
        .is_err()
      );
    }
    Grants {
      media: Some("org.mpris.MediaPlayer2.firefox.instance1".into()),
      ..Grants::default()
    }
    .validate(&requests)
    .unwrap();
    assert!(serde_json::from_str::<Requests>(r#"{"hostExec":true}"#).is_err());
    assert!(serde_json::from_str::<Grants>(r#"{"network":true,"network":false}"#).is_err());
  }
  #[test]
  fn directory_selection_is_not_a_replaceable_path() {
    let root = tempfile::tempdir().unwrap();
    let path = root.path().join("selected");
    fs::create_dir(&path).unwrap();
    let selected = FileSystemGrant::select(&path, Access::Read, Target::Directory).unwrap();
    selected.open().unwrap();
    fs::rename(&path, root.path().join("old")).unwrap();
    fs::create_dir(&path).unwrap();
    assert!(selected.open().is_err());
    for path in ["../escape", "/absolute", "dir/../escape", ""] {
      assert!(!safe_relative(path));
    }
    for id in ["../escape", "--unit", "*", "a/b", "a\n"] {
      assert!(validate_id(id).is_err());
    }
  }

  #[test]
  fn write_only_is_rejected_but_file_and_directory_targets_are_supported() {
    let root = tempfile::tempdir().unwrap();
    fs::create_dir(root.path().join("data")).unwrap();
    fs::write(root.path().join("data").join("file.txt"), "data").unwrap();
    // A write-only target is not enforceable: a bind also exposes reads.
    assert_eq!(
      FileSystemGrant::select(&root.path().join("data"), Access::Write, Target::Directory)
        .unwrap_err()
        .kind(),
      io::ErrorKind::Unsupported
    );
    // A single file is an exact, enforceable target.
    let file = FileSystemGrant::select(
      &root.path().join("data").join("file.txt"),
      Access::Read,
      Target::File,
    )
    .unwrap();
    assert_eq!(file.target, Target::File);
    // A directory target is the whole subtree.
    let directory = FileSystemGrant::select(
      &root.path().join("data"),
      Access::ReadWrite,
      Target::Directory,
    )
    .unwrap();
    assert_eq!(directory.target, Target::Directory);
    // A file target that is actually a directory is rejected.
    assert!(
      FileSystemGrant::select(&root.path().join("data"), Access::Read, Target::File).is_err()
    );
    // Round-trip preserves the target kind.
    let bytes = serde_json::to_vec(&file).unwrap();
    assert!(String::from_utf8_lossy(&bytes).contains("file"));
    assert!(
      serde_json::from_slice::<FileSystemGrant>(&bytes)
        .unwrap()
        .target
        == Target::File
    );
  }

  #[test]
  fn constructed_grant_admission_refuses_unsupported_write_and_file_type_mismatch() {
    let root = tempfile::tempdir().unwrap();
    fs::create_dir(root.path().join("data")).unwrap();
    fs::write(root.path().join("data").join("file.txt"), "data").unwrap();
    // A write-only grant that bypassed select() (e.g. deserialized from a
    // record) is refused at the admission open() path and at Grants::validate().
    let write = FileSystemGrant {
      path: root.path().join("data"),
      device: 1,
      inode: 2,
      access: Access::Write,
      target: Target::Directory,
    };
    assert_eq!(write.open().unwrap_err().kind(), io::ErrorKind::Unsupported);
    let mut grants = Grants::default();
    grants.filesystem.insert("shared".into(), write);
    let requests = Requests {
      filesystem: vec![FileSystemRequest {
        name: "shared".into(),
        path: root.path().join("data").to_str().unwrap().into(),
        target: Target::Directory,
        access: Access::ReadWrite,
        required: false,
      }],
      ..Default::default()
    };
    assert_eq!(
      grants.validate(&requests).unwrap_err().kind(),
      io::ErrorKind::Unsupported
    );
    // A file-target grant pointing at a directory is refused at open() too;
    // the bind would be a directory bind, not the exact file the grant names.
    let dir_as_file = FileSystemGrant {
      path: root.path().join("data"),
      device: 1,
      inode: 3,
      access: Access::Read,
      target: Target::File,
    };
    let error = dir_as_file.open().unwrap_err().to_string();
    assert!(error.contains("not a regular file"), "{error}");
  }

  #[test]
  fn device_and_ipc_roots_are_never_granted() {
    for unsafe_path in ["/dev", "/dev/dri", "/proc", "/proc/self", "/sys", "/"] {
      assert_eq!(
        FileSystemGrant::select(Path::new(unsafe_path), Access::Read, Target::Directory)
          .unwrap_err()
          .kind(),
        io::ErrorKind::InvalidData
      );
    }
  }

  #[test]
  fn grants_respect_the_descriptor_budget() {
    let root = tempfile::tempdir().unwrap();
    fs::create_dir(root.path().join("data")).unwrap();
    let requests = Requests {
      filesystem: (0..MAX_GRANTED_DIRS + 1)
        .map(|i| FileSystemRequest::optional(format!("dir{i:03}"), root.path().join("data").to_str().unwrap()))
        .collect(),
      ..Default::default()
    };
    assert!(validate_requests(&requests).is_err());
    let mut grants = Grants::default();
    for request in &requests.filesystem {
      grants.filesystem.insert(
        request.name.clone(),
        FileSystemGrant::select(&root.path().join("data"), Access::Read, Target::Directory)
          .unwrap(),
      );
    }
    assert!(grants.validate(&requests).is_err());
    let _ = root;
  }

  #[test]
  fn strict_request_deserialization_rejects_unknown_fields() {
    assert!(
      serde_json::from_str::<Requests>(r#"{"settings":{"required":true,"junk":1}}"#).is_err()
    );
    assert!(
      serde_json::from_str::<Requests>(r#"{"settings":{"required":true,"required":false}}"#)
        .is_err()
    );
    assert!(serde_json::from_str::<Requests>(r#"{"filesystem":[{"name":"x","junk":1}]}"#).is_err());
    assert!(serde_json::from_str::<Requests>(r#"{"filesystem":[{"required":true}]}"#).is_err());
    let requests = serde_json::from_str::<Requests>(
      r#"{"filesystem":[{"name":"notes","path":"/data/notes","required":true}, {"name":"music","path":"/data/music"}]}"#,
    )
    .unwrap();
    assert_eq!(requests.filesystem.len(), 2);
    assert!(requests.filesystem[0].required);
    assert_eq!(requests.filesystem[0].name, "notes");
    assert!(!requests.filesystem[1].required);
    // Round trip preserves requiredness in the canonical object schema.
    let bytes = serde_json::to_vec(&requests).unwrap();
    assert!(String::from_utf8_lossy(&bytes).contains("\"music\""));
  }

  #[test]
  fn directory_required_and_optional_are_both_blocking() {
    // An optional directory the user declined does not block startup.
    let requests = Requests {
      filesystem: vec![FileSystemRequest::optional("notes", "/data/notes")],
      ..Default::default()
    };
    assert!(Grants::default().required_gap(&requests).is_empty());
    // A required directory the user declined blocks activation by name.
    let requests = Requests {
      filesystem: vec![FileSystemRequest::required("notes", "/data/notes")],
      ..Default::default()
    };
    assert_eq!(Grants::default().required_gap(&requests), vec!["notes"]);
    // A required writable directory is only satisfied by a writable grant.
    let requests = Requests {
      filesystem: vec![FileSystemRequest::write("notes", "/data/notes", true)],
      ..Default::default()
    };
    assert!(
      Grants::default()
        .required_gap(&requests)
        .iter()
        .any(|x| x == "notes")
    );
    assert!(serde_json::from_str::<Requests>(r#"{"filesystem":{"notes":true}}"#).is_err());
  }
}
