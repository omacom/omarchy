echo "Install the fingerprint resume hook on existing fingerprint setups"

# Existing enrolled machines never rerun setup. Install only missing files
# so administrator changes survive an upgrade.

# Resolve shipped inputs beside the migration itself. Migration environments
# are caller state and must not choose privileged sources or destinations.
migration_path=$(/usr/bin/readlink -e -- "${BASH_SOURCE[0]}") || {
  echo "Could not resolve the fingerprint recovery migration." >&2
  exit 1
}
source_root=${migration_path%/migrations/*}
if [[ $source_root == "$migration_path" ]]; then
  echo "Could not resolve the Omarchy source root." >&2
  exit 1
fi

hook_src="$source_root/default/systemd/system-sleep/fprintd-resume"
hook_dst=/usr/lib/systemd/system-sleep/fprintd-resume
stop_timeout_src="$source_root/default/systemd/system/fprintd.service.d/10-stop-timeout.conf"
stop_timeout_dst=/etc/systemd/system/fprintd.service.d/10-stop-timeout.conf
lock_pam=/etc/pam.d/omarchy-lock-fingerprint

[[ -f $lock_pam ]] || exit 0

if [[ -f $hook_src && ! -e $hook_dst ]]; then
  echo "Installing the fprintd resume hook"
  sudo install -Dm755 "$hook_src" "$hook_dst"
fi

if [[ -f $stop_timeout_src && ! -e $stop_timeout_dst ]]; then
  sudo install -Dm644 "$stop_timeout_src" "$stop_timeout_dst"
fi

if [[ -f $stop_timeout_dst ]]; then
  reload_needed=$(systemctl show fprintd.service --property=NeedDaemonReload --value)
  if [[ $reload_needed == "yes" ]]; then
    sudo systemctl daemon-reload
  fi
fi
