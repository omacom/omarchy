echo "Disable PSR2 selective fetch on the Dell Latitude 9440 2-in-1"

# The hardware leaf that writes this workaround only runs during installation,
# so machines installed before it shipped never got it. Without it, PSR2 leaves
# this panel with severe screen and input lag while every resource stat reads
# idle.

drop_in_dir="${OMARCHY_LATITUDE_9440_DROP_IN_DIR:-/etc/limine-entry-tool.d}"
drop_in="$drop_in_dir/dell-latitude-9440-display.conf"
limine_conf="${OMARCHY_LATITUDE_9440_LIMINE_CONF:-/etc/default/limine}"

omarchy-hw-dell-latitude-9440 || exit 0
omarchy-cmd-present limine-mkinitcpio || exit 0

# Completion is machine-wide while markers are per-user, so a second user must
# not rebuild the boot image again. Any existing i915 PSR setting counts as
# handled: someone who reached for the blunter i915.enable_psr=0 by hand keeps
# it rather than having a second, contradicting drop-in appear beside it.
! grep -rqsF "i915.enable_psr" "$drop_in_dir" "$limine_conf" || exit 0

sudo mkdir -p "$drop_in_dir"
sudo tee "$drop_in" >/dev/null <<'EOF'
# Dell Latitude 9440 2-in-1 (Raptor Lake-P / Iris Xe) display workaround
KERNEL_CMDLINE[default]+=" i915.enable_psr2_sel_fetch=0"
EOF

sudo limine-mkinitcpio
omarchy-state set reboot-required
