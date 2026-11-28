echo "Disable NMI watchdog to save power"

watchdog=/proc/sys/kernel/nmi_watchdog
dropin=/etc/sysctl.d/99-omarchy-nmi-watchdog.conf

[[ -r $watchdog ]] || exit 0

# A dev checkout can run ahead of omarchy-settings: stay pending until the
# drop-in lands so the setting persists across reboots too.
if [[ ! -r $dropin ]]; then
  echo "Waiting for omarchy-settings to ship $dropin"
  exit 75
fi

[[ $(<"$watchdog") == "0" ]] || sudo /usr/lib/systemd/systemd-sysctl "$dropin"
