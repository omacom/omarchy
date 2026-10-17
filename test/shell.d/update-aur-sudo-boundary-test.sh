#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/fixtures/sudo-boundary-test.sh"

rm -f "$SUDO_TEST_ROOT/bin/omarchy-update-aur-pkgs" "$SUDO_TEST_ROOT/bin/yay" \
  "$SUDO_TEST_ROOT/bin/pacman" "$SUDO_TEST_ROOT/bin/omarchy-pkg-aur-accessible"
copy_boundary_file bin/omarchy-update-aur-pkgs

cat >"$SUDO_TEST_ROOT/bin/pacman" <<'STUB'
#!/bin/bash
[[ ! -e $SUDO_TEST_CACHE ]] || exit 91
printf 'query:%s\n' "$*" >>"$SUDO_TEST_LOG"
exit "${SUDO_TEST_NO_AUR:-0}"
STUB
cat >"$SUDO_TEST_ROOT/bin/omarchy-pkg-aur-accessible" <<'STUB'
#!/bin/bash
exit "${SUDO_TEST_AUR_OFFLINE:-0}"
STUB
cat >"$SUDO_TEST_ROOT/bin/yay" <<'STUB'
#!/bin/bash
set -euo pipefail
[[ ! -e $SUDO_TEST_CACHE ]] || exit 91
[[ $(command -v sudo) == "$OMARCHY_PATH/default/omarchy/sudo-no-update/sudo" ]] || exit 92
[[ ${OMARCHY_SUDO_NO_UPDATE:-0} == 1 && -z ${OMARCHY_UPDATE_SUDO_SESSION+x} ]] || exit 93
[[ $1 == --sudo && $2 == "$OMARCHY_PATH/default/omarchy/sudo-no-update/sudo" && $3 == --sudoloop=false ]] || exit 94
shift 3
[[ $* == '-Sua --noconfirm --cleanafter --ignore gcc14,gcc14-libs' ]] || exit 95
echo build >>"$SUDO_TEST_LOG"
# Both spellings reach harmless fixture sudo, never the host's command.
if sudo -n /usr/bin/true || "$SUDO_TEST_ROOT/mock/sudo" -n /usr/bin/true; then
  exit 96
fi
sudo /usr/bin/true
[[ ! -e $SUDO_TEST_CACHE ]] || exit 97
# Independently created authorization must also be gone on helper exit.
touch "$SUDO_TEST_CACHE"
if [[ ${SUDO_TEST_AUR_SIGNAL:-0} == 1 ]]; then
  kill -TERM "$PPID"
fi
exit "${SUDO_TEST_AUR_RESULT:-0}"
STUB
chmod +x "$SUDO_TEST_ROOT/bin/"{pacman,yay,omarchy-pkg-aur-accessible}

run_aur_update() {
  "$SUDO_TEST_ROOT/bin/omarchy-update-aur-pkgs" >"$boundary_tmp/output" 2>&1
}

for context in standalone full-update; do
  reset_boundary
  touch "$SUDO_TEST_CACHE"
  unset OMARCHY_SUDO_NO_UPDATE OMARCHY_UPDATE_SUDO_SESSION
  if [[ $context == "full-update" ]]; then
    export OMARCHY_SUDO_NO_UPDATE=1 OMARCHY_UPDATE_SUDO_SESSION=1
  fi
  run_aur_update || fail "$context AUR update failed" "$(<"$boundary_tmp/output")"
  assert_boundary_cold "$context AUR update"
  grep -qx build "$SUDO_TEST_LOG" || fail "$context did not exercise the build"
  [[ $(head -n 1 "$SUDO_TEST_LOG") == 'sudo -k' ]] || fail "$context did not revoke first"
  ! grep -q '^sudo -v\|^sudo /usr/bin/true' "$SUDO_TEST_LOG" || fail "$context refreshed reusable credentials"
  pass "$context AUR updates establish a cold boundary and use command-scoped sudo"
done
unset OMARCHY_SUDO_NO_UPDATE OMARCHY_UPDATE_SUDO_SESSION

reset_boundary
status=0
SUDO_TEST_AUR_RESULT=42 run_aur_update || status=$?
(( status == 1 )) || fail "the AUR helper retains its nonzero failure contract"
assert_boundary_cold "failed direct AUR update"
pass "failed direct AUR updates revoke independently created authorization"

reset_boundary
status=0
SUDO_TEST_AUR_SIGNAL=1 run_aur_update || status=$?
(( status == 143 )) || fail "an interrupted AUR update propagates termination"
assert_boundary_cold "interrupted direct AUR update"
pass "interrupted direct AUR updates revoke authorization"

for skipped in no-packages offline; do
  reset_boundary
  touch "$SUDO_TEST_CACHE"
  if [[ $skipped == "no-packages" ]]; then
    SUDO_TEST_NO_AUR=1 run_aur_update
  else
    SUDO_TEST_AUR_OFFLINE=1 run_aur_update
  fi
  ! grep -qx build "$SUDO_TEST_LOG" || fail "$skipped still ran a build"
  assert_boundary_cold "$skipped direct AUR update"
done
pass "no foreign packages and unavailable AUR skip builds while leaving credentials cold"

reset_boundary
SUDO_TEST_UNSUPPORTED=1 run_aur_update && fail "unsupported sudo must stop standalone AUR updates"
! grep -q '^query:\|^build$' "$SUDO_TEST_LOG" || fail "unsupported sudo reached package work"
assert_boundary_cold "unsupported sudo"
pass "direct AUR updates refuse unsupported sudo before package work"

reset_boundary
mv "$SUDO_TEST_ROOT/default/omarchy/sudo-no-update/sudo" "$boundary_tmp/sudo-wrapper"
run_aur_update && fail "a missing sudo wrapper must stop standalone AUR updates"
! grep -q '^query:\|^build$' "$SUDO_TEST_LOG" || fail "missing wrapper reached package work"
assert_boundary_cold "missing wrapper"
mv "$boundary_tmp/sudo-wrapper" "$SUDO_TEST_ROOT/default/omarchy/sudo-no-update/sudo"
pass "direct AUR updates cannot fall through to ordinary sudo when the wrapper is missing"

reset_boundary
SUDO_TEST_REVOKE_FAIL=1 run_aur_update && fail "failed revocation must stop standalone AUR updates"
! grep -q '^query:\|^build$' "$SUDO_TEST_LOG" || fail "failed revocation reached package work"
pass "failed initial revocation prevents direct AUR package work"

reset_boundary
mkdir "$boundary_tmp/other-root"
OMARCHY_PATH="$boundary_tmp/other-root" run_aur_update && fail "a mismatched source root was accepted"
[[ ! -s $SUDO_TEST_LOG ]] || fail "mismatched source root reached sudo"
pass "direct AUR updates reject mismatched source roots before work"

reset_boundary
/usr/bin/bash "$SUDO_TEST_ROOT/bin/omarchy-update-aur-pkgs" -p >"$boundary_tmp/output" 2>&1 &&
  fail "an ordinary Bash launch with a decoy -p was accepted"
[[ ! -s $SUDO_TEST_LOG ]] || fail "unprotected Bash startup reached sudo"
pass "direct AUR updates reject unprotected Bash startup"

reset_boundary
printf '%s\n' 'touch "$SUDO_TEST_ROOT/startup-marker"' >"$boundary_tmp/startup"
BASH_ENV="$boundary_tmp/startup" ENV="$boundary_tmp/startup" run_aur_update ||
  fail "protected startup failed" "$(<"$boundary_tmp/output")"
[[ ! -e $SUDO_TEST_ROOT/startup-marker ]] || fail "startup code ran before the AUR boundary"
assert_boundary_cold "protected startup"
pass "inherited startup files cannot run in direct AUR updates or build helpers"

reset_boundary
function printf() { /usr/bin/touch "$SUDO_TEST_ROOT/function-marker"; /usr/bin/printf "$@"; }
export -f printf
run_aur_update || fail "exported-function sanitization failed" "$(<"$boundary_tmp/output")"
unset -f printf
[[ ! -e $SUDO_TEST_ROOT/function-marker ]] || fail "an exported function reached AUR build helpers"
assert_boundary_cold "exported-function startup"
pass "direct AUR updates sanitize exported functions before running helpers"
