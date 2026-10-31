echo "Install Intel video acceleration on GPUs that report only Intel Graphics"

# Arrow Lake-U and other recent parts show up in lspci as plain "Intel Graphics",
# which install/hardware/intel/video-acceleration.sh did not recognize, so those
# installs decode video on the CPU. omarchy-pkg-add skips what is already there.
# Capture first: grep -q stops reading early, which can SIGPIPE the upstream
# grep and fail the pipeline under pipefail.
gpus=$(lspci | grep -iE 'vga|3d|display' || true)
if grep -qi 'intel graphics' <<<"$gpus"; then
  omarchy-pkg-add intel-media-driver libvpl vpl-gpu-rt
fi
