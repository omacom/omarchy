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

# --- DMI: original Ally, not Ally X or a later board ---

vendor="ASUSTeK COMPUTER INC."

# Leave the board empty so only the product-name branch can match these cases.
write_dmi "$vendor" "ROG Ally RC71L" ""
run_ally || fail "product ROG Ally RC71L is the original Ally"
pass "product ROG Ally RC71L is the original Ally"

write_dmi "$vendor" "ROG Ally RC71L_RC71L" ""
run_ally || fail "product ROG Ally RC71L_RC71L is the original Ally"
pass "product ROG Ally RC71L_RC71L is the original Ally"

write_dmi "$vendor" "ROG Ally RC71L_Action" ""
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

# Append to test/shell.d/hw-rog-ally-test.sh from PR #18022.
# Regression: a detector/installer integration error must not erase an Ally
# user's saved audio routes or replace their mixer on repeated finalisation.
# Reuse the suite's scratch DMI and home, but run the REAL Ally predicate.

real_predicate="$test_tmp/real-predicate"
mkdir -p "$real_predicate"
ln -s "$ROOT/bin/omarchy-hw-rog-ally" "$real_predicate/omarchy-hw-rog-ally"
cat >"$stub/amixer" <<'SH'
#!/bin/bash
printf 'amixer %s\n' "$*" >>"$PKG_LOG"
exit 1
SH
chmod +x "$stub/amixer"

route="$home/.local/state/wireplumber/default-routes"
mkdir -p "$(dirname "$route")" "$(dirname "$mixer")"
printf 'user-selected audio route\n' >"$route"
printf '# user-owned mixer\n' >"$mixer"
cp "$route" "$test_tmp/expected-routes"
cp "$mixer" "$test_tmp/expected-mixer"

for identity in product board; do
  if [[ $identity == "product" ]]; then
    write_dmi "$vendor" "ROG Ally RC71L_RC71L" ""
  else
    write_dmi "$vendor" "ROG Ally" "RC71L"
  fi
  for attempt in first repeated; do
    : >"$pkg_log"
    for leaf in hardware/asus-rog.sh user/hardware/asus/fix-audio-mixer.sh user/hardware/asus/fix-mic.sh; do
      OMARCHY_DMI_SYS_VENDOR_PATH="$dmi/sys_vendor" \
        OMARCHY_DMI_PRODUCT_NAME_PATH="$dmi/product_name" \
        OMARCHY_DMI_BOARD_NAME_PATH="$dmi/board_name" \
        FAKE_ASUS_ROG=0 PKG_LOG="$pkg_log" HOME="$home" OMARCHY_PATH="$ROOT" \
        PATH="$real_predicate:$stub:$ROOT/bin:$PATH" \
        bash -eE -c 'source "$1"' bash "$ROOT/install/$leaf" </dev/null
    done
    cmp -s "$route" "$test_tmp/expected-routes" ||
      fail "Ally $identity identity preserves audio routes on $attempt finalisation"
    cmp -s "$mixer" "$test_tmp/expected-mixer" ||
      fail "Ally $identity identity preserves a custom mixer on $attempt finalisation"
    [[ ! -s $pkg_log ]] ||
      fail "Ally $identity identity skips laptop packages and privileged audio writes" "$(cat "$pkg_log")"
  done
done
pass "real Ally detection preserves existing audio state on repeated hardware/user setup"

# A negative control keeps this from passing just because setup never runs.
write_dmi "$vendor" "ROG Strix G16" "GU605CX"
: >"$pkg_log"
OMARCHY_DMI_SYS_VENDOR_PATH="$dmi/sys_vendor" \
  OMARCHY_DMI_PRODUCT_NAME_PATH="$dmi/product_name" \
  OMARCHY_DMI_BOARD_NAME_PATH="$dmi/board_name" \
  FAKE_ASUS_ROG=0 PKG_LOG="$pkg_log" \
  PATH="$real_predicate:$stub:$ROOT/bin:$PATH" \
  bash -eE -c 'source "$1"' bash "$ROOT/install/hardware/asus-rog.sh" </dev/null
[[ $(cat "$pkg_log") == "asusctl" ]] || fail "real Ally detector leaves ROG laptop setup active"
pass "real Ally detector leaves ROG laptop setup active"

# Exercise the first-login invitation independently of an installed Steam client.
cat >"$stub/omarchy-cmd-present" <<'SH'
#!/bin/bash
[[ $1 == "omarchy-setup-gaming" && ${OMARCHY_TEST_GAMING_SETUP:-0} == "1" ]]
SH
cat >"$stub/omarchy-notification-send" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$PKG_LOG"
SH
chmod +x "$stub/omarchy-cmd-present" "$stub/omarchy-notification-send"

run_gaming_invitation() {
  OMARCHY_DMI_SYS_VENDOR_PATH="$dmi/sys_vendor" \
    OMARCHY_DMI_PRODUCT_NAME_PATH="$dmi/product_name" \
    OMARCHY_DMI_BOARD_NAME_PATH="$dmi/board_name" \
    HOME="$test_tmp/invitation-$1" OMARCHY_PATH="$ROOT" PKG_LOG="$pkg_log" \
    OMARCHY_TEST_GAMING_SETUP="$2" PATH="$real_predicate:$stub:$ROOT/bin:$PATH" \
    bash "$ROOT/install/user/first-run/setup-rog-ally.hook"
}

: >"$pkg_log"
write_dmi "$vendor" "ROG Strix G16" "GU605CX"
run_gaming_invitation other 0
[[ ! -s $pkg_log && ! -e "$test_tmp/invitation-other/.local/state/omarchy/done/rog-ally-gaming-invitation" ]] ||
  fail "other hardware receives no Ally invitation or marker"
write_dmi "$vendor" "ROG Ally RC71L_RC71L" "RC71L"
run_gaming_invitation fallback 0
run_gaming_invitation fallback 0
[[ $(wc -l <"$pkg_log") == "1" && $(<"$pkg_log") == *"--exec omarchy-menu summon install.gaming" ]] ||
  fail "the Ally invites once using the existing installer menu when Gaming Setup is absent"
: >"$pkg_log"
run_gaming_invitation guided 1
[[ $(<"$pkg_log") == *"--exec omarchy-setup-gaming" ]] ||
  fail "the Ally invitation uses Gaming Setup when available"
pass "first-login invitation is hardware-gated, once-only and independently usable"
