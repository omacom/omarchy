echo "Let btrfs reclaim partly used data chunks so metadata cannot run out of room"

# The tmpfiles drop-in applies at every boot. Apply it now as well, so a machine
# already close to the limit does not have to wait for a reboot. Machines with
# no btrfs, or a kernel without these files, have nothing to do.
conf=/etc/tmpfiles.d/omarchy-btrfs-reclaim.conf
needs_apply=0

for setting in /sys/fs/btrfs/*/allocation/data/{dynamic,periodic}_reclaim; do
  if [[ -f $setting && $(<"$setting") != "1" ]]; then
    needs_apply=1
  fi
done

if [[ -f $conf ]] && (( needs_apply )); then
  sudo systemd-tmpfiles --create "$conf"
fi
