#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const reminders = requireFromRoot('shell/plugins/reminders/ReminderFlowModel.js')

assertEqual(reminders.validMinutes('15'), '15', 'reminders accepts positive integer minutes')
assertEqual(reminders.validMinutes('  5  '), '5', 'reminders trims minute input')
assertEqual(reminders.validMinutes('0'), '', 'reminders rejects zero minutes')
assertEqual(reminders.validMinutes('-5'), '', 'reminders rejects negative minutes')
assertEqual(reminders.validMinutes('1.5'), '', 'reminders rejects fractional minutes')
assertEqual(reminders.validMinutes('soon'), '', 'reminders rejects non-numeric minutes')

assertDeepEqual(
  reminders.reminderArgs('10', 'Check the oven'),
  ['10', 'Check the oven'],
  'reminders builds command args with message'
)

assertDeepEqual(
  reminders.reminderArgs('10', ''),
  ['10'],
  'reminders omits empty message arg'
)

assertDeepEqual(
  reminders.reminderArgs('0', 'ignored'),
  [],
  'reminders command args are empty for invalid minutes'
)
JS

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
mkdir -p "$test_dir/bin" "$test_dir/runtime"

cat >"$test_dir/bin/date" <<'EOF'
#!/bin/bash
case "$*" in
"+%s") echo 1788804000 ;;
"-d +7 minutes +%H:%M") echo 11:07 ;;
"-u -d +7 minutes +%Y-%m-%d %H:%M:%S UTC") echo "2026-09-07 18:07:00 UTC" ;;
*) exit 1 ;;
esac
EOF

cat >"$test_dir/bin/systemd-run" <<'EOF'
#!/bin/bash
printf '%s\n' "$@" >"$TEST_LOG"
EOF

for command in omarchy-notification-send omarchy-shell; do
  cat >"$test_dir/bin/$command" <<'EOF'
#!/bin/bash
exit 0
EOF
  chmod +x "$test_dir/bin/$command"
done
chmod +x "$test_dir/bin/date" "$test_dir/bin/systemd-run"

TEST_LOG="$test_dir/systemd-run.log" \
  XDG_RUNTIME_DIR="$test_dir/runtime" \
  PATH="$test_dir/bin:$PATH" \
  bash "$ROOT/bin/omarchy-reminder" 7 "Tea ready"

grep -Fxq -- '--on-calendar=2026-09-07 18:07:00 UTC' "$test_dir/systemd-run.log" ||
  fail "reminder deadline uses wall-clock time" "systemd-run did not receive the absolute reminder deadline"
pass "reminder deadline uses wall-clock time"

if grep -q '^--on-active=' "$test_dir/systemd-run.log"; then
  fail "reminder avoids an active-time delay" "$(<"$test_dir/systemd-run.log")"
fi
pass "reminder avoids an active-time delay"

grep -Fxq -- '--unit=omarchy-reminder-7m-1788804000' "$test_dir/systemd-run.log" ||
  fail "reminder keeps its unit naming" "$(<"$test_dir/systemd-run.log")"
pass "reminder keeps its unit naming"

[[ $(<"$test_dir/runtime/omarchy-reminders/omarchy-reminder-7m-1788804000.message") == "Tea ready" ]] ||
  fail "reminder keeps its custom message file"
pass "reminder keeps its custom message file"
