echo "Restrict /boot so it is not world-accessible"

if [[ -d /boot ]]; then
  sudo chmod 0700 /boot || true
fi

if [[ -e /boot/loader/random-seed ]]; then
  sudo chmod 0600 /boot/loader/random-seed || true
fi

if [[ -f /etc/fstab ]] && grep -Eq '[[:space:]]/boot[[:space:]]+vfat[[:space:]]' /etc/fstab; then
  if ! grep -Eq '[[:space:]]/boot[[:space:]]+vfat[[:space:]][^[:space:]]*(fmask|dmask)' /etc/fstab; then
    tmp=$(mktemp)
    sudo cp /etc/fstab /etc/fstab.omarchy-boot-perms.bak
    awk '
      $2 == "/boot" && $3 == "vfat" && $4 !~ /fmask=/ {
        if ($4 == "defaults") $4 = "defaults,fmask=0077,dmask=0077"
        else $4 = $4 ",fmask=0077,dmask=0077"
      }
      { print }
    ' /etc/fstab >"$tmp"
    sudo install -Dm644 "$tmp" /etc/fstab
    rm -f "$tmp"
    echo "Updated /boot vfat fstab options (backup: /etc/fstab.omarchy-boot-perms.bak)"
  fi
fi
