#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'chmod -R u+rwX "$test_tmp"; rm -rf "$test_tmp"' EXIT

# --- Every setup step is reached ---

# Run the real dispatchers with run_logged recording what they would run. A
# hardware leaf neither dispatches is still reached when another hardware
# script names it, as the systemd unit yoga-slim7x.sh installs names its
# remoteproc starter.
dispatched=$(
  run_logged() { printf '%s\n' "${1#"$ROOT/install/"}"; }
  OMARCHY_INSTALL="$ROOT/install"
  source "$ROOT/install/config/all.sh"
  source "$ROOT/install/hardware/all.sh"
  source "$ROOT/install/user/all.sh"
)
while read -r script; do
  [[ -f $ROOT/install/$script ]] || fail "install/$script, run during setup, exists"
done <<<"$dispatched"
while read -r leaf; do
  leaf=${leaf#"$ROOT/install/"}
  grep -Fxq "$leaf" <<<"$dispatched" && continue
  # A comment or a message naming the leaf runs nothing, so it does not count.
  grep -rF --exclude=all.sh "$leaf" "$ROOT/install/hardware" "$ROOT/install/user/hardware" |
    grep -vF "/install/$leaf:" | grep -vqE '^[^:]+:[[:space:]]*(#|echo )' ||
    fail "install/$leaf runs during setup" "neither install/hardware/all.sh nor install/user/all.sh runs it, and no other hardware script names it"
done < <(find "$ROOT/install/hardware" "$ROOT/install/user/hardware" -name '*.sh' ! -name all.sh | sort)
while read -r leaf; do
  leaf=${leaf#"$ROOT/install/"}
  grep -Fxq "$leaf" <<<"$dispatched" || fail "install/$leaf runs during setup" "its all.sh does not run it"
done < <(find "$ROOT/install/config" "$ROOT/install/user" -maxdepth 1 -name '*.sh' ! -name all.sh | sort)
# Platform packages hook in after everything Omarchy sets up for the user.
[[ $(tail -n1 <<<"$dispatched") == "user/platform-setup.sh" ]] ||
  fail "platform setup runs last" "last: $(tail -n1 <<<"$dispatched")"
pass "every setup script is reached from setup"

# --- Each quirk is a no-op on other hardware and applies on its own ---

# The fake machine: DMI attributes as files, which cat and omarchy-hw-match
# read in place of /sys/class/dmi/id; the platform, loaded modules, input
# devices and lspci listing come from FAKE_* variables. Writes the leaves make
# through sudo land under a scratch root, and every other effect is logged.
hw="$test_tmp/hw"
root="$test_tmp/root"
stub_bin="$test_tmp/bin"
calls="$test_tmp/calls"
mkdir -p "$stub_bin"

sed 's|/sys/class/dmi/id|$FAKE_HW/dmi|g' "$ROOT/bin/omarchy-hw-match" >"$stub_bin/omarchy-hw-match"

cat >"$stub_bin/cat" <<'SH'
#!/bin/bash
args=()
for arg in "$@"; do
  [[ $arg == /sys/class/dmi/id/* ]] && arg="$FAKE_HW/dmi/${arg#/sys/class/dmi/id/}"
  args+=("$arg")
done
exec /usr/bin/cat "${args[@]}"
SH

cat >"$stub_bin/omarchy-hw-x86" <<'SH'
#!/bin/bash
[[ $FAKE_PLATFORM == "x86" ]]
SH

cat >"$stub_bin/omarchy-hw-aarch64-qualcomm" <<'SH'
#!/bin/bash
[[ $FAKE_PLATFORM == "aarch64-qualcomm" ]]
SH

cat >"$stub_bin/omarchy-hw-aarch64-n1x" <<'SH'
#!/bin/bash
[[ $FAKE_PLATFORM == "aarch64-n1x" ]]
SH

cat >"$stub_bin/lspci" <<'SH'
#!/bin/bash
printf '%b\n' "$FAKE_LSPCI"
SH

cat >"$stub_bin/lsmod" <<'SH'
#!/bin/bash
printf 'Module                  Size  Used by\n%b\n' "$FAKE_LSMOD"
SH

# -qn resolves a module without loading it: FAKE_MODPROBE_RESOLVES=1 is a
# chroot whose running kernel's modules are not on disk.
cat >"$stub_bin/modprobe" <<'SH'
#!/bin/bash
[[ $1 == "-qn" ]] && exit "$FAKE_MODPROBE_RESOLVES"
printf 'modprobe %s\n' "$*" >>"$CALLS"
exit "$FAKE_MODPROBE_STATUS"
SH

cat >"$stub_bin/omarchy-pkg-add" <<'SH'
#!/bin/bash
printf 'pkg-add %s\n' "$*" >>"$CALLS"
exit "$FAKE_PKG_ADD_STATUS"
SH

cat >"$stub_bin/omarchy-pkg-drop" <<'SH'
#!/bin/bash
printf 'pkg-drop %s\n' "$*" >>"$CALLS"
SH

cat >"$stub_bin/dell-xps13-sidecar-amps-apply" <<'SH'
#!/bin/bash
exit "$FAKE_APPLY_STATUS"
SH

# File writes run for real under the scratch root; anything else is logged and
# only runs when it is one of the stubs above.
cat >"$stub_bin/sudo" <<'SH'
#!/bin/bash
args=()
for arg in "$@"; do
  [[ $arg == /etc/* ]] && arg="$FAKE_ROOT$arg"
  args+=("$arg")
done
case $1 in
  mkdir | tee | install) exec "${args[@]}" ;;
esac
printf 'sudo %s\n' "$*" >>"$CALLS"
[[ -x $STUB_BIN/$1 ]] && exec "$STUB_BIN/$1" "${@:2}"
exit 0
SH

chmod +x "$stub_bin"/*

# machine <name>[+unreadable]: build the fake machine. +unreadable keeps its
# DMI attributes but makes them unreadable, as a locked-down sysfs does.
machine() {
  local name=${1%+unreadable}
  rm -rf "$hw" "$root"
  mkdir -p "$hw/dmi" "$root/etc" "$root/home/.config/hypr"
  printf '%s\n' '-- User look and feel' >"$root/home/.config/hypr/looknfeel.lua"
  : >"$hw/input-devices"
  FAKE_PLATFORM=x86 FAKE_LSMOD="" FAKE_LSPCI="00:02.0 VGA compatible controller: Intel Corporation Alder Lake\n\tKernel driver in use: i915"
  FAKE_MODPROBE_RESOLVES=0 FAKE_MODPROBE_STATUS=0 FAKE_PKG_ADD_STATUS=0 FAKE_APPLY_STATUS=0

  dmi() { printf '%s\n' "$2" >"$hw/dmi/$1"; }
  xps13() { dmi sys_vendor "Dell Inc."; dmi product_name "XPS 13 ${1:-DX13260}"; dmi product_sku "${2:-0E53}"; }
  synaptics() { printf '%s\n' 'N: Name="SynPS/2 Synaptics TouchPad"' >"$hw/input-devices"; }
  surface() { dmi sys_vendor "Microsoft Corporation"; dmi product_name "$1"; }

  case $name in
    plain) dmi sys_vendor LENOVO; dmi product_name 21HM0000US; dmi product_family "ThinkPad X1 Carbon Gen 11" ;;
    no-dmi) rm -rf "$hw/dmi" ;;
    macbookpro13) dmi product_name "MacBookPro13,2" ;;
    macbook8) dmi product_name "MacBook8,1" ;;
    macbookpro15) dmi product_name "MacBookPro15,1" ;;
    synaptics) synaptics ;;
    synaptics-chroot) synaptics; FAKE_MODPROBE_RESOLVES=1 ;;
    synaptics-psmouse-loaded) synaptics; FAKE_LSMOD="psmouse 217088 0" ;;
    synaptics-modprobe-fails) synaptics; FAKE_MODPROBE_STATUS=1 ;;
    surface-intel) surface "Surface Laptop 3"; FAKE_LSMOD="pinctrl_tigerlake 32768 0" ;;
    surface-intel-no-pinctrl) surface "Surface Laptop 3" ;;
    # What lsmod reports on a Surface Pro 11, where the Intel module list would break mkinitcpio.
    surface-snapdragon) surface "Surface Pro, 11th Edition"; FAKE_PLATFORM=aarch64-qualcomm FAKE_LSMOD="pinctrl_sm8550_lpass_lpi 12288 1" ;;
    t14s-21n1) dmi product_name 21N10000US; FAKE_PLATFORM=aarch64-qualcomm ;;
    t14s-21n2) dmi product_name 21N20000US; FAKE_PLATFORM=aarch64-qualcomm ;;
    t14s-21n1-not-qualcomm) dmi product_name 21N10000US; FAKE_PLATFORM=aarch64 ;;
    t14-gen4) dmi product_name 21F60000US ;;
    yoga-slim7x) dmi product_name 83ED; FAKE_PLATFORM=aarch64-qualcomm ;;
    zenbook-a16) dmi sys_vendor ASUS; dmi product_name "Zenbook A16 UX3607OA"; FAKE_PLATFORM=aarch64-qualcomm ;;
    zenbook-a16-not-qualcomm) dmi sys_vendor ASUS; dmi product_name "Zenbook A16 UX3607OA"; FAKE_PLATFORM=aarch64 ;;
    xps13-ptl) xps13; FAKE_LSPCI="00:02.0 VGA compatible controller: Intel Corporation Panther Lake [Intel Graphics]" ;;
    xps13-wcl) xps13; FAKE_LSPCI="00:02.0 VGA compatible controller: Intel Corporation Wildcat Lake [Intel Graphics]" ;;
    xps13-dx13261) xps13 DX13261; FAKE_LSPCI="00:02.0 VGA compatible controller: Intel Corporation Panther Lake [Intel Graphics]" ;;
    xps13-sku-0e54) xps13 DX13260 0E54 ;;
    # An exact SKU match must not be satisfied by one that merely contains it.
    xps13-sku-0e530) xps13 DX13260 0E530 ;;
    xps13-no-sku) xps13; rm "$hw/dmi/product_sku" ;;
    xps13-apply-fails) xps13; FAKE_APPLY_STATUS=1 ;;
    xps13-pkg-add-fails) xps13; FAKE_PKG_ADD_STATUS=1 ;;
    nouveau) FAKE_LSPCI="01:00.0 VGA compatible controller: NVIDIA Corporation GK208B\n\tKernel driver in use: nouveau" ;;
    nouveau-proprietary) FAKE_LSPCI="01:00.0 VGA compatible controller: NVIDIA Corporation GK208B\n\tKernel driver in use: nouveau"; : >"$hw/nvidia.conf" ;;
    *) fail "hardware-quirks-test knows the machine '$name'" ;;
  esac

  if [[ $1 == *+unreadable ]]; then
    chmod 000 "$hw/dmi"/*
  fi
  export FAKE_PLATFORM FAKE_LSMOD FAKE_LSPCI FAKE_MODPROBE_RESOLVES FAKE_MODPROBE_STATUS FAKE_PKG_ADD_STATUS FAKE_APPLY_STATUS
}

snapshot() {
  (cd "$root" && find . -type f -exec md5sum {} + | LC_ALL=C sort)
}

# run_leaf <install-relative script>: source it the way run_logged does, under
# errexit, and print its exit status and what it did: logged calls, then every
# file it created or changed under the scratch root.
run_leaf() {
  local before status=0
  : >"$calls"
  before=$(snapshot)
  HOME="$root/home" OMARCHY_PATH="$ROOT" PATH="$stub_bin:$ROOT/bin:$PATH" STUB_BIN="$stub_bin" CALLS="$calls" \
    FAKE_HW="$hw" FAKE_ROOT="$root" \
    OMARCHY_DMI_PRODUCT_SKU="$hw/dmi/product_sku" \
    OMARCHY_SYNAPTIC_INPUT_DEVICES="$hw/input-devices" \
    OMARCHY_SURFACE_MKINITCPIO_DIR="$root/etc/mkinitcpio.conf.d" \
    OMARCHY_NVIDIA_MODPROBE_CONFIG="$hw/nvidia.conf" \
    bash -eE -c 'source "$1"' bash "$ROOT/install/$1" </dev/null >/dev/null 2>&1 || status=$?
  {
    printf '%s\n' "$status"
    cat "$calls"
    LC_ALL=C comm -13 <(printf '%s\n' "$before") <(snapshot) | sed 's|^[^ ]*  \./|wrote |'
  } | paste -sd '|'
}

# n1x.sh drops every kernel but linux-omarchy, so its gate is the one thing
# standing between it and any other machine.
leaves=(
  hardware/apple/fix-spi-keyboard.sh
  hardware/n1x.sh
  hardware/fix-synaptic-touchpad.sh
  hardware/surface.sh
  hardware/fix-surface-keyboard.sh
  hardware/lenovo/thinkpad-t14s-camera.sh
  hardware/asus/fix-asus-zenbook-a16-speakers.sh
  hardware/dell-xps13-ptl-speaker-firmware.sh
  hardware/dell-xps13-sidecar-amps.sh
  user/hardware/fix-nouveau-cursor.sh
)

for leaf in "${leaves[@]}"; do
  for name in plain no-dmi; do
    machine "$name"
    got=$(run_leaf "$leaf")
    [[ $got == "0" ]] || fail "install/$leaf does nothing on a $name machine" "got: $got"
  done
done
pass "hardware quirks do nothing on unrelated machines or machines without DMI"

# leaf|machine|exit status, then what it did, |-separated
while IFS='|' read -r leaf name want; do
  [[ -n $leaf && $leaf != \#* ]] || continue
  if [[ $name == *+unreadable ]] && (( EUID == 0 )); then
    continue
  fi
  machine "$name"
  got=$(run_leaf "$leaf")
  [[ $got == "$want" ]] || fail "install/$leaf on $name: $want" "got: $got"
done <<'ROWS'
hardware/apple/fix-spi-keyboard.sh|macbookpro13|0|pkg-add macbook12-spi-driver-dkms|wrote etc/mkinitcpio.conf.d/macbook_spi_modules.conf
hardware/apple/fix-spi-keyboard.sh|macbook8|0|pkg-add macbook12-spi-driver-dkms|wrote etc/mkinitcpio.conf.d/macbook_spi_modules.conf
hardware/apple/fix-spi-keyboard.sh|macbookpro13+unreadable|0
hardware/apple/fix-spi-keyboard.sh|macbookpro15|0
hardware/fix-synaptic-touchpad.sh|synaptics|0|modprobe psmouse synaptics_intertouch=1
# Under arch-chroot the live kernel's modules are not the ones on disk.
hardware/fix-synaptic-touchpad.sh|synaptics-chroot|0
hardware/fix-synaptic-touchpad.sh|synaptics-psmouse-loaded|0
# An optional touchpad improvement never gets to halt an install.
hardware/fix-synaptic-touchpad.sh|synaptics-modprobe-fails|0|modprobe psmouse synaptics_intertouch=1
hardware/surface.sh|surface-intel|0|pkg-add linux-firmware-marvell
hardware/surface.sh|surface-intel+unreadable|0
hardware/surface.sh|surface-snapdragon|0
hardware/fix-surface-keyboard.sh|surface-intel|0|wrote etc/mkinitcpio.conf.d/surface_device_modules.conf
hardware/fix-surface-keyboard.sh|surface-intel-no-pinctrl|0
hardware/fix-surface-keyboard.sh|surface-snapdragon|0
hardware/lenovo/thinkpad-t14s-camera.sh|t14s-21n1|0|pkg-add pipewire-libcamera|wrote etc/udev/rules.d/70-thinkpad-t14s-camera.rules
hardware/lenovo/thinkpad-t14s-camera.sh|t14s-21n2|0|pkg-add pipewire-libcamera|wrote etc/udev/rules.d/70-thinkpad-t14s-camera.rules
hardware/lenovo/thinkpad-t14s-camera.sh|t14s-21n1+unreadable|0
hardware/lenovo/thinkpad-t14s-camera.sh|t14s-21n1-not-qualcomm|0
hardware/lenovo/thinkpad-t14s-camera.sh|t14-gen4|0
hardware/lenovo/thinkpad-t14s-camera.sh|yoga-slim7x|0
hardware/asus/fix-asus-zenbook-a16-speakers.sh|zenbook-a16|0|pkg-add asus-zenbook-a16-audio
hardware/asus/fix-asus-zenbook-a16-speakers.sh|zenbook-a16+unreadable|0
hardware/asus/fix-asus-zenbook-a16-speakers.sh|zenbook-a16-not-qualcomm|0
hardware/asus/fix-asus-zenbook-a16-speakers.sh|yoga-slim7x|0
hardware/dell-xps13-ptl-speaker-firmware.sh|xps13-ptl|0|pkg-add linux-firmware-cirrus-dx13260
hardware/dell-xps13-ptl-speaker-firmware.sh|xps13-ptl+unreadable|0
hardware/dell-xps13-ptl-speaker-firmware.sh|xps13-wcl|0
hardware/dell-xps13-ptl-speaker-firmware.sh|xps13-dx13261|0
hardware/dell-xps13-sidecar-amps.sh|xps13-ptl|0|pkg-add dell-xps13-sidecar-amps|sudo dell-xps13-sidecar-amps-apply
hardware/dell-xps13-sidecar-amps.sh|xps13-dx13261|0
hardware/dell-xps13-sidecar-amps.sh|xps13-sku-0e54|0
hardware/dell-xps13-sidecar-amps.sh|xps13-sku-0e530|0
hardware/dell-xps13-sidecar-amps.sh|xps13-no-sku|0
hardware/dell-xps13-sidecar-amps.sh|xps13-ptl+unreadable|0
# Pacman registers a package even when its scriptlet fails, so a failing apply
# has to surface rather than be swallowed by a successful install.
hardware/dell-xps13-sidecar-amps.sh|xps13-apply-fails|1|pkg-add dell-xps13-sidecar-amps|sudo dell-xps13-sidecar-amps-apply
hardware/dell-xps13-sidecar-amps.sh|xps13-pkg-add-fails|1|pkg-add dell-xps13-sidecar-amps
user/hardware/fix-nouveau-cursor.sh|nouveau|0|wrote home/.config/hypr/looknfeel.lua
# Supported GPUs still use nouveau during installation before switching drivers on reboot.
user/hardware/fix-nouveau-cursor.sh|nouveau-proprietary|0
ROWS
pass "hardware quirks apply on their own hardware and nowhere else"

# --- What the applied quirks leave behind ---

machine surface-intel
run_leaf hardware/fix-surface-keyboard.sh >/dev/null
[[ $(<"$root/etc/mkinitcpio.conf.d/surface_device_modules.conf") == "MODULES=(pinctrl_tigerlake "*")" ]] ||
  fail "Surface keyboard setup lists the detected pinctrl module first" "$(<"$root/etc/mkinitcpio.conf.d/surface_device_modules.conf")"
pass "Surface keyboard setup builds its module list around the detected pinctrl module"

machine t14s-21n1
rule="$root/etc/udev/rules.d/70-thinkpad-t14s-camera.rules"
for run in first repeated; do
  run_leaf hardware/lenovo/thinkpad-t14s-camera.sh >/dev/null
  cmp -s "$ROOT/default/udev/thinkpad-t14s-camera.rules" "$rule" || fail "T14s $run camera setup installs the shipped access rule"
  [[ $(stat -c %a "$rule") == "644" ]] || fail "T14s camera rule is not writable by other users"
done
# The active-seat ACL must not grant access to CMA heaps or world-writable nodes.
[[ $(sed '/^#/d; /^$/d' "$ROOT/default/udev/thinkpad-t14s-camera.rules") == 'SUBSYSTEM=="dma_heap", KERNEL=="system", TAG+="uaccess"' ]] ||
  fail "T14s camera access is restricted to the system heap via logind"
pass "T14s camera setup installs a scoped active-seat ACL and can be rerun"

machine nouveau
run_leaf user/hardware/fix-nouveau-cursor.sh >/dev/null
run_leaf user/hardware/fix-nouveau-cursor.sh >/dev/null
(( $(grep -c 'no_hardware_cursors = true' "$root/home/.config/hypr/looknfeel.lua") == 1 )) ||
  fail "nouveau cursor setup enables software cursors once however often it runs"
pass "nouveau cursor setup is idempotent"
