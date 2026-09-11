//! Administrative operations for the trusted plugin-review surface. This is a
//! local CLI boundary, never an endpoint exposed to sandboxed workers.
use crate::{
  grants::{Access, FileSystemGrant, Grants, Manifest, invalid, validate_id},
  revision::Revision,
  store::Store,
};
use serde::Deserialize;
use serde_json::{Value, json};
use std::{
  collections::{BTreeMap, BTreeSet},
  fs,
  io::{self, Read, Write},
  os::unix::fs::PermissionsExt,
  path::{Path, PathBuf},
};

#[derive(Deserialize)]
#[serde(tag = "operation", rename_all = "camelCase", deny_unknown_fields)]
enum Request {
  List,
  Import {
    path: PathBuf,
  },
  Preview {
    path: PathBuf,
  },
  Approve {
    id: String,
    revision: String,
    selections: Selections,
  },
  Revoke {
    id: String,
  },
  Remove {
    id: String,
  },
  Stop {
    id: String,
  },
  Recover {
    id: String,
  },
}

#[derive(Default, Deserialize)]
#[serde(default, deny_unknown_fields)]
struct Selections {
  read: BTreeSet<String>,
  write: BTreeSet<String>,
  network: bool,
  #[serde(rename = "networkProxy")]
  network_proxy: bool,
  http: BTreeSet<String>,
  exec: BTreeMap<String, BTreeSet<String>>,
  media: bool,
  notifications: bool,
  #[serde(rename = "audioPlayback")]
  audio_playback: bool,
  microphone: bool,
  #[serde(rename = "audioCapture")]
  audio_capture: bool,
  settings: crate::settings::Grant,
  #[serde(rename = "openUrls")]
  open_urls: bool,
  storage: bool,
  #[serde(rename = "desktopGeometry")]
  desktop_geometry: bool,
}

pub fn run(root: &Path) -> io::Result<()> {
  let mut bytes = Vec::new();
  io::stdin().take(65_537).read_to_end(&mut bytes)?;
  let result = execute(root, &bytes);
  let response = match result {
    Ok(value) => json!({"ok": true, "value": value}),
    Err(error) => json!({"ok": false, "error": error.to_string()}),
  };
  serde_json::to_writer(io::stdout().lock(), &response)?;
  io::stdout().write_all(b"\n")
}

fn execute(root: &Path, bytes: &[u8]) -> io::Result<Value> {
  if bytes.len() > 65_536 {
    return Err(invalid("management request is too large"));
  }
  let request: Request =
    serde_json::from_slice(bytes).map_err(|_| invalid("invalid management request"))?;
  if !root.is_absolute() {
    return Err(invalid("plugin store must have an absolute path"));
  }
  if matches!(request, Request::List) && !root.exists() {
    return Ok(json!([]));
  }
  if let Request::Revoke { id } | Request::Remove { id } = &request {
    validate_id(id)?;
    if !root.exists() {
      return Ok(Value::Null);
    }
  }
  if let Request::Preview { path } = &request {
    if !path.is_absolute() { return Err(invalid("select an absolute plugin folder")); }
    // A staged review is not an installation. Keep its snapshot ephemeral so
    // closing or denying the review leaves no persistent identity/history.
    let temporary = tempfile::Builder::new().permissions(fs::Permissions::from_mode(0o700)).tempdir()?;
    let revision = Revision::import(path, temporary.path())?;
    return review_revision(temporary.path(), &revision.digest);
  }
  let store = if matches!(request, Request::Import { .. }) {
    Store::initialize(root)?
  } else {
    Store::open(root)?
  };
  match request {
    Request::List => {
      let mut ids = BTreeSet::new();
      for entry in fs::read_dir(root)? {
        let entry = entry?;
        let name = entry.file_name();
        let Some(name) = name.to_str() else {
          continue;
        };
        if let Some(id) = name
          .strip_suffix(".json")
          .or_else(|| name.strip_suffix(".pending"))
        {
          validate_id(id)?;
          ids.insert(id.to_owned());
          if ids.len() > 128 {
            return Err(invalid("too many plugin records"));
          }
        }
      }
      let rows = ids
        .into_iter()
        .map(|id| {
          let row = (|| {
            let record = store.read(&id)?;
            let mut row = review(&store, &record.revision)?;
            // Admission is not a running session. The shell owns live status;
            // a recorded unit alone may be left over from a closed host item.
            row["approved"] = json!(record.enabled);
            row["activeUnit"] = json!(record.active_unit);
            row["grants"] = json!(record.grants);
            Ok::<_, io::Error>(row)
          })();
          row.unwrap_or_else(
            |error| json!({"id": id, "name": id, "enabled": false, "error": error.to_string()}),
          )
        })
        .collect::<Vec<_>>();
      Ok(json!(rows))
    }
    Request::Import { path } => {
      if !path.is_absolute() {
        return Err(invalid("select an absolute plugin folder"));
      }
      let revision = store.import(&path)?;
      review(&store, &revision.digest)
    }
    Request::Approve {
      id,
      revision,
      selections,
    } => {
      validate_id(&id)?;
      if review(&store, &revision)?["id"] != id {
        return Err(invalid("reviewed revision belongs to a different plugin"));
      }
      let manifest = Manifest::read(&store.revisions().join(&revision))?;
      let mut grants = Grants {
        network: selections.network,
        network_proxy: selections.network_proxy,
        media: if selections.media {
          Some(manifest.sandbox.requests.media.as_ref()
            .ok_or_else(|| invalid("media permission was not requested by this revision"))?.service.clone())
        } else { None },
        notifications: selections.notifications,
        audio_playback: selections.audio_playback,
        microphone: selections.microphone,
        audio_capture: selections.audio_capture,
        settings: selections.settings,
        open_urls: selections.open_urls,
        storage: selections.storage,
        desktop_geometry: selections.desktop_geometry,
        ..Grants::default()
      };
      for name in selections.http {
        let ask = manifest
          .sandbox
          .requests
          .http
          .get(&name)
          .ok_or_else(|| invalid("HTTP scope was not requested by this revision"))?;
        grants.http.insert(name, ask.scope.clone());
      }
      for (name, leaves) in selections.exec {
        let ask = manifest
          .sandbox
          .requests
          .exec
          .get(&name)
          .ok_or_else(|| invalid("host executable was not requested by this revision"))?;
        grants
          .exec
          .insert(name, crate::exec::Grant::select(ask, leaves)?);
      }
      for (names, access) in [(&selections.read, Access::Read), (&selections.write, Access::ReadWrite)] {
        for name in names {
        if access.writable() && selections.read.contains(name) {
          return Err(invalid(
            "a filesystem permission cannot be both read-only and writable",
          ));
        }
        let ask = manifest.sandbox.requests.filesystem.iter().find(|ask| ask.name == *name)
          .ok_or_else(|| invalid("filesystem permission was not requested by this revision"))?;
        if access != ask.access {
          return Err(invalid("filesystem selection must match the declared access"));
        }
        grants.filesystem.insert(
          name.clone(),
          FileSystemGrant::select(&ask.resolved_path()?, access, ask.target)?,
        );
        }
      }
      // Re-reviewing an active plugin requires an explicit Disable first. Do
      // not silently revoke a running revision on a failed approval attempt.
      let record = store.approve(&revision, grants)?;
      Ok(json!(record))
    }
    Request::Revoke { id } => {
      store.revoke(&id)?;
      Ok(Value::Null)
    }
    Request::Remove { id } => {
      store.remove(&id)?;
      Ok(Value::Null)
    }
    Request::Preview { .. } => unreachable!("preview returned without opening the store"),
    Request::Stop { id } => Ok(json!(store.stop(&id)?)),
    Request::Recover { id } => {
      store.recover(&id)?;
      Ok(Value::Null)
    }
  }
}

fn review(store: &Store, revision: &str) -> io::Result<Value> {
  review_revision(&store.revisions(), revision)
}

fn review_revision(revisions: &Path, revision: &str) -> io::Result<Value> {
  // Reject non-digest paths even for metadata-only reads.
  if revision.len() != 64
    || !revision
      .bytes()
      .all(|byte| byte.is_ascii_hexdigit() && !byte.is_ascii_uppercase())
  {
    return Err(invalid("invalid plugin revision"));
  }
  let manifest = Manifest::read(&revisions.join(revision))?;
  let paths = manifest.sandbox.requests.filesystem.iter()
    .map(|ask| Ok((ask.name.clone(), ask.resolved_path()?)))
    .collect::<io::Result<BTreeMap<_, _>>>()?;
  Ok(json!({
    "id": manifest.id, "name": manifest.name, "version": manifest.version,
    "kinds": manifest.kinds, "revision": revision, "requests": manifest.sandbox.requests,
    "paths": paths, "enabled": false, "approved": false, "grants": Grants::default()
  }))
}

#[cfg(test)]
mod tests {
  use super::*;

  #[test]
  fn staged_preview_leaves_no_store_identity_or_snapshot() {
    let temp = tempfile::tempdir().unwrap();
    let root = temp.path().join("store");
    let source = temp.path().join("source");
    fs::create_dir(&source).unwrap();
    fs::write(source.join("worker.qml"), "import QtQuick\nItem {}").unwrap();
    fs::write(source.join("manifest.json"), serde_json::to_vec(&json!({
      "schemaVersion":1, "id":"test.preview", "name":"Preview", "version":"1", "kinds":["bar-widget"],
      "entryPoints":{"barWidget":"worker.qml"}, "sandbox":{"version":1,"requests":{}}
    })).unwrap()).unwrap();
    let call = |request: Value| execute(&root, &serde_json::to_vec(&request).unwrap()).unwrap();
    let preview = call(json!({"operation":"preview", "path":source}));
    assert!(!root.exists(), "preview created persistent plugin state");
    let imported = call(json!({"operation":"import", "path":source}));
    assert_eq!(preview, imported, "ephemeral and installed reviews must bind identical bytes");
    call(json!({"operation":"remove", "id":"test.preview"}));
    assert_eq!(call(json!({"operation":"list"})), json!([]));
    assert!(!root.join("identities/test.preview").exists());
    assert!(!root.join("revisions").join(imported["revision"].as_str().unwrap()).exists());
    call(json!({"operation":"remove", "id":"test.preview"}));
    assert!(!root.join("test.preview.lock").exists(), "idempotent removal left an identity lock");
  }

  #[test]
  fn filesystem_requests_declare_paths_and_approval_only_selects_names() {
    let temp = tempfile::tempdir().unwrap();
    let root = temp.path().join("store");
    let source = temp.path().join("source");
    let data = temp.path().join("requested folder");
    let file = temp.path().join("requested.txt");
    fs::create_dir(&source).unwrap();
    fs::create_dir(&data).unwrap();
    fs::write(&file, "unchanged").unwrap();
    fs::write(source.join("worker.qml"), "import Quickshell\nShellRoot {}").unwrap();
    fs::write(source.join("manifest.json"), serde_json::to_vec(&json!({
      "schemaVersion": 1, "id": "test.paths", "name": "Paths", "version": "1", "kinds": ["panel"],
      "entryPoints": {"panel": "worker.qml"}, "sandbox": {"version": 1, "entryPoint": "worker.qml",
        "requests": {"media": {"service": "org.mpris.MediaPlayer2.fixture"}, "filesystem": [
          {"name": "folder", "path": data, "target": "directory", "required": true},
          {"name": "file", "path": file, "target": "file", "access": "readwrite"}
        ]}}
    })).unwrap()).unwrap();
    let call = |request: Value| execute(&root, &serde_json::to_vec(&request).unwrap());
    let review = call(json!({"operation": "import", "path": source})).unwrap();
    let approve = |selections| call(json!({"operation": "approve", "id": "test.paths", "revision": review["revision"], "selections": selections}));
    let empty = approve(json!({})).unwrap();
    assert_eq!(empty["grants"]["filesystem"], json!({}));
    let selected = approve(json!({"read": ["folder"], "write": ["file"]})).unwrap();
    assert_eq!(selected["grants"]["filesystem"]["folder"]["path"], json!(data));
    assert_eq!(selected["grants"]["filesystem"]["file"]["path"], json!(file));
    assert_eq!(selected["grants"]["filesystem"]["file"]["target"], "file");
    assert_eq!(selected["grants"]["filesystem"]["file"]["access"], "readwrite");
    assert!(approve(json!({"write": ["folder"]})).is_err());
    assert!(approve(json!({"read": ["file"]})).is_err());
    assert!(approve(json!({"read": ["unknown"]})).is_err());
    assert!(approve(json!({"read": {"folder": temp.path()}})).is_err());
    assert_eq!(call(json!({"operation": "list"})).unwrap()[0]["grants"], selected["grants"]);
    let media = approve(json!({"media": true})).unwrap();
    assert_eq!(media["grants"]["media"], "org.mpris.MediaPlayer2.fixture");
    assert!(approve(json!({"media": "org.mpris.MediaPlayer2.other"})).is_err());
    assert_eq!(call(json!({"operation": "list"})).unwrap()[0]["grants"], media["grants"]);
    assert_eq!(fs::read_to_string(file).unwrap(), "unchanged");
  }

  #[test]
  fn review_approve_and_disable_a_revision_without_running_plugin_code() {
    let temp = tempfile::tempdir().unwrap();
    let root = temp.path().join("state");
    let call = |request: Value| execute(&root, &serde_json::to_vec(&request).unwrap()).unwrap();
    assert_eq!(call(json!({"operation": "list"})), json!([]));
    call(json!({"operation": "revoke", "id": "test.review"}));
    assert!(
      !root.exists(),
      "viewing an empty list initialized the store"
    );
    let source = temp.path().join("source");
    fs::create_dir(&source).unwrap();
    fs::write(
      source.join("worker.qml"),
      "import Quickshell\nShellRoot {}\n",
    )
    .unwrap();
    fs::write(source.join("manifest.json"), serde_json::to_vec(&json!({
      "schemaVersion": 1, "id": "test.review", "name": "Review me", "version": "1", "kinds": ["panel"],
      "entryPoints": {"panel": "worker.qml"}, "sandbox": {"version": 1, "entryPoint": "worker.qml", "requests": {"network": true, "notifications": true, "storage": true, "filesystem": [{"name": "notes", "path": source}]}}
    })).unwrap()).unwrap();
    let review = call(json!({"operation": "import", "path": source}));
    assert_eq!(review["name"], "Review me");
    assert_eq!(review["enabled"], false);
    call(json!({"operation": "revoke", "id": "test.review"}));
    assert_eq!(review["requests"]["network"], true);
    assert_eq!(
      call(json!({"operation": "list"})),
      json!([]),
      "import implicitly approved a plugin"
    );
    let record = call(
      json!({"operation": "approve", "id": "test.review", "revision": review["revision"], "selections": {"notifications": true, "storage": true, "read": ["notes"]}}),
    );
    assert_eq!(record["enabled"], true);
    assert_eq!(record["grants"]["network"], false);
    assert_eq!(record["grants"]["notifications"], true);
    assert_eq!(record["grants"]["storage"], true);
    assert_eq!(record["activeUnit"], Value::Null);
    let listed = call(json!({"operation": "list"}));
    assert_eq!(listed[0]["approved"], true);
    assert_eq!(listed[0]["enabled"], false);
    assert_eq!(
      call(json!({"operation": "list"}))[0]["revision"],
      review["revision"]
    );
    call(json!({"operation": "revoke", "id": "test.review"}));
    assert_eq!(call(json!({"operation": "list"}))[0]["approved"], false);
  }

  #[test]
  fn storage_selection_defaults_off_and_survives_disable() {
    // storage may be omitted from selections (defaulting to false) without
    // failing approval, matching the optional-request discipline.
    let temp = tempfile::tempdir().unwrap();
    let root = temp.path().join("state");
    let call = |request: Value| execute(&root, &serde_json::to_vec(&request).unwrap()).unwrap();
    let source = temp.path().join("source");
    fs::create_dir(&source).unwrap();
    fs::write(source.join("worker.qml"), "import Quickshell\nShellRoot {}").unwrap();
    fs::write(
      source.join("manifest.json"),
      serde_json::to_vec(&json!({
        "schemaVersion": 1, "id": "test.storage", "name": "Storage", "version": "1",
        "kinds": ["panel"], "entryPoints": {"panel": "worker.qml"},
        "sandbox": {"version": 1, "entryPoint": "worker.qml", "requests": {"storage": true}}
      }))
      .unwrap(),
    )
    .unwrap();
    let review = call(json!({"operation": "import", "path": source}));
    let record = call(json!({
      "operation": "approve", "id": "test.storage", "revision": review["revision"],
      "selections": {}
    }));
    assert_eq!(
      record["grants"]["storage"], false,
      "storage defaults to unselected"
    );
    let with_storage = call(json!({
      "operation": "approve", "id": "test.storage", "revision": review["revision"],
      "selections": {"storage": true}
    }));
    assert_eq!(with_storage["grants"]["storage"], true);
    assert_eq!(
      call(json!({"operation": "list"}))[0]["grants"]["storage"],
      true
    );
    call(json!({"operation": "revoke", "id": "test.storage"}));
  }

  #[test]
  fn stop_keeps_approval_enabled_through_the_protocol() {
    // The Stop operation is the non-destructive predecessor to re-approval: it
    // returns the record with enabled still true (unlike Revoke), so the UI
    // can stop a running plugin and re-approve it without flipping it to
    // disabled. The running-instance (activeUnit) blocking behavior lives at
    // the store layer; here we assert the operation routes and stays enabled.
    let temp = tempfile::tempdir().unwrap();
    let root = temp.path().join("state");
    let call = |request: Value| {
      execute(&root, &serde_json::to_vec(&request).unwrap()).unwrap()
    };
    let source = temp.path().join("source");
    fs::create_dir(&source).unwrap();
    fs::write(
      source.join("worker.qml"),
      "import Quickshell\nShellRoot {}\n",
    )
    .unwrap();
    fs::write(
      source.join("manifest.json"),
      serde_json::to_vec(&json!({
        "schemaVersion": 1, "id": "test.stop", "name": "Stop.ee", "version": "1",
        "kinds": ["panel"], "entryPoints": {"panel": "worker.qml"},
        "sandbox": {"version": 1, "entryPoint": "worker.qml", "requests": {"storage": true}}
      }))
      .unwrap(),
    )
    .unwrap();
    let review = call(json!({"operation": "import", "path": source}));
    let approved = call(json!({
      "operation": "approve", "id": "test.stop", "revision": review["revision"],
      "selections": {"storage": true}
    }));
    assert_eq!(approved["enabled"], true);
    let stopped = call(json!({"operation": "stop", "id": "test.stop"}));
    assert_eq!(stopped["enabled"], true, "stop must not disable approval");
    assert_eq!(stopped["activeUnit"], Value::Null);
    // The plugin can be re-approved immediately after a stop.
    let reapproved = call(json!({
      "operation": "approve", "id": "test.stop", "revision": review["revision"],
      "selections": {"storage": true}
    }));
    assert_eq!(reapproved["enabled"], true);
    assert!(reapproved["epoch"].as_u64().unwrap() > stopped["epoch"].as_u64().unwrap());
    // Contrast: revoke is the destructive disable.
    call(json!({"operation": "revoke", "id": "test.stop"}));
    assert_eq!(call(json!({"operation": "list"}))[0]["enabled"], false);
  }
}
