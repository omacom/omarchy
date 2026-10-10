#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/fixtures/sudo-boundary-test.sh"
copy_boundary_file bin/omarchy-update

# Model the two exec boundaries without a host update log or a real lock.
# The logger uses its selected shell, then the inner update and lock inherit
# the environment encoded in the logged command.
cat >"$SUDO_TEST_ROOT/mock/script" <<'STUB'
#!/bin/bash
[[ $SHELL == "/usr/bin/bash" ]] || exit 89
printf 'logged-reexec\n' >>"$SUDO_TEST_LOG"
[[ $1 == "-qefc" ]] || exit 90
exec "$SHELL" -c "$2"
STUB
rm "$SUDO_TEST_ROOT/bin/omarchy-update-lock"
cat >"$SUDO_TEST_ROOT/bin/omarchy-update-lock" <<'STUB'
#!/bin/bash
case "$1" in
  held) [[ ${SUDO_TEST_LOCKED:-0} == "1" ]] ;;
  run)
    shift
    printf 'locked-reexec\n' >>"$SUDO_TEST_LOG"
    export SUDO_TEST_LOCKED=1
    exec "$@"
    ;;
esac
STUB
mkdir "$boundary_tmp/user commands"
cat >"$boundary_tmp/user commands/update-user-tool" <<'STUB'
#!/bin/bash
printf 'user-tool:%s\n' "$1" >>"$SUDO_TEST_LOG"
STUB
cat >"$boundary_tmp/user commands/update-shell-wrapper" <<'STUB'
#!/bin/bash
touch "$SUDO_TEST_HOME/inherited-shell-selected"
exec /usr/bin/bash "$@"
STUB
chmod +x "$SUDO_TEST_ROOT/mock/script" "$SUDO_TEST_ROOT/bin/omarchy-update-lock" \
  "$boundary_tmp/user commands/update-user-tool" "$boundary_tmp/user commands/update-shell-wrapper"

for step in omarchy-hook omarchy-update-mise; do
  rm "$SUDO_TEST_ROOT/bin/$step"
  cat >"$SUDO_TEST_ROOT/bin/$step" <<'STUB'
#!/bin/bash
[[ -e $SUDO_TEST_CACHE ]] || exit 91
[[ $(command -v sudo) != "$OMARCHY_PATH/default/omarchy/sudo-no-update/sudo" ]] || exit 92
if [[ ${SUDO_TEST_EXPECT_SHELL_EXPORTED:-1} == "1" ]]; then
  [[ $SHELL == "$SUDO_TEST_INHERITED_SHELL" ]] || exit 93
  /usr/bin/env | grep -Fqx "SHELL=$SUDO_TEST_INHERITED_SHELL" || exit 94
else
  ! /usr/bin/env | grep -q '^SHELL=' || exit 95
fi
update-user-tool "${0##*/}"
STUB
  chmod +x "$SUDO_TEST_ROOT/bin/$step"
done

for entry in fresh logged locked; do
  reset_boundary
  unset OMARCHY_UPDATE_LOGGED OMARCHY_UPDATE_USER_PATH SUDO_TEST_LOCKED
  export SUDO_TEST_INHERITED_SHELL="$boundary_tmp/user commands/update-shell-wrapper"
  case "$entry" in
    logged) export OMARCHY_UPDATE_LOGGED=1 ;;
    locked) export OMARCHY_UPDATE_LOGGED=1 SUDO_TEST_LOCKED=1 ;;
  esac
  SHELL="$SUDO_TEST_INHERITED_SHELL" PATH="$boundary_tmp/user commands:$PATH" \
    "$SUDO_TEST_ROOT/bin/omarchy-update" -y >"$boundary_tmp/output" 2>&1 ||
    fail "$entry update lost the original user PATH" "$(<"$boundary_tmp/output")"
  grep -q '^user-tool:omarchy-hook$' "$SUDO_TEST_LOG" || fail "$entry hook could not run a user-installed tool"
  grep -q '^user-tool:omarchy-update-mise$' "$SUDO_TEST_LOG" || fail "$entry mise could not run a user-installed tool"
  if [[ $entry == "fresh" ]]; then
    [[ ! -e $SUDO_TEST_HOME/inherited-shell-selected ]] || fail "fresh update let inherited SHELL select the logging interpreter"
    grep -q '^logged-reexec$' "$SUDO_TEST_LOG" || fail "fresh update did not exercise the logging exec"
  fi
  if [[ $entry != "locked" ]]; then
    grep -q '^locked-reexec$' "$SUDO_TEST_LOG" || fail "$entry update did not exercise the lock exec"
  fi
  assert_boundary_cold "$entry update"
  pass "$entry update preserves the original user PATH through logging and locking and shares its authorization"
done

reset_boundary
unset SHELL OMARCHY_UPDATE_LOGGED OMARCHY_UPDATE_USER_PATH SUDO_TEST_LOCKED
SUDO_TEST_EXPECT_SHELL_EXPORTED=0 SUDO_TEST_INHERITED_SHELL=/bin/bash PATH="$boundary_tmp/user commands:$PATH" \
  "$SUDO_TEST_ROOT/bin/omarchy-update" -y >"$boundary_tmp/output" 2>&1 ||
  fail "an update with SHELL unset did not use Bash" "$(<"$boundary_tmp/output")"
grep -q '^logged-reexec$' "$SUDO_TEST_LOG" || fail "an update with SHELL unset did not exercise the logging exec"
grep -q '^user-tool:omarchy-hook$' "$SUDO_TEST_LOG" || fail "an update with SHELL unset lost the hook user PATH"
grep -q '^user-tool:omarchy-update-mise$' "$SUDO_TEST_LOG" || fail "an update with SHELL unset lost the mise user PATH"
assert_boundary_cold "an update with SHELL unset"
pass "the logger uses Bash when the caller leaves SHELL unset"

equals_checkout="$boundary_tmp/omarchy=dev"
mkdir -p "$equals_checkout/bin"
ln -s "$SUDO_TEST_ROOT/bin/omarchy-update" "$equals_checkout/bin/omarchy-update"
reset_boundary
unset OMARCHY_UPDATE_LOGGED OMARCHY_UPDATE_USER_PATH SUDO_TEST_LOCKED
export SUDO_TEST_INHERITED_SHELL="$boundary_tmp/user commands/update-shell-wrapper"
SHELL="$SUDO_TEST_INHERITED_SHELL" PATH="$boundary_tmp/user commands:$PATH" \
  "$equals_checkout/bin/omarchy-update" -y >"$boundary_tmp/output" 2>&1 ||
  fail "an update checkout path containing = did not survive the logging re-exec" "$(<"$boundary_tmp/output")"
grep -q '^logged-reexec$' "$SUDO_TEST_LOG" || fail "the = checkout path did not exercise the logging exec"
grep -q '^locked-reexec$' "$SUDO_TEST_LOG" || fail "the = checkout path did not exercise the lock exec"
grep -q '^user-tool:omarchy-hook$' "$SUDO_TEST_LOG" || fail "the = checkout path did not reach the update hook"
[[ ! -e $SUDO_TEST_HOME/inherited-shell-selected ]] || fail "the = checkout path let inherited SHELL select the logger"
assert_boundary_cold "an update checkout path containing ="
pass "the logger preserves update checkout paths containing ="
