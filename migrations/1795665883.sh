echo "Lock the Windows VM's mount folders so a container started outside the launcher can't install onto them"

# omarchy-windows-vm now keeps each unmounted anchor immutable, but only from
# its next launch, and an install whose binds are mounted right now would get
# no lock before its next reboot. Lock the folders under the binds now, through
# a non-recursive, private bind of the parent: it shows them without the binds
# on top and receives no mount a launch makes meanwhile, so the user's own
# ~/.windows and ~/Windows are never touched. It holds the launcher's lock, so
# no VM action runs alongside. All users' anchors live under one root-owned
# tree, so another user's run finds them locked already.
[[ -d /var/lib/omarchy/windows/mounts/users ]] || exit 0

if ! grep -q '^unlock_unmounted_anchor() {' /usr/bin/omarchy-windows-vm 2>/dev/null; then
  echo "Waiting for the omarchy package whose Windows VM launcher unlocks its mount folders" >&2
  exit 75
fi

sudo bash -euo pipefail -c '
  lock=/run/lock/omarchy-windows-vm
  if getent group docker >/dev/null 2>&1; then
    install -d -o root -g docker -m 0750 -- "$lock"
  else
    install -d -o root -g root -m 0700 -- "$lock"
  fi
  exec {lock_fd}<"$lock/."
  flock -x "$lock_fd"

  work=$(mktemp -d)
  view="$work/mounts"
  release() {
    umount -- "$view" 2>/dev/null || true
    rm -f -- "$work/anchors"
    rmdir -- "$view" "$work" 2>/dev/null || true
  }
  trap release EXIT
  trap "exit 130" INT TERM HUP
  mkdir -- "$view"
  mount --bind --make-private /var/lib/omarchy/windows/mounts "$view"

  find "$view/users" -mindepth 2 -maxdepth 2 -type d \( -name storage -o -name shared \) -print0 > "$work/anchors"
  while IFS= read -r -d "" anchor; do
    # A mount here could only have propagated in; never lock through one.
    mountpoint -q -- "$anchor" && continue
    contents=$(find "$anchor" -mindepth 1 -print -quit)
    [[ -z $contents ]] || continue
    chattr +i -- "$anchor" || true
  done < "$work/anchors"
'
