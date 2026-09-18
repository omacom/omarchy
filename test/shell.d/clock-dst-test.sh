#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const calendar = requireFromRoot('shell/plugins/panels/clock/Model.js')

const september = calendar.monthGrid(2026, 8, 1, '')
  .flatMap(week => week.days)
assertDeepEqual(
  september.slice(0, 8).map(day => day.key),
  ['2026-08-31', '2026-09-01', '2026-09-02', '2026-09-03', '2026-09-04', '2026-09-05', '2026-09-06', '2026-09-07'],
  'calendar keeps civil dates consecutive around the DST transition'
)
assertEqual(september[6].weekday, 0, 'calendar keeps the DST transition day on Sunday')
assertDeepEqual(calendar.stepMonth(2026, 8, 1), { year: 2026, month: 9 }, 'calendar steps across September')
JS

require_compositor "clock calendar DST runtime test"
require_command quickshell

stage=$(mktemp -d)
trap 'rm -rf -- "$stage"' EXIT
cp "$SHELL_TEST_DIR/fixtures/clock-dst/shell.qml" "$stage/shell.qml"
cp "$ROOT/shell/plugins/panels/clock/Model.js" "$stage/Model.js"

output=$(TZ=America/Santiago HOME="$stage" OMARCHY_PATH="$ROOT" \
  timeout 15 quickshell -p "$stage" --no-color 2>&1) || fail "clock calendar DST fixture exits cleanly" "$output"
[[ $output == *"RESULT pass"* ]] || fail "clock calendar DST runtime assertions pass" "$output"
if rg -q 'RESULT fail|ReferenceError|TypeError|Error:|Unable to assign|Binding loop' <<< "$output"; then
  fail "clock calendar DST fixture has no QML errors" "$output"
fi

pass "clock calendar stays aligned across a midnight DST transition"
