# Intel MacBooks can leave the backlight/panel unprogrammed across LUKS until
# userspace modesetting runs, so the post-decrypt splash stays black. Load i915
# in the initramfs and keep the internal panel enabled on the cmdline (#13510).

sys_vendor="$(cat /sys/class/dmi/id/sys_vendor 2>/dev/null || true)"
[[ $sys_vendor == Apple* ]] || return 0

# Only Apple + Intel iGPU. NVIDIA/AMD Macs have their own early-KMS paths.
lspci -nn 2>/dev/null | grep -E 'VGA|3D|Display' | grep -qi '8086:' || return 0

echo "Detected Apple Intel graphics; enabling early i915 KMS for the disk unlock handoff"

mkdir -p /etc/mkinitcpio.conf.d
cat > /etc/mkinitcpio.conf.d/apple-intel-kms.conf <<'DROPIN'
# Early KMS so the internal panel is programmed before the LUKS password UI
# and the post-decrypt handoff to the running system (#13510).
MODULES+=(i915)
DROPIN

mkdir -p /etc/limine-entry-tool.d
cat > /etc/limine-entry-tool.d/apple-intel-edp.conf <<'DROPIN'
# Keep the internal eDP connector enabled across the initramfs → userspace
# modeset gap on Intel MacBooks (#13510).
KERNEL_CMDLINE[default]+=" video=eDP-1:e"
DROPIN
