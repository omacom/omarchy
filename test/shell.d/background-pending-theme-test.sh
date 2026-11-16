#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command magick

# Background sizes are probed from real files, so these run without a desktop.
sizes=$(mktemp -d)
trap 'rm -rf "$sizes"' EXIT
export BACKGROUND_SIZE_TEST_DIR="$sizes"

# Keep the multi-frame fixtures tiny: incorrect concatenated dimensions must
# fail before a Qt image is ever allowed to allocate from them.
magick -size 20x10 xc:red -size 20x10 xc:blue -set delay 20 -loop 0 "$sizes/animated [wallpaper] ü.gif"
magick -size 20x10 xc:red "$sizes/still.gif"
magick -size 20x10 xc:red "$sizes/still.png"
magick -size 20x10 xc:red "$sizes/still.jpg"
magick -size 20x10 xc:red "$sizes/still.webp"
# Brackets in a name must stay literal: a frame suffix would make ImageMagick
# glob this to its siblings and print both their sizes.
magick -size 20x10 xc:red "$sizes/wallpaper[12].png"
magick -size 40x30 xc:blue "$sizes/wallpaper1.png"
magick -size 50x40 xc:green "$sizes/wallpaper2.png"

run_node_test <<'JS'
const fs = require('fs')
const child = require('child_process')
const qml = fs.readFileSync(path.join(root, 'shell/plugins/background/Background.qml'), 'utf8')
const probeBody = qml.match(/  function probeNextSize\(\) \{([\s\S]*?)\n  \}/)[1]
const exitedBody = qml.match(/id: sizeProbe[\s\S]*?onExited: function\(exitCode\) \{([\s\S]*?)\n    \}/)[1]
const decodeBody = qml.match(/      function decodeSize\(path\) \{([\s\S]*?)\n      \}/)[1]
const probe = new Function('sizeProbe', 'sizeQueue', probeBody)
const finished = new Function('root', 'sizeProbe', 'sizeProbeOut', 'exitCode', 'path', exitedBody)
const decode = new Function('root', 'sized', 'decodeWidth', 'decodeHeight', 'Qt', 'path', decodeBody)

for (const name of ['animated [wallpaper] ü.gif', 'still.gif', 'still.png', 'still.jpg', 'still.webp', 'wallpaper[12].png']) {
  const media = path.join(process.env.BACKGROUND_SIZE_TEST_DIR, name)
  const sizeProbe = { running: false }
  probe(sizeProbe, [media])
  const output = child.execFileSync(sizeProbe.command[0], sizeProbe.command.slice(1), { encoding: 'utf8' })
  const state = { nativeSizes: {}, sizeQueue: [media], probeNextSize() {} }
  finished(state, sizeProbe, { text: output }, 0, sizeProbe.path)
  assertDeepEqual(state.nativeSizes[media], { width: 20, height: 10 }, `${name}: probe reads one frame's dimensions`)
  const size = decode(state, true, 1920, 1080, { size: (width, height) => ({ width, height }) }, media)
  assertDeepEqual(size, { width: 20, height: 10 }, `${name}: decode stays at native dimensions`)
  assertEqual(state.sizeQueue.length, 0, `${name}: probe advances the queue`)
}
JS

require_compositor "pending background theme cancellation"
require_command quickshell
require_command python3

stage=$(mktemp -d)
trap 'rm -rf "$sizes" "$stage"' EXIT
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
trap 'rm -rf "$sizes" "$stage" "$reveal"' EXIT
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
