echo "Offer media keys on the top row of a connected Lofree keyboard"

# Omarchy's setup used to start Apple-style keyboards such as the Lofree Flow84
# on F1-F12. New installs start them on the media keys; see
# install/hardware/fix-fkeys.sh. Only Lofree owners are asked, with the keyboard
# connected, and only while the file is still the one Omarchy wrote.
conf=/etc/modprobe.d/hid_apple.conf
rebuild_pending=/var/lib/omarchy/hid-apple-rebuild-pending

if [[ -f $conf && $(<"$conf") == "options hid_apple fnmode=2" ]] &&
  [[ -d /sys/module/hid_apple ]] && grep -qi '^N: Name=.*lofree' /proc/bus/input/devices; then
  if ! gum confirm "Make your Lofree keyboard's top row send media keys by default? Fn gives F1-F12."; then
    exit 0
  fi

  # The option also lives in the boot image. Record the rebuild before changing
  # anything, so an interrupted run still owes it.
  sudo install -Dm644 /dev/null "$rebuild_pending"
  echo "options hid_apple fnmode=1" | sudo tee "$conf" >/dev/null
  echo 1 | sudo tee /sys/module/hid_apple/parameters/fnmode >/dev/null
fi

[[ -e $rebuild_pending ]] || exit 0

log=$(mktemp)
trap 'rm -f "$log"' EXIT
sudo limine-mkinitcpio 2>&1 | tee "$log"

# limine-mkinitcpio reports a kernel it could not rebuild and still exits 0.
if grep -q 'mkinitcpio failed for kernel' "$log"; then
  echo "Could not rebuild the boot image; this migration stays pending." >&2
  exit 1
fi
sudo rm -f "$rebuild_pending"
