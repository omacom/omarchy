#!/bin/bash

# The select and input menus trade their data with omarchy-menu-select and
# omarchy-menu-input through the caller's private temp files. None of it may
# travel on a command line: every user on the machine can read
# /proc/<pid>/cmdline, and Linux refuses a single argument of 128 KiB or more.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

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

// A caller that created its selection file and gave up has removed it again.
// Written anyway, the answer would hold the pick in a new file that every user
// can read.
assert(
  /^\s*if \(activeSelectionFileCreated && !root\.requestFileExists\(activeSelectionFile\)\) return$/m.test(finish[0])
    && finish[0].indexOf('requestFileExists') < finish[0].indexOf('writeRequestFile'),
  'menu writes no answer once the caller has removed the selection file it created'
)

const open = menuQml.match(/  function openDmenu\(payload\) \{[\s\S]*?\n  \}/)
assert(open, 'menu openDmenu function exists')
assert(/root\.readOptionsFile\(String\(payload\.optionsFile\)\)/.test(open[0]), 'menu reads select rows from the file the payload names')
assert(
  /if \(options === null\) \{\s*root\.writeRequestFile\(String\(payload\.doneFile \|\| ""\), "\\n"\)\s*return\s*\}/.test(open[0])
    && open[0].indexOf('writeRequestFile') < open[0].indexOf('requestSerial += 1'),
  'menu cancels a request whose rows cannot be read, before touching the menu on screen'
)
assert(
  /var callerCreatedSelection = payload\.selectionFileCreated === true && !!payload\.selectionFile\s*\n\s*if \(callerCreatedSelection && !root\.requestFileExists\(String\(payload\.selectionFile\)\)\) return\n/.test(open[0])
    && open[0].indexOf('callerCreatedSelection') < open[0].indexOf('readOptionsFile'),
  'menu opens nothing for a caller that created its selection file and has removed it already'
)
assert(
  /selectionFile = String\(payload\.selectionFile \|\| ""\)\n\s*selectionFileCreated = callerCreatedSelection\n/.test(open[0]),
  'menu remembers whether the caller created its selection file'
)

// The rows' height follows the model's count and measures every row, so a
// long list appended row by row took seconds to open, past omarchy-shell's
// IPC timeout.
const rebuild = menuQml.match(/  function rebuildDmenuDisplay\(\) \{[\s\S]*?\n  \}/)
assert(rebuild, 'menu rebuildDmenuDisplay function exists')
assert(
  (rebuild[0].match(/displayModel\.append\(/g) || []).length === 1 && /displayModel\.append\(rows\)/.test(rebuild[0]),
  'menu appends a select list to its model in one call'
)
JS

# omarchy-menu-select against a stand-in shell that answers the way the real
# one does: it reads the options file, writes the pick and creates the done
# file. The stand-in and perl log every argument they get, so an option that
# reaches either command line is caught.
stub_bin="$tmp/bin"
mkdir -p "$stub_bin"
cat >"$stub_bin/perl" <<STUB
#!/bin/bash
printf '%s\n' "\$@" >>"\$MENU_TEST_DIR/argv"
exec $(command -v perl) "\$@"
STUB
cat >"$stub_bin/omarchy-shell" <<'STUB'
#!/bin/bash
printf '%s\n' "$@" >>"$MENU_TEST_DIR/argv"
payload=$4
printf '%s' "$payload" >"$MENU_TEST_DIR/payload.json"
options_file=$(jq -r '.optionsFile // empty' <<<"$payload")
if [[ -n $options_file ]]; then
  cp "$options_file" "$MENU_TEST_DIR/options.json"
  stat -c %a "$options_file" >"$MENU_TEST_DIR/options.mode"
fi
if [[ -n ${MENU_TEST_PICK:-} ]]; then
  printf '%s\n' "$MENU_TEST_PICK" >"$(jq -r .selectionFile <<<"$payload")"
fi
: >"$(jq -r .doneFile <<<"$payload")"
STUB
chmod +x "$stub_bin/perl" "$stub_bin/omarchy-shell"

menu_select() {
  local case_dir=$1
  shift
  MENU_TEST_DIR="$case_dir" PATH="$stub_bin:$PATH" "$ROOT/bin/omarchy-menu-select" "$@"
}

large="$tmp/large"
mkdir -p "$large"
seq -f 'menu-transport-row-%06g-padding-padding' 4000 >"$large/rows"
pick=$(MENU_TEST_PICK=menu-transport-row-004000-padding-padding menu_select "$large" "Pick a row" <"$large/rows") \
  || fail "a list over 128 KiB opens the menu"
[[ $pick == "menu-transport-row-004000-padding-padding" ]] || fail "a pick from a large list comes back" "Got: $pick"
jq -e '.prompt == "Pick a row" and has("optionsFile") and (has("options") | not)' "$large/payload.json" >/dev/null \
  || fail "the payload names the options file instead of carrying the options" "$(<"$large/payload.json")"
cmp -s <(jq -r '.[]' "$large/options.json") "$large/rows" || fail "the options file holds every row in order"
(( $(stat -c %s "$large/options.json") > 131072 )) || fail "the large list is past Linux's single-argument limit"
[[ $(<"$large/options.mode") == "600" ]] || fail "the options file is private while the menu is open" "Mode: $(<"$large/options.mode")"
jq -e '.selectionFileCreated == true' "$large/payload.json" >/dev/null || fail "omarchy-menu-select says it created its selection file" "$(<"$large/payload.json")"
[[ -s $large/argv ]] || fail "perl and the shell stand-in log their arguments"
if grep -qF menu-transport-row "$large/argv"; then
  fail "no option reaches a command line" "$(grep -F menu-transport-row "$large/argv" | head -3)"
fi
[[ ! -e $(jq -r .optionsFile "$large/payload.json") ]] || fail "the options file is removed after the pick"
pass "a 4,000-row list on stdin reaches the menu in a private file and stays off every command line"

arguments="$tmp/arguments"
mkdir -p "$arguments"
glyph=$(printf '\xef\x82\xac')
options=("$glyph"$'\tFirefox\tWeb browser' 'Ünïcode café' $'two\nlines')
MENU_TEST_PICK='Ünïcode café' menu_select "$arguments" Browser "${options[@]}" -- --width 400 >"$arguments/out" \
  || fail "options given as arguments open the menu"
[[ $(<"$arguments/out") == 'Ünïcode café' ]] || fail "a pick from argument options comes back" "Got: $(<"$arguments/out")"
[[ $(jq -c . "$arguments/options.json") == "$(jq -cn '$ARGS.positional' --args "${options[@]}")" ]] \
  || fail "options keep their glyphs, tabs, newlines and Unicode" "$(<"$arguments/options.json")"
jq -e '.width == 400 and .prompt == "Browser"' "$arguments/payload.json" >/dev/null || fail "menu arguments still reach the payload"
if grep -qF 'café' "$arguments/argv"; then
  fail "options given as arguments go no further than omarchy-menu-select's own command line"
fi
pass "options given as arguments keep their glyphs, tabs, newlines and Unicode and go no further"

cancelled="$tmp/cancelled"
mkdir -p "$cancelled"
status=0
menu_select "$cancelled" Pick one two >"$cancelled/out" || status=$?
(( status == 1 )) && [[ ! -s $cancelled/out ]] || fail "a cancelled menu exits 1 with no output" "Status: $status"
[[ ! -e $(jq -r .optionsFile "$cancelled/payload.json") ]] || fail "a cancelled menu removes its options file"
pass "a cancelled menu exits 1 and removes its options file"

input="$tmp/input"
mkdir -p "$input"
typed=$(MENU_TEST_DIR="$input" MENU_TEST_PICK='typed café' PATH="$stub_bin:$PATH" "$ROOT/bin/omarchy-menu-input" Name) \
  || fail "an input prompt returns what was typed"
[[ $typed == 'typed café' ]] || fail "an input prompt returns what was typed" "Got: $typed"
jq -e '.mode == "input" and .selectionFileCreated == true' "$input/payload.json" >/dev/null \
  || fail "omarchy-menu-input says it created its selection file" "$(<"$input/payload.json")"
pass "omarchy-menu-input says it created its selection file and returns what was typed"

# Run the shipped read and write paths against real files with Quickshell's
# FileView, offscreen and on a private runtime directory.
if ! command -v quickshell >/dev/null 2>&1; then
  skip "quickshell unavailable; skipping the real FileView reads and writes"
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
  extract(/  Component \{\n    id: requestFileReader[\s\S]*?\n  \}/, 'requestFileReader'),
  extract(/  function finishRequest\([\s\S]*?\n  \}/, 'finishRequest'),
  extract(/  function writeRequestFile\([\s\S]*?\n  \}/, 'writeRequestFile'),
  extract(/  function requestFileExists\([\s\S]*?\n  \}/, 'requestFileExists'),
  extract(/  function readOptionsFile\([\s\S]*?\n  \}/, 'readOptionsFile'),
].join('\n')
const files = path.join(process.env.FIXTURE, 'files')
const rows = Array.from({ length: 10000 }, (_, i) => `\uf0ac\tRow ${i} ünïcode\tsubtext ${i}`)
fs.writeFileSync(path.join(files, 'rows.json'), JSON.stringify(rows))
fs.writeFileSync(path.join(files, 'broken.json'), '["unterminated')
fs.writeFileSync(path.join(files, 'object.json'), '{"options":["a"]}')
fs.writeFileSync(path.join(files, 'empty.json'), '')
fs.writeFileSync(path.join(process.env.FIXTURE, 'qml', 'shell.qml'), `
import QtQuick
import Quickshell
import Quickshell.Io
ShellRoot {
  id: root
  property bool requestActive: false
  property string selectionFile: ""
  property bool selectionFileCreated: false
  property string doneFile: ""
  property bool opened: true
  property string dir: ${JSON.stringify(files)}
  property string expectedRows: ${JSON.stringify(JSON.stringify(rows))}
${parts}
  Component { id: reader; FileView { blockLoading: true; printErrors: false } }
  function read(name) {
    var file = reader.createObject(root, { path: dir + "/" + name })
    file.waitForJob()
    var text = file.loaded ? file.text() : null
    file.destroy()
    return text
  }
  // Opens a request the way openDmenu does, from a caller that created its
  // selection file unless told otherwise.
  function request(selectionName, created) {
    requestActive = true
    selectionFile = dir + "/" + selectionName
    selectionFileCreated = created !== false
    doneFile = dir + "/" + selectionName + ".done"
  }
  function check(condition, message) {
    if (!condition) throw new Error(message)
  }
  Component.onCompleted: {
    for (var i = 0; i < 20; i++)
      check(JSON.stringify(readOptionsFile(dir + "/rows.json")) === expectedRows, "10,000 rows read back whole")
    writeRequestFile(dir + "/rows.json", JSON.stringify(["replaced"]) + "\\n")
    check(JSON.stringify(readOptionsFile(dir + "/rows.json")) === '["replaced"]', "a rewritten file reads fresh")
    check(readOptionsFile(dir + "/missing.json") === null, "a missing file reads as unreadable")
    check(readOptionsFile(dir + "/broken.json") === null, "malformed JSON reads as unreadable")
    check(readOptionsFile(dir + "/object.json") === null, "JSON that is not a list reads as unreadable")
    check(readOptionsFile(dir + "/empty.json") === null, "an empty file reads as unreadable")

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

    check(requestFileExists(dir + "/cancelled") && !requestFileExists(dir + "/gone"), "an empty selection file counts as there, and a missing one as gone")

    // These callers created their selection files, then gave up and removed them.
    request("gone")
    finishRequest(pick)
    check(read("gone") === null && read("gone.done") === null, "a pick for a caller that gave up writes neither file")
    check(!requestActive && selectionFile === "" && !selectionFileCreated && doneFile === "", "a request whose caller gave up lets go of its files")
    request("gone-cancelled")
    finishRequest(null)
    check(read("gone-cancelled.done") === null, "a cancel for a caller that gave up creates no done file")

    // This caller leaves creating its selection file to the shell.
    request("uncreated", false)
    finishRequest(pick)
    check(read("uncreated") === pick + "\\n" && read("uncreated.done") !== null, "a caller that never created its selection file still gets its pick")

    requestActive = true
    selectionFile = ""
    doneFile = dir + "/bare.done"
    finishRequest(null)
    check(read("bare.done") !== null, "a request without a selection file still gets its done file")

    finishRequest("late")
    check(!opened, "a finish without a request only closes the menu")
    console.log("MENU_TRANSPORT_FILEVIEW_PASS")
    Qt.callLater(function() { Qt.quit() })
  }
}
`)
JS
if ! QT_QPA_PLATFORM=offscreen QT_QUICK_BACKEND=software QT_QPA_PLATFORMTHEME= QT_STYLE_OVERRIDE= \
  XDG_RUNTIME_DIR="$tmp/run" timeout 15 quickshell -p "$tmp/qml" --no-color >"$tmp/qml.log" 2>&1; then
  cat "$tmp/qml.log" >&2
  fail "menu transport FileView fixture exits cleanly"
fi
grep -q 'MENU_TRANSPORT_FILEVIEW_PASS' "$tmp/qml.log" || { cat "$tmp/qml.log" >&2; fail "real FileView reads menu rows and writes menu results"; }
[[ $(stat -c %a "$tmp/files/pick") == "600" ]] || fail "a pick keeps the selection file private" "Mode: $(stat -c %a "$tmp/files/pick")"
for name in gone gone.done gone-cancelled gone-cancelled.done; do
  [[ ! -e $tmp/files/$name ]] || fail "nothing is written for a caller that gave up" "Found: $name"
done
pass "real FileView reads rows fresh, refuses unreadable ones, writes picks and cancels into the caller's private files, writes nothing for a caller that gave up, and still answers one that never created its selection file"
