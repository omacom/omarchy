#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_platform_fixtures "the composed mkinitcpio HOOKS"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

for platform in apple-silicon qualcomm generic-aarch64 generic; do
  fake_platform "$test_tmp/platforms/$platform" "$platform"
done
# omarchy-settings without the runtime package: no detector on PATH.
mkdir -p "$test_tmp/platforms/no-detector/bin"
# A device tree naming both Apple and Qualcomm, which the detector refuses.
fake_platform "$test_tmp/platforms/contradiction" apple-silicon
printf '%s\0' apple,j416c qcom,x1e80100 >"$test_tmp/platforms/contradiction/proc/device-tree/compatible"

etc="$test_tmp/etc"
devices="$test_tmp/devices"

omarchy_hooks="base udev plymouth keyboard autodetect microcode modconf kms keymap consolefont block encrypt filesystems fsck btrfs-overlayfs"
omarchy_hooks_without_kms=${omarchy_hooks/ kms / }
apple_hooks="base systemd plymouth autodetect microcode modconf kms keyboard sd-vconsole block filesystems fsck"
nvidia_modules="nvidia nvidia_modeset nvidia_uvm nvidia_drm"

# The kernel being built, as modinfo answers for it: KERNEL_MODULES names its
# modules (thunderbolt, as on x86 and Aurora, unless a case says otherwise) and
# KERNEL_BUILTINS the ones built in.
cat >"$test_tmp/modinfo" <<'SH'
#!/bin/bash
[[ $1 == -k && $2 == "$KERNELVERSION" && $3 == -F && $4 == filename ]] || exit 1
if [[ " ${KERNEL_MODULES-thunderbolt} " == *" $5 "* ]]; then
  printf '/usr/lib/modules/%s/kernel/%s.ko.zst\n' "$KERNELVERSION" "$5"
elif [[ " ${KERNEL_BUILTINS-} " == *" $5 "* ]]; then
  printf '(builtin)\n'
else
  exit 1
fi
SH
chmod +x "$test_tmp/modinfo"
for fixture in "$test_tmp"/platforms/*; do
  cp "$test_tmp/modinfo" "$fixture/bin/"
done

# mkinitcpio's stock mkinitcpio.conf, which the baseline replaces, plus every
# drop-in Omarchy ships, on a machine with no PCI devices.
new_etc() {
  rm -rf "$etc" "$devices"
  mkdir -p "$etc/mkinitcpio.conf.d" "$devices"
  cat >"$etc/mkinitcpio.conf" <<'CONF'
MODULES=()
BINARIES=()
FILES=()
HOOKS=(base systemd autodetect microcode modconf kms keyboard sd-vconsole block filesystems fsck)
CONF
  cp "$ROOT"/etc/mkinitcpio.conf.d/*.conf "$etc/mkinitcpio.conf.d/"
}

# $1 names the drop-in; stdin is its content.
drop_in() {
  cat >"$etc/mkinitcpio.conf.d/$1"
}

# Each argument is a PCI device as "vendor:class", in sysfs's own format.
pci_devices() {
  local index=0 spec slot
  for spec in "$@"; do
    slot=$(printf '0000:%02x:00.0' "$index")
    mkdir -p "$devices/$slot"
    printf '%s\n' "${spec%%:*}" >"$devices/$slot/vendor"
    printf '%s\n' "${spec##*:}" >"$devices/$slot/class"
    index=$((index + 1))
  done
}

# mkinitcpio appends the drop-ins to mkinitcpio.conf in its own order and
# sources the result once. Do the same on a platform fixture and print what the
# image is built from. The vconsole.conf entry comes from the host's own file,
# so it is left out of FILES.
compose() {
  local fixture="$test_tmp/platforms/$1" config="$test_tmp/buildconfig" conf
  local -a conf_files=()
  mapfile -d '' conf_files < <(LC_ALL=C.UTF-8 find "$etc/mkinitcpio.conf.d" -maxdepth 1 -xtype f -name '*.conf' -print0 |
    sed -z 's/.*\///' | LC_ALL=C.UTF-8 sort -zVu)
  cat -- "$etc/mkinitcpio.conf" >"$config"
  for conf in "${conf_files[@]}"; do
    cat -- "$etc/mkinitcpio.conf.d/$conf" >>"$config"
  done

  local path="$fixture/bin:$ROOT/bin:$PATH"
  [[ $1 != "no-detector" ]] || path="$fixture/bin"
  KERNELVERSION=6.99.0-test OMARCHY_PROC_ROOT="$fixture/proc" OMARCHY_PCI_DEVICES_PATH="$devices" PATH="$path" "$BASH" -c '
    . "$1" || exit 1
    files=()
    for file in "${FILES[@]}"; do
      [[ $file == /etc/vconsole.conf ]] || files+=("$file")
    done
    printf "HOOKS=%s\nMODULES=%s\nFILES=%s\n" "${HOOKS[*]}" "${MODULES[*]}" "${files[*]}"
  ' -- "$config"
}

assert_composed() {
  local description="$1" platform="$2" hooks="$3" modules="$4" files="$5"
  local expected actual
  expected=$(printf 'HOOKS=%s\nMODULES=%s\nFILES=%s\n' "$hooks" "$modules" "$files")
  actual=$(compose "$platform") || fail "$description" "the drop-ins do not source cleanly"
  [[ $actual == "$expected" ]] ||
    fail "$description" "expected:"$'\n'"$expected"$'\n'"actual:"$'\n'"$actual"
  pass "$description"
}

assert_hooks() {
  local description="$1" platform="$2" expected="$3" actual
  actual=$(compose "$platform") || fail "$description" "the drop-ins do not source cleanly"
  actual=$(sed -n 's/^HOOKS=//p' <<<"$actual")
  [[ $actual == "$expected" ]] ||
    fail "$description" "expected: $expected"$'\n'"actual:   $actual"
  pass "$description"
}

# Each platform starts from its own baseline, whatever mkinitcpio.conf says.
new_etc
assert_hooks "Apple Silicon starts from the systemd baseline" apple-silicon "$apple_hooks"
assert_hooks "Qualcomm starts from the Omarchy baseline" qualcomm "$omarchy_hooks"
assert_hooks "generic aarch64 starts from the Omarchy baseline" generic-aarch64 "$omarchy_hooks"
assert_hooks "x86 starts from the Omarchy baseline" generic "$omarchy_hooks"
assert_hooks "without the detector the Omarchy baseline stays" no-detector "$omarchy_hooks"

if composed=$(compose contradiction 2>"$test_tmp/contradiction.err"); then
  fail "a platform the detector cannot place stops the build" "composed: $composed"
fi
grep -q "contradictory platform identity" "$test_tmp/contradiction.err" ||
  fail "a platform the detector cannot place stops the build" "stderr: $(<"$test_tmp/contradiction.err")"
pass "a platform the detector cannot place stops the build"

# A Mac that set up its own initramfs before the Apple boot package keeps it:
# busybox encrypt unlocks through cryptdevice=, which sd-encrypt cannot parse,
# and the asahi hook carries the firmware. The asahi hook marks such a root off
# a Mac too. Busybox encrypt alone means nothing off Apple Silicon.
legacy_encrypted="base udev plymouth autodetect microcode modconf kms keyboard keymap consolefont block encrypt asahi filesystems fsck"
legacy_plain="base udev autodetect microcode modconf kms keyboard keymap consolefont block asahi filesystems fsck"
for legacy in "$legacy_encrypted" "$legacy_plain" "${legacy_encrypted/ asahi / }"; do
  new_etc
  sed -i "s/^HOOKS=.*/HOOKS=($legacy)/" "$etc/mkinitcpio.conf"
  assert_hooks "a Mac keeps its own HOOKS=($legacy)" apple-silicon "$legacy"
done
new_etc
sed -i "s/^HOOKS=.*/HOOKS=($legacy_plain)/" "$etc/mkinitcpio.conf"
assert_hooks "an asahi root keeps its HOOKS off a Mac" generic-aarch64 "$legacy_plain"
# A legacy GRUB Mac has the asahi hook right after base, where Asahi's images
# put it, and may run a runtime older than the detector.
legacy_grub="base asahi udev plymouth autodetect microcode modconf kms keyboard keymap consolefont block encrypt filesystems fsck"
for platform in apple-silicon no-detector; do
  for legacy in "$legacy_grub" "${legacy_grub/ encrypt / }"; do
    new_etc
    sed -i "s/^HOOKS=.*/HOOKS=($legacy)/" "$etc/mkinitcpio.conf"
    assert_hooks "a legacy GRUB Mac keeps HOOKS=($legacy) ($platform)" "$platform" "$legacy"
  done
done
new_etc
sed -i "s/^HOOKS=.*/HOOKS=(base udev autodetect modconf block encrypt filesystems fsck)/" "$etc/mkinitcpio.conf"
assert_hooks "busybox encrypt off Apple Silicon still gets the Omarchy baseline" generic "$omarchy_hooks"
new_etc
sed -i "s/^HOOKS=.*/HOOKS=(base udev autodetect modconf kms keyboard keymap consolefont block filesystems fsck)/" "$etc/mkinitcpio.conf"
assert_hooks "a Mac with a stock busybox line and no asahi hook gets the systemd baseline" apple-silicon "$apple_hooks"

# A platform fragment sorts after the baseline and before omarchy_hooks.conf,
# as omarchy-mac-boot's 90- drop-ins do. Its hooks must reach the image.
new_etc
drop_in 90-platform-fragment.conf <<'CONF'
_fragment_hooks=()
for _fragment_hook in "${HOOKS[@]}"; do
  [[ $_fragment_hook == "filesystems" ]] && _fragment_hooks+=(platform-firmware)
  _fragment_hooks+=("$_fragment_hook")
done
HOOKS=("${_fragment_hooks[@]}" platform-late)
unset _fragment_hooks _fragment_hook
CONF
assert_hooks "a platform fragment's hooks survive on Apple Silicon" apple-silicon \
  "base systemd plymouth autodetect microcode modconf kms keyboard sd-vconsole block platform-firmware filesystems fsck platform-late"
assert_hooks "a platform fragment's hooks survive on Qualcomm" qualcomm \
  "base udev plymouth keyboard autodetect microcode modconf kms keymap consolefont block encrypt platform-firmware filesystems fsck btrfs-overlayfs platform-late"
assert_hooks "a platform fragment's hooks survive on generic aarch64" generic-aarch64 \
  "base udev plymouth keyboard autodetect microcode modconf kms keymap consolefont block encrypt platform-firmware filesystems fsck btrfs-overlayfs platform-late"
assert_hooks "a platform fragment's hooks survive on x86" generic \
  "base udev plymouth keyboard autodetect microcode modconf kms keymap consolefont block encrypt platform-firmware filesystems fsck btrfs-overlayfs platform-late"

# The NVIDIA filter still runs after the fragment and removes only kms.
drop_in nvidia.conf <<<"MODULES+=($nvidia_modules)"
pci_devices 0x10de:0x030000
assert_hooks "the NVIDIA filter keeps a platform fragment's hooks" generic \
  "base udev plymouth keyboard autodetect microcode modconf keymap consolefont block encrypt platform-firmware filesystems fsck btrfs-overlayfs platform-late"

# Existing x86 configurations build the image they built before the baseline
# moved: the same HOOKS, MODULES and FILES.
new_etc
assert_composed "a machine without hardware drop-ins is unchanged" generic \
  "$omarchy_hooks" "thunderbolt" ""

new_etc
drop_in nvidia.conf <<<"MODULES+=($nvidia_modules)"
pci_devices 0x10de:0x030000
assert_composed "NVIDIA-only drops only kms" generic \
  "$omarchy_hooks_without_kms" "$nvidia_modules thunderbolt" ""

new_etc
drop_in nvidia.conf <<<"MODULES+=($nvidia_modules)"
pci_devices 0x8086:0x030000 0x10de:0x030200
assert_composed "hybrid graphics keeps kms for the iGPU" generic \
  "$omarchy_hooks" "$nvidia_modules thunderbolt" ""

new_etc
pci_devices 0x10de:0x030000
assert_composed "NVIDIA-only without early nvidia_drm keeps kms" generic \
  "$omarchy_hooks" "thunderbolt" ""

new_etc
drop_in nvidia.conf <<<"MODULES+=($nvidia_modules)"
drop_in omarchy_resume.conf <<<"HOOKS+=(resume)"
drop_in 99-omarchy-provisioning-key.conf <<<"FILES+=(/etc/omarchy/provisioning.key)"
pci_devices 0x10de:0x030000
assert_composed "NVIDIA-only with hibernation and a provisioning key is unchanged" generic \
  "$omarchy_hooks_without_kms resume" "$nvidia_modules thunderbolt" "/etc/omarchy/provisioning.key"

new_etc
drop_in apple-t2.conf <<<"MODULES+=(t2bce_vhci usbhid hid_apple hid_generic xhci_pci xhci_hcd)"
assert_composed "a T2 Mac is unchanged" generic \
  "$omarchy_hooks" "t2bce_vhci usbhid hid_apple hid_generic xhci_pci xhci_hcd thunderbolt" ""

new_etc
drop_in macbook_spi_modules.conf <<<"MODULES=(applespi intel_lpss_pci spi_pxa2xx_platform)"
assert_composed "an SPI keyboard MacBook is unchanged" generic \
  "$omarchy_hooks" "applespi intel_lpss_pci spi_pxa2xx_platform thunderbolt" ""

new_etc
drop_in nvidia.conf <<<"MODULES+=($nvidia_modules)"
drop_in surface_device_modules.conf <<<"MODULES=(pinctrl_tigerlake surface_aggregator surface_aggregator_registry surface_aggregator_hub surface_hid_core surface_hid surface_kbd intel_lpss_pci 8250_dw)"
pci_devices 0x8086:0x030000
assert_composed "a Surface is unchanged" generic \
  "$omarchy_hooks" "pinctrl_tigerlake surface_aggregator surface_aggregator_registry surface_aggregator_hub surface_hid_core surface_hid surface_kbd intel_lpss_pci 8250_dw thunderbolt" ""


# Snapdragon and other aarch64 machines build the same image as x86, whatever
# systemd line their mkinitcpio.conf starts from.
for platform in qualcomm generic-aarch64; do
  new_etc
  drop_in omarchy_resume.conf <<<"HOOKS+=(resume)"
  drop_in 99-omarchy-provisioning-key.conf <<<"FILES+=(/etc/omarchy/provisioning.key)"
  assert_composed "$platform with hibernation and a provisioning key is unchanged" "$platform" \
    "$omarchy_hooks resume" "thunderbolt" "/etc/omarchy/provisioning.key"
done

# thunderbolt is early-loaded only where the kernel builds it as a module. A
# systemd initramfs writes MODULES into modules-load.d as they are, so neither
# an optional thunderbolt? nor a module the kernel lacks may reach it.
new_etc
assert_composed "Apple Silicon early-loads the Aurora kernel's thunderbolt module" apple-silicon \
  "$apple_hooks" "thunderbolt" ""
new_etc
KERNEL_MODULES="" assert_composed "a generic aarch64 kernel without thunderbolt leaves it out" generic-aarch64 \
  "$omarchy_hooks" "" ""
new_etc
KERNEL_MODULES="" KERNEL_BUILTINS=thunderbolt assert_composed "a kernel with thunderbolt built in leaves it out" generic \
  "$omarchy_hooks" "" ""
