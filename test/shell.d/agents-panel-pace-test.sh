#!/bin/bash

source "$(dirname "$0")/base-test.sh"

require_command node

# The panel's pace logic is plain QML/JavaScript, so it is driven directly
# rather than through a QML runtime: the harness brace-extracts the window
# helpers and LimitRow's own property bindings out of Panel.qml and runs them
# against a stub root. What must hold is that the window's own length survives
# limitWindow(), that a duration in a model name does not, and that the elapsed
# fraction and the caption follow from the shipped bindings.
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
assert(/^ok - a 5h window with 47m left is ~84% elapsed$/m.test(output), 'a 5h window is paced by the clock')
assert(/^ok - a window behind the clock says so$/m.test(output), 'a window behind the clock says so')
assert(/^ok - a window ahead of the clock says so$/m.test(output), 'a window ahead of the clock says so')
assert(/^ok - a level window reads as on pace$/m.test(output), 'a level window reads as on pace')
assert(/^ok - a window of unknown length has no elapsed position$/m.test(output), 'a window of unknown length is left unpaced')
assert(/^ok - a window of unknown length says nothing$/m.test(output), 'a window of unknown length says no caption')
assert(/^ok - windowSpanMs reads Opus 5 \(1M context\) Session$/m.test(output), "a model name's context size is not a cycle length")
assert(/^ok - windowSpanMs reads Rolling \(30m\)$/m.test(output), 'a collector may label a window in bare minutes')
assert(/^ok - windowSpanMs reads 90m window$/m.test(output), 'a minute cycle may run past an hour')
assert(/^ok - windowSpanMs reads Opus 5 \(1M context\) 30m window$/m.test(output), 'a stated cycle survives a context size in the same label')
assert(/^ok - windowSpanMs reads GPT 5\.4 \(1M context\)$/m.test(output), 'a context size with no session word is not a cycle either')
assert(/^ok - an already-reset window has no elapsed position$/m.test(output), 'a window past its reset is left unpaced')
assert(/^ok - a window that has not started clamps to zero elapsed$/m.test(output), 'a window before its cycle clamps to zero')
JS
