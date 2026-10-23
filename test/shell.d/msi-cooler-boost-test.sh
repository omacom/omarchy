#!/bin/bash

# Titan GT77HX Cooler Boost watcher: hardware gate, 85C on / 70C off hysteresis,
# 30s sustained high-temp before enable, and --once against a stub msi-ec sysfs tree.

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
  actual=$("$ROOT/bin/omarchy-msi-cooler-boost-watch" --decide "$@")
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

# Hysteresis decision logic (no sustain): off until 85, stays on until 70
assert_decide "off at 84C stays off" off off 84 50
assert_decide "CPU 85C turns boost on" on off 85 50
assert_decide "GPU 85C turns boost on" on off 50 85
assert_decide "80C does not enable boost" off off 80 50
assert_decide "on at 71C stays on" on on 71 50
assert_decide "on at 70C turns boost off" off on 70 50
assert_decide "off at 70C stays off" off off 70 50
assert_decide "garbage temps stay off" off off x y

# --once: sustain requires 30s at >=85C (6 polls at 5s interval)
write_dmi_ids "Micro-Star International Co., Ltd." "Titan GT77HX 13VI" "Titan GT77HX 13VI"
mkdir -p "$tmp_dir/ec/cpu" "$tmp_dir/ec/gpu"
printf 'off\n' >"$tmp_dir/ec/cooler_boost"
printf '86\n' >"$tmp_dir/ec/cpu/realtime_temperature"
printf '48\n' >"$tmp_dir/ec/gpu/realtime_temperature"
export OMARCHY_MSI_SUSTAIN_FILE="$tmp_dir/sustain"
rm -f "$OMARCHY_MSI_SUSTAIN_FILE"

# 6 consecutive polls at 86C (30s accumulated) — should NOT turn on yet (needs >30s)
for i in 1 2 3 4 5 6; do
  OMARCHY_DMI_ID_PATH="$tmp_dir/dmi/id" OMARCHY_MSI_EC_PATH="$tmp_dir/ec" \
    "$ROOT/bin/omarchy-msi-cooler-boost-watch" --once
  [[ $(tr -d '[:space:]' <"$tmp_dir/ec/cooler_boost") == off ]] || fail "poll $i/7: boost turned on too early at 86C"
done
pass "6 polls at 86C does not enable boost (sustain not reached at exactly 30s)"

# 7th poll reaches 35s — should turn on
OMARCHY_DMI_ID_PATH="$tmp_dir/dmi/id" OMARCHY_MSI_EC_PATH="$tmp_dir/ec" \
  "$ROOT/bin/omarchy-msi-cooler-boost-watch" --once
[[ $(tr -d '[:space:]' <"$tmp_dir/ec/cooler_boost") == on ]] || fail "7th poll at 86C should enable boost"
pass "7th poll at 86C enables boost after >30s sustained"

# Exactly 85C counts as "at or above" — 6 polls still off, 7th enables
printf 'off\n' >"$tmp_dir/ec/cooler_boost"
printf '85\n' >"$tmp_dir/ec/cpu/realtime_temperature"
rm -f "$OMARCHY_MSI_SUSTAIN_FILE"
for i in 1 2 3 4 5 6; do
  OMARCHY_DMI_ID_PATH="$tmp_dir/dmi/id" OMARCHY_MSI_EC_PATH="$tmp_dir/ec" \
    "$ROOT/bin/omarchy-msi-cooler-boost-watch" --once
done
[[ $(tr -d '[:space:]' <"$tmp_dir/ec/cooler_boost") == off ]] || fail "exactly 85C should not enable before the sustain window elapses"
OMARCHY_DMI_ID_PATH="$tmp_dir/dmi/id" OMARCHY_MSI_EC_PATH="$tmp_dir/ec" \
  "$ROOT/bin/omarchy-msi-cooler-boost-watch" --once
[[ $(tr -d '[:space:]' <"$tmp_dir/ec/cooler_boost") == on ]] || fail "exactly 85C should enable after the sustain window"
pass "exactly 85C counts toward the sustain window"

# Drop below 70C — should turn off immediately
printf '69\n' >"$tmp_dir/ec/cpu/realtime_temperature"
OMARCHY_DMI_ID_PATH="$tmp_dir/dmi/id" OMARCHY_MSI_EC_PATH="$tmp_dir/ec" \
  "$ROOT/bin/omarchy-msi-cooler-boost-watch" --once
[[ $(tr -d '[:space:]' <"$tmp_dir/ec/cooler_boost") == off ]] || fail "boost should turn off at 69C"
pass "boost turns off immediately at 69C"

# Temp drops before sustain reached — counter resets
printf 'off\n' >"$tmp_dir/ec/cooler_boost"
printf '86\n' >"$tmp_dir/ec/cpu/realtime_temperature"
rm -f "$OMARCHY_MSI_SUSTAIN_FILE"
# 3 polls at 86C (15s)
for i in 1 2 3; do
  OMARCHY_DMI_ID_PATH="$tmp_dir/dmi/id" OMARCHY_MSI_EC_PATH="$tmp_dir/ec" \
    "$ROOT/bin/omarchy-msi-cooler-boost-watch" --once
done
[[ $(tr -d '[:space:]' <"$tmp_dir/ec/cooler_boost") == off ]] || fail "3 polls at 86C should not enable boost"
pass "3 polls at 86C does not enable boost"

# Temp drops to 70C — counter resets
printf '70\n' >"$tmp_dir/ec/cpu/realtime_temperature"
OMARCHY_DMI_ID_PATH="$tmp_dir/dmi/id" OMARCHY_MSI_EC_PATH="$tmp_dir/ec" \
  "$ROOT/bin/omarchy-msi-cooler-boost-watch" --once
[[ ! -f "$OMARCHY_MSI_SUSTAIN_FILE" ]] || fail "sustain counter should reset when temp drops"
pass "sustain counter resets when temp drops below threshold"

# 80C does not enable boost
printf 'off\n' >"$tmp_dir/ec/cooler_boost"
printf '80\n' >"$tmp_dir/ec/cpu/realtime_temperature"
OMARCHY_DMI_ID_PATH="$tmp_dir/dmi/id" OMARCHY_MSI_EC_PATH="$tmp_dir/ec" \
  "$ROOT/bin/omarchy-msi-cooler-boost-watch" --once
[[ $(tr -d '[:space:]' <"$tmp_dir/ec/cooler_boost") == off ]] || fail "80C does not enable boost"
pass "80C does not enable boost (threshold is 85)"

# Non-Titan hardware exits cleanly without touching the EC
write_dmi_ids "ASUSTeK COMPUTER INC." "ROG Strix G733ZW" "ROG Strix G733ZW"
printf 'off\n' >"$tmp_dir/ec/cooler_boost"
OMARCHY_DMI_ID_PATH="$tmp_dir/dmi/id" OMARCHY_MSI_EC_PATH="$tmp_dir/ec" \
  "$ROOT/bin/omarchy-msi-cooler-boost-watch" --once
[[ $(tr -d '[:space:]' <"$tmp_dir/ec/cooler_boost") == off ]] || fail "non-Titan hardware must not touch the EC"
pass "non-Titan hardware exits cleanly without touching the EC"

# systemd unit tests
[[ -f $ROOT/default/systemd/system/omarchy-msi-cooler-boost-watch.service ]] || fail "systemd unit missing"
pass "systemd unit exists"

grep -q "MSI_COOLER_BOOST_ON_AT=85" "$ROOT/default/systemd/system/omarchy-msi-cooler-boost-watch.service" || \
  fail "unit on-threshold is not 85"
pass "unit on-threshold is 85"

grep -q "MSI_COOLER_BOOST_OFF_AT=70" "$ROOT/default/systemd/system/omarchy-msi-cooler-boost-watch.service" || \
  fail "unit off-threshold is not 70"
pass "unit off-threshold is 70"

grep -q "MSI_COOLER_BOOST_SUSTAIN=30" "$ROOT/default/systemd/system/omarchy-msi-cooler-boost-watch.service" || \
  fail "unit sustain is not 30"
pass "unit sustain is 30"

grep -q "omarchy-hw-msi-titan" "$ROOT/install/hardware/msi.sh" || fail "msi.sh does not gate on titan"
pass "msi.sh enables watcher only on Titan"

grep -q "omarchy-msi-cooler-boost-watch.service" "$ROOT/install/hardware/msi.sh" || fail "msi.sh does not install unit"
pass "msi.sh installs cooler-boost unit"
