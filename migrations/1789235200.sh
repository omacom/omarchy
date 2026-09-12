echo "Tune Btrfs mounts to noatime"

if [[ -f /etc/fstab ]] && grep -qE '[[:space:]]btrfs[[:space:]].*\brelatime\b' /etc/fstab; then
  sudo cp -a /etc/fstab "/etc/fstab.$(date +%Y%m%d%H%M%S).bak"
  sudo sed -i '/[[:space:]]btrfs[[:space:]]/s/\brelatime\b/noatime/g' /etc/fstab

  # Remount active Btrfs mountpoints with noatime immediately
  awk '$3 == "btrfs" && $4 ~ /\brelatime\b/ { print $2 }' /proc/mounts 2>/dev/null | while read -r mp; do
    sudo mount -o remount,noatime "$mp" 2>/dev/null || true
  done
fi
