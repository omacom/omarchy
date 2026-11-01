# Boot keyboards that leave Fn-lock to Linux (ASUS laptops and keyboards, Apple
# and Apple-style keyboards such as the Lofree Flow84) with media keys on the
# top row; Fn gives F1-F12. Set up already, by Omarchy or an administrator, it
# stays as it is. Apple Silicon is left alone: the omarchy-mac package owns its
# keyboard mode. Setup's last step builds the boot image, so none is built here.
modprobe_dir="${OMARCHY_MODPROBE_DIR:-/etc/modprobe.d}"
if ! omarchy-hw-aarch64-apple && [[ ! -f $modprobe_dir/omarchy-fnkeys.conf && ! -f $modprobe_dir/hid_apple.conf && ! -f $modprobe_dir/hid_asus.conf ]]; then
  omarchy-keyboard-fnkeys off --no-rebuild
fi
