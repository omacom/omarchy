echo "Shrink an AMD APU's dedicated VRAM so the GPU can map more of RAM"

# See omarchy-apply-amd-gpu-memory. Only firmware that lets amdgpu change the
# carveout has uma/carveout, and only a shrunk carveout needs a rebuild: the
# cap is resized for the RAM it frees, and both apply from the next boot. A
# machine-wide marker, written only after the rebuild, records that this one
# is done, so a second user's run does nothing. The carveout is already written
# when a rebuild fails, so a pending marker makes the retry rebuild anyway.
done_marker=/var/lib/omarchy/migrations/1794919730-done
pending_marker=/var/lib/omarchy/migrations/1794919730-pending
if [[ -e $done_marker ]]; then
  exit 0
fi

carveouts() {
  cat /sys/bus/pci/devices/*/uma/carveout 2>/dev/null || true
}

before=$(carveouts)
if [[ -z $before ]]; then
  exit 0
fi

sudo env PATH="$PATH" omarchy-apply-amd-gpu-memory || exit 1

if [[ $(carveouts) == "$before" && ! -e $pending_marker ]]; then
  exit 0
fi

sudo install -Dm644 /dev/null "$pending_marker"
rebuild_log=$(mktemp)
trap 'rm -f "$rebuild_log"' EXIT
sudo limine-mkinitcpio 2>&1 | tee "$rebuild_log"

# limine-mkinitcpio reports a kernel it could not rebuild and still exits 0.
if grep -q 'mkinitcpio failed for kernel' "$rebuild_log"; then
  echo "A boot image was not rebuilt. Fix the error above, then run omarchy-migrate again before rebooting." >&2
  exit 1
fi

sudo install -Dm644 /dev/null "$done_marker"
sudo rm -f "$pending_marker"
omarchy-state set reboot-required
