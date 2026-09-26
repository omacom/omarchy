echo "Disable broken eDP Panel Replay on Dell XPS Panther Lake systems"

DROP_IN="/etc/limine-entry-tool.d/dell-xps-ptl-panel-replay.conf"

# New installs get this from install/hardware/intel/fix-dell-xps-ptl-panel-replay.sh.
# Systems that predate that hook live with the Panel Replay interrupt storm
# (~6000 xe IRQs/s, GT pinned awake, roughly half the battery life they should
# get), so retrofit the drop-in here. Second and later users no-op on the file
# check.
if omarchy-hw-match "XPS" && omarchy-hw-intel-ptl; then
  if [[ ! -f $DROP_IN ]]; then
    sudo mkdir -p /etc/limine-entry-tool.d
    cat <<'EOF' | sudo tee "$DROP_IN" >/dev/null
# Dell XPS Panther Lake eDP Panel Replay workaround
KERNEL_CMDLINE[default]+=" xe.enable_panel_replay=0"
EOF
    sudo limine-update
  fi
fi
