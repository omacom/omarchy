use omarchy_ward::{exec::Ask, exec_policy::PluginDir, grants::Manifest};
use serde_json::Value;
use std::fs;

// Author-facing JSON examples exercise the actual parser and policy, not a
// separate permissive validator. This test does not launch QML or host jobs.
#[test]
fn authoring_examples_match_the_implemented_contract() {
  let document = include_str!("../../../../../docs/sandboxed-plugin-authoring.md");
  let mut manifests = 0;
  let mut commands = 0;
  for block in document.split("```json\n").skip(1) {
    let json = block.split_once("```").unwrap().0;
    let example: Value = serde_json::from_str(json).unwrap();
    if example.get("schemaVersion").is_some() {
      let root = tempfile::tempdir().unwrap();
      fs::write(root.path().join("manifest.json"), json).unwrap();
      for entry in example["entryPoints"].as_object().unwrap().values() {
        let path = root.path().join(entry.as_str().unwrap());
        fs::create_dir_all(path.parent().unwrap()).unwrap();
        fs::write(path, "import QtQuick\nItem {}\n").unwrap();
      }
      let manifest = Manifest::read(root.path()).unwrap();
      assert!(manifest.sandbox.requests.storage.asked());
      assert!(!manifest.sandbox.requests.storage.required);
      manifests += 1;
    } else if example.get("executable").is_some() {
      let ask: Ask = serde_json::from_value(example).unwrap();
      ask.validate().unwrap();
      let selected = ["chime".into()].into();
      let paths = [PluginDir::assets("/run/example/assets".into())];
      let mut argv: Vec<String> = ["--volume", "0.5", "$OMARCHY_PLUGIN_PATH/sounds/chime.wav"]
        .map(String::from)
        .into();
      ask.tree.check_with(&paths, &selected, &argv).unwrap();
      argv[2] = "/run/example/assets/sounds/chime.wav".into();
      ask.tree.check_with(&paths, &selected, &argv).unwrap();
      assert!(
        ask
          .tree
          .check_with(&paths, &Default::default(), &argv)
          .is_err()
      );
      argv.push("--extra".into());
      assert!(ask.tree.check_with(&paths, &selected, &argv).is_err());
      argv.pop();
      argv[2] = "$OMARCHY_PLUGIN_PATH/../secret".into();
      assert!(ask.tree.check_with(&paths, &selected, &argv).is_err());
      commands += 1;
    } else {
      panic!("new JSON example needs a native contract assertion");
    }
  }
  assert!(
    manifests > 0 && commands > 0,
    "authoring examples disappeared"
  );
}
