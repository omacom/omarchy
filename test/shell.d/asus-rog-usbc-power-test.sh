#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

sys="$tmp_dir/sys"
armoury="$sys/class/firmware-attributes/asus-armoury/attributes/charge_mode"
legacy="$sys/devices/platform/asus-nb-wmi"
power="$tmp_dir/power"
mkdir -p "$tmp_dir/bin" "$tmp_dir/state" "$armoury" "$legacy" "$power/ACAD"
printf 'Mains\n' >"$power/ACAD/type"
printf '1\n' >"$power/ACAD/online"

# The machine is a ROG laptop unless a test says otherwise.
cat >"$tmp_dir/bin/omarchy-hw-asus-rog" <<'EOF'
#!/bin/bash
[[ ${STUB_ROG:-1} == "1" ]]
EOF
cat >"$tmp_dir/bin/omarchy-hw-match" <<'EOF'
#!/bin/bash
[[ ${STUB_FAMILY:-Zephyrus} == *"$1"* ]]
EOF
cat >"$tmp_dir/bin/powerprofilesctl" <<'EOF'
#!/bin/bash
if [[ $1 == "list" ]]; then
  printf '  power-saver:\n* balanced:\n  performance:\n'
elif [[ $1 == "set" ]]; then
  printf '%s\n' "$2" >>"$POWERPROFILES_LOG"
fi
EOF
cat >"$tmp_dir/bin/busctl" <<'EOF'
#!/bin/bash
echo "b false"
EOF
chmod +x "$tmp_dir/bin/"*

export PATH="$tmp_dir/bin:$ROOT/bin:$PATH"
export OMARCHY_SYS_ROOT="$sys"
export OMARCHY_POWER_SUPPLY_PATH="$power"
export OMARCHY_POWERPROFILES_STATE_DIR="$tmp_dir/state"
export POWERPROFILES_LOG="$tmp_dir/calls"
# Toggle flags live under $HOME; keep the developer's own out of the test.
export HOME="$tmp_dir/home"
mkdir -p "$HOME"

usbc() {
  "$ROOT/bin/omarchy-hw-asus-rog-usbc-power"
}

charge_mode() {
  printf '%s\n' "$1" >"$armoury/current_value"
}

charge_mode 2
usbc || fail "a USB-C charger reads as USB-C power"
charge_mode 1
! usbc || fail "the barrel adapter is not USB-C power"
charge_mode 3
! usbc || fail "barrel and USB-C together charge from the barrel"
charge_mode 18
usbc || fail "a 60 W PD charger (18, bit 4 set as well) reads as USB-C power"
charge_mode 17
! usbc || fail "the barrel with bit 4 set is not USB-C power"
pass "charge_mode tells a USB-C charger from the barrel adapter"

rm "$armoury/current_value"
printf '2\n' >"$legacy/charge_mode"
usbc || fail "asus-nb-wmi charge_mode serves kernels without asus-armoury"
rm "$legacy/charge_mode"
! usbc || fail "a machine without charge_mode has no USB-C power"
pass "the older asus-nb-wmi attribute is read when asus-armoury is missing"

charge_mode 2
! STUB_ROG=0 usbc || fail "a non-ROG ASUS machine is left alone"
STUB_FAMILY="ROG Strix" usbc || fail "a ROG Strix on USB-C is detected too"
pass "every ROG laptop is checked, not only the Zephyrus"

# On battery 0 is the answer at once; with power present the firmware gets a
# moment to report the adapter.
charge_mode 0
printf '0\n' >"$power/ACAD/online"
start=$SECONDS
! usbc || fail "battery is not USB-C power"
(( SECONDS - start < 1 )) || fail "battery is answered without waiting"
printf '1\n' >"$power/ACAD/online"
(sleep 0.5 && charge_mode 2) &
usbc || fail "a charger the firmware reports a moment late still reads as USB-C"
wait
pass "a just-plugged charger is given time to show up in charge_mode"

charge_mode 2
"$ROOT/bin/omarchy-powerprofiles-set" ac
[[ $(tail -n 1 "$POWERPROFILES_LOG") == "balanced" ]] || fail "USB-C defaults to balanced"
charge_mode 1
"$ROOT/bin/omarchy-powerprofiles-set" ac
[[ $(tail -n 1 "$POWERPROFILES_LOG") == "performance" ]] || fail "the barrel keeps performance"
pass "USB-C saves power while the barrel adapter keeps full power"

charge_mode 2
"$ROOT/bin/omarchy-powerprofiles-set" autodetect power-saver
[[ $(<"$tmp_dir/state/usb-c") == "power-saver" ]] || fail "a profile picked on USB-C is remembered for USB-C"
[[ ! -e $tmp_dir/state/ac ]] || fail "a profile picked on USB-C leaves the barrel's alone"
charge_mode 1
"$ROOT/bin/omarchy-powerprofiles-set" autodetect
[[ $(tail -n 1 "$POWERPROFILES_LOG") == "performance" ]] || fail "the barrel restores its own profile"
charge_mode 2
"$ROOT/bin/omarchy-powerprofiles-set" autodetect
[[ $(tail -n 1 "$POWERPROFILES_LOG") == "power-saver" ]] || fail "USB-C restores its own profile"
pass "USB-C remembers its profile apart from the barrel adapter"

"$ROOT/bin/omarchy-powerprofiles-set" battery
[[ $(tail -n 1 "$POWERPROFILES_LOG") == "balanced" ]] || fail "battery is unaffected by charge_mode"
STUB_ROG=0 "$ROOT/bin/omarchy-powerprofiles-set" ac
[[ $(tail -n 1 "$POWERPROFILES_LOG") == "performance" ]] || fail "other machines keep performance on AC"
pass "battery and other machines behave as before"

charge_mode 18
"$ROOT/bin/omarchy-powerprofiles-set" ac balanced
[[ $(<"$tmp_dir/state/ac") == "balanced" ]] || fail "ac <profile> on USB-C sets the barrel's profile"
[[ $(<"$tmp_dir/state/usb-c") == "power-saver" ]] || fail "ac <profile> on USB-C leaves USB-C's profile alone"
charge_mode 1
"$ROOT/bin/omarchy-powerprofiles-set" usb-c performance
[[ $(<"$tmp_dir/state/usb-c") == "performance" ]] || fail "usb-c <profile> on the barrel sets USB-C's profile"
[[ $(<"$tmp_dir/state/ac") == "balanced" ]] || fail "usb-c <profile> leaves the barrel's profile alone"
pass "naming ac or usb-c sets that source's profile from anywhere"
