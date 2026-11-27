# On >=32 GiB machines, zram is capped at 8 GiB (min(ram / 2, 8192)), shrinking
# from 25% of RAM at 32 GiB down to ~6% at 128 GiB. High-core workstations can
# allocate across 8-32 threads at 8-30+ GB/s and exhaust all 8 GiB of zram in
# under a second -- beating systemd-oomd's polling loop and triggering either
# global kernel OOM kills against Hyprland/Quickshell/PipeWire or multi-minute
# lockups with order:0 page allocation failures.
#
# Cap app.slice RAM with MemoryMax so the kernel's cgroup OOM killer contains
# fast runaway bursts synchronously inside app.slice while preserving headroom
# outside app.slice for session.slice, system.slice, and zram's uncompressed
# worst-case footprint (up to 8 GiB). Reserve 10% of RAM capped at 11 GiB
# (8 GiB max zram + ~3 GiB session/system/kernel), so 128 GiB machines keep
# ~114 GiB of RAM (plus 8 GiB zram swap) available for local models and apps
# and 256+ GiB workstations do not lose excessive capacity.
meminfo=${OMARCHY_MEMINFO:-/proc/meminfo}
user_systemd_dir=${OMARCHY_USER_SYSTEMD_DIR:-/etc/systemd/user}
dropin_dir="$user_systemd_dir/app.slice.d"
dropin_file="$dropin_dir/20-omarchy-high-memory.conf"
# 28 GiB catches 32 GiB machines (whose MemTotal reads ~30-31 GiB) while
# leaving 4-24 GiB machines uncapped.
high_memory_kib=29360128
max_reserve_mib=11264

write_atomic() {
  local dest=$1 tmp
  tmp=$(mktemp "$(dirname "$dest")/.$(basename "$dest").XXXXXX") || return 1
  if cat >"$tmp" && chmod 0644 "$tmp" && mv -f "$tmp" "$dest"; then
    return 0
  fi
  rm -f "$tmp"
  return 1
}

total_kib=$(awk '$1 == "MemTotal:" { print $2; exit }' "$meminfo" 2>/dev/null)
if [[ ! $total_kib =~ ^[0-9]+$ ]] || (( total_kib == 0 )); then
  return 0 2>/dev/null || exit 0
fi

if (( total_kib >= high_memory_kib )); then
  total_mib=$(( total_kib / 1024 ))
  reserve_mib=$(( total_mib / 10 ))
  if (( reserve_mib > max_reserve_mib )); then
    reserve_mib=$max_reserve_mib
  fi
  app_max_mib=$(( total_mib - reserve_mib ))

  mkdir -p "$dropin_dir"

  # Named to sort after /usr/lib/systemd/user/app.slice.d/10-oomd.conf.
  write_atomic "$dropin_file" <<CONF
# >=32 GiB machines: contain fast app.slice bursts before they outrun
# systemd-oomd and trigger global kernel OOM; see install/hardware/high-memory.sh.
[Slice]
MemoryMax=${app_max_mib}M
CONF
else
  rm -f "$dropin_file"
fi
