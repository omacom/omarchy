echo "Keep the NVIDIA driver out of the initramfs so hibernation can resume"

# nvidia.conf still lists the modules so omarchy_hooks.conf can drop kms on
# an NVIDIA-only machine. The later drop-in removes them. Existing installs
# keep the old boot image until this rebuild. The rebuild is machine-wide;
# the marker makes a later user's run a no-op, and a missing marker retries
# a rebuild that did not finish.

dropin="${OMARCHY_NVIDIA_NO_EARLY_LOAD_CONF:-/etc/mkinitcpio.conf.d/zz-nvidia-no-early-load.conf}"
nvidia_conf="${OMARCHY_MKINITCPIO_NVIDIA_CONF:-/etc/mkinitcpio.conf.d/nvidia.conf}"
marker="${OMARCHY_NVIDIA_HIBERNATE_REBUILD_MARKER:-/var/lib/omarchy/migrations/1791210803}"
source_conf="$OMARCHY_PATH/install/hardware/nvidia-no-early-load.conf"

[[ -f $nvidia_conf ]] || exit 0
omarchy-cmd-present limine-mkinitcpio || exit 0
[[ ! -e $marker ]] || exit 0

sudo install -Dm644 "$source_conf" "$dropin"
sudo limine-mkinitcpio
sudo install -Dm644 /dev/null "$marker"
