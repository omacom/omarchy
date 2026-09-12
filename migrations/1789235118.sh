echo "Enable Google BBR TCP congestion control and Fair Queueing"

sudo modprobe tcp_bbr 2>/dev/null || true
sudo sysctl -p /etc/sysctl.d/99-omarchy-sysctl.conf >/dev/null || true
