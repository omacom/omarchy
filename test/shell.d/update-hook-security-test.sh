#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/fixtures/sudo-boundary-test.sh"
copy_boundary_file bin/omarchy-update
copy_boundary_file bin/omarchy-refresh-pacman
copy_boundary_file bin/omarchy-apply-pacman
# Replace the step symlink, preserving the real fixture dispatcher.
rm "$SUDO_TEST_ROOT/bin/omarchy-update-aur-pkgs"
copy_boundary_file bin/omarchy-update-aur-pkgs
export OMARCHY_UPDATE_LOGGED=1

run_update() {
  "$SUDO_TEST_ROOT/bin/omarchy-update" "$@" >"$boundary_tmp/output" 2>&1
}

for args in '-y' ''; do
  reset_boundary
  run_update $args || fail "update failed" "$(<"$boundary_tmp/output")"
  python3 - "$SUDO_TEST_LOG" <<'PY'
import sys
s=open(sys.argv[1]).read().splitlines()
# The update authorizes exactly once before any step that could need sudo.
# Authorization runs a command (sudo -v prompts even with passwordless sudo).
prune=s.index('step:omarchy-update-pkg-prune ')
auth=s.index('sudo true')
assert auth < prune, s
assert [l for l in s[:prune] if l.startswith('sudo ')]==['sudo true'], s
assert 'sudo -v' not in s, s
positions=[next(i for i,line in enumerate(s) if line.startswith(prefix)) for prefix in ['step:omarchy-update-system-pkgs','step:omarchy-migrate','step:omarchy-update-restart --services-only','step:omarchy-hook post-update','step:omarchy-update-mise','step:yay','step:omarchy-update-stay-awake stop','step:omarchy-update-restart --reboot-only']]
assert positions==sorted(positions), s
yay=positions[5]
# Everything through AUR shares the one authorization (the stand-in exits 94
# if the hook, mise or yay found it gone), and nothing revokes it.
assert 'sudo -k' not in s, s
# Nothing after AUR authorizes again.
assert not any(line.startswith('sudo ') for line in s[yay:]), s
PY
  pass "update $args authorizes once for everything, AUR included"
done

for step in omarchy-update-system-pkgs yay omarchy-hook; do
  reset_boundary
  export SUDO_TEST_FAIL_STEP=$step
  if run_update -y; then fail "$step failure must fail the update"; fi
  grep -Fxq 'step:omarchy-update-stay-awake stop' "$SUDO_TEST_LOG" || fail "failed $step left the sleep inhibitor" "$(<"$SUDO_TEST_LOG")"
  if grep -q '^step:omarchy-update-restart --reboot-only' "$SUDO_TEST_LOG"; then fail "failed $step still offered a reboot"; fi
  pass "update stops after $step fails and releases the sleep inhibitor"
done

reset_boundary
export SUDO_TEST_SIGNAL_STEP=omarchy-hook
if run_update -y; then fail "interrupted update must fail"; fi
grep -Fxq 'step:omarchy-update-stay-awake stop' "$SUDO_TEST_LOG" || fail "an interrupted update left the sleep inhibitor" "$(<"$SUDO_TEST_LOG")"
pass "update stops on TERM and releases the sleep inhibitor"

reset_boundary
"$SUDO_TEST_ROOT/bin/omarchy-refresh-pacman" stable >"$boundary_tmp/output" 2>&1 || fail "refresh failed" "$(<"$boundary_tmp/output")"
python3 - "$SUDO_TEST_LOG" <<'PY'
import sys
s=open(sys.argv[1]).read().splitlines()
hook=next(i for i,l in enumerate(s) if l=='step:omarchy-hook pre-refresh-pacman')
copies=[i for i,l in enumerate(s) if l.startswith('sudo cp ')]
transaction=next(i for i,l in enumerate(s) if l.startswith('step:pacman '))
assert len(copies)==4 and max(copies) < hook < transaction, s
PY
pass "refresh runs the hook between the config re-sync and the transaction"

for step in pacman omarchy-hook; do
  reset_boundary
  export SUDO_TEST_FAIL_STEP=$step
  if "$SUDO_TEST_ROOT/bin/omarchy-refresh-pacman" stable >"$boundary_tmp/output" 2>&1; then fail "refresh must propagate $step failure"; fi
  if [[ $step == "omarchy-hook" ]] && grep -q '^step:pacman ' "$SUDO_TEST_LOG"; then fail "a failed hook still reached the transaction"; fi
  pass "refresh propagates $step failure"
done
