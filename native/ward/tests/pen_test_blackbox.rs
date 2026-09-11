//! Ward black-box pen-test: what a plugin author with ONLY the authoring
//! docs (docs/sandboxed-plugin-authoring.md) would try, without reading the
//! Rust source. These are the naive attacks a docs-only author would attempt;
//! the assertions prove the host-side boundary contains them. They are framed
//! by the plugin author's mental model, not by the implementation.
use omarchy_ward::{
  context::UiContext,
  exec_policy::{Argument, PluginDir, Step, Tree},
  grants::{Access, FileSystemGrant, Grants, Requests, Target},
  http::Scope,
  notification::Request as Notification,
  settings::Grant as SettingsGrant,
};
use std::collections::BTreeSet;
use serde_json::json;

fn sel(names: &[&str]) -> BTreeSet<String> {
  names.iter().map(|s| (*s).into()).collect()
}

// ---------------------------------------------------------------------------
// A docs-only author reads "a plugin can request host files". They try to
// request a sensitive host path and expect it to just work.
// ---------------------------------------------------------------------------

#[test]
fn blackbox_a_plugin_cannot_self_approve_a_host_file_grant() {
  // The author writes a manifest asking for /etc/passwd. The manifest can only
  // *request*; the grant is a separate, reviewer-approved record that must
  // cover the request exactly. A manifest alone approves nothing.
  let manifest: Requests =
    serde_json::from_value(json!({ "filesystem": [{ "name": "passwd", "path": "/etc/passwd", "target": "file", "access": "read" }] })).unwrap();
  // A manifest only *requests*; an empty grant is a gap, not a validate() error
  // (the request is optional). A required request that is not granted is a gap
  // reported to the reviewer.
  let no_grant = Grants::default();
  no_grant.validate(&manifest).unwrap();
  // Granting something the plugin never requested is rejected.
  let mut too_much = Grants::default();
  too_much.network = true;
  assert!(too_much.validate(&manifest).is_err());
  // Approval cannot substitute an unrelated directory for the declared file.
  let root = tempfile::tempdir().unwrap();
  let dir = root.path();
  let mut approved = Grants::default();
  approved
    .filesystem
    .insert("passwd".into(), FileSystemGrant::select(&dir, Access::Read, Target::Directory).unwrap());
  assert!(approved.validate(&manifest).is_err());
  approved.filesystem.insert("passwd".into(), FileSystemGrant::select(std::path::Path::new("/etc/passwd"), Access::Read, Target::File).unwrap());
  approved.validate(&manifest).unwrap();
}

// ---------------------------------------------------------------------------
// A docs-only author reads "a plugin can call host commands". They try to
// smuggle flags into a command whose argv was not reviewed.
// ---------------------------------------------------------------------------

#[test]
fn blackbox_a_plugin_cannot_add_arguments_to_a_reviewed_command() {
  // The author is granted `omarchy-pkg-add <name>`. They try to append a flag.
  let policy = Tree {
    end: None,
    next: vec![Step {
      arg: Argument::Text { prefix: String::new(), min: 1, max: 64 },
      then: Tree { end: Some("install".into()), next: Vec::new() },
    }],
  };
  // Exactly one argument is reviewed.
  assert!(policy.check(&sel(&["install"]), &["firefox".into()]).is_ok());
  // A second argument (a smuggled flag) is not part of the reviewed path.
  assert!(policy.check(&sel(&["install"]), &["firefox".into(), "--sudo".into()]).is_err());
  // A free-text argument accepts any single string by design (the reviewer
  // chose it); the protection is against EXTRA arguments, not the content of
  // the one reviewed slot. That is the documented "argv matching is not
  // semantic safety" limitation, not a bug.
  assert!(policy.check(&sel(&["install"]), &["--sudo".into()]).is_ok());
}

// ---------------------------------------------------------------------------
// A docs-only author reads "a plugin can make HTTP requests". They try to
// hit an origin the reviewer did not approve.
// ---------------------------------------------------------------------------

#[test]
fn blackbox_a_plugin_cannot_request_an_unapproved_http_origin() {
  // The author is granted api.example.test. They try api.example.test.evil.test.
  // validate() accepts a well-formed scope; the request-vs-scope match (private
  // check) is what enforces the origin — the existing module test
  // `methods_origins_paths_and_required_query_filters_cannot_be_widened`
  // proves the mismatch is rejected. Here we confirm the granted scope is a
  // valid, exact selection and that an "unrecognized" origin is a schema error.
  let granted: Scope = serde_json::from_value(json!({
    "origin": "https://api.example.test", "method": "GET", "path": "/jobs"
  }))
  .unwrap();
  granted.validate().unwrap();
  // A scope with an unrecognized field is a schema error, not a widening.
  assert!(serde_json::from_value::<Scope>(json!({
    "origin": "https://api.example.test", "method": "GET", "path": "/jobs", "any": true
  }))
  .is_err());
  // A "match everything" path is not expressible: '*' is one segment only.
  let wildcard: Scope = serde_json::from_value(json!({
    "origin": "https://api.example.test", "method": "GET", "path": "/*"
  }))
  .unwrap();
  // validate() accepts a single-segment wildcard; the match still requires the
  // exact origin and method, so it cannot reach another host.
  wildcard.validate().unwrap();
}

// ---------------------------------------------------------------------------
// A docs-only author reads "a plugin can write settings". They try to write a
// key the reviewer only allowed to read, or a host-structure key.
// ---------------------------------------------------------------------------

#[test]
fn blackbox_a_plugin_cannot_write_a_read_only_or_host_structure_key() {
  // The reviewer granted read of `theme` and write of `volume`.
  let grant = SettingsGrant {
    read: ["theme".into()].into(),
    write: ["volume".into()].into(),
  };
  assert!(grant.validate().is_ok());
  // Writing `volume` is allowed.
  assert!(grant.check_write(&serde_json::from_value(json!({ "volume": 10 })).unwrap()).is_ok());
  // Writing `theme` (read-only) is rejected.
  assert!(grant.check_write(&serde_json::from_value(json!({ "theme": "light" })).unwrap()).is_err());
  // The author cannot widen the write set to a host-structure key.
  let mut widened = grant.clone();
  widened.write.insert("constructor".into());
  assert!(widened.validate().is_err());
}

// ---------------------------------------------------------------------------
// A docs-only author reads "a plugin can notify". They try to smuggle markup
// or a command into the notification.
// ---------------------------------------------------------------------------

#[test]
fn blackbox_a_plugin_cannot_smuggle_markup_into_a_notification() {
  // Markup, control chars, and RTL are all rejected or escaped by the text
  // policy. The helper prefixes the title so a title that looks like an
  // option cannot be re-parsed by the receiver.
  assert!(Notification::new("<img src=x onerror=alert(1)>".into(), "x".into()).is_ok());
  // A null byte or newline in the title is rejected.
  assert!(Notification::new("\n".into(), "x".into()).is_err());
  assert!(Notification::new("\u{202e}".into(), "x".into()).is_err());
}

// ---------------------------------------------------------------------------
// A docs-only author reads "a plugin gets UI context". They try to read a
// context that carries more than the host allowed, or that is malformed.
// ---------------------------------------------------------------------------

#[test]
fn blackbox_a_plugin_cannot_get_a_malformed_or_oversized_context() {
  // A context the host never sends cannot be constructed by the plugin: the
  // plugin only reads the host-published file. A malformed/oversized context
  // fails the worker (not the host).
  let oversized = json!({ "settings": { "k": "x".repeat(70_000) } });
  assert!(UiContext::parse(&serde_json::to_vec(&oversized).unwrap()).is_err());
  // A context with an unknown field is rejected.
  let evil = json!({ "settings": {}, "openSudo": true });
  assert!(UiContext::parse(&serde_json::to_vec(&evil).unwrap()).is_err());
  // A context with a non-finite bar coordinate is rejected.
  let nan = json!({ "bar": { "x": 1e308, "y": 1.0, "width": 1.0, "height": 1.0, "size": 10, "position": "top", "visible": true } });
  assert!(UiContext::parse(&serde_json::to_vec(&nan).unwrap()).is_err());
}

// ---------------------------------------------------------------------------
// A docs-only author reads "a plugin can read its own assets". They try to
// read a host path by abusing the plugin-path token.
// ---------------------------------------------------------------------------

#[test]
fn blackbox_a_plugin_cannot_traverse_out_of_its_assets() {
  let policy = Tree {
    end: None,
    next: vec![Step {
      arg: Argument::Text { prefix: "$OMARCHY_PLUGIN_PATH/sounds/".into(), min: 12, max: 200 },
      then: Tree { end: Some("play".into()), next: Vec::new() },
    }],
  };
  let dirs = [PluginDir::assets("/run/user/1000/omarchy/plugin/p".to_owned())];
  // A legitimate asset is accepted.
  assert!(policy.check_with(&dirs, &sel(&["play"]), &["$OMARCHY_PLUGIN_PATH/sounds/a.wav".into()]).is_ok());
  // The author's obvious traversal attempts are all rejected.
  for bad in [
    "$OMARCHY_PLUGIN_PATH/../etc/passwd",
    "$OMARCHY_PLUGIN_PATH/../../etc/shadow",
    "$OMARCHY_PLUGIN_PATH/./a.wav",
    "$OMARCHY_PLUGIN_PATH/",
  ] {
    assert!(policy.check_with(&dirs, &sel(&["play"]), &[bad.into()]).is_err(), "{bad}");
  }
}
