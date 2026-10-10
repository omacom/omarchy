#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/fixtures/sudo-boundary-test.sh"
copy_boundary_file bin/omarchy-pkg-aur-install
rm "$SUDO_TEST_ROOT/bin/yay"

cat >"$SUDO_TEST_ROOT/bin/yay" <<'STUB'
#!/bin/bash
set -euo pipefail
[[ ! -e $SUDO_TEST_CACHE ]] || exit 91
if [[ $1 == "-Slqa" ]]; then
  printf '%s\n' audit-one audit-two
  exit 0
fi
[[ $(command -v sudo) == "$OMARCHY_PATH/default/omarchy/sudo-no-update/sudo" ]] || exit 92
[[ -z ${OMARCHY_UPDATE_SUDO_SESSION+x} ]] || exit 95
[[ $1 == "--sudo" && $2 == "$OMARCHY_PATH/default/omarchy/sudo-no-update/sudo" && $3 == "--sudoloop=false" ]] || exit 93
shift 3
printf '%s\n' "$@" >"$SUDO_TEST_ROOT/packages"
# A build must not inherit a ticket through either sudo spelling. Both paths
# resolve to harmless mocks; the workflow never reaches the host's sudo.
if sudo -n /usr/bin/true || "$SUDO_TEST_ROOT/mock/sudo" -n /usr/bin/true; then
  exit 94
fi
if [[ ${SUDO_TEST_AUR_SIGNAL:-0} == 1 ]]; then
  touch "$SUDO_TEST_CACHE"
  kill -TERM "$PPID"
fi
# Model third-party code obtaining a ticket independently; cleanup must revoke.
touch "$SUDO_TEST_CACHE"
exit "${SUDO_TEST_AUR_STATUS:-0}"
STUB
cat >"$SUDO_TEST_ROOT/bin/fzf" <<'STUB'
#!/bin/bash
cat
exit "${SUDO_TEST_FZF_STATUS:-0}"
STUB
cat >"$SUDO_TEST_ROOT/bin/omarchy-show-done" <<'STUB'
#!/bin/bash
[[ ! -e $SUDO_TEST_CACHE ]] || exit 91
printf 'done:%s\n' "$1" >>"$SUDO_TEST_LOG"
STUB
cat >"$SUDO_TEST_ROOT/bin/updatedb" <<'STUB'
#!/bin/bash
echo unexpected-updatedb >>"$SUDO_TEST_LOG"
exit 99
STUB
chmod +x "$SUDO_TEST_ROOT/bin/"{yay,fzf,omarchy-show-done,updatedb}

run_install() {
  "$SUDO_TEST_ROOT/bin/omarchy-pkg-aur-install" >"$boundary_tmp/output" 2>&1
}

for result in 0 42; do
  reset_boundary
  touch "$SUDO_TEST_CACHE"
  status=0
  OMARCHY_UPDATE_SUDO_SESSION=1 SUDO_TEST_AUR_STATUS=$result run_install || status=$?
  (( status == result )) || fail "AUR installer preserves build status $result" "$(<"$boundary_tmp/output")"
  assert_boundary_cold "AUR status $result"
  [[ $(<"$SUDO_TEST_ROOT/packages") == $'-S\n--noconfirm\n--\naur/audit-one\naur/audit-two' ]] || fail "selected AUR package operands remain distinct"
  grep -qx "done:$result" "$SUDO_TEST_LOG" || fail "AUR status $result is shown after revocation"
  if grep -q 'unexpected-updatedb\|sudo -v' "$SUDO_TEST_LOG"; then
    fail "AUR install must not maintain credentials or run a filesystem scan"
  fi
  pass "AUR install $result runs builds cold, revokes before the result prompt, and preserves its status"
done

for selection in 1 130 2; do
  reset_boundary
  rm -f "$SUDO_TEST_ROOT/packages"
  status=0
  SUDO_TEST_FZF_STATUS=$selection run_install || status=$?
  expected=0
  (( selection != 2 )) || expected=2
  (( status == expected )) || fail "selection status $selection is handled correctly"
  [[ ! -f $SUDO_TEST_ROOT/packages ]] || fail "cancelled or failed selection must not install packages"
  assert_boundary_cold "selection status $selection"
done
pass "cancelled and failed selections install nothing and leave credentials revoked"

reset_boundary
if SUDO_TEST_AUR_SIGNAL=1 run_install; then fail "an interrupted AUR build must not succeed"; fi
assert_boundary_cold "interrupted AUR install"
pass "interrupted AUR installs revoke cached authorization"

reset_boundary
if /usr/bin/bash "$SUDO_TEST_ROOT/bin/omarchy-pkg-aur-install" -p >"$boundary_tmp/output" 2>&1; then
  fail "AUR installer accepts a decoy privileged Bash argument"
fi
[[ ! -s $SUDO_TEST_LOG ]] || fail "unsafe AUR interpreter startup reached sudo"
pass "AUR installer rejects unprotected Bash startup"

reset_boundary
printf '%s\n' 'touch "$SUDO_TEST_ROOT/startup-marker"' >"$boundary_tmp/startup"
BASH_ENV="$boundary_tmp/startup" ENV="$boundary_tmp/startup" run_install || fail "protected AUR startup failed"
[[ ! -e $SUDO_TEST_ROOT/startup-marker ]] || fail "AUR startup files ran before the credential boundary"
pass "AUR installer prevents inherited shell startup injection"
