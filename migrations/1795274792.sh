echo "Show the disk unlock prompt on Snapdragon X laptops"

# See install/hardware/qualcomm/hamoa-display.sh. The prompt needs the display
# chain in the boot image, so it takes a rebuild. The Surface Laptop 7 13.8"
# needs its keyboard there as well, which microsoft/surface-laptop-7.sh adds
# and no earlier migration ran for it. A machine-wide marker, written only
# after a rebuild, records that this one is done, and a retry after a failed
# rebuild runs the setup and the rebuild again.
if ! omarchy-hw-aarch64-qualcomm || ! omarchy-hw-match-device-tree qcom,x1e80100 qcom,x1p42100; then
  exit 0
fi

done_marker=/var/lib/omarchy/migrations/1795274792-done
if [[ -e $done_marker ]]; then
  exit 0
fi

sudo env PATH="$PATH" OMARCHY_PATH="$OMARCHY_PATH" bash -euo pipefail -c '
  source "$OMARCHY_PATH/install/hardware/qualcomm/hamoa-display.sh"
  if omarchy-hw-match-device-tree microsoft,romulus13; then
    source "$OMARCHY_PATH/install/hardware/microsoft/surface-laptop-7.sh"
  fi
' || exit 1

rebuild_log=$(mktemp)
trap 'rm -f "$rebuild_log"' EXIT
sudo limine-mkinitcpio 2>&1 | tee "$rebuild_log"

# limine-mkinitcpio reports a kernel it could not rebuild and still exits 0.
if grep -q 'mkinitcpio failed for kernel' "$rebuild_log"; then
  echo "A boot image was not rebuilt. Fix the error above, then run omarchy-migrate again before rebooting." >&2
  exit 1
fi

sudo install -Dm644 /dev/null "$done_marker"
omarchy-state set reboot-required
