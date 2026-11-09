echo "Let the AMD Strix Halo GPU borrow all but 8 GiB of RAM instead of half"

# See omarchy-apply-strix-halo-gpu-memory. It takes effect at the next boot.
omarchy-hw-amd-strix-halo || exit 0

sudo omarchy-apply-strix-halo-gpu-memory --rebuild
