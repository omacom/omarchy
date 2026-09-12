#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
launch_log="$test_tmp/launch-log"
notify_log="$test_tmp/notify-log"
mkdir -p "$mock_bin"

cat >"$mock_bin/omarchy-launch-webapp" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$OMARCHY_TEST_LAUNCH_LOG"
SH

cat >"$mock_bin/omarchy-notification-send" <<'SH'
#!/bin/bash
printf '%s\0' "$@" >>"$OMARCHY_TEST_NOTIFY_LOG"
SH

chmod +x "$mock_bin"/*

export PATH="$mock_bin:$ROOT/bin:$PATH"
export OMARCHY_TEST_LAUNCH_LOG="$launch_log"
export OMARCHY_TEST_NOTIFY_LOG="$notify_log"

: >"$launch_log"
bash "$ROOT/bin/omarchy-webapp-handler-hey"
[[ $(<"$launch_log") == "https://app.hey.com" ]] || fail "HEY handler without a target opens mail"
pass "HEY handler without a target opens mail"

: >"$launch_log"
bash "$ROOT/bin/omarchy-webapp-handler-hey" "mailto:ada@example.com"
[[ $(<"$launch_log") == "https://app.hey.com/messages/new?to=ada@example.com" ]] ||
  fail "HEY handler turns mailto into a compose URL"
pass "HEY handler turns mailto into a compose URL"

: >"$launch_log"
bash "$ROOT/bin/omarchy-webapp-handler-hey" "$test_tmp/invite.ics"
[[ $(<"$launch_log") == "https://app.hey.com/calendar/weeks/" ]] ||
  fail "HEY handler opens calendar for an .ics path"
pass "HEY handler opens calendar for an .ics path"

: >"$launch_log"
bash "$ROOT/bin/omarchy-webapp-handler-hey" "webcal://example.com/feed.ics"
[[ $(<"$launch_log") == "https://app.hey.com/calendar/weeks/" ]] ||
  fail "HEY handler opens calendar for a webcal feed"
pass "HEY handler opens calendar for a webcal feed"

cat >"$test_tmp/timed.ics" <<'EOF'
BEGIN:VCALENDAR
BEGIN:VEVENT
UID:timed-1@example.com
DTSTART;TZID=America/Chicago:20260910T140000
DTEND;TZID=America/Chicago:20260910T150000
SUMMARY:Call with Eric
LOCATION:2130 Utopia Ave
END:VEVENT
END:VCALENDAR
EOF

: >"$launch_log"
python3 "$ROOT/bin/omarchy-webapp-handler-google-calendar"
[[ $(<"$launch_log") == "https://calendar.google.com/calendar/r" ]] ||
  fail "Google Calendar handler without a target opens the calendar"
pass "Google Calendar handler without a target opens the calendar"

: >"$launch_log"
python3 "$ROOT/bin/omarchy-webapp-handler-google-calendar" "$test_tmp/timed.ics"
grep -F 'action=TEMPLATE' "$launch_log" >/dev/null || fail "Google Calendar handler builds a template URL"
grep -F 'text=Call%20with%20Eric' "$launch_log" >/dev/null || fail "Google Calendar handler includes the summary"
grep -F 'dates=20260910T140000/20260910T150000' "$launch_log" >/dev/null ||
  fail "Google Calendar handler includes the event times"
grep -F 'ctz=America/Chicago' "$launch_log" >/dev/null || fail "Google Calendar handler includes the timezone"
grep -F 'location=2130%20Utopia%20Ave' "$launch_log" >/dev/null ||
  fail "Google Calendar handler includes the location"
pass "Google Calendar handler turns an invite into a template URL"

: >"$launch_log"
python3 "$ROOT/bin/omarchy-webapp-handler-google-calendar" "webcal://example.com/feed.ics"
[[ $(<"$launch_log") == "https://calendar.google.com/calendar/r?cid=https%3A%2F%2Fexample.com%2Ffeed.ics" ]] ||
  fail "Google Calendar handler subscribes to a webcal feed"
pass "Google Calendar handler subscribes to a webcal feed"
