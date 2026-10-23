# Display/power fix for Dell XPS Panther Lake (XPS 14, PTL-H).
#
# Panel Replay is Xe3-new, default-on in the xe driver, and negotiates
# selective-update + early transport + DSC on this eDP panel but never
# completes a cycle: the sink reports a Link CRC error, and every frame
# update costs ~50 GPU interrupts (~6000/s at 120Hz), pinning the GT at
# its 900MHz policy floor and blocking package C-states. Idle draw sits
# near 13W instead of ~7.5W, roughly halving battery life. Classic PSR2
# works fine once Panel Replay is off, so only that gets disabled —
# unlike the Wildcat Lake XPS 13, which also needs xe.enable_psr=0.

if omarchy-hw-match "XPS" && omarchy-hw-intel-ptl; then
  mkdir -p /etc/limine-entry-tool.d
  cat > /etc/limine-entry-tool.d/dell-xps-ptl-panel-replay.conf <<'EOF'
# Dell XPS Panther Lake eDP Panel Replay workaround
KERNEL_CMDLINE[default]+=" xe.enable_panel_replay=0"
EOF
fi
