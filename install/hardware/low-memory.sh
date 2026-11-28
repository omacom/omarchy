# On <=8 GiB machines, the default 16+ GiB local-AI profile (half-RAM lzo-rle
# zram + vm.swappiness=1) leaves only ~3.9 GiB of swap before systemd-oomd's
# 90% swap limit trips and evicts hot executable page cache to disk before
# compressing cold browser tabs.
#
# Size zram to full RAM with zstd (~3:1 on desktop/browser pages) without a
# zram-resident-limit (hitting mem_limit returns -ENOMEM on an already-assigned
# zram slot without overflowing to disk swap or tripping oomd's swap limit),
# and raise vm.swappiness to 100 so cold app.slice pages compress into zram
# while session.slice stays pinned in RAM (MemorySwapMax=0).
meminfo=${OMARCHY_MEMINFO:-/proc/meminfo}
sysctl_dir=${OMARCHY_SYSCTL_DIR:-/etc/sysctl.d}
zram_dir=${OMARCHY_ZRAM_DIR:-/etc/systemd/zram-generator.conf.d}
# 9 GiB catches 8 GiB machines (whose MemTotal reads ~7.3-7.9 GiB) while
# leaving 12 GiB and larger machines on the default profile.
low_memory_kib=9437184

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

if (( total_kib <= low_memory_kib )); then
  mkdir -p "$zram_dir" "$sysctl_dir"

  # Named to sort after 90-omarchy.conf and 99-omarchy-sysctl.conf.
  write_atomic "$zram_dir/95-omarchy-low-memory.conf" <<'CONF'
# <=8 GiB machines: full-RAM zstd zram; see install/hardware/low-memory.sh.
[zram0]
zram-size = ram
compression-algorithm = zstd
CONF

  write_atomic "$sysctl_dir/zz-omarchy-low-memory.conf" <<'CONF'
# <=8 GiB machines: compress cold app.slice pages to RAM-backed zram instead of
# evicting executable page cache to disk (session.slice has MemorySwapMax=0);
# see install/hardware/low-memory.sh.
vm.swappiness=100
CONF

  # An image's first boot runs this after systemd-sysctl and zram-generator
  # have already run, and its migration is already marked done, so apply now.
  if [[ ${OMARCHY_IMAGE_DEFERRED_HARDWARE:-} == "1" ]]; then
    sysctl -q -p "$sysctl_dir/zz-omarchy-low-memory.conf" ||
      echo "Warning: could not apply low-memory sysctl override" >&2
    if systemctl daemon-reload; then
      zram_used=$(awk '$1 == "/dev/zram0" { print $4; exit }' /proc/swaps 2>/dev/null)
      if [[ ${zram_used:-0} == "0" ]]; then
        systemctl restart dev-zram0.swap ||
          echo "Warning: could not restart dev-zram0.swap; new zram sizing applies on next boot" >&2
      fi
    else
      echo "Warning: systemctl daemon-reload failed; new zram sizing applies on next boot" >&2
    fi
  fi
else
  rm -f "$zram_dir/95-omarchy-low-memory.conf" "$sysctl_dir/zz-omarchy-low-memory.conf"
fi
