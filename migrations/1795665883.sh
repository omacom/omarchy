echo "Lock the Windows VM's mount folders so a container started outside the launcher can't install onto them"

[[ -d /var/lib/omarchy/windows/mounts/users ]] || exit 0

if ! grep -q '^unlock_unmounted_anchor() {' /usr/bin/omarchy-windows-vm 2>/dev/null; then
  echo "Waiting for the omarchy package whose Windows VM launcher unlocks its mount folders" >&2
  exit 75
fi

# A private mount namespace keeps concurrent binds out of the underlying view
# and releases it even if the migration is killed before cleanup.
sudo unshare --mount --propagation private bash -euo pipefail <<'ROOT'
mounts=/var/lib/omarchy/windows/mounts

# Share the launcher's directory-inode lock without changing docker access.
lock=/run/lock/omarchy-windows-vm
if getent group docker >/dev/null 2>&1; then
  install -d -o root -g docker -m 0750 -- "$lock"
else
  install -d -o root -g root -m 0700 -- "$lock"
fi
exec {lock_fd}<"$lock/."
flock -x "$lock_fd"
[[ -d $mounts/users ]] || exit 0

work=$(mktemp -d)
view="$work/mounts"
trap 'umount -- "$view" 2>/dev/null || true; rm -f -- "$work/anchors"; rmdir -- "$view" "$work"' EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
mkdir -- "$view"
mount --bind "$mounts" "$view"
# The non-recursive bind exposes anchors, not the user's mounted VM folders.
find "$view/users" -mindepth 2 -maxdepth 2 -type d \( -name storage -o -name shared \) -print0 > "$work/anchors"
while IFS= read -r -d '' anchor; do
  contents=$(find "$anchor" -mindepth 1 -print -quit)
  if [[ -z $contents ]]; then
    chattr +i -- "$anchor" || true
  fi
done < "$work/anchors"
ROOT
