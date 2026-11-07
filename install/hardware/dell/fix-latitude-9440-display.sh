# Display fix for Dell Latitude 9440 2-in-1 (Raptor Lake-P / Iris Xe, AU Optronics eDP panel).
#
# PSR2 leaves this panel with severe system-wide screen and input lag: the
# pointer and keystrokes land late while every CPU, GPU, and memory stat reads
# idle, so it looks like a machine that cannot keep up rather than a display
# problem. i915 also reports, once per boot:
#   i915 0000:00:02.0: [drm] Selective fetch area calculation failed in pipe A
# That line is the driver falling back to full-frame updates, which is a sign
# selective fetch is unhappy on this panel rather than the stall itself; the
# mechanism behind the lag is not established.
#
# i915.enable_psr2_sel_fetch=0 drops the panel to PSR1, which keeps self-refresh
# and its power saving and gives up only PSR2's partial-frame updates.

if omarchy-hw-dell-latitude-9440; then
  mkdir -p /etc/limine-entry-tool.d
  cat > /etc/limine-entry-tool.d/dell-latitude-9440-display.conf <<'EOF'
# Dell Latitude 9440 2-in-1 (Raptor Lake-P / Iris Xe) display workaround
KERNEL_CMDLINE[default]+=" i915.enable_psr2_sel_fetch=0"
EOF
fi
