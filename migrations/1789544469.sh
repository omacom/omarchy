echo "Stop wifi answering ARP for the wired interface"

# Applies the shipped sysctl early; boot picks it up regardless. Loading our
# file rather than --system avoids a nonzero exit from any unrelated invalid
# key in another admin sysctl file. Takes effect immediately, so no reboot.
sudo sysctl -p /etc/sysctl.d/99-omarchy-sysctl.conf >/dev/null || true
