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

# Written before the parameters change and removed only after the rebuild:
# once they hold the new cap, they no longer show that a rebuild is owed, so a
# retry after a failed rebuild goes by this instead.
owed_marker=/var/lib/omarchy/migrations/1795354093-owed

if [[ ! -e $owed_marker ]]; then
  # What the helper would set, worked out without root and without touching
  # the parameters in effect: it writes into empty scratch directories, one
  # per boot loader's format. Only the setting counts: the helper's comment
  # line changed with this, and a raise omarchy-local-ai wrote carries its own.
  scratch=$(mktemp -d)
  OMARCHY_AMD_GPU_MEMORY_CONF=$scratch/limine/amd-gpu-memory.conf OMARCHY_BOOT_CMDLINE_DIR=$scratch/cmdline \
    omarchy-apply-gpu-memory >/dev/null
  wanted=$(OMARCHY_BOOT_LIMINE_DROPINS=$scratch/limine OMARCHY_BOOT_CMDLINE_DIR=$scratch/cmdline omarchy-boot-cmdline get amd-gpu-memory)
  rm -rf "$scratch"

  # No integrated GPU it covers, or 16 GB or less where the kernel's default is
  # as high.
  if [[ -z $wanted ]]; then
    exit 0
  fi

  # An AMD machine that 1794855305 already rebuilt for, with the same cap,
  # needs no second rebuild.
  if [[ -e /var/lib/omarchy/migrations/1794855305-done && $(omarchy-boot-cmdline get amd-gpu-memory) == "$wanted" ]]; then
    sudo install -Dm644 /dev/null "$done_marker"
    exit 0
  fi

  sudo install -Dm644 /dev/null "$owed_marker"
fi

sudo env PATH="$PATH" omarchy-apply-gpu-memory || exit 1

if ! sudo omarchy-boot-rebuild; then
  echo "A boot image was not rebuilt. Fix the error above, then run omarchy-migrate again before rebooting." >&2
  exit 1
fi

sudo install -Dm644 /dev/null "$done_marker"
sudo rm -f "$owed_marker"
omarchy-state set reboot-required
