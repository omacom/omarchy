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

# Reminders persist across reboots: each one keeps its absolute due time under
# the state dir, and `restore` re-arms the transient timers a reboot dropped.
reminder_tmp=$(mktemp -d)
trap 'rm -rf "$reminder_tmp"' EXIT
mkdir -p "$reminder_tmp/bin"
printf '#!/bin/bash\nexit 0\n' >"$reminder_tmp/bin/omarchy-shell"
cat >"$reminder_tmp/bin/omarchy-notification-send" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >>"$REMINDER_TEST_NOTIFY_LOG"
STUB
# Logs the timer it was asked to start; with REMINDER_TEST_FIRE set it also runs
# the timer's payload right away, as if the timer had elapsed.
cat >"$reminder_tmp/bin/systemd-run" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >>"$REMINDER_TEST_LOG"
if [[ -n $REMINDER_TEST_FIRE ]]; then
  while (($#)) && [[ $1 != bash ]]; do shift; done
  "$@"
fi
STUB
cat >"$reminder_tmp/bin/systemctl" <<'STUB'
#!/bin/bash
if [[ " $* " == *" is-active "* ]]; then
  [[ " $* " == *" $REMINDER_TEST_ACTIVE "* ]]
fi
STUB
chmod +x "$reminder_tmp/bin"/*

reminder() {
  PATH="$reminder_tmp/bin:$PATH" XDG_STATE_HOME="$reminder_tmp/state" \
    REMINDER_TEST_LOG="$reminder_tmp/runs" REMINDER_TEST_ACTIVE="${REMINDER_TEST_ACTIVE:-none}" \
    REMINDER_TEST_NOTIFY_LOG="$reminder_tmp/notifications" REMINDER_TEST_FIRE="${REMINDER_TEST_FIRE:-}" \
    "$ROOT/bin/omarchy-reminder" "$@"
}

store="$reminder_tmp/state/omarchy/reminders"
before=$(date +%s)
reminder 10 "Check the oven"
after=$(date +%s)
due_file=$(compgen -G "$store/omarchy-reminder-10m-*.due") || fail "setting a reminder stores its due time"
read -r due due_minutes <"$due_file"
((due >= before + 600 && due <= after + 600)) || fail "stored due time is ten minutes out ($due)"
[[ $due_minutes == 10 ]] || fail "setting a reminder stores its minutes ($due_minutes)"
[[ $(<"${due_file%.due}.message") == "Check the oven" ]] || fail "setting a reminder stores its message"
grep -q -- "--on-active=600s" "$reminder_tmp/runs" || fail "setting a reminder arms a ten-minute timer"
pass "setting a reminder stores its absolute due time and message"

rm -rf "$store" "$reminder_tmp/runs"
mkdir -p "$store"
now=$(date +%s)
echo "$((now + 3600)) 90" >"$store/omarchy-reminder-90m-1000.due"
echo "$((now - 3600)) 5" >"$store/omarchy-reminder-5m-2000.due"
printf '%s' "Stand up" >"$store/omarchy-reminder-5m-2000.message"
echo "$((now + 60)) 2" >"$store/omarchy-reminder-2m-3000.due"
echo "garbage" >"$store/omarchy-reminder-1m-4000.due"
# The default message comes from the stored minutes, not the unit name.
echo "$((now + 1800)) 30" >"$store/omarchy-reminder-30-1700000000-12345.due"
REMINDER_TEST_ACTIVE=omarchy-reminder-2m-3000.timer reminder restore

grep -Eq -- "--on-active=(359[0-9]|3600)s --unit=omarchy-reminder-90m-1000 .*Your 90 minutes are up" "$reminder_tmp/runs" ||
  fail "restore re-arms a pending reminder for its remaining time"
pass "restore re-arms a pending reminder for its remaining time"

grep -Eq -- "--on-active=(179[0-9]|1800)s --unit=omarchy-reminder-30-1700000000-12345 .*Your 30 minutes are up" "$reminder_tmp/runs" ||
  fail "restore builds the default message from the stored minutes"
pass "restore builds the default message from the stored minutes"

grep -q -- "--on-active=1s --unit=omarchy-reminder-5m-2000 .*Stand up" "$reminder_tmp/runs" ||
  fail "restore fires an overdue reminder right away with its message"
pass "restore fires an overdue reminder right away with its message"

if grep -q "omarchy-reminder-2m-3000" "$reminder_tmp/runs"; then
  fail "restore leaves a reminder whose timer is still live alone"
fi
pass "restore leaves a reminder whose timer is still live alone"

[[ ! -e $store/omarchy-reminder-1m-4000.due ]] || fail "restore drops a malformed record"
pass "restore drops a malformed record"

reminder clear
[[ -z $(compgen -G "$store/*") ]] || fail "clear removes stored reminders"
pass "clear removes stored reminders"

rm -rf "$store" "$reminder_tmp/runs"
reminder 010
grep -q -- "--on-active=600s --unit=omarchy-reminder-10m-" "$reminder_tmp/runs" ||
  fail "minutes with a leading zero are read as base 10"
due_file=$(compgen -G "$store/omarchy-reminder-10m-*.due") || fail "a leading-zero reminder is stored under its base-10 minutes"
pass "minutes with a leading zero are read as base 10"

if reminder 00 >/dev/null; then
  fail "zero minutes written with a leading zero are rejected"
fi
pass "zero minutes written with a leading zero are rejected"

rm -rf "$store" "$reminder_tmp/runs" "$reminder_tmp/notifications"
REMINDER_TEST_FIRE=1 reminder 5 "Stretch"
grep -q "Reminder Stretch" "$reminder_tmp/notifications" || fail "a fired reminder sends its message"
[[ -z $(compgen -G "$store/omarchy-reminder-*") ]] || fail "a fired reminder drops its stored due time and message"
rm -f "$reminder_tmp/runs"
reminder restore
if grep -q "omarchy-reminder-5m-" "$reminder_tmp/runs" 2>/dev/null; then
  fail "restore does not re-arm a reminder that already fired"
fi
pass "a fired reminder is dropped and not re-armed by restore"
