#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/fixtures/sudo-boundary-test.sh"
copy_boundary_file bin/omarchy-channel-set
copy_boundary_file bin/omarchy-refresh-pacman
copy_boundary_file bin/omarchy-update
export OMARCHY_UPDATE_LOGGED=1

# Relocate the package root into the fixture, including the explicit handoff
# from the development checkout. All privileged operations remain stand-ins.
python3 - "$SUDO_TEST_ROOT/bin/omarchy-channel-set" "$SUDO_TEST_ROOT" <<'PY'
import sys
from pathlib import Path
p = Path(sys.argv[1])
p.write_text(p.read_text().replace('/usr/share/omarchy', sys.argv[2]))
PY

for command in omarchy-dev-link omarchy-dev-unlink omarchy-state gum git; do
  cat >"$SUDO_TEST_ROOT/bin/$command" <<'STUB'
#!/bin/bash
set -euo pipefail
step=${0##*/}
printf 'step:%s %s\n' "$step" "$*" >>"$SUDO_TEST_LOG"
case "$step" in
  omarchy-dev-link|omarchy-dev-unlink) sudo /usr/bin/true ;;
  git)
    [[ $1 == "clone" ]] || exit 90
    /usr/bin/cp -a "$SUDO_TEST_ROOT" "${@: -1}"
    mkdir -p "${@: -1}/.git" "${@: -1}/shell"
    ;;
esac
STUB
  chmod +x "$SUDO_TEST_ROOT/bin/$command"
done

assert_scoped_channel() {
  local label=$1
  assert_boundary_cold "$label"
  python3 - "$SUDO_TEST_LOG" <<'PY'
import sys
events = open(sys.argv[1]).read().splitlines()
assert events[0] == 'sudo -k', events
sudo = [event for event in events if event.startswith('sudo ')]
assert all(event in ('sudo -h', 'sudo -k') or event.startswith('sudo -N ') for event in sudo), events
hooks = [i for i, event in enumerate(events) if event.startswith('step:omarchy-hook ')]
assert len(hooks) == 2, events
assert events[hooks[0]] == 'step:omarchy-hook pre-refresh-pacman', events
assert events[hooks[1]] == 'step:omarchy-hook post-update', events
assert events[hooks[0] - 1] == 'sudo -k' and events[hooks[0] + 1] == 'sudo -k', events
transaction = next(i for i, event in enumerate(events) if event.startswith('step:pacman '))
assert hooks[0] < transaction, events
assert not any(event.startswith('sudo -N ') for event in events[hooks[1]:]), events
PY
}

run_channel() {
  "$OMARCHY_PATH/bin/omarchy-channel-set" "$@" >"$boundary_tmp/output" 2>&1
}
for channel in stable rc edge dev; do
  reset_boundary
  run_channel "$channel" || fail "$channel failed" "$(<"$boundary_tmp/output")"
  assert_scoped_channel "$channel"
  pass "$channel starts cold, authorizes only individual commands, runs the refresh hook cold before its transaction and exits cold"
done

reset_boundary
wrapper="$SUDO_TEST_HOME/omarchy/default/omarchy/sudo-no-update/sudo"
mv "$wrapper" "$boundary_tmp/saved-wrapper"
if run_channel dev; then fail "an old checkout without the wrapper was accepted"; fi
if grep -Eq '^step:omarchy-(dev-link|state)|^sudo -N ' "$SUDO_TEST_LOG"; then
  fail "an incompatible dev checkout changed the system before rejection"
fi
grep -q 'Update the checkout before switching to dev' "$boundary_tmp/output" || fail "stale checkout rejection lacks recovery guidance"
assert_boundary_cold "stale checkout"
mv "$boundary_tmp/saved-wrapper" "$wrapper"
pass "a stale dev checkout is rejected before linking or privileged work"

reset_boundary
OMARCHY_PATH="$SUDO_TEST_HOME/omarchy" run_channel stable || fail "leaving dev failed" "$(<"$boundary_tmp/output")"
assert_scoped_channel "dev to stable"
pass "leaving dev preserves no-update sudo through unlink and the packaged update"

# A packaged destination that predates the wrapper cannot be checked before its
# package is installed. Its updater authenticates without --no-update, so the
# switch must not launch it: it stops at a consistent point with instructions.
reset_boundary
mv "$SUDO_TEST_ROOT/default/omarchy/sudo-no-update/sudo" "$boundary_tmp/saved-package-wrapper"
mv "$SUDO_TEST_ROOT/bin/omarchy-update" "$boundary_tmp/saved-package-update"
ln -s test-step "$SUDO_TEST_ROOT/bin/omarchy-update"
if OMARCHY_PATH="$SUDO_TEST_HOME/omarchy" run_channel stable; then fail "an older packaged destination was updated with ordinary sudo" "$(<"$SUDO_TEST_LOG")"; fi
grep -q "predates command-scoped sudo" "$boundary_tmp/output" || fail "an older packaged destination was not reported" "$(<"$boundary_tmp/output")"
grep -q "Run 'omarchy update' from a new terminal to finish" "$boundary_tmp/output" || fail "an older packaged destination lacks recovery guidance" "$(<"$boundary_tmp/output")"
grep -Fxq 'step:omarchy-dev-unlink --no-reboot' "$SUDO_TEST_LOG" || fail "the package switch was not completed before stopping" "$(<"$SUDO_TEST_LOG")"
grep -Fxq 'step:omarchy-state set reboot-required' "$SUDO_TEST_LOG" || fail "leaving dev for an older release did not mark the reboot" "$(<"$SUDO_TEST_LOG")"
if grep -q '^step:omarchy-update ' "$SUDO_TEST_LOG"; then fail "an older packaged updater was launched from the hardened switch" "$(<"$SUDO_TEST_LOG")"; fi
grep -q 'The channel switch did not complete' "$boundary_tmp/output" && fail "the stop was reported as an error needing a rerun" "$(<"$boundary_tmp/output")"
assert_boundary_cold "older packaged destination"
rm "$SUDO_TEST_ROOT/bin/omarchy-update"
mv "$boundary_tmp/saved-package-update" "$SUDO_TEST_ROOT/bin/omarchy-update"
mv "$boundary_tmp/saved-package-wrapper" "$SUDO_TEST_ROOT/default/omarchy/sudo-no-update/sudo"
pass "an older packaged destination stops the switch cold with instructions instead of running its updater"

# A package-backed source can be downgraded by its own transaction to a release
# without the wrapper. From then on a bare sudo would be the real one, so no
# privileged step may follow either transaction without checking first. A decoy
# sudo in the package bin catches any such call instead of reaching the host.
cat >"$SUDO_TEST_ROOT/bin/sudo" <<'STUB'
#!/bin/bash
printf 'unwrapped-sudo %s\n' "$*" >>"$SUDO_TEST_LOG"
exit 97
STUB
chmod +x "$SUDO_TEST_ROOT/bin/sudo"
cp "$SUDO_TEST_ROOT/default/omarchy/sudo-no-update/sudo" "$boundary_tmp/saved-package-wrapper"
for pattern in 'pacman -Syyuu*' 'pacman -S --needed*'; do
  reset_boundary
  export SUDO_TEST_REMOVE_WRAPPER_STEP=$pattern
  if run_channel rc; then fail "a downgrade during '$pattern' was not detected" "$(<"$SUDO_TEST_LOG")"; fi
  unset SUDO_TEST_REMOVE_WRAPPER_STEP
  grep -q "predates command-scoped sudo" "$boundary_tmp/output" || fail "downgrade during '$pattern' was not reported" "$(<"$boundary_tmp/output")"
  if grep -q '^unwrapped-sudo ' "$SUDO_TEST_LOG"; then fail "downgrade during '$pattern' reached ordinary sudo" "$(<"$SUDO_TEST_LOG")"; fi
  if grep -q '^step:omarchy-dev-unlink' "$SUDO_TEST_LOG"; then fail "downgrade during '$pattern' still unlinked" "$(<"$SUDO_TEST_LOG")"; fi
  if grep -q '^step:omarchy-update ' "$SUDO_TEST_LOG"; then fail "downgrade during '$pattern' still updated" "$(<"$SUDO_TEST_LOG")"; fi
  python3 - "$SUDO_TEST_LOG" "$pattern" <<'PY'
import sys
events = open(sys.argv[1]).read().splitlines()
transactions = [e for e in events if e.startswith('step:pacman ')]
assert len(transactions) == (1 if sys.argv[2].startswith('pacman -Syyuu') else 2), events
assert all(e in ('sudo -h', 'sudo -k') or e.startswith('sudo -N ') for e in events if e.startswith('sudo ')), events
PY
  assert_boundary_cold "downgrade during $pattern"
  cp "$boundary_tmp/saved-package-wrapper" "$SUDO_TEST_ROOT/default/omarchy/sudo-no-update/sudo"
  pass "a transaction that removes the wrapper stops the switch before any further sudo ($pattern)"
done
rm "$SUDO_TEST_ROOT/bin/sudo"

mkdir "$boundary_tmp/user tools"
cat >"$boundary_tmp/user tools/channel-user-tool" <<'STUB'
#!/bin/bash
printf 'user-tool:%s\n' "$*" >>"$SUDO_TEST_LOG"
STUB
chmod +x "$boundary_tmp/user tools/channel-user-tool"
for command in omarchy-hook omarchy-update-mise; do
  rm "$SUDO_TEST_ROOT/bin/$command"
  cat >"$SUDO_TEST_ROOT/bin/$command" <<'STUB'
#!/bin/bash
[[ ! -e $SUDO_TEST_CACHE ]] || exit 91
[[ $(command -v sudo) == "$OMARCHY_PATH/default/omarchy/sudo-no-update/sudo" ]] || exit 92
channel-user-tool "${0##*/}" "$@"
STUB
  chmod +x "$SUDO_TEST_ROOT/bin/$command"
done
reset_boundary
PATH="$boundary_tmp/user tools:$PATH" run_channel stable || fail "channel hooks lost the user's PATH" "$(<"$boundary_tmp/output")"
for event in 'omarchy-hook post-update' 'omarchy-update-mise' 'omarchy-hook pre-refresh-pacman'; do
  grep -Fxq "user-tool:$event" "$SUDO_TEST_LOG" || fail "user PATH was not preserved for $event"
done
assert_boundary_cold "channel user PATH"
for command in omarchy-hook omarchy-update-mise; do
  ln -sfn test-step "$SUDO_TEST_ROOT/bin/$command"
done
pass "channel switching preserves user tools behind the wrapper for both hooks and mise"

for step in pacman omarchy-update-system-pkgs omarchy-hook; do
  reset_boundary
  if SUDO_TEST_FAIL_STEP="$step" run_channel stable; then fail "$step failure was ignored"; fi
  assert_boundary_cold "$step failure"
  if grep -q '^step:omarchy-hook post-update$' "$SUDO_TEST_LOG"; then fail "$step failure reached the post-update hook"; fi
  pass "$step failure exits cold without the post-update hook"
done

for signal in HUP INT TERM; do
  reset_boundary
  cat >"$SUDO_TEST_ROOT/bin/omarchy-dev-unlink" <<'STUB'
#!/bin/bash
sudo /usr/bin/true || exit 1
kill -s "$SUDO_TEST_CHANNEL_SIGNAL" "$PPID"
STUB
  if SUDO_TEST_CHANNEL_SIGNAL="$signal" run_channel stable; then fail "$signal was ignored"; fi
  assert_boundary_cold "$signal"
  if grep -q '^step:omarchy-hook post-update$' "$SUDO_TEST_LOG"; then fail "$signal reached the post-update hook"; fi
  pass "$signal stops the channel transition and revokes authorization"
done

for refusal in unsupported-sudo failed-revocation ordinary-bash; do
  reset_boundary
  case "$refusal" in
    unsupported-sudo) export SUDO_TEST_UNSUPPORTED=1 ;;
    failed-revocation) export SUDO_TEST_REVOKE_FAIL=1 ;;
  esac
  if [[ $refusal == "ordinary-bash" ]]; then
    if /usr/bin/bash "$SUDO_TEST_ROOT/bin/omarchy-channel-set" -p >"$boundary_tmp/output" 2>&1; then fail "$refusal was accepted"; fi
  elif run_channel stable; then
    fail "$refusal was accepted"
  fi
  if grep -q '^step:' "$SUDO_TEST_LOG"; then fail "$refusal reached channel work"; fi
  pass "$refusal is rejected before channel work"
done
