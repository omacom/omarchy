# Top row for the ASUS Zenbook A16 UX3607OA (Snapdragon X2 Elite, 0B05:4B42
# keyboard on i2c-hid).
#
# The keyboard leaves Fn-lock to the host, and hid-asus boots it with F1-F12
# as function keys whatever Fn+Esc was last set to. Boot it with media keys
# instead, as the laptop ships; Fn+Esc still switches to F1-F12. hid-asus loads
# from the initramfs, so the option takes effect once the initramfs is rebuilt.
# A hid_asus.conf already there is the administrator's choice; leave it.

modprobe_dir=${OMARCHY_ZENBOOK_A16_MODPROBE_DIR:-/etc/modprobe.d}

if omarchy-hw-aarch64-qualcomm && omarchy-hw-match "UX3607OA" && [[ ! -f $modprobe_dir/hid_asus.conf ]]; then
  mkdir -p "$modprobe_dir"
  cat >"$modprobe_dir/hid_asus.conf" <<'CONF'
# ASUS Zenbook A16: the top row sends media keys by default; Fn+Esc switches to F1-F12.
options hid_asus fnlock_default=0
CONF
fi
