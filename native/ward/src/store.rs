use crate::{
  grants::{Grants, MAX_PERSISTED_BYTES, Manifest, invalid, read_json, validate_id},
  revision::{Revision, require_private_directory},
  supervisor::{Limits, Unit, validate_name},
};
use base64::Engine;
use ed25519_dalek::{Signature, Signer, VerifyingKey, SigningKey};
use serde::{Deserialize, Serialize};
use std::{
  ffi::OsString,
  fs::{self, DirBuilder, File, OpenOptions},
  io::{self, Read, Write},
  os::{
    fd::AsRawFd,
    unix::fs::{DirBuilderExt, MetadataExt, OpenOptionsExt},
  },
  path::{Path, PathBuf},
  time::{Duration, Instant},
};

#[derive(Clone, Debug, Deserialize, Serialize)]
#[serde(rename_all = "camelCase", deny_unknown_fields)]
pub struct Record {
  pub version: u32,
  pub id: String,
  pub revision: String,
  pub epoch: u64,
  pub enabled: bool,
  pub grants: Grants,
  pub active_unit: Option<String>,
  /// Review-minted signature over the immutable approval content
  /// (`id`, `revision`, `enabled`, `grants`). Runtime state (`epoch`,
  /// `active_unit`) is deliberately excluded so the controller can bump it
  /// without needing the signing key. Every publication re-signs, and every
  /// read re-verifies, so a hand-edited `grants` set fails closed.
  pub signature: String,
}

pub struct Store {
  root: PathBuf,
}

/// The reviewed approval content that a record signature vouches for. Runtime
/// state (`epoch`, `active_unit`) is excluded so the controller can advance it
/// without holding the signing key; only a (re)publication that changes the
/// approved access re-mints the signature.
#[derive(Serialize)]
#[serde(rename_all = "camelCase")]
struct SignedFields<'a> {
  id: &'a str,
  revision: &'a str,
  enabled: bool,
  grants: &'a Grants,
}

fn signed_bytes(record: &Record) -> io::Result<Vec<u8>> {
  serde_json::to_vec(&SignedFields {
    id: &record.id,
    revision: &record.revision,
    enabled: record.enabled,
    grants: &record.grants,
  })
  .map_err(|_| invalid("could not encode signing payload"))
}

impl Store {
  fn secrets_dir(&self) -> PathBuf {
    self.root.join("secrets")
  }
  fn signing_key_path(&self) -> PathBuf {
    self.secrets_dir().join("signing.key")
  }
  fn signing_pub_path(&self) -> PathBuf {
    self.secrets_dir().join("signing.pub")
  }

  /// The verification public key. The keypair is minted by `initialize()`; a
  /// store opened for read-side work must already carry one (every record in
  /// this greenfield format is signed against it).
  fn verifying_key(&self) -> io::Result<VerifyingKey> {
    let file = OpenOptions::new()
      .read(true)
      .custom_flags(libc::O_NOFOLLOW | libc::O_PATH)
      .open(self.signing_pub_path())?;
    if !file.metadata()?.is_file() {
      return Err(invalid("signing public key is not a regular file"));
    }
    let mut file = File::open(format!("/proc/self/fd/{}", file.as_raw_fd()))?;
    let mut bytes = [0u8; 32];
    file.read_exact(&mut bytes)?;
    VerifyingKey::from_bytes(&bytes)
      .map_err(|_| invalid("invalid signing public key"))
  }

  fn ensure_keys(&self) -> io::Result<()> {
    match DirBuilder::new().mode(0o700).create(self.secrets_dir()) {
      Ok(()) => (),
      Err(error) if error.kind() == io::ErrorKind::AlreadyExists => (),
      Err(error) => return Err(error),
    }
    require_private_directory(&self.secrets_dir())?;
    let secret_exists = self.signing_key_path().try_exists()?;
    let public_exists = self.signing_pub_path().try_exists()?;
    if secret_exists || public_exists {
      if secret_exists && public_exists {
        return Ok(());
      }
      return Err(invalid("incomplete signing keypair; restore the original keypair before reviewing"));
    }
    let mut random = File::open("/dev/urandom")?;
    let mut seed = [0u8; 32];
    random.read_exact(&mut seed)?;
    let signing = SigningKey::from_bytes(&seed);
    let mut secret = OpenOptions::new()
      .write(true)
      .create_new(true)
      .mode(0o600)
      .open(self.signing_key_path())?;
    secret.write_all(&seed)?;
    secret.sync_all()?;
    let mut public = OpenOptions::new()
      .write(true)
      .create_new(true)
      .mode(0o644)
      .open(self.signing_pub_path())?;
    public.write_all(&signing.verifying_key().to_bytes())?;
    public.sync_all()?;
    File::open(&self.secrets_dir())?.sync_all()?;
    File::open(&self.root)?.sync_all()?;
    Ok(())
  }

  /// Re-mint the record signature for the currently-reviewed approval content.
  fn sign(&self, record: &Record) -> io::Result<String> {
    let file = OpenOptions::new()
      .read(true)
      .custom_flags(libc::O_NOFOLLOW | libc::O_PATH)
      .open(self.signing_key_path())?;
    let mut file = File::open(format!("/proc/self/fd/{}", file.as_raw_fd()))?;
    let mut seed = [0u8; 32];
    file.read_exact(&mut seed)?;
    let key = SigningKey::from_bytes(&seed);
    let signature = key.sign(&signed_bytes(record)?);
    Ok(base64::engine::general_purpose::STANDARD.encode(signature.to_bytes()))
  }

  fn verify_signature(&self, record: &Record) -> io::Result<()> {
    if record.signature.is_empty() {
      return Err(invalid("grant record is unsigned"));
    }
    let signature = base64::engine::general_purpose::STANDARD
      .decode(&record.signature)
      .map_err(|_| invalid("grant record signature is not valid base64"))?;
    let signature = Signature::from_bytes(
      <&[u8; 64]>::try_from(signature.as_slice())
        .map_err(|_| invalid("grant record signature has the wrong length"))?,
    );
    self
      .verifying_key()?
      .verify_strict(&signed_bytes(record)?, &signature)
      .map_err(|_| invalid("grant record signature does not match the approved grants"))
  }
  pub fn open(root: &Path) -> io::Result<Self> {
    require_private_directory(root)?;
    require_private_directory(&root.join("revisions"))?;
    Ok(Self { root: root.into() })
  }

  /// Explicit initialization; opening a missing store never creates grants.
  pub fn initialize(root: &Path) -> io::Result<Self> {
    if !root.is_absolute() {
      return Err(invalid("plugin store must have an absolute path"));
    }
    for path in [root.to_path_buf(), root.join("revisions")] {
      match fs::DirBuilder::new().mode(0o700).create(&path) {
        Ok(()) => (),
        Err(error) if error.kind() == io::ErrorKind::AlreadyExists => (),
        Err(error) => return Err(error),
      }
      require_private_directory(&path)?;
    }
    File::open(root)?.sync_all()?;
    File::open(
      root
        .parent()
        .ok_or_else(|| invalid("invalid plugin store root"))?,
    )?
    .sync_all()?;
    Self::open(root)?.ensure_keys()?;
    Self::open(root)
  }

  pub fn revisions(&self) -> PathBuf {
    self.root.join("revisions")
  }

  /// Import and index a reviewed revision under the same identity lock as
  /// approval/removal. A concurrent removal cannot leave a late snapshot.
  pub fn import(&self, source: &Path) -> io::Result<Revision> {
    let id = Manifest::read(source)?.id;
    let _lock = self.lock(&id)?;
    self.require_ready(&id)?;
    let revision = Revision::import(source, &self.revisions())?;
    if Manifest::read(&revision.path)?.id != id {
      return Err(invalid("plugin identity changed during review"));
    }
    self.retain_revision(&id, &revision.digest)?;
    Ok(revision)
  }

  /// Host-readable isolation and snapshot ownership, never approval. Retained
  /// by disable/revoke; explicit removal deletes it after stopping the worker.
  fn retain_revision(&self, id: &str, revision: &str) -> io::Result<()> {
    validate_id(id)?;
    let directory = self.root.join("identities");
    match DirBuilder::new().mode(0o700).create(&directory) {
      Ok(()) => (),
      Err(error) if error.kind() == io::ErrorKind::AlreadyExists => (),
      Err(error) => return Err(error),
    }
    require_private_directory(&directory)?;
    let marker = directory.join(id);
    match DirBuilder::new().mode(0o700).create(&marker) {
      Ok(()) => (),
      Err(error) if error.kind() == io::ErrorKind::AlreadyExists => (),
      Err(error) => return Err(error),
    }
    require_private_directory(&marker)?;
    let revision_marker = OpenOptions::new().write(true).create(true).truncate(false)
      .mode(0o600).custom_flags(libc::O_NOFOLLOW | libc::O_NONBLOCK)
      .open(marker.join(revision))?;
    revision_marker.sync_all()?;
    File::open(&marker)?.sync_all()?;
    File::open(&directory)?.sync_all()?;
    File::open(&self.root)?.sync_all()
  }

  pub fn read(&self, id: &str) -> io::Result<Record> {
    let _lock = self.lock(id)?;
    self.require_ready(id)?;
    self.record(id)
  }

  /// Approval is an administrative operation on an exact reviewed snapshot.
  /// Neither manifest requests nor worker messages may call this API.
  pub fn approve(&self, revision: &str, grants: Grants) -> io::Result<Record> {
    validate_revision(revision)?;
    let manifest = Manifest::read(&self.revisions().join(revision))?;
    let _lock = self.lock(&manifest.id)?;
    self.require_ready(&manifest.id)?;
    Revision::verify(&self.revisions(), revision)?;
    self.retain_revision(&manifest.id, revision)?;
    grants.validate(&manifest.sandbox.requests)?;
    let protected = crate::authority::ProtectedPaths::for_store(&self.root)?;
    for directory in grants.filesystem.values() {
      protected.check(directory)?;
      directory.open()?;
    }
    let previous = match self.record(&manifest.id) {
      Ok(record) => Some(record),
      Err(error) if error.kind() == io::ErrorKind::NotFound && self.record_absent(&manifest.id) => None,
      Err(error) => return Err(error),
    };
    if previous
      .as_ref()
      .is_some_and(|record| record.active_unit.is_some())
    {
      return Err(invalid(
        "stop or revoke the previous instance before approving a revision",
      ));
    }
    let mut record = Record {
      version: 1,
      id: manifest.id,
      revision: revision.into(),
      epoch: next_epoch(previous.as_ref().map_or(0, |record| record.epoch))?,
      enabled: true,
      grants,
      active_unit: None,
      signature: String::new(),
    };
    // publish() re-mints the signature over the approved content, preflights
    // the serialized size below, and does so before it creates the durable
    // pending marker, so no publish transition (approve, launch, stop, revoke,
    // recover) can poison a prior usable record with an over-limit approval.
    self.publish(&mut record, None, |_| Ok(()))?;
    Ok(record)
  }

  /// Reserve and record the unit before launching it. A crash at any point
  /// therefore leaves either no possible worker or an identity recovery can stop.
  pub fn launch(&self, id: &str, program: &Path, host_socket: &Path) -> io::Result<(Unit, Record)> {
    let _lock = self.lock(id)?;
    self.require_ready(id)?;
    let mut record = self.record(id)?;
    self.validate_authority(&record)?;
    let unit = Unit::prepare()?;
    let previous = record.active_unit.replace(unit.name().into());
    record.epoch = next_epoch(record.epoch)?;
    self.publish(&mut record, previous.as_deref(), |_| Ok(()))?;
    let args = [
      OsString::from("--controller"),
      host_socket.into(),
      self.root.clone().into(),
      id.into(),
      record.epoch.to_string().into(),
    ];
    let launched = unit.launch(
      program,
      &args.iter().map(OsString::as_os_str).collect::<Vec<_>>(),
      Limits::default(),
    );
    match launched {
      Ok(unit) => Ok((unit, record)),
      Err(error) => {
        // A reservation was published before systemd was called. Failed exec
        // must retire it too, but only after confirming any service is stopped.
        self.stop_record(&mut record).map_err(|cleanup| {
          io::Error::other(format!("{error}; could not retire failed startup: {cleanup}"))
        })?;
        Err(error)
      }
    }
  }

  /// Keep admission serialized through the beginning/completion of a bounded
  /// effect. Revocation cannot report success while an admitted effect holds it.
  pub fn with_authority<T>(
    &self,
    id: &str,
    epoch: u64,
    unit: &str,
    effect: impl FnOnce(&Record) -> io::Result<T>,
  ) -> io::Result<T> {
    let _lock = self.lock(id)?;
    self.require_ready(id)?;
    let record = self.record(id)?;
    if !record.enabled || record.epoch != epoch || record.active_unit.as_deref() != Some(unit) {
      return Err(invalid("plugin authority is disabled or stale"));
    }
    effect(&record)
  }

  pub fn admit(&self, id: &str, epoch: u64, unit: &str) -> io::Result<Record> {
    self.with_authority(id, epoch, unit, |record| {
      self.validate_authority(record)?;
      Ok(record.clone())
    })
  }

  pub fn revoke(&self, id: &str) -> io::Result<()> {
    let _lock = self.lock(id)?;
    if self.pending(id)? {
      return self.recover_locked(id);
    }
    let mut record = match self.record(id) {
      Ok(record) => record,
      // An installed or reviewed plugin need not have been approved yet.
      Err(error) if error.kind() == io::ErrorKind::NotFound && self.record_absent(id) => return Ok(()),
      Err(error) => {
        self.deny_and_stop_unverified(id)?;
        return Err(error);
      }
    };
    // Revocation is fail-closed even when signing/publication is unavailable.
    // Persist denial and stop independently before touching the signing key.
    self.deny_and_stop(&record)?;
    record.enabled = false;
    record.epoch = record.epoch.saturating_add(1);
    record.active_unit = None;
    record.signature = self.sign(&record)?;
    self.finish(&record, &mut |_| Ok(()))
  }

  /// Uninstall the identity, not merely its current approval. Never forget a
  /// controller until its stop is confirmed; failures retain durable denial
  /// and enough ownership metadata to retry. No signing key is needed.
  pub fn remove(&self, id: &str) -> io::Result<()> {
    let _lock = self.lock(id)?;
    let record = match self.record(id) {
      Ok(record) => Some(record),
      Err(error) if error.kind() == io::ErrorKind::NotFound && self.record_absent(id) => None,
      Err(error) => { self.deny_and_stop_unverified(id)?; return Err(error); }
    };
    if let Some(record) = &record {
      self.deny_and_stop(record)?;
    } else {
      self.mark_denied(id)?;
    }

    let mut revisions = std::collections::BTreeSet::new();
    if let Some(record) = &record { revisions.insert(record.revision.clone()); }
    let identities = self.root.join("identities");
    let identity = identities.join(id);
    if identities.try_exists()? {
      require_private_directory(&identities)?;
      if identity.try_exists()? {
        require_private_directory(&identity)?;
        for entry in fs::read_dir(&identity)? {
          let name = entry?.file_name().into_string().map_err(|_| invalid("invalid revision ownership record"))?;
          validate_revision(&name)?;
          revisions.insert(name);
        }
      }
    }
    // Earlier imports used an empty identity marker. Identify their snapshots
    // from bounded, non-following manifest reads, without trusting grant paths.
    for entry in fs::read_dir(self.revisions())? {
      let entry = entry?;
      let name = entry.file_name();
      let Some(name) = name.to_str() else { continue; };
      if validate_revision(name).is_err() || !entry.file_type()?.is_dir() { continue; }
      let manifest = read_json::<serde_json::Value>(&entry.path().join("manifest.json"));
      if manifest.ok().and_then(|value| value.get("id").and_then(|id| id.as_str()).map(str::to_owned)).as_deref() == Some(id) {
        revisions.insert(name.to_owned());
      }
    }
    for revision in revisions {
      remove_owned_path(&self.revisions().join(revision))?;
    }
    File::open(self.revisions())?.sync_all()?;
    remove_owned_path(&self.path(id, "json"))?;
    File::open(&self.root)?.sync_all()?;
    remove_owned_path(&identity)?;
    if identities.try_exists()? { File::open(&identities)?.sync_all()?; }
    remove_owned_path(&self.path(id, "pending"))?;
    File::open(&self.root)?.sync_all()?;
    // This must be last. lock() checks the inode after acquiring it, so a
    // waiter on the unlinked inode retries rather than splitting ownership.
    remove_owned_path(&self.path(id, "lock"))?;
    File::open(&self.root)?.sync_all()
  }

  fn mark_denied(&self, id: &str) -> io::Result<()> {
    match OpenOptions::new().write(true).create_new(true).mode(0o600)
      .open(self.path(id, "pending")) {
      Ok(marker) => marker.sync_all()?,
      Err(error) if error.kind() == io::ErrorKind::AlreadyExists => (),
      Err(error) => return Err(error),
    }
    File::open(&self.root)?.sync_all()
  }

  fn record_absent(&self, id: &str) -> bool {
    matches!(fs::symlink_metadata(self.path(id, "json")), Err(error) if error.kind() == io::ErrorKind::NotFound)
  }

  fn deny_and_stop_unverified(&self, id: &str) -> io::Result<()> {
    let denied = self.mark_denied(id);
    let stopped = Unit::stop_matching(&self.root, id);
    denied?;
    stopped
  }

  fn deny_and_stop(&self, record: &Record) -> io::Result<()> {
    let denied = self.mark_denied(&record.id);
    // Still attempt emergency stop if the store cannot be written. Return an
    // error, never a successful durable revocation, if either operation fails.
    let stopped = match record.active_unit.as_deref() {
      Some(unit) => Unit::recover(unit).and_then(|mut unit| unit.stop()),
      None => Ok(()),
    };
    denied?;
    stopped
  }

  /// Stop a running plugin **without** disabling its approval. This is the
  /// non-destructive predecessor to a re-approval: the active unit is stopped
  /// and the epoch advanced (so stale host leases die), but `enabled` stays
  /// true and the reviewed grants are untouched, so an approval on the same
  /// revision can follow immediately.
  pub fn stop(&self, id: &str) -> io::Result<Record> {
    let _lock = self.lock(id)?;
    if self.pending(id)? {
      return Err(invalid(
        "interrupted grant publication requires explicit recovery",
      ));
    }
    let mut record = self.record(id)?;
    self.stop_record(&mut record)?;
    Ok(record)
  }

  /// Retire only this host session's reservation. Cleanup racing a newer
  /// launch/revocation must not stop it, clear its record, or recover denial.
  pub(crate) fn finish_session(&self, id: &str, epoch: u64, unit: &str) -> io::Result<()> {
    let _lock = self.lock(id)?;
    if self.pending(id)? {
      return Ok(());
    }
    let mut record = self.record(id)?;
    if record.epoch != epoch || record.active_unit.as_deref() != Some(unit) {
      return Ok(());
    }
    self.stop_record(&mut record)
  }

  fn stop_record(&self, record: &mut Record) -> io::Result<()> {
    self.deny_and_stop(record)?;
    record.active_unit = None;
    record.epoch = record.epoch.saturating_add(1);
    // The signed approval content is unchanged; stopping needs no private key.
    self.finish(record, &mut |_| Ok(()))
  }

  /// Explicit recovery only disables authority; it never completes a pending
  /// approval by guessing what the user intended.
  pub fn recover(&self, id: &str) -> io::Result<()> {
    let _lock = self.lock(id)?;
    if !self.pending(id)? {
      return Err(invalid("no interrupted publication to recover"));
    }
    self.recover_locked(id)
  }

  fn recover_locked(&self, id: &str) -> io::Result<()> {
    match self.record(id) {
      Ok(mut record) => {
        if let Some(unit) = record.active_unit.take() {
          Unit::recover(&unit)?.stop()?;
        }
        record.enabled = false;
        record.epoch = record.epoch.saturating_add(1);
        record.signature = self.sign(&record)?;
        self.finish(&record, &mut |_| Ok(()))
      }
      Err(error) if error.kind() == io::ErrorKind::NotFound && self.record_absent(id) => {
        // No unit may be launched until its record has been durably published.
        fs::remove_file(self.path(id, "pending"))?;
        File::open(&self.root)?.sync_all()
      }
      Err(error) => { self.deny_and_stop_unverified(id)?; Err(error) },
    }
  }

  fn validate_authority(&self, record: &Record) -> io::Result<()> {
    if !record.enabled {
      return Err(invalid("plugin is not approved"));
    }
    let protected = crate::authority::ProtectedPaths::for_store(&self.root)?;
    for directory in record.grants.filesystem.values() {
      protected.check(directory)?;
      directory.open()?;
    }
    Revision::verify(&self.revisions(), &record.revision)?;
    let manifest = Manifest::read(&self.revisions().join(&record.revision))?;
    if manifest.id != record.id {
      return Err(invalid("revision identity mismatch"));
    }
    // A grant the (maybe newer) revision no longer requests is a re-review
    // situation, not a validation defect: surface it as such rather than as a
    // generic grants-validate failure, which would hide why the plugin can no
    // longer start.
    let unrequested = record.grants.unrequested(&manifest.sandbox.requests);
    if !unrequested.is_empty() {
      return Err(invalid(&format!(
        "this plugin's newer revision no longer requests these previously-approved permissions; re-review and re-approve before launching: {}",
        unrequested.join(", ")
      )));
    }
    record.grants.validate(&manifest.sandbox.requests)?;
    // A required grant that the approval did not cover must block activation
    // with an actionable explanation; it is never implied by the request. A
    // declined *optional* request does not block startup.
    let missing = record.grants.required_gap(&manifest.sandbox.requests);
    if !missing.is_empty() {
      return Err(invalid(&format!(
        "plugin requires the following access before it can start; approve each one first: {}",
        missing.join(", ")
      )));
    }
    Ok(())
  }

  fn record(&self, id: &str) -> io::Result<Record> {
    let record: Record = read_json(&self.path(id, "json"))?;
    if record.version != 1
      || record.id != id
      || record.epoch == 0
      || record.revision.len() != 64
      || !record
        .revision
        .bytes()
        .all(|byte| byte.is_ascii_digit() || (b'a'..=b'f').contains(&byte))
    {
      return Err(invalid("invalid plugin grant record"));
    }
    if let Some(unit) = &record.active_unit {
      validate_name(unit)?;
    }
    // Re-verify the review-minted signature: a hand-edited grants set (or a
    // record that bypassed the review tool) fails closed here and at launch.
    self.verify_signature(&record)?;
    Ok(record)
  }

  fn publish(
    &self,
    record: &mut Record,
    previous_unit: Option<&str>,
    mut checkpoint: impl FnMut(u8) -> io::Result<()>,
  ) -> io::Result<()> {
    // Re-mint the signature over the approved content and preflight the
    // serialized size before the pending marker exists. A record may be
    // exactly at the budget at approve() and still grow past it once launch()
    // attaches an active unit and bumps the epoch, so every publish transition
    // must be sized before committing any durable state. Rejecting here leaves
    // the prior usable record untouched.
    record.signature = self.sign(record)?;
    Self::check_record_size(record)?;
    let marker = OpenOptions::new()
      .write(true)
      .create_new(true)
      .mode(0o600)
      .open(self.path(&record.id, "pending"))?;
    marker.sync_all()?;
    checkpoint(1)?;
    File::open(&self.root)?.sync_all()?;
    checkpoint(2)?;
    if let Some(unit) = previous_unit {
      Unit::recover(unit)?.stop()?;
    }
    self.finish(record, &mut checkpoint)
  }

  fn finish(
    &self,
    record: &Record,
    checkpoint: &mut impl FnMut(u8) -> io::Result<()>,
  ) -> io::Result<()> {
    Self::check_record_size(record)?;
    let bytes = serde_json::to_vec(record).map_err(|_| invalid("could not encode grant record"))?;
    let mut temporary = tempfile::NamedTempFile::new_in(&self.root)?;
    temporary.write_all(&bytes)?;
    temporary.as_file().sync_all()?;
    checkpoint(3)?;
    temporary
      .persist(self.path(&record.id, "json"))
      .map_err(|error| error.error)?;
    checkpoint(4)?;
    File::open(&self.root)?.sync_all()?;
    checkpoint(5)?;
    fs::remove_file(self.path(&record.id, "pending"))?;
    checkpoint(6)?;
    File::open(&self.root)?.sync_all()?;
    checkpoint(7)
  }

  fn check_record_size(record: &Record) -> io::Result<()> {
    let bytes = serde_json::to_vec(record).map_err(|_| invalid("could not encode grant record"))?;
    if bytes.len() > MAX_PERSISTED_BYTES {
      return Err(invalid(&format!(
        "approved grant record is too large ({} bytes); reduce the number or length of selected directories",
        bytes.len()
      )));
    }
    Ok(())
  }

  fn lock(&self, id: &str) -> io::Result<File> {
    validate_id(id)?;
    let deadline = Instant::now() + Duration::from_secs(1);
    loop {
      let lock = OpenOptions::new()
        .read(true)
        .write(true)
        .create(true)
        .truncate(false)
        .mode(0o600)
        .custom_flags(libc::O_NOFOLLOW | libc::O_NONBLOCK)
        .open(self.path(id, "lock"))?;
      let metadata = lock.metadata()?;
      if !metadata.is_file() || metadata.nlink() != 1 || metadata.uid() != unsafe { libc::geteuid() } {
        return Err(invalid("invalid plugin writer lock"));
      }
      loop {
        if unsafe { libc::flock(lock.as_raw_fd(), libc::LOCK_EX | libc::LOCK_NB) } == 0 {
          match self.path(id, "lock").symlink_metadata() {
            Ok(current) if current.dev() == metadata.dev() && current.ino() == metadata.ino() => return Ok(lock),
            Ok(_) => break,
            Err(error) if error.kind() == io::ErrorKind::NotFound => break,
            Err(error) => return Err(error),
          }
        }
        let error = io::Error::last_os_error();
        if error.kind() != io::ErrorKind::WouldBlock || Instant::now() >= deadline {
          return Err(error);
        }
        std::thread::sleep(Duration::from_millis(10));
      }
      if Instant::now() >= deadline {
        return Err(io::Error::new(io::ErrorKind::WouldBlock, "plugin writer lock changed during removal"));
      }
    }
  }
  fn path(&self, id: &str, extension: &str) -> PathBuf {
    self.root.join(format!("{id}.{extension}"))
  }
  fn pending(&self, id: &str) -> io::Result<bool> {
    match self.path(id, "pending").symlink_metadata() {
      Ok(_) => Ok(true),
      Err(error) if error.kind() == io::ErrorKind::NotFound => Ok(false),
      Err(error) => Err(error),
    }
  }
  fn require_ready(&self, id: &str) -> io::Result<()> {
    if self.pending(id)? {
      Err(invalid(
        "interrupted grant publication requires explicit recovery",
      ))
    } else {
      Ok(())
    }
  }
}

fn validate_revision(revision: &str) -> io::Result<()> {
  if revision.len() == 64 && revision.bytes().all(|byte| byte.is_ascii_digit() || (b'a'..=b'f').contains(&byte)) {
    Ok(())
  } else { Err(invalid("invalid plugin revision")) }
}

fn remove_owned_path(path: &Path) -> io::Result<()> {
  match path.symlink_metadata() {
    Ok(metadata) if metadata.is_dir() => fs::remove_dir_all(path),
    Ok(_) => fs::remove_file(path),
    Err(error) if error.kind() == io::ErrorKind::NotFound => Ok(()),
    Err(error) => Err(error),
  }
}

fn next_epoch(epoch: u64) -> io::Result<u64> {
  epoch
    .checked_add(1)
    .ok_or_else(|| invalid("grant epoch exhausted"))
}

#[cfg(test)]
mod tests {
  use super::*;
  use std::{
    os::unix::fs::PermissionsExt,
    process::{Command, Stdio},
  };

  fn fixture() -> (tempfile::TempDir, Store, Revision) {
    let root = tempfile::Builder::new()
      .permissions(fs::Permissions::from_mode(0o700))
      .tempdir()
      .unwrap();
    let source = root.path().join("source");
    fs::create_dir(&source).unwrap();
    fs::write(
      source.join("worker.qml"),
      "import Quickshell\nShellRoot {}\n",
    )
    .unwrap();
    fs::write(source.join("manifest.json"), serde_json::to_vec(&serde_json::json!({
      "schemaVersion": 1, "id": "test.widget", "name": "Test", "version": "1", "kinds": ["barWidget"],
      "entryPoints": {"barWidget": "worker.qml"}, "sandbox": {"version": 1, "entryPoint": "worker.qml",
        "requests": {"network": true, "storage": true, "filesystem": [{"name": "files", "path": root.path().join("state-not-authority"), "access": "readwrite"}]}}
    })).unwrap()).unwrap();
    let store = Store::initialize(&root.path().join("state")).unwrap();
    let revision = Revision::import(&source, &store.revisions()).unwrap();
    (root, store, revision)
  }

  #[test]
  fn removal_purges_owned_revisions_and_identity_but_not_other_plugins_or_sources() {
    let (root, store, first) = fixture();
    let source = root.path().join("source");
    store.approve(&first.digest, Grants::default()).unwrap();
    fs::write(source.join("worker.qml"), "second revision").unwrap();
    let second = store.import(&source).unwrap();
    // Ownership records also cover revisions whose manifest later gets damaged.
    fs::write(second.path.join("manifest.json"), "damaged").unwrap();
    fs::write(source.join("worker.qml"), "legacy unapproved snapshot").unwrap();
    let legacy = Revision::import(&source, &store.revisions()).unwrap();
    let mut manifest: serde_json::Value = read_json(&source.join("manifest.json")).unwrap();
    manifest["id"] = "test.other".into();
    fs::write(source.join("manifest.json"), serde_json::to_vec(&manifest).unwrap()).unwrap();
    let other = store.import(&source).unwrap();
    store.approve(&other.digest, Grants::default()).unwrap();
    store.revoke("test.widget").unwrap();
    assert!(first.path.exists() && second.path.exists() && legacy.path.exists());
    assert!(store.root.join("identities/test.widget").exists());
    fs::remove_file(store.signing_key_path()).unwrap();
    store.remove("test.widget").unwrap();
    for revision in [first, second, legacy] { assert!(!revision.path.exists()); }
    for suffix in ["json", "pending", "lock"] { assert!(!store.path("test.widget", suffix).exists()); }
    assert!(!store.root.join("identities/test.widget").exists());
    assert!(other.path.exists() && store.read("test.other").unwrap().enabled);
    assert!(source.join("manifest.json").exists() && store.signing_pub_path().exists());
    store.remove("test.widget").unwrap();
    assert!(!store.path("test.widget", "lock").exists());
    assert!(store.remove("../source").is_err());
  }

  #[test]
  fn removal_failure_keeps_denial_and_ownership_for_retry() {
    let (_root, store, revision) = fixture();
    store.approve(&revision.digest, Grants::default()).unwrap();
    fs::set_permissions(&revision.path, fs::Permissions::from_mode(0o500)).unwrap();
    assert!(store.remove("test.widget").is_err());
    assert!(store.pending("test.widget").unwrap());
    assert!(store.path("test.widget", "json").exists());
    assert!(store.root.join("identities/test.widget").exists());
    assert!(store.read("test.widget").is_err());
    fs::set_permissions(&revision.path, fs::Permissions::from_mode(0o700)).unwrap();
    store.remove("test.widget").unwrap();
    assert!(!revision.path.exists() && !store.path("test.widget", "json").exists());
  }

  #[test]
  fn removal_refuses_to_forget_an_unverifiable_controller_record() {
    let (_root, store, revision) = fixture();
    store.approve(&revision.digest, Grants::default()).unwrap();
    fs::write(store.path("test.widget", "json"), "damaged record").unwrap();
    assert!(store.remove("test.widget").is_err());
    assert!(store.pending("test.widget").unwrap());
    assert!(revision.path.exists() && store.root.join("identities/test.widget").exists());
  }

  #[test]
  fn lock_waiters_retry_an_inode_retired_by_removal() {
    let (_root, store, _revision) = fixture();
    let held = store.lock("test.widget").unwrap();
    let original = held.metadata().unwrap().ino();
    let root = store.root.clone();
    let (started, waiting) = std::sync::mpsc::channel();
    let waiter = std::thread::spawn(move || {
      let store = Store::open(&root).unwrap();
      started.send(()).unwrap();
      let lock = store.lock("test.widget").unwrap();
      assert_ne!(lock.metadata().unwrap().ino(), original);
      assert_eq!(lock.metadata().unwrap().ino(), store.path("test.widget", "lock").metadata().unwrap().ino());
    });
    waiting.recv().unwrap();
    std::thread::sleep(Duration::from_millis(30));
    fs::remove_file(store.path("test.widget", "lock")).unwrap();
    drop(held);
    waiter.join().unwrap();
  }

  #[test]
  fn removal_stops_the_recorded_service_before_forgetting_authority() {
    if std::env::var("OMARCHY_TEST_SYSTEMD").as_deref() != Ok("1") { return; }
    let (_root, store, revision) = fixture();
    let mut record = store.approve(&revision.digest, Grants::default()).unwrap();
    let unit = Unit::prepare().unwrap();
    record.active_unit = Some(unit.name().into());
    store.publish(&mut record, None, |_| Ok(())).unwrap();
    let unit = unit.launch(Path::new("/usr/bin/sleep"), &[std::ffi::OsStr::new("30")], Limits::default()).unwrap();
    assert!(unit.running().unwrap());
    fs::remove_file(store.signing_key_path()).unwrap();
    store.remove("test.widget").unwrap();
    assert!(!unit.running().unwrap());
    assert!(!store.path("test.widget", "json").exists() && !revision.path.exists());
  }

  #[test]
  fn stale_session_cleanup_preserves_newer_and_denied_authority() {
    let (_root, store, revision) = fixture();
    let mut record = store.approve(&revision.digest, Grants::default()).unwrap();
    let unit = Unit::prepare().unwrap();
    record.active_unit = Some(unit.name().into());
    record.epoch += 1;
    let original = serde_json::to_vec(&record).unwrap();
    fs::write(store.path(&record.id, "json"), &original).unwrap();
    store.finish_session(&record.id, record.epoch - 1, unit.name()).unwrap();
    assert_eq!(fs::read(store.path(&record.id, "json")).unwrap(), original);
    store.finish_session(&record.id, record.epoch, Unit::prepare().unwrap().name()).unwrap();
    assert_eq!(fs::read(store.path(&record.id, "json")).unwrap(), original);
    store.mark_denied(&record.id).unwrap();
    store.finish_session(&record.id, record.epoch, unit.name()).unwrap();
    assert!(store.pending(&record.id).unwrap());
    assert_eq!(fs::read(store.path(&record.id, "json")).unwrap(), original);
    assert!(store.read(&record.id).is_err());
  }

  #[test]
  fn failed_service_exec_retires_reservation_without_revoking_approval() {
    if std::env::var("OMARCHY_TEST_SYSTEMD").as_deref() != Ok("1") {
      return;
    }
    let (root, store, revision) = fixture();
    let approved = store.approve(&revision.digest, Grants::default()).unwrap();
    assert!(store.launch(&approved.id, &root.path().join("missing-controller"), &root.path().join("host")).is_err());
    let stopped = store.read(&approved.id).unwrap();
    assert!(stopped.enabled);
    assert!(stopped.active_unit.is_none());
    assert_eq!(stopped.signature, approved.signature);
    assert!(stopped.epoch > approved.epoch);
    store.approve(&revision.digest, Grants::default()).unwrap();
  }

  /// Build a store + revision whose manifest declares `count` optional
  /// filesystem slots (each with the maximum legal 96-character name) and
  /// returns them along with a data root holding a selected directory for
  /// every slot.
  fn filesystem_fixture(
    count: usize,
    deep: bool,
  ) -> (
    tempfile::TempDir,
    Store,
    Revision,
    Vec<String>,
    std::path::PathBuf,
  ) {
    let root = tempfile::Builder::new()
      .permissions(fs::Permissions::from_mode(0o700))
      .tempdir()
      .unwrap();
    let source = root.path().join("source");
    fs::create_dir(&source).unwrap();
    fs::write(
      source.join("worker.qml"),
      "import Quickshell\nShellRoot {}\n",
    )
    .unwrap();
    let names: Vec<String> = (0..count)
      .map(|i| format!("grant-{i:04}-{}", "n".repeat(85)))
      .collect();
    let data = if deep {
      root.path().join(format!("deep-{}", "y".repeat(140)))
    } else {
      root.path().join("data")
    };
    fs::create_dir(&data).unwrap();
    for i in 0..count {
      fs::create_dir(data.join(format!("d{i}"))).unwrap();
    }
    let requested = root.path().join("requested");
    std::os::unix::fs::symlink(&data, &requested).unwrap();
    fs::write(
      source.join("manifest.json"),
      serde_json::to_vec(&serde_json::json!({
        "schemaVersion": 1, "id": "size.widget", "name": "S", "version": "1", "kinds": ["barWidget"],
        "entryPoints": {"barWidget": "worker.qml"}, "sandbox": {"version": 1, "entryPoint": "worker.qml",
          "requests": {"filesystem": names.iter().enumerate().map(|(i, name)| crate::grants::FileSystemRequest::optional(name, requested.join(format!("d{i}")).to_str().unwrap())).collect::<Vec<_>>()}}
      }))
      .unwrap(),
    )
    .unwrap();
    let store = Store::initialize(&root.path().join("state")).unwrap();
    let revision = Revision::import(&source, &store.revisions()).unwrap();
    (root, store, revision, names, data)
  }

  fn select_all<P: AsRef<Path>>(data: &P, names: &[String]) -> Grants {
    use crate::grants::{Access, FileSystemGrant, Target};
    let mut grants = Grants::default();
    for (i, name) in names.iter().enumerate() {
      grants.filesystem.insert(
        name.clone(),
        FileSystemGrant::select(
          &data.as_ref().join(format!("d{i}")),
          Access::Read,
          Target::Directory,
        )
        .unwrap(),
      );
    }
    grants
  }

  #[test]
  fn max_count_filesystem_grants_round_trip_within_the_persisted_budget() {
    use crate::grants::MAX_GRANTED_DIRS;
    let (_root, store, revision, names, data) = filesystem_fixture(MAX_GRANTED_DIRS, false);
    let grants = select_all(&data, &names);
    let record = store.approve(&revision.digest, grants).unwrap();
    assert_eq!(record.grants.filesystem.len(), MAX_GRANTED_DIRS);
    let persisted = serde_json::to_vec(&record).unwrap();
    assert!(
      persisted.len() <= MAX_PERSISTED_BYTES,
      "max-count record exceeds the persisted budget: {} bytes",
      persisted.len()
    );
    // The persisted file is smaller than the in-memory JSON (no pretty format)
    // and reopens through the capped read path without truncation.
    let reopened = store.read("size.widget").unwrap();
    assert_eq!(reopened.grants.filesystem.len(), MAX_GRANTED_DIRS);
    assert_eq!(reopened.revision, revision.digest);
  }

  #[test]
  fn oversize_approval_is_rejected_before_publishing_or_poisoning() {
    use crate::grants::MAX_GRANTED_DIRS;
    // A realistic shorter-path record first, so there is a prior usable
    // approval to guarantee is left untouched by a rejected oversize attempt.
    let (_root, store, revision, all_names, _data) = filesystem_fixture(MAX_GRANTED_DIRS, false);
    let tiny = store
      .approve(&revision.digest, select_all(&_data, &all_names[0..1]))
      .unwrap();
    assert!(!store.pending("size.widget").unwrap());
    // The oversize attempt mounts the same slots under a very deep path so the
    // persisted record would exceed the 64 KiB cap while still validating and
    // opening every selected directory.
    let deep = _root.path().join(format!("deep-{}", "y".repeat(140)));
    fs::create_dir(&deep).unwrap();
    for i in 0..all_names.len() {
      fs::create_dir(deep.join(format!("d{i}"))).unwrap();
    }
    let requested = _root.path().join("requested-deep");
    std::os::unix::fs::symlink(&deep, &requested).unwrap();
    let source = _root.path().join("source");
    let mut manifest: serde_json::Value = read_json(&source.join("manifest.json")).unwrap();
    for (i, request) in manifest["sandbox"]["requests"]["filesystem"].as_array_mut().unwrap().iter_mut().enumerate() {
      request["path"] = serde_json::json!(requested.join(format!("d{i}")));
    }
    fs::write(source.join("manifest.json"), serde_json::to_vec(&manifest).unwrap()).unwrap();
    let deep_revision = Revision::import(&source, &store.revisions()).unwrap();
    let oversize = select_all(&deep, &all_names);
    let error = store.approve(&deep_revision.digest, oversize).unwrap_err();
    let message = error.to_string();
    assert!(message.contains("too large"), "unexpected error: {message}");
    // No pending marker was created, and the prior usable approval is intact.
    assert!(!store.pending("size.widget").unwrap());
    let current = store.read("size.widget").unwrap();
    assert_eq!(current.grants.filesystem.len(), 1);
    assert_eq!(current.epoch, tiny.epoch);
    assert_eq!(current.revision, revision.digest);
    store.validate_authority(&current).unwrap();
  }

  #[test]
  fn launch_growth_oversize_is_rejected_before_pending_preserving_prior_approval() {
    use crate::grants::{Access as GrantAccess, FileSystemGrant, Target};
    let root = tempfile::Builder::new()
      .permissions(fs::Permissions::from_mode(0o700))
      .tempdir()
      .unwrap();
    let store = Store::initialize(&root.path().join("state")).unwrap();
    // The active-unit string below is long only to widen the "growth band"
    // (its serialized contribution) past the per-grant step, so the boundary
    // count is hit deterministically; the mechanism is identical for a real
    // short unit name that pushes an already-near-limit record over the cap.
    let unit: String = format!("unit-{}", "x".repeat(2000));
    let mut count = 0usize;
    loop {
      let mut grants = Grants::default();
      for i in 0..=count {
        grants.filesystem.insert(
          format!("g{i}"),
          FileSystemGrant {
            path: format!("/data/d{i:04}/{}", "y".repeat(520)).into(),
            device: 1,
            inode: i as u64 + 1,
            access: GrantAccess::Read,
            target: Target::Directory,
          },
        );
      }
      let mut base = Record {
        version: 1,
        id: "size.widget".into(),
        revision: "ab".repeat(32),
        epoch: 1,
        enabled: true,
        grants,
        active_unit: None,
        signature: String::new(),
      };
      let mut grown = Record {
        active_unit: Some(unit.clone()),
        ..base.clone()
      };
      let base_size = serde_json::to_vec(&base).unwrap().len();
      let grown_size = serde_json::to_vec(&grown).unwrap().len();
      if base_size <= MAX_PERSISTED_BYTES && grown_size > MAX_PERSISTED_BYTES {
        // Commit the bare approval as the usable prior state.
        store.publish(&mut base, None, |_| Ok(())).unwrap();
        assert!(!store.pending("size.widget").unwrap());
        // launch()'s growth (active unit + epoch bump) must be rejected before
        // publish() creates a pending marker, so the prior approval is kept.
        let error = store.publish(&mut grown, None, |_| Ok(())).unwrap_err();
        assert!(error.to_string().contains("too large"));
        assert!(!store.pending("size.widget").unwrap());
        let current = store.read("size.widget").unwrap();
        assert!(current.enabled);
        assert_eq!(current.epoch, 1);
        assert_eq!(current.active_unit, None);
        assert_eq!(current.grants.filesystem.len(), count + 1);
        return;
      }
      if count > crate::grants::MAX_GRANTED_DIRS * 2 {
        panic!("could not construct a budget-boundary grant set");
      }
      count += 1;
    }
  }

  #[test]
  fn grants_are_revision_bound_and_revocation_is_not_approval() {
    let (_root, store, revision) = fixture();
    let approved = store.approve(&revision.digest, Grants::default()).unwrap();
    assert!(approved.enabled && !approved.grants.network);
    assert_eq!(store.read("test.widget").unwrap().revision, revision.digest);
    assert!(
      store
        .approve(
          &revision.digest,
          Grants {
            notifications: true,
            ..Grants::default()
          }
        )
        .is_err()
    );
    store.revoke("test.widget").unwrap();
    let revoked = store.read("test.widget").unwrap();
    assert!(!revoked.enabled && revoked.epoch > approved.epoch);
    assert!(store.validate_authority(&revoked).is_err());
    let approved = store
      .approve(
        &revision.digest,
        Grants {
          network: true,
          ..Grants::default()
        },
      )
      .unwrap();
    assert!(approved.epoch > revoked.epoch);
    let mut record = approved.clone();
    let reservation = Unit::prepare().unwrap();
    record.active_unit = Some(reservation.name().into());
    store.publish(&mut record, None, |_| Ok(())).unwrap();
    assert!(
      store
        .with_authority("test.widget", revoked.epoch, reservation.name(), |_| Ok(()))
        .is_err()
    );
    assert!(
      store
        .with_authority("test.widget", record.epoch, "wrong", |_| Ok(()))
        .is_err()
    );
    store
      .with_authority("test.widget", record.epoch, reservation.name(), |_| Ok(()))
      .unwrap();
    assert!(store.approve(&revision.digest, Grants::default()).is_err());
    fs::write(revision.path.join("worker.qml"), "modified").unwrap();
    assert!(store.validate_authority(&record).is_err());
  }

  #[test]
  fn filesystem_approval_cannot_expose_authority_or_its_aliases() {
    use crate::grants::{Access, FileSystemGrant, Target};
    use std::os::unix::fs::symlink;
    let (root, store, _revision) = fixture();
    let alias = root.path().join("alias");
    symlink(&store.root, &alias).unwrap();
    let sibling = root.path().join("state-not-authority");
    fs::create_dir(&sibling).unwrap();
    let revision_for = |path: &Path, access: Access| {
      let source = root.path().join("source");
      let mut manifest: serde_json::Value = read_json(&source.join("manifest.json")).unwrap();
      manifest["sandbox"]["requests"]["filesystem"][0]["path"] = serde_json::json!(path);
      manifest["sandbox"]["requests"]["filesystem"][0]["access"] = serde_json::json!(access);
      fs::write(source.join("manifest.json"), serde_json::to_vec(&manifest).unwrap()).unwrap();
      Revision::import(&source, &store.revisions()).unwrap()
    };
    for access in [Access::Read, Access::ReadWrite] {
      for selected in [&store.root, &store.secrets_dir(), root.path(), &alias] {
        let revision = revision_for(selected, access);
        let grant = FileSystemGrant::select(selected, access, Target::Directory).unwrap();
        let error = store.approve(&revision.digest, Grants {
          filesystem: [("files".into(), grant)].into(), ..Grants::default()
        }).unwrap_err();
        assert!(error.to_string().contains("host authority"), "{error}");
        assert!(!store.path("test.widget", "json").exists());
      }
      let revision = revision_for(&sibling, access);
      let grant = FileSystemGrant::select(&sibling, access, Target::Directory).unwrap();
      store.approve(&revision.digest, Grants {
        filesystem: [("files".into(), grant)].into(), ..Grants::default()
      }).unwrap();
      store.revoke("test.widget").unwrap();
      fs::remove_file(store.path("test.widget", "json")).unwrap();
    }
    let key_alias = sibling.join("key-alias");
    fs::hard_link(store.signing_key_path(), &key_alias).unwrap();
    let grant = FileSystemGrant::select(&sibling, Access::Read, Target::Directory).unwrap();
    let revision = revision_for(&sibling, Access::Read);
    assert!(store.approve(&revision.digest, Grants {
      filesystem: [("files".into(), grant)].into(), ..Grants::default()
    }).unwrap_err().to_string().contains("single-link"));
  }

  #[test]
  fn old_signed_authority_grants_are_rejected_at_admission() {
    use crate::grants::{Access, FileSystemGrant, Target};
    let (_root, store, revision) = fixture();
    let mut old = store.approve(&revision.digest, Grants::default()).unwrap();
    old.grants.filesystem.insert("files".into(),
      FileSystemGrant::select(&store.root, Access::Read, Target::Directory).unwrap());
    // Simulate a valid signed approval produced by the pre-fix release.
    store.publish(&mut old, None, |_| Ok(())).unwrap();
    assert!(store.validate_authority(&old).unwrap_err().to_string().contains("host authority"));
  }

  #[test]
  fn missing_verification_key_cannot_replace_an_existing_approval() {
    let (_root, store, revision) = fixture();
    store.approve(&revision.digest, Grants::default()).unwrap();
    let before = fs::read(store.path("test.widget", "json")).unwrap();
    fs::remove_file(store.signing_pub_path()).unwrap();
    assert!(store.approve(&revision.digest, Grants::default()).is_err());
    assert_eq!(fs::read(store.path("test.widget", "json")).unwrap(), before);
  }

  #[test]
  fn revocation_signing_failure_leaves_durable_denial_until_recovery() {
    let (_root, store, revision) = fixture();
    store.approve(&revision.digest, Grants::default()).unwrap();
    let backup = store.secrets_dir().join("signing.saved");
    fs::rename(store.signing_key_path(), &backup).unwrap();
    assert!(Store::initialize(&store.root).is_err(), "review must not replace a missing signing key");
    assert!(!store.signing_key_path().exists());
    assert!(store.revoke("test.widget").is_err());
    assert!(store.pending("test.widget").unwrap());
    assert!(store.read("test.widget").is_err());
    assert!(store.approve(&revision.digest, Grants::default()).is_err());
    fs::rename(backup, store.signing_key_path()).unwrap();
    store.recover("test.widget").unwrap();
    assert!(!store.read("test.widget").unwrap().enabled);
  }

  #[test]
  fn revocation_stops_live_service_before_failed_signing() {
    if std::env::var("OMARCHY_TEST_SYSTEMD").as_deref() != Ok("1") {
      eprintln!("SKIP: set OMARCHY_TEST_SYSTEMD=1 for real revocation service test");
      return;
    }
    let (_root, store, revision) = fixture();
    let mut record = store.approve(&revision.digest, Grants::default()).unwrap();
    let unit = Unit::prepare().unwrap();
    record.active_unit = Some(unit.name().into());
    store.publish(&mut record, None, |_| Ok(())).unwrap();
    let unit = unit.launch(Path::new("/usr/bin/sleep"), &[std::ffi::OsStr::new("30")], Limits::default()).unwrap();
    assert!(unit.running().unwrap());
    fs::rename(store.signing_key_path(), store.secrets_dir().join("signing.saved")).unwrap();
    assert!(store.revoke("test.widget").is_err());
    assert!(!unit.running().unwrap(), "signing failure must not leave the service running");
    assert!(store.pending("test.widget").unwrap());
    assert!(store.with_authority("test.widget", record.epoch, unit.name(), |_| Ok(())).is_err());
  }

  #[test]
  fn publication_crash_child() {
    let Some(root) = std::env::var_os("OMARCHY_STORE_CRASH_ROOT") else {
      return;
    };
    let stage: u8 = std::env::var("OMARCHY_STORE_CRASH_STAGE")
      .unwrap()
      .parse()
      .unwrap();
    let store = Store::open(Path::new(&root)).unwrap();
    let _lock = store.lock("test.widget").unwrap();
    let mut record = store.record("test.widget").unwrap();
    record.epoch += 1;
    record.grants.network = true;
    store
      .publish(&mut record, None, |checkpoint| {
        if checkpoint == stage {
          unsafe {
            libc::_exit(71);
          }
        }
        Ok(())
      })
      .unwrap();
    panic!("crash checkpoint was not reached");
  }

  #[test]
  fn publication_errors_and_process_crashes_have_explicit_recovery() {
    for crash in [false, true] {
      for stage in 1..=7 {
        let (_root, store, revision) = fixture();
        let approved = store.approve(&revision.digest, Grants::default()).unwrap();
        if crash {
          let status = Command::new(std::env::current_exe().unwrap())
            .args([
              "--exact",
              "store::tests::publication_crash_child",
              "--nocapture",
            ])
            .env("OMARCHY_STORE_CRASH_ROOT", &store.root)
            .env("OMARCHY_STORE_CRASH_STAGE", stage.to_string())
            .stdout(Stdio::null())
            .status()
            .unwrap();
          assert_eq!(status.code(), Some(71));
        } else {
          let mut next = approved.clone();
          next.epoch += 1;
          next.grants.network = true;
          let _lock = store.lock("test.widget").unwrap();
          assert!(
            store
              .publish(&mut next, None, |checkpoint| {
                if checkpoint == stage {
                  Err(io::Error::other("injected filesystem failure"))
                } else {
                  Ok(())
                }
              })
              .is_err()
          );
        }
        let reopened = Store::open(&store.root).unwrap();
        if stage <= 5 {
          assert!(
            reopened.read("test.widget").is_err(),
            "pending transaction was admitted"
          );
          assert!(
            reopened
              .approve(&revision.digest, Grants::default())
              .is_err()
          );
          reopened.recover("test.widget").unwrap();
          let recovered = reopened.read("test.widget").unwrap();
          assert!(
            !recovered.enabled,
            "recovery must not finish an interrupted approval"
          );
        } else {
          // Marker removal is the visibility commit point. The record was
          // already synchronized; a missing acknowledgement may still commit
          // exactly the authority approved by this operation, never other data.
          let committed = reopened.read("test.widget").unwrap();
          assert!(committed.enabled && committed.grants.network);
          assert_eq!(committed.revision, approved.revision);
          assert_eq!(committed.epoch, approved.epoch + 1);
        }
      }
    }
  }

  #[test]
  fn malformed_state_and_writer_contention_fail_closed() {
    let (_root, store, revision) = fixture();
    store.approve(&revision.digest, Grants::default()).unwrap();
    let lock = store.lock("test.widget").unwrap();
    let root = store.root.clone();
    let digest = revision.digest.clone();
    let writer = std::thread::spawn(move || {
      Store::open(&root)
        .unwrap()
        .approve(&digest, Grants::default())
        .unwrap_err()
    });
    assert_eq!(writer.join().unwrap().kind(), io::ErrorKind::WouldBlock);
    drop(lock);
    assert!(store.read("test.widget").unwrap().enabled);
    fs::write(store.path("test.widget", "json"), b"{invalid").unwrap();
    assert!(store.read("test.widget").is_err());
    assert!(store.approve(&revision.digest, Grants::default()).is_err());
    assert!(store.read("../escape").is_err());
  }

  #[test]
  fn exhausted_epoch_cannot_prevent_revocation() {
    let (_root, store, revision) = fixture();
    let mut record = store.approve(&revision.digest, Grants::default()).unwrap();
    record.epoch = u64::MAX;
    store.publish(&mut record, None, |_| Ok(())).unwrap();
    assert!(store.approve(&revision.digest, Grants::default()).is_err());
    store.revoke("test.widget").unwrap();
    assert!(!store.read("test.widget").unwrap().enabled);
  }

  #[test]
  fn stop_clears_active_unit_without_disabling() {
    let (_root, store, revision) = fixture();
    let approved = store.approve(&revision.digest, Grants::default()).unwrap();
    let unit = Unit::prepare().unwrap();
    let mut running = approved.clone();
    running.active_unit = Some(unit.name().into());
    running.epoch += 1;
    store.publish(&mut running, None, |_| Ok(())).unwrap();
    // approve() must refuse while an instance is running.
    assert!(store.approve(&revision.digest, Grants::default()).is_err());
    // stop() is non-destructive: it clears the active unit and advances the
    // epoch (so stale host leases die) but keeps the approval enabled.
    let stopped = store.stop("test.widget").unwrap();
    assert!(stopped.enabled, "stop must keep approval enabled");
    assert_eq!(stopped.active_unit, None);
    assert!(stopped.epoch > running.epoch);
    // Re-approval is now possible without a destructive revoke.
    let reapproved = store.approve(&revision.digest, Grants::default()).unwrap();
    assert!(reapproved.enabled);
    assert!(reapproved.epoch > stopped.epoch);
  }

  #[test]
  fn tampered_grant_record_fails_verification() {
    let (_root, store, revision) = fixture();
    let record = store.approve(&revision.digest, Grants::default()).unwrap();
    assert!(record.enabled);
    // Simulate a user hand-editing grants.json to self-grant network access by
    // writing straight to the store file, bypassing publish()'s re-signing.
    let mut edited: Record = serde_json::from_slice(
      &fs::read(store.path("test.widget", "json")).unwrap(),
    )
    .unwrap();
    edited.grants.network = true;
    fs::write(
      store.path("test.widget", "json"),
      serde_json::to_vec(&edited).unwrap(),
    )
    .unwrap();
    let error = store.read("test.widget").unwrap_err();
    assert!(error.to_string().contains("signature"), "{error}");
    assert!(store.approve(&revision.digest, Grants::default()).is_err());
  }

  #[test]
  fn new_revision_removing_capability_requires_review() {
    let (root, store, revision) = fixture();
    // Approve network access against the original revision, which requests it.
    let record = store
      .approve(
        &revision.digest,
        crate::grants::Grants {
          network: true,
          ..crate::grants::Grants::default()
        },
      )
      .unwrap();
    assert!(record.grants.network);
    // The plugin updates to a newer revision that drops the network request.
    let source2 = root.path().join("source2");
    fs::create_dir(&source2).unwrap();
    fs::write(
      source2.join("worker.qml"),
      "import Quickshell\nShellRoot {}\n",
    )
    .unwrap();
    fs::write(
      source2.join("manifest.json"),
      serde_json::to_vec(&serde_json::json!({
        "schemaVersion": 1, "id": "test.widget", "name": "Test", "version": "2",
        "kinds": ["barWidget"], "entryPoints": {"barWidget": "worker.qml"},
        "sandbox": {"version": 1, "entryPoint": "worker.qml",
          "requests": {"storage": true, "filesystem": [{"name": "files", "path": root.path().join("state-not-authority")}]}}
      }))
      .unwrap(),
    )
    .unwrap();
    let newer = Revision::import(&source2, &store.revisions()).unwrap();
    assert_ne!(newer.digest, revision.digest);
    // Repoint the approval at the newer revision and re-publish (re-signed).
    let mut record = store.record("test.widget").unwrap();
    record.revision = newer.digest.clone();
    store.publish(&mut record, None, |_| Ok(())).unwrap();
    // Activation must report re-review rather than a generic validation error.
    let error = store
      .validate_authority(&store.read("test.widget").unwrap())
      .unwrap_err();
    assert!(error.to_string().contains("no longer requests"), "{error}");
    assert!(error.to_string().contains("network"), "{error}");
  }
}
