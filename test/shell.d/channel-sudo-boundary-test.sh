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
assert events[hooks[-1]] == 'step:omarchy-hook pre-refresh-pacman', events
assert not any(event.startswith('sudo -N ') for event in events[hooks[0]:]), events
PY
}

run_channel() {
  "$OMARCHY_PATH/bin/omarchy-channel-set" "$@" >"$boundary_tmp/output" 2>&1
}
for channel in stable rc edge dev; do
  reset_boundary
  run_channel "$channel" || fail "$channel failed" "$(<"$boundary_tmp/output")"
  assert_scoped_channel "$channel"
  pass "$channel starts cold, authorizes only individual commands, defers hooks and exits cold"
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
  if grep -q '^step:omarchy-hook pre-refresh-pacman$' "$SUDO_TEST_LOG"; then fail "$step failure reached the deferred hook"; fi
  pass "$step failure exits cold without the deferred hook"
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
  if grep -q '^step:omarchy-hook ' "$SUDO_TEST_LOG"; then fail "$signal reached an update hook"; fi
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
