#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

fix_t2="$ROOT/install/hardware/apple/fix-t2.sh"
hwdb="$ROOT/install/hardware/apple/t2-trackpad.hwdb"
migration="$ROOT/migrations/1788912000.sh"

require_command systemd-hwdb

# Fresh T2 installs must deploy the same rule that the migration uses, compile
# the hwdb, and try to refresh existing input devices immediately.
grep -Fq 'install -Dm644 "$OMARCHY_PATH/install/hardware/apple/t2-trackpad.hwdb"' "$fix_t2" ||
  fail "fresh T2 setup installs the internal-trackpad hwdb rule"
grep -Fq 'systemd-hwdb update' "$fix_t2" ||
  fail "fresh T2 setup compiles the updated hwdb"
grep -Fq 'udevadm trigger --subsystem-match=input --action=change || true' "$fix_t2" ||
  fail "fresh T2 setup retriggers input devices without making install depend on it"
pass "fresh T2 setup installs and activates the trackpad classification"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

# Validate the actual shipped rule with systemd-hwdb. Product IDs differ across
# T2 models, while the built-in composite device name stays specific enough not
# to match an external Magic Trackpad. 0340 is hardware-validated on a
# MacBookPro16,1 in addition to the originally reported controller IDs.
hwdb_root="$test_tmp/hwdb-root"
mkdir -p "$hwdb_root/etc/udev/hwdb.d"
cp "$hwdb" "$hwdb_root/etc/udev/hwdb.d/71-omarchy-t2-trackpad.hwdb"
systemd-hwdb --root="$hwdb_root" --strict update

query_hwdb() {
  systemd-hwdb --root="$hwdb_root" query "$1" 2>/dev/null || true
}

for product in 027b 027e 0340; do
  result=$(query_hwdb "touchpad:usb:v05acp${product}:name:Apple Inc. Apple Internal Keyboard / Trackpad:")
  grep -Fxq 'ID_INPUT_TOUCHPAD_INTEGRATION=internal' <<<"$result" ||
    fail "T2 internal trackpad product $product is classified as internal" "$result"
done
pass "known T2 internal trackpads match the shipped hwdb rule"

magic=$(query_hwdb 'touchpad:usb:v05acp0265:name:Apple Inc. Magic Trackpad:')
! grep -q 'ID_INPUT_TOUCHPAD_INTEGRATION=internal' <<<"$magic" ||
  fail "external Magic Trackpad is not classified as internal" "$magic"
pass "external Magic Trackpad stays outside the T2 override"

# Existing installs are repaired by a new migration, and rerunning it after the
# file is current must be a no-op.
stub_bin="$test_tmp/bin"
calls="$test_tmp/calls.log"
migration_output="$test_tmp/migration.out"
target_hwdb="$test_tmp/etc/udev/hwdb.d/71-omarchy-t2-trackpad.hwdb"
mkdir -p "$stub_bin"
: >"$calls"

cat >"$stub_bin/lspci" <<'SH'
#!/bin/bash
if (( ${T2_HARDWARE:-0} == 1 )); then
  echo '01:00.0 Bridge [0680]: Apple Inc. T2 Security Chip [106b:1801]'
else
  echo '00:00.0 Host bridge [0600]: Example [ffff:0000]'
fi
SH

cat >"$stub_bin/sudo" <<'SH'
#!/bin/bash
printf 'sudo' >>"$TEST_LOG"
printf '\t%s' "$@" >>"$TEST_LOG"
printf '\n' >>"$TEST_LOG"
"$@"
SH

cat >"$stub_bin/systemd-hwdb" <<'SH'
#!/bin/bash
printf 'systemd-hwdb' >>"$TEST_LOG"
printf '\t%s' "$@" >>"$TEST_LOG"
printf '\n' >>"$TEST_LOG"
SH

cat >"$stub_bin/udevadm" <<'SH'
#!/bin/bash
printf 'udevadm' >>"$TEST_LOG"
printf '\t%s' "$@" >>"$TEST_LOG"
printf '\n' >>"$TEST_LOG"
SH

chmod +x "$stub_bin"/*

run_migration() {
  PATH="$stub_bin:$PATH" \
    TEST_LOG="$calls" \
    T2_HARDWARE="$1" \
    OMARCHY_PATH="$ROOT" \
    OMARCHY_T2_TRACKPAD_HWDB="$target_hwdb" \
    bash -euo pipefail "$migration" >"$migration_output"
}

run_migration 1
cmp -s "$hwdb" "$target_hwdb" ||
  fail "T2 migration installs the exact shipped hwdb rule"
grep -Fq $'systemd-hwdb\tupdate' "$calls" ||
  fail "T2 migration recompiles the hwdb" "$(cat "$calls")"
grep -Fq $'udevadm\ttrigger\t--subsystem-match=input\t--action=change' "$calls" ||
  fail "T2 migration retriggers input devices" "$(cat "$calls")"
grep -Fq 'Log out and back in or reboot to activate disable-while-typing' "$migration_output" ||
  fail "T2 migration tells existing users when a new session is required" "$(cat "$migration_output")"
pass "T2 migration repairs existing installs and explains activation"

: >"$calls"
run_migration 1
[[ ! -s $calls ]] ||
  fail "T2 migration is idempotent once the rule is current" "$(cat "$calls")"
! grep -Fq 'Log out and back in or reboot to activate disable-while-typing' "$migration_output" ||
  fail "T2 migration does not repeat activation guidance when no repair was needed" "$(cat "$migration_output")"
pass "T2 migration leaves an already-current rule alone"

rm -f "$target_hwdb"
: >"$calls"
run_migration 0
[[ ! -e $target_hwdb ]] ||
  fail "non-T2 systems do not receive the trackpad override"
[[ ! -s $calls ]] ||
  fail "non-T2 systems skip hwdb activation" "$(cat "$calls")"
! grep -Fq 'Log out and back in or reboot to activate disable-while-typing' "$migration_output" ||
  fail "non-T2 systems do not receive T2 activation guidance" "$(cat "$migration_output")"
pass "T2 migration skips unrelated hardware"
