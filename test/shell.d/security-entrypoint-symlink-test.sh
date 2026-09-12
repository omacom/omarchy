#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/fixtures/sudo-boundary-test.sh"
export OMARCHY_UPDATE_LOGGED=1

# The real fixed entrypoints run only fixture operations. The sibling library
# is a harmless sentinel: invoking a command through another directory must
# source the library beside the resolved command instead of this file.
mkdir "$boundary_tmp/links"
printf '%s\n' 'touch "$SUDO_TEST_HOME/wrong-library"' >"$boundary_tmp/links/omarchy-security-functions"
for command in omarchy-update omarchy-refresh-pacman omarchy-update-stay-awake omarchy-channel-set omarchy-migrate omarchy-setup-security-sshd omarchy-pkg-add; do
  rm -f "$SUDO_TEST_ROOT/bin/$command"
  copy_boundary_file "bin/$command"
  ln -s "$SUDO_TEST_ROOT/bin/$command" "$boundary_tmp/links/$command"
  reset_boundary
  args=(unexpected)
  case "$command" in
    omarchy-update) args=(-y) ;;
    omarchy-migrate) args=(--pending) ;;
    omarchy-pkg-add) args=() ;;
  esac
  status=0
  "$boundary_tmp/links/$command" "${args[@]}" >"$boundary_tmp/output" 2>&1 || status=$?
  [[ ! -e $SUDO_TEST_HOME/wrong-library ]] || fail "$command sourced a library beside its symlink"
  (( status != 126 )) || fail "$command failed to locate its actual library" "$(<"$boundary_tmp/output")"
  if [[ $command == "omarchy-migrate" || $command == "omarchy-pkg-add" ]]; then
    [[ ! -s $SUDO_TEST_LOG ]] || fail "$command performed work during its read-only/usage check"
  else
    [[ -s $SUDO_TEST_LOG ]] || fail "$command did not reach the protected fixture boundary"
    assert_boundary_cold "$command symlink"
  fi
  pass "$command resolves its own library when invoked through a symlink"
done

ln -s "$SUDO_TEST_ROOT/default/omarchy/sudo-no-update/sudo" "$boundary_tmp/links/sudo"
reset_boundary
"$boundary_tmp/links/sudo" -k || fail "symlinked sudo wrapper lost its source library"
[[ $(<"$SUDO_TEST_LOG") == "sudo -k" ]] || fail "symlinked wrapper did not reach the fixed sudo stand-in"
pass "the sudo wrapper resolves its source library independently of its invocation link"
