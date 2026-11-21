echo "Enable early i915 KMS on Apple Intel Macs"

sys_vendor="$(cat /sys/class/dmi/id/sys_vendor 2>/dev/null || true)"
[[ $sys_vendor == Apple* ]] || exit 0
lspci -nn 2>/dev/null | grep -E 'VGA|3D|Display' | grep -qi '8086:' || exit 0

mkinit_dropin=/etc/mkinitcpio.conf.d/apple-intel-kms.conf
limine_dropin=/etc/limine-entry-tool.d/apple-intel-edp.conf
rebuild_marker=/var/lib/omarchy/migrations/1790599768

if [[ ! -f $mkinit_dropin ]]; then
  sudo rm -f "$rebuild_marker"
  sudo mkdir -p /etc/mkinitcpio.conf.d
  sudo tee "$mkinit_dropin" >/dev/null <<'DROPIN'
# Early KMS so the internal panel is programmed before the LUKS password UI
# and the post-decrypt handoff to the running system (#13510).
MODULES+=(i915)
DROPIN
fi

if [[ ! -f $limine_dropin ]]; then
  sudo rm -f "$rebuild_marker"
  sudo mkdir -p /etc/limine-entry-tool.d
  sudo tee "$limine_dropin" >/dev/null <<'DROPIN'
# Keep the internal eDP connector enabled across the initramfs → userspace
# modeset gap on Intel MacBooks (#13510).
KERNEL_CMDLINE[default]+=" video=eDP-1:e"
DROPIN
fi

if [[ ! -f $rebuild_marker ]] && omarchy-cmd-present limine-mkinitcpio; then
  sudo limine-mkinitcpio
  sudo mkdir -p /var/lib/omarchy/migrations
  sudo touch "$rebuild_marker"
fi
