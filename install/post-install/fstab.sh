# Archinstall writes Btrfs subvolume mounts with 'relatime'. In Btrfs, every
# access-time update triggers Copy-on-Write metadata writes that fragment
# snapshots and add write amplification to SSD/NVMe. Tune Btrfs mounts to 'noatime'.
if [[ -f /etc/fstab ]]; then
  sed -i '/[[:space:]]btrfs[[:space:]]/s/\brelatime\b/noatime/g' /etc/fstab
fi
