//! Positive-only argument trees. This matcher does not launch host processes.
//! Executable binding, execution inputs, admission and supervision belong to
//! the broker; matching argv does not establish application-level safety.
use crate::grants::{invalid, validate_id};
use serde::{Deserialize, Serialize};
use std::{collections::BTreeSet, io};

// Three JSON containers per argument leave room for the manifest envelope
// within serde_json's default recursion limit; do not disable that limit.
const MAX_ARGS: usize = 32;
const MAX_ARG_BYTES: usize = 8192;
const MAX_BYTES: usize = 65536;
const MAX_NODES: usize = 512;

struct Size(usize);
impl io::Write for Size {
  fn write(&mut self, bytes: &[u8]) -> io::Result<usize> {
    if bytes.len() > MAX_BYTES - self.0 {
      return Err(invalid("command tree exceeds its byte limit"));
    }
    self.0 += bytes.len();
    Ok(bytes.len())
  }
  fn flush(&mut self) -> io::Result<()> {
    Ok(())
  }
}

#[derive(Clone, Debug, Default, Deserialize, Serialize, PartialEq, Eq)]
#[serde(deny_unknown_fields)]
pub struct Tree {
  /// Name of the request ending here, not permission for trailing arguments.
  #[serde(default)]
  pub end: Option<String>,
  #[serde(default)]
  pub next: Vec<Step>,
}

#[derive(Clone, Debug, Deserialize, Serialize, PartialEq, Eq)]
#[serde(deny_unknown_fields)]
pub struct Step {
  pub arg: Argument,
  pub then: Tree,
}

#[derive(Clone, Debug, Deserialize, Serialize, PartialEq, Eq)]
#[serde(tag = "kind", rename_all = "camelCase", deny_unknown_fields)]
pub enum Argument {
  Exact {
    value: String,
  },
  OneOf {
    values: Vec<String>,
  },
  Integer {
    min: u64,
    max: u64,
  },
  /// Bounds are UTF-8 byte lengths of the whole argument, including prefix.
  /// An empty prefix deliberately permits any literal text within the bounds.
  Text {
    prefix: String,
    min: usize,
    max: usize,
  },
  /// Match one complete argument, with bounded pattern/automaton/input sizes.
  Pattern {
    value: String,
    max: usize,
  },
}

fn pattern(value: &str) -> io::Result<regex::Regex> {
  if value.len() > 4096 || value.contains('\0') {
    return Err(invalid("command pattern exceeds its limit"));
  }
  let compile = |source: &str| {
    regex::RegexBuilder::new(source)
      .size_limit(65536)
      .dfa_size_limit(65536)
      .nest_limit(32)
      .build()
      .map_err(|_| invalid("invalid or oversized command pattern"))
  };
  // Validate the standalone pattern first: unmatched parentheses must not
  // escape the outer group that enforces whole-argument matching.
  compile(value)?;
  compile(&format!(r"\A(?:{value})\z"))
}

fn valid_argument(value: &str) -> bool {
  value.len() <= MAX_ARG_BYTES && !value.contains('\0')
}

pub(crate) fn validate_argv(argv: &[String]) -> io::Result<()> {
  if argv.len() > MAX_ARGS
    || argv.iter().any(|arg| !valid_argument(arg))
    || argv.iter().map(String::len).sum::<usize>() > MAX_BYTES
  {
    return Err(invalid("command arguments exceed their limits"));
  }
  Ok(())
}

/// The plugin's own host-staged assets and persistent data, each exposed two
/// ways: as an environment variable inside the sandbox (so source can build
/// host-real absolute paths) and as a `$...` token in exec args and constraints.
/// Both share one host-chosen value at launch (never stored in the record), so
/// a plugin declares machine-independent paths like
/// `$OMARCHY_PLUGIN_PATH/sounds/ball.wav` and the host resolves them to the
/// staged, machine-specific location.
pub const PLUGIN_PATH: &str = "$OMARCHY_PLUGIN_PATH";
pub const PLUGIN_DATA: &str = "$OMARCHY_PLUGIN_DATA";
pub const PLUGIN_PATH_ENV: &str = "OMARCHY_PLUGIN_PATH";
pub const PLUGIN_DATA_ENV: &str = "OMARCHY_PLUGIN_DATA";

/// One resolvable plugin path: the token a manifest uses, the env var exposing
/// the same value in the sandbox, and the host-chosen value they both mean.
/// Only the directories that are actually admitted are present.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct PluginDir {
  pub token: &'static str,
  pub env: &'static str,
  pub value: String,
}

impl PluginDir {
  /// The per-session stage of the plugin's own read-only assets/bundle.
  pub fn assets(value: String) -> Self {
    Self {
      token: PLUGIN_PATH,
      env: PLUGIN_PATH_ENV,
      value,
    }
  }
  /// The persistent per-identity data directory behind the storage mount.
  pub fn data(value: String) -> Self {
    Self {
      token: PLUGIN_DATA,
      env: PLUGIN_DATA_ENV,
      value,
    }
  }
}

/// Guard a trailing relative portion against escaping the pinned dir: `..` and
/// `.` components and an empty path are rejected, so a worker can never
/// concatenate or traverse out of the host path.
fn guard(rest: &str) -> io::Result<()> {
  let trimmed = rest.strip_suffix('/').unwrap_or(rest);
  if trimmed.is_empty()
    || trimmed
      .split('/')
      .any(|part| part == ".." || part == "." || part.is_empty())
  {
    return Err(invalid(
      "plugin path must not traverse outside the plugin directory",
    ));
  }
  Ok(())
}

/// Resolve a value against the admitted plugin directories. For each token the
/// value may use either form: a `$TOKEN/rel` token is rewritten to `value/rel`
/// (the bare `$TOKEN` to `value`), or an absolute path already under `value/`
/// passes through untouched. Anything else passes through unchanged and must
/// still match its constraint. Both in-the-directory forms are guarded.
pub fn resolve_plugin_path(value: &str, dirs: &[PluginDir]) -> io::Result<String> {
  for dir in dirs {
    if let Some(rest) = value.strip_prefix(dir.token) {
      let rest = match rest.strip_prefix('/') {
        Some(rest) => rest,
        None if rest.is_empty() => return Ok(dir.value.clone()),
        None => continue,
      };
      guard(rest)?;
      return Ok(format!("{}/{}", dir.value, rest));
    }
    if value == dir.value {
      return Ok(value.to_owned());
    }
    let prefix = format!("{}/", dir.value);
    if value.starts_with(&prefix) {
      guard(&value[prefix.len()..])?;
      return Ok(value.to_owned());
    }
  }
  Ok(value.to_owned())
}

impl Argument {
  fn validate(&self) -> io::Result<()> {
    let valid = match self {
      Self::Exact { value } => valid_argument(value),
      Self::OneOf { values } => {
        !values.is_empty()
          && values.len() <= 32
          && values.iter().all(|value| valid_argument(value))
          && values.iter().collect::<BTreeSet<_>>().len() == values.len()
      }
      Self::Integer { min, max } => min <= max,
      Self::Text { prefix, min, max } => {
        valid_argument(prefix) && min <= max && prefix.len() <= *max && *max <= MAX_ARG_BYTES
      }
      Self::Pattern { value, max } => *max <= MAX_ARG_BYTES && pattern(value).is_ok(),
    };
    if valid {
      Ok(())
    } else {
      Err(invalid("invalid command argument constraint"))
    }
  }

  fn accepts(&self, value: &str) -> bool {
    match self {
      Self::Exact { value: expected } => value == expected,
      Self::OneOf { values } => values.iter().any(|expected| value == expected),
      Self::Integer { min, max } => {
        !value.is_empty()
          && value.bytes().all(|byte| byte.is_ascii_digit())
          && (value == "0" || !value.starts_with('0'))
          && value
            .parse::<u64>()
            .is_ok_and(|number| (*min..=*max).contains(&number))
      }
      Self::Text { prefix, min, max } => {
        (*min..=*max).contains(&value.len()) && value.starts_with(prefix)
      }
      Self::Pattern {
        value: expected,
        max,
      } => value.len() <= *max && pattern(expected).is_ok_and(|pattern| pattern.is_match(value)),
    }
  }

  fn accepts_with(&self, value: &str, dirs: &[PluginDir]) -> bool {
    if !self.accepts(value) {
      return false;
    }
    if let Self::Text { prefix, .. } = self {
      // A bare token/root text prefix denotes this directory, not a sibling
      // whose name happens to begin with it. Preserve ordinary text prefixes
      // (including filename prefixes already beneath a plugin root).
      for dir in dirs {
        if prefix == &dir.value && value != dir.value
          && !value.starts_with(&format!("{}/", dir.value)) {
          return false;
        }
      }
    }
    true
  }

  /// Substitute the admitted plugin directories into path-like constraint
  /// values (exact/one-of/text). Patterns are intentionally left unresolved so
  /// they never accept a literal variable token or a guessed host path.
  fn resolve(&self, dirs: &[PluginDir]) -> io::Result<Self> {
    Ok(match self {
      Self::Exact { value } => Self::Exact {
        value: resolve_plugin_path(value, dirs)?,
      },
      Self::OneOf { values } => Self::OneOf {
        values: values
          .iter()
          .map(|value| resolve_plugin_path(value, dirs))
          .collect::<io::Result<Vec<_>>>()?,
      },
      Self::Integer { min, max } => Self::Integer {
        min: *min,
        max: *max,
      },
      Self::Text { prefix, min, max } => Self::Text {
        prefix: resolve_plugin_path(prefix, dirs)?,
        min: *min,
        max: *max,
      },
      Self::Pattern { value, max } => Self::Pattern {
        value: value.clone(),
        max: *max,
      },
    })
  }
}

impl Tree {
  pub fn leaves(&self) -> io::Result<BTreeSet<String>> {
    let mut leaves = BTreeSet::new();
    self.validate(0, &mut 0, &mut leaves)?;
    serde_json::to_writer(Size(0), self)?;
    Ok(leaves)
  }

  fn validate(
    &self,
    depth: usize,
    nodes: &mut usize,
    leaves: &mut BTreeSet<String>,
  ) -> io::Result<()> {
    *nodes += 1;
    if depth > MAX_ARGS
      || *nodes > MAX_NODES
      || self.next.len() > MAX_NODES
      || self.end.is_none() && self.next.is_empty()
    {
      return Err(invalid("command tree is empty or exceeds its limits"));
    }
    if let Some(name) = &self.end {
      validate_id(name)?;
      if !leaves.insert(name.clone()) {
        return Err(invalid("command terminal names must be unique"));
      }
    }
    for step in &self.next {
      step.arg.validate()?;
      step.then.validate(depth + 1, nodes, leaves)?;
    }
    Ok(())
  }

  /// All selected names must come from this reviewed tree. No exclusion rules,
  /// command-line reparsing, wildcard suffixes, normalization or first-match
  /// precedence: a complete path to any selected terminal is sufficient.
  pub fn check(&self, selected: &BTreeSet<String>, argv: &[String]) -> io::Result<()> {
    self.check_resolved(&[], selected, argv)
  }

  fn check_resolved(&self, dirs: &[PluginDir], selected: &BTreeSet<String>, argv: &[String]) -> io::Result<()> {
    if !selected.is_subset(&self.leaves()?) {
      return Err(invalid("command selection was not requested"));
    }
    validate_argv(argv)?;
    if self.matches(dirs, selected, argv) {
      Ok(())
    } else {
      Err(invalid("command invocation was not granted"))
    }
  }

  fn matches(&self, dirs: &[PluginDir], selected: &BTreeSet<String>, argv: &[String]) -> bool {
    match argv.split_first() {
      None => self
        .end
        .as_ref()
        .is_some_and(|name| selected.contains(name)),
      Some((arg, rest)) => self
        .next
        .iter()
        .any(|step| step.arg.accepts_with(arg, dirs) && step.then.matches(dirs, selected, rest)),
    }
  }

  /// Resolve every path constraint against the admitted plugin directories.
  fn resolve(&self, dirs: &[PluginDir]) -> io::Result<Self> {
    Ok(Tree {
      end: self.end.clone(),
      next: self
        .next
        .iter()
        .map(|step| {
          Ok(Step {
            arg: step.arg.resolve(dirs)?,
            then: step.then.resolve(dirs)?,
          })
        })
        .collect::<io::Result<Vec<_>>>()?,
    })
  }

  /// Check like [`Tree::check`], first resolving the plugin paths
  /// symmetrically in the candidate argv and the tree constraints so a plugin
  /// can invoke a host executable against its own staged assets or data at a
  /// machine-specific path. `dirs` holds only the directories actually
  /// admitted (assets when exec is granted, data when storage is granted).
  pub fn check_with(
    &self,
    dirs: &[PluginDir],
    selected: &BTreeSet<String>,
    argv: &[String],
  ) -> io::Result<()> {
    if dirs.is_empty() {
      return self.check(selected, argv);
    }
    let argv = argv
      .iter()
      .map(|arg| resolve_plugin_path(arg, dirs))
      .collect::<io::Result<Vec<_>>>()?;
    self.resolve(dirs)?.check_resolved(dirs, selected, &argv)
  }
}

#[cfg(test)]
mod tests {
  use super::*;
  use serde_json::json;

  fn terminal(name: &str) -> Tree {
    Tree {
      end: Some(name.into()),
      next: Vec::new(),
    }
  }
  fn step(arg: Argument, then: Tree) -> Step {
    Step { arg, then }
  }
  fn exact(value: &str, then: Tree) -> Step {
    step(
      Argument::Exact {
        value: value.into(),
      },
      then,
    )
  }
  fn tree(next: Vec<Step>) -> Tree {
    Tree { end: None, next }
  }
  fn selected(names: &[&str]) -> BTreeSet<String> {
    names.iter().map(|s| (*s).into()).collect()
  }
  fn args(values: &[&str]) -> Vec<String> {
    values.iter().map(|s| (*s).into()).collect()
  }

  #[test]
  fn plugin_path_variable_resolves_within_the_pinned_directory_only() {
    let root = "/run/user/1000/omarchy/plugin/p.test";
    let dirs = [PluginDir::assets(root.to_owned())];
    assert_eq!(
      resolve_plugin_path("$OMARCHY_PLUGIN_PATH", &dirs).unwrap(),
      root
    );
    assert_eq!(
      resolve_plugin_path("$OMARCHY_PLUGIN_PATH/sounds/ball.wav", &dirs).unwrap(),
      "/run/user/1000/omarchy/plugin/p.test/sounds/ball.wav"
    );
    assert_eq!(
      resolve_plugin_path("/etc/passwd", &dirs).unwrap(),
      "/etc/passwd"
    );
    // An absolute path already under the root also passes through (the plugin
    // may have built it from the OMARCHY_PLUGIN_PATH env var), untouched.
    assert_eq!(
      resolve_plugin_path("/run/user/1000/omarchy/plugin/p.test/sounds/a.wav", &dirs).unwrap(),
      "/run/user/1000/omarchy/plugin/p.test/sounds/a.wav"
    );
    for bad in [
      "$OMARCHY_PLUGIN_PATH/../etc/shadow",
      "$OMARCHY_PLUGIN_PATH/./x",
      "$OMARCHY_PLUGIN_PATH/",
      "$OMARCHY_PLUGIN_PATH/..",
      // Even a real absolute path under the root may not traverse out of it.
      "/run/user/1000/omarchy/plugin/p.test/../../etc/shadow",
      "/run/user/1000/omarchy/plugin/p.test/./x",
    ] {
      assert!(
        resolve_plugin_path(bad, &dirs).is_err(),
        "should reject {bad}"
      );
    }
  }

  #[test]
  fn plugin_data_and_assets_resolve_independently() {
    let dirs = [
      PluginDir::assets("/run/user/1000/omarchy/plugin/test.assets".to_owned()),
      PluginDir::data("/home/me/.local/state/omarchy/plugins/test.assets".to_owned()),
    ];
    // Each token resolves to its own directory.
    assert_eq!(
      resolve_plugin_path("$OMARCHY_PLUGIN_DATA/save.json", &dirs).unwrap(),
      "/home/me/.local/state/omarchy/plugins/test.assets/save.json"
    );
    assert_eq!(
      resolve_plugin_path("$OMARCHY_PLUGIN_PATH/sounds/a.wav", &dirs).unwrap(),
      "/run/user/1000/omarchy/plugin/test.assets/sounds/a.wav"
    );
    // Traversal is rejected from either directory.
    assert!(resolve_plugin_path("$OMARCHY_PLUGIN_DATA/../etc/shadow", &dirs).is_err());
    assert!(resolve_plugin_path("$OMARCHY_PLUGIN_PATH/../etc/shadow", &dirs).is_err());
    // Similar variable names are not aliases for an admitted directory.
    for value in [
      "$OMARCHY_PLUGIN_PATH_EXTRA",
      "$OMARCHY_PLUGIN_DATA..",
      "$OMARCHY_PLUGIN_PATHother/file",
    ] {
      assert_eq!(resolve_plugin_path(value, &dirs).unwrap(), value);
    }
  }

  #[test]
  fn check_with_resolves_plugin_path_symmetrically_and_rejects_escape() {
    let policy = tree(vec![step(
      Argument::Text {
        prefix: "$OMARCHY_PLUGIN_PATH/sounds/".into(),
        min: 12,
        max: 200,
      },
      terminal("play"),
    )]);
    let root = "/run/user/1000/omarchy/plugin/test.assets";
    let dirs = [PluginDir::assets(root.to_owned())];
    let resolved_arg = format!("{root}/sounds/ball.wav");
    // Symbolic argv accepted once both sides resolve to the same host path.
    assert!(
      policy
        .check_with(
          &dirs,
          &selected(&["play"]),
          &args(&["$OMARCHY_PLUGIN_PATH/sounds/ball.wav"])
        )
        .is_ok()
    );
    // Already-resolved argv (built from the env var) is accepted too.
    assert!(
      policy
        .check_with(&dirs, &selected(&["play"]), &args(&[&resolved_arg]))
        .is_ok()
    );
    // Without the variable the reviewed tree matches the literal token only.
    assert!(
      policy
        .check_with(
          &[],
          &selected(&["play"]),
          &args(&["$OMARCHY_PLUGIN_PATH/sounds/ball.wav"])
        )
        .is_ok()
    );
    // Traversal and wrong-directory targets are rejected, in both forms.
    assert!(
      policy
        .check_with(
          &dirs,
          &selected(&["play"]),
          &args(&["$OMARCHY_PLUGIN_PATH/../etc/passwd"])
        )
        .is_err()
    );
    assert!(
      policy
        .check_with(&dirs, &selected(&["play"]), &args(&["/etc/passwd"]))
        .is_err()
    );
    // A real absolute path under the root may not traverse out of it either.
    assert!(
      policy
        .check_with(
          &dirs,
          &selected(&["play"]),
          &args(&["/run/user/1000/omarchy/plugin/test.assets/sounds/../x"])
        )
        .is_err()
    );
    assert!(
      policy
        .check_with(&dirs, &selected(&["play"]), &args(&["x"]))
        .is_err()
    );
  }

  #[test]
  fn complete_selected_leaves_not_prefixes_or_parent_authority() {
    let status = Tree {
      end: Some("status".into()),
      next: vec![exact(
        "--hostname",
        tree(vec![exact("example.test", terminal("host-status"))]),
      )],
    };
    let policy = tree(vec![exact("auth", tree(vec![exact("status", status)]))]);
    assert_eq!(
      policy.leaves().unwrap(),
      selected(&["status", "host-status"])
    );
    for input in [
      vec!["auth", "status"],
      vec!["auth", "status", "--hostname", "example.test"],
    ] {
      assert!(
        policy
          .check(&selected(&["status", "host-status"]), &args(&input))
          .is_ok()
      );
    }
    for input in [
      vec![],
      vec!["auth"],
      vec!["auth", "token"],
      vec!["auth", "status", "--show-token"],
      vec!["auth", "status", "--hostname", "other.test"],
      vec!["auth", "status", "--hostname=example.test"],
      vec![
        "auth",
        "status",
        "--hostname",
        "example.test",
        "--show-token",
      ],
    ] {
      assert!(
        policy
          .check(&selected(&["status", "host-status"]), &args(&input))
          .is_err(),
        "{input:?}"
      );
    }
    assert!(
      policy
        .check(
          &selected(&["status"]),
          &args(&["auth", "status", "--hostname", "example.test"])
        )
        .is_err()
    );
    assert!(
      policy
        .check(&selected(&["host-status"]), &args(&["auth", "status"]))
        .is_err()
    );
    assert!(
      policy
        .check(&selected(&[]), &args(&["auth", "status"]))
        .is_err()
    );
    assert!(
      policy
        .check(&selected(&["auth", "status"]), &args(&["auth", "status"]))
        .is_err()
    );
  }

  #[test]
  fn plugin_root_text_prefixes_require_a_path_component_boundary() {
    for dir in [PluginDir::data("/private/data".into()), PluginDir::assets("/private/assets".into())] {
      let dirs = [dir.clone()];
      for prefix in [dir.token.to_owned(), dir.value.clone()] {
        let policy = tree(vec![step(Argument::Text {prefix, min: 1, max: 1024}, terminal("read"))]);
        for candidate in [dir.token.to_owned(), dir.value.clone(), format!("{}/save.json", dir.token), format!("{}/save.json", dir.value)] {
          assert!(policy.check_with(&dirs, &selected(&["read"]), &[candidate.clone()]).is_ok(), "{candidate}");
        }
        for candidate in [format!("{}.vault/secret", dir.value), format!("{}-other/file", dir.value),
          format!("{}/", dir.value), format!("{}/../secret", dir.value), format!("{}/./file", dir.value)] {
          assert!(policy.check_with(&dirs, &selected(&["read"]), &[candidate.clone()]).is_err(), "{candidate}");
        }
      }
      let policy = tree(vec![step(Argument::Text {
        prefix: format!("{}/image-", dir.token), min: 1, max: 1024
      }, terminal("read"))]);
      assert!(policy.check_with(&dirs, &selected(&["read"]), &[format!("{}/image-one.png", dir.value)]).is_ok());
    }
  }

  #[test]
  fn alternatives_and_values_are_literal_bounded_arguments() {
    let policy = tree(vec![step(
      Argument::OneOf {
        values: args(&["list", "show"]),
      },
      tree(vec![step(
        Argument::Integer { min: 1, max: 100 },
        tree(vec![step(
          Argument::Text {
            prefix: "query=".into(),
            min: 6,
            max: 32,
          },
          terminal("read"),
        )]),
      )]),
    )]);
    let selection = selected(&["read"]);
    for input in [
      vec!["list", "1", "query=hello world"],
      vec!["show", "100", "query=$(touch /tmp/no)"],
    ] {
      assert!(policy.check(&selection, &args(&input)).is_ok());
    }
    for input in [
      vec!["delete", "1", "query=x"],
      vec!["list", "0", "query=x"],
      vec!["list", "101", "query=x"],
      vec!["list", "01", "query=x"],
      vec!["list", "+1", "query=x"],
      vec!["list", "18446744073709551616", "query=x"],
      vec!["list", "1", "--input=/host/file"],
      vec!["list", "1", "query=abcdefghijklmnopqrstuvwxyz1234567890"],
      vec!["list", "1", "query=x\0y"],
      vec!["list", "1", "query=x", "extra"],
    ] {
      assert!(
        policy.check(&selection, &args(&input)).is_err(),
        "{input:?}"
      );
    }
    let empty = terminal("no-arguments");
    assert!(empty.check(&selected(&["no-arguments"]), &[]).is_ok());
    assert!(
      empty
        .check(&selected(&["no-arguments"]), &args(&[""]))
        .is_err()
    );
  }

  #[test]
  fn patterns_match_whole_bounded_arguments_without_exclusions() {
    let arg = Argument::Pattern {
      value: "/threads/[0-9]+".into(),
      max: 24,
    };
    assert!(arg.validate().is_ok());
    for value in ["/threads/1", "/threads/123456"] {
      assert!(arg.accepts(value));
    }
    for value in [
      "x/threads/1",
      "/threads/1/other",
      "/threads/../secret",
      "/threads/%31",
      "/threads/1\n",
      "/threads/12345678901234567890",
    ] {
      assert!(!arg.accepts(value), "{value}");
    }
    assert!(pattern("a|ab").unwrap().is_match("ab"));
    for value in ["a)|.*(?:", "(?=a)", r"(a)\1", "[a-z]{100000}"] {
      assert!(pattern(value).is_err(), "{value}");
    }
    assert!(!pattern("(?m:^a$)").unwrap().is_match("x\na\nx"));
    assert!(pattern(&"a".repeat(4097)).is_err());
    assert!(
      Argument::Pattern {
        value: ".*".into(),
        max: 8193
      }
      .validate()
      .is_err()
    );
  }

  #[test]
  fn positive_overlap_has_no_order_or_exclusion_semantics() {
    let mut policy = tree(vec![
      step(
        Argument::Text {
          prefix: "status".into(),
          min: 6,
          max: 12,
        },
        terminal("broad"),
      ),
      exact("status", terminal("exact")),
    ]);
    for _ in 0..2 {
      assert!(
        policy
          .check(&selected(&["exact"]), &args(&["status"]))
          .is_ok()
      );
      assert!(
        policy
          .check(&selected(&["exact"]), &args(&["status-extra"]))
          .is_err()
      );
      policy.next.reverse();
    }
    for value in [
      json!({"end":"status", "exclude":["token"]}),
      json!({"end":"status", "deny":true}),
      json!({"end":"status", "allowRest":true}),
    ] {
      assert!(serde_json::from_value::<Tree>(value).is_err());
    }
    assert!(serde_json::from_value::<Argument>(json!({"kind":"regex", "pattern":".*"})).is_err());
  }

  #[test]
  fn malformed_and_oversized_trees_fail_before_matching() {
    assert!(Tree::default().leaves().is_err());
    assert!(terminal("*").leaves().is_err());
    assert!(
      tree(vec![
        exact("one", terminal("same")),
        exact("two", terminal("same"))
      ])
      .leaves()
      .is_err()
    );
    for constraint in [
      Argument::OneOf { values: vec![] },
      Argument::OneOf {
        values: args(&["same", "same"]),
      },
      Argument::Integer { min: 2, max: 1 },
      Argument::Exact { value: "\0".into() },
      Argument::Text {
        prefix: "prefix".into(),
        min: 0,
        max: 1,
      },
      Argument::Text {
        prefix: "".into(),
        min: 2,
        max: 1,
      },
    ] {
      assert!(
        tree(vec![step(constraint, terminal("test"))])
          .leaves()
          .is_err()
      );
    }
    let mut deep = terminal("deep");
    for _ in 0..MAX_ARGS {
      deep = tree(vec![exact("a", deep)]);
    }
    let bytes = serde_json::to_vec(&deep).unwrap();
    let restored: Tree = serde_json::from_slice(&bytes).unwrap();
    assert_eq!(restored, deep);
    assert!(
      deep
        .check(&selected(&["deep"]), &vec!["a".into(); MAX_ARGS])
        .is_ok()
    );
    assert!(tree(vec![exact("a", deep)]).leaves().is_err());
    let wide = tree(
      (0..MAX_NODES)
        .map(|i| exact("a", terminal(&format!("leaf{i}"))))
        .collect(),
    );
    assert!(wide.leaves().is_err());
    let huge = tree(
      (0..16)
        .map(|i| exact(&"a".repeat(MAX_ARG_BYTES), terminal(&format!("leaf{i}"))))
        .collect(),
    );
    assert!(huge.leaves().is_err());
    let policy = terminal("empty");
    assert!(
      policy
        .check(&selected(&["empty"]), &vec!["a".into(); MAX_ARGS + 1])
        .is_err()
    );
    assert!(
      policy
        .check(&selected(&["empty"]), &["a".repeat(MAX_ARG_BYTES + 1)])
        .is_err()
    );
  }
}
