echo "Ignore the suspend key on the IdeaPad Slim 3 15AMN8"

# On the Lenovo 82XQ the Micron NVMe rejects all I/O after s2idle resume and
# the root filesystem goes read-only mid-session, so suspend can never
# succeed on this model. Ignore suspend-key presses to avoid the NVMe failure
# from #12887. The installer logind drop-in was missing on existing installs;
# write it and reload logind.

dmi="${OMARCHY_DMI_PATH:-/sys/class/dmi/id}"
conf_dir="${OMARCHY_LOGIND_CONF_DIR:-/etc/systemd/logind.conf.d}"
dropin="$conf_dir/50-ideapad-suspend.conf"

[[ -r $dmi/sys_vendor && -r $dmi/product_name ]] || exit 0
[[ $(<"$dmi/sys_vendor") == "LENOVO" && $(<"$dmi/product_name") == "82XQ" ]] || exit 0
[[ -f $dropin ]] && exit 0

sudo install -d -m 0755 "$conf_dir"
sudo tee "$dropin" >/dev/null <<'CONF'
# On this model, ignore suspend-key presses to avoid the NVMe failure from
# #12887. Lid close still locks the session and powers down the panel.
[Login]
HandleLidSwitch=lock
HandleSuspendKey=ignore
HandleSuspendKeyLongPress=ignore
CONF

# Reload rather than restart: restarting systemd-logind tears down the session.
# If the reload fails, the drop-in only takes effect after a reboot.
sudo systemctl reload systemd-logind >/dev/null 2>&1 || omarchy-state set reboot-required
