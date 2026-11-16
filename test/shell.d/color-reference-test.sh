#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')

const source = fs.readFileSync(path.join(root, 'shell/Commons/Color.qml'), 'utf8')
const geometry = fs.readFileSync(path.join(root, 'shell/Commons/BorderGeometry.js'), 'utf8').replace(/^\.pragma library\n/, '')
const palette = { foreground: '#eeeeee', background: '#111111', accent: '#abcdef', urgent: '#ff0000', muted: '#777777' }
const context = vm.createContext({ root: { ...palette, shellValues: {} }, Geometry: {} })
vm.runInNewContext(geometry, context.Geometry)
for (const name of ['firstColorToken', 'flatColor', 'parseShell']) {
  const fn = source.match(new RegExp(`  function ${name}\\([^]*?\\n  }`))
  if (!fn) fail(`Color.qml provides ${name}`)
  vm.runInContext(fn[0], context)
}

function check(values, input, expected, description) {
  context.root.shellValues = values
  context.input = input
  const result = vm.runInContext('flatColor(input, "#123456")', context, { timeout: 1000 })
  assertEqual(result, expected, description)
}

const cycle = context.parseShell('[bar]\nbackground = "menu.background"\n[menu]\nbackground = "bar.background"')
check(cycle, 'bar.background', '#123456', 'two-entry theme cycle returns the supplied fallback')
check({ 'a.color': 'b.color', 'b.color': 'c.color', 'c.color': 'a.color' }, 'a.color', '#123456', 'longer cycle returns fallback')
check({ 'start.color': 'a.color', 'a.color': 'b.color', 'b.color': 'a.color' }, 'start.color', '#123456', 'chain entering a cycle returns fallback')
check({ 'a.color': 'a.color' }, 'a.color', '#123456', 'direct self-reference returns fallback')
check({ 'a.color': ' A.COLOR ' }, 'a.color', '#123456', 'normalized self-reference returns fallback')
check({ 'a.color': '45deg b.color #ffffff', 'b.color': 'a.color' }, 'a.color', '#123456', 'gradient first-stop cycle returns fallback')

check({ 'a.color': 'b.color', 'b.color': '#abcdef' }, 'a.color', '#abcdef', 'acyclic references preserve the final color')
check({ 'a.color': ' B.COLOR ', 'b.color': '#abcdef' }, 'A.COLOR', '#abcdef', 'each reference keeps case and whitespace normalization')
check({ 'a.color': 'b.color', 'b.color': 'accent' }, 'a.color', palette.accent, 'acyclic references preserve palette roles')
check({ 'a.color': '45deg rgba(11223380) #ffffff' }, 'a.color', '#11223380', 'referenced gradient keeps its first color and alpha')
check({ 'a.color': 'missing.color' }, 'a.color', '#123456', 'missing reference returns fallback')
check({}, '', '#123456', 'empty input returns fallback')
for (const [role, color] of Object.entries(palette)) check({}, role, color, `palette role ${role} is unchanged`)
check({}, 'text', palette.foreground, 'text alias is unchanged')
for (const [input, output] of [['#abc', '#aabbcc'], ['#abcdef', '#abcdef'], ['rgb(abcdef)', '#abcdef'], ['rgba(11223380)', '#11223380']]) {
  check({}, input, output, `direct color ${input} is unchanged`)
}

const chain = {}
for (let i = 0; i < 10000; i++) chain[`chain.c${i}`] = `chain.c${i + 1}`
chain['chain.c10000'] = '#abcdef'
check(chain, 'chain.c0', '#abcdef', 'long acyclic chains do not exhaust the call stack')
check({ 'a.color': '#abcdef' }, 'a.color', '#abcdef', 'visited references do not leak between resolutions')
JS
