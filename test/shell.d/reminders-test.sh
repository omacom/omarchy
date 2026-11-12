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

# `omarchy reminder show` sends one transient card per reminder: when it's due
# as the headline and its message below.
reminder_tmp=$(mktemp -d)
trap 'rm -rf "$reminder_tmp"' EXIT
mkdir -p "$reminder_tmp/bin" "$reminder_tmp/runtime/omarchy-reminders"

cat >"$reminder_tmp/bin/omarchy-notification-send" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >>"$REMINDER_TEST_NOTIFY_LOG"
STUB
printf '#!/bin/bash\n' >"$reminder_tmp/bin/omarchy-shell"

# Lists REMINDER_TEST_COUNT timers, the first due an hour after
# REMINDER_TEST_NOW, then one an hour apart. Other calls are logged, and
# is-active succeeds only for REMINDER_TEST_ACTIVE.
cat >"$reminder_tmp/bin/systemctl" <<'STUB'
#!/bin/bash
if [[ " $* " != *" list-timers "* ]]; then
  printf '%s\n' "$*" >>"$REMINDER_TEST_SYSTEMCTL_LOG"
  [[ " $* " != *" is-active "* || " $* " == *" ${REMINDER_TEST_ACTIVE:-none}.timer "* ]]
  exit
fi
now=$REMINDER_TEST_NOW
printf '['
for ((i = 1; i <= REMINDER_TEST_COUNT; i++)); do
  ((i > 1)) && printf ','
  printf '{"unit":"omarchy-reminder-%sm-%s.timer","next":%s}' $((i * 60)) "$i" "$(((now + i * 3600 + 30) * 1000000))"
done
printf ']\n'
STUB
chmod +x "$reminder_tmp/bin"/*

# One reading of the clock for the fake timers and the expected times, so a
# minute passing in between can't make them disagree.
test_now=$(date +%s)

show_cards() {
  rm -f "$reminder_tmp/notifications"
  REMINDER_TEST_COUNT=$1 REMINDER_TEST_NOW=$test_now OMARCHY_PATH="$ROOT" PATH="$reminder_tmp/bin:$ROOT/bin:$PATH" \
    XDG_RUNTIME_DIR="$reminder_tmp/runtime" XDG_CONFIG_HOME="$reminder_tmp/config" \
    REMINDER_TEST_NOTIFY_LOG="$reminder_tmp/notifications" \
    "$ROOT/bin/omarchy-reminder" show
  cat "$reminder_tmp/notifications"
}

for i in 1 2 3; do
  printf 'Thing %s, with a message long enough to need a card of its own' "$i" \
    >"$reminder_tmp/runtime/omarchy-reminders/omarchy-reminder-$((i * 60))m-$i.message"
done
# The time left ticks while the test runs, so only its shape is checked.
cards=$(show_cards 3 | sed -E 's/In [0-9]+m( [0-9]+s)? · at/In <left> · at/')
expected=$(for i in 3 2 1; do
  printf -- '-g 󰢌 --transient In <left> · at %s Thing %s, with a message long enough to need a card of its own --action Keep true --action Cancel omarchy-reminder cancel --with omarchy-reminder-%sm-%s\n' \
    "$(date -d "@$((test_now + i * 3600 + 30))" +%-H:%M)" "$i" $((i * 60)) "$i"
done)
[[ $cards == "$expected" ]] || fail "reminder list sends a card per reminder, soonest last" "$cards"
pass "reminder list sends a card per reminder, soonest last"

cards=$(show_cards 8)
[[ $(wc -l <<<"$cards") == 6 ]] || fail "reminder list shows five cards and one for the rest" "$cards"
[[ $(head -1 <<<"$cards") == "-g 󰢌 --transient 3 more reminders" ]] || fail "reminder list sums up the rest in one card" "$cards"
[[ $(tail -1 <<<"$cards") == *" Thing 1, "* ]] || fail "reminder list puts the soonest reminder on top" "$cards"
pass "reminder list shows five cards and sums up the rest"

[[ $(show_cards 0) == "-g 󰢌 --transient Upcoming reminders No outstanding reminders" ]] ||
  fail "reminder list says when there are none" "$(show_cards 0)"
pass "reminder list says when there are none"

# Cancel on a card stops that one reminder and drops its message.
cancel() {
  rm -f "$reminder_tmp/notifications" "$reminder_tmp/systemctl.log"
  REMINDER_TEST_ACTIVE=${REMINDER_TEST_ACTIVE:-} OMARCHY_PATH="$ROOT" PATH="$reminder_tmp/bin:$ROOT/bin:$PATH" \
    XDG_RUNTIME_DIR="$reminder_tmp/runtime" XDG_CONFIG_HOME="$reminder_tmp/config" \
    REMINDER_TEST_NOTIFY_LOG="$reminder_tmp/notifications" REMINDER_TEST_SYSTEMCTL_LOG="$reminder_tmp/systemctl.log" \
    "$ROOT/bin/omarchy-reminder" cancel "$@"
}

REMINDER_TEST_ACTIVE=omarchy-reminder-120m-2 cancel omarchy-reminder-120m-2 ||
  fail "cancelling a pending reminder succeeds"
grep -qx -- "--user stop omarchy-reminder-120m-2.timer" "$reminder_tmp/systemctl.log" ||
  fail "cancelling a reminder stops its timer" "$(cat "$reminder_tmp/systemctl.log")"
[[ ! -e $reminder_tmp/runtime/omarchy-reminders/omarchy-reminder-120m-2.message ]] ||
  fail "cancelling a reminder drops its message"
[[ -e $reminder_tmp/runtime/omarchy-reminders/omarchy-reminder-60m-1.message ]] ||
  fail "cancelling a reminder leaves the others alone"
[[ $(cat "$reminder_tmp/notifications") == "-g 󰢌 --transient Reminder cancelled Thing 2, with a message long enough to need a card of its own" ]] ||
  fail "cancelling a reminder says which one" "$(cat "$reminder_tmp/notifications")"
pass "cancelling a reminder stops it, drops its message and says which one"

if cancel omarchy-reminder-60m-1; then
  fail "cancelling a reminder that already went off fails"
fi
[[ $(cat "$reminder_tmp/notifications") == "-g 󰢌 --transient That reminder has already gone off" ]] ||
  fail "cancelling a reminder that already went off says so" "$(cat "$reminder_tmp/notifications")"
pass "cancelling a reminder that already went off says so"

for unit in "" "sshd" "omarchy-reminder-5m-1; rm -rf ~" "omarchy-reminder-5m-1.timer"; do
  if cancel "$unit" 2>/dev/null; then
    fail "cancel refuses a unit that isn't a reminder" "$unit"
  fi
  [[ ! -s $reminder_tmp/systemctl.log ]] || fail "cancel touches no unit for a bad name" "$unit: $(cat "$reminder_tmp/systemctl.log")"
done
pass "cancel refuses anything that isn't a reminder's unit name"
