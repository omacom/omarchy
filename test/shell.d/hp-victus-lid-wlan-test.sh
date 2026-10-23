#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

leaf="$ROOT/install/hardware/hp/fix-victus-lid-wlan.sh"
hwdb="$ROOT/default/udev/hp-victus-lid-wlan.hwdb"

grep -q 'run_logged .*hardware/hp/fix-victus-lid-wlan.sh' "$ROOT/install/hardware/all.sh" ||
  fail "the Victus lid Wi-Fi fix runs during hardware setup"
pass "the Victus lid Wi-Fi fix runs during hardware setup"

grep -lq 'install/hardware/hp/fix-victus-lid-wlan.sh' "$ROOT"/migrations/*.sh ||
  fail "a migration applies the Victus lid Wi-Fi fix to existing installs"
pass "a migration applies the Victus lid Wi-Fi fix to existing installs"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mkdir -p "$test_tmp/bin"
calls="$test_tmp/calls"

cat >"$test_tmp/bin/sudo" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$TEST_CALLS"
SH

cat >"$test_tmp/bin/omarchy-hw-match" <<'SH'
#!/bin/bash
[[ ${TEST_PRODUCT,,} == *"${1,,}"* ]]
SH

chmod +x "$test_tmp/bin"/*

run_fix() {
  : >"$calls"

  TEST_CALLS="$calls" TEST_PRODUCT="$1" OMARCHY_PATH="$ROOT" PATH="$test_tmp/bin:$PATH" \
    bash -eE -c 'source "$1"' bash "$leaf"
}

run_fix "Victus by HP Gaming Laptop 16-s1xxx"
grep -qx "install -Dm644 $hwdb /etc/udev/hwdb.d/61-omarchy-hp-victus-lid-wlan.hwdb" "$calls" ||
  fail "the Victus 16-s1 gets the lid Wi-Fi keymap override" "$(<"$calls")"
grep -qx 'systemd-hwdb --usr update' "$calls" ||
  fail "the override is compiled into the hwdb pacman maintains" "$(<"$calls")"
pass "the Victus 16-s1 gets the lid Wi-Fi keymap override"

run_fix "Victus by HP Gaming Laptop 15-fb0xxx"
[[ ! -s $calls ]] || fail "other HP models keep their wireless key" "$(<"$calls")"
pass "other HP models keep their wireless key"

# Compile the override beside systemd's own keymap to prove it wins for this
# model and leaves the generic HP mapping alone everywhere else.
system_keyboard_hwdb=/usr/lib/udev/hwdb.d/60-keyboard.hwdb
if [[ ! -f $system_keyboard_hwdb ]] || omarchy-cmd-missing systemd-hwdb; then
  skip "the override beats systemd's generic HP wireless key mapping"
  exit 0
fi

victus="evdev:atkbd:dmi:bvnInsyde:bvrF.15:bd03/26/2025:br15.15:svnHP:pnVictusbyHPGamingLaptop16-s1xxx:pvr:rvnHP:rn8C9C:rvrKBCVersion99.47:cvnHP:ct10:cvrChassisVersion:skuA1BC2UA#ABA:"
elitebook="evdev:atkbd:dmi:bvnHP:bvrV70Ver.01.05.00:bd01/01/2024:svnHP:pnHPEliteBook840G10:pvr:rvnHP:rn8B41:cvnHP:ct10:"

hwdb_root="$test_tmp/root"
mkdir -p "$hwdb_root/usr/lib/udev/hwdb.d" "$hwdb_root/etc/udev/hwdb.d"
cp "$system_keyboard_hwdb" "$hwdb_root/usr/lib/udev/hwdb.d/"

d7_mapping() {
  systemd-hwdb --root "$hwdb_root" query "$1" | sed -n 's/^KEYBOARD_KEY_d7=//p'
}

systemd-hwdb --root "$hwdb_root" --usr update
[[ $(d7_mapping "$victus") == "wlan" ]] ||
  fail "systemd's generic HP keymap still maps 0xd7 to wlan on the Victus"

cp "$hwdb" "$hwdb_root/etc/udev/hwdb.d/61-omarchy-hp-victus-lid-wlan.hwdb"
systemd-hwdb --root "$hwdb_root" --usr update
[[ $(d7_mapping "$victus") == "reserved" ]] ||
  fail "the override beats systemd's generic HP wireless key mapping" "$(d7_mapping "$victus")"
[[ $(d7_mapping "$elitebook") == "wlan" ]] ||
  fail "other HP models keep 0xd7 as their wireless key" "$(d7_mapping "$elitebook")"
pass "the override beats systemd's generic HP wireless key mapping"
