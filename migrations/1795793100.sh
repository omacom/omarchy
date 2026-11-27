echo "Cap app.slice RAM on >=32 GiB machines to prevent global OOM session kills"

# 28 GiB catches 32 GiB machines (MemTotal ~30-31 GiB) while skipping sudo on
# 4-24 GiB machines.
total_kib=$(awk '$1 == "MemTotal:" { print $2; exit }' /proc/meminfo 2>/dev/null)
if [[ ! $total_kib =~ ^[0-9]+$ ]] || (( total_kib < 29360128 )); then
  exit 0
fi

total_mib=$(( total_kib / 1024 ))
reserve_mib=$(( total_mib / 10 ))
if (( reserve_mib > 11264 )); then
  reserve_mib=11264
fi
app_max_mib=$(( total_mib - reserve_mib ))

dropin=/etc/systemd/user/app.slice.d/20-omarchy-high-memory.conf
config_updated=0

if [[ ! -f $dropin ]] || ! grep -Fqx "MemoryMax=${app_max_mib}M" "$dropin"; then
  sudo bash -e "$OMARCHY_PATH/install/hardware/high-memory.sh"
  config_updated=1
fi

if systemctl --user show-environment >/dev/null 2>&1; then
  cur_max=$(systemctl --user show -p MemoryMax --value app.slice 2>/dev/null || true)
  if (( config_updated == 1 )) || [[ $cur_max == "infinity" ]]; then
    systemctl --user daemon-reload
  fi
fi
