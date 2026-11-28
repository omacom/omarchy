#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
mkdir -p "$work/bin" "$work/repo/install/hardware/apple"

leaf="$ROOT/install/hardware/apple/fix-touchpad-typing.sh"
migration="$ROOT/migrations/1791969218.sh"
conf="$work/etc/udev/hwdb.d/71-omarchy-macbook-touchpad.hwdb"
calls="$work/calls"

# Redirect filesystem writes into the fixture, following the hardware tests.
sed "s|/etc/udev/hwdb.d|$work/etc/udev/hwdb.d|g" "$leaf" >"$work/repo/install/hardware/apple/fix-touchpad-typing.sh"

cat >"$work/bin/omarchy-hw-match" <<'SH'
#!/bin/bash
[[ ${TEST_MODEL:-Unknown} =~ $1 ]]
SH

cat >"$work/bin/sudo" <<'SH'
#!/bin/bash
printf 'sudo %s\n' "$*" >>"$TEST_CALLS"
"$@"
SH

cat >"$work/bin/systemd-hwdb" <<'SH'
#!/bin/bash
if [[ $1 == "query" ]]; then
  [[ $2 == "touchpad:usb:v05acp0263:name:bcm5974:" ]] || exit 1
  if [[ ${TEST_INTERNAL:-0} == "1" ]]; then
    echo "ID_INPUT_TOUCHPAD_INTEGRATION=internal"
  fi
else
  [[ $* == "update --strict" ]] || exit 1
  [[ ${TEST_UPDATE_FAIL:-0} == "0" ]]
fi
SH

cat >"$work/bin/omarchy-state" <<'SH'
#!/bin/bash
printf 'state %s\n' "$*" >>"$TEST_CALLS"
SH

chmod +x "$work/bin/"*

run_migration() {
  TEST_MODEL="${1:-MacBookPro11,3}" TEST_INTERNAL="${2:-0}" TEST_UPDATE_FAIL="${3:-0}" \
    TEST_CALLS="$calls" PATH="$work/bin:$PATH" OMARCHY_PATH="$work/repo" \
    bash -euo pipefail "$migration"
}

run_leaf() {
  TEST_MODEL=MacBookPro11,3 TEST_CALLS="$calls" PATH="$work/bin:$PATH" \
    bash -euo pipefail -c 'source "$1"' bash "$work/repo/install/hardware/apple/fix-touchpad-typing.sh"
}

grep -F 'run_logged "$OMARCHY_INSTALL/hardware/apple/fix-touchpad-typing.sh"' "$ROOT/install/hardware/all.sh" >/dev/null ||
  fail "the trackpad correction runs during new installation"
pass "the trackpad correction runs during new installation"

run_leaf
[[ -f $conf ]] || fail "a new installation receives the trackpad correction"
grep -Fx 'touchpad:usb:v05acp0263:name:bcm5974:*' "$conf" >/dev/null || fail "the correction matches the verified trackpad"
grep -Fx ' ID_INPUT_TOUCHPAD_INTEGRATION=internal' "$conf" >/dev/null || fail "the correction marks the trackpad internal"
grep -Fx 'sudo systemd-hwdb update --strict' "$calls" >/dev/null || fail "installation rebuilds the hardware database"
pass "new installations receive a compiled correction for the verified trackpad"

rm -rf "$work/etc"
: >"$calls"
run_migration
[[ -f $conf ]] || fail "the migration repairs an existing installation"
grep -Fx 'state set reboot-required' "$calls" >/dev/null || fail "the migration requests a reboot to reopen the trackpad"
pass "existing installations receive the correction and a reboot request"

: >"$calls"
run_migration
[[ ! -s $calls ]] || fail "repeated migrations must not modify the system or request another reboot"
pass "the repair is idempotent across users"

rm -rf "$work/etc"
: >"$calls"
run_migration MacBookPro11,3 1
[[ ! -e $conf && ! -s $calls ]] || fail "an upstream or local correction must not be replaced"
pass "an existing internal classification skips the workaround"

for model in MacBookPro11,1 MacBookPro11,30 MacBookPro18,3 ThinkPad Unknown; do
  : >"$calls"
  run_migration "$model"
  [[ ! -e $conf && ! -s $calls ]] || fail "unverified hardware is left untouched" "$model"
done
pass "unverified Mac models and other hardware are left untouched"

mkdir -p "$(dirname "$conf")"
printf '# administrator override\n' >"$conf"
: >"$calls"
run_migration
[[ $(cat "$conf") == "# administrator override" && ! -s $calls ]] || fail "administrator files must be preserved"
pass "administrator-authored files are preserved"

rm "$conf"
ln -s "$work/nonexistent" "$conf"
: >"$calls"
run_migration
[[ -L $conf && ! -s $calls ]] || fail "a dangling administrator symlink must be preserved"
pass "dangling administrator symlinks are preserved"

rm "$conf"
: >"$calls"
if run_migration MacBookPro11,3 0 1; then
  fail "a database rebuild failure must leave the migration pending"
fi
[[ ! -e $conf ]] || fail "a failed correction must not block the next attempt"
if grep -Fx 'state set reboot-required' "$calls" >/dev/null; then
  fail "a failed correction must not request a reboot"
fi
: >"$calls"
run_migration
[[ -f $conf ]] || fail "a failed correction must be retryable"
pass "database failures stay pending and can be retried"

# Compile the actual payload and test the hwdb matcher, not a mocked parser.
if command -v systemd-hwdb >/dev/null; then
  systemd-hwdb --root="$work" update --strict
  [[ $(systemd-hwdb --root="$work" query "touchpad:usb:v05acp0263:name:bcm5974:") == "ID_INPUT_TOUCHPAD_INTEGRATION=internal" ]] ||
    fail "the actual database matches the verified device"
  for key in \
    "touchpad:usb:v05acp0265:name:bcm5974:" \
    "touchpad:usb:v05acp0263:name:unrelated:" \
    "touchpad:usb:v1234p0263:name:bcm5974:" \
    "touchpad:bluetooth:v05acp0263:name:bcm5974:"; do
    [[ -z $(systemd-hwdb --root="$work" query "$key") ]] || fail "the database excludes other devices" "$key"
  done
  pass "the hardware database compiles and excludes other devices"
else
  skip "systemd-hwdb is unavailable; skipping actual database compilation"
fi
