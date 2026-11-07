#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Apple Silicon Touch Bar support is the 13-inch M1/M2 MacBook Pros only.
# Intel T2 bars and every other Mac stay on their existing path.

grep -Fq 'hardware/apple/touchbar.sh' "$ROOT/install/hardware/all.sh" ||
  fail "hardware setup runs the Touch Bar leaf"
! grep -qx 'tiny-dfr' "$ROOT/install/omarchy-aarch64-apple.packages" ||
  fail "tiny-dfr stays off the shared Apple Silicon package list"
! grep -qx 'tiny-dfr' "$ROOT/install/omarchy-other.packages" ||
  fail "the shared package list does not cache tiny-dfr"
! grep -q 'tiny-dfr' "$ROOT/install/hardware/apple/fix-t2.sh" ||
  fail "T2 setup still leaves tiny-dfr uninstalled"
grep -Fq 'require("default.hypr.apple-touchbar")' "$ROOT/default/hypr/envs.lua" ||
  fail "Hyprland loads the Touch Bar DRM exclusion"
[[ $(head -n 1 "$ROOT/migrations/1794057900.sh") != '#!'* ]] ||
  fail "the Touch Bar migration has no shebang"
[[ $(stat -c '%a' "$ROOT/migrations/1794057900.sh") == "644" ]] ||
  fail "the Touch Bar migration is not executable"
[[ $(head -n 1 "$ROOT/install/hardware/apple/touchbar.sh") != '#!'* ]] ||
  fail "the Touch Bar install leaf has no shebang"
pass "Touch Bar install is wired only for its own leaf"

require_platform_fixtures "mocked DMI and sysfs"
require_command lua

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

fixture="$test_tmp/machine"
calls="$test_tmp/calls"
mkdir -p "$fixture/bin"
: >"$calls"

cat >"$fixture/bin/omarchy-pkg-add" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$PKG_CALLS"
SH
chmod +x "$fixture/bin/omarchy-pkg-add"

export PKG_CALLS="$calls"

write_tree() {
  local platform=$1 compatible=$2 product=$3
  local -a tokens=()

  rm -rf "$fixture"
  fake_platform "$fixture" "$platform"
  mkdir -p "$fixture/bin" "$fixture/sys"
  cp "$test_tmp/machine-pkg" "$fixture/bin/omarchy-pkg-add" 2>/dev/null || true

  if [[ -n $compatible ]]; then
    read -r -a tokens <<<"$compatible"
    mkdir -p "$fixture/sys/firmware/devicetree/base"
    if [[ -d $fixture/proc/device-tree ]]; then
      printf '%s\0' "${tokens[@]}" >"$fixture/proc/device-tree/compatible"
    else
      mkdir -p "$fixture/proc/device-tree"
      printf '%s\0' "${tokens[@]}" >"$fixture/proc/device-tree/compatible"
    fi
    printf '%s\0' "${tokens[@]}" >"$fixture/sys/firmware/devicetree/base/compatible"
  fi

  if [[ -n $product ]]; then
    mkdir -p "$fixture/sys/class/dmi/id"
    printf '%s\n' "$product" >"$fixture/sys/class/dmi/id/product_name"
  fi
}

# fake_platform recreates the tree, so keep the package stub outside it.
cp "$fixture/bin/omarchy-pkg-add" "$test_tmp/machine-pkg"
chmod +x "$test_tmp/machine-pkg"

use_fixture() {
  export OMARCHY_PROC_ROOT="$fixture/proc" OMARCHY_SYS_ROOT="$fixture/sys"
  export PATH="$fixture/bin:$ROOT/bin:${PATH#"$fixture/bin:"}"
  cp "$test_tmp/machine-pkg" "$fixture/bin/omarchy-pkg-add"
  chmod +x "$fixture/bin/omarchy-pkg-add"
  : >"$calls"
}

expect_model() {
  local want=$1 description=$2
  local status=0

  "$ROOT/bin/omarchy-hw-apple-touchbar" || status=$?
  if [[ $want == yes ]]; then
    [[ $status == 0 ]] || fail "$description" "exit $status"
  else
    [[ $status != 0 ]] || fail "$description" "matched"
  fi
  pass "$description"
}

run_leaf() {
  bash -eE -c 'source "$1"' _ "$ROOT/install/hardware/apple/touchbar.sh"
}

expect_install() {
  local want=$1 description=$2

  : >"$calls"
  run_leaf
  if [[ $want == yes ]]; then
    grep -Fxq 'tiny-dfr' "$calls" || fail "$description" "$(cat "$calls")"
  else
    [[ ! -s $calls ]] || fail "$description" "$(cat "$calls")"
  fi
  pass "$description"
}

write_tree aarch64-apple "apple,j293 apple,t8103 apple,arm-platform" "MacBookPro17,1"
use_fixture
expect_model yes "M1 MacBookPro17,1 / j293 is a Touch Bar Mac"
expect_install yes "M1 MacBookPro17,1 installs tiny-dfr"

write_tree aarch64-apple "apple,j493 apple,t8112 apple,arm-platform" "Mac14,7"
use_fixture
expect_model yes "M2 Mac14,7 / j493 is a Touch Bar Mac"
expect_install yes "M2 Mac14,7 installs tiny-dfr"

write_tree aarch64-apple "apple,t8103 apple,arm-platform" "  MacBookPro17,1  "
use_fixture
expect_model yes "DMI MacBookPro17,1 is enough when the board id is generic"
expect_install yes "DMI MacBookPro17,1 installs tiny-dfr"

write_tree aarch64-apple "apple,arm-platform" ""
rm -rf "$fixture/proc/device-tree"
mkdir -p "$fixture/sys/firmware/devicetree/base"
printf '%s\0' apple,j293 apple,t8103 apple,arm-platform >"$fixture/sys/firmware/devicetree/base/compatible"
use_fixture
expect_model yes "sysfs apple,j293 is enough with no DMI and no proc tree"
expect_install yes "sysfs apple,j293 installs tiny-dfr"

write_tree aarch64-apple "apple,j313 apple,t8103 apple,arm-platform" "MacBookPro17,1"
use_fixture
expect_model yes "a Touch Bar DMI name still matches when the board id does not"

write_tree aarch64-apple "apple,j293 apple,t8103 apple,arm-platform" "MacBookAir10,1"
use_fixture
expect_model yes "a j293 board still matches when DMI names a MacBook Air"
expect_install yes "a j293 board installs tiny-dfr when DMI names a MacBook Air"

write_tree aarch64-apple "apple,j416c apple,t6021 apple,arm-platform" "MacBookPro18,2"
use_fixture
expect_model no "a 16-inch M1 Max MacBook Pro is not a Touch Bar Mac"
expect_install no "a 16-inch M1 Max does not install tiny-dfr"

write_tree aarch64-apple "apple,j313 apple,t8103 apple,arm-platform" "MacBookAir10,1"
use_fixture
mkdir -p "$fixture/sys/class/dmi/id"
printf '%s\n' "MacBookPro17,1" >"$fixture/sys/class/dmi/id/product_family"
expect_model no "an Air stays excluded when only the DMI family mentions a Touch Bar"
expect_install no "an Air does not install tiny-dfr"

write_tree aarch64-apple "apple,j316s apple,t6000 apple,arm-platform" "MacBookPro18,1"
use_fixture
expect_model no "a 16-inch M1 Pro MacBook Pro is not a Touch Bar Mac"

write_tree aarch64-apple "apple,arm-platform" "MacBookPro17,10"
use_fixture
expect_model no "MacBookPro17,10 is not MacBookPro17,1"

write_tree aarch64-apple "apple,arm-platform" "Mac14,70"
use_fixture
expect_model no "Mac14,70 is not Mac14,7"

write_tree aarch64-apple "apple,j2930 apple,arm-platform" ""
use_fixture
expect_model no "apple,j2930 is not the j293 board"

write_tree aarch64-apple "apple,t8103 apple,arm-platform" ""
use_fixture
expect_model no "Apple Silicon without a Touch Bar identity does not match"

write_tree x86 "" "MacBookPro16,1"
use_fixture
expect_model no "an Intel T2 MacBookPro16,1 is not an Apple Silicon Touch Bar"
expect_install no "an Intel T2 Mac does not install tiny-dfr"

write_tree x86 "" "MacBookPro17,1"
use_fixture
expect_model no "a PC whose DMI says MacBookPro17,1 is not Apple Silicon"
expect_install no "a PC whose DMI says MacBookPro17,1 does not install tiny-dfr"

write_tree aarch64 "" "MacBookPro17,1"
use_fixture
expect_model no "a non-Apple ARM board whose DMI says MacBookPro17,1 does not match"
expect_install no "a non-Apple ARM board does not install tiny-dfr"

write_tree aarch64-apple "apple,j293 apple,t8103 apple,arm-platform" "MacBookPro17,1"
use_fixture
cat >"$fixture/bin/omarchy-pkg-add" <<'SH'
#!/bin/bash
exit 1
SH
chmod +x "$fixture/bin/omarchy-pkg-add"
if run_leaf; then
  fail "a failed tiny-dfr install fails the hardware leaf"
fi
pass "a failed tiny-dfr install fails the hardware leaf"
cp "$test_tmp/machine-pkg" "$fixture/bin/omarchy-pkg-add"
chmod +x "$fixture/bin/omarchy-pkg-add"

: >"$calls"
OMARCHY_PATH="$ROOT" bash -euo pipefail "$ROOT/migrations/1794057900.sh"
grep -Fxq 'tiny-dfr' "$calls" || fail "the migration installs tiny-dfr on a Touch Bar Mac" "$(cat "$calls")"
pass "the migration installs tiny-dfr on a Touch Bar Mac"

write_tree x86 "" "MacBookPro16,1"
use_fixture
OMARCHY_PATH="$ROOT" bash -euo pipefail "$ROOT/migrations/1794057900.sh"
[[ ! -s $calls ]] || fail "the migration leaves an Intel T2 Mac alone" "$(cat "$calls")"
pass "the migration leaves an Intel T2 Mac alone"

write_tree aarch64-apple "apple,j313 apple,t8103 apple,arm-platform" "MacBookAir10,1"
use_fixture
OMARCHY_PATH="$ROOT" bash -euo pipefail "$ROOT/migrations/1794057900.sh"
[[ ! -s $calls ]] || fail "the migration leaves a MacBook Air alone" "$(cat "$calls")"
pass "the migration leaves a MacBook Air alone"

# DRM exclusion: only the adp card is dropped, and only when one is present.
drm() {
  "$ROOT/bin/omarchy-hw-apple-touchbar-drm"
}

reset_drm() {
  rm -rf "$fixture/sys"
  mkdir -p "$fixture/sys"
  export OMARCHY_SYS_ROOT="$fixture/sys"
  unset OMARCHY_DRI_PATH
}

add_card() {
  local name=$1 driver=$2
  local device=$fixture/sys/class/drm/$name/device
  mkdir -p "$device"
  if [[ $driver == link:* ]]; then
    ln -s "../../../../bus/platform/drivers/${driver#link:}" "$device/driver"
  else
    printf 'DRIVER=%s\nMODALIAS=ignored\n' "$driver" >"$device/uevent"
  fi
}

expect_drm() {
  local expected=$1 description=$2
  local actual
  actual=$(drm)
  [[ $actual == "$expected" ]] || fail "$description" "expected: $expected"$'\n'"actual:   $actual"
  pass "$description"
}

reset_drm
add_card card0 apple
add_card card1 adp
mkdir -p "$fixture/sys/class/drm/card1-DSI-1/device"
printf 'DRIVER=adp\n' >"$fixture/sys/class/drm/card1-DSI-1/device/uevent"
add_card card2 appletbdrm
expect_drm "/dev/dri/card0:/dev/dri/card2" "Hyprland keeps the display and a T2-style card, and drops only adp"

reset_drm
add_card card1 adp
expect_drm "" "an adp card with no other card does not blank Hyprland"

reset_drm
add_card card0 apple
add_card card2 apple-drm
expect_drm "" "no Touch Bar card leaves AQ_DRM_DEVICES unset"

reset_drm
add_card card0 adp
add_card card2 apple
add_card card10 apple-drm
expect_drm "/dev/dri/card2:/dev/dri/card10" "remaining cards stay in card-number order"

reset_drm
add_card card0 apple
add_card card3 "link:adp"
expect_drm "/dev/dri/card0" "an adp driver symlink is the Touch Bar when uevent has no DRIVER"

reset_drm
add_card card0 apple
mkdir -p "$fixture/sys/class/drm/card1/device"
ln -s "../../../../bus/platform/drivers/adp" "$fixture/sys/class/drm/card1/device/driver"
printf 'DRIVER=apple\n' >"$fixture/sys/class/drm/card1/device/uevent"
expect_drm "" "a DRIVER= value wins over a stale adp driver symlink"

reset_drm
add_card card0 apple
add_card card1 adp
export OMARCHY_DRI_PATH="/tmp/a:b"
expect_drm "" "a DRM path containing a colon is not written into AQ_DRM_DEVICES"
unset OMARCHY_DRI_PATH

hypr_env() {
  env -u AQ_DRM_DEVICES lua <<'LUA'
package.path = os.getenv("ROOT") .. "/?.lua;" .. package.path
require("default.hypr.helpers")
local env = {}
hl = { env = function(key, value) env[key] = value end }
require("default.hypr.apple-touchbar")
print(env.AQ_DRM_DEVICES or "-")
LUA
}

export ROOT OMARCHY_PATH="$ROOT"
reset_drm
add_card card0 apple
add_card card1 adp
add_card card2 apple-drm
[[ $(hypr_env) == "/dev/dri/card0:/dev/dri/card2" ]] ||
  fail "Hyprland exports every card except the Touch Bar" "$(hypr_env)"
pass "Hyprland exports every card except the Touch Bar"

reset_drm
add_card card0 apple
[[ $(hypr_env) == "-" ]] || fail "Hyprland sets nothing when there is no Touch Bar card" "$(hypr_env)"
pass "Hyprland sets nothing when there is no Touch Bar card"

reset_drm
add_card card0 apple
add_card card1 adp
actual=$(AQ_DRM_DEVICES=/dev/dri/card9 lua <<'LUA'
package.path = os.getenv("ROOT") .. "/?.lua;" .. package.path
require("default.hypr.helpers")
local env = {}
hl = { env = function(key, value) env[key] = value end }
require("default.hypr.apple-touchbar")
print(env.AQ_DRM_DEVICES or "-")
LUA
)
[[ $actual == "-" ]] || fail "a caller-supplied AQ_DRM_DEVICES is left as set" "$actual"
pass "a caller-supplied AQ_DRM_DEVICES is left as set"
