echo "Keep the T2 internal keyboard in the linux-t2 initramfs"

# The later T2 drop-in restores loadable keyboard modules even when this
# installer filter was customized. Rebuild once for all users, and record
# completion only after the repair helper has checked every known T2 image.
filter="${OMARCHY_INITRAMFS_MODULES_CONF:-/etc/mkinitcpio.conf.d/zz-omarchy-kernel-modules.conf}"
marker="${OMARCHY_T2_KEYBOARD_INITRAMFS_MARKER:-/var/lib/omarchy/migrations/1794052135}"

[[ -e $filter || -L $filter ]] || exit 0
if [[ ! -f $filter || ! -r $filter ]]; then
  echo "Cannot read the installer module filter: $filter" >&2
  exit 1
fi
[[ ! -e $marker ]] || exit 0
if grep -Eq '(^|[[:space:](])t2bce_vhci([[:space:])]|$)' "$filter"; then
  :
else
  status=$?
  (( status == 1 )) && exit 0
  exit "$status"
fi

omarchy-repair-t2-initramfs
sudo install -Dm644 /dev/null "$marker"
