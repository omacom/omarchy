#!/bin/bash

# Test omarchy-hw-msi detection via OMARCHY_DMI_ID_PATH stubs.
# The detector reads /sys/class/dmi/id/{sys_vendor,product_family,product_name}
# to identify MSI laptops. We point OMARCHY_DMI_ID_PATH at a fixture tree
# to exercise vendor string, product family, and laptop-vs-desktop filtering.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

write_dmi_ids() {
  mkdir -p "$tmp_dir/dmi/id"
  printf '%s' "$1" >"$tmp_dir/dmi/id/sys_vendor"
  printf '%s' "$2" >"$tmp_dir/dmi/id/product_family"
  printf '%s' "$3" >"$tmp_dir/dmi/id/product_name"
}

hw_msi() {
  OMARCHY_DMI_ID_PATH="$tmp_dir/dmi/id" "$ROOT/bin/omarchy-hw-msi"
}

assert_msi() {
  local description="$1" expected="$2"
  local actual=no
  hw_msi && actual=yes
  [[ $actual == "$expected" ]] || fail "$description" "expected $expected, got $actual"
  pass "$description"
}

# === MSI laptops — should detect (all 14 families) ===

write_dmi_ids "Micro-Star International Co., Ltd." "Titan GT77HX 13VI" "Titan GT77HX 13VI"
assert_msi "Titan GT77HX 13VI detected" yes

write_dmi_ids "Micro-Star International Co., Ltd." "Stealth 16 Studio A13V" "Stealth 16 Studio A13V"
assert_msi "Stealth 16 Studio detected" yes

write_dmi_ids "Micro-Star International Co., Ltd." "Raider GE78HX 13V" "Raider GE78HX 13V"
assert_msi "Raider GE78HX detected" yes

write_dmi_ids "Micro-Star International Co., Ltd." "Vector 17 HX B14V" "Vector 17 HX B14V"
assert_msi "Vector 17 HX detected" yes

write_dmi_ids "Micro-Star International Co., Ltd." "Crosshair 17 HX D14V" "Crosshair 17 HX D14V"
assert_msi "Crosshair 17 HX detected" yes

write_dmi_ids "Micro-Star International Co., Ltd." "Summit E16 Flip Evo A13MT" "Summit E16 Flip Evo A13MT"
assert_msi "Summit E16 Flip detected" yes

write_dmi_ids "Micro-Star International Co., Ltd." "Creator Z17 HX Studio A13V" "Creator Z17 HX Studio A13V"
assert_msi "Creator Z17 detected" yes

write_dmi_ids "Micro-Star International Co., Ltd." "Modern 15 H B13M" "Modern 15 H B13M"
assert_msi "Modern 15 detected" yes

write_dmi_ids "Micro-Star International Co., Ltd." "Katana 17 B13V" "Katana 17 B13V"
assert_msi "Katana 17 detected" yes

write_dmi_ids "Micro-Star International Co., Ltd." "Cyborg 15 A13VF" "Cyborg 15 A13VF"
assert_msi "Cyborg 15 detected" yes

write_dmi_ids "Micro-Star International Co., Ltd." "Pulse 17 B13V" "Pulse 17 B13V"
assert_msi "Pulse 17 detected" yes

write_dmi_ids "Micro-Star International Co., Ltd." "Bravo 15 B7E" "Bravo 15 B7E"
assert_msi "Bravo 15 detected" yes

write_dmi_ids "Micro-Star International Co., Ltd." "Alpha 17 B5E" "Alpha 17 B5E"
assert_msi "Alpha 17 detected" yes

write_dmi_ids "Micro-Star International Co., Ltd." "Prestige 16 Evo B13M" "Prestige 16 Evo B13M"
assert_msi "Prestige 16 Evo detected" yes

# === Edge cases — product_family only ===

write_dmi_ids "Micro-Star International Co., Ltd." "Titan GT77HX 13VI" ""
assert_msi "Titan detected (family only)" yes

write_dmi_ids "Micro-Star International Co., Ltd." "" "Titan GT77HX 13VI"
assert_msi "Titan detected (name only)" yes

# === MSI desktop — should NOT detect ===

write_dmi_ids "Micro-Star International Co., Ltd." "MEG X670E ACE" "MEG X670E ACE"
assert_msi "MSI desktop board rejected" no

write_dmi_ids "Micro-Star International Co., Ltd." "MAG B760M MORTAR WIFI" "MAG B760M MORTAR WIFI"
assert_msi "MSI motherboard rejected" no

write_dmi_ids "Micro-Star International Co., Ltd." "" ""
assert_msi "MSI with empty DMI fields rejected" no

# === Other vendors — should NOT detect ===

write_dmi_ids "ASUSTeK COMPUTER INC." "ROG Strix G733ZW" "ROG Strix G733ZW"
assert_msi "ASUS ROG rejected" no

write_dmi_ids "Dell Inc." "XPS 15 9530" "XPS 15 9530"
assert_msi "Dell XPS rejected" no

write_dmi_ids "LENOVO" "Legion 5 16IRX9" "Legion 5 16IRX9"
assert_msi "Lenovo Legion rejected" no

write_dmi_ids "HP" "Omen 16" "Omen 16"
assert_msi "HP Omen rejected" no

write_dmi_ids "Acer Incorporated" "Predator Helios 16" "Predator Helios 16"
assert_msi "Acer Predator rejected" no

write_dmi_ids "Framework" "Laptop 16" "Laptop 16"
assert_msi "Framework 16 rejected" no

# === Completely empty ===

write_dmi_ids "" "" ""
assert_msi "Empty DMI IDs rejected" no

# === msi.sh install script tests ===

pass "msi.sh exists"
[[ -f "$ROOT/install/hardware/msi.sh" ]] || fail "msi.sh missing"

pass "msi.sh references r8125-dkms"
grep -q "r8125-dkms" "$ROOT/install/hardware/msi.sh" || fail "r8125-dkms not referenced"

pass "msi.sh references msi-ec-dkms-git"
grep -q "msi-ec-dkms-git" "$ROOT/install/hardware/msi.sh" || fail "msi-ec-dkms-git not referenced"

pass "msi.sh references coolercontrol"
grep -q "coolercontrol" "$ROOT/install/hardware/msi.sh" || fail "coolercontrol not referenced"

pass "msi.sh references thermald"
grep -q "thermald" "$ROOT/install/hardware/msi.sh" || fail "thermald not referenced"

pass "msi.sh references nvidia-settings"
grep -q "nvidia-settings" "$ROOT/install/hardware/msi.sh" || fail "nvidia-settings not referenced"

pass "msi.sh sets battery charge thresholds"
grep -q "charge_control" "$ROOT/install/hardware/msi.sh" || fail "battery thresholds missing"

pass "msi.sh guards r8169 blacklist with r8125 loaded check"
grep -q "lsmod.*r8125" "$ROOT/install/hardware/msi.sh" || fail "r8125 guard missing"

pass "msi.sh uses install -Dm644 for atomic writes"
grep -q "install -Dm644" "$ROOT/install/hardware/msi.sh" || fail "install -Dm644 missing"

pass "msi.sh uses tee for sysfs writes"
grep -q "tee" "$ROOT/install/hardware/msi.sh" || fail "tee for sysfs missing"

pass "msi.sh has set -euo pipefail"
grep -q "set -euo pipefail" "$ROOT/install/hardware/msi.sh" || fail "set -euo pipefail missing"

pass "msi.sh does NOT use local keyword"
! grep -qw "local" "$ROOT/install/hardware/msi.sh" || fail "local keyword found"
