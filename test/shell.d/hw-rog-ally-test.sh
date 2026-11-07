#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

dmi="$test_tmp/dmi"
mkdir -p "$dmi" "$dmi/lid" "$dmi/input"
: >"$dmi/sys_vendor"
: >"$dmi/product_name"
: >"$dmi/board_name"
printf '3\n' >"$dmi/chassis_type"

write_dmi() {
  printf '%s\n' "$1" >"$dmi/sys_vendor"
  printf '%s\n' "$2" >"$dmi/product_name"
  printf '%s\n' "$3" >"$dmi/board_name"
}

run_ally() {
  OMARCHY_DMI_SYS_VENDOR_PATH="$dmi/sys_vendor" \
    OMARCHY_DMI_PRODUCT_NAME_PATH="$dmi/product_name" \
    OMARCHY_DMI_BOARD_NAME_PATH="$dmi/board_name" \
    "$ROOT/bin/omarchy-hw-rog-ally"
}

run_laptop() {
  printf '%s\n' "$1" >"$dmi/chassis_type"
  OMARCHY_DMI_CHASSIS_TYPE_PATH="$dmi/chassis_type" \
    OMARCHY_DMI_SYS_VENDOR_PATH="$dmi/sys_vendor" \
    OMARCHY_DMI_PRODUCT_NAME_PATH="$dmi/product_name" \
    OMARCHY_DMI_BOARD_NAME_PATH="$dmi/board_name" \
    OMARCHY_ACPI_LID_PATH="$dmi/lid" \
    OMARCHY_INPUT_CLASS_PATH="$dmi/input" \
    PATH="$ROOT/bin:$PATH" \
    "$ROOT/bin/omarchy-hw-laptop"
}

# --- DMI: original Ally, not Ally X or a later board ---

vendor="ASUSTeK COMPUTER INC."

write_dmi "$vendor" "ROG Ally RC71L" "RC71L"
run_ally || fail "product ROG Ally RC71L is the original Ally"
pass "product ROG Ally RC71L is the original Ally"

write_dmi "$vendor" "ROG Ally RC71L_RC71L" "RC71L"
run_ally || fail "product ROG Ally RC71L_RC71L is the original Ally"
pass "product ROG Ally RC71L_RC71L is the original Ally"

write_dmi "$vendor" "ROG Ally RC71L_Action" "RC71L"
run_ally || fail "product ROG Ally RC71L_Action is the original Ally"
pass "product ROG Ally RC71L_Action is the original Ally"

write_dmi "$vendor" "ROG Ally" "RC71L"
run_ally || fail "board RC71L is the original Ally when the product string is short"
pass "board RC71L is the original Ally when the product string is short"

write_dmi "$vendor" "ROG Ally X RC72LA" "RC72LA"
if run_ally; then
  fail "Ally X product ROG Ally X RC72LA is not the original Ally"
fi
pass "Ally X product ROG Ally X RC72LA is not the original Ally"

write_dmi "$vendor" "ROG Ally X RC72LA_RC72LA" "RC72LA"
if run_ally; then
  fail "Ally X product ROG Ally X RC72LA_RC72LA is not the original Ally"
fi
pass "Ally X product ROG Ally X RC72LA_RC72LA is not the original Ally"

write_dmi "$vendor" "ROG Xbox Ally RC73YA" "RC73YA"
if run_ally; then
  fail "Xbox Ally RC73YA is not the original Ally"
fi
pass "Xbox Ally RC73YA is not the original Ally"

write_dmi "ASUS" "ROG Ally RC71L_RC71L" "RC71L"
if run_ally; then
  fail "a short ASUS vendor string is not the original Ally"
fi
pass "a short ASUS vendor string is not the original Ally"

write_dmi "LENOVO" "ROG Ally RC71L" "RC71L"
if run_ally; then
  fail "another vendor with an Ally product string is not the original Ally"
fi
pass "another vendor with an Ally product string is not the original Ally"

write_dmi "$vendor" "ROG Strix G16" "GU605CX"
if run_ally; then
  fail "a ROG laptop is not the original Ally"
fi
pass "a ROG laptop is not the original Ally"

OMARCHY_DMI_SYS_VENDOR_PATH="$dmi/missing-vendor" \
  OMARCHY_DMI_PRODUCT_NAME_PATH="$dmi/missing-product" \
  OMARCHY_DMI_BOARD_NAME_PATH="$dmi/missing-board" \
  "$ROOT/bin/omarchy-hw-rog-ally" && fail "missing DMI is not the original Ally"
pass "missing DMI is not the original Ally"

# --- Laptop fallback: only this handheld, not every hand-held chassis ---

write_dmi "$vendor" "ROG Ally RC71L_RC71L" "RC71L"
run_laptop 3 || fail "an original Ally with a desktop chassis is treated as a laptop"
pass "an original Ally with a desktop chassis is treated as a laptop"

run_laptop 11 || fail "an original Ally reporting Hand Held is treated as a laptop"
pass "an original Ally reporting Hand Held is treated as a laptop"

write_dmi "$vendor" "ROG Ally X RC72LA_RC72LA" "RC72LA"
if run_laptop 11; then
  fail "Hand Held chassis alone is not a laptop"
fi
pass "Hand Held chassis alone is not a laptop"

if run_laptop 3; then
  fail "an Ally X with a desktop chassis is not a laptop"
fi
pass "an Ally X with a desktop chassis is not a laptop"

write_dmi "$vendor" "" ""
run_laptop 30 || fail "a tablet chassis is still a laptop without an Ally match"
pass "a tablet chassis is still a laptop without an Ally match"

# --- asusctl is the laptop package, and the Ally leaf only speaks on RC71L ---

stub="$test_tmp/bin"
mkdir -p "$stub"
pkg_log="$test_tmp/packages"
: >"$pkg_log"

cat >"$stub/omarchy-pkg-add" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$PKG_LOG"
SH
chmod +x "$stub/omarchy-pkg-add"

cat >"$stub/omarchy-hw-asus-rog" <<'SH'
#!/bin/bash
exit "${FAKE_ASUS_ROG:-1}"
SH
chmod +x "$stub/omarchy-hw-asus-rog"

cat >"$stub/omarchy-hw-rog-ally" <<'SH'
#!/bin/bash
exit "${FAKE_ROG_ALLY:-1}"
SH
chmod +x "$stub/omarchy-hw-rog-ally"

source_install() {
  local script="$1"
  PKG_LOG="$pkg_log" FAKE_ASUS_ROG="${2:-1}" FAKE_ROG_ALLY="${3:-1}" \
    PATH="$stub:$PATH" \
    bash -eE -c 'source "$1"' bash "$script" </dev/null
}

: >"$pkg_log"
source_install "$ROOT/install/hardware/asus-rog.sh" 0 1
[[ $(cat "$pkg_log") == "asusctl" ]] || fail "a ROG laptop still installs asusctl" "$(cat "$pkg_log")"
pass "a ROG laptop still installs asusctl"

: >"$pkg_log"
source_install "$ROOT/install/hardware/asus-rog.sh" 0 0
[[ ! -s $pkg_log ]] || fail "the original Ally does not install asusctl" "$(cat "$pkg_log")"
pass "the original Ally does not install asusctl"

: >"$pkg_log"
source_install "$ROOT/install/hardware/asus-rog.sh" 1 1
[[ ! -s $pkg_log ]] || fail "a non-ROG machine does not install asusctl" "$(cat "$pkg_log")"
pass "a non-ROG machine does not install asusctl"

note=$(
  write_dmi "$vendor" "ROG Ally RC71L_RC71L" "RC71L"
  OMARCHY_DMI_SYS_VENDOR_PATH="$dmi/sys_vendor" \
    OMARCHY_DMI_PRODUCT_NAME_PATH="$dmi/product_name" \
    OMARCHY_DMI_BOARD_NAME_PATH="$dmi/board_name" \
    PATH="$ROOT/bin:$PATH" \
    bash -eE -c 'source "$1"' bash "$ROOT/install/hardware/asus/rog-ally.sh" </dev/null
)
[[ $note == *"RC71L"* && $note == *"asusctl"* ]] || fail "the Ally hardware leaf names the machine and the skipped package" "$note"
pass "the Ally hardware leaf names the machine and the skipped package"

note=$(
  write_dmi "$vendor" "ROG Ally X RC72LA_RC72LA" "RC72LA"
  OMARCHY_DMI_SYS_VENDOR_PATH="$dmi/sys_vendor" \
    OMARCHY_DMI_PRODUCT_NAME_PATH="$dmi/product_name" \
    OMARCHY_DMI_BOARD_NAME_PATH="$dmi/board_name" \
    PATH="$ROOT/bin:$PATH" \
    bash -eE -c 'source "$1"' bash "$ROOT/install/hardware/asus/rog-ally.sh" </dev/null
)
[[ -z $note ]] || fail "the Ally hardware leaf is silent on an Ally X" "$note"
pass "the Ally hardware leaf is silent on an Ally X"

# Laptop audio quirks must not run on the Ally. sudo is stubbed so a body that
# does run cannot touch the machine.
cat >"$stub/sudo" <<'SH'
#!/bin/bash
printf '%s\n' "sudo $*" >>"$PKG_LOG"
exit 1
SH
chmod +x "$stub/sudo"

# Keep the laptop-path mixer test off the host's sound cards.
cat >"$stub/aplay" <<'SH'
#!/bin/bash
exit 0
SH
chmod +x "$stub/aplay"

home="$test_tmp/home"
mkdir -p "$home"
mixer="$home/.config/wireplumber/wireplumber.conf.d/alsa-soft-mixer.conf"

: >"$pkg_log"
FAKE_ASUS_ROG=0 FAKE_ROG_ALLY=0 PKG_LOG="$pkg_log" \
  HOME="$home" OMARCHY_PATH="$ROOT" PATH="$stub:$PATH" \
  bash -eE -c 'source "$1"' bash "$ROOT/install/user/hardware/asus/fix-audio-mixer.sh" </dev/null
[[ ! -e $mixer ]] || fail "the Ally does not get the ROG laptop soft mixer"
[[ ! -s $pkg_log ]] || fail "the Ally audio leaf does not call sudo" "$(cat "$pkg_log")"
pass "the Ally does not get the ROG laptop soft mixer"

: >"$pkg_log"
FAKE_ASUS_ROG=0 FAKE_ROG_ALLY=0 PKG_LOG="$pkg_log" \
  HOME="$home" OMARCHY_PATH="$ROOT" PATH="$stub:$PATH" \
  bash -eE -c 'source "$1"' bash "$ROOT/install/user/hardware/asus/fix-mic.sh" </dev/null
[[ ! -s $pkg_log ]] || fail "the Ally mic leaf does not call sudo" "$(cat "$pkg_log")"
pass "the Ally does not get the ROG laptop mic boost change"

: >"$pkg_log"
FAKE_ASUS_ROG=0 FAKE_ROG_ALLY=1 PKG_LOG="$pkg_log" \
  HOME="$home" OMARCHY_PATH="$ROOT" PATH="$stub:$PATH" \
  bash -eE -c 'source "$1"' bash "$ROOT/install/user/hardware/asus/fix-audio-mixer.sh" </dev/null
[[ -f $mixer ]] || fail "a ROG laptop still gets the soft mixer"
pass "a ROG laptop still gets the soft mixer"
