#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

command_path="$ROOT/bin/omarchy-launch-autostart"
helpers="$ROOT/default/hypr/helpers.lua"

[[ -x $command_path ]] || fail "omarchy-launch-autostart exists and is executable"
pass "omarchy-launch-autostart exists and is executable"

grep -Fxq '# omarchy:hidden=true' "$command_path" || fail "omarchy-launch-autostart is hidden plumbing"
grep -Eq '^# omarchy:summary=.+' "$command_path" || fail "omarchy-launch-autostart declares a summary"
pass "omarchy-launch-autostart carries command metadata"

# Everything below runs headless: fakes on PATH stand in for gdbus, uwsm-app and
# logger, and record what they were called with.
fakes=$(mktemp -d)
trap 'rm -rf "$fakes"' EXIT

cat >"$fakes/uwsm-app" <<'EOF'
#!/bin/bash
printf '%s\n' "$@" >"$FAKE_LOG_DIR/uwsm-app"
EOF

cat >"$fakes/logger" <<'EOF'
#!/bin/bash
printf '%s\n' "$*" >>"$FAKE_LOG_DIR/logger"
EOF

write_gdbus() {
  cat >"$fakes/gdbus" <<EOF
#!/bin/bash
printf '%s\n' "\$*" >>"\$FAKE_LOG_DIR/gdbus"
[[ -e "\$FAKE_LOG_DIR/uwsm-app" ]] && echo launched-before-wait >>"\$FAKE_LOG_DIR/gdbus"
exit $1
EOF
  chmod +x "$fakes/gdbus"
}
chmod +x "$fakes/uwsm-app" "$fakes/logger"

run_command() {
  FAKE_LOG_DIR=$(mktemp -d -p "$fakes")
  PATH="$fakes:$PATH" FAKE_LOG_DIR="$FAKE_LOG_DIR" "$command_path" "$@"
}

# Bus name present: wait once, then launch with the arguments untouched.
write_gdbus 0
run_command chromium --new-window --app="https://example.com/" "two words"

[[ $(cat "$FAKE_LOG_DIR/gdbus") == "wait --session --timeout 15 org.freedesktop.Notifications" ]] ||
  fail "autostart waits for the notification service before launching" "$(cat "$FAKE_LOG_DIR/gdbus")"
pass "autostart waits for the notification service before launching"

expected=$'--\nchromium\n--new-window\n--app=https://example.com/\ntwo words'
[[ $(cat "$FAKE_LOG_DIR/uwsm-app") == "$expected" ]] ||
  fail "autostart passes the command to uwsm-app unchanged" "$(cat "$FAKE_LOG_DIR/uwsm-app")"
pass "autostart passes the command to uwsm-app unchanged"

[[ ! -e $FAKE_LOG_DIR/logger ]] || fail "autostart logs nothing when the service is up" "$(cat "$FAKE_LOG_DIR/logger")"
pass "autostart logs nothing when the service is up"

# Bus name never appears: launch anyway, exit clean, leave one journal line.
write_gdbus 1
run_command my-service --flag

[[ -e $FAKE_LOG_DIR/uwsm-app ]] || fail "autostart still launches the app after the wait times out"
[[ $(cat "$FAKE_LOG_DIR/uwsm-app") == $'--\nmy-service\n--flag' ]] ||
  fail "autostart launches the app after a timeout with arguments intact" "$(cat "$FAKE_LOG_DIR/uwsm-app")"
pass "autostart still launches the app after the wait times out"

[[ -e $FAKE_LOG_DIR/logger ]] || fail "autostart reports a timed-out wait to the journal"
(( $(wc -l <"$FAKE_LOG_DIR/logger") == 1 )) || fail "autostart logs exactly one line on timeout" "$(cat "$FAKE_LOG_DIR/logger")"
grep -Fq 'org.freedesktop.Notifications' "$FAKE_LOG_DIR/logger" ||
  fail "autostart names the missing bus name in its journal line" "$(cat "$FAKE_LOG_DIR/logger")"
grep -Fq -- '-t omarchy-autostart' "$FAKE_LOG_DIR/logger" ||
  fail "autostart tags its journal line" "$(cat "$FAKE_LOG_DIR/logger")"
pass "autostart reports a timed-out wait to the journal"

# The Hyprland helper routes autostart through the command; binds stay immediate.
grep -Fq 'o.exec_on_start("omarchy-launch-autostart " .. command)' "$helpers" ||
  fail "o.launch_on_start routes through omarchy-launch-autostart"
pass "o.launch_on_start routes through omarchy-launch-autostart"

grep -Fxq '  return "uwsm-app -- " .. command' "$helpers" || fail "o.launch still launches immediately for binds"
pass "o.launch still launches immediately for binds"
