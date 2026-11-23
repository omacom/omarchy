echo "Let AMD GPUs map all of RAM but 8 GiB, not half"

# See omarchy-apply-gpu-memory. The cap is a kernel option, so it takes a
# boot image rebuild and applies from the next boot. A machine-wide marker,
# written only after the rebuild, records that this one is done, so a retry
# after a failed rebuild writes and rebuilds again and a second user's run
# does nothing.
done_marker=/var/lib/omarchy/migrations/1794855305-done
if [[ -e $done_marker ]]; then
  exit 0
fi

sudo env PATH="$PATH" omarchy-apply-gpu-memory || exit 1

# No AMD GPU, or 16 GB or less where the kernel's default is as high.
if [[ ! -f /etc/limine-entry-tool.d/amd-gpu-memory.conf ]]; then
  exit 0
fi

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
