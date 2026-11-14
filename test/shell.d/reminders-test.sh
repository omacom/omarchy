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

# The fired reminder runs this stub, and it records the arguments the
# notification actually receives, so the test reads the urgency that was
# delivered rather than the text that builds the command.
printf '%s\n' \
  '#!/bin/bash' \
  'if [[ -n ${OMARCHY_TEST_NOTIFY_ARGS:-} ]]; then' \
  '  printf "%s\n" "$@" >"$OMARCHY_TEST_NOTIFY_ARGS"' \
  'fi' \
  >"$tmpdir/omarchy-notification-send"
chmod +x "$tmpdir/omarchy-notification-send"

printf '%s\n' '#!/bin/bash' 'printf "Reminder"' >"$tmpdir/omarchy-i18n"
chmod +x "$tmpdir/omarchy-i18n"

printf '%s\n' '#!/bin/bash' 'exit 0' >"$tmpdir/omarchy-shell"
chmod +x "$tmpdir/omarchy-shell"

args_file="$tmpdir/systemd-run-args"
notify_file="$tmpdir/notify-args"

run_reminder() {
  rm -f "$args_file" "$notify_file"
  OMARCHY_TEST_SYSTEMD_RUN_ARGS="$args_file" \
    PATH="$tmpdir:$ROOT/bin:$PATH" \
    XDG_RUNTIME_DIR="$tmpdir/runtime" \
    omarchy-reminder "$@"
}

# systemd-run execs its command line verbatim, so replaying the captured argv is
# what the timer runs when the reminder fires. The stubs on PATH stand in for the
# notification and i18n helpers the payload calls.
fire_reminder() {
  mapfile -t run_args <"$args_file"
  local i command=()
  for ((i = 0; i < ${#run_args[@]}; i++)); do
    if [[ ${run_args[i]} == "bash" && ${run_args[i + 1]:-} == "-c" ]]; then
      command=("${run_args[@]:i}")
      break
    fi
  done
  ((${#command[@]})) || fail "reminders hand systemd-run a bash payload" "$args_file"
  OMARCHY_TEST_NOTIFY_ARGS="$notify_file" PATH="$tmpdir:$PATH" "${command[@]}"
}

# Urgency the notification helper was called with, read from the -u it received.
delivered_urgency() {
  [[ -f $notify_file ]] || return 1
  mapfile -t notify_args <"$notify_file"
  local i
  for ((i = 0; i < ${#notify_args[@]}; i++)); do
    if [[ ${notify_args[i]} == "-u" ]]; then
      printf '%s' "${notify_args[i + 1]}"
      return 0
    fi
  done
  return 1
}

run_reminder 5 "Check the oven"
fire_reminder
[[ $(delivered_urgency) == "critical" ]] ||
  fail "reminders fire at critical urgency by default" "$(cat "$notify_file")"
pass "reminders fire at critical urgency by default"

run_reminder -u low 5 "Check the oven"
fire_reminder
[[ $(delivered_urgency) == "low" ]] ||
  fail "reminders deliver the chosen urgency" "$(cat "$notify_file")"
pass "reminders deliver a chosen urgency"

if run_reminder -u urgent 5 "Check the oven" >/dev/null 2>&1; then
  fail "reminders reject an unknown urgency"
fi
pass "reminders reject an unknown urgency"
