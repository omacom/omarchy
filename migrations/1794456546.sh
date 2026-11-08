echo "Rebuild the initramfs so an NVIDIA GPU set up after installation loads its driver early"

# nvidia_module.conf now early-loads the NVIDIA driver wherever its modules are
# installed and nvidia.conf is missing, as on machines whose NVIDIA GPU or
# driver came after installation.
# Nothing rebuilds the initramfs for a drop-in change, so those machines would
# keep loading the driver late, with Hyprland on the wrong GPU, until their
# next kernel update. Rebuild once, only where the drop-in adds the modules for
# an installed kernel that mkinitcpio.conf does not already early-load them for.

nvidia_conf="${OMARCHY_MKINITCPIO_NVIDIA_CONF:-/etc/mkinitcpio.conf.d/nvidia.conf}"
module_conf="${OMARCHY_MKINITCPIO_NVIDIA_MODULE_CONF:-/etc/mkinitcpio.conf.d/nvidia_module.conf}"
rebuild_marker="${OMARCHY_NVIDIA_MODULE_REBUILD_MARKER:-/var/lib/omarchy/migrations/1794456546}"

omarchy-cmd-present limine-mkinitcpio || exit 0
[[ -f $module_conf && ! -f $nvidia_conf ]] || exit 0

# Only a machine with an NVIDIA GPU has the lag now. Elsewhere the drop-in takes
# effect at the next rebuild, with no reboot to ask for.
omarchy-hw-nvidia || exit 0

# The rebuild is machine-wide, but migrations run once per user: a marker
# records completion so another user's run does not repeat it, while a missing
# marker still retries an interrupted rebuild.
[[ ! -e $rebuild_marker ]] || exit 0

adds_modules=0
for pkgbase in /usr/lib/modules/*/pkgbase; do
  [[ -f $pkgbase ]] || continue
  kernel_version=${pkgbase%/pkgbase}
  kernel_version=${kernel_version##*/}
  if KERNELVERSION=$kernel_version bash -c '
    source /etc/mkinitcpio.conf
    [[ " ${MODULES[*]:-} " != *" nvidia_drm "* ]] || exit 1
    source "$1"
    [[ " ${MODULES[*]:-} " == *" nvidia_drm "* ]]
  ' -- "$module_conf"; then
    adds_modules=1
  fi
done

if (( adds_modules )); then
  rebuild_log=$(mktemp)
  trap 'rm -f "$rebuild_log"' EXIT
  sudo limine-mkinitcpio 2>&1 | tee "$rebuild_log"

  # limine-mkinitcpio reports a kernel it could not rebuild and still exits 0.
  if grep -q 'mkinitcpio failed for kernel' "$rebuild_log"; then
    echo "A boot image was not rebuilt. Fix the error above, then run omarchy-migrate again before rebooting." >&2
    exit 1
  fi

  sudo install -Dm644 /dev/null "$rebuild_marker"
  omarchy-state set reboot-required
fi
