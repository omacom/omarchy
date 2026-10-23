# The IdeaPad Slim 3 15AMN8 (Lenovo 82XQ) only offers s2idle, and its Micron
# NVMe firmware rejects all I/O with Access Denied/DNR on resume, taking the
# root filesystem read-only mid-session. The kernel already works around the
# platform's suspend bug ("Using s2idle quirk to avoid IdeaPad Slim 3 15AMN8
# platform firmware bug") but the drive still dies, so suspend can never
# succeed on this model.
#
# Ignore suspend-key presses on this model to avoid the NVMe failure from
# #12887. Locking on lid close remains the fallback: the session locks and the
# panel powers down while keeping the machine alive.

dmi="${OMARCHY_DMI_PATH:-/sys/class/dmi/id}"

conf_dir="${OMARCHY_LOGIND_CONF_DIR:-/etc/systemd/logind.conf.d}"

if [[ -r $dmi/sys_vendor && -r $dmi/product_name ]] &&
  [[ $(<"$dmi/sys_vendor") == "LENOVO" && $(<"$dmi/product_name") == "82XQ" ]]; then
  install -d -m 0755 "$conf_dir"
  cat >"$conf_dir/50-ideapad-suspend.conf" <<'EOF'
# On this model, ignore suspend-key presses to avoid the NVMe failure from
# #12887. Lid close still locks the session and powers down the panel.
[Login]
HandleLidSwitch=lock
HandleSuspendKey=ignore
HandleSuspendKeyLongPress=ignore
EOF
fi
