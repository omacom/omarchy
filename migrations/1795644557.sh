echo "Load apple-gmux from the initramfs on dual-GPU Macs so the panel's GPU is up before login"

# See install/hardware/apple/fix-apple-gmux-initramfs.sh, including why the
# MacBookPro16,1 is left out; the gate below matches the leaf's. The drop-in
# only takes effect once the boot image is rebuilt, so the done marker goes down
# after the rebuild: a failed rebuild leaves this pending and the next run
# repeats both. The marker is machine-wide, so a second user's run does nothing.
done_marker=/var/lib/omarchy/migrations/1795644557-done

if [[ -e $done_marker ]] || ! omarchy-hw-apple-gmux || omarchy-hw-match "MacBookPro16,1"; then
  exit 0
fi

sudo env PATH="$PATH" OMARCHY_PATH="$OMARCHY_PATH" \
  bash -euo pipefail "$OMARCHY_PATH/install/hardware/apple/fix-apple-gmux-initramfs.sh"

if ! sudo omarchy-boot-rebuild; then
  echo "A boot image was not rebuilt. Fix the error above, then run omarchy-migrate again before rebooting." >&2
  exit 1
fi

sudo install -Dm644 /dev/null "$done_marker"
omarchy-state set reboot-required
