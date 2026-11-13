# Board data for a Qualcomm Wi-Fi card that linux-firmware does not list yet,
# in Snapdragon and x86 laptops alike. ath12k, or ath11k for the WCN6855,
# finds no board data for such a card, so it has no Wi-Fi.
# ath12k-board-fallback copies the record linux-firmware ships for the card's
# module family, the one Qualcomm's Windows driver also uses for it, and
# removes the copy once linux-firmware lists the card. The upstream fix is an
# entry for each card in linux-firmware's board-2.bin.

if lspci -nn | grep -qE '\[17cb:(1103|1107|1112)\]'; then
  omarchy-pkg-add ath12k-board-fallback

  # On an image's first boot (omarchy-provision-hardware sets the marker) the
  # driver probed the card before the package gave it board data, and nothing
  # reboots before the desktop, so rebind the card to load it now. An install leaves
  # that to the first boot. A failed rebind is fixed by the next boot.
  pci_devices=${OMARCHY_PCI_DEVICES:-/sys/bus/pci/devices}
  board_state=${OMARCHY_ATH12K_BOARD_STATE:-/var/lib/ath12k-board-fallback/installed}
  if [[ ${OMARCHY_IMAGE_DEFERRED_HARDWARE:-} == "1" && -s $board_state ]]; then
    for device in "$pci_devices"/*; do
      if [[ $(<"$device/vendor") == "0x17cb" && $(<"$device/device") =~ ^0x(1103|1107|1112)$ && -e $device/driver ]]; then
        driver=$(readlink -f "$device/driver")
        { echo "${device##*/}" >"$driver/unbind" && echo "${device##*/}" >"$driver/bind"; } || true
      fi
    done
  fi
fi
