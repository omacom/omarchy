# Dual-GPU Intel MacBook Pros wire the internal panel through Apple's gmux to
# either the Intel iGPU or the discrete GPU. Booted without macOS, the firmware
# gives the panel to the discrete GPU. On a MacBookPro11,3 that is a GT 750M
# (Kepler) on nouveau, which cannot reclock and runs the Retina desktop at boot
# clocks, so everything stutters. NVIDIA's own driver for Kepler (470xx) no
# longer builds against current kernels.
#
# The kernel's EFI stub already calls Apple's set_os protocol on these models,
# which keeps the iGPU alive. gpu-power-prefs is the NVRAM variable macOS
# writes for "integrated only": with it set to 1 the firmware switches gmux to
# Intel before the kernel starts, and i915 finds the panel. Hyprland is then
# pointed at the iGPU (default/hypr/apple-dual-gpu.lua) and the idle discrete
# GPU is powered off through vga_switcheroo. nouveau leaves runtime PM off on
# gmux Macs, so without that the GPU stays powered and the machine runs ~10C
# hotter at idle.
#
# Only the MacBookPro11,3 is verified. Other dual-GPU models the EFI stub
# handles (11,5, 13,3, 14,3, 15,x, 16,x) have AMD discrete GPUs and are left
# alone until someone tests them.
product_name="$(cat /sys/class/dmi/id/product_name 2>/dev/null || true)"

if [[ $product_name == "MacBookPro11,3" && -d /sys/firmware/efi/efivars ]]; then
  echo "Detected $product_name; driving the internal panel from the Intel iGPU"

  # Attributes NV+BS+RT (0x7), value 1 = integrated. efivarfs marks existing
  # variables immutable, so clear that before rewriting it.
  gpu_power_prefs=/sys/firmware/efi/efivars/gpu-power-prefs-fa4ce28d-b62f-4c99-9cc3-6815686e30f9
  if [[ -e $gpu_power_prefs ]]; then
    chattr -i "$gpu_power_prefs"
  fi
  printf '\x07\x00\x00\x00\x01\x00\x00\x00' > "$gpu_power_prefs"

  mkdir -p /etc/udev/rules.d
  cat > /etc/udev/rules.d/90-omarchy-apple-igpu.rules <<'EOF'
# Stable name for the Intel iGPU on dual-GPU Macs, read by default/hypr/apple-dual-gpu.lua.
SUBSYSTEM=="drm", KERNEL=="card[0-9]*", DRIVERS=="i915", SYMLINK+="dri/omarchy-apple-igpu"
EOF

  mkdir -p /etc/systemd/system
  cat > /etc/systemd/system/omarchy-apple-dgpu-off.service <<'EOF'
[Unit]
Description=Omarchy: power off the idle discrete GPU on dual-GPU Macs
After=systemd-modules-load.service display-manager.service suspend.target hibernate.target hybrid-sleep.target suspend-then-hibernate.target

[Service]
Type=oneshot
ExecStart=/bin/sh -c 'grep -q "^[0-9]*:DIS:.*Pwr" /sys/kernel/debug/vgaswitcheroo/switch && echo OFF > /sys/kernel/debug/vgaswitcheroo/switch || true'

[Install]
WantedBy=graphical.target suspend.target hibernate.target hybrid-sleep.target suspend-then-hibernate.target
EOF

  systemctl enable omarchy-apple-dgpu-off.service
fi
