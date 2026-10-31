# Install firmware for Broadcom Bluetooth controllers whose HCD file linux-firmware does not carry:
# - BCM20702A1 (0a5c:216f), the Bluetooth half of the DW1560 combo card in the Dell XPS 13 9343 and other laptops.
#
# btusb asks for brcm/<controller>-<vid>-<pid>.hcd, named after the ROM revision the controller reports, and then
# falls back to the controller-agnostic brcm/BCM-<vid>-<pid>.hcd (btbcm_initialize in drivers/bluetooth/btbcm.c).
# Neither file is in linux-firmware: Broadcom only ever shipped this firmware inside its Windows driver, which is
# what the broadcom-bt-firmware package repackages. Without it the controller still enumerates and takes its USB
# address, but its patchram never uploads, so BlueZ reports no adapter at all instead of one that fails to pair.
#
# The package is in the ISO cache, so an offline installation ships the firmware too.

usb_devices=/sys/bus/usb/devices

bluetooth_device_present=false

for id_vendor in "$usb_devices"/*/idVendor; do
  [[ -f $id_vendor ]] || continue

  id_product="${id_vendor%idVendor}idProduct"
  [[ -f $id_product ]] || continue

  read -r vendor <"$id_vendor"
  read -r product <"$id_product"

  if [[ $vendor == "0a5c" && $product == "216f" ]]; then
    bluetooth_device_present=true
    break
  fi
done

if [[ $bluetooth_device_present == true ]]; then
  echo "BCM20702A1 Bluetooth controller detected"
  omarchy-pkg-add broadcom-bt-firmware
fi
