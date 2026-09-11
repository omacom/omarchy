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

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

printf '%s\n' \
  '#!/bin/bash' \
  'printf "%s\n" "$@" >"$OMARCHY_TEST_SYSTEMD_RUN_ARGS"' \
  >"$tmpdir/systemd-run"
chmod +x "$tmpdir/systemd-run"

printf '%s\n' '#!/bin/bash' 'exit 0' >"$tmpdir/omarchy-notification-send"
chmod +x "$tmpdir/omarchy-notification-send"

printf '%s\n' '#!/bin/bash' 'exit 0' >"$tmpdir/omarchy-shell"
chmod +x "$tmpdir/omarchy-shell"

args_file="$tmpdir/systemd-run-args"
OMARCHY_TEST_SYSTEMD_RUN_ARGS="$args_file" \
  PATH="$tmpdir:$ROOT/bin:$PATH" \
  XDG_RUNTIME_DIR="$tmpdir/runtime" \
  omarchy-reminder 5 "Check the oven"

mapfile -t run_args <"$args_file"
timer_payload=""
for ((i = 0; i < ${#run_args[@]}; i++)); do
  if [[ ${run_args[i]} == "-c" ]]; then
    timer_payload=${run_args[i + 1]}
    break
  fi
done

[[ $timer_payload == *'omarchy-notification-send -g 󰢌 "Reminder" "$1" -u critical'* ]] || fail "reminders use a persistent critical notification" "$timer_payload"
pass "reminders use a persistent critical notification"
