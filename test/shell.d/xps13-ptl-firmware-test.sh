#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

leaf="$ROOT/install/hardware/dell-xps13-ptl-speaker-firmware.sh"
migration="$ROOT/migrations/1791265613.sh"

grep -q 'run_logged .*hardware/dell-xps13-ptl-speaker-firmware.sh' "$ROOT/install/hardware/all.sh" ||
  fail "hardware setup installs the Panther Lake XPS 13 firmware"
pass "hardware setup installs the Panther Lake XPS 13 firmware"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mkdir -p "$test_tmp/bin"

cat >"$test_tmp/bin/omarchy-hw-match" <<'SH'
#!/bin/bash
[[ $TEST_PRODUCT_NAME == *"$1"* ]]
SH
cat >"$test_tmp/bin/omarchy-hw-intel-ptl" <<'SH'
#!/bin/bash
[[ $TEST_INTEL_PTL == "1" ]]
SH
cat >"$test_tmp/bin/sudo" <<'SH'
#!/bin/bash
if [[ $1 == "pacman" ]]; then
  exec "$@"
fi
printf 'Unexpected privileged command: %s\n' "$*" >&2
exit 1
SH
cat >"$test_tmp/bin/pacman" <<'SH'
#!/bin/bash
if [[ $1 == "-Q" ]]; then
  if [[ ${@: -1} == "linux-firmware-cirrus-dx13260" ]]; then
    [[ -e $TEST_ALIAS_FILE ]] || exit 1
    printf 'linux-firmware-cirrus-dx13260 20260810-1\n'
  else
    [[ -s $TEST_VERSION_FILE ]] || exit 1
    printf 'linux-firmware-cirrus %s\n' "$(<"$TEST_VERSION_FILE")"
  fi
else
  printf 'pacman %s\n' "$*" >>"$TEST_LOG"
  [[ $* == "-S --noconfirm --needed -- linux-firmware-cirrus-dx13260" ]] || exit 1
  [[ ${TEST_INSTALL_FAILURE:-0} == "0" ]] || exit 1
  touch "$TEST_ALIAS_FILE"
fi
SH
cat >"$test_tmp/bin/omarchy-state" <<'SH'
#!/bin/bash
printf 'state %s\n' "$*" >>"$TEST_LOG"
SH
chmod +x "$test_tmp/bin/"*

export PATH="$test_tmp/bin:$ROOT/bin:$PATH"
export TEST_LOG="$test_tmp/calls" TEST_VERSION_FILE="$test_tmp/version" TEST_ALIAS_FILE="$test_tmp/alias-installed"
export TEST_PRODUCT_NAME="XPS 13 DX13260" TEST_INTEL_PTL=1
install_call="pacman -S --noconfirm --needed -- linux-firmware-cirrus-dx13260"
export OMARCHY_PATH="$ROOT"

reset_fixture() {
  : >"$TEST_LOG"
  printf '%s' "$1" >"$TEST_VERSION_FILE"
  rm -f "$TEST_ALIAS_FILE"
}

run_leaf() {
  bash -eE -c 'source "$1"' bash "$leaf"
}

run_migration() {
  bash -euo pipefail "$migration" >/dev/null
}

for model in "XPS 9350" "XPS 13 DX13261"; do
  reset_fixture "20260810-2"
  TEST_PRODUCT_NAME="$model" run_leaf
  TEST_PRODUCT_NAME="$model" run_migration
  [[ ! -s $TEST_LOG ]] || fail "other models receive no firmware repair"
done
reset_fixture "20260810-2"
TEST_INTEL_PTL=0 run_leaf
TEST_INTEL_PTL=0 run_migration
[[ ! -s $TEST_LOG ]] || fail "the Wildcat Lake variant receives no firmware repair"
pass "other models and the Wildcat Lake variant receive no firmware repair"

for version in "" "20260810-2" "20260810-3" "20260810-4" "20260910-2" "20260916-1" "1:20260810-2"; do
  reset_fixture "$version"
  run_leaf || fail "the alias package is installed during hardware setup"
  [[ $(<"$TEST_LOG") == "$install_call" && $(<"$TEST_VERSION_FILE") == "$version" && -e $TEST_ALIAS_FILE ]] ||
    fail "hardware setup installs the separate aliases without replacing stock firmware"
done
pass "hardware setup installs the package identity without replacing any stock firmware"
pass "hardware setup leaves reboot bookkeeping to the migration"

reset_fixture "20260810-2"
touch "$TEST_ALIAS_FILE"
run_leaf
[[ ! -s $TEST_LOG ]] || fail "installed aliases are idempotent on stock firmware"
pass "installed aliases are idempotent on stock firmware"

run_migration
[[ $(<"$TEST_LOG") == "state set reboot-required" ]] ||
  fail "the migration requests a reboot even if hardware setup already installed the aliases"
pass "the migration requests a reboot even if hardware setup already installed the aliases"

reset_fixture "20260810-2"
if TEST_INSTALL_FAILURE=1 run_migration; then
  fail "a failed firmware installation fails the migration"
fi
[[ $(<"$TEST_LOG") == "$install_call" && $(<"$TEST_VERSION_FILE") == "20260810-2" ]] ||
  fail "a failed installation leaves the migration retryable without claiming success"
pass "a failed firmware installation fails the migration and remains retryable"

: >"$TEST_LOG"
run_migration
[[ $(<"$TEST_LOG") == "$install_call"$'\nstate set reboot-required' ]] ||
  fail "retrying the migration installs the firmware and requests a reboot"
pass "retrying the migration installs the firmware and requests a reboot"

: >"$TEST_LOG"
run_migration
[[ $(<"$TEST_LOG") == "state set reboot-required" ]] ||
  fail "a second user before reboot is prompted without reinstalling"
pass "a second user before reboot is prompted without reinstalling"
