# Install Wi-Fi drivers for Broadcom chips found in some MacBooks, as well as other systems:
# - BCM4360 (14e4:43a0, 2013–2015 MacBooks) has no in-kernel driver. broadcom-wl is the only option.
# - BCM4331 (14e4:4331, 2011–early 2013 MacBooks) normally uses broadcom-wl.
#   On MacBookAir4,1 it has been reported to freeze the machine (#7593).
#   Skip wl only on that model: it would also blacklist the alternative b43
#   driver. b43 needs separately supplied firmware; linux-firmware-broadcom
#   does not contain it, so this exception does not provision working Wi-Fi.

pci_info=$(lspci -nn)
product_name=$(cat /sys/class/dmi/id/product_name 2>/dev/null || true)

if [[ $product_name == "MacBookAir4,1" ]] && echo "$pci_info" | grep -q "14e4:4331"; then
  echo "MacBookAir4,1 with BCM4331 detected; skipping broadcom-wl due to reported freezes"
  echo "Wi-Fi requires separately supplied b43 firmware; see the Mac support manual"
elif echo "$pci_info" | grep -qE "14e4:(43a0|4331)"; then
  echo "BCM4360 / BCM4331 detected"
  omarchy-pkg-add broadcom-wl-dkms
fi
