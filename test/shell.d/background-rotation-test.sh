#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

rot_home="$test_tmp/home"
rot_state="$rot_home/.local/state/omarchy"
rot_enabled="$test_tmp/rot-enabled"
mkdir -p "$rot_state"

command_bin="$test_tmp/bin"
command_log="$test_tmp/command-log"
mkdir -p "$command_bin"

# systemctl: simulate the timer's enabled state with a marker file and record
# the calls, so the command's orchestration can be asserted without the real
# timer. `enable --now` and `disable --now` flip the marker the way systemd
# would flip `is-enabled`.
cat >"$command_bin/systemctl" <<'SH'
#!/bin/bash
if [[ ${1:-} == "--user" && ${2:-} == "is-enabled" ]]; then
  if [[ -f $ROT_ENABLED ]]; then printf 'enabled\n'; exit 0; fi
  exit 1
fi
printf 'systemctl %s\n' "$*" >>"$COMMAND_LOG"
case "$*" in
  *" enable --now"*) touch "$ROT_ENABLED" ;;
  *" disable --now"*) rm -f "$ROT_ENABLED" ;;
esac
SH
chmod +x "$command_bin/systemctl"

cat >"$command_bin/omarchy" <<'SH'
#!/bin/bash
printf 'omarchy %s\n' "$*" >>"$COMMAND_LOG"
SH
chmod +x "$command_bin/omarchy"

cat >"$command_bin/omarchy-notification-send" <<'SH'
#!/bin/bash
printf 'notify %s\n' "$*" >>"$COMMAND_LOG"
SH
chmod +x "$command_bin/omarchy-notification-send"

cat >"$command_bin/omarchy-i18n" <<'SH'
#!/bin/bash
printf '%s' "$*"
SH
chmod +x "$command_bin/omarchy-i18n"

run() {
  HOME="$rot_home" PATH="$command_bin:$ROOT/bin:$PATH" ROT_ENABLED="$rot_enabled" COMMAND_LOG="$command_log" "$@"
}

state=$(run "$ROOT/bin/omarchy-theme-bg-rotate" status || true)
[[ $state == "off" ]] || fail "rotation is off until enabled" "$state"

interval=$(run "$ROOT/bin/omarchy-theme-bg-interval" status)
[[ $interval == "30" ]] || fail "a missing interval defaults to 30 minutes" "$interval"
if run "$ROOT/bin/omarchy-theme-bg-interval" 0; then fail "interval 0 is rejected"; fi
if run "$ROOT/bin/omarchy-theme-bg-interval" nope; then fail "a non-numeric interval is rejected"; fi
if run "$ROOT/bin/omarchy-theme-bg-interval" 1441; then fail "an interval over a day is rejected"; fi
run "$ROOT/bin/omarchy-theme-bg-interval" 90
interval=$(run "$ROOT/bin/omarchy-theme-bg-interval" status)
[[ $interval == "90" ]] || fail "a set interval is read back" "$interval"

: >"$command_log"
run "$ROOT/bin/omarchy-theme-bg-rotate" on
[[ -f $rot_home/.config/systemd/user/omarchy-theme-bg-rotate.timer ]] || fail "on installs the timer unit"
grep -q 'systemctl --user enable --now omarchy-theme-bg-rotate.timer' "$command_log" || fail "on enables the timer"
state=$(run "$ROOT/bin/omarchy-theme-bg-rotate" status || true)
[[ $state == "on" ]] || fail "on flips status to on" "$state"

printf '0\n' >"$rot_state/background-rotation.last"
: >"$command_log"
run "$ROOT/bin/omarchy-theme-bg-rotate" --tick
grep -q 'omarchy theme bg next' "$command_log" || fail "a due tick advances the background"

printf '4000000000\n' >"$rot_state/background-rotation.last"
: >"$command_log"
run "$ROOT/bin/omarchy-theme-bg-rotate" --tick
if grep -q 'omarchy theme bg next' "$command_log"; then fail "a tick before the interval does nothing"; fi

: >"$command_log"
run "$ROOT/bin/omarchy-theme-bg-rotate" toggle
state=$(run "$ROOT/bin/omarchy-theme-bg-rotate" status || true)
[[ $state == "off" ]] || fail "toggle turns an on timer off" "$state"
grep -q 'systemctl --user disable --now omarchy-theme-bg-rotate.timer' "$command_log" || fail "off disables the timer"
run "$ROOT/bin/omarchy-theme-bg-rotate" toggle
state=$(run "$ROOT/bin/omarchy-theme-bg-rotate" status || true)
[[ $state == "on" ]] || fail "toggle turns an off timer on" "$state"

pass "background rotation toggles, interval, and due tick behave"
