# Omarchy keeps ~1.25% of memory free (vm.watermark_scale_factor=125 in
# 99-omarchy-sysctl.conf) so kswapd reclaims ahead of allocations. On a GB10's
# 128 GB that's ~3 GiB the kernel keeps evicting to hold free, out of memory
# the GPU shares: a local model loaded next to the desktop had 4.3 GiB more
# available at the kernel's default of 10, which DGX OS ships.
sysctl_dir=${OMARCHY_SYSCTL_DIR:-/etc/sysctl.d}

if omarchy-hw-aarch64-gb10; then
  mkdir -p "$sysctl_dir"
  # Named to sort after 99-omarchy-sysctl.conf, whose setting this overrides.
  cat >"$sysctl_dir/zz-omarchy-gb10-memory.conf" <<'CONF'
# GB10: keep the kernel's default free-memory watermark; see
# install/hardware/gb10/memory-watermark.sh.
vm.watermark_scale_factor=10
CONF

  # An image's first boot runs this after systemd-sysctl has applied Omarchy's
  # setting, and its migration is already marked done, so apply it now. Only
  # there, as in install/hardware/qualcomm/powerprofiles-floor.sh.
  if [[ ${OMARCHY_IMAGE_DEFERRED_HARDWARE:-} == "1" ]]; then
    sysctl -q -p "$sysctl_dir/zz-omarchy-gb10-memory.conf" || true
  fi
fi
