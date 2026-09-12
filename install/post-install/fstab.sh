# Archinstall writes Btrfs subvolume mounts with 'relatime'. Avoid access-time
# metadata updates on Omarchy's read-heavy, snapshotted Btrfs layout.
if [[ -f /etc/fstab ]]; then
  sed -i '/[[:space:]]btrfs[[:space:]]/s/\brelatime\b/noatime/g' /etc/fstab
fi
