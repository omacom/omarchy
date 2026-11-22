echo "Install Intel hardware video decoding on Alder Lake-P GPUs named only \"Integrated Graphics Controller\""

# Hardware setup missed these GPUs, so video was decoded on the CPU.
# See install/hardware/intel/video-acceleration.sh.
if lspci | grep -iE 'vga|3d|display' | grep -qi 'intel.*alder lake'; then
  omarchy-pkg-add intel-media-driver libvpl vpl-gpu-rt
fi
