use std::process::Command;

#[test]
fn bootstrap_reports_errors_as_one_json_record_without_side_files() {
  for (args, expected) in [
    (vec!["--exec"], "invalid"),
    (vec!["--notify", "", "body"], "invalid"),
    (vec!["--settings", "not JSON"], "invalid"),
    (vec!["--open-url", "browser", "file:///private"], "invalid"),
    (vec!["--exec", "fixture"], "unavailable"),
    (vec!["--manage", "/nonexistent"], "invalid"),
    (vec!["--worker"], "invalid"),
    (vec!["--http", "/unused-metadata-file"], "invalid"),
  ] {
    let output = Command::new(env!("CARGO_BIN_EXE_omarchy-ward"))
      .arg("--json")
      .args(args)
      .output()
      .unwrap();
    assert_eq!(output.status.code(), Some(1));
    assert!(output.stderr.is_empty());
    assert_eq!(
      serde_json::from_slice::<serde_json::Value>(&output.stdout).unwrap(),
      serde_json::json!({"version":1,"status":expected})
    );
  }
}
