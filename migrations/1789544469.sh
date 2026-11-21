echo "Stop wifi answering ARP for the wired interface"

# Applies the shipped sysctl early; boot picks it up regardless. Loading our
# file rather than --system avoids a nonzero exit from any unrelated invalid
# key in another admin sysctl file. Takes effect immediately; a failed reload waits for the next boot.
if [[ $(sysctl -n net.ipv4.conf.all.arp_ignore) == "1" && $(sysctl -n net.ipv4.conf.all.arp_announce) == "2" ]]; then
  exit 0
fi

sudo sysctl -p /etc/sysctl.d/99-omarchy-sysctl.conf >/dev/null || omarchy-state set reboot-required
