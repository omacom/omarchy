echo "Take the T2 Mac packages from the Omarchy repository"

# Omarchy builds linux-t2 and the T2 support packages in its own repository
# now, so the extra repository T2 installs used to add is no longer needed.
# Done once per machine; other users find the marker.
marker="${OMARCHY_T2_REPO_MARKER:-/var/lib/omarchy/migrations/1794859637}"
[[ ! -e $marker ]] || exit 0

pacman_conf=/etc/pacman.conf
old_repo=arch-mact2
t2_packages=(linux-t2 linux-t2-headers apple-t2-audio-config apple-bcm-firmware-fetcher t2fanrd)

repos=$(pacman-conf --repo-list)
grep -qx "$old_repo" <<<"$repos" || exit 0

# Every installed T2 package must come from [omarchy]. Reinstall them from
# there by name first, while the old repository is still configured, so a
# failed transaction leaves this migration pending with nothing removed.
targets=()
for pkg in "${t2_packages[@]}"; do
  pacman -Q -- "$pkg" &>/dev/null || continue
  if ! pacman -Si "omarchy/$pkg" &>/dev/null; then
    echo "omarchy/$pkg is not available on this channel yet; leaving the $old_repo repository in place" >&2
    exit 1
  fi
  targets+=("omarchy/$pkg")
done
if (( ${#targets[@]} )); then
  sudo pacman -S --noconfirm "${targets[@]}"
fi

# Drop the section the way pacman reads headers: trimmed of whitespace and
# carriage returns, a line in brackets starts a section.
new_conf=$(sudo mktemp /etc/pacman.conf.XXXXXX)
sudo chmod 644 "$new_conf"
sudo awk -v drop="[$old_repo]" '
  { header = $0; gsub(/^[[:space:]]+|[[:space:]]+$/, "", header) }
  header ~ /^\[.*\]$/ { skip = (header == drop) }
  !skip
' "$pacman_conf" | sudo tee "$new_conf" >/dev/null

expected=$(grep -vx "$old_repo" <<<"$repos")
if [[ $(pacman-conf --config "$new_conf" --repo-list) != "$expected" ]]; then
  sudo rm -f "$new_conf"
  echo "Could not remove [$old_repo] from $pacman_conf by itself; remove it by hand and rerun omarchy-migrate" >&2
  exit 1
fi

[[ -e $pacman_conf.bak-t2 ]] || sudo cp -p "$pacman_conf" "$pacman_conf.bak-t2"
sudo mv -f "$new_conf" "$pacman_conf"
sudo install -Dm644 /dev/null "$marker"
