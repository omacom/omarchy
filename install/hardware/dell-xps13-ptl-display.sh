# Display fix for the Dell XPS 13 DX13260 (Panther Lake / Xe3 iGPU, Sharp
# SHP5597 2560x1600@120 eDP).
#
# The panel advertises Panel Replay with selective update and PSR2 with early
# transport, and the xe driver enables Panel Replay selective update by default.
# The panel then reports RFB storage errors (DPCD PANEL_REPLAY_ERROR_STATUS /
# PSR_ERROR_STATUS bit 1) in both selective-update modes: a bright line down
# the right edge, horizontal white flashes during content updates, and a laggy
# hardware cursor. Only PSR1 is clean, so force it. Both parameters are needed:
# with Panel Replay alone disabled the driver falls back to PSR2 selective
# update, which fails the same way.
#
# Respect an existing manual PSR choice rather than stacking flags on it. The
# ISO pins the command line in /etc/default/limine, so look there as well.

DROP_IN_DIR="${OMARCHY_LIMINE_DROP_IN_DIR:-/etc/limine-entry-tool.d}"
DROP_IN="$DROP_IN_DIR/dell-xps13-dx13260-display.conf"
LIMINE_CONF="${OMARCHY_LIMINE_CONF:-/etc/default/limine}"

if omarchy-hw-dell-xps13-dx13260-ptl; then
  if [[ ! -f $DROP_IN ]] &&
    grep -qs '^[^#]*xe\.enable_psr' "$LIMINE_CONF" "$DROP_IN_DIR"/*.conf; then
    : # a manual PSR setting is already in place; leave it alone
  elif ! grep -qs '^KERNEL_CMDLINE.*xe\.enable_psr2_sel_fetch=0 xe\.enable_panel_replay=0' "$DROP_IN"; then
    sudo mkdir -p "$DROP_IN_DIR"
    cat <<'EOF2' | sudo tee "$DROP_IN" >/dev/null
# Dell XPS 13 DX13260 (Panther Lake / Xe3) display workaround: force PSR1.
# Panel Replay and PSR2 selective update both raise RFB storage errors on the
# Sharp SHP5597 panel (right-edge line, horizontal flashes, cursor lag).
KERNEL_CMDLINE[default]+=" xe.enable_psr2_sel_fetch=0 xe.enable_panel_replay=0"
EOF2
  fi
fi
