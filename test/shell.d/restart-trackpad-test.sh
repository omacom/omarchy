#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

bin_dir="$test_tmp/bin"
mkdir -p "$bin_dir"

# Mock sudo
cat >"$bin_dir/sudo" <<'EOF'
#!/bin/bash
"$@"
EOF
chmod +x "$bin_dir/sudo"

PATH="$bin_dir:$PATH"

sysfs_mock="$test_tmp/sys"
mkdir -p "$sysfs_mock/bus/i2c/drivers/elan_i2c/i2c-ELAN1000:00"
touch "$sysfs_mock/bus/i2c/drivers/elan_i2c/unbind" "$sysfs_mock/bus/i2c/drivers/elan_i2c/bind"

script="$test_tmp/omarchy-restart-trackpad"
sed "s|/sys/bus/i2c/drivers|$sysfs_mock/bus/i2c/drivers|g" "$ROOT/bin/omarchy-restart-trackpad" >"$script"
chmod +x "$script"

# Test 1: Resetting elan_i2c device
output=$(bash "$script")
[[ $output == *"Resetting i2c-ELAN1000:00 via elan_i2c unbind/rebind..."* ]] || fail "restarts elan_i2c trackpad" "$output"
[[ $output == *"Done"* ]] || fail "completes restart for elan_i2c" "$output"
pass "restarts elan_i2c trackpad"

# Test 2: Unbind and bind received the device name
unbind_content=$(cat "$sysfs_mock/bus/i2c/drivers/elan_i2c/unbind")
[[ $unbind_content == *"i2c-ELAN1000:00"* ]] || fail "unbound elan_i2c device" "$unbind_content"
bind_content=$(cat "$sysfs_mock/bus/i2c/drivers/elan_i2c/bind")
[[ $bind_content == *"i2c-ELAN1000:00"* ]] || fail "re-bound elan_i2c device" "$bind_content"
pass "writes device to unbind and bind files"

# Test 3: Error when no devices found
rm -rf "$sysfs_mock/bus/i2c/drivers/elan_i2c/i2c-ELAN1000:00"
if bash "$script" >"$test_tmp/err.out" 2>&1; then
  fail "expected failure when no trackpad is found"
fi
err_out=$(cat "$test_tmp/err.out")
[[ $err_out == *"No supported trackpad device found to restart."* ]] || fail "reports missing trackpad error" "$err_out"
pass "reports error and exits non-zero when no trackpad is found"
