echo "Socket-activate CUPS so cupsd starts on demand"

pending=/var/lib/omarchy/migrations/1795788620-cups-socket

if ! systemctl is-enabled --quiet cups.service 2>/dev/null && [[ ! -e $pending ]]; then
  exit 0
fi

# Record that the switch started before disabling cups.service (whose Also=
# also disables cups.socket and cups.path), so an interrupted run finishes
# enabling them on retry while deliberately disabled installs stay untouched.
sudo install -d -m 0755 /var/lib/omarchy/migrations
sudo touch "$pending"
sudo systemctl disable cups.service
sudo systemctl enable --now cups.socket cups.path
sudo rm -f "$pending"
