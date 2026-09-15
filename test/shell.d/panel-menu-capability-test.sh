#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

if ! command -v quickshell >/dev/null 2>&1; then
  pass "quickshell not installed; skipping panel menu capability runtime test"
  exit 0
fi
require_command python3
require_command timeout

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
mkdir "$tmpdir/services"
cp "$ROOT/shell/services/PluginShellApi.qml" "$ROOT/shell/services/PluginAppLibraryApi.qml" "$tmpdir/services/"

# Exercise the production binding and grant across a real Qt model boundary.
# Node alone cannot reproduce Qt's conversion of nested arrays to sequences.
python3 - "$ROOT" "$tmpdir/shell.qml" <<'PY'
from pathlib import Path
import re
import sys

root = Path(sys.argv[1])
source = (root / "shell/shell.qml").read_text()
fixture = (root / "test/shell.d/fixtures/panel-menu-capability/shell.qml").read_text()
panel = source[source.index("id: panelEntry"):]
replacements = {
    "__PANEL_MANIFEST_BINDING__": re.search(r"readonly property var manifest: [^\n]+", panel).group(),
    "__MANIFEST_HAS_KIND__": re.search(r"function manifestHasKind\([^)]*\) \{.*?\n  \}", source, re.S).group(),
    "__APP_LIBRARY_GRANT__": re.search(r"appLibrary: (shell\.manifestHasKind\(manifest, \"menu\"\).*?),\n", source, re.S).group(1),
    "__APP_LIBRARY_SIGNALS__": re.search(r"Connections \{\s+target: shell\.appLibrary\n.*?\n  \}", source, re.S).group(),
}
for marker, code in replacements.items():
    fixture = fixture.replace(marker, code)
Path(sys.argv[2]).write_text(fixture)
PY

# No windows or Wayland services: this test also runs with Qt's offscreen backend.
if ! env -u WAYLAND_DISPLAY QT_QPA_PLATFORM=offscreen \
  timeout 8 quickshell --no-color -p "$tmpdir" >"$tmpdir/log" 2>&1; then
  fail "panel menu capability fixture runs" "$(<"$tmpdir/log")"
fi
if ! grep -q 'PANEL_MENU_OK' "$tmpdir/log"; then
  fail "menu plugins retain their app library across the Qt model boundary" "$(<"$tmpdir/log")"
fi
pass "menu plugins retain their app library across the Qt model boundary"
pass "ordinary panels cannot access the app library"
pass "app and icon refresh signals reach menu plugins"
