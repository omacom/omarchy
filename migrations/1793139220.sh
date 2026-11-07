echo "Rebuild the initramfs so hybrid laptops shed the unused NVIDIA early KMS stack"

# omarchy_hooks.conf now drops the early nvidia modules and the kms hook on
# hybrid laptops whose NVIDIA GPU drives no display, early-loading the iGPU's
# driver instead. The settings package deploys that conditional, but nothing
# rebuilds the initramfs for a mkinitcpio drop-in change, so affected machines
# would keep the nvidia modules, nouveau and their firmware until the next
# kernel update. Rebuild once, and only where the conditional changes the
# outcome: evaluate the installed drop-ins the way mkinitcpio does and check
# that nvidia_drm dropped out of MODULES.

hooks_conf="${OMARCHY_MKINITCPIO_HOOKS_CONF:-/etc/mkinitcpio.conf.d/omarchy_hooks.conf}"
baseline_conf="${hooks_conf%/*}/00-omarchy-hooks.conf"
nvidia_conf="${OMARCHY_MKINITCPIO_NVIDIA_CONF:-/etc/mkinitcpio.conf.d/nvidia.conf}"
rebuild_marker="${OMARCHY_HYBRID_REBUILD_MARKER:-/var/lib/omarchy/migrations/1793139220}"

omarchy-cmd-present limine-mkinitcpio || exit 0
[[ -f $hooks_conf && -f $nvidia_conf ]] || exit 0

# The rebuild is machine-wide, but migrations run once per user: a marker
# records completion so another user's run does not repeat it, while a missing
# marker still retries an interrupted rebuild.
[[ ! -e $rebuild_marker ]] || exit 0

# Include the baseline when installed, then the hardware and filter drop-ins.
# A config that fails to evaluate leaves the migration pending, so it retries
# once the config is fixed.
modules=$(OMARCHY_MKINITCPIO_CONF_DIR="${hooks_conf%/*}" bash -c 'if [[ -f $1 ]]; then source "$1" || exit 1; fi; source "$2" && source "$3" && echo " ${MODULES[*]} "' -- "$baseline_conf" "$nvidia_conf" "$hooks_conf") || exit 1

[[ $modules != *" nvidia_drm "* ]] || exit 0

echo "This hybrid laptop no longer needs NVIDIA in the initramfs; rebuilding it"
sudo limine-mkinitcpio
sudo install -Dm644 /dev/null "$rebuild_marker"
