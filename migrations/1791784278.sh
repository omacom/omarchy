echo "Have the N1x firmware reserve 4 GiB for the GPU instead of reclaiming its 62.5 GiB in the kernel"

# See omarchy-apply-n1x-gpu-memory. The firmware's own setting replaces the
# efi_reclaim_reserved= kernel option the earlier migrations added, which
# linux-omarchy-n1x is dropping.
dropin="${OMARCHY_N1X_GPU_MEMORY_CONF:-/etc/limine-entry-tool.d/omarchy-n1x-gpu-memory.conf}"
cmdline="${OMARCHY_N1X_PROC_CMDLINE:-/proc/cmdline}"

omarchy-hw-aarch64-n1x || exit 0

sudo omarchy-apply-n1x-gpu-memory

# Rebuild while the running kernel still has the option, not only while the
# drop-in is there: a retry after a failed rebuild finds the drop-in gone.
if [[ -f $dropin ]] || grep -q 'efi_reclaim_reserved=' "$cmdline"; then
  sudo rm -f "$dropin"
  sudo limine-mkinitcpio
fi
