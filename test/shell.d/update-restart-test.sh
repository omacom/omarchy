#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

require_command script

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
test_home="$test_tmp/home"
mkdir -p "$stub_bin" "$test_home/.local/state/omarchy"

GUM_LOG="$test_tmp/gum.log"
SUDO_LOG="$test_tmp/sudo.log"
REBOOT_LOG="$test_tmp/reboot.log"
STATE_LOG="$test_tmp/state.log"
RESTART_LOG="$test_tmp/restart.log"
SYSTEMCTL_LOG="$test_tmp/systemctl.log"
SHELL_LOG="$test_tmp/shell.log"
: >"$GUM_LOG"
: >"$SUDO_LOG"
: >"$REBOOT_LOG"
: >"$STATE_LOG"
: >"$RESTART_LOG"
: >"$SYSTEMCTL_LOG"
: >"$SHELL_LOG"

write_stub() {
  local name="$1"
  local body="$2"

  cat >"$stub_bin/$name" <<SH
#!/bin/bash
$body
SH
  chmod +x "$stub_bin/$name"
}

reset_logs() {
  : >"$GUM_LOG"
  : >"$SUDO_LOG"
  : >"$REBOOT_LOG"
  : >"$STATE_LOG"
  : >"$RESTART_LOG"
  : >"$SYSTEMCTL_LOG"
  : >"$SHELL_LOG"
}

clean_pty_out() {
  tr -d '\r' <"$1"
}

clear_reboot_markers() {
  rm -f "$test_home/.local/state/omarchy/reboot-required"
}

clear_restart_markers() {
  rm -f "$test_home"/.local/state/omarchy/restart-*-required
}

existing_kernel="$(basename "$(dirname "$(ls /usr/lib/modules/*/vmlinuz 2>/dev/null | head -n 1)")")"
[[ -n $existing_kernel ]] || existing_kernel="$(uname -r)"

write_stub uname 'if [[ ${1:-} == "-r" ]]; then printf "%s\\n" "${TEST_RUNNING_KERNEL:-fake}"; exit 0; fi
exec /usr/bin/uname "$@"'

write_stub pacman 'if [[ ${1:-} == "-Qo" ]]; then exit 0; fi
echo "unexpected pacman $*" >&2
exit 1'

write_stub pgrep 'if [[ ${1:-} == "-x" && ${2:-} == "Hyprland" ]]; then
  if [[ ${TEST_PGREP_MODE:-none} == "present" ]]; then printf "1234\\n"; exit 0; else exit 1; fi
fi
echo "unexpected pgrep $*" >&2
exit 1'

write_stub readlink 'if [[ ${1:-} == "-f" ]]; then exec /usr/bin/readlink "$@"; fi
if [[ ${1:-} == /proc/*/exe ]]; then
  if [[ ${TEST_HYPRLAND_DELETED:-0} == "1" ]]; then printf "/usr/bin/Hyprland (deleted)\\n"; exit 0; else exit 1; fi
fi
exec /usr/bin/readlink "$@"'

write_stub gum 'printf "%s\\n" "$*" >>"${GUM_LOG:-/dev/null}"
exit "${TEST_GUM_EXIT:-99}"'

write_stub omarchy-system-reboot 'printf "reboot\\n%s\\n" "$*" >>"${REBOOT_LOG:-/dev/null}"
exit 0'

write_stub omarchy-state 'printf "%s\\n" "$*" >>"${STATE_LOG:-/dev/null}"
if [[ ${1:-} == "clear" ]]; then rm -f "$HOME/.local/state/omarchy/${2:-}"; exit 0; fi
exit 0'

write_stub omarchy-restart-audio 'printf "audio %s\\n" "$*" >>"${RESTART_LOG:-/dev/null}"
exit "${TEST_RESTART_AUDIO_EXIT:-0}"'

write_stub omarchy-restart-trackpad 'printf "trackpad %s\\n" "$*" >>"${RESTART_LOG:-/dev/null}"
exit "${TEST_RESTART_TRACKPAD_EXIT:-0}"'

write_stub omarchy-restart-shell 'printf "shell %s\\n" "$*" >>"${SHELL_LOG:-/dev/null}"
exit 0'

write_stub sudo 'printf "%q " "$@" >>"${SUDO_LOG:-/dev/null}"
printf "\\n" >>"${SUDO_LOG:-/dev/null}"
args=()
for a in "$@"; do
  if [[ $a == "-n" ]]; then continue; fi
  if [[ $a == "--" ]]; then continue; fi
  args+=("$a")
done
if (( ${#args[@]} == 0 )); then exit 0; fi
exec "${args[@]}"'

write_stub systemctl 'printf "%q " "$@" >>"${SYSTEMCTL_LOG:-/dev/null}"
printf "\\n" >>"${SYSTEMCTL_LOG:-/dev/null}"
exit "${TEST_SYSTEMCTL_EXIT:-0}"'

export GUM_LOG SUDO_LOG REBOOT_LOG STATE_LOG RESTART_LOG SYSTEMCTL_LOG SHELL_LOG

# Interactive ask PTY decline: default policy (unset) with unset UNATTENDED is
# ask; gum decline continues without reboot.
reset_logs
clear_reboot_markers
clear_restart_markers
set +e
unset OMARCHY_UPDATE_REBOOT
unset OMARCHY_UPDATE_UNATTENDED
export OMARCHY_UPDATE_RESTARTS="run"
export TEST_RUNNING_KERNEL="0.0.0-fake-no-match"
export TEST_PGREP_MODE="none"
export TEST_HYPRLAND_DELETED="0"
export TEST_GUM_EXIT="1"
export TEST_SYSTEMCTL_EXIT="0"
export TEST_RESTART_AUDIO_EXIT="0"
export TEST_RESTART_TRACKPAD_EXIT="0"
HOME="$test_home" PATH="$stub_bin:$PATH" script -qec "$ROOT/bin/omarchy-update-restart" /dev/null >"$test_tmp/ask-decline.out" 2>"$test_tmp/ask-decline.err"
ask_decline_status=$?
set -e
(( ask_decline_status == 0 )) || fail "ask PTY decline exits 0" "got $ask_decline_status"
(( $(wc -l <"$GUM_LOG") == 1 )) || fail "ask PTY decline calls gum once" "$(cat "$GUM_LOG")"
grep -q 'confirm' "$GUM_LOG" || fail "ask PTY decline uses gum confirm" "$(cat "$GUM_LOG")"
grep -q 'Linux kernel has been updated. Reboot?' "$GUM_LOG" || fail "ask PTY decline preserves kernel message" "$(cat "$GUM_LOG")"
[[ ! -s $REBOOT_LOG ]] || fail "ask PTY decline does not reboot" "$(cat "$REBOOT_LOG")"
[[ ! -s $SUDO_LOG ]] || fail "ask PTY decline does not call sudo" "$(cat "$SUDO_LOG")"
pass "ask PTY decline preserves interactive prompt without reboot"

# Interactive ask PTY accept: explicit ask calls omarchy-system-reboot once and
# exits before shell restart.
reset_logs
clear_reboot_markers
clear_restart_markers
set +e
export OMARCHY_UPDATE_REBOOT="ask"
unset OMARCHY_UPDATE_UNATTENDED
export OMARCHY_UPDATE_RESTARTS="run"
export TEST_RUNNING_KERNEL="0.0.0-fake-no-match"
export TEST_PGREP_MODE="none"
export TEST_HYPRLAND_DELETED="0"
export TEST_GUM_EXIT="0"
HOME="$test_home" PATH="$stub_bin:$PATH" script -qec "$ROOT/bin/omarchy-update-restart" /dev/null >"$test_tmp/ask-accept.out" 2>"$test_tmp/ask-accept.err"
ask_accept_status=$?
set -e
(( ask_accept_status == 0 )) || fail "ask PTY accept exits 0" "got $ask_accept_status"
(( $(wc -l <"$GUM_LOG") == 1 )) || fail "ask PTY accept calls gum once" "$(cat "$GUM_LOG")"
(( $(grep -c '^reboot$' "$REBOOT_LOG") == 1 )) || fail "ask PTY accept calls omarchy-system-reboot once" "$(cat "$REBOOT_LOG")"
[[ ! -s $SUDO_LOG ]] || fail "ask PTY accept does not call sudo directly" "$(cat "$SUDO_LOG")"
[[ ! -s $SYSTEMCTL_LOG ]] || fail "ask PTY accept does not call systemctl" "$(cat "$SYSTEMCTL_LOG")"
[[ ! -s $SHELL_LOG ]] || fail "ask PTY accept exits before shell restart" "$(cat "$SHELL_LOG")"
pass "ask PTY accept calls omarchy-system-reboot once"

# Unattended ask under PTY must never reach gum (leak regression).
reset_logs
clear_reboot_markers
clear_restart_markers
set +e
export OMARCHY_UPDATE_REBOOT="ask"
export OMARCHY_UPDATE_UNATTENDED="1"
export OMARCHY_UPDATE_RESTARTS="run"
export TEST_RUNNING_KERNEL="0.0.0-fake-no-match"
export TEST_PGREP_MODE="none"
export TEST_HYPRLAND_DELETED="0"
export TEST_GUM_EXIT="0"
HOME="$test_home" PATH="$stub_bin:$PATH" script -qec "$ROOT/bin/omarchy-update-restart" /dev/null >"$test_tmp/unattended-ask-pty.out" 2>"$test_tmp/unattended-ask-pty.err"
unattended_ask_status=$?
set -e
(( unattended_ask_status == 0 )) || fail "unattended ask PTY exits 0" "got $unattended_ask_status"
[[ ! -s $GUM_LOG ]] || fail "unattended ask PTY does not call gum" "$(cat "$GUM_LOG")"
[[ ! -s $REBOOT_LOG ]] || fail "unattended ask PTY does not reboot" "$(cat "$REBOOT_LOG")"
[[ ! -s $SUDO_LOG ]] || fail "unattended ask PTY does not call sudo" "$(cat "$SUDO_LOG")"
clean_pty_out "$test_tmp/unattended-ask-pty.out" | grep -q 'Reboot required:' || fail "unattended ask PTY reports need" "$(clean_pty_out "$test_tmp/unattended-ask-pty.out")"
pass "unattended ask never reaches gum even under PTY"

# never under PTY + unattended: report, no gum, no reboot, markers kept.
reset_logs
clear_restart_markers
mkdir -p "$test_home/.local/state/omarchy"
touch "$test_home/.local/state/omarchy/reboot-required"
set +e
export OMARCHY_UPDATE_REBOOT="never"
export OMARCHY_UPDATE_UNATTENDED="1"
export OMARCHY_UPDATE_RESTARTS="run"
export TEST_RUNNING_KERNEL="$existing_kernel"
export TEST_PGREP_MODE="none"
export TEST_HYPRLAND_DELETED="0"
export TEST_GUM_EXIT="99"
HOME="$test_home" PATH="$stub_bin:$PATH" script -qec "$ROOT/bin/omarchy-update-restart" /dev/null >"$test_tmp/never-pty.out" 2>"$test_tmp/never-pty.err"
never_pty_status=$?
set -e
(( never_pty_status == 0 )) || fail "never PTY exits 0" "got $never_pty_status"
[[ ! -s $GUM_LOG ]] || fail "never PTY does not call gum" "$(cat "$GUM_LOG")"
[[ ! -s $REBOOT_LOG ]] || fail "never PTY does not reboot" "$(cat "$REBOOT_LOG")"
[[ ! -s $SUDO_LOG ]] || fail "never PTY does not call sudo" "$(cat "$SUDO_LOG")"
clean_pty_out "$test_tmp/never-pty.out" | grep -q 'Reboot required:' || fail "never PTY reports need" "$(clean_pty_out "$test_tmp/never-pty.out")"
[[ -f $test_home/.local/state/omarchy/reboot-required ]] || fail "never PTY keeps reboot marker"
pass "never reports without reboot under PTY"

# if-needed unattended PTY via scoped adapter: single sudo reboot, no double.
reset_logs
clear_restart_markers
mkdir -p "$test_home/.local/state/omarchy"
touch "$test_home/.local/state/omarchy/reboot-required"
set +e
export OMARCHY_UPDATE_REBOOT="if-needed"
export OMARCHY_UPDATE_UNATTENDED="1"
export OMARCHY_UPDATE_RESTARTS="run"
export OMARCHY_PATH="$ROOT"
export TEST_RUNNING_KERNEL="0.0.0-fake-no-match"
export TEST_PGREP_MODE="present"
export TEST_HYPRLAND_DELETED="1"
export TEST_GUM_EXIT="99"
export TEST_SYSTEMCTL_EXIT="0"
HOME="$test_home" PATH="$stub_bin:$PATH" script -qec "$ROOT/bin/omarchy-update-run $ROOT/bin/omarchy-update-restart" /dev/null >"$test_tmp/ifneeded-pty.out" 2>"$test_tmp/ifneeded-pty.err"
ifneeded_status=$?
set -e
(( ifneeded_status == 0 )) || fail "if-needed PTY exits 0" "got $ifneeded_status; out=$(clean_pty_out "$test_tmp/ifneeded-pty.out"); err=$(cat "$test_tmp/ifneeded-pty.err")"
[[ ! -s $GUM_LOG ]] || fail "if-needed PTY does not call gum" "$(cat "$GUM_LOG")"
[[ ! -s $REBOOT_LOG ]] || fail "if-needed does not call omarchy-system-reboot" "$(cat "$REBOOT_LOG")"
grep -q -- '-n' "$SUDO_LOG" || fail "if-needed via adapter uses sudo -n" "$(cat "$SUDO_LOG")"
grep -q 'systemctl' "$SUDO_LOG" || fail "if-needed calls systemctl via sudo" "$(cat "$SUDO_LOG")"
grep -q -- '--no-ask-password' "$SUDO_LOG" || fail "if-needed uses --no-ask-password" "$(cat "$SUDO_LOG")"
grep -q -- 'reboot' "$SUDO_LOG" || fail "if-needed reboots via sudo" "$(cat "$SUDO_LOG")"
grep -q -- '--no-wall' "$SUDO_LOG" || fail "if-needed uses --no-wall" "$(cat "$SUDO_LOG")"
(( $(wc -l <"$SUDO_LOG") == 1 )) || fail "if-needed requests reboot exactly once" "$(cat "$SUDO_LOG")"
(( $(wc -l <"$SYSTEMCTL_LOG") == 1 )) || fail "if-needed calls systemctl exactly once" "$(cat "$SYSTEMCTL_LOG")"
clean_pty_out "$test_tmp/ifneeded-pty.out" | grep -q 'Reboot requested\.' || fail "if-needed prints success message" "$(clean_pty_out "$test_tmp/ifneeded-pty.out")"
unset OMARCHY_PATH
pass "if-needed reboots once via sudo -n without double request"

# if-needed failure: systemctl exit 5 -> nonzero, no success message.
reset_logs
clear_reboot_markers
clear_restart_markers
set +e
export OMARCHY_UPDATE_REBOOT="if-needed"
export OMARCHY_UPDATE_UNATTENDED="1"
export OMARCHY_PATH="$ROOT"
export OMARCHY_UPDATE_RESTARTS="run"
export TEST_RUNNING_KERNEL="0.0.0-fake-no-match"
export TEST_PGREP_MODE="none"
export TEST_HYPRLAND_DELETED="0"
export TEST_GUM_EXIT="99"
export TEST_SYSTEMCTL_EXIT="5"
HOME="$test_home" PATH="$stub_bin:$PATH" "$ROOT/bin/omarchy-update-run" "$ROOT/bin/omarchy-update-restart" >"$test_tmp/ifneeded-fail.out" 2>"$test_tmp/ifneeded-fail.err"
ifneeded_fail_status=$?
set -e
(( ifneeded_fail_status != 0 )) || fail "if-needed failure exits nonzero" "got 0"
grep -q 'Reboot requested\.' "$test_tmp/ifneeded-fail.out" && fail "if-needed failure prints no success message" "$(cat "$test_tmp/ifneeded-fail.out")"
grep -q 'automatic reboot failed' "$test_tmp/ifneeded-fail.err" || fail "if-needed failure reports on stderr" "$(cat "$test_tmp/ifneeded-fail.err")"
[[ ! -s $GUM_LOG ]] || fail "if-needed failure does not call gum" "$(cat "$GUM_LOG")"
[[ ! -s $REBOOT_LOG ]] || fail "if-needed failure does not call omarchy-system-reboot" "$(cat "$REBOOT_LOG")"
unset OMARCHY_PATH
pass "if-needed failure exits nonzero without success message"

# never with all 3 triggers: one report line per need, no reboot, markers kept.
reset_logs
clear_restart_markers
mkdir -p "$test_home/.local/state/omarchy"
touch "$test_home/.local/state/omarchy/reboot-required"
set +e
export OMARCHY_UPDATE_REBOOT="never"
export OMARCHY_UPDATE_UNATTENDED="1"
export OMARCHY_UPDATE_RESTARTS="run"
unset OMARCHY_PATH
export TEST_RUNNING_KERNEL="0.0.0-fake-no-match"
export TEST_PGREP_MODE="present"
export TEST_HYPRLAND_DELETED="1"
export TEST_GUM_EXIT="99"
export TEST_SYSTEMCTL_EXIT="0"
HOME="$test_home" PATH="$stub_bin:$PATH" "$ROOT/bin/omarchy-update-restart" >"$test_tmp/never-all.out" 2>"$test_tmp/never-all.err"
never_all_status=$?
set -e
(( never_all_status == 0 )) || fail "never all triggers exits 0" "got $never_all_status"
[[ ! -s $GUM_LOG ]] || fail "never all triggers does not call gum" "$(cat "$GUM_LOG")"
[[ ! -s $REBOOT_LOG ]] || fail "never all triggers does not reboot" "$(cat "$REBOOT_LOG")"
[[ ! -s $SUDO_LOG ]] || fail "never all triggers does not call sudo" "$(cat "$SUDO_LOG")"
[[ ! -s $SYSTEMCTL_LOG ]] || fail "never all triggers does not call systemctl" "$(cat "$SYSTEMCTL_LOG")"
(( $(grep -c 'Reboot required:' "$test_tmp/never-all.out") == 3 )) || fail "never all triggers reports each need once" "$(cat "$test_tmp/never-all.out")"
grep -q 'Linux kernel has been updated. Reboot?' "$test_tmp/never-all.out" || fail "never all triggers reports kernel" "$(cat "$test_tmp/never-all.out")"
grep -q 'Updates require reboot. Ready?' "$test_tmp/never-all.out" || fail "never all triggers reports marker" "$(cat "$test_tmp/never-all.out")"
grep -q 'Hyprland has been updated. Reboot?' "$test_tmp/never-all.out" || fail "never all triggers reports hyprland" "$(cat "$test_tmp/never-all.out")"
[[ -f $test_home/.local/state/omarchy/reboot-required ]] || fail "never all triggers keeps reboot marker"
pass "never with all triggers reports each need once without reboot"

# No triggers: no reboot output, quiet.
reset_logs
clear_reboot_markers
clear_restart_markers
set +e
export OMARCHY_UPDATE_REBOOT="never"
unset OMARCHY_UPDATE_UNATTENDED
export OMARCHY_UPDATE_RESTARTS="run"
export TEST_RUNNING_KERNEL="$existing_kernel"
export TEST_PGREP_MODE="none"
export TEST_HYPRLAND_DELETED="0"
export TEST_GUM_EXIT="99"
HOME="$test_home" PATH="$stub_bin:$PATH" "$ROOT/bin/omarchy-update-restart" >"$test_tmp/no-trigger.out" 2>"$test_tmp/no-trigger.err"
no_trigger_status=$?
set -e
(( no_trigger_status == 0 )) || fail "no triggers exits 0" "got $no_trigger_status"
grep -q 'Reboot required:' "$test_tmp/no-trigger.out" && fail "no triggers prints no reboot output" "$(cat "$test_tmp/no-trigger.out")"
[[ ! -s $GUM_LOG ]] || fail "no triggers does not call gum" "$(cat "$GUM_LOG")"
[[ ! -s $REBOOT_LOG ]] || fail "no triggers does not reboot" "$(cat "$REBOOT_LOG")"
[[ ! -s $SUDO_LOG ]] || fail "no triggers does not call sudo" "$(cat "$SUDO_LOG")"
pass "no triggers stays quiet without reboot output"

# restarts=skip with markers present: intact, no restart calls, exit 0.
reset_logs
clear_reboot_markers
mkdir -p "$test_home/.local/state/omarchy"
touch "$test_home/.local/state/omarchy/restart-audio-required"
touch "$test_home/.local/state/omarchy/restart-trackpad-required"
set +e
export OMARCHY_UPDATE_REBOOT="never"
unset OMARCHY_UPDATE_UNATTENDED
export OMARCHY_UPDATE_RESTARTS="skip"
export TEST_RUNNING_KERNEL="$existing_kernel"
export TEST_PGREP_MODE="none"
export TEST_HYPRLAND_DELETED="0"
export TEST_GUM_EXIT="99"
HOME="$test_home" PATH="$stub_bin:$PATH" "$ROOT/bin/omarchy-update-restart" >"$test_tmp/skip.out" 2>"$test_tmp/skip.err"
skip_status=$?
set -e
(( skip_status == 0 )) || fail "restarts skip exits 0" "got $skip_status"
[[ -f $test_home/.local/state/omarchy/restart-audio-required ]] || fail "restarts skip keeps audio marker"
[[ -f $test_home/.local/state/omarchy/restart-trackpad-required ]] || fail "restarts skip keeps trackpad marker"
[[ ! -s $RESTART_LOG ]] || fail "restarts skip makes no service calls" "$(cat "$RESTART_LOG")"
[[ ! -s $SHELL_LOG ]] || fail "restarts skip makes no shell call" "$(cat "$SHELL_LOG")"
[[ ! -s $STATE_LOG ]] || fail "restarts skip clears no marker" "$(cat "$STATE_LOG")"
grep -q 'Skipping service restarts (--restarts=skip)' "$test_tmp/skip.out" || fail "restarts skip reports summary" "$(cat "$test_tmp/skip.out")"
grep -q 'Shell restart deferred' "$test_tmp/skip.out" || fail "restarts skip defers shell" "$(cat "$test_tmp/skip.out")"
pass "restarts skip retains markers without restart calls"

# restarts=run: failing service keeps marker, later services attempted, nonzero.
reset_logs
clear_reboot_markers
mkdir -p "$test_home/.local/state/omarchy"
touch "$test_home/.local/state/omarchy/restart-audio-required"
touch "$test_home/.local/state/omarchy/restart-trackpad-required"
set +e
export OMARCHY_UPDATE_REBOOT="never"
unset OMARCHY_UPDATE_UNATTENDED
export OMARCHY_UPDATE_RESTARTS="run"
export TEST_RUNNING_KERNEL="$existing_kernel"
export TEST_PGREP_MODE="none"
export TEST_HYPRLAND_DELETED="0"
export TEST_GUM_EXIT="99"
export TEST_RESTART_AUDIO_EXIT="3"
export TEST_RESTART_TRACKPAD_EXIT="0"
HOME="$test_home" PATH="$stub_bin:$PATH" "$ROOT/bin/omarchy-update-restart" >"$test_tmp/run-fail.out" 2>"$test_tmp/run-fail.err"
run_fail_status=$?
set -e
(( run_fail_status != 0 )) || fail "restarts run failure exits nonzero" "got 0"
grep -q 'audio' "$RESTART_LOG" || fail "restarts run attempts failing service" "$(cat "$RESTART_LOG")"
grep -q 'trackpad' "$RESTART_LOG" || fail "restarts run continues to later service" "$(cat "$RESTART_LOG")"
[[ -f $test_home/.local/state/omarchy/restart-audio-required ]] || fail "restarts run keeps failing marker"
[[ ! -f $test_home/.local/state/omarchy/restart-trackpad-required ]] || fail "restarts run clears succeeding marker"
grep -q 'clear.*restart-trackpad-required' "$STATE_LOG" || fail "restarts run clears only after success" "$(cat "$STATE_LOG")"
grep -q 'clear.*restart-audio-required' "$STATE_LOG" && fail "restarts run does not clear failing marker" "$(cat "$STATE_LOG")"
grep -q 'failed to restart audio' "$test_tmp/run-fail.err" || fail "restarts run reports failure" "$(cat "$test_tmp/run-fail.err")"
(( $(grep -c '^shell' "$SHELL_LOG") == 1 )) || fail "restarts run still restarts shell after failure" "$(cat "$SHELL_LOG")"
pass "restarts run clears only after success and fails nonzero"

# Shell restart still runs when restarts=run even with no markers.
reset_logs
clear_reboot_markers
clear_restart_markers
set +e
export OMARCHY_UPDATE_REBOOT="never"
unset OMARCHY_UPDATE_UNATTENDED
export OMARCHY_UPDATE_RESTARTS="run"
export TEST_RUNNING_KERNEL="$existing_kernel"
export TEST_PGREP_MODE="none"
export TEST_HYPRLAND_DELETED="0"
export TEST_GUM_EXIT="99"
export TEST_RESTART_AUDIO_EXIT="0"
export TEST_RESTART_TRACKPAD_EXIT="0"
HOME="$test_home" PATH="$stub_bin:$PATH" "$ROOT/bin/omarchy-update-restart" >"$test_tmp/shell.out" 2>"$test_tmp/shell.err"
shell_status=$?
set -e
(( shell_status == 0 )) || fail "shell restart with no markers exits 0" "got $shell_status"
(( $(grep -c '^shell' "$SHELL_LOG") == 1 )) || fail "shell restart runs with no markers" "$(cat "$SHELL_LOG")"
grep -q 'Restarting shell' "$test_tmp/shell.out" || fail "shell restart prints message" "$(cat "$test_tmp/shell.out")"
pass "shell restart still runs with no markers"

# Invalid reboot policy exits 2 with no side effects.
reset_logs
mkdir -p "$test_home/.local/state/omarchy"
touch "$test_home/.local/state/omarchy/reboot-required"
touch "$test_home/.local/state/omarchy/restart-audio-required"
set +e
export OMARCHY_UPDATE_REBOOT="bogus"
unset OMARCHY_UPDATE_UNATTENDED
export OMARCHY_UPDATE_RESTARTS="run"
export TEST_RUNNING_KERNEL="0.0.0-fake-no-match"
export TEST_PGREP_MODE="present"
export TEST_HYPRLAND_DELETED="1"
export TEST_GUM_EXIT="0"
HOME="$test_home" PATH="$stub_bin:$PATH" "$ROOT/bin/omarchy-update-restart" >"$test_tmp/invalid-reboot.out" 2>"$test_tmp/invalid-reboot.err"
invalid_reboot_status=$?
set -e
(( invalid_reboot_status == 2 )) || fail "invalid reboot exits 2" "got $invalid_reboot_status"
[[ ! -s $GUM_LOG ]] || fail "invalid reboot does not call gum" "$(cat "$GUM_LOG")"
[[ ! -s $SUDO_LOG ]] || fail "invalid reboot does not call sudo" "$(cat "$SUDO_LOG")"
[[ ! -s $REBOOT_LOG ]] || fail "invalid reboot does not reboot" "$(cat "$REBOOT_LOG")"
[[ ! -s $RESTART_LOG ]] || fail "invalid reboot makes no restart calls" "$(cat "$RESTART_LOG")"
[[ -f $test_home/.local/state/omarchy/reboot-required ]] || fail "invalid reboot keeps markers"
[[ -f $test_home/.local/state/omarchy/restart-audio-required ]] || fail "invalid reboot keeps restart markers"
pass "invalid reboot exits 2 without side effects"

# Invalid restarts policy exits 2 with no side effects.
reset_logs
clear_reboot_markers
rm -f "$test_home/.local/state/omarchy/restart-audio-required"
touch "$test_home/.local/state/omarchy/restart-trackpad-required"
set +e
export OMARCHY_UPDATE_REBOOT="never"
unset OMARCHY_UPDATE_UNATTENDED
export OMARCHY_UPDATE_RESTARTS="bogus"
export TEST_RUNNING_KERNEL="$existing_kernel"
export TEST_PGREP_MODE="none"
export TEST_HYPRLAND_DELETED="0"
HOME="$test_home" PATH="$stub_bin:$PATH" "$ROOT/bin/omarchy-update-restart" >"$test_tmp/invalid-restarts.out" 2>"$test_tmp/invalid-restarts.err"
invalid_restarts_status=$?
set -e
(( invalid_restarts_status == 2 )) || fail "invalid restarts exits 2" "got $invalid_restarts_status"
[[ ! -s $GUM_LOG ]] || fail "invalid restarts does not call gum" "$(cat "$GUM_LOG")"
[[ ! -s $RESTART_LOG ]] || fail "invalid restarts makes no restart calls" "$(cat "$RESTART_LOG")"
[[ ! -s $SHELL_LOG ]] || fail "invalid restarts makes no shell call" "$(cat "$SHELL_LOG")"
[[ -f $test_home/.local/state/omarchy/restart-trackpad-required ]] || fail "invalid restarts keeps markers"
pass "invalid restarts exits 2 without side effects"

# Stale env documents value-only behavior: UNATTENDED=1 reports, unset prompts.
reset_logs
clear_reboot_markers
clear_restart_markers
set +e
export OMARCHY_UPDATE_REBOOT="ask"
export OMARCHY_UPDATE_UNATTENDED="1"
export OMARCHY_UPDATE_RESTARTS="run"
export TEST_RUNNING_KERNEL="0.0.0-fake-no-match"
export TEST_PGREP_MODE="none"
export TEST_HYPRLAND_DELETED="0"
export TEST_GUM_EXIT="99"
HOME="$test_home" PATH="$stub_bin:$PATH" "$ROOT/bin/omarchy-update-restart" >"$test_tmp/stale-set.out" 2>"$test_tmp/stale-set.err"
stale_set_status=$?
set -e
(( stale_set_status == 0 )) || fail "stale UNATTENDED=1 exits 0" "got $stale_set_status"
[[ ! -s $GUM_LOG ]] || fail "stale UNATTENDED=1 does not call gum" "$(cat "$GUM_LOG")"
grep -q 'Reboot required:' "$test_tmp/stale-set.out" || fail "stale UNATTENDED=1 reports need" "$(cat "$test_tmp/stale-set.out")"
reset_logs
set +e
export OMARCHY_UPDATE_REBOOT="ask"
unset OMARCHY_UPDATE_UNATTENDED
export TEST_GUM_EXIT="1"
HOME="$test_home" PATH="$stub_bin:$PATH" "$ROOT/bin/omarchy-update-restart" </dev/null >"$test_tmp/stale-unset.out" 2>"$test_tmp/stale-unset.err"
stale_unset_status=$?
set -e
# Headless without TTY reports even when unset; interactive PTY covered above.
(( stale_unset_status == 0 )) || fail "unset UNATTENDED headless exits 0" "got $stale_unset_status"
[[ ! -s $GUM_LOG ]] || fail "unset UNATTENDED headless does not call gum without TTY" "$(cat "$GUM_LOG")"
grep -q 'Reboot required:' "$test_tmp/stale-unset.out" || fail "unset UNATTENDED headless reports without TTY" "$(cat "$test_tmp/stale-unset.out")"
pass "stale UNATTENDED keys on value only without speculative reject"

unset OMARCHY_UPDATE_REBOOT
unset OMARCHY_UPDATE_RESTARTS
unset OMARCHY_UPDATE_UNATTENDED
unset OMARCHY_PATH
