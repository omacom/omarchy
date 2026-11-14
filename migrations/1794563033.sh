echo "Blacklist the GB10 initcalls NVIDIA requires"

# Without these two initcalls blacklisted the GB10 platform corrupts kernel
# memory: list corruption, a bad page state, Oopses in unrelated subsystems,
# then a hard freeze that leaves the filesystem dirty. DGX OS ships the same
# parameter, and install/hardware/gb10/initcall-blacklist.sh now writes it for
# fresh installs. See
# https://forums.developer.nvidia.com/t/dgx-spark-kernel-7-0-0-1025-nvidia-memory-corruption-and-system-freezes/388215
limine_conf_dir="${OMARCHY_LIMINE_ENTRY_TOOL_DIR:-/etc/limine-entry-tool.d}"
dropin=$limine_conf_dir/omarchy-gb10-initcall.conf
rebuild_marker="${OMARCHY_GB10_INITCALL_MARKER:-/var/lib/omarchy/migrations/1794563033}"

omarchy-hw-aarch64-gb10 || exit 0
omarchy-cmd-present limine-mkinitcpio || exit 0

# Machine-wide: the marker lets another user's run skip the rebuild, while a
# missing marker retries one that failed or was interrupted. The drop-in alone
# is not enough, a UKI carries the command line it was built with.
[[ ! -e $rebuild_marker ]] || exit 0

# Only the active drop-ins count. A saved .bak copy, or a commented-out line in
# /etc/default/limine, never reaches the boot command line.
if ! grep -rqs --include='*.conf' "initcall_blacklist=tegra234_cbb_init,power_wrap_init" \
  "$limine_conf_dir"; then
  sudo install -Dm644 /dev/stdin "$dropin" <<'CONF'
# GB10: NVIDIA requires these two initcalls blacklisted on Spark-class hardware;
# without it the platform corrupts kernel memory. See
# install/hardware/gb10/initcall-blacklist.sh.
KERNEL_CMDLINE[default]+=" initcall_blacklist=tegra234_cbb_init,power_wrap_init"
CONF
fi

# A failed rebuild leaves the old boot image without the parameter, so it exits
# non-zero and stays pending: the marker is only written once the rebuild ran.
sudo limine-mkinitcpio || exit 1
sudo install -Dm644 /dev/null "$rebuild_marker"
