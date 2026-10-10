# Top row for the ASUS ProArt P14 H7407BA (NVIDIA N1x, 0B05:4B42 keyboard on
# i2c-hid).
#
# The keyboard leaves Fn-lock to the host, and hid-asus in linux-omarchy-n1x
# boots it with F1-F12 as function keys. Boot it with media keys instead, as
# the laptop ships; Fn+Esc still switches to F1-F12. hid-asus loads from the
# initramfs, so the option takes effect once the initramfs is rebuilt.

if omarchy-hw-match "H7407BA"; then
  conf=/etc/modprobe.d/hid_asus.conf

  if [[ ! -f $conf ]]; then
    mkdir -p /etc/modprobe.d
    cat >"$conf" <<'CONF'
# ASUS ProArt P14: the top row sends media keys by default; Fn+Esc switches to F1-F12.
options hid_asus fnlock_default=0
CONF
  fi
fi
