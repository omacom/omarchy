echo "Install Intel video acceleration on GPUs that report only Intel Graphics"

# Arrow Lake-U and other recent parts show up in lspci as plain "Intel Graphics",
# which install/hardware/intel/video-acceleration.sh did not recognize, so those
# installs decode video on the CPU. omarchy-pkg-add skips what is already there.
if lspci | grep -iE 'vga|3d|display' | grep -iq 'intel graphics'; then
  omarchy-pkg-add intel-media-driver libvpl vpl-gpu-rt
fi
