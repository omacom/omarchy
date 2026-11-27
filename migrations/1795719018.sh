echo "Stop suspending a docked laptop on external power when its display blinks"

dropin=/etc/systemd/logind.conf.d/30-lid-external-power.conf

# A dev checkout can run ahead of omarchy-settings: reloading or rebooting
# before the drop-in lands changes nothing, so stay pending until it does.
if [[ ! -r $dropin ]]; then
  echo "Waiting for omarchy-settings to ship $dropin"
  exit 75
fi

# Reload rather than restart: restarting systemd-logind tears down the session.
sudo systemctl reload systemd-logind >/dev/null 2>&1 || true

# A reload that left the old lid handling in place only takes effect on reboot.
effective=$(busctl get-property org.freedesktop.login1 /org/freedesktop/login1 \
  org.freedesktop.login1.Manager HandleLidSwitchExternalPower 2>/dev/null || true)

if [[ $effective != 's "ignore"' ]]; then
  omarchy-state set reboot-required
fi
