#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/fixtures/sudo-boundary-test.sh"
copy_boundary_file bin/omarchy-update
copy_boundary_file bin/omarchy-refresh-pacman
# Replace the step symlink, preserving the real fixture dispatcher.
rm "$SUDO_TEST_ROOT/bin/omarchy-update-aur-pkgs"
copy_boundary_file bin/omarchy-update-aur-pkgs
export OMARCHY_UPDATE_LOGGED=1

run_update() {
  "$SUDO_TEST_ROOT/bin/omarchy-update" "$@" >"$boundary_tmp/output" 2>&1
}

for args in '-y' ''; do
  reset_boundary
  touch "$SUDO_TEST_CACHE"
  run_update $args || fail "update failed" "$(<"$boundary_tmp/output")"
  assert_boundary_cold "successful update"
  grep -q '^sudo -N /usr/bin/true$' "$SUDO_TEST_LOG" || fail "update package helpers must use no-update sudo"
  python3 - "$SUDO_TEST_LOG" <<'PY'
import sys
s=open(sys.argv[1]).read().splitlines()
positions=[next(i for i,line in enumerate(s) if line.startswith(prefix)) for prefix in ['step:omarchy-update-restart --services-only','step:yay','step:omarchy-hook post-update','step:omarchy-update-mise','step:omarchy-update-stay-awake stop','step:omarchy-update-restart --reboot-only']]
assert positions==sorted(positions), s
assert not any(line.startswith('sudo -N ') for line in s[positions[2]:]), s
PY
  pass "update $args runs privileged phases before hooks and exits cold"
done

for step in omarchy-update-system-pkgs yay omarchy-hook omarchy-update-mise; do
  reset_boundary
  export SUDO_TEST_FAIL_STEP=$step
  if run_update -y; then fail "$step failure must fail the update"; fi
  assert_boundary_cold "failed $step"
  python3 - "$SUDO_TEST_LOG" <<'PY'
import sys
s=open(sys.argv[1]).read().splitlines()
for i,line in enumerate(s):
 if line=='step:omarchy-update-stay-awake stop': assert i>0 and s[i-1]=='sudo -k',s
PY
  pass "update revokes credentials after $step fails"
done

reset_boundary
export SUDO_TEST_SIGNAL_STEP=omarchy-hook
if run_update -y; then fail "interrupted update must fail"; fi
assert_boundary_cold "interrupted update"
pass "update revokes credentials on TERM"

reset_boundary
export SUDO_TEST_REVOKE_FAIL=1
if run_update -y; then fail "failed initial revocation must fail the update"; fi
if grep -q '^step:' "$SUDO_TEST_LOG"; then fail "failed revocation must precede update work"; fi
pass "a failed cold start prevents update work"

reset_boundary
export SUDO_TEST_UNSUPPORTED=1
if run_update -y; then fail "unsupported sudo must prevent mixed-trust work"; fi
assert_boundary_cold "unsupported sudo"
pass "unsupported sudo fails without running update steps"

reset_boundary
"$SUDO_TEST_ROOT/bin/omarchy-refresh-pacman" stable >"$boundary_tmp/output" 2>&1 || fail "refresh failed" "$(<"$boundary_tmp/output")"
assert_boundary_cold "refresh"
python3 - "$SUDO_TEST_LOG" <<'PY'
import sys
s=open(sys.argv[1]).read().splitlines()
hook=next(i for i,l in enumerate(s) if l=='step:omarchy-hook pre-refresh-pacman')
copies=[i for i,l in enumerate(s) if l.startswith('sudo -N cp ')]
transaction=next(i for i,l in enumerate(s) if l.startswith('step:pacman '))
assert len(copies)==4 and max(copies) < hook < transaction, s
assert s[hook-1]=='sudo -k' and s[hook+1]=='sudo -k', s
assert all(l in ('sudo -h','sudo -k') or l.startswith('sudo -N ') for l in s if l.startswith('sudo ')), s
PY
pass "refresh runs the hook cold between the config re-sync and the transaction"

for step in pacman omarchy-hook; do
  reset_boundary
  export SUDO_TEST_FAIL_STEP=$step
  if "$SUDO_TEST_ROOT/bin/omarchy-refresh-pacman" stable >"$boundary_tmp/output" 2>&1; then fail "refresh must propagate $step failure"; fi
  assert_boundary_cold "failed refresh $step"
  pass "refresh revokes after $step failure"
done

# The wrapper must preserve sudo's own option parser, including validation and
# explicit --, while standalone timestamp maintenance cannot be combined with N.
for args in '-v' '-n /usr/bin/true' '--user test -- /usr/bin/true' '-- /usr/bin/true' '-k' '-K'; do
  reset_boundary
  "$SUDO_TEST_ROOT/default/omarchy/sudo-no-update/sudo" $args
  case "$args" in
    -k|-K) expected="sudo $args" ;;
    *) expected="sudo -N $args" ;;
  esac
  [[ $(<"$SUDO_TEST_LOG") == "$expected" ]] || fail "wrapper changed options: $args" "$(<"$SUDO_TEST_LOG")"
  [[ ! -e $SUDO_TEST_CACHE ]] || fail "wrapper refreshed credentials"
  pass "sudo wrapper preserves $args"
done

for script in bin/omarchy-update bin/omarchy-refresh-pacman default/omarchy/sudo-no-update/sudo; do
  reset_boundary
  if /usr/bin/bash "$SUDO_TEST_ROOT/$script" -p >"$boundary_tmp/output" 2>&1; then fail "$script accepted an ordinary Bash launch"; fi
  [[ ! -s $SUDO_TEST_LOG ]] || fail "$script reached sudo through an invalid interpreter"
  pass "$script rejects a decoy privileged-mode argument"
done

reset_boundary
printf '%s\n' 'printf startup-ran >>"$SUDO_TEST_ROOT/startup-marker"' >"$boundary_tmp/startup"
BASH_ENV="$boundary_tmp/startup" ENV="$boundary_tmp/startup" run_update -y || fail "sanitized update failed" "$(<"$boundary_tmp/output")"
[[ ! -e $SUDO_TEST_ROOT/startup-marker ]] || fail "startup code leaked into an update helper"
pass "inherited startup files do not run in the updater or its child scripts"

reset_boundary
function printf() { /usr/bin/touch "$SUDO_TEST_ROOT/function-marker"; }
export -f printf
run_update -y || fail "update failed with inherited function" "$(<"$boundary_tmp/output")"
unset -f printf
[[ ! -e $SUDO_TEST_ROOT/function-marker ]] || fail "an inherited function reached an update helper"
pass "exported functions do not reach update helper interpreters"
