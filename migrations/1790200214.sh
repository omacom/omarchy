echo "Rebuild the initramfs so the amdgpu HDMI HPD debounce applies at early boot"

# etc/modprobe.d/amdgpu.conf now arms amdgpu's HDMI HPD filter (off by default
# upstream) so displays that drop hotplug-detect in DPMS power save no longer
# remove and re-add a locked output every ~15s. The parameter is read once at
# module load, and amdgpu loads out of the initramfs (kms + modconf hooks), so
# existing installs only see it after an initramfs rebuild and a reboot; a
# plain package update would leave it inert until some later kernel rebuild.
# Rebuild once, only where it does anything: an amdgpu share of a display
# controller is present and the packaged config has actually landed.

omarchy-cmd-present limine-mkinitcpio || exit 0
conf="${OMARCHY_AMDGPU_HPD_CONF:-/etc/modprobe.d/amdgpu.conf}"
[[ -f $conf ]] || exit 0

rebuild_marker="${OMARCHY_AMDGPU_HPD_REBUILD_MARKER:-/var/lib/omarchy/migrations/1790200214}"

# The rebuild is machine-wide, but migrations run once per user: a marker
# records completion so another user's run does not repeat it, while a missing
# marker still retries an interrupted rebuild.
[[ ! -e $rebuild_marker ]] || exit 0

# Scope the rebuild to machines with an AMD display controller, mirroring the
# PCI scan the mkinitcpio drop-ins use. The config is inert elsewhere, so
# rebuilding there would only needlessly flag a reboot.
have_amd=0
for pci_device in "${OMARCHY_PCI_DEVICES_PATH:-/sys/bus/pci/devices}"/*; do
  [[ -r $pci_device/vendor && -r $pci_device/class ]] || continue
  [[ $(<"$pci_device/vendor") == "0x1002" ]] || continue
  [[ $(<"$pci_device/class") == "0x03"* ]] || continue
  have_amd=1
  break
done
(( have_amd )) || exit 0

echo "AMD GPU present; rebuilding the initramfs with the amdgpu HDMI HPD debounce"
sudo limine-mkinitcpio
sudo install -Dm644 /dev/null "$rebuild_marker"
omarchy-state set reboot-required