echo "Shut the Windows VM down cleanly at the first reboot after this update"

# Docker pulls omarchy-windows-vm-shutdown.service in when it starts, so a
# Docker already running during the update hasn't, and the next reboot would
# still cut Windows off after Docker's 5 seconds. Start the helper now. Only
# machines with the VM installed and Docker running need it: an install keeps
# its compose in /var/lib/omarchy/windows, or in ~/.config/windows until its
# next launch moves it there.
[[ -f /var/lib/omarchy/windows/docker-compose.yml || -f $HOME/.config/windows/docker-compose.yml ]] || exit 0
systemctl is-active --quiet docker.service || exit 0
systemctl is-active --quiet omarchy-windows-vm-shutdown.service && exit 0

if [[ ! -f /etc/systemd/system/omarchy-windows-vm-shutdown.service ]]; then
  echo "Waiting for omarchy-settings to ship omarchy-windows-vm-shutdown.service"
  exit 75
fi

sudo systemctl start omarchy-windows-vm-shutdown.service
