echo "Lock instead of suspending on the IdeaPad Slim 3 15AMN8"

# On the Lenovo 82XQ the Micron NVMe rejects all I/O after s2idle resume and
# the root filesystem goes read-only mid-session, so suspend can never
# succeed on this model. The logind drop-in the installer now writes was
# missing on existing installs; write it and reload logind.

dmi="${OMARCHY_DMI_PATH:-/sys/class/dmi/id}"
conf_dir="${OMARCHY_LOGIND_CONF_DIR:-/etc/systemd/logind.conf.d}"
dropin="$conf_dir/50-ideapad-suspend.conf"

[[ -r $dmi/sys_vendor && -r $dmi/product_name ]] || exit 0
[[ $(<"$dmi/sys_vendor") == "LENOVO" && $(<"$dmi/product_name") == "82XQ" ]] || exit 0
[[ -f $dropin ]] && exit 0

sudo install -d -m 0755 "$conf_dir" || exit 0
sudo tee "$dropin" >/dev/null <<'CONF'
# The Micron NVMe in this model rejects all I/O after s2idle resume, so
# suspend can never complete. Lock instead of suspending: the session locks
# and the panel powers down, and the filesystem stays alive.
[Login]
HandleLidSwitch=lock
HandleSuspendKey=lock
HandleSuspendKeyLongPress=lock
CONF

# Reload rather than restart: restarting systemd-logind tears down the session.
sudo systemctl reload systemd-logind >/dev/null 2>&1 || true
