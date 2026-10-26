# NVIDIA N1x: the firmware reserves 62.5 GiB as the GPU's Windows memory. Have
# it reserve 4 GiB from the next boot on; see omarchy-apply-n1x-gpu-memory.

omarchy-hw-aarch64-n1x || return 0

omarchy-apply-n1x-gpu-memory
