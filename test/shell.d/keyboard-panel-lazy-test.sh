#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')

function stripLine(line) {
  return line.replace(/"(\\.|[^"\\])*"/g, '""').replace(/'(\\.|[^'\\])*'/g, "''").replace(/\/\/.*$/, '')
}

function panelFiles(dir) {
  const out = []
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, entry.name)
    if (entry.isDirectory()) out.push(...panelFiles(full))
    else if (entry.name.endsWith('.qml')) out.push(full)
  }
  return out
}

const users = panelFiles(root + '/shell/plugins').filter(file => /^\s*KeyboardPanel\s*\{/m.test(fs.readFileSync(file, 'utf8')))
assert(users.length >= 10, 'first-party keyboard panels are found', String(users.length))

for (const file of users) {
  const name = path.relative(root, file)
  const lines = fs.readFileSync(file, 'utf8').split('\n')
  const start = lines.findIndex(line => /^\s*KeyboardPanel\s*\{/.test(line))
  let depth = 0
  const children = []
  for (let i = start; i < lines.length; i++) {
    const line = stripLine(lines[i])
    if (depth === 1 && /\{/.test(line)) children.push(line.trim())
    depth += (line.match(/\{/g) || []).length - (line.match(/\}/g) || []).length
    if (depth === 0) break
  }
  assert(children.length > 0 && children.every(child => /^content:/.test(child)), `${name} builds its panel content lazily`, children.join('\n'))

  const source = lines.join('\n')
  const mirrors = [...source.matchAll(/readonly property Item (\w+): panel\.loadedContent \? panel\.loadedContent\.(\w+) : null/g)]
  for (const [, mirror, target] of mirrors) {
    assert(mirror === target && new RegExp(`property alias ${target}: ${target}\\b`).test(source), `${name} exposes ${target} from its content`)
  }
}
pass('first-party keyboard panels build their content on first open')
JS

# The panel surface spans the screen, but the bar is laid out inside the
# monitor's reserved area. Whatever was reserved before it (Hyprland's config
# error banner, a reserved_area rule) moves the bar in, along it as well as
# across it, and the card and the clicks forwarded to the bar have to follow.
run_node_test <<'JS'
const area = requireFromRoot('shell/Commons/ReservedArea.js')
const W = 2400, H = 1350, bar = 28

const insets = (reserved, position, zone = bar) => area.barInsets(reserved, position, zone)
const origin = (reserved, position, w, h, zone = bar) => area.barWindowOrigin(insets(reserved, position, zone), position, W, H, w, h)

assertDeepEqual(insets([0, 28, 0, 0], 'top'), { left: 0, top: 0, right: 0, bottom: 0 }, 'a bar reserving only its own edge sits at the screen edge')
assertDeepEqual(insets([0, 223, 0, 0], 'top'), { left: 0, top: 195, right: 0, bottom: 0 }, 'a band reserved above a top bar moves it down by the band')
assertDeepEqual(insets([0, 195, 0, 0], 'top', 0), { left: 0, top: 195, right: 0, bottom: 0 }, 'a hidden bar claims no zone of its own')
assertDeepEqual(insets(null, 'top'), { left: 0, top: 0, right: 0, bottom: 0 }, 'an unknown reserved area leaves the bar at its edge')

assertDeepEqual(origin([0, 28, 0, 0], 'top', W, H), { x: 0, y: 0 }, 'a top bar window sits at the screen corner')
assertDeepEqual(origin([0, 223, 0, 0], 'top', W, H), { x: 0, y: 195 }, 'a top bar window starts below the banner')
assertDeepEqual(origin([0, 0, 0, 28], 'bottom', W, H), { x: 0, y: 0 }, 'a full-screen bottom bar window covers the screen')
assertDeepEqual(origin([0, 195, 0, 60], 'bottom', W, H), { x: 0, y: -32 }, 'a bottom bar window moves up by what was reserved below it')
assertDeepEqual(origin([28, 195, 0, 0], 'left', W, H - 195), { x: 0, y: 195 }, 'a left bar window starts below the banner')
assertDeepEqual(origin([0, 195, 40, 0], 'right', W, H - 195), { x: -12, y: 195 }, 'a right bar window moves in along both axes')
assertDeepEqual(origin([100, 28, 0, 0], 'top', W - 100, H), { x: 100, y: 0 }, 'a top bar window moves along by a band reserved beside it')
JS

require_compositor "keyboard panel lazy content runtime test"
require_command quickshell

stage=$(mktemp -d)
trap 'rm -rf -- "$stage"' EXIT
ln -s "$ROOT/shell/Ui" "$stage/Ui"
ln -s "$ROOT/shell/Commons" "$stage/Commons"
cp "$SHELL_TEST_DIR/fixtures/keyboard-panel-lazy/shell.qml" "$stage/shell.qml"

output=$(HOME="$stage" OMARCHY_PATH="$ROOT" timeout 30 quickshell -p "$stage" --no-color 2>&1) || fail "keyboard panel fixture exits cleanly" "$output"
[[ $output == *"RESULT pass"* ]] || fail "keyboard panel lazy content assertions pass" "$output"
if rg -q 'RESULT fail|ReferenceError|TypeError|Error:|Unable to assign|Binding loop' <<< "$output"; then
  fail "keyboard panel fixture has no QML errors" "$output"
fi
pass "keyboard panel content builds on open, survives close, and is reused on reopen"
