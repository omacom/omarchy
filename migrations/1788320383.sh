echo "Restore WPA3 support on Broadcom BCM4364 T2 Macs"

# BCM4364 firmware on T2 Macs requires firmware SAE offload for WPA3-only
# networks. Omarchy's 0x82000 quirk disables SAE (bit 19), so remove only the
# exact blocks written by the old T2 installer and the current Broadcom setup.
# Administrator-authored variants remain untouched.
conf="${OMARCHY_BRCMFMAC_CONF:-/etc/modprobe.d/brcmfmac.conf}"

lspci -nn | grep "106b:180[12]" >/dev/null || exit 0
lspci -nn | grep "14e4:4464" >/dev/null || exit 0
[[ -f $conf ]] || exit 0

# Read through sudo so a root-only file fails the migration and gets retried
# rather than reading as empty and burning the per-user migration marker. The
# sentinel keeps the trailing newlines that command substitution would strip.
content="$(sudo cat "$conf" && printf x)" || exit 1
content=${content%x}

legacy_block='# Fix for T2 MacBook WiFi connectivity issues
options brcmfmac feature_disable=0x82000'

current_block="# Broadcom's firmware supplicant and authenticator fail the WPA four-way
# handshake on Apple hardware, which surfaces as a rejected password. Disable
# both so wpa_supplicant performs the handshake instead.
options brcmfmac feature_disable=0x82000"

# Match whole lines only, wherever a block sits and however often it repeats.
# Padding with newlines gives the first and last lines a boundary to match on.
# The blank line 1786391100.sh put before its appended block goes with it.
rest=$'\n'"$content"$'\n'
previous=""
while [[ $rest != "$previous" ]]; do
  previous=$rest
  for block in "$current_block" "$legacy_block"; do
    rest=${rest//$'\n\n'"$block"$'\n'/$'\n'}
    rest=${rest//$'\n'"$block"$'\n'/$'\n'}
  done
done
rest=${rest#$'\n'}
rest=${rest%$'\n'}

[[ $rest != "$content" ]] || exit 0

# Request the reboot before editing because brcmfmac reads module options only
# when it loads. Do not reload it during an update carried over Wi-Fi.
omarchy-state set reboot-required

if [[ -z ${rest//[[:space:]]/} ]]; then
  if [[ -L $conf ]]; then
    : | sudo tee "$conf" >/dev/null
  else
    sudo rm -f "$conf"
  fi
else
  printf '%s' "$rest" | sudo tee "$conf" >/dev/null
fi
