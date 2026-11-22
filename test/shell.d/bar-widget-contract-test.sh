#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_quickshell "bar widget contract test"
require_command python3

bar_widgets=$(ROOT="$ROOT" python3 <<'PY'
import base64
import json
import os
from pathlib import Path

root = Path(os.environ["ROOT"])
entries = []
for manifest_path in sorted((root / "shell/plugins").glob("**/manifest.json")) + sorted((root / "shell/plugins").glob("**/*.manifest.json")):
  manifest = json.loads(manifest_path.read_text())
  if "bar-widget" not in manifest.get("kinds", []):
    continue
  entry_point = manifest.get("entryPoints", {}).get("barWidget")
  if not entry_point:
    continue
  entries.append({
    "id": manifest["id"],
    "url": (manifest_path.parent / entry_point).resolve().as_uri(),
    "manifest": manifest,
  })

print(base64.b64encode(json.dumps(entries).encode()).decode())
PY
)

OMARCHY_QML_BAR_WIDGETS="$bar_widgets" \
  run_qml_fixture bar-widget-contract "bar widget contracts pass" Ui Commons
