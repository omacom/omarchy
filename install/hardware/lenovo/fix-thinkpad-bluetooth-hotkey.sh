# Unmask the ThinkPad Bluetooth F10 hotkey (thinkpad_acpi bit 20).

# Install-time chroots often lack the loaded module even on a ThinkPad, so DMI
# match is enough to ship the drop-in. The live sysfs OR still needs the module.
if ! omarchy-hw-match "ThinkPad" && [[ ! -d /sys/module/thinkpad_acpi ]]; then
  return 0
fi

sudo mkdir -p /etc/modprobe.d
sudo install -Dm644 "$OMARCHY_PATH/default/modprobe.d/omarchy-thinkpad-bluetooth-hotkey.conf" \
  /etc/modprobe.d/omarchy-thinkpad-bluetooth-hotkey.conf

# Apply immediately when the sysfs knob is writable; otherwise the drop-in
# takes effect on the next module load / reboot.
mask_path=/sys/devices/platform/thinkpad_acpi/hotkey_mask
if [[ -w $mask_path ]]; then
  current=$(<"$mask_path")
  printf '%#x\n' "$((current | 0x00100000))" | sudo tee "$mask_path" >/dev/null || true
fi
