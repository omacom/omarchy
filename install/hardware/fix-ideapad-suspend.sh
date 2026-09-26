# The IdeaPad Slim 3 15AMN8 (Lenovo 82XQ) only offers s2idle, and its Micron
# NVMe firmware rejects all I/O with Access Denied/DNR on resume, taking the
# root filesystem read-only mid-session. The kernel already works around the
# platform's suspend bug ("Using s2idle quirk to avoid IdeaPad Slim 3 15AMN8
# platform firmware bug") but the drive still dies, so suspend can never
# succeed on this model.
#
# Locking on lid close is the strictly better fallback: the session locks and
# the panel powers down -- what a user expects from closing a laptop -- while
# keeping the machine alive instead of inviting a read-only root.

dmi="${OMARCHY_DMI_PATH:-/sys/class/dmi/id}"

conf_dir="${OMARCHY_LOGIND_CONF_DIR:-/etc/systemd/logind.conf.d}"

if [[ -r $dmi/sys_vendor && -r $dmi/product_name ]] &&
  [[ $(<"$dmi/sys_vendor") == "LENOVO" && $(<"$dmi/product_name") == "82XQ" ]]; then
  install -d -m 0755 "$conf_dir"
  cat >"$conf_dir/50-ideapad-suspend.conf" <<'EOF'
# The Micron NVMe in this model rejects all I/O after s2idle resume, so
# suspend can never complete. Lock instead of suspending: the session locks
# and the panel powers down, and the filesystem stays alive.
[Login]
HandleLidSwitch=lock
HandleSuspendKey=lock
HandleSuspendKeyLongPress=lock
EOF
fi
