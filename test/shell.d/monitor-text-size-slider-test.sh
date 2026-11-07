#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const src = fs.readFileSync(path.join(root, 'shell/plugins/panels/monitor/Panel.qml'), 'utf8')

assert(/id: textScaleProc\n    onRunningChanged: if \(!running\) root\.runQueuedTextSize\(\)/.test(src), 'text size command exit runs the queued change')
assert(/onExited: function\(exitCode\) \{ root\.textSizeCommandExited\(exitCode\) \}/.test(src), 'text size command exit reports its exit code')
assert(/onReleased: function\(v\) \{ root\.selectTextSize\(Math\.round\(v\)\) \}/.test(src), 'text size slider release goes through selectTextSize')

function fn(name) {
  const m = src.match(new RegExp('^  function ' + name + '\\(.*?^  \\}', 'ms'))
  if (!m) throw new Error('missing ' + name)
  return m[0].replace(/^  function /, 'function ')
}

// Run the panel's own text-size functions against a fake root.
function make(basePx, pending = -1) {
  const root = {
    textSizeStops: [9, 10, 11, 12, 14, 16, 20],
    textSizePreviewIndex: pending,
    Style: { font: { baseSize: basePx } },
    queuedTextSize: 0,
    started: [],
    textScaleProc: null,
    markReflowing() {}
  }
  // Like Process: setting running starts a run with the current command only
  // when it was not running; finish() is the exit, which fires onRunningChanged.
  const proc = {
    command: null,
    _running: false,
    get running() { return this._running },
    set running(v) {
      if (v && !this._running) root.started.push(this.command[1])
      this._running = v
    },
    finish(code = 0) { this._running = false; root.runQueuedTextSize(); root.textSizeCommandExited(code) }
  }
  root.textScaleProc = proc
  const names = ['nearestTextStop', 'currentTextIndex', 'displayedTextPx', 'setTextSize', 'runQueuedTextSize', 'textSizeCommandExited', 'adjustTextSize', 'selectTextSize']
  const body = names.map(fn).join('\n')
  const fns = new Function('root', 'with (root) {' + body + '\nreturn { selectTextSize, runQueuedTextSize, textSizeCommandExited } }')(root)
  root.select = fns.selectTextSize
  root.runQueuedTextSize = fns.runQueuedTextSize
  root.textSizeCommandExited = fns.textSizeCommandExited
  return root
}

function select(basePx, idx, pending = -1) {
  const root = make(basePx, pending)
  root.select(idx)
  return root
}

let r = select(12, 5)
assertDeepEqual(r.textScaleProc.command, ['omarchy-display-text-size', '16'], '12px to 16px runs the command')
assertEqual(r.textSizePreviewIndex, 5, '12px to 16px holds the pending stop')

r = select(13, 3)
assertDeepEqual(r.textScaleProc.command, ['omarchy-display-text-size', '12'], '13px to the 12px stop still runs the command')
assertEqual(r.textSizePreviewIndex, 3, '13px to 12px holds the pending stop')

r = select(12, 3)
assertEqual(r.textScaleProc.command, null, 'selecting the size already in effect does nothing')
assertEqual(r.textSizePreviewIndex, -1, 'selecting the size already in effect leaves no pending stop')

// Fast 12 -> 16 -> 20 while the first command is still running.
r = make(12)
r.select(5)
assertDeepEqual(r.started, ['16'], '16px starts immediately')
r.select(6)
assertDeepEqual(r.started, ['16'], '20px waits while the 16px command runs')
assertEqual(r.textSizePreviewIndex, 6, '20px is pending while queued')
r.textScaleProc.finish()
assertDeepEqual(r.started, ['16', '20'], '20px runs when the 16px command exits')
r.textScaleProc.finish()
assertEqual(r.queuedTextSize, 0, 'the queue is empty after the last command')
assertEqual(r.textSizePreviewIndex, 6, 'the final pending stop is the 20px one, cleared by the base-size handler once it lands')

// 16 -> 20 -> 16 while running: the first command already wrote 16px, so the
// queued 16px run changes nothing and the pending stop must still clear.
r = make(12)
r.select(5)
r.Style.font.baseSize = 16
r.select(6)
r.select(5)
assertDeepEqual(r.started, ['16'], 'only the first command runs while it is active')
r.textScaleProc.finish()
assertDeepEqual(r.started, ['16', '16'], 'the last selection runs after the first exits')
r.textScaleProc.finish()
assertEqual(r.textSizePreviewIndex, -1, 'the pending stop clears when the live size already matches')

// The command fails and the size stays 12: the pending stop must clear and the
// same value must be selectable again.
r = make(12)
r.select(5)
r.textScaleProc.finish(1)
assertEqual(r.textSizePreviewIndex, -1, 'a failed command clears the pending stop')
r.select(5)
assertDeepEqual(r.started, ['16', '16'], 'retrying the same size runs the command again')
r.textScaleProc.finish(0)
assertEqual(r.textSizePreviewIndex, 5, 'a successful exit leaves the pending stop for the base-size handler')
JS
