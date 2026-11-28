#!/bin/bash

# The bar marks a workspace whose layout is its own. Runs the reader the bar
# uses over a workspace-layouts directory, then the widget's parser and label
# rules over what it printed, so a change to either shows up here.

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

require_command bash

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

widget="$ROOT/shell/plugins/bar/widgets/WorkspaceLayouts.qml"
layouts="$tmpdir/workspace-layouts"
mkdir -p "$layouts"

# The reader's script, lifted out of the widget so this tests what ships: the
# lines of the script property, with their QML quoting undone.
sed -n '/^  readonly property string script: \[/,/^  \]\.join/p' "$widget" |
  sed -e '1d' -e '$d' -e 's/^    "\(.*\)",\{0,1\}$/\1/' |
  sed -e 's/\\\\/\\/g' -e 's/\\"/"/g' >"$tmpdir/read.sh"

[[ -s $tmpdir/read.sh ]] || fail "the reader script is found in the widget"

# A directory with nothing in it follows dwindle, with no workspace of its own.
output=$(bash "$tmpdir/read.sh" "$layouts")
[[ $(sed -n '2p' <<<"$output") == "dwindle" ]] ||
  fail "a directory with no files follows dwindle" "$output"
[[ ! $(sed -n '4,$p' <<<"$output") ]] ||
  fail "a workspace with no file of its own has no mark" "$output"
pass "an empty layout directory follows dwindle"

# A workspace with a layout of its own, and a default that is not dwindle.
printf 'o.workspace_mode({ workspace = "3", mode = "scrolling" })\n' >"$layouts/3.lua"
printf 'o.workspace_mode({ default = "floating" })\n' >"$layouts/default.lua"
output=$(bash "$tmpdir/read.sh" "$layouts")
[[ $(sed -n '2p' <<<"$output") == "floating" ]] ||
  fail "the default layout is read from default.lua" "$output"
grep -qx "3 scrolling" <<<"$output" ||
  fail "a saved workspace layout is read back" "$output"
pass "the default and a workspace of its own are read"

# A workspace saved on dwindle is one of its own all the same.
printf 'o.workspace_mode({ workspace = "10", mode = "dwindle" })\n' >"$layouts/10.lua"
output=$(bash "$tmpdir/read.sh" "$layouts")
grep -qx "10 dwindle" <<<"$output" ||
  fail "a workspace on dwindle is still one of its own" "$output"
pass "a workspace saved on dwindle keeps its mark"

# A file caught half written names no mode and is left out rather than read as
# something else.
printf 'o.workspace_mode({ workspace = "5", mode = \n' >"$layouts/5.lua"
output=$(bash "$tmpdir/read.sh" "$layouts")
if grep -q '^5 ' <<<"$output"; then
  fail "a half-written file names no layout" "$output"
fi
pass "a half-written file names no layout"

# The parser and labels, as the widget reads them: the default follows the
# heading, a workspace with its own layout carries its mark, and one that only
# follows the default stays bare. The functions are lifted out of the widget,
# so this runs the code that ships rather than a copy of it.
if ! command -v qs >/dev/null 2>&1; then
  skip "labels need qs, which is not installed here"
  exit 0
fi

functions=$(sed -n '/^  function read(text) {/,/^  function label(id, slot) {/p' "$widget" | sed -e '$d' -e 's/root\./labels./g')
functions+=$(sed -n '/^  function label(id, slot) {/,/^  }$/p' "$widget" | sed -e 's/root\./labels./g' -e 's/^  function label/\n  function label/')

runner="$tmpdir/runner.qml"
{
  printf 'import QtQuick\nimport Quickshell\nimport QtQml\n\nShellRoot {\n'
  printf '  QtObject {\n    id: labels\n'
  printf '    property var overrides: ({})\n'
  printf '    property string defaultLayout: "dwindle"\n'
  printf '    readonly property var layouts: ["dwindle", "scrolling", "floating"]\n'
  printf '    signal checked(string labels)\n\n'
  printf '%s\n\n' "$functions"
  printf '  }\n\n'
  printf '  Connections {\n    target: labels\n'
  printf '    function onChecked(labels) {\n'
  printf '      console.log("LABELS " + labels)\n'
  printf '      Qt.quit()\n'
  printf '    }\n  }\n\n'
  printf '  Component.onCompleted: {\n'
  printf '    labels.read("default\\nfloating\\noverrides\\n3 scrolling\\n10 dwindle\\n5 sideways\\n")\n'
  printf '    var out = [labels.label(1, 1), labels.label(3, 3), labels.label(10, 10), labels.label(5, 5), labels.label(2, 12), labels.defaultLayout]\n'
  printf '    labels.checked(out.join("|"))\n'
  printf '  }\n}\n'
} >"$runner"

result=$(timeout 20 qs -p "$runner" 2>&1 | grep -o "LABELS .*" | tail -n 1 || true)
[[ $result == "LABELS 1|3s|0d|5|12|floating" ]] ||
  fail "a bare number stays bare, an own layout is marked, the tenth keeps its zero" "labels: ${result:-none} ($runner)"
pass "labels mark only a workspace with a layout of its own"
