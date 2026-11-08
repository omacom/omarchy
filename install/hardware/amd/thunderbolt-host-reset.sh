# Keep the firmware's USB4 link to a display on AMD machines.
#
# The thunderbolt driver resets the USB4 host router when it loads, tearing
# down the link the firmware brought a display up on. The display then
# negotiates again, and which mode it lands in varies from boot to boot: an
# Apple Pro Display XDR came back either as one 6K output or as two tiles that
# showed a black LUKS prompt and a phantom monitor in Hyprland. Skipping the
# reset keeps the firmware's link, so the display is lit and stays one output.
# The option only exists for the software connection manager AMD's USB4
# routers use, and does nothing on a machine without one.

if omarchy-hw-amd; then
  mkdir -p /etc/limine-entry-tool.d
  cat >/etc/limine-entry-tool.d/amd-thunderbolt.conf <<'EOF'
# AMD: keep the firmware's USB4 display link at boot
KERNEL_CMDLINE[default]+=" thunderbolt.host_reset=0"
EOF
fi
