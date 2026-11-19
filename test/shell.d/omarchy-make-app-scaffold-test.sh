#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command python3

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

scaffold=$ROOT/default/agents/skills/omarchy-make-app/scaffold

# The scaffold reads its files out of templates.md by heading, so a template
# heading or fence written differently would drop a file without an error.
mkdir -p "$test_tmp/tally"
output=$(cd "$test_tmp/tally" && HOME=$test_tmp "$scaffold" tally "Tally Counter" --no-build)
for path in CMakeLists.txt bin/build bin/test .github/workflows/test.yml src/main.cpp src/theme.h src/theme.cpp \
  src/translator.h src/translator.cpp src/backend.h src/backend.cpp src/Main.qml src/resources.qrc \
  src/i18n/en.json src/i18n/da.json tests/tally_tests.cpp share/tally.desktop share/tally.svg .gitignore LICENSE; do
  [[ -s $test_tmp/tally/$path ]] || fail "the scaffold writes $path" "$output"
done
pass "the scaffold writes every starter file"

# The display name also names the test class, and a display name with a space
# must still give a C++ identifier, or the untouched starter fails to build.
grep -q "^class TallyCounterTests : public QObject" "$test_tmp/tally/tests/tally_tests.cpp" ||
  fail "a display name with a space gives a valid test class name" "$(grep -n 'Tests' "$test_tmp/tally/tests/tally_tests.cpp" | head -3)"
pass "a display name with a space gives a valid test class name"

if leftover=$(grep -rln -e '<name>' -e '<Name>' -e '<code>' "$test_tmp/tally" --exclude-dir=.git); then
  fail "the scaffold fills in every placeholder" "$leftover"
fi
pass "the scaffold fills in every placeholder"

[[ -x $test_tmp/tally/bin/test && -d $test_tmp/tally/.git ]] || fail "the scaffold makes bin/ executable and inits git"
pass "the scaffold makes bin/ executable and inits git"

# Run in a directory with work in it, it refuses rather than mixing the
# starter into someone's files.
mkdir -p "$test_tmp/busy"
echo keep >"$test_tmp/busy/notes.txt"
if (cd "$test_tmp/busy" && "$scaffold" tally --no-build >/dev/null 2>&1); then
  fail "the scaffold refuses a directory that has files"
fi
[[ $(cat "$test_tmp/busy/notes.txt") == "keep" && ! -e $test_tmp/busy/CMakeLists.txt ]] ||
  fail "the scaffold leaves a busy directory alone"
pass "the scaffold refuses a directory that has files"

# The display name goes into a QML string as it is, so one that would end the
# string is refused before anything is written.
mkdir -p "$test_tmp/quoted"
if (cd "$test_tmp/quoted" && "$scaffold" notes 'My "Notes"' --no-build >/dev/null 2>&1); then
  fail "the scaffold refuses a display name with a quote in it"
fi
[[ -z $(ls -A "$test_tmp/quoted") ]] || fail "a refused display name writes nothing" "$(ls -A "$test_tmp/quoted")"
pass "the scaffold refuses a display name that would break the starter"
