# NVIDIA N1x: the firmware reserves a Windows-sized GPU carve-out (62.5 GiB on
# the XPS 16, 32 GiB on the Lenovo Pro 9). Have it reserve 4 GiB from the next
# boot on; see omarchy-apply-n1x-gpu-memory.

omarchy-hw-aarch64-n1x || return 0

omarchy-apply-n1x-gpu-memory
