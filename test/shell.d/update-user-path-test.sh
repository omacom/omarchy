#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/fixtures/sudo-boundary-test.sh"
copy_boundary_file bin/omarchy-update

# Model the two exec boundaries without a host update log or a real lock.
# Both child processes inherit the environment exactly as script/lock would.
cat >"$SUDO_TEST_ROOT/bin/script" <<'STUB'
#!/bin/bash
printf 'logged-reexec\n' >>"$SUDO_TEST_LOG"
[[ $1 == "-qefc" ]] || exit 90
exec /usr/bin/bash -p -c "$2"
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
chmod +x "$SUDO_TEST_ROOT/bin/script" "$SUDO_TEST_ROOT/bin/omarchy-update-lock" "$boundary_tmp/user commands/update-user-tool"

for step in omarchy-hook omarchy-update-mise; do
  rm "$SUDO_TEST_ROOT/bin/$step"
  cat >"$SUDO_TEST_ROOT/bin/$step" <<'STUB'
#!/bin/bash
[[ ! -e $SUDO_TEST_CACHE ]] || exit 91
[[ $(command -v sudo) == "$OMARCHY_PATH/default/omarchy/sudo-no-update/sudo" ]] || exit 92
update-user-tool "${0##*/}"
STUB
  chmod +x "$SUDO_TEST_ROOT/bin/$step"
done

for entry in fresh logged locked; do
  reset_boundary
  unset OMARCHY_UPDATE_LOGGED OMARCHY_UPDATE_USER_PATH SUDO_TEST_LOCKED
  case "$entry" in
    logged) export OMARCHY_UPDATE_LOGGED=1 ;;
    locked) export OMARCHY_UPDATE_LOGGED=1 SUDO_TEST_LOCKED=1 ;;
  esac
  PATH="$boundary_tmp/user commands:$PATH" "$SUDO_TEST_ROOT/bin/omarchy-update" -y >"$boundary_tmp/output" 2>&1 ||
    fail "$entry update lost the original user PATH" "$(<"$boundary_tmp/output")"
  grep -q '^user-tool:omarchy-hook$' "$SUDO_TEST_LOG" || fail "$entry hook could not run a user-installed tool"
  grep -q '^user-tool:omarchy-update-mise$' "$SUDO_TEST_LOG" || fail "$entry mise could not run a user-installed tool"
  if [[ $entry == "fresh" ]]; then
    grep -q '^logged-reexec$' "$SUDO_TEST_LOG" || fail "fresh update did not exercise the logging exec"
  fi
  if [[ $entry != "locked" ]]; then
    grep -q '^locked-reexec$' "$SUDO_TEST_LOG" || fail "$entry update did not exercise the lock exec"
  fi
  assert_boundary_cold "$entry update"
  pass "$entry update preserves the original user PATH through logging and locking with no-update sudo first"
done
