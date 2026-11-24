FIREWALL_RULES_VERSION="2"
FIREWALL_STAMP="${OMARCHY_FIREWALL_STAMP:-/var/lib/omarchy/firewall-rules-version}"

if [[ ! -f $FIREWALL_STAMP || $(<"$FIREWALL_STAMP") != "$FIREWALL_RULES_VERSION" ]]; then
  # Allow nothing in, everything out.
  ufw default deny incoming
  ufw default allow outgoing

  # Allow ports for LocalSend.
  ufw allow 53317/udp
  ufw allow 53317/tcp

  # Rootless containers use the user network stack. Rootful Podman bridges need
  # DNS to aardvark and outbound forwarding; unsolicited inbound stays denied.
  ufw allow in on podman+ to any port 53 proto udp comment omarchy-podman-dns
  ufw allow in on podman+ to any port 53 proto tcp comment omarchy-podman-dns
  ufw route allow in on podman+ comment omarchy-podman-egress

  mkdir -p "$(dirname "$FIREWALL_STAMP")"
  printf '%s\n' "$FIREWALL_RULES_VERSION" >"$FIREWALL_STAMP"
fi

# Image builds pre-bake the rules above with OMARCHY_FIREWALL_RULES_ONLY=1 while
# leaving ENABLED=no in ufw.conf, so any later chroot ufw call during install
# cannot reload the live ISO's kernel firewall.
if [[ ${OMARCHY_FIREWALL_RULES_ONLY:-0} != "1" ]]; then
  # Installs are followed by reboot, so configure UFW to start on the installed
  # system instead of mutating the live install session's firewall.
  sed -i 's/^ENABLED=.*/ENABLED=yes/' /etc/ufw/ufw.conf
  systemctl enable ufw
fi
