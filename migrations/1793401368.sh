echo "Start the Zenbook A16 DSPs before opening the root disk"

omarchy-hw-aarch64-qualcomm && omarchy-hw-match-device-tree asus,zenbook-a16-ux3607oa || exit 0

# The boot image is shared even though migration completion is per user.
rebuild_marker=/var/lib/omarchy/migrations/1793401368
[[ ! -e $rebuild_marker ]] || exit 0

sudo env OMARCHY_PATH="$OMARCHY_PATH" bash -euo pipefail -c '
  export PATH="$OMARCHY_PATH/bin:$PATH"
  source "$OMARCHY_PATH/install/hardware/qualcomm/initramfs.sh"
  source "$OMARCHY_PATH/install/hardware/asus/fix-asus-zenbook-a16-dsp.sh"
'

build_log=$(mktemp)
trap 'rm -f "$build_log"' EXIT
build_status=0
# shellcheck disable=SC2024 # The temporary log belongs to the invoking user.
sudo limine-mkinitcpio >"$build_log" 2>&1 || build_status=$?
cat "$build_log"
# Older limine-mkinitcpio versions return success after skipping a failed image.
if (( build_status != 0 )) || grep -Eq '(^==> ERROR:|mkinitcpio failed for kernel)' "$build_log"; then
  echo "A16 DSP boot image rebuild failed; the migration will retry" >&2
  exit 1
fi

omarchy-state set reboot-required
sudo install -Dm644 /dev/null "$rebuild_marker"
