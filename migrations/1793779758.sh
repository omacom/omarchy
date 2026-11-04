echo "Reload fingerprint resume configuration missed through a protected directory"

lock_pam="${OMARCHY_LOCK_FINGERPRINT_PAM:-/etc/pam.d/omarchy-lock-fingerprint}"
stop_timeout_dst="${OMARCHY_FPRINTD_STOP_TIMEOUT_DST:-/etc/systemd/system/fprintd.service.d/10-stop-timeout.conf}"

[[ -f $lock_pam ]] || exit 0

# The shipped installer could miss its reload after installing into a
# restricted directory. Inspect as root without replaying installation.
sudo bash -euo pipefail -c '
  [[ -f $1 ]] || exit 0
  reload_needed=$(systemctl show fprintd.service --property=NeedDaemonReload --value)
  if [[ $reload_needed == "yes" ]]; then
    systemctl daemon-reload
  fi
' bash "$stop_timeout_dst"
