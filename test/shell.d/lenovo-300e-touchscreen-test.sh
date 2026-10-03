#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

leaf="$ROOT/install/hardware/lenovo/fix-300e-touchscreen-resume.sh"
all="$ROOT/install/hardware/all.sh"
hook="$ROOT/default/systemd/system-sleep/lenovo-300e-touchscreen"
migration="$ROOT/migrations/1791045085.sh"

grep -q 'run_logged .*hardware/lenovo/fix-300e-touchscreen-resume.sh' "$all" ||
  fail "the 300e touchscreen quirk runs during hardware setup"
pass "the 300e touchscreen quirk runs during hardware setup"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mkdir -p "$test_tmp/bin"
sudo_log="$test_tmp/sudo.log"

cat >"$test_tmp/bin/omarchy-hw-match" <<'SH'
#!/bin/bash

[[ ${TEST_HW_MATCH:-0} == 1 ]]
SH

cat >"$test_tmp/bin/sudo" <<'SH'
#!/bin/bash

printf '%s\n' "$*" >>"$SUDO_LOG"
SH

chmod +x "$test_tmp/bin"/*

run_leaf() {
  : >"$sudo_log"
  SUDO_LOG="$sudo_log" \
    PATH="$test_tmp/bin:$PATH" \
    OMARCHY_PATH="$ROOT" \
    TEST_HW_MATCH="$1" \
    bash -eE -c 'source "$1"' bash "$leaf"
}

run_leaf 0
if [[ -s $sudo_log ]]; then
  fail "the 300e touchscreen quirk stays off other machines"
fi
pass "the 300e touchscreen quirk stays off other machines"

run_leaf 1
grep -q '/usr/lib/systemd/system-sleep/lenovo-300e-touchscreen' "$sudo_log" ||
  fail "the 300e touchscreen quirk installs the resume hook"
pass "the 300e touchscreen quirk installs the resume hook"

grep -q 'i2c-ELAN238E:00' "$hook" ||
  fail "the resume hook rebinds the ELAN238E touchscreen"
grep -q '\[\[ $1 == "post" \]\]' "$hook" ||
  fail "the resume hook runs after resume"
if grep -q 'SYNA2392' "$hook"; then
  fail "the resume hook must not name the touchpad"
fi
pass "the resume hook rebinds only the ELAN238E touchscreen after resume"

grep -q 'omarchy-hw-match "300e 2nd Gen"' "$migration" ||
  fail "existing 300e installs pick up the resume hook"
grep -q '/usr/lib/systemd/system-sleep/lenovo-300e-touchscreen' "$migration" ||
  fail "existing 300e installs pick up the resume hook"
pass "existing 300e installs pick up the resume hook"
