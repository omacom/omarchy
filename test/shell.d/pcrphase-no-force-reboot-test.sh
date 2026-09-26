#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

units=(
  systemd-pcrphase-sysinit.service
  systemd-pcrphase.service
  systemd-pcrmachine.service
  systemd-pcrfs-root.service
  'systemd-pcrfs@.service'
)

for unit in "${units[@]}"; do
  drop_in="$ROOT/etc/systemd/system/${unit}.d/10-omarchy-no-force-reboot.conf"
  [[ -f $drop_in ]] || fail "shipped drop-in exists for $unit"
  grep -qxF 'FailureAction=none' "$drop_in" ||
    fail "drop-in clears reboot-force for $unit"
  grep -qxF '[Unit]' "$drop_in" ||
    fail "FailureAction override is under [Unit] for $unit"
done

pass "PCR measurement units ship FailureAction=none drop-ins"

migration="$ROOT/migrations/1789561000.sh"
[[ -f $migration ]] || fail "migration that applies the drop-ins exists"
grep -q 'FailureAction=none' "$migration" ||
  fail "migration documents the FailureAction override"
grep -q 'systemctl daemon-reload' "$migration" ||
  fail "migration reloads systemd so the drop-ins apply without reboot"
grep -q '10-omarchy-no-force-reboot.conf' "$migration" ||
  fail "migration installs the shipped drop-in name"

pass "migration installs drop-ins and daemon-reloads"

# Exercise the migration against a fake systemd tree and a stub systemctl.
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mkdir -p "$test_tmp/src/etc/systemd/system"
for unit in "${units[@]}"; do
  mkdir -p "$test_tmp/src/etc/systemd/system/${unit}.d"
  cp "$ROOT/etc/systemd/system/${unit}.d/10-omarchy-no-force-reboot.conf" \
    "$test_tmp/src/etc/systemd/system/${unit}.d/"
done

mkdir -p "$test_tmp/bin"
cat >"$test_tmp/bin/systemctl" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >>"$TEST_TMP/systemctl.log"
exit 0
STUB
cat >"$test_tmp/bin/sudo" <<'STUB'
#!/bin/bash
exec "$@"
STUB
cat >"$test_tmp/bin/omarchy-state" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >>"$TEST_TMP/state.log"
STUB
chmod +x "$test_tmp/bin"/*

PATH="$test_tmp/bin:$PATH" \
  OMARCHY_PATH="$test_tmp/src" \
  OMARCHY_SYSTEMD_SYSTEM_DIR="$test_tmp/etc/systemd/system" \
  TEST_TMP="$test_tmp" \
  bash "$migration"

for unit in "${units[@]}"; do
  drop_in="$test_tmp/etc/systemd/system/${unit}.d/10-omarchy-no-force-reboot.conf"
  [[ -f $drop_in ]] || fail "migration installs drop-in for $unit into empty /etc"
  grep -qxF 'FailureAction=none' "$drop_in" ||
    fail "installed drop-in for $unit has FailureAction=none"
done

grep -qxF 'daemon-reload' "$test_tmp/systemctl.log" ||
  fail "migration runs systemctl daemon-reload"
[[ ! -e $test_tmp/state.log ]] ||
  fail "successful reload does not set reboot-required"

pass "migration installs missing drop-ins and reloads systemd"
