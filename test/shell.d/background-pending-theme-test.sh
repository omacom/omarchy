#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_compositor "pending background theme cancellation"
require_command quickshell
require_command python3
require_command magick

stage=$(mktemp -d)
trap 'rm -rf "$stage"' EXIT
mkdir -p "$stage/home/.local/state/omarchy/current"
ln -s "$ROOT/shell/plugins/background" "$stage/background"
ln -s "$ROOT/shell/Commons" "$stage/Commons"
ln -s "$ROOT/shell/Ui" "$stage/Ui"
magick -size 128x128 xc:magenta "$stage/still.png"
magick -size 128x128 xc:cyan "$stage/home/next.png"
ln -s "$stage/still.png" "$stage/home/.local/state/omarchy/current/background"
python3 - "$ROOT/shell/shell.qml" "$SHELL_TEST_DIR/fixtures/background-pending-theme/shell.qml" "$stage/shell.qml" <<'PY'
import re
import sys
from pathlib import Path
source = Path(sys.argv[1]).read_text()
method = re.search(r'^    function applyTheme\([^\n]+\n.*?^    }', source, re.M | re.S)
assert method, 'real shell applyTheme method not found'
fixture = Path(sys.argv[2]).read_text()
Path(sys.argv[3]).write_text(fixture.replace('  // APPLY_THEME_FUNCTION', method.group()))
PY
output=$(HOME="$stage/home" timeout 10 quickshell -p "$stage" --no-color 2>&1) || fail "pending theme fixture exits cleanly" "$output"
[[ $output == *"RESULT pass"* && $output != *"RESULT fail"* ]] || fail "the palette survives the fallback timer, and a still covers the desktop until OWE takes a video" "$output"
pass "a pending still transition cannot restore old colors after the current theme is applied"
pass "a video chosen during a reveal keeps the stills on screen, and the reveal ends on its still"
