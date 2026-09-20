# Install MIPI camera support for Intel IPU6 hardware

if omarchy-hw-intel-ipu6; then
  # The ISYS driver only exposes raw Bayer capture queues, which nothing can
  # use as a webcam. libcamera composes them into one camera and its software
  # ISP debayers it; pipewire-libcamera is what puts that in front of apps.
  omarchy-pkg-add libcamera pipewire-libcamera gst-plugin-libcamera
fi
