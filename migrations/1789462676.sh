echo "Rescope LocalSend's firewall rule to private network ranges on existing installs"

if ! command -v ufw >/dev/null 2>&1; then
  exit 0
fi

# The old rule allowed 53317 from Anywhere, including IPv6, which is
# frequently globally routable without NAT. install/config/firewall.sh only
# runs at install and on major-version upgrades, so an existing install
# never picks up the new scoping on its own; remove the old rule here and
# add its replacement, matching install/config/firewall.sh.
sudo ufw delete allow 53317/tcp >/dev/null 2>&1 || true
sudo ufw delete allow 53317/udp >/dev/null 2>&1 || true

for net in 192.168.0.0/16 10.0.0.0/8 172.16.0.0/12; do
  sudo ufw allow from "$net" to any port 53317 proto tcp
  sudo ufw allow from "$net" to any port 53317 proto udp
done
