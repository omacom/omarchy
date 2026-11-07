echo "Install the Broadcom Bluetooth firmware the BCM20702A1 controller needs"

# btusb asks for brcm/BCM20702A1-0a5c-216f.hcd and then for the controller-agnostic brcm/BCM-0a5c-216f.hcd, and
# the controller comes up with no adapter in BlueZ when neither is there. See
# install/hardware/fix-bcm20702a1-bluetooth.sh for the failure and for why linux-firmware has neither file.
#
# Nothing in linux-firmware and nothing in the base install provides it, so an existing install needs this the
# same way a new one does; the install-time leaf only reaches machines set up after it shipped.
usb_devices="${OMARCHY_BCM20702A1_USB_ROOT:-/sys/bus/usb/devices}"
firmware="${OMARCHY_BCM20702A1_FIRMWARE:-/usr/lib/firmware/brcm/BCM20702A1-0a5c-216f.hcd}"

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

[[ $bluetooth_device_present == true ]] || exit 0

# Only the installation needs the reboot. Every user after the first one on a machine that already has the package
# must not be told to reboot again for it.
if omarchy-pkg-missing broadcom-bt-firmware; then
  # Following the ArchWiki page for this laptop means a hand-extracted .hcd sitting at the path the package owns, and
  # pacman refuses to install over a file no package owns. Keep that file under the backup name Omarchy uses
  # elsewhere, and let the package take the path from here on; the firmware it installs is the same.
  #
  # Move it only once the package is actually missing. omarchy-migrate runs this with set -e and writes the marker
  # after it returns, so a failed install stays pending: putting the file back leaves Bluetooth working until the
  # next try, instead of the next boot finding neither the hand-extracted file nor the package.
  firmware_moved=false

  if [[ -f $firmware ]] && ! pacman -Qo "$firmware" >/dev/null 2>&1; then
    sudo mv -f "$firmware" "$firmware.omarchy-backup"
    firmware_moved=true
  fi

  if ! omarchy-pkg-add broadcom-bt-firmware; then
    if [[ $firmware_moved == true ]]; then
      sudo mv -f "$firmware.omarchy-backup" "$firmware"
    fi

    exit 1
  fi

  # btusb reads the firmware when it probes the controller, so it is not in use until the next boot.
  omarchy-state set reboot-required
fi
