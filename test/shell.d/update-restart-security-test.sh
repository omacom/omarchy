#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/fixtures/sudo-boundary-test.sh"
rm "$SUDO_TEST_ROOT/bin/omarchy-update-restart"
copy_boundary_file bin/omarchy-update-restart

services=(audio bluetooth btop helix herdr hyprctl hyprsunset opencode shell terminal tmux trackpad wifi xcompose)
for service in "${services[@]}"; do
  cp "$SUDO_TEST_ROOT/bin/test-step" "$SUDO_TEST_ROOT/bin/omarchy-restart-$service"
done
cp "$SUDO_TEST_ROOT/bin/test-step" "$SUDO_TEST_ROOT/bin/omarchy-system-reboot"
cat >"$SUDO_TEST_ROOT/bin/gum" <<'STUB'
#!/bin/bash
printf 'prompt:%s\n' "$*" >>"$SUDO_TEST_LOG"
[[ ${SUDO_TEST_CONFIRM:-0} == "1" ]]
STUB
chmod +x "$SUDO_TEST_ROOT/bin/gum"

state_dir="$SUDO_TEST_HOME/.local/state/omarchy"
mkdir -p "$state_dir"
run_restart() {
  "$SUDO_TEST_ROOT/bin/omarchy-update-restart" "$@" >"$boundary_tmp/output" 2>&1
}
reset_restart() {
  reset_boundary
  rm -rf "$state_dir"
  mkdir -p "$state_dir"
}
assert_no_step() {
  if grep -Eq '^step:omarchy-(restart-|system-reboot)' "$SUDO_TEST_LOG"; then
    fail "$1 ran a restart or reboot" "$(<"$SUDO_TEST_LOG")"
  fi
}

for service in "${services[@]}"; do
  reset_restart
  touch "$state_dir/restart-$service-required" "$SUDO_TEST_CACHE"
  run_restart --services-only || fail "$service restart failed" "$(<"$boundary_tmp/output")"
  [[ $(grep -c "^step:omarchy-restart-$service " "$SUDO_TEST_LOG") == "1" ]] || fail "$service did not restart exactly once"
  [[ ! -e $state_dir/restart-$service-required ]] || fail "$service left a completed marker"
  assert_boundary_cold "$service restart"
  pass "the $service marker selects its supported command once and finishes cold"
done

# These are harmless fixture names and logging commands. No real sudo or
# restart helpers run, and no vulnerable baseline or privilege proof is used.
reset_restart
for service in custom app gum sshd 'two words' '[wifi]' $'line\nbreak'; do
  touch "$state_dir/restart-$service-required"
done
cp "$SUDO_TEST_ROOT/bin/test-step" "$SUDO_TEST_ROOT/bin/omarchy-restart-custom"
run_restart --services-only || fail "unsupported markers blocked ordinary restart handling"
[[ $(grep -c '^step:' "$SUDO_TEST_LOG") == "1" ]] || fail "unsupported markers dispatched a command"
[[ -z $(ls -A "$state_dir") ]] || fail "unsupported markers were not removed"
grep -Fq 'line\nbreak' "$boundary_tmp/output" || fail "marker diagnostics did not escape a newline"
pass "unsupported marker names are removed without dispatch and are safely printed"

reset_restart
mkdir "$boundary_tmp/user-bin"
cp "$SUDO_TEST_ROOT/bin/test-step" "$boundary_tmp/user-bin/omarchy-restart-bluetooth"
sed -i 's/step:/user-path:/' "$boundary_tmp/user-bin/omarchy-restart-bluetooth"
touch "$state_dir/restart-bluetooth-required"
PATH="$boundary_tmp/user-bin:$PATH" run_restart --services-only || fail "a custom user PATH broke supported restarts"
if grep -q '^user-path:' "$SUDO_TEST_LOG"; then fail "restart resolution used the caller PATH"; fi
grep -q '^step:omarchy-restart-bluetooth ' "$SUDO_TEST_LOG" || fail "the fixed restart command did not run"
pass "a supported marker uses the installation command regardless of caller PATH"

for availability in missing non-executable symlink; do
  reset_restart
  rm "$SUDO_TEST_ROOT/bin/omarchy-restart-bluetooth"
  case "$availability" in
    non-executable) cp "$SUDO_TEST_ROOT/bin/test-step" "$SUDO_TEST_ROOT/bin/omarchy-restart-bluetooth"; chmod -x "$SUDO_TEST_ROOT/bin/omarchy-restart-bluetooth" ;;
    symlink) ln -s test-step "$SUDO_TEST_ROOT/bin/omarchy-restart-bluetooth" ;;
  esac
  touch "$state_dir/restart-bluetooth-required"
  run_restart --services-only || fail "$availability helper blocked the shell refresh"
  [[ ! -e $state_dir/restart-bluetooth-required ]] || fail "$availability helper left an unavailable marker"
  if grep -q '^step:omarchy-restart-bluetooth ' "$SUDO_TEST_LOG"; then fail "$availability helper was dispatched"; fi
  rm -f "$SUDO_TEST_ROOT/bin/omarchy-restart-bluetooth"
  cp "$SUDO_TEST_ROOT/bin/test-step" "$SUDO_TEST_ROOT/bin/omarchy-restart-bluetooth"
  pass "a $availability checkout helper is not dispatched"
done

reset_restart
touch "$boundary_tmp/target"
ln -s "$boundary_tmp/target" "$state_dir/restart-bluetooth-required"
mkfifo "$state_dir/restart-wifi-required"
mkdir "$state_dir/restart-trackpad-required"
run_restart --services-only || fail "non-regular markers blocked restart handling"
[[ $(grep -c '^step:' "$SUDO_TEST_LOG") == "1" ]] || fail "a non-regular marker selected a restart"
[[ -f $boundary_tmp/target && -L $state_dir/restart-bluetooth-required ]] || fail "marker handling followed or deleted a symlink"
pass "symlink, FIFO and directory entries cannot select a restart"

for service in bluetooth shell; do
  reset_restart
  touch "$state_dir/restart-$service-required"
  SUDO_TEST_FAIL_STEP="omarchy-restart-$service" run_restart --services-only || fail "optional restart failure aborted the update"
  [[ -f $state_dir/restart-$service-required ]] || fail "failed $service restart lost its retry marker"
  assert_boundary_cold "failed $service restart"
  run_restart --services-only || fail "retrying $service failed"
  [[ ! -e $state_dir/restart-$service-required ]] || fail "successful $service retry kept its marker"
  pass "a failed $service restart preserves its marker until a successful retry"
done

reset_restart
cat >"$SUDO_TEST_ROOT/bin/omarchy-restart-trackpad" <<'STUB'
#!/bin/bash
printf 'step:omarchy-restart-trackpad \n' >>"$SUDO_TEST_LOG"
if [[ -n ${SUDO_TEST_SEND_SIGNAL:-} ]]; then
  kill -s "$SUDO_TEST_SEND_SIGNAL" "$PPID"
else
  sudo /usr/bin/true
fi
STUB
chmod +x "$SUDO_TEST_ROOT/bin/omarchy-restart-trackpad"
touch "$state_dir/restart-trackpad-required" "$SUDO_TEST_CACHE"
run_restart --services-only || fail "command-scoped restart authorization failed"
grep -q '^sudo -N /usr/bin/true$' "$SUDO_TEST_LOG" || fail "restart helpers did not inherit no-update sudo"
assert_boundary_cold "privileged restart fixture"
pass "standalone restart handling uses command-scoped authorization for its helpers"

for signal in HUP INT TERM; do
  reset_restart
  touch "$state_dir/restart-trackpad-required"
  if SUDO_TEST_SEND_SIGNAL="$signal" run_restart --services-only; then fail "$signal did not stop restart handling"; fi
  [[ -f $state_dir/restart-trackpad-required ]] || fail "$signal lost the unfinished restart marker"
  assert_boundary_cold "$signal interruption"
  pass "$signal exits cold and preserves the unfinished restart marker"
done

for refusal in unsupported-sudo failed-revocation mismatched-root relative-root ordinary-bash extra-argument; do
  reset_restart
  touch "$state_dir/restart-bluetooth-required"
  status=0
  case "$refusal" in
    unsupported-sudo) SUDO_TEST_UNSUPPORTED=1 run_restart --services-only || status=$? ;;
    failed-revocation) SUDO_TEST_REVOKE_FAIL=1 run_restart --services-only || status=$? ;;
    mismatched-root) OMARCHY_PATH="$boundary_tmp" run_restart --services-only || status=$? ;;
    relative-root) OMARCHY_PATH=. run_restart --services-only || status=$? ;;
    ordinary-bash) /usr/bin/bash "$SUDO_TEST_ROOT/bin/omarchy-update-restart" -p >"$boundary_tmp/output" 2>&1 || status=$? ;;
    extra-argument) run_restart --services-only unexpected || status=$? ;;
  esac
  (( status != 0 )) || fail "$refusal was accepted"
  assert_no_step "$refusal"
  [[ -f $state_dir/restart-bluetooth-required ]] || fail "$refusal consumed a marker"
  pass "$refusal is rejected before restart dispatch"
done

reset_restart
printf '%s\n' 'printf startup-ran >>"$SUDO_TEST_ROOT/startup-marker"' >"$boundary_tmp/startup"
touch "$state_dir/restart-bluetooth-required"
BASH_ENV="$boundary_tmp/startup" ENV="$boundary_tmp/startup" run_restart --services-only || fail "restart startup sanitation failed"
[[ ! -e $SUDO_TEST_ROOT/startup-marker ]] || fail "startup code reached a restart helper"
assert_boundary_cold "sanitized restart"
pass "inherited startup files do not run in restart handling or its helpers"

reset_restart
mkdir "$boundary_tmp/restart-links"
ln -s "$SUDO_TEST_ROOT/bin/omarchy-update-restart" "$boundary_tmp/restart-links/omarchy-update-restart"
printf '%s\n' 'touch "$SUDO_TEST_HOME/wrong-library"' >"$boundary_tmp/restart-links/omarchy-security-functions"
touch "$state_dir/restart-bluetooth-required"
"$boundary_tmp/restart-links/omarchy-update-restart" --services-only >"$boundary_tmp/output" 2>&1 || fail "symlink invocation failed"
[[ ! -e $SUDO_TEST_HOME/wrong-library ]] || fail "restart handling sourced a library beside its invocation link"
[[ ! -e $state_dir/restart-bluetooth-required ]] || fail "symlink invocation did not run the supported restart"
assert_boundary_cold "symlinked restart command"
pass "symlink invocation loads the library beside the canonical restart command"

for mode in all --reboot-only; do
  reset_restart
  touch "$state_dir/restart-bluetooth-required" "$state_dir/reboot-required"
  run_restart "$mode" || fail "declining a reboot failed restart handling"
  if [[ $mode == "all" ]]; then
    [[ ! -e $state_dir/restart-bluetooth-required ]] || fail "combined mode skipped services after a declined reboot"
    python3 - "$SUDO_TEST_LOG" <<'PY'
import sys
events = open(sys.argv[1]).read().splitlines()
prompt = next(i for i, event in enumerate(events) if event.startswith('prompt:'))
assert any(event.startswith('step:omarchy-restart-') for event in events[:prompt]), events
assert not any(event.startswith(('step:omarchy-restart-', 'sudo -N ')) for event in events[prompt:]), events
PY
  else
    [[ -f $state_dir/restart-bluetooth-required ]] || fail "reboot-only consumed a service marker"
    assert_no_step "declined reboot-only"
  fi
  assert_boundary_cold "$mode phase"
  pass "$mode preserves service/reboot ordering when reboot is declined"
done

reset_restart
touch "$state_dir/reboot-required" "$state_dir/restart-bluetooth-required"
SUDO_TEST_CONFIRM=1 run_restart --reboot-only || fail "confirmed reboot was not dispatched"
grep -q '^step:omarchy-system-reboot ' "$SUDO_TEST_LOG" || fail "confirmed reboot did not call its fixed helper"
[[ -f $state_dir/restart-bluetooth-required ]] || fail "reboot-only processed service markers"
assert_boundary_cold "confirmed reboot"
pass "confirmed reboot calls its fixed helper and performs no service restart"

# Exercise the real updater and restart dispatcher together. Package actions,
# prompts and component restarts remain harmless fixture commands.
reset_restart
copy_boundary_file bin/omarchy-update
touch "$state_dir/restart-bluetooth-required" "$state_dir/restart-custom-required"
OMARCHY_UPDATE_LOGGED=1 "$SUDO_TEST_ROOT/bin/omarchy-update" -y >"$boundary_tmp/output" 2>&1 ||
  fail "the updater could not complete with real restart handling" "$(<"$boundary_tmp/output")"
[[ ! -e $state_dir/restart-custom-required ]] || fail "the updater retained an unsupported marker"
python3 - "$SUDO_TEST_LOG" <<'PY'
import sys
events = open(sys.argv[1]).read().splitlines()
restart = next(i for i, event in enumerate(events) if event.startswith('step:omarchy-restart-bluetooth '))
shell = next(i for i, event in enumerate(events) if event.startswith('step:omarchy-restart-shell '))
hook = next(i for i, event in enumerate(events) if event.startswith('step:omarchy-hook '))
mise = next(i for i, event in enumerate(events) if event.startswith('step:omarchy-update-mise '))
assert restart < shell < hook < mise, events
assert not any(event.startswith(('step:omarchy-restart-', 'sudo -N ')) for event in events[hook:]), events
assert not any(event.startswith('step:omarchy-restart-custom ') for event in events), events
PY
assert_boundary_cold "the complete update/restart fixture"
pass "the real updater handles markers before hooks/mise and performs no later service or authorization work"
