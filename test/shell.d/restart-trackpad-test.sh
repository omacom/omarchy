#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

mock_bin="$tmp_dir/bin"
sysfs_root="$tmp_dir/sys"
mkdir -p "$mock_bin"

cat >"$mock_bin/sudo" <<'SH'
#!/bin/bash
# The helper only elevates tee/modprobe; run the requested command as-is.
exec "$@"
SH
cat >"$mock_bin/lsmod" <<'SH'
#!/bin/bash
exit 0
SH
chmod +x "$mock_bin/sudo" "$mock_bin/lsmod"

run_restart() {
  PATH="$mock_bin:$PATH" \
    OMARCHY_TEST_SYSFS_ROOT="$sysfs_root" \
    OMARCHY_TEST_TRACKPAD_REBIND_PAUSE=0 \
    "$ROOT/bin/omarchy-restart-trackpad" "$@"
}

# No matching driver: must fail loudly instead of exiting 0 with no output.
if run_restart >"$tmp_dir/out" 2>"$tmp_dir/err"; then
  fail "restart-trackpad should fail when no supported driver is present"
fi
[[ ! -s $tmp_dir/out ]] || fail "unsupported restart-trackpad should stay silent on stdout"
grep -F 'No supported trackpad driver' "$tmp_dir/err" >/dev/null ||
  fail "restart-trackpad should explain the unsupported driver case"
pass "restart-trackpad fails clearly when no supported driver is present"

# elan_i2c-only hardware (the ASUS case from #13398): reset that driver.
elan_dir="$sysfs_root/bus/i2c/drivers/elan_i2c"
mkdir -p "$elan_dir/i2c-ELAN1000:00"
: >"$elan_dir/unbind"
: >"$elan_dir/bind"

run_restart >"$tmp_dir/elan-out" 2>"$tmp_dir/elan-err"
grep -F 'Resetting i2c-ELAN1000:00 via elan_i2c unbind/rebind' "$tmp_dir/elan-out" >/dev/null ||
  fail "restart-trackpad should reset an elan_i2c touchpad"
grep -Fx 'Done' "$tmp_dir/elan-out" >/dev/null ||
  fail "restart-trackpad should report Done after an elan_i2c reset"
[[ $(cat "$elan_dir/unbind") == "i2c-ELAN1000:00" ]] ||
  fail "restart-trackpad should unbind the elan_i2c device"
[[ $(cat "$elan_dir/bind") == "i2c-ELAN1000:00" ]] ||
  fail "restart-trackpad should rebind the elan_i2c device"
[[ ! -s $tmp_dir/elan-err ]] || fail "elan_i2c reset should not write to stderr"
pass "restart-trackpad resets elan_i2c touchpads"

# i2c_hid_acpi still works as before.
rm -rf "$sysfs_root"
hid_dir="$sysfs_root/bus/i2c/drivers/i2c_hid_acpi"
mkdir -p "$hid_dir/i2c-SYNA2393:00"
: >"$hid_dir/unbind"
: >"$hid_dir/bind"

run_restart >"$tmp_dir/hid-out" 2>"$tmp_dir/hid-err"
grep -F 'Resetting i2c-SYNA2393:00 via i2c_hid_acpi unbind/rebind' "$tmp_dir/hid-out" >/dev/null ||
  fail "restart-trackpad should still reset i2c_hid_acpi devices"
[[ $(cat "$hid_dir/unbind") == "i2c-SYNA2393:00" && $(cat "$hid_dir/bind") == "i2c-SYNA2393:00" ]] ||
  fail "restart-trackpad should unbind/rebind the i2c_hid_acpi device"
pass "restart-trackpad still resets i2c_hid_acpi devices"
