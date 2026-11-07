echo "Start NordVPN once NetworkManager has brought up the network at boot"

# Install only a missing drop-in, so administrator changes survive and the
# run for a second user on the machine is a no-op.
drop_in_src="$OMARCHY_PATH/default/systemd/system/nordvpnd.service.d/10-omarchy.conf"
drop_in_dst="${OMARCHY_NORDVPN_DROP_IN_DST:-/etc/systemd/system/nordvpnd.service.d/10-omarchy.conf}"

if omarchy-pkg-present nordvpn-bin && [[ ! -e $drop_in_dst ]]; then
  sudo install -Dm644 "$drop_in_src" "$drop_in_dst"
  sudo systemctl daemon-reload
fi
