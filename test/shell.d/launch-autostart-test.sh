#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command lua

command_path="$ROOT/bin/omarchy-launch-autostart"

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

# Records each call as one block, one argument per line, so a broken argv (say
# "--timeout 15" as one word, which real gdbus rejects at once) cannot pass as
# the right call. The exit status is per bus name: FAKE_GDBUS_FAIL lists the
# names whose wait should time out.
cat >"$fakes/gdbus" <<'EOF'
#!/bin/bash
{ printf '%s\n' "$@"; echo; } >>"$FAKE_LOG_DIR/gdbus"
[[ -e "$FAKE_LOG_DIR/uwsm-app" ]] && echo launched-before-wait >>"$FAKE_LOG_DIR/gdbus"
name="${@: -1}"
[[ " ${FAKE_GDBUS_FAIL:-} " == *" $name "* ]] && exit 1
exit 0
EOF
chmod +x "$fakes/uwsm-app" "$fakes/logger" "$fakes/gdbus"

# Each run gets its own HOME, so the shell.json under test is the only one.
run_command() {
  FAKE_LOG_DIR=$(mktemp -d -p "$fakes")
  HOME="$FAKE_HOME" PATH="$fakes:$PATH" FAKE_LOG_DIR="$FAKE_LOG_DIR" FAKE_GDBUS_FAIL="${FAKE_GDBUS_FAIL:-}" "$command_path" "$@"
}

write_shell_config() {
  FAKE_HOME=$(mktemp -d -p "$fakes")
  mkdir -p "$FAKE_HOME/.config/omarchy"
  printf '%s\n' "$1" >"$FAKE_HOME/.config/omarchy/shell.json"
}

# The recorded gdbus calls, with the second wait's remaining budget replaced by
# R: it is whatever is left of the 15 s after the first wait, so a second tick
# during the run would otherwise make the exact value flaky.
gdbus_calls() {
  awk 'BEGIN { call = 1 } /^$/ { call++; print; next } { if (call > 1 && prev == "--timeout" && $0 ~ /^[0-9]+$/) $0 = "R"; prev = $0; print }' "$FAKE_LOG_DIR/gdbus"
}

# Command substitution strips trailing newlines from both sides, so the blank
# line after the last call never has to match.
calls_are() {
  [[ $(gdbus_calls) == $(printf '%s' "$1") ]]
}

notifications_wait=$'wait\n--session\n--timeout\n15\norg.freedesktop.Notifications\n\n'
notifications_activate=$'wait\n--session\n--activate\n--timeout\n15\norg.freedesktop.Notifications\n\n'
tray_wait=$'wait\n--session\n--timeout\nR\norg.kde.StatusNotifierWatcher\n\n'

FAKE_HOME=$(mktemp -d -p "$fakes")
FAKE_GDBUS_FAIL=""

# Both bus names present: wait for each in turn, then launch with the
# arguments untouched.
run_command chromium --new-window --app="https://example.com/" "two words"

calls_are "$notifications_wait$tray_wait" ||
  fail "autostart waits for the notification service and the tray watcher before launching" "$(gdbus_calls)"
pass "autostart waits for the notification service and the tray watcher before launching"

expected=$'--\nchromium\n--new-window\n--app=https://example.com/\ntwo words'
[[ $(cat "$FAKE_LOG_DIR/uwsm-app") == "$expected" ]] ||
  fail "autostart passes the command to uwsm-app unchanged" "$(cat "$FAKE_LOG_DIR/uwsm-app")"
pass "autostart passes the command to uwsm-app unchanged"

[[ ! -e $FAKE_LOG_DIR/logger ]] || fail "autostart logs nothing when the services are up" "$(cat "$FAKE_LOG_DIR/logger")"
pass "autostart logs nothing when the services are up"

# The second wait spends what is left of the one budget, never a fresh 15 s.
second_timeout=$(awk '/^$/ { call++ } call == 1 && prev == "--timeout" { print; exit } { prev = $0 }' "$FAKE_LOG_DIR/gdbus")
[[ $second_timeout =~ ^[0-9]+$ ]] && (( second_timeout >= 1 && second_timeout <= 15 )) ||
  fail "the tray wait gets the remainder of the shared 15 s budget" "$second_timeout"
pass "the tray wait gets the remainder of the shared 15 s budget"

# Only a disabled shell plugin activates a stand-in daemon: with the plugin on,
# an installed mako or dunst must not get started and beat the shell to the name.
write_shell_config '{"version":1,"disabledPlugins":["omarchy.notifications"]}'
run_command my-app
calls_are "$notifications_activate$tray_wait" ||
  fail "autostart activates a notification daemon when the shell plugin is disabled" "$(gdbus_calls)"
pass "autostart activates a notification daemon when the shell plugin is disabled"

write_shell_config '{"version":1,"disabledPlugins":["omarchy.weather"]}'
run_command my-app
calls_are "$notifications_wait$tray_wait" ||
  fail "autostart does not activate a daemon when the shell plugin is enabled" "$(gdbus_calls)"
pass "autostart does not activate a daemon when the shell plugin is enabled"

write_shell_config 'not json'
run_command my-app
calls_are "$notifications_wait$tray_wait" ||
  fail "autostart treats an unreadable shell.json as everything enabled" "$(gdbus_calls)"
pass "autostart treats an unreadable shell.json as everything enabled"

# The tray watcher comes from whichever bar widget is a tray. A layout with no
# such widget skips that wait; a fork of the stock widget keeps it.
write_shell_config '{"version":1,"bar":{"layout":{"left":[{"id":"omarchy.menu"}],"center":[],"right":[{"id":"omarchy.power"}]}}}'
run_command my-app
calls_are "$notifications_wait" ||
  fail "autostart skips the tray wait when no bar widget is a tray" "$(gdbus_calls)"
pass "autostart skips the tray wait when no bar widget is a tray"

write_shell_config '{"version":1,"bar":{"layout":{"left":[],"center":[],"right":[{"id":"mihailo.tray"}]}}}'
run_command my-app
calls_are "$notifications_wait$tray_wait" ||
  fail "autostart waits for a tray widget forked under another id" "$(gdbus_calls)"
pass "autostart waits for a tray widget forked under another id"

write_shell_config '{"version":1,"bar":{"position":"top"}}'
run_command my-app
calls_are "$notifications_wait$tray_wait" ||
  fail "autostart waits for the tray when shell.json has no bar layout" "$(gdbus_calls)"
pass "autostart waits for the tray when shell.json has no bar layout"

FAKE_HOME=$(mktemp -d -p "$fakes")

# One bus name never appears: launch anyway, exit clean, leave one journal
# line naming that service.
FAKE_GDBUS_FAIL="org.kde.StatusNotifierWatcher"
run_command my-service --flag

[[ -e $FAKE_LOG_DIR/uwsm-app ]] || fail "autostart still launches the app after a wait times out"
[[ $(cat "$FAKE_LOG_DIR/uwsm-app") == $'--\nmy-service\n--flag' ]] ||
  fail "autostart launches the app after a timeout with arguments intact" "$(cat "$FAKE_LOG_DIR/uwsm-app")"
pass "autostart still launches the app after a wait times out"

[[ -e $FAKE_LOG_DIR/logger ]] || fail "autostart reports a timed-out wait to the journal"
(( $(wc -l <"$FAKE_LOG_DIR/logger") == 1 )) || fail "autostart logs exactly one line per missing service" "$(cat "$FAKE_LOG_DIR/logger")"
grep -Fq 'org.kde.StatusNotifierWatcher' "$FAKE_LOG_DIR/logger" ||
  fail "autostart names the missing bus name in its journal line" "$(cat "$FAKE_LOG_DIR/logger")"
! grep -Fq 'org.freedesktop.Notifications' "$FAKE_LOG_DIR/logger" ||
  fail "autostart does not report a service that was there" "$(cat "$FAKE_LOG_DIR/logger")"
grep -Fq -- '-t omarchy-autostart' "$FAKE_LOG_DIR/logger" ||
  fail "autostart tags its journal line" "$(cat "$FAKE_LOG_DIR/logger")"
grep -Fq 'was not available after waiting up to 15s' "$FAKE_LOG_DIR/logger" ||
  fail "autostart's journal line stays true when gdbus fails for any reason" "$(cat "$FAKE_LOG_DIR/logger")"
pass "autostart reports a timed-out wait to the journal"

# Both missing: two lines, one per name.
FAKE_GDBUS_FAIL="org.freedesktop.Notifications org.kde.StatusNotifierWatcher"
run_command my-service
(( $(wc -l <"$FAKE_LOG_DIR/logger") == 2 )) || fail "autostart logs one line per missing service" "$(cat "$FAKE_LOG_DIR/logger")"
pass "autostart logs one line per missing service"
FAKE_GDBUS_FAIL=""

# The Hyprland helper routes autostart through the command and keeps a leading
# Hyprland exec rule outside it; binds stay immediate. Evaluated with a stub hl
# rather than read from the source, so a commented-out routing line cannot pass.
helper_output=$(OMARCHY_PATH="$ROOT" lua <<'LUA'
package.path = os.getenv("OMARCHY_PATH") .. "/?.lua;" .. package.path
local handlers, executed = {}, {}
hl = {
  on = function(event, fn)
    handlers[event] = handlers[event] or {}
    table.insert(handlers[event], fn)
  end,
  exec_cmd = function(command) table.insert(executed, command) end,
}
require("default.hypr.helpers")
o.launch_on_start("my-app --flag")
o.launch_on_start("[workspace 4 silent] foot")
o.launch_on_start("[float] kitty --class notes")
for _, fn in ipairs(handlers["hyprland.start"] or {}) do fn() end
print(table.concat(executed, "\n"))
print(o.launch("my-app --flag"))
LUA
) || fail "helpers.lua can be evaluated with a stub hl"

helper_expected=$'omarchy-launch-autostart my-app --flag\n[workspace 4 silent] omarchy-launch-autostart foot\n[float] omarchy-launch-autostart kitty --class notes\nuwsm-app -- my-app --flag'
[[ $helper_output == "$helper_expected" ]] ||
  fail "o.launch_on_start routes through omarchy-launch-autostart with exec rules kept outside it" "$helper_output"
pass "o.launch_on_start routes through omarchy-launch-autostart"
pass "o.launch_on_start keeps a Hyprland exec rule in front of the helper"
pass "o.launch still launches immediately for binds"
