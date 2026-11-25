echo "Leave the N1x GPU firmware room below its memory, which a large external display reaches into"

# See install/hardware/fix-n1x-gpu-memory.sh. Installs from before it reclaim a
# second range right under the block the GPU firmware keeps; with a 5K monitor
# the firmware wrote into it and corrupted kernel memory. Keep the first range.
dropin="${OMARCHY_N1X_GPU_MEMORY_CONF:-/etc/limine-entry-tool.d/omarchy-n1x-gpu-memory.conf}"

if [[ ! -f $dropin ]] || ! grep -q 'efi_reclaim_reserved=58G@8G,3968M@67712M' "$dropin"; then
  exit 0
fi

sudo sed -i 's/efi_reclaim_reserved=58G@8G,3968M@67712M/efi_reclaim_reserved=58G@8G/' "$dropin"
sudo limine-mkinitcpio
