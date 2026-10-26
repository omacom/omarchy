echo "Make the ASUS ProArt P16 keyboard's top row send media keys by default"

# See install/hardware/asus/fix-asus-proart-p16-fkeys.sh. hid-asus loads from
# the initramfs, so the option needs a rebuild to reach it.
conf=/etc/modprobe.d/hid_asus.conf
rebuild_marker=/var/lib/omarchy/migrations/1792977220

if ! omarchy-hw-match "H7607BA"; then
  exit 0
fi

# A hid_asus.conf already there is the administrator's choice; leave it.
if [[ ! -f $conf ]]; then
  sudo install -Dm644 /dev/stdin "$conf" <<'CONF'
# ASUS ProArt P16: the top row sends media keys by default; Fn+Esc switches to F1-F12.
options hid_asus fnlock_default=0
CONF
elif [[ ! -e $rebuild_marker ]] && ! grep -qx 'options hid_asus fnlock_default=0' "$conf"; then
  exit 0
fi

# A marker records the machine-wide rebuild: another user's run must not repeat
# it, while a missing marker still retries an interrupted rebuild.
[[ ! -e $rebuild_marker ]] || exit 0

rebuild_log=$(mktemp)
trap 'rm -f "$rebuild_log"' EXIT
sudo limine-mkinitcpio 2>&1 | tee "$rebuild_log"

# limine-mkinitcpio reports a kernel it could not rebuild and still exits 0.
# That kernel's initramfs lacks the option, so the migration stays pending.
if grep -q 'mkinitcpio failed for kernel' "$rebuild_log"; then
  echo "A boot image was not rebuilt. Fix the error above, then run omarchy-migrate again before rebooting." >&2
  exit 1
fi

sudo install -Dm644 /dev/null "$rebuild_marker"
