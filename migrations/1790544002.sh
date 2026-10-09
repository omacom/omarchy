echo "Rebuild the initramfs when an idle iGPU no longer keeps the kms hook"

# omarchy_hooks.conf now drops kms when NVIDIA owns every connected display,
# even if an idle iGPU is still visible on the PCI bus (#13357). The settings
# package deploys that conditional, but nothing rebuilds the initramfs for a
# mkinitcpio drop-in change. Rebuild once where the conditional now drops kms.

hooks_conf="${OMARCHY_MKINITCPIO_HOOKS_CONF:-/etc/mkinitcpio.conf.d/omarchy_hooks.conf}"
nvidia_conf="${OMARCHY_MKINITCPIO_NVIDIA_CONF:-/etc/mkinitcpio.conf.d/nvidia.conf}"
rebuild_marker="${OMARCHY_KMS_IDLE_IGPU_REBUILD_MARKER:-/var/lib/omarchy/migrations/1790544002}"

omarchy-cmd-present limine-mkinitcpio || exit 0
[[ -f $hooks_conf && -f $nvidia_conf ]] || exit 0
[[ ! -e $rebuild_marker ]] || exit 0

hooks=$(bash -c 'source "$1" && source "$2" && echo " ${HOOKS[*]} "' -- "$nvidia_conf" "$hooks_conf") || exit 0

[[ $hooks != *" kms "* ]] || exit 0

echo "This machine no longer uses the kms hook; rebuilding the initramfs without idle-iGPU firmware"
sudo limine-mkinitcpio
sudo install -Dm644 /dev/null "$rebuild_marker"
