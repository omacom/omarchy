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
