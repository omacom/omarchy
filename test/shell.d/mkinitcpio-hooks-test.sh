#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_platform_fixtures "the composed mkinitcpio HOOKS"

test_tmp=$(mktemp -d)
trap 'if [[ -n ${images:-} && -d $images/esp ]]; then chmod u+rwx "$images/esp"; fi; rm -rf "$test_tmp"' EXIT

home="$test_tmp/home"
mkdir -p "$home"/{config,cache,data,state,runtime,tmp}
# No installed Omarchy or effectful host command is reachable by the fixtures.
safe_bin="$test_tmp/safe-bin"
mkdir -p "$safe_bin"
for cmd in cat cmp grep mktemp rm sed stat; do
  ln -s "$(command -v "$cmd")" "$safe_bin/$cmd"
done
clean_env=(/usr/bin/env -i HOME="$home" XDG_CONFIG_HOME="$home/config"
  XDG_CACHE_HOME="$home/cache" XDG_DATA_HOME="$home/data"
  XDG_STATE_HOME="$home/state" XDG_RUNTIME_DIR="$home/runtime"
  TMPDIR="$home/tmp" LC_ALL=C.UTF-8 OMARCHY_PATH="$ROOT")

for platform in aarch64-apple aarch64-qualcomm aarch64 x86; do
  fake_platform "$test_tmp/platforms/$platform" "$platform"
done
# omarchy-settings without the runtime package: no detector on PATH.
mkdir -p "$test_tmp/platforms/no-detector/bin"
# A device tree naming both Apple and Qualcomm, which the detector refuses.
fake_platform "$test_tmp/platforms/contradiction" aarch64-apple
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
  if [[ $fixture != */no-detector ]]; then
    ln -s "$ROOT/bin/omarchy-hw-platform" "$fixture/bin/omarchy-hw-platform"
    ln -s "$ROOT/bin/omarchy-hw-aarch64-qualcomm" "$fixture/bin/omarchy-hw-aarch64-qualcomm"
  fi
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
# image is built from. The drop-ins read /etc/vconsole.conf, so point them at
# $vconsole, which only the cases that need a layout write.
vconsole="$test_tmp/vconsole.conf"
compose() {
  local fixture="$test_tmp/platforms/$1" config="$test_tmp/buildconfig" conf
  local -a conf_files=()
  mapfile -d '' conf_files < <(LC_ALL=C.UTF-8 find "$etc/mkinitcpio.conf.d" -maxdepth 1 -xtype f -name '*.conf' -print0 |
    sed -z 's/.*\///' | LC_ALL=C.UTF-8 sort -zVu)
  cat -- "$etc/mkinitcpio.conf" >"$config"
  for conf in "${conf_files[@]}"; do
    cat -- "$etc/mkinitcpio.conf.d/$conf" >>"$config"
  done
  sed -i "s|/etc/vconsole.conf|$vconsole|g" "$config"

  "${clean_env[@]}" PATH="$fixture/bin:$safe_bin" KERNELVERSION=6.99.0-test \
    KERNEL_MODULES="${KERNEL_MODULES-thunderbolt}" KERNEL_BUILTINS="${KERNEL_BUILTINS-}" \
    OMARCHY_PROC_ROOT="$fixture/proc" OMARCHY_PCI_DEVICES_PATH="$devices" /bin/bash -c '
    . "$1" || exit 1
    printf "HOOKS=%s\nMODULES=%s\nFILES=%s\n" "${HOOKS[*]}" "${MODULES[*]}" "${FILES[*]}"
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
assert_hooks "Apple Silicon starts from the systemd baseline" aarch64-apple "$apple_hooks"
assert_hooks "plain aarch64 starts from the Omarchy baseline" aarch64 "$omarchy_hooks"
assert_hooks "x86 starts from the Omarchy baseline" x86 "$omarchy_hooks"
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
  assert_hooks "a Mac keeps its own HOOKS=($legacy)" aarch64-apple "$legacy"
done
new_etc
sed -i "s/^HOOKS=.*/HOOKS=($legacy_plain)/" "$etc/mkinitcpio.conf"
assert_hooks "an asahi root keeps its HOOKS off a Mac" aarch64 "$legacy_plain"
# A legacy GRUB Mac has the asahi hook right after base, where Asahi's images
# put it, and may run a runtime older than the detector.
legacy_grub="base asahi udev plymouth autodetect microcode modconf kms keyboard keymap consolefont block encrypt filesystems fsck"
for platform in aarch64-apple no-detector; do
  for legacy in "$legacy_grub" "${legacy_grub/ encrypt / }"; do
    new_etc
    sed -i "s/^HOOKS=.*/HOOKS=($legacy)/" "$etc/mkinitcpio.conf"
    assert_hooks "a legacy GRUB Mac keeps HOOKS=($legacy) ($platform)" "$platform" "$legacy"
  done
done
new_etc
sed -i "s/^HOOKS=.*/HOOKS=(base udev autodetect modconf block encrypt filesystems fsck)/" "$etc/mkinitcpio.conf"
assert_hooks "busybox encrypt off Apple Silicon still gets the Omarchy baseline" x86 "$omarchy_hooks"
new_etc
sed -i "s/^HOOKS=.*/HOOKS=(base udev autodetect modconf kms keyboard keymap consolefont block filesystems fsck)/" "$etc/mkinitcpio.conf"
assert_hooks "a Mac with a stock busybox line and no asahi hook gets the systemd baseline" aarch64-apple "$apple_hooks"

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
assert_hooks "a platform fragment's hooks survive on Apple Silicon" aarch64-apple \
  "base systemd plymouth autodetect microcode modconf kms keyboard sd-vconsole block platform-firmware filesystems fsck platform-late"
assert_hooks "a platform fragment's hooks survive on plain aarch64" aarch64 \
  "base udev plymouth keyboard autodetect microcode modconf kms keymap consolefont block encrypt platform-firmware filesystems fsck btrfs-overlayfs platform-late"
assert_hooks "a platform fragment's hooks survive on x86" x86 \
  "base udev plymouth keyboard autodetect microcode modconf kms keymap consolefont block encrypt platform-firmware filesystems fsck btrfs-overlayfs platform-late"

# The NVIDIA filter still runs after the fragment and removes only kms.
drop_in nvidia.conf <<<"MODULES+=($nvidia_modules)"
pci_devices 0x10de:0x030000
assert_hooks "the NVIDIA filter keeps a platform fragment's hooks" x86 \
  "base udev plymouth keyboard autodetect microcode modconf keymap consolefont block encrypt platform-firmware filesystems fsck btrfs-overlayfs platform-late"

# Existing x86 configurations build the image they built before the baseline
# moved: the same HOOKS, MODULES and FILES.
new_etc
assert_composed "a machine without hardware drop-ins is unchanged" x86 \
  "$omarchy_hooks" "thunderbolt" ""

new_etc
drop_in nvidia.conf <<<"MODULES+=($nvidia_modules)"
pci_devices 0x10de:0x030000
assert_composed "NVIDIA-only drops only kms" x86 \
  "$omarchy_hooks_without_kms" "$nvidia_modules thunderbolt" ""

new_etc
drop_in nvidia.conf <<<"MODULES+=($nvidia_modules)"
pci_devices 0x8086:0x030000 0x10de:0x030200
assert_composed "hybrid graphics keeps kms for the iGPU" x86 \
  "$omarchy_hooks" "$nvidia_modules thunderbolt" ""

new_etc
pci_devices 0x10de:0x030000
assert_composed "NVIDIA-only without early nvidia_drm keeps kms" x86 \
  "$omarchy_hooks" "thunderbolt" ""

new_etc
drop_in nvidia.conf <<<"MODULES+=($nvidia_modules)"
drop_in omarchy_resume.conf <<<"HOOKS+=(resume)"
drop_in 99-omarchy-provisioning-key.conf <<<"FILES+=(/etc/omarchy/provisioning.key)"
pci_devices 0x10de:0x030000
assert_composed "NVIDIA-only with hibernation and a provisioning key is unchanged" x86 \
  "$omarchy_hooks_without_kms resume" "$nvidia_modules thunderbolt" "/etc/omarchy/provisioning.key"

new_etc
drop_in apple-t2.conf <<<"MODULES+=(t2bce_vhci usbhid hid_apple hid_generic xhci_pci xhci_hcd)"
assert_composed "a T2 Mac is unchanged" x86 \
  "$omarchy_hooks" "t2bce_vhci usbhid hid_apple hid_generic xhci_pci xhci_hcd thunderbolt" ""

# The installer records a module as absent when any installed kernel lacks it,
# then zz-omarchy-kernel-modules.conf removes it for every kernel. linux-omarchy
# has no t2bce stack, so the same drop-in was stripping the internal keyboard
# from the linux-t2 image. The later keyboard drop-in puts back each module
# this kernel ships.
installer_filter=$(cat <<'CONF'
# Written by the Omarchy installer. The installed kernel has no such
# modules, and mkinitcpio fails on a module it cannot find.
_omarchy_absent=(t2bce_vhci)
_omarchy_kept=()
for _omarchy_module in "${MODULES[@]}"; do
  [[ " ${_omarchy_absent[*]} " == *" $_omarchy_module "* ]] || _omarchy_kept+=("$_omarchy_module")
done
MODULES=("${_omarchy_kept[@]}")
unset _omarchy_absent _omarchy_kept _omarchy_module
CONF
)
t2_modules="thunderbolt t2bce_dma t2bce_core t2bce_vhci usbhid hid_apple hid_generic xhci_pci xhci_hcd"
new_etc
drop_in apple-t2.conf <<<"MODULES+=(t2bce_vhci usbhid hid_apple hid_generic xhci_pci xhci_hcd)"
drop_in zz-omarchy-kernel-modules.conf <<<"$installer_filter"
KERNEL_MODULES="$t2_modules" assert_composed "linux-t2 keeps the internal keyboard after the installer filter" x86 \
  "$omarchy_hooks" "usbhid hid_apple hid_generic xhci_pci xhci_hcd thunderbolt t2bce_dma t2bce_core t2bce_vhci" ""
new_etc
drop_in apple-t2.conf <<<"MODULES+=(t2bce_vhci usbhid hid_apple hid_generic xhci_pci xhci_hcd)"
drop_in zz-omarchy-kernel-modules.conf <<<"$installer_filter"
KERNEL_MODULES="thunderbolt usbhid hid_apple hid_generic xhci_pci xhci_hcd" \
  assert_composed "a kernel without t2bce_vhci still builds after the installer filter" x86 \
  "$omarchy_hooks" "usbhid hid_apple hid_generic xhci_pci xhci_hcd thunderbolt" ""
installer_filter_hid=${installer_filter/_omarchy_absent=(t2bce_vhci)/_omarchy_absent=(t2bce_vhci hid_apple)}
new_etc
drop_in apple-t2.conf <<<"MODULES+=(t2bce_vhci usbhid hid_apple hid_generic xhci_pci xhci_hcd)"
drop_in zz-omarchy-kernel-modules.conf <<<"$installer_filter_hid"
KERNEL_MODULES="$t2_modules" assert_composed "linux-t2 keeps hid_apple when the installer filter drops it too" x86 \
  "$omarchy_hooks" "usbhid hid_generic xhci_pci xhci_hcd thunderbolt t2bce_dma t2bce_core t2bce_vhci hid_apple" ""

new_etc
drop_in macbook_spi_modules.conf <<<"MODULES=(applespi intel_lpss_pci spi_pxa2xx_platform)"
assert_composed "an SPI keyboard MacBook is unchanged" x86 \
  "$omarchy_hooks" "applespi intel_lpss_pci spi_pxa2xx_platform thunderbolt" ""

new_etc
drop_in nvidia.conf <<<"MODULES+=($nvidia_modules)"
drop_in surface_device_modules.conf <<<"MODULES=(pinctrl_tigerlake surface_aggregator surface_aggregator_registry surface_aggregator_hub surface_hid_core surface_hid surface_kbd intel_lpss_pci 8250_dw)"
pci_devices 0x8086:0x030000
assert_composed "a Surface is unchanged" x86 \
  "$omarchy_hooks" "pinctrl_tigerlake surface_aggregator surface_aggregator_registry surface_aggregator_hub surface_hid_core surface_hid surface_kbd intel_lpss_pci 8250_dw thunderbolt" ""


# Snapdragon and other aarch64 machines build the same image as x86, whatever
# systemd line their mkinitcpio.conf starts from.
for platform in aarch64; do
  new_etc
  drop_in omarchy_resume.conf <<<"HOOKS+=(resume)"
  drop_in 99-omarchy-provisioning-key.conf <<<"FILES+=(/etc/omarchy/provisioning.key)"
  assert_composed "$platform with hibernation and a provisioning key is unchanged" "$platform" \
    "$omarchy_hooks resume" "thunderbolt" "/etc/omarchy/provisioning.key"
done

# A Snapdragon laptop's internal keyboard on I2C needs the I2C HID transport
# at the disk unlock prompt; mkinitcpio's keyboard hook adds only hid-*. It is
# early-loaded where the detector calls the machine Snapdragon and the kernel
# builds it as a module, and nowhere else.
new_etc
KERNEL_MODULES="thunderbolt i2c-hid-of" assert_composed "a Snapdragon laptop early-loads i2c-hid-of for its keyboard" aarch64-qualcomm \
  "$omarchy_hooks" "i2c-hid-of thunderbolt" ""
new_etc
KERNEL_MODULES="thunderbolt i2c-hid-of" assert_composed "a machine without a device tree leaves i2c-hid-of out" x86 \
  "$omarchy_hooks" "thunderbolt" ""
new_etc
KERNEL_MODULES="thunderbolt i2c-hid-of" assert_composed "a device-tree machine that isn't Snapdragon leaves i2c-hid-of out" aarch64 \
  "$omarchy_hooks" "thunderbolt" ""
new_etc
KERNEL_MODULES="thunderbolt i2c-hid-of" assert_composed "without the runtime's detector i2c-hid-of stays out" no-detector \
  "$omarchy_hooks" "thunderbolt" ""
new_etc
KERNEL_MODULES="thunderbolt i2c-hid-of" assert_composed "an Apple Silicon Mac leaves i2c-hid-of out" aarch64-apple \
  "$apple_hooks" "thunderbolt" ""
new_etc
KERNEL_MODULES="thunderbolt" KERNEL_BUILTINS="i2c-hid-of" assert_composed "a kernel with i2c-hid-of built in leaves it out" aarch64-qualcomm \
  "$omarchy_hooks" "thunderbolt" ""

# thunderbolt is early-loaded only where the kernel builds it as a module. A
# systemd initramfs writes MODULES into modules-load.d as they are, so neither
# an optional thunderbolt? nor a module the kernel lacks may reach it.
new_etc
assert_composed "Apple Silicon early-loads the Aurora kernel's thunderbolt module" aarch64-apple \
  "$apple_hooks" "thunderbolt" ""
new_etc
KERNEL_MODULES="" assert_composed "a plain aarch64 kernel without thunderbolt leaves it out" aarch64 \
  "$omarchy_hooks" "" ""
new_etc
KERNEL_MODULES="" KERNEL_BUILTINS=thunderbolt assert_composed "a kernel with thunderbolt built in leaves it out" x86 \
  "$omarchy_hooks" "" ""

# Apple Silicon's boot package ships mkinitcpio drop-ins 90- to 94- that sort
# after the HOOKS baseline and add the Asahi firmware and systemd unlock hooks
# to it. The fixtures are the drop-ins omarchy-mac-boot 20260926-1.45 installs,
# as read from an encrypted M1 Pro, byte for byte the same as
# omarchy-mac-boot/files/etc/mkinitcpio.conf.d in omacom/omarchy-mac-pkgs at
# 4399105 (MIT). The encryption drop-in leaves a line carrying busybox encrypt
# alone, since that is a Mac unlocked through cryptdevice=, so the baseline must
# give a Mac the systemd line. No kernel modules here: the HID drop-in adds
# only what modinfo finds.
mac_etc() {
  new_etc
  cp "$ROOT"/test/shell.d/fixtures/omarchy-mac-boot-mkinitcpio/*.conf "$etc/mkinitcpio.conf.d/"
  sed -i "s/^HOOKS=.*/HOOKS=($1)/" "$etc/mkinitcpio.conf"
}

mac_files() {
  KERNEL_MODULES="" compose aarch64-apple | sed -n 's/^FILES=//p'
}

# The HOOKS the M1 Pro builds its encrypted image from today.
mac_hooks="base systemd plymouth autodetect microcode modconf kms keyboard sd-vconsole block asahi omarchy-vendorfw omarchy-mac-encrypt sd-encrypt filesystems fsck"
alarm_systemd="base systemd autodetect microcode modconf kms keyboard sd-vconsole block filesystems fsck"
alarm_busybox="base udev autodetect microcode modconf kms keyboard keymap consolefont block filesystems fsck"

printf 'KEYMAP=us\nXKBLAYOUT=us\n' >"$vconsole"
mac_etc "$alarm_systemd"
KERNEL_MODULES="" assert_hooks "a Mac keeps its firmware and systemd unlock hooks" aarch64-apple "$mac_hooks"
[[ $(mac_files) == *"$vconsole"* ]] || fail "a Latin layout reaches the Mac image" "FILES=$(mac_files)"
pass "a Latin layout reaches the Mac image"
mac_etc "$alarm_busybox"
KERNEL_MODULES="" assert_hooks "a Mac whose mkinitcpio.conf has the busybox line gets the same hooks" aarch64-apple "$mac_hooks"

printf 'KEYMAP=ru\nXKBLAYOUT=ru\n' >"$vconsole"
mac_etc "$alarm_systemd"
KERNEL_MODULES="" assert_hooks "a non-Latin layout keeps the Mac prompt on the US map" aarch64-apple "${mac_hooks/ sd-vconsole / }"
[[ $(mac_files) != *vconsole* ]] || fail "a non-Latin layout stays out of the Mac image" "FILES=$(mac_files)"
pass "a non-Latin layout stays out of the Mac image"

# A Mac that unlocks through cryptdevice= keeps its busybox line, drop-ins and all.
printf 'KEYMAP=us\nXKBLAYOUT=us\n' >"$vconsole"
mac_etc "$legacy_encrypted"
KERNEL_MODULES="" assert_hooks "a busybox encrypt Mac keeps its own line with the Apple drop-ins" aarch64-apple "$legacy_encrypted"

rm -f "$vconsole"

# Exercise the reusable repair, not the one-time migration. Fake sudo accepts
# only these scratch-file operations and never forwards arbitrary commands.
repair="$test_tmp/repair"
repair_bin="$repair/bin"
filter="$repair/filter.conf"
images="$repair/images"
calls="$repair/calls"
mkdir -p "$repair_bin" "$images/esp" "$images/other-esp"
ln -s "$ROOT/bin/omarchy-cmd-present" "$repair_bin/omarchy-cmd-present"
for cmd in limine-mkinitcpio lsinitcpio; do
  printf '#!/bin/bash\nexit 97\n' >"$repair_bin/$cmd"
  chmod +x "$repair_bin/$cmd"
done
cat >"$repair_bin/sudo" <<'SH'
#!/bin/bash
set -euo pipefail
discovery='
for dir; do
  [[ -n $dir ]] || continue
  [[ -e $dir || -L $dir ]] || continue
  [[ -d $dir ]] || exit 1
  /usr/bin/find -H "$dir" -maxdepth 1 -name "*linux-t2*.efi" \( -type f -o -type l \) -print0
done
'
if [[ $# == 9 && $1 == "/bin/bash" && $2 == "-euo" && $3 == "pipefail" && $4 == "-c" && $5 == "$discovery" &&
      $6 == "--" && $7 == "$TEST_REPAIR/images/esp" && $8 == "$TEST_REPAIR/images/other-esp" && $9 == "$TEST_REPAIR/images/absent" ]]; then
  # The script and all roots are exact known arguments, not arbitrary sudo.
  /bin/bash -euo pipefail -c "$discovery" -- "$7" "$8" "$9"
elif [[ $# == 1 && $1 == "limine-mkinitcpio" ]]; then
  printf 'rebuild\n' >>"$TEST_REPAIR/calls"
  exit "${REBUILD_STATUS:-0}"
elif [[ $# == 3 && $1 == "chmod" && $2 == "644" && $3 == "$TEST_REPAIR/filter.conf" ]]; then
  /usr/bin/chmod 644 "$3"
elif [[ $# == 3 && $1 == "cp" && $2 == "$TMPDIR"/* && $3 == "$TEST_REPAIR/filter.conf" ]]; then
  /usr/bin/cp -- "$2" "$3"
elif [[ $# == 2 && $1 == "lsinitcpio" && $2 == "$TEST_REPAIR"/images/*linux-t2*.efi ]]; then
  [[ ! -e $2.unreadable ]] || exit 1
  /usr/bin/cat -- "$2"
else
  echo "Refusing unexpected fixture sudo: $*" >&2
  exit 97
fi
SH
chmod +x "$repair_bin/sudo"

run_repair() {
  "${clean_env[@]}" PATH="$repair_bin:$safe_bin" TEST_REPAIR="$repair" \
    REBUILD_STATUS="${REBUILD_STATUS:-0}" OMARCHY_INITRAMFS_MODULES_CONF="$filter" \
    OMARCHY_T2_BOOT_IMAGES="$images/esp:$images/other-esp:$images/absent" \
    /bin/bash "$ROOT/bin/omarchy-repair-t2-initramfs"
}

generated=${installer_filter/_omarchy_absent=(t2bce_vhci)/_omarchy_absent=(t2bce_vhci thunderbolt)}
printf '%s\nMODULES+=(nvme)\n' "$generated" >"$filter"
cp "$filter" "$repair/custom.conf"
run_repair >"$repair/out" 2>"$repair/err"
cmp -s "$filter" "$repair/custom.conf" || fail "the T2 repair preserves custom boot additions"
new_etc
drop_in zz-omarchy-kernel-modules.conf <"$filter"
KERNEL_MODULES="$t2_modules" assert_composed "custom boot additions survive the repair and the later T2 drop-in" x86 \
  "$omarchy_hooks" "nvme t2bce_dma t2bce_core t2bce_vhci usbhid hid_apple hid_generic xhci_pci xhci_hcd" ""

printf '%s\n' "$generated" >"$filter"
chmod 000 "$filter"
if run_repair >"$repair/out" 2>"$repair/err"; then
  fail "an unreadable installer filter cannot count as repaired"
fi
chmod 644 "$filter"
pass "an unreadable installer filter cannot count as repaired"
run_repair >"$repair/out" 2>"$repair/err"
new_etc
drop_in apple-t2.conf <<<"MODULES+=(t2bce_vhci usbhid hid_apple hid_generic xhci_pci xhci_hcd)"
drop_in zz-omarchy-kernel-modules.conf <"$filter"
KERNEL_MODULES="${t2_modules/thunderbolt /}" assert_composed "the repaired filter keeps available T2 modules and drops absent thunderbolt" x86 \
  "$omarchy_hooks" "t2bce_vhci usbhid hid_apple hid_generic xhci_pci xhci_hcd t2bce_dma t2bce_core" ""
KERNEL_MODULES="thunderbolt usbhid hid_apple hid_generic xhci_pci xhci_hcd" \
  assert_composed "the repaired filter still drops modules the kernel lacks" x86 \
  "$omarchy_hooks" "usbhid hid_apple hid_generic xhci_pci xhci_hcd thunderbolt" ""

normal="$images/esp/omarchy_linux-t2.efi"
fallback="$images/esp/omarchy_linux-t2-fallback.efi"
module='usr/lib/modules/test/kernel/drivers/staging/t2bce/t2bce_vhci.ko.zst'
printf '%s\n' "$module" >"$fallback"
: >"$normal"
if run_repair >"$repair/out" 2>"$repair/err"; then
  fail "a working fallback cannot hide a broken normal image"
fi
grep -Fq "$normal" "$repair/err" || fail "the repair identifies the broken normal image"
pass "a working fallback cannot hide a broken normal image"

printf '%s\n' "$module" >"$normal"
: >"$normal.unreadable"
if run_repair >"$repair/out" 2>"$repair/err"; then
  fail "an unreadable normal image cannot count as repaired"
fi
pass "an unreadable normal image cannot count as repaired"
rm "$normal.unreadable"
printf '%s\n' "$module.disabled" >"$normal"
if run_repair >"$repair/out" 2>"$repair/err"; then
  fail "a similarly named file cannot count as the T2 module"
fi
pass "a similarly named file cannot count as the T2 module"

printf '%s\n' "$module" >"$normal"
: >"$images/other-esp/omarchy_linux-t2.efi"
if run_repair >"$repair/out" 2>"$repair/err"; then
  fail "a good first ESP cannot hide a broken image on another ESP"
fi
printf '%s\n' "$module" >"$images/other-esp/omarchy_linux-t2.efi"
run_repair >"$repair/out" 2>"$repair/err"
pass "all discovered T2 boot images must carry the module"

if REBUILD_STATUS=1 run_repair >"$repair/out" 2>"$repair/err"; then
  fail "a failed rebuild cannot count as repaired"
fi
pass "a failed rebuild cannot count as repaired"

chmod 000 "$images/esp"
if run_repair >"$repair/out" 2>"$repair/err"; then
  fail "an unlistable ESP cannot masquerade as no boot images"
fi
chmod 755 "$images/esp"
pass "an unlistable ESP cannot masquerade as no boot images"

printf '%s\n' "${generated/t2bce_vhci thunderbolt/thunderbolt}" >"$filter"
: >"$calls"
run_repair >"$repair/out" 2>"$repair/err"
[[ ! -s $calls ]] || fail "a non-T2 installer filter does not trigger a rebuild"
pass "a non-T2 installer filter does not trigger a rebuild"
