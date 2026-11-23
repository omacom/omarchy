echo "Blacklist the GB10 initcalls NVIDIA requires"

# Without these two initcalls blacklisted the GB10 platform corrupts kernel
# memory: list corruption, a bad page state, Oopses in unrelated subsystems,
# then a hard freeze that leaves the filesystem dirty. DGX OS ships the same
# parameter, and install/hardware/gb10/initcall-blacklist.sh now writes it for
# fresh installs. See
# https://forums.developer.nvidia.com/t/dgx-spark-kernel-7-0-0-1025-nvidia-memory-corruption-and-system-freezes/388215
rebuild_marker="${OMARCHY_GB10_INITCALL_MARKER:-/var/lib/omarchy/migrations/1794563033}"

omarchy-hw-aarch64-gb10 || exit 0
omarchy-cmd-present limine-mkinitcpio || exit 0

# Machine-wide: the marker lets another user's run skip the rebuild, while a
# missing marker retries one that failed or was interrupted. The drop-in alone
# is not enough, a UKI carries the command line it was built with.
[[ ! -e $rebuild_marker ]] || exit 0

sudo bash "$OMARCHY_PATH/install/hardware/gb10/initcall-blacklist.sh"

rebuild_log=$(mktemp)
trap 'rm -f "$rebuild_log"' EXIT
sudo limine-mkinitcpio 2>&1 | tee "$rebuild_log"

# limine-mkinitcpio reports a kernel it could not rebuild and still exits 0.
# That image lacks the parameter, so the migration stays pending.
if grep -q 'mkinitcpio failed for kernel' "$rebuild_log"; then
  echo "A boot image was not rebuilt. Fix the error above, then run omarchy-migrate again before rebooting." >&2
  exit 1
fi

sudo install -Dm644 /dev/null "$rebuild_marker"
omarchy-state set reboot-required
