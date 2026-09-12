#!/bin/bash
set -euo pipefail

# Install and configure MSI-specific drivers for Titan/Stealth/Raider/etc laptops.
# Requires omarchy-hw-msi detection to gate execution.

if omarchy-hw-msi; then
  # Killer E-series Ethernet (RTL8125B) — blacklist r8169 for stability.
  # Use sysfs reads instead of lspci (see PR #11259) to avoid waking
  # suspended GPUs on hybrid laptops.
  pci_devices_path="${OMARCHY_PCI_DEVICES_PATH:-/sys/bus/pci/devices}"
  rtl8125b_found=false
  for device in "$pci_devices_path"/*; do
    [[ $(< "$device/vendor" 2>/dev/null) == "0x10ec" ]] || continue
    device_id=$(< "$device/device" 2>/dev/null)
    if [[ $device_id == "0x8125" ]]; then
      rtl8125b_found=true
      break
    fi
  done

  if $rtl8125b_found; then
    if ! omarchy-pkg-present r8125-dkms 2>/dev/null; then
      omarchy-pkg-add r8125-dkms || echo "WARNING: Failed to install r8125-dkms" >&2
    fi

    # Blacklist r8169 so r8125 loads exclusively. Only do this if r8125
    # is actually loaded — otherwise we risk leaving the system with no
    # network driver until the next reboot.
    if lsmod | grep -q r8125; then
      sudo install -Dm644 /dev/stdin /etc/modprobe.d/r8169.conf <<'EOF'
blacklist r8169
EOF
      sudo install -Dm644 /dev/stdin /etc/modules-load.d/r8125.conf <<'EOF'
r8125
EOF
      limine-mkinitcpio 2>/dev/null || sudo mkinitcpio -P
    else
      echo "WARNING: r8125 module not loaded — skipping blacklist to avoid network loss" >&2
    fi
  fi

  # MSI Embedded Controller — required for fan modes, shift modes,
  # battery thresholds, and other laptop-specific features.
  if ! lsmod | grep -q msi_ec; then
    if ! omarchy-pkg-present msi-ec-dkms-git 2>/dev/null; then
      omarchy-pkg-add msi-ec-dkms-git || echo "WARNING: Failed to install msi-ec-dkms-git" >&2
    fi
  fi

  # Set battery charge thresholds for battery health.
  # Start charging at 60%, stop at 80% to preserve battery lifespan.
  # Only set if the system is currently on battery (not AC power).
  if [[ -f /sys/class/power_supply/BAT1/charge_control_start_threshold ]]; then
    current_status=$(cat /sys/class/power_supply/BAT1/status 2>/dev/null)
    if [[ $current_status == "Discharging" ]]; then
      echo 60 | sudo tee /sys/class/power_supply/BAT1/charge_control_start_threshold >/dev/null
      echo 80 | sudo tee /sys/class/power_supply/BAT1/charge_control_end_threshold >/dev/null
    fi
  fi

  # CoolerControl for fan curves + thermal management. Disable thermald
  # (generic DPTF) to avoid conflicts — coolercontrold talks to the EC
  # directly and knows the MSI fan table.
  if ! omarchy-pkg-present coolercontrol 2>/dev/null; then
    omarchy-pkg-add coolercontrol || echo "WARNING: Failed to install coolercontrol" >&2
  fi

  if systemctl is-enabled thermald.service &>/dev/null; then
    sudo systemctl disable --now thermald.service || echo "WARNING: Failed to disable thermald" >&2
  fi

  if ! systemctl is-active coolercontrold.service &>/dev/null; then
    sudo systemctl enable --now coolercontrold.service || echo "WARNING: Failed to enable coolercontrold" >&2
  fi

  # NVIDIA-settings for GPU monitoring and tuning on MSI dGPU laptops
  if omarchy-hw-nvidia; then
    if ! omarchy-pkg-present nvidia-settings 2>/dev/null; then
      omarchy-pkg-add nvidia-settings || echo "WARNING: Failed to install nvidia-settings" >&2
    fi

    # X11 config for DPMS and backlight control via nvidia-settings
    sudo install -Dm644 /dev/stdin /etc/X11/xorg.conf.d/10-nvidia-dpms.conf <<'EOF'
Section "Device"
    Identifier "NVIDIA Card"
    Driver "nvidia"
    Option "RegistryDwords" "EnableBrightnessControl=1"
EndSection

Section "Screen"
    Identifier "Screen0"
    Device "NVIDIA Card"
    Option "AllowNVIDIAGPUScreens" "on"
EndSection
EOF
  fi

  # Early-load msi_ec module via mkinitcpio if it's currently loaded
  if lsmod | grep -q msi_ec; then
    sudo install -Dm644 /dev/stdin /etc/mkinitcpio.conf.d/msi.conf <<'EOF'
MODULES+=(msi_ec)
EOF
    limine-mkinitcpio 2>/dev/null || sudo mkinitcpio -P
  fi
fi
