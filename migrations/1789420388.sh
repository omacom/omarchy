echo "Disable PSR2 selective fetch on the Dell Latitude 9440 2-in-1"

# The hardware leaf that writes this workaround only runs during installation,
# so machines installed before it shipped never got it. Without it, PSR2 leaves
# this panel with severe screen and input lag while every resource stat reads
# idle.

drop_in_dir="${OMARCHY_LATITUDE_9440_DROP_IN_DIR:-/etc/limine-entry-tool.d}"
drop_in="$drop_in_dir/dell-latitude-9440-display.conf"
limine_conf="${OMARCHY_LATITUDE_9440_LIMINE_CONF:-/etc/default/limine}"
rebuild_marker="${OMARCHY_LATITUDE_9440_REBUILD_MARKER:-/var/lib/omarchy/migrations/1789420388}"
workaround='# Dell Latitude 9440 2-in-1 (Raptor Lake-P / Iris Xe) display workaround
KERNEL_CMDLINE[default]+=" i915.enable_psr2_sel_fetch=0"'

omarchy-hw-dell-latitude-9440 || exit 0
omarchy-cmd-present limine-mkinitcpio || exit 0

# The rebuild is machine-wide, but migrations run once per user: a marker
# records completion so another user's run does not repeat it, while a missing
# marker still retries an interrupted rebuild.
[[ ! -e $rebuild_marker ]] || exit 0

# Someone who reached for the blunter i915.enable_psr=0 by hand keeps it rather
# than having a second, contradicting drop-in appear beside it. Our drop-in as
# an interrupted run leaves it is not theirs; one they have edited is.
[[ ! -e $drop_in || $(<"$drop_in") == "$workaround" ]] || exit 0
! grep -qsE --exclude="${drop_in##*/}" '^[^#]*i915\.enable_psr' "$drop_in_dir"/*.conf "$limine_conf" || exit 0

sudo mkdir -p "$drop_in_dir"
printf '%s\n' "$workaround" | sudo tee "$drop_in" >/dev/null

sudo limine-mkinitcpio
omarchy-state set reboot-required
sudo install -Dm644 /dev/null "$rebuild_marker"
