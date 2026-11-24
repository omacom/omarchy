echo "Let Intel GPUs map all of RAM but 8 GiB, not half"

# See omarchy-apply-gpu-memory, which now raises the cap for Intel graphics on
# xe as well as AMD. The cap is a kernel option, so it takes a boot image
# rebuild and applies from the next boot. A machine-wide marker, written only
# after the rebuild, records that this one is done, so a second user's run
# does nothing.
done_marker=/var/lib/omarchy/migrations/1795354093-done
if [[ -e $done_marker ]]; then
  exit 0
fi

# Written before the drop-in changes and removed only after the rebuild: once
# the drop-in holds the new cap, it no longer shows that a rebuild is owed, so
# a retry after a failed rebuild goes by this instead.
owed_marker=/var/lib/omarchy/migrations/1795354093-owed
drop_in=/etc/limine-entry-tool.d/amd-gpu-memory.conf

if [[ ! -e $owed_marker ]]; then
  # What the helper would write, worked out without root and without touching
  # the drop-in. Only the setting counts: the helper's comment line changed
  # with this, and a raise omarchy-local-ai wrote carries its own.
  wanted_conf=$(mktemp -u)
  OMARCHY_AMD_GPU_MEMORY_CONF=$wanted_conf omarchy-apply-gpu-memory >/dev/null
  wanted=$(grep -v '^#' "$wanted_conf" 2>/dev/null || true)
  rm -f "$wanted_conf"

  # No integrated GPU it covers, or 16 GB or less where the kernel's default is
  # as high.
  if [[ -z $wanted ]]; then
    exit 0
  fi

  # An AMD machine that 1794855305 already rebuilt for, with the same cap,
  # needs no second rebuild.
  if [[ -e /var/lib/omarchy/migrations/1794855305-done && $(grep -v '^#' "$drop_in" 2>/dev/null || true) == "$wanted" ]]; then
    sudo install -Dm644 /dev/null "$done_marker"
    exit 0
  fi

  sudo install -Dm644 /dev/null "$owed_marker"
fi

sudo env PATH="$PATH" omarchy-apply-gpu-memory || exit 1

rebuild_log=$(mktemp)
trap 'rm -f "$rebuild_log"' EXIT
sudo limine-mkinitcpio 2>&1 | tee "$rebuild_log"

# limine-mkinitcpio reports a kernel it could not rebuild and still exits 0.
if grep -q 'mkinitcpio failed for kernel' "$rebuild_log"; then
  echo "A boot image was not rebuilt. Fix the error above, then run omarchy-migrate again before rebooting." >&2
  exit 1
fi

sudo install -Dm644 /dev/null "$done_marker"
sudo rm -f "$owed_marker"
omarchy-state set reboot-required
