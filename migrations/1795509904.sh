echo "Cap zram at 8 GiB with lzo-rle and prefer dropping page cache over swapping desktop apps"

# Wait until omarchy-settings delivers the updated vendor drop-in and sysctl file.
zram_dropin=/usr/lib/systemd/zram-generator.conf.d/90-omarchy.conf
if [[ ! -f $zram_dropin ]] || ! grep -q '^compression-algorithm = lzo-rle$' "$zram_dropin"; then
  echo "Waiting for the omarchy-settings package that ships the updated zram and reclaim tuning" >&2
  exit 75
fi

# Skip privileged work when another user or a reboot already applied the tuning.
zram_ready=1
if [[ -r /sys/block/zram0/comp_algorithm && -r /sys/block/zram0/disksize ]]; then
  zram_algo=$(< /sys/block/zram0/comp_algorithm)
  zram_size=$(< /sys/block/zram0/disksize)
  half_ram=$(awk '$1 == "MemTotal:" {print $2 * 512}' /proc/meminfo)
  max_zram=$(( half_ram < 8589934592 ? half_ram : 8589934592 ))
  if [[ $zram_algo != *"[lzo-rle]"* ]] || (( zram_size > max_zram + 16777216 )); then
    zram_ready=0
  fi
fi

cur_swappiness=$(sysctl -n vm.swappiness)
cur_vfs_pressure=$(sysctl -n vm.vfs_cache_pressure)

if [[ $cur_swappiness == "1" && $cur_vfs_pressure != "50" ]] && (( zram_ready == 1 )); then
  exit 0
fi

# Apply only the two sysctl keys this update changes so later drop-ins (such as
# zz-omarchy-gb10-memory.conf) keep their live values. Fail if sudo or sysctl
# fails so the migration stays pending instead of being marked complete.
sysctl_updates=()
if [[ $cur_swappiness != "1" ]]; then
  sysctl_updates+=(vm.swappiness=1)
fi
if [[ $cur_vfs_pressure == "50" ]]; then
  sysctl_updates+=(vm.vfs_cache_pressure=100)
fi
if (( ${#sysctl_updates[@]} > 0 )); then
  sudo sysctl -q -w "${sysctl_updates[@]}"
fi

if (( zram_ready == 1 )); then
  exit 0
fi

if sudo systemctl daemon-reload; then
  # Resizing swaps the device off first, which faults every stored page back
  # into memory. Only do that while it is empty; otherwise pick it up on reboot.
  zram_used=$(awk '$1 == "/dev/zram0" {print $4}' /proc/swaps)

  if [[ ${zram_used:-0} == 0 ]] && sudo systemctl restart dev-zram0.swap; then
    exit 0
  fi
fi

omarchy-state set reboot-required
