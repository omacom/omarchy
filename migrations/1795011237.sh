echo "Return freed GPU memory to the system at once on GB10 machines"

# See install/hardware/gb10/nvidia-memory-pools.sh. The nvidia module loads from
# the boot image, which carries its options, so the image is rebuilt.
rebuild_marker="${OMARCHY_LIMINE_REBUILD_MARKER:-/var/lib/omarchy/migrations/1795011237}"

omarchy-hw-aarch64-gb10 || exit 0

sudo env PATH="$PATH" bash "$OMARCHY_PATH/install/hardware/gb10/nvidia-memory-pools.sh"

# A marker records the machine-wide rebuild: another user's run must not repeat
# it, while a missing marker still retries an interrupted rebuild.
if [[ ! -e $rebuild_marker ]]; then
  rebuild_log=$(mktemp)
  trap 'rm -f "$rebuild_log"' EXIT
  sudo limine-mkinitcpio 2>&1 | tee "$rebuild_log"

  # limine-mkinitcpio reports a kernel it could not rebuild and still exits 0.
  # That image lacks the option, so the migration stays pending.
  if grep -q 'mkinitcpio failed for kernel' "$rebuild_log"; then
    echo "A boot image was not rebuilt. Fix the error above, then run omarchy-migrate again before rebooting." >&2
    exit 1
  fi

  sudo install -Dm644 /dev/null "$rebuild_marker"
  omarchy-state set reboot-required
fi
