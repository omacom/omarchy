echo "Lock the Windows VM's mount folders so a container started outside the launcher can't install onto them"

# omarchy-windows-vm now keeps each unmounted anchor immutable, but only from
# its next launch, and an install whose binds are mounted right now would get
# no lock before its next reboot. Lock the folders under the mounts now: a
# non-recursive bind of the parent shows them without the binds on top, so
# the user's own ~/.windows and ~/Windows are never touched. Every user's
# anchors live under one root-owned tree, so another user's run finds them
# locked already.
mounts=/var/lib/omarchy/windows/mounts
[[ -d $mounts/users ]] || exit 0

view=$(mktemp -d)
sudo mount --bind "$mounts" "$view"
# users/ is root's (0711), so only root can list it.
while IFS= read -r -d '' anchor; do
  if [[ -z $(sudo find "$anchor" -mindepth 1 -print -quit) ]]; then
    sudo chattr +i -- "$anchor" || true
  fi
done < <(sudo find "$view/users" -mindepth 2 -maxdepth 2 -type d \( -name storage -o -name shared \) -print0)
sudo umount "$view"
rmdir "$view"
