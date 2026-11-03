echo "Make the ASUS ProArt P14 keyboard's top row send media keys by default"

# See install/hardware/asus/fix-asus-proart-p14-fkeys.sh. hid-asus loads from
# the initramfs, so the option needs a rebuild to reach it.
conf="${OMARCHY_HID_ASUS_CONF:-/etc/modprobe.d/hid_asus.conf}"
rebuild_marker="${OMARCHY_LIMINE_REBUILD_MARKER:-/var/lib/omarchy/migrations/1791408113}"

if ! omarchy-hw-match "H7407BA"; then
  exit 0
fi

# A hid_asus.conf already there is the administrator's choice; leave it.
if [[ ! -f $conf ]]; then
  sudo install -Dm644 /dev/stdin "$conf" <<'CONF'
# ASUS ProArt P14: the top row sends media keys by default; Fn+Esc switches to F1-F12.
options hid_asus fnlock_default=0
CONF
elif [[ ! -e $rebuild_marker ]] && ! grep -qx 'options hid_asus fnlock_default=0' "$conf"; then
  exit 0
fi

# A marker records the machine-wide rebuild: another user's run must not repeat
# it, while a missing marker still retries an interrupted rebuild.
[[ ! -e $rebuild_marker ]] || exit 0

sudo limine-mkinitcpio
sudo install -Dm644 /dev/null "$rebuild_marker"
