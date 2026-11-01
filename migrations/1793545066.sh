echo "Make the ASUS Zenbook A16 keyboard's top row send media keys by default"

# hid-asus set the A16 back to F1-F12 at every boot, whatever Fn+Esc was last
# set to. New installs default every such keyboard to media keys; see
# install/hardware/fix-fkeys.sh. A choice already made stays.
if ! omarchy-hw-aarch64-qualcomm || ! omarchy-hw-match "UX3607OA"; then
  exit 0
fi

if [[ -f /etc/modprobe.d/omarchy-toprow.conf || -f /etc/modprobe.d/hid_asus.conf ]] && [[ ! -e /var/lib/omarchy/toprow-rebuild-pending ]]; then
  exit 0
fi

# Rebuilds the boot image, where hid-asus loads; a failed rebuild exits non-zero
# and keeps this migration pending.
omarchy-keyboard-toprow media
