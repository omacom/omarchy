echo "Tune zram and reclaim for 8 GiB machines"

# 9 GiB catches 8 GiB machines (MemTotal ~7.3-7.9 GiB) while skipping sudo on
# 12 GiB and larger machines.
total_kib=$(awk '$1 == "MemTotal:" { print $2; exit }' /proc/meminfo 2>/dev/null)
[[ $total_kib =~ ^[0-9]+$ ]] && (( total_kib > 0 && total_kib <= 9437184 )) || exit 0

zram_conf=/etc/systemd/zram-generator.conf.d/95-omarchy-low-memory.conf
sysctl_conf=/etc/sysctl.d/zz-omarchy-low-memory.conf

configs_ready=0
if [[ -f $zram_conf && -f $sysctl_conf ]] &&
  grep -Fqx 'zram-size = ram' "$zram_conf" &&
  grep -Fqx 'compression-algorithm = zstd' "$zram_conf" &&
  grep -Fqx 'vm.swappiness=100' "$sysctl_conf"; then
  configs_ready=1
fi

zram_ready=1
if [[ -r /sys/block/zram0/comp_algorithm && -r /sys/block/zram0/disksize ]]; then
  zram_algo=$(< /sys/block/zram0/comp_algorithm)
  zram_size=$(< /sys/block/zram0/disksize)
  target_bytes=$(( total_kib * 1024 ))
  if [[ $zram_algo != *"[zstd]"* ]] || (( zram_size + 67108864 < target_bytes )); then
    zram_ready=0
  fi
fi

cur_swappiness=$(sysctl -n vm.swappiness)

if (( configs_ready == 1 && zram_ready == 1 )) && [[ $cur_swappiness == "100" ]]; then
  exit 0
fi

if (( configs_ready == 0 )); then
  sudo bash -e "$OMARCHY_PATH/install/hardware/low-memory.sh"
fi

if [[ $cur_swappiness != "100" ]]; then
  sudo sysctl -q -p "$sysctl_conf"
fi

if (( zram_ready == 1 )); then
  exit 0
fi

if sudo systemctl daemon-reload; then
  # Resizing swaps the device off first, which faults every stored page back
  # into memory. Only do that while it is empty; otherwise pick it up on reboot.
  zram_used=$(awk '$1 == "/dev/zram0" { print $4; exit }' /proc/swaps 2>/dev/null)
  if [[ ${zram_used:-0} == "0" ]] && sudo systemctl restart dev-zram0.swap; then
    exit 0
  fi
fi

omarchy-state set reboot-required
