#!/bin/bash

# The select and input menus trade their data with omarchy-menu-select and
# omarchy-menu-input through the caller's private temp files. None of it may
# travel on a command line: every user on the machine can read
# /proc/<pid>/cmdline.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

run_node_test <<'JS'
const fs = require('fs')
const menuQml = fs.readFileSync(path.join(root, 'shell/plugins/menu/Menu.qml'), 'utf8')

const finish = menuQml.match(/  function finishRequest\(selection\) \{[\s\S]*?\n  \}/)
assert(finish, 'menu finishRequest function exists')
assert(!/bash|printf|\.command|\.running/.test(finish[0]), 'menu writes a pick without starting a command')
assert(!/resultProc/.test(menuQml), 'menu keeps no process for writing results')
assert(
  /id: requestFileWriter\s*FileView \{[^}]*atomicWrites: false[^}]*blockWrites: true/.test(menuQml),
  'menu writes results in place, finishing the selection before the done file'
)
JS

# Run the shipped write path against real files with Quickshell's FileView,
# offscreen and on a private runtime directory.
if ! command -v quickshell >/dev/null 2>&1; then
  skip "quickshell unavailable; skipping the real FileView result writes"
  exit 0
fi
mkdir -p "$tmp/qml" "$tmp/run" "$tmp/files"
chmod 700 "$tmp/run"
(
  umask 077
  for name in pick pick-again cancelled; do
    : >"$tmp/files/$name"
  done
)
ROOT="$ROOT" FIXTURE="$tmp" node <<'JS'
const fs = require('fs')
const path = require('path')
const source = fs.readFileSync(path.join(process.env.ROOT, 'shell/plugins/menu/Menu.qml'), 'utf8')
const extract = (pattern, name) => {
  const match = source.match(pattern)
  if (!match) {
    console.error(`Menu.qml has no ${name}`)
    process.exit(1)
  }
  return match[0]
}
const parts = [
  extract(/  Component \{\n    id: requestFileWriter[\s\S]*?\n  \}/, 'requestFileWriter'),
  extract(/  function finishRequest\([\s\S]*?\n  \}/, 'finishRequest'),
  extract(/  function writeRequestFile\([\s\S]*?\n  \}/, 'writeRequestFile'),
].join('\n')
const files = path.join(process.env.FIXTURE, 'files')
fs.writeFileSync(path.join(process.env.FIXTURE, 'qml', 'shell.qml'), `
import QtQuick
import Quickshell
import Quickshell.Io
ShellRoot {
  id: root
  property bool requestActive: false
  property string selectionFile: ""
  property string doneFile: ""
  property bool opened: true
  property string dir: ${JSON.stringify(files)}
${parts}
  Component { id: reader; FileView { blockLoading: true; printErrors: false } }
  function read(name) {
    var file = reader.createObject(root, { path: dir + "/" + name })
    file.waitForJob()
    var text = file.loaded ? file.text() : null
    file.destroy()
    return text
  }
  function request(selectionName) {
    requestActive = true
    selectionFile = dir + "/" + selectionName
    doneFile = dir + "/" + selectionName + ".done"
  }
  function check(condition, message) {
    if (!condition) throw new Error(message)
  }
  Component.onCompleted: {
    var pick = "Firefox\\tünïcode subtext"
    request("pick")
    finishRequest(pick)
    check(read("pick") === pick + "\\n", "a pick reaches the selection file")
    check(read("pick.done") !== null, "a pick creates the done file")
    check(!requestActive && selectionFile === "" && doneFile === "", "a finished request lets go of its files")

    request("pick-again")
    finishRequest(pick)
    check(read("pick-again") === pick + "\\n", "the same pick reaches the next request's file")

    request("cancelled")
    finishRequest(null)
    check(read("cancelled") === "", "a cancel leaves the selection empty")
    check(read("cancelled.done") !== null, "a cancel creates the done file")

    finishRequest("late")
    check(!opened, "a finish without a request only closes the menu")
    console.log("MENU_RESULT_FILEVIEW_PASS")
    Qt.callLater(function() { Qt.quit() })
  }
}
`)
JS
if ! QT_QPA_PLATFORM=offscreen QT_QUICK_BACKEND=software QT_QPA_PLATFORMTHEME= QT_STYLE_OVERRIDE= \
  XDG_RUNTIME_DIR="$tmp/run" timeout 15 quickshell -p "$tmp/qml" --no-color >"$tmp/qml.log" 2>&1; then
  cat "$tmp/qml.log" >&2
  fail "menu result FileView fixture exits cleanly"
fi
grep -q 'MENU_RESULT_FILEVIEW_PASS' "$tmp/qml.log" || { cat "$tmp/qml.log" >&2; fail "real FileView writes menu results"; }
[[ $(stat -c %a "$tmp/files/pick") == "600" ]] || fail "a pick keeps the selection file private" "Mode: $(stat -c %a "$tmp/files/pick")"
pass "real FileView writes picks and cancels into the caller's files and keeps them private"
