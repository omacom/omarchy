# Install MIPI camera support for Intel IPU6 hardware
#
# The kernel drives IPU6 on its own, but only as raw Bayer /dev/video* nodes
# that no browser or conferencing app can decode. libcamera's software ISP is
# what turns them into a usable picture, and pipewire-libcamera is what puts
# that in the PipeWire graph. Without both, an IPU6 laptop has no working
# camera no matter which node you pick.

if omarchy-hw-intel-ipu6; then
  omarchy-pkg-add libcamera pipewire-libcamera
fi
