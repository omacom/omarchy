# Stop lid-open from soft-blocking Wi-Fi on the HP Victus 16-s1xxx.
#
# Its firmware injects scancode 0xd7 on the internal keyboard every time the lid
# opens. systemd's generic HP keymap in 60-keyboard.hwdb maps 0xd7 to KEY_WLAN,
# and the kernel's rfkill-input handler turns that keypress into a Wi-Fi soft
# block, so the machine drops off the network until Wi-Fi is turned back on.
#
# pacman's hwdb hook compiles only /usr/lib/udev/hwdb.bin, but udev reads
# /etc/udev/hwdb.bin first wherever systemd-hwdb-update.service has written one.

if omarchy-hw-match "Victus by HP Gaming Laptop 16-s1"; then
  sudo install -Dm644 "$OMARCHY_PATH/default/udev/hp-victus-lid-wlan.hwdb" /etc/udev/hwdb.d/61-omarchy-hp-victus-lid-wlan.hwdb
  sudo systemd-hwdb --usr update

  if [[ -e /etc/udev/hwdb.bin ]]; then
    sudo systemd-hwdb update
  fi
fi
