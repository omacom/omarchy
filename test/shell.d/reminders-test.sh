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

const now = new Date(2026, 9, 12, 13, 41, 30)

assertDeepEqual(reminders.parseWhen('15'), { kind: 'duration', minutes: 15 }, 'reminders parses plain minutes')
assertDeepEqual(reminders.parseWhen('1h30m'), { kind: 'duration', minutes: 90 }, 'reminders parses hour and minute durations')
assertDeepEqual(reminders.parseWhen('in 2 hours'), { kind: 'duration', minutes: 120 }, 'reminders parses spelled-out durations')
assertDeepEqual(reminders.parseWhen('3:30 PM'), { kind: 'time', hour: 15, minute: 30, tomorrow: false }, 'reminders parses 12-hour clock times')
assertDeepEqual(reminders.parseWhen('12am'), { kind: 'time', hour: 0, minute: 0, tomorrow: false }, 'reminders parses 12am as midnight')
assertDeepEqual(reminders.parseWhen('15:30'), { kind: 'time', hour: 15, minute: 30, tomorrow: false }, 'reminders parses 24-hour clock times')
assertDeepEqual(reminders.parseWhen('tomorrow at 9am'), { kind: 'time', hour: 9, minute: 0, tomorrow: true }, 'reminders parses tomorrow times')
assertEqual(reminders.parseWhen('13pm'), null, 'reminders rejects invalid 12-hour times')
assertEqual(reminders.parseWhen('25:00'), null, 'reminders rejects invalid 24-hour times')
assertEqual(reminders.parseWhen('soon'), null, 'reminders rejects unrecognized input')

assertEqual(reminders.describe(reminders.parseWhen('1h30m'), now), 'In 1h 30m · at 3:11 PM', 'reminders previews durations')
assertEqual(reminders.describe(reminders.parseWhen('3:30pm'), now), '3:30 PM today · in 1h 49m', 'reminders previews clock times')
assertEqual(reminders.describe(reminders.parseWhen('9am'), now), '9:00 AM tomorrow · in 19h 19m', 'reminders rolls past times to tomorrow')

assertDeepEqual(reminders.scheduleArgs(reminders.parseWhen('1h'), 'Stretch', now), ['60', 'Stretch'], 'reminders schedules durations in minutes')
assertDeepEqual(reminders.scheduleArgs(reminders.parseWhen('3:30pm'), '', now), ['15:30'], 'reminders schedules clock times for today')
assertDeepEqual(reminders.scheduleArgs(reminders.parseWhen('9am'), 'Call mom', now), ['tomorrow 09:00', 'Call mom'], 'reminders schedules passed times for tomorrow')
assertEqual(reminders.describe(reminders.parseWhen('tomorrow 9am'), new Date(2026, 9, 12, 1, 0)), '9:00 AM tomorrow · in 32h', 'reminders previews the full wait for tomorrow times')
JS

TZ=America/New_York run_node_test <<'JS'
const reminders = requireFromRoot('shell/plugins/reminders/ReminderFlowModel.js')

const beforeSpringForward = new Date(2026, 2, 7, 13, 0)
const beforeFallBack = new Date(2026, 9, 31, 13, 0)
const springTomorrow = reminders.resolveDate(reminders.parseWhen('tomorrow 9am'), beforeSpringForward)
const fallTomorrow = reminders.resolveDate(reminders.parseWhen('tomorrow 9am'), beforeFallBack)

assertEqual(`${springTomorrow.getDate()} ${springTomorrow.getHours()}:${springTomorrow.getMinutes()}`, '8 9:0', 'reminders keep tomorrow at the requested hour across spring forward')
assertEqual(`${fallTomorrow.getDate()} ${fallTomorrow.getHours()}:${fallTomorrow.getMinutes()}`, '1 9:0', 'reminders keep tomorrow at the requested hour across fall back')
assertDeepEqual(
  reminders.scheduleArgs(reminders.parseWhen('tomorrow 2:30am'), '', beforeSpringForward),
  ['tomorrow 02:30'],
  'reminders pass the requested time when today skips that hour'
)
JS

TZ=Australia/Lord_Howe run_node_test <<'JS'
const reminders = requireFromRoot('shell/plugins/reminders/ReminderFlowModel.js')

assertEqual(
  reminders.describe(reminders.parseWhen('tomorrow 2:15am'), new Date(2026, 9, 3, 13, 0)),
  '2:45 AM tomorrow · in 13h 15m',
  'reminders preview a skipped time past a half-hour jump'
)
JS

TZ=Europe/Berlin run_node_test <<'JS'
const reminders = requireFromRoot('shell/plugins/reminders/ReminderFlowModel.js')

assertEqual(
  reminders.describe(reminders.parseWhen('2:30am'), new Date(2026, 9, 25, 0, 30)),
  '2:30 AM today · in 2h',
  'reminders preview the first of a repeated time'
)
JS

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

real_date=$(command -v date)
mkdir -p "$tmp_dir/bin" "$tmp_dir/runtime"

cat >"$tmp_dir/bin/date" <<STUB
#!/bin/bash

for arg in "\$@"; do
  if [[ \$arg == -d* ]]; then
    exec "$real_date" "\$@"
  fi
done

exec "$real_date" -d "@\$FAKE_NOW" "\$@"
STUB

cat >"$tmp_dir/bin/systemd-run" <<STUB
#!/bin/bash

printf '%s\n' "\$@" >"$tmp_dir/systemd-run.args"
STUB

cat >"$tmp_dir/bin/omarchy-notification-send" <<STUB
#!/bin/bash

printf '%s\n' "\$@" >"$tmp_dir/notification.args"
STUB

printf '#!/bin/bash\n' >"$tmp_dir/bin/omarchy-shell"
chmod +x "$tmp_dir/bin/"*

# schedule <local now> <omarchy-reminder args...>, in $REMINDER_TZ (New York by default).
schedule() {
  local now=$1 tz=${REMINDER_TZ:-America/New_York}
  shift

  rm -f "$tmp_dir/systemd-run.args" "$tmp_dir/notification.args"
  FAKE_NOW=$(TZ=$tz "$real_date" -d "$now" +%s) TZ=$tz \
    XDG_RUNTIME_DIR="$tmp_dir/runtime" PATH="$tmp_dir/bin:$PATH" "$ROOT/bin/omarchy-reminder" "$@" >/dev/null
}

assert_timer() {
  local expected=$1 description=$2

  grep -Fx -- "$expected" "$tmp_dir/systemd-run.args" >/dev/null ||
    fail "$description" "expected $expected in: $(cat "$tmp_dir/systemd-run.args" 2>/dev/null)"
  pass "$description"
}

schedule "2026-10-12 13:41" 15 "Stretch"
assert_timer "--on-active=15m" "reminder cli keeps minutes as a countdown"

schedule "2026-10-12 13:41" 3:30pm
assert_timer "--on-calendar=2026-10-12 19:30:00 UTC" "reminder cli schedules a time later today"
assert_timer "--unit=omarchy-reminder-109m-$(TZ=America/New_York "$real_date" -d "2026-10-12 13:41" +%s)" "reminder cli names clock timers by minutes away"
grep -Fx "You'll be reminded today at 3:30 PM" "$tmp_dir/notification.args" >/dev/null || fail "reminder cli confirms the clock time"
pass "reminder cli confirms the clock time"

schedule "2026-10-12 13:41" 3p
assert_timer "--on-calendar=2026-10-12 19:00:00 UTC" "reminder cli reads a bare p as pm"

schedule "2026-10-12 13:41" 9am
assert_timer "--on-calendar=2026-10-13 13:00:00 UTC" "reminder cli rolls a passed time over to tomorrow"

schedule "2026-03-07 13:00" "tomorrow 9am"
assert_timer "--on-calendar=2026-03-08 13:00:00 UTC" "reminder cli keeps tomorrow's time across spring forward"

schedule "2026-10-31 13:00" "9am tomorrow"
assert_timer "--on-calendar=2026-11-01 14:00:00 UTC" "reminder cli keeps tomorrow's time across fall back"

schedule "2026-03-08 04:00" 2:30am
assert_timer "--on-calendar=2026-03-09 06:30:00 UTC" "reminder cli rolls over a time skipped today"

schedule "2026-03-07 13:00" "tomorrow 2:30am"
assert_timer "--on-calendar=2026-03-08 07:30:00 UTC" "reminder cli moves a skipped time past the jump"

schedule "2026-11-01 00:30" 1:30am
assert_timer "--on-calendar=2026-11-01 05:30:00 UTC" "reminder cli picks the first of a repeated time"

REMINDER_TZ=Europe/Berlin schedule "2026-10-25 00:30" 2:30am
assert_timer "--on-calendar=2026-10-25 00:30:00 UTC" "reminder cli picks the first of a repeated time where date would not"

REMINDER_TZ=Europe/Berlin schedule "2026-10-24 13:00" "tomorrow 9am"
assert_timer "--on-calendar=2026-10-25 08:00:00 UTC" "reminder cli keeps times after a fall back on the new offset"

REMINDER_TZ=Australia/Lord_Howe schedule "2026-10-03 13:00" "tomorrow 2:15am"
assert_timer "--on-calendar=2026-10-03 15:45:00 UTC" "reminder cli moves a skipped time by a half-hour jump's length"

for input in 1h 13pm 25:00 soon 0; do
  if schedule "2026-10-12 13:41" "$input" 2>/dev/null || [[ -e $tmp_dir/systemd-run.args ]]; then
    fail "reminder cli rejects $input"
  fi
done
pass "reminder cli rejects input that is not minutes or a clock time"
