echo "Tune Btrfs mounts to noatime"

if [[ -f /etc/fstab ]] && grep -qE '[[:space:]]btrfs[[:space:]].*\brelatime\b' /etc/fstab; then
  sudo cp -a /etc/fstab "/etc/fstab.$(date +%Y%m%d%H%M%S).bak"
  sudo sed -i '/[[:space:]]btrfs[[:space:]]/s/\brelatime\b/noatime/g' /etc/fstab

  echo "Btrfs noatime mounts will take effect after reboot"
fi
