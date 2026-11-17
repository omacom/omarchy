echo "Rebuild the boot image a prebuilt image brought from the machine that built it"

# A prebuilt image is built away from the machine it runs on, so the boot
# image it carries describes the machine that built it: its initramfs holds
# that machine's modules and none of this machine's, so a display on a
# discrete GPU has no driver until the real root loads one, after the session
# has already started, and the session picks the wrong card.
#
# A machine's first boot now rebuilds the boot image for its own hardware and
# records that in /var/lib/omarchy/image/boot-image-rebuilt. A machine that
# booted an image before that rebuild existed still carries the builder's, so
# it gets one here.

image_dir=/var/lib/omarchy/image

as_root() {
  if (( EUID == 0 )); then
    "$@"
  else
    sudo "$@"
  fi
}

# A machine that never booted a prebuilt image has a boot image of its own.
if [[ ! -e $image_dir/target.booted ]]; then
  exit 0
fi

# The rebuild that made the boot image the machine's own has been recorded.
if [[ -e $image_dir/boot-image-rebuilt ]]; then
  exit 0
fi

rebuild_log=$(mktemp)
trap 'rm -f "$rebuild_log"' EXIT

# The same rebuild the first boot makes: Limine's where the machine has it,
# mkinitcpio's presets where it does not.
rebuild_status=0
if omarchy-cmd-present limine-mkinitcpio; then
  source "$OMARCHY_PATH/install/helpers/image-target.sh"
  as_root limine-mkinitcpio </dev/null 2>&1 | tee "$rebuild_log" || rebuild_status=$?
  omarchy_image_limine_rebuild_confirmed "$(<"$rebuild_log")" || rebuild_status=1
else
  as_root mkinitcpio -P </dev/null 2>&1 | tee "$rebuild_log" || rebuild_status=$?
fi

if (( rebuild_status != 0 )); then
  echo "A boot image was not rebuilt. Fix the error above, then run omarchy-migrate again before rebooting." >&2
  exit 1
fi

as_root install -Dm644 /dev/null "$image_dir/boot-image-rebuilt"
omarchy-state set reboot-required
