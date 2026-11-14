echo "Cap the memory kswapd keeps free on machines over 32 GB"

# Installs from before install/hardware/memory-watermark.sh keep 1.25% of RAM
# per watermark step, ~1.5 GiB on 128 GB.
(( $(awk '/^MemTotal:/ { print $2 }' /proc/meminfo) > 32 * 1024 * 1024 )) || exit 0
grep -qE '^vm\.watermark_scale_factor=[0-9]+$' /etc/sysctl.d/99-omarchy-watermark.conf 2>/dev/null && exit 0

sudo bash -eE "$OMARCHY_PATH/install/hardware/memory-watermark.sh"
sudo sysctl -p /etc/sysctl.d/99-omarchy-watermark.conf >/dev/null || omarchy-state set reboot-required
