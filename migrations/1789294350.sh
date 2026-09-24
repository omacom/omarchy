echo "Switch TCP congestion control to BBR with fq pacing"

# Boot applies the shipped file regardless; this only makes new connections
# use BBR now. Setting the sysctls autoloads tcp_bbr and sch_fq. Qdiscs
# already attached to interfaces stay until they are recreated, normally at
# reboot.
if [[ $(sysctl -n net.ipv4.tcp_congestion_control) == "bbr" && $(sysctl -n net.core.default_qdisc) == "fq" ]]; then
  exit 0
fi

sudo sysctl -p /etc/sysctl.d/99-omarchy-sysctl.conf >/dev/null || omarchy-state set reboot-required
