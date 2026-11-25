echo "Give zram a disk swapfile to overflow into"

# Installs before this got swap on zram only, capped at half of RAM or 8 GiB,
# so a busy desktop that fills RAM and zram has nowhere left to go. Hibernation
# setup already made the swapfile on machines where the owner asked for it;
# omarchy-apply-swapfile finds that one and leaves it as it is, and also skips
# non-Btrfs roots, existing disk swap and nearly full disks.
grep -Fq /swap/swapfile /etc/fstab && exit 0

sudo omarchy-apply-swapfile
