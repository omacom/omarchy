#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/base-test.sh"
require_command lua
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mkdir -p "$test_tmp/bin" "$test_tmp/dmi"

grep -q 'run_logged .*hardware/gpd-pocket-4.sh' "$ROOT/install/hardware/all.sh" || fail "hardware setup is wired"
grep -q 'require("default.hypr.gpd-pocket-4")' "$ROOT/default/hypr/omarchy.lua" || fail "fixed session defaults are wired"
! grep -q 'iio-sensor-proxy' "$ROOT/install/hardware/gpd-pocket-4.sh" || fail "baseline must not install the sensor service"
! grep -q 'gpd-pocket-4-rotate' "$ROOT/install/user/first-run/enable-user-units.sh" || fail "autorotation must not be enabled by baseline"
pass "fixed GPD compatibility is wired independently of autorotation"

# Execute the production Lua module, recording actual compositor calls.
# Use a file rather than stdin: Lua 5.5 may report stdin errors as success.
cat >"$test_tmp/check.lua" <<'LUA'
local module = arg[1]
package.loaded["default.hypr.paths"] = { omarchy_path = "/fixture" }
local matches = false
local calls = {}
o = {
  shell_quote = function(path) return path end,
  shell_succeeds = function(command)
    assert(command == "/fixture/bin/omarchy-hw-gpd-pocket-4")
    return matches
  end
}
hl = {
  monitor = function(config) calls[#calls + 1] = { "monitor", config } end,
  device = function(config) calls[#calls + 1] = { "device", config } end
}
dofile(module)
assert(#calls == 0, "other hardware must remain untouched")
matches = true
dofile(module)
assert(#calls == 2)
assert(calls[1][1] == "monitor" and calls[1][2].output == "eDP-1" and calls[1][2].transform == 3)
assert(calls[2][1] == "device" and calls[2][2].name == "nvtk0603:00-0603:f001" and calls[2][2].transform == 3)
calls = {}
dofile(module)
assert(#calls == 2 and calls[1][2].transform == calls[2][2].transform, "reload must restore matching transforms")
LUA
lua "$test_tmp/check.lua" "$ROOT/default/hypr/gpd-pocket-4.lua"
pass "production session defaults rotate monitor and touch together, survive reload and skip other hardware"

cat >"$test_tmp/bin/omarchy-hw-match" <<'SH'
#!/bin/bash
grep -qi "$1" "$OMARCHY_TEST_DMI/product_name" || grep -qi "$1" "$OMARCHY_TEST_DMI/product_family"
SH
chmod +x "$test_tmp/bin/omarchy-hw-match"
printf 'G1628-04\n' >"$test_tmp/dmi/product_name"
printf 'GPD Pocket 4\n' >"$test_tmp/dmi/product_family"
PATH="$test_tmp/bin:$PATH" OMARCHY_TEST_DMI="$test_tmp/dmi" "$ROOT/bin/omarchy-hw-gpd-pocket-4"
printf 'ThinkPad X1\n' >"$test_tmp/dmi/product_name"
printf 'ThinkPad\n' >"$test_tmp/dmi/product_family"
if PATH="$test_tmp/bin:$PATH" OMARCHY_TEST_DMI="$test_tmp/dmi" "$ROOT/bin/omarchy-hw-gpd-pocket-4"; then fail "detector accepts unrelated hardware"; fi
pass "real detector accepts GPD DMI and rejects unrelated machines"

grep -q 'sudo tee /etc/limine-entry-tool.d/gpd-pocket4-orientation.conf' "$ROOT/install/hardware/gpd-pocket-4.sh" || fail "boot setup must write as root"
grep -q 'sudo tee /etc/udev/rules.d/99-gpd-pocket4-touchscreen.rules' "$ROOT/install/hardware/gpd-pocket-4.sh" || fail "touch setup must write as root"
grep -q 'sudo limine-mkinitcpio' "$ROOT/migrations/1788852858.sh" || fail "migration must rebuild boot entries"
! grep -q 'systemctl\|iio-sensor' "$ROOT/migrations/1788852858.sh" || fail "baseline migration must not enable autorotation"
pass "boot and touch migration do not depend on autorotation"

# Execute the hardware leaf with a privileged filesystem view. The boot file
# cannot be found by an ordinary lookup, but sudo can access its backing file,
# modelling /boot mounted with fmask=0077,dmask=0077 without requiring root.
boot_file=$test_tmp/root-boot/limine.conf
hidden_boot_file=$test_tmp/unprivileged-boot/limine.conf
mkdir -p "$test_tmp/root-boot"
export boot_file hidden_boot_file
omarchy-hw-gpd-pocket-4() { return 0; }
sudo() {
  local command=$1
  shift
  case "$command" in
    test|grep|sed)
      local args=() arg
      for arg in "$@"; do
        if [[ $arg == "$hidden_boot_file" ]]; then
          args+=("$boot_file")
        else
          args+=("$arg")
        fi
      done
      command "$command" "${args[@]}"
      ;;
    tee) cat >/dev/null ;;
    mkdir|udevadm) return 0 ;;
    *) fail "unexpected privileged command: $command" ;;
  esac
}
run_hardware_leaf() {
  local script
  script=$(<"$ROOT/install/hardware/gpd-pocket-4.sh")
  source /dev/stdin <<< "${script//\/boot\/limine.conf/$hidden_boot_file}"
}
printf 'timeout: 5\n' > "$boot_file"
run_hardware_leaf
grep -qx 'interface_rotation: 90' "$boot_file" || fail "root-only boot config must receive Limine rotation"
run_hardware_leaf
[[ $(grep -c '^interface_rotation:' "$boot_file") == 1 ]] || fail "repeated setup must not duplicate rotation"
printf 'interface_rotation: 180\ntimeout: 5\n' > "$boot_file"
run_hardware_leaf
grep -qx 'interface_rotation: 180' "$boot_file" || fail "setup must preserve an existing Limine rotation"
[[ $(grep -c '^interface_rotation:' "$boot_file") == 1 ]] || fail "existing rotation must not be duplicated"
rm "$boot_file"
run_hardware_leaf
[[ ! -e $boot_file ]] || fail "setup must not create a missing Limine config"
pass "privileged Limine checks handle root-only boot, repeat runs, existing rotation and missing config"
