# AMD Strix Halo: the kernel lets the GPU borrow only half of RAM. Raise that
# to all but 8 GiB from the next boot on; see omarchy-apply-strix-halo-gpu-memory.

omarchy-hw-amd-strix-halo || return 0

omarchy-apply-strix-halo-gpu-memory
