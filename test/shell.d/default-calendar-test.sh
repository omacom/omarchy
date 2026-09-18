#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
test_home="$test_tmp/home"
mime_dir="$test_tmp/mime"
notification_log="$test_tmp/notification-log"
mkdir -p "$mock_bin" "$test_home/.local/share/applications" "$mime_dir"

cat >"$mock_bin/xdg-mime" <<'SH'
#!/bin/bash
mkdir -p "$OMARCHY_TEST_MIME_DIR"
key=${3//\//_}
case $1 in
query)
  if [[ $2 == default && -f $OMARCHY_TEST_MIME_DIR/$key ]]; then
    cat "$OMARCHY_TEST_MIME_DIR/$key"
  fi
  ;;
default)
  printf '%s\n' "$2" >"$OMARCHY_TEST_MIME_DIR/$key"
  ;;
esac
SH

cat >"$mock_bin/omarchy-notification-send" <<'SH'
#!/bin/bash
printf '%s\0' "$@" >>"$OMARCHY_TEST_NOTIFICATION_LOG"
SH

cat >"$mock_bin/update-desktop-database" <<'SH'
#!/bin/bash
exit 0
SH

chmod +x "$mock_bin"/*

export HOME="$test_home"
export PATH="$mock_bin:$ROOT/bin:$PATH"
export OMARCHY_PATH="$ROOT"
export OMARCHY_TEST_MIME_DIR="$mime_dir"
export OMARCHY_TEST_NOTIFICATION_LOG="$notification_log"

grep -qx 'text/calendar=HEY.desktop' "$ROOT/default/applications/mimeapps.list" ||
  fail "system mimeapps.list defaults text/calendar to HEY"
grep -qx 'x-scheme-handler/webcal=HEY.desktop' "$ROOT/default/applications/mimeapps.list" ||
  fail "system mimeapps.list defaults webcal to HEY"
grep -q 'text/calendar' "$ROOT/applications/HEY.desktop" ||
  fail "HEY.desktop declares text/calendar"
grep -q 'x-scheme-handler/webcal' "$ROOT/applications/Google Calendar.desktop" ||
  fail "Google Calendar.desktop declares webcal"
pass "packaged calendar MIME defaults point at HEY"

[[ $(omarchy-default-calendar) == "hey" ]] || fail "an unset calendar handler reads as hey"
pass "unset calendar handler is HEY"

if omarchy-default-calendar thunderbird >"$test_tmp/invalid" 2>&1; then
  fail "invalid calendar selection returns an error"
fi
grep -F "Usage: omarchy-default-calendar" "$test_tmp/invalid" >/dev/null ||
  fail "invalid calendar selection prints usage"
[[ $(omarchy-default-calendar) == "hey" ]] || fail "invalid calendar selection preserves the default"
pass "invalid calendar selection is rejected"

: >"$notification_log"
omarchy-default-calendar google
[[ $(omarchy-default-calendar) == "google" ]] || fail "google becomes the default calendar"
[[ $(xdg-mime query default text/calendar) == "Google Calendar.desktop" ]] ||
  fail "google owns text/calendar"
[[ $(xdg-mime query default x-scheme-handler/webcal) == "Google Calendar.desktop" ]] ||
  fail "google owns webcal"
[[ -f "$test_home/.local/share/applications/Google Calendar.desktop" ]] ||
  fail "google copies the packaged Google Calendar launcher"
grep -z 'Google Calendar is now the default calendar' "$notification_log" >/dev/null ||
  fail "google selection notifies"
pass "google calendar becomes the XDG handler"

: >"$notification_log"
omarchy-default-calendar hey
[[ $(omarchy-default-calendar) == "hey" ]] || fail "hey becomes the default calendar"
[[ $(xdg-mime query default text/calendar) == "HEY.desktop" ]] || fail "hey owns text/calendar"
[[ $(xdg-mime query default application/ics) == "HEY.desktop" ]] || fail "hey owns application/ics"
[[ $(xdg-mime query default text/x-vcalendar) == "HEY.desktop" ]] || fail "hey owns text/x-vcalendar"
[[ $(xdg-mime query default x-scheme-handler/webcal) == "HEY.desktop" ]] || fail "hey owns webcal"
pass "hey calendar restores the packaged default"
