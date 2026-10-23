# Boot settings for the Microsoft Surface Laptop Ultra (NVIDIA N1x). Runs
# after n1x.sh, which writes the rescue entry's whole command line.
#
# The firmware's DSDT and SSDT3 return _STA=0 for the SSPM power manager
# (NVDA8400) and four other platform devices when _OSI("Windows 2022") is true,
# which Linux answers yes to. Without SSPM, mtk_pwrap fails and xHCI, I2C and
# SPI never probe: no USB, no internal keyboard or touchpad, so not even the
# LUKS passphrase can be typed. Those are the only _OSI checks in the tables,
# so acpi_osi=! changes nothing else.
#
# The Volume Down side button (MSHW0040, soc_button_array) reports itself held
# forever through gpio-keys, flooding the console and the compositor with
# volume-down presses. Keep gpio_keys from loading until soc_button_array
# handles this button; the side buttons do nothing meanwhile.
#
# The rescue entry gets a plain KERNEL_CMDLINE[fallback] assignment in
# zz-omarchy-n1x-boot-order.conf, so append to it from a drop-in that sorts
# after that one.

if omarchy-hw-aarch64-n1x && omarchy-hw-match "Surface Laptop Ultra"; then
  mkdir -p /etc/limine-entry-tool.d
  cat > /etc/limine-entry-tool.d/zz-omarchy-surface-laptop-ultra.conf <<'CONF'
# Surface Laptop Ultra: the DSDT hides the USB/I2C/SPI power manager from
# Windows 2022 _OSI, and gpio-keys reports Volume Down stuck; see
# install/hardware/microsoft/fix-surface-laptop-ultra-boot.sh.
KERNEL_CMDLINE[default]+=" acpi_osi=! modprobe.blacklist=gpio_keys"
KERNEL_CMDLINE[fallback]+=" acpi_osi=! modprobe.blacklist=gpio_keys"
CONF
fi
