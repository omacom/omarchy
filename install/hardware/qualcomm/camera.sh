# Snapdragon cameras run through libcamera, which apps reach through
# PipeWire's libcamera backend.

if omarchy-hw-aarch64-qualcomm; then
  omarchy-pkg-add pipewire-libcamera
fi
