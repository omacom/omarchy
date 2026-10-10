#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/fixtures/menu-selector-model/runner.sh"

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$scratch/bin" "$scratch/qt6" "$scratch/probe"
# A private PATH keeps this test independent of installed Qt.
# The helper only needs cat; the runner executables below are private stubs.
ln -s "$(command -v cat)" "$scratch/bin/cat"

make_runner() {
  local target="$1" major="$2" status="${3:-0}"
  cat >"$target" <<SH
#!/bin/bash
printf '%s\\n' 'Config: Using QtTest library $major.0.0, Qt $major.0.0'
exit $status
SH
  chmod +x "$target"
}

select_runner() {
  PATH="$scratch/bin" find_qt6_qmltestrunner "$scratch/probe" "$scratch/qt6"
}

make_runner "$scratch/bin/qmltestrunner" 5
make_runner "$scratch/bin/qmltestrunner6" 6
selected=$(select_runner)
[[ $selected == "$scratch/bin/qmltestrunner6" ]] || fail "versioned Qt 6 runner takes priority over unversioned Qt 5"
pass "versioned Qt 6 runner takes priority over unversioned Qt 5"

rm "$scratch/bin/qmltestrunner6"
make_runner "$scratch/qt6/qmltestrunner" 6
selected=$(select_runner)
[[ $selected == "$scratch/qt6/qmltestrunner" ]] || fail "Qt 6 library-directory runner takes priority over unversioned Qt 5"
pass "Qt 6 library-directory runner takes priority over unversioned Qt 5"

rm "$scratch/qt6/qmltestrunner"
make_runner "$scratch/bin/qmltestrunner" 6
selected=$(select_runner)
[[ $selected == "$scratch/bin/qmltestrunner" ]] || fail "unversioned runner is accepted when its Qt runtime is 6"
pass "unversioned runner is accepted when its Qt runtime is 6"

make_runner "$scratch/bin/qmltestrunner" 5
if selected=$(select_runner); then
  fail "Qt 5-only installations have no compatible runner" "$selected"
fi
pass "Qt 5-only installations have no compatible runner"

make_runner "$scratch/bin/qmltestrunner6" 5
make_runner "$scratch/bin/qmltestrunner" 6
selected=$(select_runner)
[[ $selected == "$scratch/bin/qmltestrunner" ]] || fail "a misleading versioned name is rejected by the runtime probe"
pass "a misleading versioned name is rejected by the runtime probe"

make_runner "$scratch/bin/qmltestrunner6" 6 1
selected=$(select_runner)
[[ $selected == "$scratch/bin/qmltestrunner" ]] || fail "an unloadable preferred runner falls through to a working Qt 6 runner"
pass "an unloadable preferred runner falls through to a working Qt 6 runner"

rm "$scratch/bin/qmltestrunner6" "$scratch/bin/qmltestrunner"
if selected=$(select_runner); then
  fail "missing optional Qt runners produce no selection" "$selected"
fi
pass "missing optional Qt runners produce no selection"
