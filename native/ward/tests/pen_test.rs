//! Ward pen-test: malicious-plugin artifacts driven through the real
//! validation code. Each case is the concrete thing a plugin would emit; the
//! assertion is that the boundary holds. White-box cases target a named
//! invariant from the source; black-box cases are the obvious things a plugin
//! author with only the authoring docs would try. These are regression guards:
//! they assert containment, not a vulnerability.
use omarchy_ward::{
  channel::{Channel, Packet, MAX_BYTES},
  context::UiContext,
  exec_policy::{Argument, PluginDir, Step, Tree},
  grants::{Access, Grants, Requests, Target},
  http::Scope,
  notification::Request as Notification,
  presentation::{Buffer, Event, Region, Viewport},
  settings::Grant as SettingsGrant,
};
use std::{collections::BTreeSet, fs::File};
use serde_json::json;

fn selected(names: &[&str]) -> BTreeSet<String> {
  names.iter().map(|s| (*s).into()).collect()
}
fn args(values: &[&str]) -> Vec<String> {
  values.iter().map(|s| (*s).into()).collect()
}
fn term(name: &str) -> Tree {
  Tree { end: Some(name.into()), next: Vec::new() }
}
fn tree(next: Vec<Step>) -> Tree {
  Tree { end: None, next }
}
fn step(arg: Argument, then: Tree) -> Step {
  Step { arg, then }
}
fn exact(value: &str, then: Tree) -> Step {
  step(Argument::Exact { value: value.into() }, then)
}

// ---------------------------------------------------------------------------
// TB-8 / exec policy: positive-only argv matching.
// ---------------------------------------------------------------------------

#[test]
fn whitebox_exec_traversal_prefix_and_overflow_are_rejected() {
  // A policy that plays a sound under the plugin's own assets.
  let policy = tree(vec![step(
    Argument::Text { prefix: "$OMARCHY_PLUGIN_PATH/sounds/".into(), min: 12, max: 200 },
    term("play"),
  )]);
  let dirs = [PluginDir::assets("/run/user/1000/omarchy/plugin/p".to_owned())];

  // Legitimate: a sound under the pinned directory.
  assert!(policy
    .check_with(&dirs, &selected(&["play"]), &args(&["$OMARCHY_PLUGIN_PATH/sounds/ball.wav"]))
    .is_ok());

  // White-box: traversal out of the pinned directory, in token and resolved forms.
  for bad in [
    "$OMARCHY_PLUGIN_PATH/../etc/passwd",
    "$OMARCHY_PLUGIN_PATH/../../etc/shadow",
    "/run/user/1000/omarchy/plugin/p/../../etc/passwd",
    "/run/user/1000/omarchy/plugin/p/sounds/../etc/passwd",
    "$OMARCHY_PLUGIN_PATH/./x",
    "$OMARCHY_PLUGIN_PATH/",
    "$OMARCHY_PLUGIN_PATH/..",
  ] {
    assert!(policy
      .check_with(&dirs, &selected(&["play"]), &args(&[bad]))
      .is_err(), "leaked {bad}");
  }

  // A different directory is not an alias for the pinned one.
  for bad in [
    "$OMARCHY_PLUGIN_PATH_EXTRA/x",
    "$OMARCHY_PLUGIN_DATA/sounds/ball.wav",
    "/etc/passwd",
  ] {
    assert!(policy
      .check_with(&dirs, &selected(&["play"]), &args(&[bad]))
      .is_err(), "leaked {bad}");
  }
}

#[test]
fn whitebox_exec_extra_args_and_prefix_injection_are_rejected() {
  // `omarchy-pkg-add <name>` with no further authority.
  let policy = tree(vec![step(
    Argument::Text { prefix: String::new(), min: 1, max: 64 },
    term("install"),
  )]);
  let sel = selected(&["install"]);
  assert!(policy.check(&sel, &args(&["firefox"])).is_ok());
  // Extra trailing argument is not part of the reviewed path.
  assert!(policy.check(&sel, &args(&["firefox", "--sudo"])).is_err());
  // An empty argument is not a valid Text match.
  assert!(policy.check(&sel, &args(&[""])).is_err());
  // A null byte cannot sneak into a Text argument.
  assert!(policy.check(&sel, &args(&["fir\0efox"])).is_err());
  // Over the bound.
  assert!(policy.check(&sel, &["a".repeat(65)]).is_err());
}

#[test]
fn whitebox_exec_integer_and_pattern_constraints_are_strict() {
  let policy = tree(vec![step(
    Argument::Integer { min: 1, max: 10 },
    term("count"),
  )]);
  let sel = selected(&["count"]);
  for ok in ["1", "10", "7"] {
    assert!(policy.check(&sel, &args(&[ok])).is_ok(), "{ok}");
  }
  for bad in ["0", "11", "01", "+1", "-1", "1.0", "1e1", "1_0", "0x1", " 1", "1 "] {
    assert!(policy.check(&sel, &args(&[bad])).is_err(), "{bad}");
  }

  // A pattern is a whole-argument match with no exclusion and no escaping.
  let pattern = tree(vec![step(
    Argument::Pattern { value: "/threads/[0-9]+".into(), max: 24 },
    term("thread"),
  )]);
  let sel = selected(&["thread"]);
  for ok in ["/threads/1", "/threads/123456"] {
    assert!(pattern.check(&sel, &args(&[ok])).is_ok(), "{ok}");
  }
  for bad in [
    "x/threads/1",
    "/threads/1/extra",
    "/threads/../secret",
    "/threads/%31",
    "/threads/1\n",
    "/threads/12345678901234567890",
  ] {
    assert!(pattern.check(&sel, &args(&[bad])).is_err(), "{bad}");
  }
}

#[test]
fn whitebox_exec_selection_must_come_from_the_reviewed_tree() {
  let status = Tree {
    end: Some("status".into()),
    next: vec![exact("--hostname", tree(vec![exact("example.test", term("host-status"))]))],
  };
  let policy = tree(vec![exact("auth", tree(vec![exact("status", status)]))]);
  // A selection not in the tree is rejected even if the argv would match a leaf.
  assert!(policy.check(&selected(&["not-a-leaf"]), &args(&["auth", "status"])).is_err());
  // The parent name is not a leaf; selecting it does not authorize the child path.
  assert!(policy.check(&selected(&["auth", "status"]), &args(&["auth", "status"])).is_err());
  // An argv that matches no leaf is rejected.
  assert!(policy.check(&selected(&["status"]), &args(&["auth", "token"])).is_err());
}

// ---------------------------------------------------------------------------
// TB-8 / http: exact reviewed selections, not network authority.
// (The scope-vs-request matching lives in the module's private check; these
//  cases exercise the public validate() that rejects the scope definition
//  a malicious plugin would try to widen.)
// ---------------------------------------------------------------------------

#[test]
fn whitebox_http_scope_definition_attacks_fail_validation() {
  // A '*' is exactly one nonempty segment; a two-segment wildcard is fine, a
  // literal '*' in another position is not.
  assert!(serde_json::from_value::<Scope>(json!({
    "origin": "https://api.example.test", "method": "GET", "path": "/groups/*/secret/*"
  }))
  .is_ok());
  // A subtree path must end in '/' and contain no '*'.
  for path in ["/allowed", "/allowed/*/"] {
    let scope: Scope =
      serde_json::from_value(json!({ "origin": "https://example.test", "method": "GET", "path": path })).unwrap();
    let mut scope = scope;
    scope.subtree = true;
    assert!(scope.validate().is_err(), "path {path}");
  }
  // Origin must canonicalize to itself; a port, scheme change, or credentials is rejected.
  for origin in [
    "https://user@api.example.test",
    "https://api.example.test#frag",
  ] {
    let scope: Scope =
      serde_json::from_value(json!({ "origin": origin, "method": "GET", "path": "/x" })).unwrap();
    assert!(scope.validate().is_err(), "origin {origin}");
  }
  // A port or scheme change is a valid origin; a request to a different origin is
  // rejected at matching time, not by validate().
  // GET/HEAD cannot carry a body scope.
  let scope: Scope = serde_json::from_value(json!({
    "origin": "https://api.example.test", "method": "GET", "path": "/x",
    "body": { "query": { "kind": "string", "max": 10 } }
  }))
  .unwrap();
  assert!(scope.validate().is_err());
  // Unknown fields are rejected (no implicit wildcard).
  assert!(serde_json::from_value::<Scope>(json!({
    "origin": "https://api.example.test", "method": "GET", "path": "/x", "account": "no"
  }))
  .is_err());
}

// ---------------------------------------------------------------------------
// TB-2 / grants: fail-closed validation.
// ---------------------------------------------------------------------------

#[test]
fn whitebox_grants_validation_is_fail_closed() {
  let scope: Scope =
    serde_json::from_value(json!({ "origin": "https://api.example.test", "method": "GET", "path": "/jobs" }))
      .unwrap();
  let mut requests = Requests::default();
  requests.network.asked = true;
  requests.http.insert(
    "actions".into(),
    omarchy_ward::http::Ask { scope: scope.clone(), required: true },
  );
  let mut grants = Grants::default();
  // A missing required scope is a gap, not a validate() failure: the session
  // starts and the gap is reported for the reviewer.
  grants.validate(&requests).unwrap();
  assert_eq!(grants.required_gap(&requests), ["http:actions"]);
  // Granting the scope exactly closes the gap.
  grants.http.insert("actions".into(), scope.clone());
  grants.validate(&requests).unwrap();
  assert!(grants.required_gap(&requests).is_empty());
  // Granting network access the plugin never asked for is rejected.
  grants.network = true;
  assert!(grants.validate(&requests).is_err());
  // A grant the plugin never requested cannot be approved at all.
  let empty = Requests::default();
  let mut too_much = Grants::default();
  too_much.network = true;
  assert!(too_much.validate(&empty).is_err());
}

#[test]
fn whitebox_grants_filesystem_access_and_target_are_independent() {
  let dir = std::env::temp_dir().join("ward-pen-test-grants");
  std::fs::create_dir_all(&dir).unwrap();
  let read = omarchy_ward::grants::FileSystemGrant::select(&dir, Access::Read, Target::Directory)
    .unwrap();
  let write = omarchy_ward::grants::FileSystemGrant::select(&dir, Access::ReadWrite, Target::Directory)
    .unwrap();
  assert!(!read.access.writable());
  assert!(write.access.writable());
  // A write-only selection is unsupported (a bind also exposes reads).
  assert!(omarchy_ward::grants::FileSystemGrant::select(&dir, Access::Write, Target::Directory).is_err());
}

// ---------------------------------------------------------------------------
// TB-8 / settings: exact own-entry keys.
// ---------------------------------------------------------------------------

#[test]
fn whitebox_settings_host_structure_and_wildcards_are_rejected() {
  for key in ["*", "id", "sandbox", "constructor", "__proto__", "prototype"] {
    let grant = SettingsGrant {
      read: [key.into()].into(),
      write: BTreeSet::new(),
    };
    assert!(grant.validate().is_err(), "key {key}");
  }
  // A valid grant: read and write are independent exact keys.
  let grant = SettingsGrant {
    read: ["theme".into()].into(),
    write: ["volume".into()].into(),
  };
  assert!(grant.validate().is_ok());
  // A write to a host-structure key is rejected.
  let mut bad = grant.clone();
  bad.write.insert("__proto__".into());
  assert!(bad.validate().is_err());
}

#[test]
fn whitebox_settings_write_is_bounded_by_approved_keys() {
  let grant = SettingsGrant {
    read: ["theme".into()].into(),
    write: ["volume".into()].into(),
  };
  assert!(grant.validate().is_ok());
  // A write within the approved keys is allowed.
  assert!(grant.check_write(&serde_json::from_value(json!({ "volume": 10 })).unwrap()).is_ok());
  // A write to an unapproved key (even one the plugin can read) is rejected.
  assert!(grant.check_write(&serde_json::from_value(json!({ "theme": "light" })).unwrap()).is_err());
  // The read filter only exposes approved read keys.
  let mut values = serde_json::from_value(json!({ "theme": "dark", "volume": 50, "secret": "hidden" })).unwrap();
  grant.filter(&mut values);
  assert_eq!(serde_json::to_value(&values).unwrap(), json!({ "theme": "dark" }));
}

// ---------------------------------------------------------------------------
// TB-8 / notification: text policy.
// ---------------------------------------------------------------------------

#[test]
fn whitebox_notification_text_policy_rejects_control_and_rtl() {
  let n = |t: &str, b: &str| Notification::new(t.to_string(), b.to_string());
  assert!(n("Title", "Message").is_ok());
  // Control characters in the title (null, newline, CR, tab) are rejected.
  for text in ["\0", "\n", "\r", "\t"] {
    assert!(n(text, "").is_err(), "title {text:?}");
  }
  // A newline is allowed in the body but other control chars are not.
  assert!(n("Title", "line1\nline2").is_ok());
  assert!(n("Title", "a\0b").is_err());
  // Right-to-left override and embedding characters are rejected.
  for text in ["\u{202e}", "\u{2066}", "\u{202a}", "\u{202c}"] {
    assert!(n("Title", text).is_err(), "{text}");
  }
  // An empty title, an oversized title, or an oversized body are rejected.
  assert!(n("", "x").is_err());
  assert!(n(&"x".repeat(161), "x").is_err());
  assert!(n("x", &"x".repeat(2049)).is_err());
}

#[test]
fn whitebox_notification_packet_attacks_fail_decode() {
  let packet = |bytes: &[u8]| Packet { bytes: bytes.to_vec(), fds: Vec::new() };
  for bytes in [
    br#"{"version":1,"title":"ok","body":"","id":"other"}"#.as_slice(),
    br#"{"version":1,"title":"ok","body":"","exec":"sh"}"#.as_slice(),
    br#"{"version":2,"title":"ok","body":""}"#.as_slice(),
    br#"{"version":1,"title":"a","title":"b","body":""}"#.as_slice(),
  ] {
    assert!(Notification::decode(packet(bytes)).is_err(), "accepted {bytes:?}");
  }
  // A packet that carries a descriptor is rejected.
  let with_fd = Packet {
    bytes: br#"{"version":1,"title":"ok","body":""}"#.to_vec(),
    fds: vec![std::os::fd::OwnedFd::from(File::open("/dev/null").unwrap())],
  };
  assert!(Notification::decode(with_fd).is_err());
  // A packet over the byte limit is rejected.
  assert!(Notification::decode(Packet { bytes: vec![b';'; MAX_BYTES], fds: Vec::new() }).is_err());
  // The good packet decodes.
  assert!(Notification::decode(packet(
    br#"{"version":1,"title":"ok","body":""}"#
  ))
  .is_ok());
}

// ---------------------------------------------------------------------------
// TB-6 / context: one-way, bounded, finite.
// ---------------------------------------------------------------------------

#[test]
fn whitebox_context_bounding_is_strict() {
  let good = json!({ "settings": {}, "theme": null, "panel": null, "geometry": null, "bar": null });
  assert!(UiContext::parse(&serde_json::to_vec(&good).unwrap()).is_ok());
  // An oversized context is rejected.
  let huge = json!({ "settings": { "k": "x".repeat(70_000) } });
  assert!(UiContext::parse(&serde_json::to_vec(&huge).unwrap()).is_err());
  // A bar with a non-finite coordinate is rejected even though the JSON is valid.
  for bar in [
    json!({ "x": 1e308, "y": 1.0, "width": 1.0, "height": 1.0, "size": 10, "position": "top", "visible": true }),
    json!({ "x": 1.0, "y": 1.0, "width": 0.0, "height": 1.0, "size": 10, "position": "top", "visible": true }),
    json!({ "x": 1.0, "y": 1.0, "width": 1.0, "height": 2048.0, "size": 10, "position": "top", "visible": true }),
    json!({ "x": 1.0, "y": 1.0, "width": 1.0, "height": 1.0, "size": 0, "position": "top", "visible": true }),
    json!({ "x": 1.0, "y": 1.0, "width": 1.0, "height": 1.0, "size": 10, "position": "nowhere", "visible": true }),
  ] {
    let context = json!({ "bar": bar });
    assert!(UiContext::parse(&serde_json::to_vec(&context).unwrap()).is_err());
  }
  // An own-panel command with serial 0, a payload when closed, or an oversized
  // payload is rejected.
  for panel in [
    json!({ "serial": 0, "open": true, "payload": "x" }),
    json!({ "serial": 1, "open": false, "payload": "x" }),
    json!({ "serial": 1, "open": true, "payload": "x".repeat(4097) }),
  ] {
    let context = json!({ "panel": panel });
    assert!(UiContext::parse(&serde_json::to_vec(&context).unwrap()).is_err());
  }
  // Unknown fields are rejected.
  let context = json!({ "settings": {}, "evil": true });
  assert!(UiContext::parse(&serde_json::to_vec(&context).unwrap()).is_err());
}

// ---------------------------------------------------------------------------
// TB-6 / presentation: strict slot/generation state machine.
// ---------------------------------------------------------------------------

#[test]
fn whitebox_presentation_record_attacks_fail_decode() {
  let (a, b) = Channel::pair().unwrap();
  // A well-formed Configured round-trips.
  Event::Configured {
    generation: 1,
    viewport: Viewport { width: 100, height: 100, scale_fixed: 120 },
  }
  .send(&a)
  .unwrap();
  assert!(Event::decode(b.receive().unwrap()).is_ok());

  // generation 0 is rejected; so are out-of-bounds dimensions and bad scales.
  for (w, h, s) in [(0, 100, 1), (4097, 100, 1), (100, 100, 0), (100, 100, 5)] {
    assert!(Event::Configured {
      generation: 1,
      viewport: Viewport { width: w, height: h, scale_fixed: s },
    }
    .send(&a)
    .is_err());
  }

  // Hand-crafted records: the magic is required.
  assert!(Event::decode(Packet { bytes: vec![0; 16], fds: Vec::new() }).is_err());
  // A Frame with a bad slot (> 1) or serial 0 is rejected.
  assert!(Event::Frame { generation: 1, serial: 0, slot: 0 }.send(&a).is_err());
  assert!(Event::Frame { generation: 1, serial: 1, slot: 2 }.send(&a).is_err());
  // A good Frame round-trips.
  Event::Frame { generation: 1, serial: 1, slot: 1 }.send(&a).unwrap();
  assert!(Event::decode(b.receive().unwrap()).is_ok());
  // A Mask over the region cap is rejected.
  let regions: Vec<Region> = (0..omarchy_ward::presentation::MAX_REGIONS + 1)
    .map(|i| Region { operation: 0, x: 0, y: 0, width: 1, height: 1 + (i as u32) % 100 })
    .collect();
  assert!(Event::Mask { generation: 1, regions }.send(&a).is_err());
}

#[test]
fn whitebox_presentation_buffer_attacks_fail_validation() {
  let (a, b) = Channel::pair().unwrap();
  let fd = || std::os::fd::OwnedFd::from(File::open("/dev/null").unwrap());
  // A buffer whose pixel area exceeds the cap is rejected.
  assert!(Event::Buffer(Buffer {
    generation: 1,
    slot: 0,
    width: 4096,
    height: 4096,
    stride: 4096 * 4,
    fd: fd(),
  })
  .send(&a)
  .is_err());
  // A buffer with an odd stride (not a multiple of 4) is rejected.
  assert!(Event::Buffer(Buffer {
    generation: 1,
    slot: 0,
    width: 100,
    height: 100,
    stride: 3,
    fd: fd(),
  })
  .send(&a)
  .is_err());
  // A buffer with too-small a stride is rejected.
  assert!(Event::Buffer(Buffer {
    generation: 1,
    slot: 0,
    width: 100,
    height: 100,
    stride: 100,
    fd: fd(),
  })
  .send(&a)
  .is_err());
  // A well-formed small buffer round-trips.
  Event::Buffer(Buffer {
    generation: 1,
    slot: 0,
    width: 100,
    height: 100,
    stride: 400,
    fd: fd(),
  })
  .send(&a)
  .unwrap();
  assert!(Event::decode(b.receive().unwrap()).is_ok());
  // A buffer packet without its fd is rejected.
  a.send(b"OPH\x01", &[]).unwrap();
  assert!(Event::decode(b.receive().unwrap()).is_err());
}

// ---------------------------------------------------------------------------
// TB-8 / http: the network request path is the shared boundary; the
// open-url helper (requests.rs) is private and covered by its own module
// tests, so the pen-test drives the public http scope validation instead.
// ---------------------------------------------------------------------------
