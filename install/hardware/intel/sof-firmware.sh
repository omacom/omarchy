# Install Sound Open Firmware for Intel audio DSPs. The sof-audio-pci-intel-*
# driver family requires this firmware; without it PipeWire exposes only a
# Dummy Output sink.

if omarchy-hw-intel-sof; then
  OMARCHY_PKG_DEFER=1 omarchy-pkg-add sof-firmware
fi
