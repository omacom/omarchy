#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command magick

stage=$(mktemp -d)
trap 'rm -rf "$stage"' EXIT
export BACKGROUND_SIZE_TEST_DIR="$stage"

# Keep the multi-frame fixtures tiny: incorrect concatenated dimensions must
# fail before a Qt image is ever allowed to allocate from them.
magick -size 20x10 xc:red -size 20x10 xc:blue -set delay 20 -loop 0 "$stage/animated [wallpaper] ü.gif"
magick -size 20x10 xc:red "$stage/still.gif"
magick -size 20x10 xc:red "$stage/still.png"
magick -size 20x10 xc:red "$stage/still.jpg"
magick -size 20x10 xc:red "$stage/still.webp"
# Brackets in a name must stay literal: a frame suffix would make ImageMagick
# glob this to its siblings and print both their sizes.
magick -size 20x10 xc:red "$stage/wallpaper[12].png"
magick -size 40x30 xc:blue "$stage/wallpaper1.png"
magick -size 50x40 xc:green "$stage/wallpaper2.png"

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
