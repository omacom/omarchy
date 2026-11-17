echo "Take the Apple Silicon packages from Omarchy instead of the Asahi ALARM repository"

# Omarchy builds every package Apple Silicon took from [asahi-alarm] in its own
# repository now: aurora-scripts and aurora-fwextract replace asahi-scripts and
# asahi-fwextract, and the others keep their names at a higher pkgrel. Installed
# Macs drop that repository, its keyring and its signing key. Done once per
# machine; other users find the marker.
omarchy-hw-aarch64-apple || exit 0

marker="${OMARCHY_ASAHI_ALARM_MARKER:-/var/lib/omarchy/migrations/1794947255}"
[[ ! -e $marker ]] || exit 0

pacman_conf="${OMARCHY_ASAHI_ALARM_PACMAN_CONF:-/etc/pacman.conf}"
old_repo=asahi-alarm
keyring=asahi-alarm-keyring
key=12CE6799A94A3F1B5DDFFE88F576553597FB8FEB
# Each package Omarchy builds in place of asahi-alarm's, as old:new.
imports=(asahi-scripts:aurora-scripts asahi-fwextract:aurora-fwextract lzfse:lzfse
  speakersafetyd:speakersafetyd bankstown:bankstown triforce-lv2:triforce-lv2
  widevine:widevine muvm:muvm FEX-Emu:fex-emu)

repos=$(pacman-conf --config "$pacman_conf" --repo-list)
if ! grep -qx "$old_repo" <<<"$repos" && ! pacman -Q -- "$keyring" &>/dev/null; then
  exit 0
fi

if grep -qx "$old_repo" <<<"$repos"; then
  # Every installed import must have its Omarchy build on this channel before
  # the old repository goes, so a channel that doesn't carry them yet leaves this
  # migration pending with nothing changed.
  for import in "${imports[@]}"; do
    pacman -Q -- "${import%%:*}" &>/dev/null || continue
    if ! pacman -Si "omarchy/${import#*:}" &>/dev/null; then
      echo "omarchy/${import#*:} is not available on this channel yet; leaving the $old_repo repository in place" >&2
      exit 1
    fi
  done
  from_old_repo=$(comm -12 <(pacman -Slq "$old_repo" | sort -u) <(pacman -Qq | sort))

  # Drop the section the way pacman reads headers: trimmed of whitespace and
  # carriage returns, a line in brackets starts a section.
  new_conf=$(sudo mktemp "$pacman_conf.XXXXXX")
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

  [[ -e $pacman_conf.bak-asahi-alarm ]] || sudo cp -p "$pacman_conf" "$pacman_conf.bak-asahi-alarm"
  sudo mv -f "$new_conf" "$pacman_conf"
fi

# Upgrade against the repositories that remain, so the aurora-* replacements
# and the higher-pkgrel Omarchy builds take over. Run this even when the
# section is already gone, so a failed upgrade is retried.
omarchy-update-system-pkgs

# Anything else asahi-alarm carried, such as steam and its FEX rootfs, stays
# installed but gets no more updates.
left_behind=$(comm -12 <(grep -vx "$keyring" <<<"${from_old_repo:-}" || true) <(pacman -Qqm | sort))
if [[ -n $left_behind ]]; then
  echo "No longer updated, since only [$old_repo] carried them:" $left_behind
fi

# The keyring goes only when nothing requires it any more: omarchy-mac and
# omarchy-mac-boot required it before their keyring-free builds. Its key is
# deleted with it; pacman never removes a key when a keyring package goes.
if pacman -Q -- "$keyring" &>/dev/null; then
  required_by=$(LC_ALL=C pacman -Qi -- "$keyring" | sed -n 's/^Required By *: //p')
  if [[ $required_by != "None" ]]; then
    echo "Keeping $keyring and its key: $required_by still requires it"
    exit 0
  fi
fi
if sudo pacman-key --list-keys "$key" &>/dev/null; then
  sudo pacman-key --delete "$key"
fi
omarchy-pkg-drop "$keyring"

sudo install -Dm644 /dev/null "$marker"
