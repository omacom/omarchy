#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/fixtures/sudo-boundary-test.sh"

# The real fixed entrypoint runs only fixture operations. The sibling library
# is a harmless sentinel: invoking the command through another directory must
# source the library beside the resolved command instead of this file.
mkdir "$boundary_tmp/links"
printf '%s\n' 'touch "$SUDO_TEST_HOME/wrong-library"' >"$boundary_tmp/links/omarchy-security-functions"
command=omarchy-update-stay-awake
rm -f "$SUDO_TEST_ROOT/bin/$command"
copy_boundary_file "bin/$command"
ln -s "$SUDO_TEST_ROOT/bin/$command" "$boundary_tmp/links/$command"
reset_boundary
status=0
"$boundary_tmp/links/$command" unexpected >"$boundary_tmp/output" 2>&1 || status=$?
[[ ! -e $SUDO_TEST_HOME/wrong-library ]] || fail "$command sourced a library beside its symlink"
(( status != 126 )) || fail "$command failed to locate its actual library" "$(<"$boundary_tmp/output")"
grep -Eq '^Usage:' "$boundary_tmp/output" || fail "$command did not reach its own argument check" "$(<"$boundary_tmp/output")"
pass "$command resolves its own library when invoked through a symlink"
