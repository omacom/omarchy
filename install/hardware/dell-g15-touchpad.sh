# Make the Synaptics I2C-HID touchpad (VEN_06CB:00 06CB:CE81) on the Dell G15
# 5530 bind at boot.
#
# On this model i2c_hid_acpi loads but never binds to the touchpad and logs
# nothing, so Hyprland only sees the PS/2 mouse. Reloading i2c_hid_acpi after
# boot binds it straight away: the driver probes before the Raptor Lake GPIO
# (pinctrl_alderlake) and LPSS I2C (intel_lpss_pci) drivers it depends on are
# up. Load those two in the initramfs, and order i2c_hid_acpi after them for
# when it loads from the root filesystem instead.
#
# Only writes boot settings: the installer's final limine-update builds the
# image, and the migration rebuilds it on existing installs.
# See https://github.com/omacom/omarchy/issues/17322

if omarchy-hw-x86 && omarchy-hw-match "G15 5530"; then
  sudo mkdir -p /etc/modprobe.d /etc/mkinitcpio.conf.d
  sudo tee /etc/modprobe.d/dell-g15-touchpad.conf >/dev/null <<'CONF'
softdep i2c_hid_acpi pre: pinctrl_alderlake intel_lpss_pci
CONF
  sudo tee /etc/mkinitcpio.conf.d/dell_g15_touchpad.conf >/dev/null <<'CONF'
MODULES+=(intel_lpss_pci pinctrl_alderlake)
CONF
fi
