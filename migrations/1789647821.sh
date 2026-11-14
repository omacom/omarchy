echo "Clear the eight-second enterprise Wi-Fi auth timeout"

# Old panel joins pinned 802-1x.auth-timeout to 8 (#12270). Reset those
# wpa-eap profiles to 0 (NetworkManager global default). Idempotent.
# A failed connection list or profile lookup must exit non-zero so omarchy-migrate leaves the
# marker unset and retries later instead of treating a failed lookup as "nothing to do".

# The live 3 -> 4 upgrade runs migrations before NetworkManager first starts;
# no panel profile exists yet, and failing here would abort the upgrade.
systemctl is-active --quiet NetworkManager.service || exit 0

if ! connections=$(nmcli -t -f UUID,TYPE connection show); then
  echo "Could not list NetworkManager connections; leaving migration pending." >&2
  exit 1
fi

while IFS=: read -r uuid type; do
  [[ $type == "802-11-wireless" ]] || continue
  [[ -n $uuid ]] || continue

  key=$(nmcli -g 802-11-wireless-security.key-mgmt connection show uuid "$uuid")
  [[ $key == "wpa-eap" ]] || continue

  timeout=$(nmcli -g 802-1x.auth-timeout connection show uuid "$uuid")
  [[ $timeout == "8" ]] || continue

  nmcli connection modify uuid "$uuid" 802-1x.auth-timeout 0 >/dev/null
done <<< "$connections"
