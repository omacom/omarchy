echo "Keep the NVIDIA driver out of the initramfs so hibernation can resume"

# nvidia.conf still lists the modules so omarchy_hooks.conf can drop kms on
# an NVIDIA-only machine. The later drop-in removes them. Existing installs
# keep the old boot image until this rebuild. The rebuild is machine-wide;
# the marker makes a later user's run a no-op, and a missing marker retries
# a rebuild that did not finish. limine-mkinitcpio can return success after
# skipping a failed kernel build, so the marker is written only once the
# current UKIs omit the proprietary NVIDIA modules.

dropin="${OMARCHY_NVIDIA_NO_EARLY_LOAD_CONF:-/etc/mkinitcpio.conf.d/zz-nvidia-no-early-load.conf}"
nvidia_conf="${OMARCHY_MKINITCPIO_NVIDIA_CONF:-/etc/mkinitcpio.conf.d/nvidia.conf}"
marker="${OMARCHY_NVIDIA_HIBERNATE_REBUILD_MARKER:-/var/lib/omarchy/migrations/1791210803}"
uki_dir="${OMARCHY_BOOT_UKI_DIR:-/boot/EFI/Linux}"
source_conf="$OMARCHY_PATH/install/hardware/nvidia-no-early-load.conf"

[[ -f $nvidia_conf ]] || exit 0
omarchy-cmd-present limine-mkinitcpio || exit 0
[[ ! -e $marker ]] || exit 0

sudo install -Dm644 "$source_conf" "$dropin"
sudo limine-mkinitcpio

mapfile -d '' images < <(sudo find "$uki_dir" -maxdepth 1 -name 'omarchy_linux*.efi' -print0 2>/dev/null | sort -z)
if ((${#images[@]} == 0)); then
  echo "No Omarchy boot image was found; rerun omarchy-migrate after fixing the boot image build." >&2
  exit 1
fi

image=""
for image in "${images[@]}"; do
  [[ -n $image ]] || continue
  listing=$(sudo lsinitcpio "$image") || {
    echo "Could not read boot image: $image" >&2
    exit 1
  }
  if grep -E '/nvidia(_modeset|_uvm|_drm|_peermem)?\.ko' <<<"$listing" >/dev/null; then
    echo "Boot image still contains the NVIDIA driver: $image" >&2
    echo "Rerun omarchy-migrate after fixing the boot image build." >&2
    exit 1
  fi
done

sudo install -Dm644 /dev/null "$marker"
