#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

command="$ROOT/bin/omarchy-install-imac20-amdgpu-hwaccel"
all_hardware="$ROOT/install/hardware/all.sh"
manual="$ROOT/manual/44-mac-support.md"

test -x "$command" || fail "opt-in command is executable"
! grep -Fq 'imac20-amdgpu-hwaccel' "$all_hardware" ||
  fail "hardware acceleration stays opt-in, not part of install"
grep -Fq 'omarchy-install-imac20-amdgpu-hwaccel' "$manual" ||
  fail "Mac support manual mentions the opt-in command"
! grep -Eq 'git clone|amdgpu\.ko' "$command" ||
  fail "opt-in uses the linux-t2 package amdgpu, no module build"
pass "iMac20 hardware acceleration is an opt-in command"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT
stubs="$tmp_dir/bin"
mkdir -p "$stubs" "$tmp_dir/uki" "$tmp_dir/devices/0000:03:00.0"

echo "iMac20,1" >"$tmp_dir/product_name"
echo 0x1002 >"$tmp_dir/devices/0000:03:00.0/vendor"
echo 0x7340 >"$tmp_dir/devices/0000:03:00.0/device"
echo 0x030000 >"$tmp_dir/devices/0000:03:00.0/class"

cat >"$stubs/sudo" <<'SH'
#!/bin/bash
exec "$@"
SH

# Build the default UKI with whatever cmdline the display drop-in currently holds.
cat >"$stubs/limine-mkinitcpio" <<'SH'
#!/bin/bash
echo "limine-mkinitcpio" >>"$TEST_LOG"
[[ -n ${FAIL_MKINITCPIO:-} ]] && exit 1
sed -n 's/^KERNEL_CMDLINE\[default\]+=" \(.*\)"$/\1/p' "$OMARCHY_IMAC20_DISPLAY_CONF" \
  >"$OMARCHY_UKI_DIR/omarchy_linux-t2.efi"
SH

cat >"$stubs/objcopy" <<'SH'
#!/bin/bash
cat "$4"
SH

cat >"$stubs/limine-entry-tool" <<'SH'
#!/bin/bash
echo "limine-entry-tool $*" >>"$TEST_LOG"
[[ $1 == --remove-efi-path ]] && rm -f "$2"
exit 0
SH
chmod +x "$stubs"/*

run() {
  OMARCHY_DMI_PRODUCT_NAME="$tmp_dir/product_name" \
    OMARCHY_PCI_DEVICES_PATH="$tmp_dir/devices" \
    OMARCHY_IMAC20_DISPLAY_CONF="$tmp_dir/imac20-display.conf" \
    OMARCHY_LIMINE_CONF="$tmp_dir/limine.conf" \
    OMARCHY_UKI_DIR="$tmp_dir/uki" \
    OMARCHY_IMAC20_HWACCEL_HOOK="$tmp_dir/hwaccel.hook" \
    TEST_LOG="$tmp_dir/calls.log" \
    PATH="$stubs:$ROOT/bin:$PATH" \
    "$command" "$@" </dev/null >"$tmp_dir/out.log" 2>&1
}

cat >"$tmp_dir/imac20-display.conf" <<'EOF'
KERNEL_CMDLINE[default]+=" plymouth.enable=0 nomodeset"
EOF
printf '%s\n' '#default_entry: <OS name>/<kernel name>' >"$tmp_dir/limine.conf"

run || fail "opt-in succeeds" "$(cat "$tmp_dir/out.log")"
grep -Fq 'amdgpu.modeset=1 video=efifb:off' "$tmp_dir/uki/omarchy_linux-t2-hwaccel.efi" ||
  fail "hardware-acceleration UKI boots amdgpu with the EFI framebuffer off"
grep -Fq 'nomodeset' "$tmp_dir/uki/omarchy_linux-t2.efi" ||
  fail "default UKI is rebuilt with the safe flags"
grep -Fq 'plymouth.enable=0 nomodeset' "$tmp_dir/imac20-display.conf" ||
  fail "display drop-in is restored to the safe flags"
grep -Fq 'limine-entry-tool --add-efi imac20-hwaccel' "$tmp_dir/calls.log" ||
  fail "hardware-acceleration Limine entry is added"
grep -Fq '#default_entry:' "$tmp_dir/limine.conf" ||
  fail "safe entry stays the default without --default"
grep -Fq 'Target = linux-t2' "$tmp_dir/hwaccel.hook" &&
  grep -Fq 'omarchy-install-imac20-amdgpu-hwaccel --rebuild' "$tmp_dir/hwaccel.hook" ||
  fail "pacman hook rebuilds the entry on linux-t2 upgrades"
pass "opt-in adds a hardware-acceleration entry next to the safe default"

run --default || fail "--default succeeds" "$(cat "$tmp_dir/out.log")"
grep -Fxq 'default_entry: imac20-hwaccel' "$tmp_dir/limine.conf" ||
  fail "--default boots the hardware-acceleration entry"
pass "--default makes the hardware-acceleration entry the default"

: >"$tmp_dir/calls.log"
FAIL_MKINITCPIO=1 run --rebuild || fail "--rebuild never fails the pacman transaction"
[[ ! -e $tmp_dir/uki/omarchy_linux-t2-hwaccel.efi ]] ||
  fail "failed rebuild removes the stale hardware-acceleration UKI"
grep -Fq '#default_entry:' "$tmp_dir/limine.conf" ||
  fail "failed rebuild falls back to the safe default"
grep -Fq 'plymouth.enable=0 nomodeset' "$tmp_dir/imac20-display.conf" ||
  fail "failed rebuild restores the safe flags"
pass "failed rebuild falls back to the safe entry"

run || fail "opt-in succeeds again"
run --remove || fail "--remove succeeds"
[[ ! -e $tmp_dir/uki/omarchy_linux-t2-hwaccel.efi && ! -e $tmp_dir/hwaccel.hook ]] ||
  fail "--remove drops the entry and the hook"
pass "--remove drops the entry and the hook"

echo "MacBookPro16,1" >"$tmp_dir/product_name"
: >"$tmp_dir/calls.log"
run || fail "exits 0 on other hardware"
[[ ! -s $tmp_dir/calls.log ]] || fail "other hardware is left alone" "$(cat "$tmp_dir/calls.log")"
pass "other hardware is left alone"
