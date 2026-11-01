#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_quickshell "manifest entrypoint load test"
require_command python3

manifest_entries=$(ROOT="$ROOT" python3 <<'PY'
import base64
import json
import os
from pathlib import Path

root = Path(os.environ["ROOT"])
entries = []

kind_entry_points = {
  "bar": "bar",
  "bar-widget": "barWidget",
  "menu": "menu",
  "overlay": "overlay",
  "panel": "panel",
  "service": "service",
}

for manifest_path in sorted((root / "shell/plugins").glob("**/manifest.json")) + sorted((root / "shell/plugins").glob("**/*.manifest.json")):
  manifest = json.loads(manifest_path.read_text())
  for kind in manifest.get("kinds", []):
    entry_key = kind_entry_points.get(kind)
    entry_point = manifest.get("entryPoints", {}).get(entry_key)
    if not entry_point:
      continue
    entry_path = manifest_path.parent / entry_point
    entries.append({
      "id": manifest["id"],
      "kind": kind,
      "entryKey": entry_key,
      "entryPoint": entry_point,
      "url": entry_path.resolve().as_uri(),
      "manifest": manifest,
    })

print(base64.b64encode(json.dumps(entries).encode()).decode())
PY
)

OMARCHY_QML_MANIFESTS="$manifest_entries" \
  run_qml_fixture manifest-entrypoints "manifest entrypoints load" Ui Commons
