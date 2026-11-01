echo "Make the ASUS Zenbook A16 keyboard's top row send media keys by default"

# hid-asus set the A16 back to F1-F12 at every boot, whatever Fn+Esc was last
# set to. New installs start every such keyboard on the media keys; see
# install/hardware/fix-fkeys.sh. hid-asus loads from the A16's initramfs, so the
# option needs a rebuild to reach it.
conf=/etc/modprobe.d/omarchy-toprow.conf
rebuild_marker=/var/lib/omarchy/migrations/1793545066

if ! omarchy-hw-aarch64-qualcomm || ! omarchy-hw-match "UX3607OA"; then
  exit 0
fi

# An Fn-lock option already set is the administrator's choice; leave it.
if [[ ! -f $conf ]] && ! grep -qsE '^[[:space:]]*options[[:space:]]+hid_asus[[:space:]].*fnlock_default=' /etc/modprobe.d/*.conf; then
  sudo install -Dm644 /dev/stdin "$conf" <<'CONF'
# Written by Omarchy: the top row sends the media keys by default, and Fn
# (Fn+Esc to lock it) gives F1-F12.
options hid_apple fnmode=1
options hid_asus fnlock_default=0
options asus_wmi fnlock_default=0
CONF
elif [[ ! -e $rebuild_marker ]] && ! grep -qx 'options hid_asus fnlock_default=0' "$conf" 2>/dev/null; then
  exit 0
fi

# A marker records the machine-wide rebuild: another user's run must not repeat
# it, while a missing marker still retries an interrupted rebuild.
[[ ! -e $rebuild_marker ]] || exit 0

sudo limine-mkinitcpio
sudo install -Dm644 /dev/null "$rebuild_marker"
