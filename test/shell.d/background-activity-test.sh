#!/bin/bash
source "$(dirname "$0")/base-test.sh"

PYTHONDONTWRITEBYTECODE=1 python3 "$SHELL_TEST_DIR/background-activity.py" || exit 1

run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')
const context = vm.createContext({})
vm.runInContext(fs.readFileSync(path.join(root, 'shell/plugins/background/ReactiveScene.js'), 'utf8').replace('.pragma library', ''), context)
const scene = JSON.parse(fs.readFileSync(path.join(root, 'themes/catppuccin-latte/backgrounds/05-circuit-city.png.reactive.json'), 'utf8'))
assert(context.parse(JSON.stringify(scene)), 'the shipped circuit scene is valid')
for (const bad of ['', 'null', '{}', '{broken', 'x'.repeat(65537)]) {
  assert(context.parse(bad) === null, 'missing or malformed scenes stay static')
}
for (const change of [s => s.width = 0, s => s.height = 99999, s => s.lights[0].color = 'url(file:///tmp/x)', s => s.lights[0].width = 999, s => s.lights[0].channel = 'exec', s => s.lights[0].path = '<svg/>', s => s.lights = Array(33).fill(s.lights[0])]) {
  const s = JSON.parse(JSON.stringify(scene)); change(s)
  assert(context.parse(JSON.stringify(s)) === null, 'invalid light definitions fail closed')
}
for (const input of [null, '1', NaN, Infinity, -1]) assert(context.level(input) === 0, 'invalid activity is idle')
assert(context.level(20) === 1 && context.level(0.4) === 0.4, 'activity is bounded')
JS
