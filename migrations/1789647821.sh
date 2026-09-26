echo "Clear the eight-second enterprise Wi-Fi auth timeout"

# Old panel joins pinned 802-1x.auth-timeout to 8 (#12270). Reset those
# wpa-eap profiles to 0 (NetworkManager global default). Idempotent.
# A failed connection list must exit non-zero so omarchy-migrate leaves the
# marker unset and retries later instead of treating "NM down" as "nothing to do".

if ! connections=$(nmcli -t -f UUID,TYPE connection show); then
  echo "Could not list NetworkManager connections; leaving migration pending." >&2
  exit 1
fi

while IFS=: read -r uuid type; do
  [[ $type == "802-11-wireless" ]] || continue
  [[ -n $uuid ]] || continue

  key=$(nmcli -g 802-11-wireless-security.key-mgmt connection show uuid "$uuid" 2>/dev/null || true)
  [[ $key == "wpa-eap" ]] || continue

  timeout=$(nmcli -g 802-1x.auth-timeout connection show uuid "$uuid" 2>/dev/null || true)
  [[ $timeout == "8" ]] || continue

  nmcli connection modify uuid "$uuid" 802-1x.auth-timeout 0 >/dev/null
done <<< "$connections"
