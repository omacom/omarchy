# Dual-GPU Macs route the internal panel through Apple's gmux, and their GPU
# drivers wait for apple-gmux before they bind: vga_switcheroo defers the
# inactive GPU's probe until gmux registers, and linux-t2 (patch 2009,
# apple-gmux-allow-switching-to-igpu-at-probe) extends that to every GPU,
# including the one driving the panel.
#
# mkinitcpio's kms hook only collects drivers/gpu/drm, so apple-gmux
# (drivers/platform/x86) is never in the initramfs. The deferred GPUs then wait
# until apple-gmux loads from the real root, after the LUKS unlock, and SDDM's
# autologin can start Hyprland before the panel's GPU exists: Hyprland comes up
# on simpledrm, loses it when amdgpu takes over, and the screen stays black.
# With apple-gmux in the initramfs, the GPUs bind before the root is unlocked.
# The generic fix belongs in mkinitcpio's kms hook; this covers Omarchy installs
# until it lands there.
#
# The MacBookPro16,1 is left out until someone tests it there. Its Radeon Pro
# 5300M/5500M can hang once an accelerated session runs on it (#9609), and some
# of those machines only reach a session today because amdgpu loses this race
# and Hyprland renders on Intel. Loading apple-gmux early would end that.
if omarchy-hw-apple-gmux && ! omarchy-hw-match "MacBookPro16,1"; then
  echo "Detected Apple gmux; loading apple-gmux from the initramfs"

  mkdir -p /etc/mkinitcpio.conf.d
  cat > /etc/mkinitcpio.conf.d/apple-gmux.conf <<'EOF'
# Load apple-gmux early so the GPU drivers waiting on it bind before login.
MODULES+=(apple_gmux)
EOF
fi
