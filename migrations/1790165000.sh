echo "Restore WPA3 support on Broadcom BCM4364 and Apple Silicon Macs"

# Broadcom BCM4364 (all T2 Macs and iMac19,x) and Apple Silicon (BCM4378/4387)
# carry modern firmware and must not have SAE disabled by Omarchy's 0x82000
# transition-mode quirk. Remove only the exact blocks written by the old
# T2 installer and the Broadcom supplicant setup. Administrator-authored
# variants remain untouched.
conf="${OMARCHY_BRCMFMAC_CONF:-/etc/modprobe.d/brcmfmac.conf}"

# Only run cleanup on Macs that carried the unneeded quirk:
# 1. T2 Macs (106b:180[12])
# 2. BCM4364 Macs (14e4:4464)
# 3. Apple Silicon Macs (14e4:(4425|4433))
if ! lspci -nn | grep -E "106b:180[12]|14e4:(4464|4425|4433)" >/dev/null; then
  exit 0
fi

[[ -f $conf ]] || exit 0

# Read through sudo so a root-only file fails the migration and gets retried
# rather than reading as empty and burning the per-user migration marker.
content="$(sudo cat "$conf")"

legacy_block='# Fix for T2 MacBook WiFi connectivity issues
options brcmfmac feature_disable=0x82000'

current_block="# Broadcom's firmware supplicant and authenticator fail the WPA four-way
# handshake on Apple hardware, which surfaces as a rejected password. Disable
# both so wpa_supplicant performs the handshake instead.
options brcmfmac feature_disable=0x82000"

if [[ $content == "$legacy_block" ]]; then
  matched_block="$legacy_block"
elif [[ $content == "$current_block" || $content == *$'\n'"$current_block" ]]; then
  matched_block="$current_block"
else
  exit 0
fi

# Request the reboot before editing because brcmfmac reads module options only
# when it loads. Do not reload it during an update carried over Wi-Fi.
omarchy-state set reboot-required

rest=${content%"$matched_block"}
while [[ $rest == *$'\n' ]]; do rest=${rest%$'\n'}; done

if [[ -z $rest ]]; then
  if [[ -L $conf ]]; then
    : | sudo tee "$conf" >/dev/null
  else
    sudo rm -f "$conf"
  fi
else
  printf '%s\n' "$rest" | sudo tee "$conf" >/dev/null
fi
