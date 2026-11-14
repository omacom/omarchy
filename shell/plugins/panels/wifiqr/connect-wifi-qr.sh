#!/bin/bash

# Connects to a Wi-Fi network decoded from a WIFI: QR code.
# Args: <ssid> <security: WPA|SAE|WEP|nopass> <hidden: yes|no> [iface]
# Password is read from stdin so it never appears in process argv (/proc).

set -uo pipefail

ssid="${1:-}"
security="${2:-WPA}"
hidden="${3:-no}"
iface="${4:-}"

password=""
IFS= read -r password || true

if [[ -z $ssid ]]; then
  echo "Missing Wi-Fi network name" >&2
  exit 1
fi

if [[ $(LC_ALL=C nmcli radio wifi 2>/dev/null || true) != "enabled" ]]; then
  nmcli radio wifi on >/dev/null 2>&1 || true
  for ((i = 0; i < 25; i++)); do
    state=$(LC_ALL=C nmcli -t -f TYPE,STATE device status 2>/dev/null | awk -F: '$1 == "wifi" { print $2; exit }')
    [[ -n $state && $state != "unavailable" && $state != "unmanaged" ]] && break
    sleep 0.1
  done
fi

if [[ -z $iface ]]; then
  iface=$(LC_ALL=C nmcli -t -f DEVICE,TYPE device status 2>/dev/null | awk -F: '$2 == "wifi" { print $1; exit }')
fi

if [[ -z $iface ]]; then
  echo "No Wi-Fi adapter available" >&2
  exit 1
fi

# Check if already connected to the target SSID on this interface.
active_uuid=$(nmcli --get-values GENERAL.CON-UUID device show "$iface" 2>/dev/null | head -n 1 || true)
if [[ -n $active_uuid && $active_uuid != "--" ]]; then
  active_ssid=$(nmcli --escape no --get-values 802-11-wireless.ssid connection show uuid "$active_uuid" 2>/dev/null | head -n 1 || true)
  if [[ $active_ssid == "$ssid" ]]; then
    exit 0
  fi
fi

# Trigger a scan for the target SSID so newly enabled hotspots or hidden APs are found.
nmcli device wifi rescan ifname "$iface" ssid "$ssid" >/dev/null 2>&1 ||
  nmcli device wifi rescan ifname "$iface" >/dev/null 2>&1 || true
sleep 0.4

# Find if a saved Wi-Fi profile already exists for this SSID.
existing_uuid=""
while IFS=: read -r cand_uuid cand_type; do
  [[ $cand_type == "802-11-wireless" ]] || continue
  cand_ssid=$(nmcli --escape no --get-values 802-11-wireless.ssid connection show uuid "$cand_uuid" 2>/dev/null | head -n 1 || true)
  if [[ $cand_ssid == "$ssid" ]]; then
    existing_uuid="$cand_uuid"
    break
  fi
done < <(LC_ALL=C nmcli -t -f UUID,TYPE connection show 2>/dev/null)

if [[ $security == "nopass" ]]; then
  if [[ -n $existing_uuid ]]; then
    nmcli connection modify uuid "$existing_uuid" 802-11-wireless.hidden "$hidden" >/dev/null 2>&1 || true
    if nmcli --wait 25 connection up uuid "$existing_uuid" ifname "$iface" >/dev/null 2>&1; then
      exit 0
    fi
  fi
  if nmcli --wait 25 device wifi connect "$ssid" ifname "$iface" hidden "$hidden" >/dev/null 2>&1; then
    exit 0
  fi
  echo "Could not connect to $ssid" >&2
  exit 1
fi

created_new=0
target_uuid="$existing_uuid"
if [[ -z $target_uuid ]]; then
  target_uuid=$(uuidgen)
  created_new=1
  if ! nmcli connection add type wifi con-name "$ssid" ssid "$ssid" \
    connection.uuid "$target_uuid" ifname "$iface" autoconnect no \
    802-11-wireless.hidden "$hidden" >/dev/null 2>&1; then
    echo "Could not create connection profile for $ssid" >&2
    exit 1
  fi
else
  nmcli connection modify uuid "$target_uuid" 802-11-wireless.hidden "$hidden" >/dev/null 2>&1 || true
fi

try_activate_psk() {
  local key_mgmt="$1"
  nmcli connection modify uuid "$target_uuid" wifi-sec.key-mgmt "$key_mgmt" connection.autoconnect yes >/dev/null 2>&1 || return 1
  printf 'set 802-11-wireless-security.psk %s\nsave\nquit\n' "$password" |
    nmcli connection edit uuid "$target_uuid" >/dev/null 2>&1 || return 1
  nmcli --wait 25 connection up uuid "$target_uuid" ifname "$iface" >/dev/null 2>&1
}

if [[ $security == "WEP" ]]; then
  nmcli connection modify uuid "$target_uuid" wifi-sec.key-mgmt none >/dev/null 2>&1 || true
  printf 'set 802-11-wireless-security.wep-key0 %s\nsave\nquit\n' "$password" |
    nmcli connection edit uuid "$target_uuid" >/dev/null 2>&1 || true
  if nmcli --wait 25 connection up uuid "$target_uuid" ifname "$iface" >/dev/null 2>&1; then
    exit 0
  fi
elif [[ $security == "SAE" ]]; then
  if try_activate_psk "sae" || try_activate_psk "wpa-psk"; then
    exit 0
  fi
else
  if try_activate_psk "wpa-psk" || try_activate_psk "sae"; then
    exit 0
  fi
fi

if (( created_new )); then
  nmcli connection delete uuid "$target_uuid" >/dev/null 2>&1 || true
fi

echo "Could not connect to $ssid" >&2
exit 1
