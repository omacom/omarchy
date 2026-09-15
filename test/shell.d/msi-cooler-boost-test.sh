#!/bin/bash

# Titan GT77HX Cooler Boost watcher: hardware gate, 80C on / 70C off hysteresis,
# and --once against a stub msi-ec sysfs tree.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

export PATH="$ROOT/bin:$PATH"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

write_dmi_ids() {
  mkdir -p "$tmp_dir/dmi/id"
  printf '%s' "$1" >"$tmp_dir/dmi/id/sys_vendor"
  printf '%s' "$2" >"$tmp_dir/dmi/id/product_family"
  printf '%s' "$3" >"$tmp_dir/dmi/id/product_name"
}

hw_titan() {
  OMARCHY_DMI_ID_PATH="$tmp_dir/dmi/id" "$ROOT/bin/omarchy-hw-msi-titan"
}

assert_titan() {
  local description="$1" expected="$2"
  local actual=no
  hw_titan && actual=yes
  [[ $actual == "$expected" ]] || fail "$description" "expected $expected, got $actual"
  pass "$description"
}

assert_decide() {
  local description="$1" expected="$2"
  shift 2
  local actual
  actual=$(MSI_COOLER_BOOST_ON_AT=80 MSI_COOLER_BOOST_OFF_AT=70 \
    "$ROOT/bin/omarchy-msi-cooler-boost-watch" --decide "$@")
  [[ $actual == "$expected" ]] || fail "$description" "expected $expected, got $actual"
  pass "$description"
}

write_dmi_ids "Micro-Star International Co., Ltd." "Titan GT77HX 13VI" "Titan GT77HX 13VI"
assert_titan "Titan GT77HX 13VI detected" yes

write_dmi_ids "Micro-Star International Co., Ltd." "Titan GT77HX 13VH" "Titan GT77HX 13VH"
assert_titan "Titan GT77HX 13VH detected" yes

write_dmi_ids "Micro-Star International Co., Ltd." "Stealth 16 Studio A13V" "Stealth 16 Studio A13V"
assert_titan "Stealth is not a Titan" no

write_dmi_ids "Micro-Star International Co., Ltd." "MEG X670E ACE" "MEG X670E ACE"
assert_titan "MSI desktop rejected" no

write_dmi_ids "ASUSTeK COMPUTER INC." "ROG Strix G733ZW" "ROG Strix G733ZW"
assert_titan "ASUS rejected" no

# Hysteresis: off until 80, stays on until 70
assert_decide "off at 79C stays off" off off 79 50
assert_decide "CPU 80C turns boost on" on off 80 50
assert_decide "GPU 80C turns boost on" on off 50 80
assert_decide "on at 71C stays on" on on 71 50
assert_decide "on at 70C turns boost off" off on 70 50
assert_decide "off at 70C stays off" off off 70 50
assert_decide "garbage temps stay off" off off x y

# --once writes the stub EC when this DMI is a Titan
write_dmi_ids "Micro-Star International Co., Ltd." "Titan GT77HX 13VI" "Titan GT77HX 13VI"
mkdir -p "$tmp_dir/ec/cpu" "$tmp_dir/ec/gpu"
printf 'off\n' >"$tmp_dir/ec/cooler_boost"
printf '81\n' >"$tmp_dir/ec/cpu/realtime_temperature"
printf '48\n' >"$tmp_dir/ec/gpu/realtime_temperature"
OMARCHY_DMI_ID_PATH="$tmp_dir/dmi/id" OMARCHY_MSI_EC_PATH="$tmp_dir/ec" \
  MSI_COOLER_BOOST_ON_AT=80 MSI_COOLER_BOOST_OFF_AT=70 \
  "$ROOT/bin/omarchy-msi-cooler-boost-watch" --once
[[ $(tr -d '[:space:]' <"$tmp_dir/ec/cooler_boost") == on ]] || fail "--once enables boost at 81C"
pass "--once enables boost at 81C"

printf '65\n' >"$tmp_dir/ec/cpu/realtime_temperature"
OMARCHY_DMI_ID_PATH="$tmp_dir/dmi/id" OMARCHY_MSI_EC_PATH="$tmp_dir/ec" \
  MSI_COOLER_BOOST_ON_AT=80 MSI_COOLER_BOOST_OFF_AT=70 \
  "$ROOT/bin/omarchy-msi-cooler-boost-watch" --once
[[ $(tr -d '[:space:]' <"$tmp_dir/ec/cooler_boost") == off ]] || fail "--once disables boost at 65C"
pass "--once disables boost at 65C"

printf '75\n' >"$tmp_dir/ec/cpu/realtime_temperature"
printf 'off\n' >"$tmp_dir/ec/cooler_boost"
OMARCHY_DMI_ID_PATH="$tmp_dir/dmi/id" OMARCHY_MSI_EC_PATH="$tmp_dir/ec" \
  MSI_COOLER_BOOST_ON_AT=80 MSI_COOLER_BOOST_OFF_AT=70 \
  "$ROOT/bin/omarchy-msi-cooler-boost-watch" --once
[[ $(tr -d '[:space:]' <"$tmp_dir/ec/cooler_boost") == off ]] || fail "75C does not enable boost"
pass "75C does not enable boost (threshold is 80)"

[[ -f $ROOT/default/systemd/system/omarchy-msi-cooler-boost-watch.service ]] || fail "systemd unit missing"
pass "systemd unit exists"

grep -q "MSI_COOLER_BOOST_ON_AT=80" "$ROOT/default/systemd/system/omarchy-msi-cooler-boost-watch.service" || \
  fail "unit on-threshold is not 80"
pass "unit on-threshold is 80"

grep -q "omarchy-hw-msi-titan" "$ROOT/install/hardware/msi.sh" || fail "msi.sh does not gate on titan"
pass "msi.sh enables watcher only on Titan"

grep -q "omarchy-msi-cooler-boost-watch.service" "$ROOT/install/hardware/msi.sh" || fail "msi.sh does not install unit"
pass "msi.sh installs cooler-boost unit"
