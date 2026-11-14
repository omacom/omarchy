#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_platform_fixtures "the composed mkinitcpio HOOKS"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

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
#
# Plymouth's install hook is mocked. Omarchy installs it, and the legacy LUKS
# line gains plymouth only when the file is there; the suite must not depend on
# the machine running the test having /usr/lib/initcpio/install/plymouth.
vconsole="$test_tmp/vconsole.conf"
initcpio_install="$test_tmp/initcpio-install"
mkdir -p "$initcpio_install" "$test_tmp/initcpio-install-without"
printf '#!/bin/bash\n' >"$initcpio_install/plymouth"
compose() {
  local fixture="$test_tmp/platforms/$1" config="$test_tmp/buildconfig" conf
  local -a conf_files=()
  local install_dir=$initcpio_install
  [[ -z ${OMARCHY_INITCPIO_INSTALL:-} ]] || install_dir=$OMARCHY_INITCPIO_INSTALL
  mapfile -d '' conf_files < <(LC_ALL=C.UTF-8 find "$etc/mkinitcpio.conf.d" -maxdepth 1 -xtype f -name '*.conf' -print0 |
    sed -z 's/.*\///' | LC_ALL=C.UTF-8 sort -zVu)
  cat -- "$etc/mkinitcpio.conf" >"$config"
  for conf in "${conf_files[@]}"; do
    cat -- "$etc/mkinitcpio.conf.d/$conf" >>"$config"
  done
  sed -i "s|/etc/vconsole.conf|$vconsole|g" "$config"

  local path="$fixture/bin:$ROOT/bin:$PATH"
  [[ $1 != "no-detector" ]] || path="$fixture/bin"
  KERNELVERSION=6.99.0-test OMARCHY_PROC_ROOT="$fixture/proc" OMARCHY_PCI_DEVICES_PATH="$devices" \
    OMARCHY_INITCPIO_INSTALL="$install_dir" PATH="$path" "$BASH" -c '
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

# The line a pre-4.5 Asahi install actually stores. Plymouth was never in the
# file; the old drop-in supplied it at build time, and 4.5 stopped doing so
# (#18009). It comes back after udev, and the rest of the line stays, including
# asahi and busybox encrypt. The same insert applies off a Mac when asahi marks
# the root, and with no detector at all. It does not apply when the plymouth
# install hook is absent, or when the line has no passphrase prompt.
legacy_luks_without_plymouth="base asahi udev autodetect microcode modconf kms keyboard keymap consolefont block encrypt filesystems fsck"
legacy_luks_with_plymouth="base asahi udev plymouth autodetect microcode modconf kms keyboard keymap consolefont block encrypt filesystems fsck"
legacy_luks_no_asahi="base udev autodetect microcode modconf kms keyboard keymap consolefont block encrypt filesystems fsck"
legacy_luks_no_asahi_with_plymouth="base udev plymouth autodetect microcode modconf kms keyboard keymap consolefont block encrypt filesystems fsck"
for platform in aarch64-apple no-detector aarch64 x86; do
  new_etc
  sed -i "s/^HOOKS=.*/HOOKS=($legacy_luks_without_plymouth)/" "$etc/mkinitcpio.conf"
  assert_hooks "a legacy LUKS line gains plymouth after udev ($platform)" "$platform" "$legacy_luks_with_plymouth"
done
new_etc
sed -i "s/^HOOKS=.*/HOOKS=($legacy_luks_without_plymouth)/" "$etc/mkinitcpio.conf"
OMARCHY_INITCPIO_INSTALL="$test_tmp/initcpio-install-without" \
  assert_hooks "a legacy LUKS line stays without plymouth when the hook is not installed" aarch64-apple "$legacy_luks_without_plymouth"
new_etc
sed -i "s/^HOOKS=.*/HOOKS=($legacy_luks_no_asahi)/" "$etc/mkinitcpio.conf"
assert_hooks "a Mac whose busybox encrypt line omitted plymouth gains it" aarch64-apple "$legacy_luks_no_asahi_with_plymouth"
for platform in x86 aarch64 no-detector; do
  new_etc
  sed -i "s/^HOOKS=.*/HOOKS=($legacy_luks_no_asahi)/" "$etc/mkinitcpio.conf"
  assert_hooks "busybox encrypt without asahi still gets the Omarchy baseline ($platform)" "$platform" "$omarchy_hooks"
done
new_etc
sed -i "s/^HOOKS=.*/HOOKS=(base asahi encrypt filesystems fsck)/" "$etc/mkinitcpio.conf"
assert_hooks "a legacy LUKS line without udev gains plymouth before encrypt" aarch64-apple \
  "base asahi plymouth encrypt filesystems fsck"
new_etc
sed -i "s/^HOOKS=.*/HOOKS=(base systemd autodetect microcode modconf kms keyboard sd-vconsole block asahi sd-encrypt filesystems fsck)/" "$etc/mkinitcpio.conf"
assert_hooks "an asahi systemd line without busybox encrypt does not gain plymouth here" aarch64-apple \
  "base systemd autodetect microcode modconf kms keyboard sd-vconsole block asahi sd-encrypt filesystems fsck"

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
# The Apple package inserts plymouth only after systemd, so a legacy encrypt
# line would still miss it without the baseline insert. encrypt stays: sd-encrypt
# cannot parse cryptdevice=. With no plymouth install hook, the line is untouched.
mac_etc "$legacy_luks_without_plymouth"
KERNEL_MODULES="" assert_hooks "a busybox encrypt Mac without plymouth keeps encrypt and gains plymouth" aarch64-apple "$legacy_luks_with_plymouth"
mac_etc "$legacy_luks_without_plymouth"
KERNEL_MODULES="" OMARCHY_INITCPIO_INSTALL="$test_tmp/initcpio-install-without" \
  assert_hooks "without the plymouth hook a busybox encrypt Mac stays on its own line" aarch64-apple "$legacy_luks_without_plymouth"

# Exercise the reusable repair, never the one-shot migration. Its entire PATH
# is an allowlist: removing a fixture builder must not expose the host's one.
repair="$test_tmp/repair"
repair_command="$ROOT/bin/omarchy-repair-apple-plymouth"
mkdir -p "$repair/bin" "$repair/home" "$repair/runtime" "$repair/tmp"
for tool in bash rm install; do
  ln -s "$(command -v "$tool")" "$repair/bin/$tool"
done
for tool in cat find sort mktemp; do
  cat >"$repair/bin/$tool" <<'SH'
#!/bin/bash
[[ ${TEST_FAIL_TOOL:-} != "${0##*/}" ]] || exit 42
exec "/usr/bin/${0##*/}" "$@"
SH
  chmod +x "$repair/bin/$tool"
done
for tool in omarchy-hw-platform omarchy-cmd-present; do
  ln -s "$ROOT/bin/$tool" "$repair/bin/$tool"
done
cat >"$repair/bin/sudo" <<'SH'
#!/bin/bash
# No arbitrary dispatch, even if this fixture accidentally inherits host PATH.
case $1 in
  mkinitcpio|limine-mkinitcpio) exec "$TEST_REPAIR_ROOT/bin/$1" "${@:2}" ;;
  install)
    (( $# == 4 )) && [[ $2 == "-Dm644" && $3 == "/dev/null" && $4 == "$TEST_REPAIR_ROOT/rebuilt" ]] || exit 125
    exec "$TEST_REPAIR_ROOT/bin/install" "${@:2}"
    ;;
  *) exit 125 ;;
esac
SH
make_builder() {
  cat >"$repair/bin/$1" <<'SH'
#!/bin/bash
printf '%s %s\n' "${0##*/}" "$*" >>"$TEST_REPAIR_ROOT/build-log"
exit "${TEST_BUILD_STATUS:-0}"
SH
  chmod +x "$repair/bin/$1"
}
chmod +x "$repair/bin/sudo"
make_builder mkinitcpio
make_builder limine-mkinitcpio

new_repair() {
  new_etc
  sed -i "s/^HOOKS=.*/HOOKS=($legacy_luks_without_plymouth)/" "$etc/mkinitcpio.conf"
  sed -i "s|/etc/vconsole.conf|$repair/vconsole.conf|g" "$etc/mkinitcpio.conf.d/omarchy_hooks.conf"
  rm -f "$repair/build-log" "$repair/rebuilt"
}
run_repair() {
  local platform=${1:-aarch64-apple}
  env -i HOME="$repair/home" XDG_CONFIG_HOME="$repair/home/.config" \
    XDG_STATE_HOME="$repair/home/.local/state" XDG_RUNTIME_DIR="$repair/runtime" TMPDIR="$repair/tmp" \
    PATH="$repair/bin:$test_tmp/platforms/$platform/bin" OMARCHY_PATH="$ROOT" \
    OMARCHY_PROC_ROOT="$test_tmp/platforms/$platform/proc" OMARCHY_PCI_DEVICES_PATH="$devices" \
    OMARCHY_MKINITCPIO_CONF="$etc/mkinitcpio.conf" OMARCHY_MKINITCPIO_CONF_DIR="$etc/mkinitcpio.conf.d" \
    OMARCHY_INITCPIO_INSTALL="$initcpio_install" OMARCHY_PLYMOUTH_REBUILD_MARKER="$repair/rebuilt" \
    KERNELVERSION=6.99.0-test TEST_REPAIR_ROOT="$repair" \
    TEST_FAIL_TOOL="${TEST_FAIL_TOOL:-}" TEST_BUILD_STATUS="${TEST_BUILD_STATUS:-0}" \
    /bin/bash "$repair_command"
}
assert_repair_pending() {
  local description=$1
  if run_repair "${2:-aarch64-apple}" >"$repair/output" 2>"$repair/error"; then
    fail "$description" "repair incorrectly returned success"
  fi
  [[ ! -e $repair/rebuilt ]] || fail "$description" "repair incorrectly recorded completion"
  pass "$description"
}

new_repair
# The asahi hook is enough even when the runtime detector is not installed.
rm "$repair/bin/omarchy-hw-platform"
run_repair no-detector >/dev/null
run_repair no-detector >/dev/null
[[ $(<"$repair/build-log") == "mkinitcpio -P" && -f $repair/rebuilt ]] || fail "the repair builds a legacy image once without a detector"
pass "the repair builds a legacy image once without a detector"
ln -s "$ROOT/bin/omarchy-hw-platform" "$repair/bin/omarchy-hw-platform"

new_repair
# The Mac predicate must work independently of an asahi token in HOOKS.
sed -i 's/ asahi / /' "$etc/mkinitcpio.conf"
run_repair >/dev/null
[[ $(<"$repair/build-log") == "mkinitcpio -P" && -f $repair/rebuilt ]] || fail "a Mac encrypt line rebuilds without an asahi hook"
pass "a Mac encrypt line rebuilds without an asahi hook"

new_repair
rm "$repair/bin/mkinitcpio"
run_repair >/dev/null
[[ $(<"$repair/build-log") == "limine-mkinitcpio " && -f $repair/rebuilt ]] || fail "the repair uses the fallback builder with no host lookup"
pass "the repair uses the fallback builder with no host lookup"
make_builder mkinitcpio

for hooks in "$legacy_luks_with_plymouth" "$apple_hooks" "base asahi udev filesystems fsck"; do
  new_repair
  sed -i "s/^HOOKS=.*/HOOKS=($hooks)/" "$etc/mkinitcpio.conf"
  run_repair >/dev/null
  [[ ! -e $repair/build-log && ! -e $repair/rebuilt ]] || fail "an unaffected line is not rebuilt: $hooks"
done
new_repair
printf ':\n' >"$etc/mkinitcpio.conf.d/00-omarchy-hooks.conf"
run_repair >/dev/null
[[ ! -e $repair/build-log && ! -e $repair/rebuilt ]] || fail "a held-back Plymouth drop-in is not rebuilt"
pass "unaffected lines and a held-back Plymouth drop-in are not rebuilt"

new_repair
printf 'return 1\n' >"$etc/mkinitcpio.conf"
assert_repair_pending "a config read failure stays pending"
new_repair
printf 'false\nHOOKS=(base asahi encrypt)\n' >"$etc/mkinitcpio.conf"
assert_repair_pending "a config error before a successful assignment stays pending"
new_repair
assert_repair_pending "a platform detector failure stays pending" contradiction
new_repair
printf 'return 1\n' >"$etc/mkinitcpio.conf.d/99-broken.conf"
assert_repair_pending "a composed config failure stays pending"
new_repair
printf 'false\n:\n' >"$etc/mkinitcpio.conf.d/99-broken.conf"
assert_repair_pending "an error inside a composed drop-in stays pending"
for tool in mktemp cat find sort; do
  new_repair
  TEST_FAIL_TOOL=$tool assert_repair_pending "a $tool failure during composition stays pending"
  [[ ! -e $repair/build-log ]] || fail "a $tool failure must not reach a builder"
done
new_repair
rm "$repair/bin/mkinitcpio" "$repair/bin/limine-mkinitcpio"
assert_repair_pending "an affected machine without either builder stays pending"
make_builder mkinitcpio
make_builder limine-mkinitcpio
new_repair
TEST_BUILD_STATUS=42 assert_repair_pending "a failed builder leaves no completion marker"
run_repair >/dev/null
[[ $(<"$repair/build-log") == $'mkinitcpio -P\nmkinitcpio -P' && -f $repair/rebuilt ]] || fail "a failed build is retried successfully"
pass "a failed build is retried successfully"
