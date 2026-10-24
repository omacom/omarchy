#!/bin/bash

source "$(dirname "$0")/base-test.sh"

require_command node

# The panel's pace logic is plain QML/JavaScript, so it is driven directly rather
# than through a QML runtime: the harness brace-extracts the window helpers and
# CompactLimit's own pace bindings out of Panel.qml and runs them against a stub
# root. What must hold is that the cycle a label names survives limitWindow() and
# displayWindows(), that a duration in a model name does not become one, and that
# the elapsed fraction and the caption follow from the shipped bindings.
run_node_test <<'JS'
const { execFileSync } = require('child_process')
const fs = require('fs')

const harness = root + '/scripts/agents-pace-harness.js'
const panel = root + '/shell/plugins/agents/Panel.qml'

assert(fs.existsSync(harness), 'the agents pace harness ships with the repo')
assert(fs.existsSync(panel), 'the agents panel is present')

let output = ''
try {
  output = execFileSync('node', [harness, panel], { encoding: 'utf8' })
} catch (error) {
  output = (error.stdout || '') + (error.stderr || '')
  console.error(output)
  assert(false, 'the agents pace harness passes on the panel as shipped')
  process.exit(1)
}

console.log(output.trim())

// The harness pads "ok" to line up with "not ok", so match any gap.
const ok = name => new RegExp('^ok\\s+- ' + name.replace(/[.*+?^${}()|[\]\\]/g, '\\$&') + '$', 'm')

assert(ok('a 5h window with 47m left is ~84% elapsed').test(output), 'a 5h window is paced by the clock')
assert(ok('and 68 points behind the clock reads as behind').test(output), 'a window behind the clock says so')
assert(ok('a 7d window with 4d10h left is ~37% elapsed').test(output), 'a weekly window is paced too')
assert(ok('a window ahead of the clock says so').test(output), 'a window ahead of the clock says so')
assert(ok('a level window reads as on pace').test(output), 'a level window reads as on pace')
assert(ok('a window of unknown length has no elapsed position').test(output), 'a window of unknown length is left unpaced')
assert(ok('a window of unknown length says nothing').test(output), 'a window of unknown length says no caption')
assert(ok('a model-scoped window is left unpaced').test(output), 'a model-scoped window is left unpaced')
assert(ok('an already-reset window has no elapsed position').test(output), 'a window past its reset is left unpaced')
assert(ok('a window before its cycle clamps to zero elapsed').test(output), 'a window before its cycle clamps to zero')
assert(ok('a kept reading still reads the same an hour later').test(output), 'a reading kept past a failed check holds its pace')
assert(ok('and its position is unchanged').test(output), 'a kept reading holds its position on the clock')
assert(ok('while the countdown beside it does advance').test(output), 'the countdown beside a kept reading stays live')
assert(ok('a month read at its start sits at the start of its cycle').test(output), 'a month read at its start is not mistaken for a rolled window')
assert(ok('and reads as on pace rather than behind').test(output), 'a window that has not rolled is not paced against the live clock')
assert(ok('windowSpanMs reads Rolling (5h)').test(output), 'a five-hour window states its cycle')
assert(ok('windowSpanMs reads 5 hours').test(output), 'a spelled-out hour count is a cycle')
assert(ok('windowSpanMs reads Rolling (30m)').test(output), 'a collector may label a window in bare minutes')
assert(ok('windowSpanMs reads 90m window').test(output), 'a minute cycle may run past an hour')
assert(ok('windowSpanMs reads Opus 5 (1M context) Session').test(output), "a model name's context size is not a cycle length")
assert(ok('windowSpanMs reads Opus 5 (1M context) 30m window').test(output), 'a stated cycle survives a context size in the same label')
assert(ok('windowSpanMs reads GPT 5.4 (1M context)').test(output), 'a context size with no session word is not a cycle either')
assert(ok('displayWindows keeps the cycle on the base row').test(output), 'the cycle survives the row-building')
assert(ok('and attaches the scoped allowance to it').test(output), 'a model-scoped allowance still attaches to its window')
JS
