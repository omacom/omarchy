echo "Remove the Validity post-suspend daemon restart that slowed wake"

sudo rm -f /usr/lib/systemd/system-sleep/python-validity-wakeup
sudo rm -f /usr/lib/systemd/system-sleep/fprint_wakeup

if systemctl list-unit-files --no-legend python3-validity-suspend-hotfix.service 2>/dev/null | grep -q '^python3-validity-suspend-hotfix.service'; then
  sudo systemctl disable --now python3-validity-suspend-hotfix.service
  sudo systemctl mask python3-validity-suspend-hotfix.service
fi
sudo systemctl daemon-reload
