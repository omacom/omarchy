# NVIDIA requires two initcalls blacklisted on the GB10 platform. Without it
# the kernel corrupts memory: list corruption, a page whose refcount and
# mapcount disagree, Oopses in whatever subsystem touches the overwritten
# pointer, and finally a deadlock on the vmap area lock that leaves the machine
# frozen with no further log output. DGX OS ships the same parameter, and every
# GB10 quirk Omarchy already carries (sleep, CPU idle states) was read off DGX
# OS the same way. Remove this once NVIDIA's driver no longer needs it:
# https://forums.developer.nvidia.com/t/dgx-spark-kernel-7-0-0-1025-nvidia-memory-corruption-and-system-freezes/388215
limine_config_dir=${OMARCHY_LIMINE_CONFIG_DIR:-/etc/limine-entry-tool.d}

if omarchy-hw-aarch64-gb10; then
  # Only writes the drop-in: the installer's final limine-update builds the
  # UKIs, and an image's first boot rebuilds once after its last step.
  mkdir -p "$limine_config_dir"
  cat >"$limine_config_dir/omarchy-gb10-initcall.conf" <<'CONF'
# GB10: NVIDIA requires these two initcalls blacklisted on Spark-class hardware;
# without it the platform corrupts kernel memory. See
# install/hardware/gb10/initcall-blacklist.sh.
KERNEL_CMDLINE[default]+=" initcall_blacklist=tegra234_cbb_init,power_wrap_init"
CONF
fi
