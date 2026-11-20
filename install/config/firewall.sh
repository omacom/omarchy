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

# Installs are followed by reboot, so configure UFW to start on the installed
# system instead of mutating the live install session's firewall.
sed -i 's/^ENABLED=.*/ENABLED=yes/' /etc/ufw/ufw.conf
systemctl enable ufw
