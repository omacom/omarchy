#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

migration="$ROOT/migrations/1795805414.sh"

# Fresh installs must no longer invoke or bundle the retired XPS 13 audio workarounds.
for retired in \
  "$ROOT/install/hardware/dell-xps13-sidecar-amps.sh" \
  "$ROOT/install/hardware/dell-xps13-ptl-speaker-firmware.sh" \
  "$ROOT/bin/omarchy-hw-dell-xps13-sidecar-amps" \
  "$ROOT/bin/omarchy-hw-dell-xps13-dx13260-ptl" \
  "$ROOT/migrations/1787666837.sh" \
  "$ROOT/migrations/1791265613.sh"; do
  [[ ! -e $retired ]] || fail "retired XPS 13 audio file must be removed" "$retired"
done

! grep -qE 'dell-xps13-(sidecar-amps|ptl-speaker-firmware)' \
  "$ROOT/install/hardware/all.sh" \
  "$ROOT/install/helpers/logging.sh" ||
  fail "hardware/all.sh and logging.sh must not reference retired XPS 13 audio leaves"

! grep -qE '^(dell-xps13-sidecar-amps|linux-firmware-cirrus-dx13260)$' \
  "$ROOT/install/omarchy-other.packages" ||
  fail "omarchy-other.packages must not list retired XPS 13 audio packages"

pass "retired XPS 13 audio leaves, predicates, and package entries are removed"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
modules_dir="$test_tmp/modules"
drop_log="$test_tmp/drops"
mkdir -p "$mock_bin" "$modules_dir"

cat >"$mock_bin/omarchy-pkg-present" <<'SH'
#!/bin/bash
[[ " ${TEST_INSTALLED:-} " == *" $1 "* ]]
SH

cat >"$mock_bin/pacman" <<'SH'
#!/bin/bash
if [[ $1 == "-Q" && $2 == "linux-firmware-cirrus" ]]; then
  [[ -n ${TEST_CIRRUS_VER:-} ]] || exit 1
  printf 'linux-firmware-cirrus %s\n' "$TEST_CIRRUS_VER"
  exit 0
fi
exit 1
SH

cat >"$mock_bin/omarchy-pkg-drop" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$TEST_DROP_LOG"
SH

chmod +x "$mock_bin/"*

run_migration() {
  : >"$drop_log"
  PATH="$mock_bin:$PATH" \
  OMARCHY_MODULES_DIR="$modules_dir" \
  TEST_DROP_LOG="$drop_log" \
  TEST_INSTALLED="${1:-}" \
  TEST_CIRRUS_VER="${2:-}" \
    bash -euo pipefail "$migration" >/dev/null
}

set_kernels() {
  rm -rf "$modules_dir"/*
  local kver
  for kver in "$@"; do
    mkdir -p "$modules_dir/$kver"
    printf 'linux-omarchy\n' >"$modules_dir/$kver/pkgbase"
  done
}

# 1. No-op when neither package is installed.
set_kernels "7.3.6-2-omarchy"
run_migration "" "20261124-1"
[[ ! -s $drop_log ]] || fail "migration is a no-op when neither package is installed"
pass "migration is a no-op when neither package is installed"

# 2. Drops dell-xps13-sidecar-amps when every installed kernel is >= 7.2.
set_kernels "7.3.6-2-omarchy" "7.2.0-1-arch"
run_migration "dell-xps13-sidecar-amps" "20261124-1"
[[ $(<"$drop_log") == "dell-xps13-sidecar-amps" ]] ||
  fail "migration drops dell-xps13-sidecar-amps on Linux >= 7.2" "$(<"$drop_log")"
pass "migration drops dell-xps13-sidecar-amps when all installed kernels are >= 7.2"

# 3. Keeps dell-xps13-sidecar-amps if an older kernel (e.g. linux-lts) is also installed.
set_kernels "7.3.6-2-omarchy" "6.18.65-1-lts"
run_migration "dell-xps13-sidecar-amps" "20261124-1"
[[ ! -s $drop_log ]] || fail "migration preserves dell-xps13-sidecar-amps when linux-lts < 7.2 is present"
pass "migration preserves dell-xps13-sidecar-amps when an older kernel is installed"

# 4. Keeps dell-xps13-sidecar-amps on 7.2-rc kernels.
set_kernels "7.2-rc4-1-omarchy"
run_migration "dell-xps13-sidecar-amps" "20261124-1"
[[ ! -s $drop_log ]] || fail "migration preserves dell-xps13-sidecar-amps on pre-release rc kernels"
pass "migration preserves dell-xps13-sidecar-amps on pre-release rc kernels"

# 5. Drops linux-firmware-cirrus-dx13260 when stock linux-firmware-cirrus >= 20260910-2.
set_kernels "7.3.6-2-omarchy"
run_migration "linux-firmware-cirrus-dx13260" "20261124-1"
[[ $(<"$drop_log") == "linux-firmware-cirrus-dx13260" ]] ||
  fail "migration drops linux-firmware-cirrus-dx13260 when native aliases exist" "$(<"$drop_log")"
pass "migration drops linux-firmware-cirrus-dx13260 when linux-firmware-cirrus >= 20260910-2"

# 6. Keeps linux-firmware-cirrus-dx13260 when stock firmware is too old or missing.
run_migration "linux-firmware-cirrus-dx13260" "20260810-2"
[[ ! -s $drop_log ]] || fail "migration preserves firmware overlay on older linux-firmware-cirrus"
run_migration "linux-firmware-cirrus-dx13260" ""
[[ ! -s $drop_log ]] || fail "migration preserves firmware overlay when linux-firmware-cirrus is absent"
pass "migration preserves linux-firmware-cirrus-dx13260 when stock firmware is too old"

# 7. Drops both packages in a single omarchy-pkg-drop call when both qualify.
set_kernels "7.3.6-2-omarchy"
run_migration "dell-xps13-sidecar-amps linux-firmware-cirrus-dx13260" "20261124-1"
[[ $(<"$drop_log") == "dell-xps13-sidecar-amps linux-firmware-cirrus-dx13260" ]] ||
  fail "migration batches both obsolete packages into one omarchy-pkg-drop call" "$(<"$drop_log")"
pass "migration batches both obsolete packages into one omarchy-pkg-drop call"
