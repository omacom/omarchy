# etc/sysctl.d/99-omarchy-sysctl.conf sets vm.watermark_scale_factor=125, a
# kswapd step of 1.25% of RAM between each watermark. The step only has to
# cover the allocations that arrive while kswapd catches up, which doesn't
# grow with RAM, but 1.25% does: ~1.5 GiB on 128 GB, where the high watermark
# then holds back ~3 GiB the kernel no longer reports as available. Above
# 32 GB, scale the share down to what a 32 GB machine gets.
watermark_conf_dir=${OMARCHY_SYSCTL_CONFIG_DIR:-/etc/sysctl.d}
# Read after 99-omarchy-sysctl.conf, so this value wins.
watermark_conf="$watermark_conf_dir/99-omarchy-watermark.conf"
watermark_shipped_factor=125

watermark_factor=$(awk -v shipped="$watermark_shipped_factor" '
  /^MemTotal:/ && $2 > 0 { print int(32 * 1024 * 1024 * shipped / $2); found = 1 }
  END { exit !found }
' "${OMARCHY_PROC_ROOT:-/proc}/meminfo")

if (( watermark_factor < watermark_shipped_factor )); then
  # Never below the kernel's own default.
  if (( watermark_factor < 10 )); then
    watermark_factor=10
  fi
  mkdir -p "$watermark_conf_dir"
  cat >"$watermark_conf.tmp" <<CONF
# Omarchy: this machine's share of 99-omarchy-sysctl.conf's 1.25% capped at
# what a 32 GB machine gets (install/hardware/memory-watermark.sh).
vm.watermark_scale_factor=$watermark_factor
CONF
  mv -f "$watermark_conf.tmp" "$watermark_conf"
  # An image's first boot runs this after systemd-sysctl, and no reboot
  # follows. Under the installer's chroot it reaches only the live kernel, and
  # the file covers the installed system's boot.
  sysctl -q -p "$watermark_conf" >/dev/null ||
    echo "Warning: could not apply $watermark_conf until the next boot" >&2
elif [[ -f $watermark_conf ]]; then
  # The machine has dropped to 32 GB or less since the cap was written.
  rm -f "$watermark_conf"
  sysctl -q -w vm.watermark_scale_factor="$watermark_shipped_factor" >/dev/null ||
    echo "Warning: could not restore vm.watermark_scale_factor until the next boot" >&2
fi
