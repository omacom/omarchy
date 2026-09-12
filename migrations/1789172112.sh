echo "Remove the Intel Broadcom workaround from affected Apple Silicon Macs"

omarchy-hw-apple-silicon || exit 0
lspci -nn | grep -E '14e4:(4425|4433)' >/dev/null || exit 0

conf="${OMARCHY_BRCMFMAC_CONF:-/etc/modprobe.d/brcmfmac.conf}"
pending="${OMARCHY_BRCMFMAC_PENDING:-/var/lib/omarchy/migrations/1789172112-initramfs-pending}"
block="# Broadcom's firmware supplicant and authenticator fail the WPA four-way
# handshake on Apple hardware, which surfaces as a rejected password. Disable
# both so wpa_supplicant performs the handshake instead.
options brcmfmac feature_disable=0x82000"

if [[ -e $conf ]]; then
  content="$(sudo cat "$conf")"
  matched=false
  if [[ $content == "$block" ]]; then
    rest=""
    matched=true
  elif [[ $content == *$'\n'"$block" ]]; then
    rest="${content%$'\n'"$block"}"
    matched=true
  fi

  if $matched; then
    # Record the rebuild obligation before changing the config. It survives a
    # failed rebuild, an interrupted run, and a retry by another user.
    sudo install -Dm644 /dev/null "$pending"
    omarchy-state set reboot-required
    if [[ -n $rest ]]; then
      printf '%s\n' "$rest" | sudo tee "$conf" >/dev/null
    elif [[ -L $conf ]]; then
      sudo tee "$conf" </dev/null >/dev/null
    else
      sudo rm -- "$conf"
    fi
  fi
fi

[[ -f $pending ]] || exit 0
omarchy-state set reboot-required
sudo mkinitcpio -P
sudo rm -- "$pending"
