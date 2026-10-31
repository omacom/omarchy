echo "Give the ASUS Zenbook A16 (UX3607OA) its DSP firmware, Wi-Fi board data and text-console unlock"

# See install/hardware/asus/fix-asus-zenbook-a16-firmware.sh and
# fix-asus-zenbook-a16-boot.sh.
rebuild_marker="${OMARCHY_LIMINE_REBUILD_MARKER:-/var/lib/omarchy/migrations/1793364921}"

if ! omarchy-hw-aarch64-qualcomm || ! omarchy-hw-match "UX3607OA"; then
  exit 0
fi

omarchy-pkg-add asus-zenbook-a16-firmware

# Setup kept the DSP driver off while its firmware was missing; with the
# package in place the same step now lets it start. The boot settings change
# the initramfs and the kernel command line, so the image is rebuilt once.
sudo env PATH="$PATH" OMARCHY_PATH="$OMARCHY_PATH" bash -c '
  source "$OMARCHY_PATH/install/hardware/qualcomm/firmware.sh"
  source "$OMARCHY_PATH/install/hardware/asus/fix-asus-zenbook-a16-boot.sh"
'

# A marker records the machine-wide rebuild: another user's run must not repeat
# it, while a missing marker still retries an interrupted rebuild.
if [[ ! -e $rebuild_marker ]]; then
  sudo limine-mkinitcpio
  sudo install -Dm644 /dev/null "$rebuild_marker"
fi

omarchy-state set reboot-required
