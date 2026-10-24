#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT
mkdir -p "$tmp_dir/bin"
export CALL_LOG="$tmp_dir/calls"
export PATH="$tmp_dir/bin:$PATH"

# Every privileged or hardware-facing command is a shim that records its call.
for command in omarchy-pkg-add omarchy-pkg-drop limine-entry-tool limine-mkinitcpio systemctl; do
  printf '#!/bin/bash\necho "%s $*" >> "$CALL_LOG"\n' "$command" > "$tmp_dir/bin/$command"
done
cat > "$tmp_dir/bin/omarchy-hw-aarch64-n1x" <<'SH'
#!/bin/bash
[[ ${IS_N1X:-1} == 1 ]]
SH
cat > "$tmp_dir/bin/omarchy-hw-match" <<'SH'
#!/bin/bash
[[ ${PRODUCT:-H7407BA} == *"$1"* ]]
SH
cat > "$tmp_dir/bin/modinfo" <<'SH'
#!/bin/bash
[[ ${HAVE_NVIDIA:-1} == 1 ]]
SH
cat > "$tmp_dir/bin/uname" <<'SH'
#!/bin/bash
echo "$RUNNING_KERNEL"
SH
cat > "$tmp_dir/bin/sudo" <<'SH'
#!/bin/bash
"$@"
SH
chmod +x "$tmp_dir/bin/"*

migration="$ROOT/migrations/1791077437.sh"

run_migration() {
  rm -rf "$tmp_dir/etc" "$tmp_dir/modules" "$tmp_dir/marker"
  mkdir -p "$tmp_dir/etc/limine-entry-tool.d" "$tmp_dir/etc/mkinitcpio.conf.d" "$tmp_dir/etc/systemd/system" "$tmp_dir/etc/kernel"
  mkdir -p "$tmp_dir/modules/7.2.5-9-omarchy-n1x" "$tmp_dir/modules/7.0.14-3-n1x"
  echo linux-omarchy-n1x > "$tmp_dir/modules/7.2.5-9-omarchy-n1x/pkgbase"
  echo linux-n1x > "$tmp_dir/modules/7.0.14-3-n1x/pkgbase"
  echo 'cryptdevice=PARTUUID=x:root root=/dev/mapper/root rw' > "$tmp_dir/etc/kernel/cmdline"
  echo 'MODULES+=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)' > "$tmp_dir/etc/mkinitcpio.conf.d/nvidia.conf"
  echo '[Unit]' > "$tmp_dir/etc/systemd/system/omarchy-n1x-probe.service"
  : > "$CALL_LOG"
  OMARCHY_LIMINE_ENTRY_TOOL_DIR="$tmp_dir/etc/limine-entry-tool.d" \
    OMARCHY_MKINITCPIO_CONF_DIR="$tmp_dir/etc/mkinitcpio.conf.d" \
    OMARCHY_MODULES_DIR="$tmp_dir/modules" \
    OMARCHY_KERNEL_CMDLINE="$tmp_dir/etc/kernel/cmdline" \
    OMARCHY_N1X_PROBE_UNIT="$tmp_dir/etc/systemd/system/omarchy-n1x-probe.service" \
    OMARCHY_LIMINE_REBUILD_MARKER="$tmp_dir/marker" \
    bash -euo pipefail "$migration" >/dev/null 2>&1
}

rerun_migration() {
  : > "$CALL_LOG"
  OMARCHY_LIMINE_ENTRY_TOOL_DIR="$tmp_dir/etc/limine-entry-tool.d" \
    OMARCHY_MKINITCPIO_CONF_DIR="$tmp_dir/etc/mkinitcpio.conf.d" \
    OMARCHY_MODULES_DIR="$tmp_dir/modules" \
    OMARCHY_KERNEL_CMDLINE="$tmp_dir/etc/kernel/cmdline" \
    OMARCHY_N1X_PROBE_UNIT="$tmp_dir/etc/systemd/system/omarchy-n1x-probe.service" \
    OMARCHY_LIMINE_REBUILD_MARKER="$tmp_dir/marker" \
    bash -euo pipefail "$migration" >/dev/null 2>&1
}

export RUNNING_KERNEL=7.0.14-3-n1x

IS_N1X=0 run_migration
[[ ! -s $CALL_LOG && ! -e $tmp_dir/etc/limine-entry-tool.d/zz-omarchy-n1x-boot-order.conf ]] && pass "other machines are left alone" || fail "other machines are left alone"

export RUNNING_KERNEL=7.2.5-9-omarchy-n1x
run_migration
boot_order="$tmp_dir/etc/limine-entry-tool.d/zz-omarchy-n1x-boot-order.conf"
grep -Fq 'omarchy-pkg-add linux-omarchy-n1x linux-omarchy-n1x-headers' "$CALL_LOG" && pass "the new kernel is installed" || fail "the new kernel is installed"
grep -Fq 'MKINITCPIO_FALLBACK=linux-omarchy-n1x' "$boot_order" && pass "the rescue entry becomes the fallback UKI" || fail "the rescue entry becomes the fallback UKI"
grep -Fq 'KERNEL_CMDLINE[fallback]="cryptdevice=PARTUUID=x:root root=/dev/mapper/root rw initramfs_async=0 console=tty0' "$boot_order" && pass "the rescue cmdline keeps the root device" || fail "the rescue cmdline keeps the root device"
grep -Fq 'BOOT_ORDER="linux-omarchy-n1x, linux-omarchy-n1x-fallback, *, Snapshots"' "$boot_order" && pass "linux-omarchy-n1x boots by default" || fail "linux-omarchy-n1x boots by default"
grep -Fq 'i2c_mt65xx i2c_hid_acpi' "$tmp_dir/etc/mkinitcpio.conf.d/omarchy-n1x-input.conf" && pass "keyboard modules move into their own drop-in" || fail "keyboard modules move into their own drop-in"
grep -Fq 'mem_sleep_default=s2idle' "$tmp_dir/etc/limine-entry-tool.d/00-omarchy-n1x-sleep.conf" && pass "suspend to idle is set" || fail "suspend to idle is set"
grep -Fq 'power_wrap_drv.usb4_release=0' "$tmp_dir/etc/limine-entry-tool.d/00-omarchy-n1x-usb4.conf" && pass "the ProArt gets the USB4 cmdline" || fail "the ProArt gets the USB4 cmdline"
[[ ! -e $tmp_dir/etc/systemd/system/omarchy-n1x-probe.service ]] && pass "the every-boot probe is removed" || fail "the every-boot probe is removed"
grep -Fq 'limine-entry-tool --remove-uki linux-n1x-rescue' "$CALL_LOG" && pass "the one-off rescue UKI is removed" || fail "the one-off rescue UKI is removed"
grep -Fq 'omarchy-pkg-drop linux-n1x linux-n1x-headers' "$CALL_LOG" && pass "linux-n1x is dropped once the new kernel runs" || fail "linux-n1x is dropped once the new kernel runs"
grep -Fxq 'limine-mkinitcpio ' "$CALL_LOG" && [[ -e $tmp_dir/marker ]] && pass "the UKIs are rebuilt once" || fail "the UKIs are rebuilt once"
rerun_migration
[[ ! -s $CALL_LOG ]] && pass "another user's run is a no-op" || fail "another user's run is a no-op"

export RUNNING_KERNEL=7.0.14-3-n1x
run_migration
grep -Fq 'omarchy-pkg-drop linux-n1x' "$CALL_LOG" && fail "the running linux-n1x is kept" || pass "the running linux-n1x is kept"

if HAVE_NVIDIA=0 run_migration; then
  fail "missing NVIDIA modules leave the migration pending"
else
  [[ ! -e $boot_order ]] && pass "missing NVIDIA modules leave the migration pending" || fail "missing NVIDIA modules leave the migration pending"
fi

PRODUCT=DX16263 run_migration
[[ ! -e $tmp_dir/etc/limine-entry-tool.d/00-omarchy-n1x-usb4.conf ]] && pass "USB4 cmdline stays off where it is not validated" || fail "USB4 cmdline stays off where it is not validated"
