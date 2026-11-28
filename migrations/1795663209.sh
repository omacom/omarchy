echo "Shut the Windows VM down cleanly at the first reboot after this update"

# Docker won't pull the helper into a service that is already running.
# Start it now so the first reboot is protected if Windows is installed later.
systemctl is-active --quiet docker.service || exit 0
systemctl is-active --quiet omarchy-windows-vm-shutdown.service && exit 0

if [[ ! -f /etc/systemd/system/omarchy-windows-vm-shutdown.service ]]; then
  echo "Waiting for omarchy-settings to ship omarchy-windows-vm-shutdown.service"
  exit 75
fi

sudo systemctl start omarchy-windows-vm-shutdown.service
