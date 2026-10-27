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
[[ $output == *"RESULT pass"* && $output != *"RESULT fail"* ]] || fail "the authoritative palette survives the previous background fallback timer" "$output"
pass "a pending still transition cannot restore old colors after the current theme is applied"

# A theme switch replaces the file behind a path the previous theme also used.
qml_fixture_scratch
trap 'rm -rf "$stage"; qml_fixture_cleanup' EXIT
theme_backgrounds="$QML_FIXTURE_TMP/home/.local/state/omarchy/current/theme/backgrounds"
mkdir -p "$theme_backgrounds"
magick -size 128x128 xc:magenta "$theme_backgrounds/1-same-name.png"
magick -size 128x128 xc:lime "$QML_FIXTURE_TMP/next.png"
cp "$QML_FIXTURE_TMP/next.png" "$QML_FIXTURE_TMP/snapshot.png"
ln -s "$theme_backgrounds/1-same-name.png" "$QML_FIXTURE_TMP/home/.local/state/omarchy/current/background"
BACKGROUND_TEST_STAGE="$QML_FIXTURE_TMP" run_qml_fixture background-same-path-theme "the same-path theme fixture grabs the base wallpaper" Commons Ui plugins
pixel=$(magick "$QML_FIXTURE_TMP/base.png" -format '%[hex:p{8,8}]' info:)
[[ ${pixel:0:6} == "00FF00" ]] || fail "a theme switch reloads a background whose path the previous theme also used" "base pixel $pixel"
pass "a theme switch reloads a background whose path the previous theme also used"
