echo "Stop suspending a docked laptop on external power when its display blinks"

# Reload rather than restart: restarting systemd-logind tears down the session.
sudo systemctl reload systemd-logind >/dev/null 2>&1 || true

# A reload that left the old lid handling in place only takes effect on reboot.
effective=$(busctl get-property org.freedesktop.login1 /org/freedesktop/login1 \
  org.freedesktop.login1.Manager HandleLidSwitchExternalPower 2>/dev/null || true)

if [[ $effective != 's "ignore"' ]]; then
  omarchy-state set reboot-required
fi
