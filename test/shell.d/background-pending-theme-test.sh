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

# Wallpapers larger than any screen decode at each screen's own size, so a
# larger screen finishes later than a smaller one, as on a real desk.
reveal=$(mktemp -d)
trap 'rm -rf "$stage" "$reveal"' EXIT
mkdir -p "$reveal/home/.local/state/omarchy/current"
ln -s "$ROOT/shell/plugins/background" "$reveal/background"
ln -s "$ROOT/shell/Commons" "$reveal/Commons"
ln -s "$ROOT/shell/Ui" "$reveal/Ui"
magick -size 4000x2500 gradient:magenta-navy "$reveal/still.png"
magick -size 4000x2500 gradient:cyan-orange "$reveal/home/next.png"
ln -s "$reveal/still.png" "$reveal/home/.local/state/omarchy/current/background"
cp "$SHELL_TEST_DIR/fixtures/background-reveal/shell.qml" "$reveal/shell.qml"
output=$(HOME="$reveal/home" timeout 10 quickshell -p "$reveal" --no-color 2>&1) || fail "background reveal fixture exits cleanly" "$output"
[[ $output == *"RESULT pass"* && $output != *"RESULT fail"* ]] || fail "every screen slides together and keeps its frame until its new background is drawn" "$output"
pass "every screen joins the reveal, also one that decoded after it started"
pass "the reveal comes down only after every screen has drawn its new background"
