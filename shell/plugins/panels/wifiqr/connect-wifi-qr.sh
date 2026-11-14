#!/bin/bash

# Connects to a Wi-Fi network decoded from a WIFI: QR code.
# Args: <ssid> <security: WPA|SAE|WEP|OWE|nopass> <hidden: yes|no> [iface]
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

# Find a saved Wi-Fi profile for this SSID that applies to this adapter (or any
# adapter). Profiles pinned to a different interface are left untouched.
existing_uuid=""
while IFS=: read -r cand_uuid cand_type; do
  [[ $cand_type == "802-11-wireless" ]] || continue
  cand_ssid=$(nmcli --escape no --get-values 802-11-wireless.ssid connection show uuid "$cand_uuid" 2>/dev/null | head -n 1 || true)
  [[ $cand_ssid == "$ssid" ]] || continue
  cand_iface=$(nmcli --escape no --get-values connection.interface-name connection show uuid "$cand_uuid" 2>/dev/null | head -n 1 || true)
  if [[ -z $cand_iface || $cand_iface == "--" || $cand_iface == "$iface" ]]; then
    existing_uuid="$cand_uuid"
    break
  fi
done < <(LC_ALL=C nmcli -t -f UUID,TYPE connection show 2>/dev/null)

# Always verify the scanned credentials using a temporary profile first so a
# failed or stale QR code never overwrites working saved credentials.
target_uuid=$(uuidgen)
if ! nmcli connection add type wifi con-name "$ssid" ssid "$ssid" \
  connection.uuid "$target_uuid" ifname "$iface" autoconnect no \
  802-11-wireless.hidden "$hidden" >/dev/null 2>&1; then
  echo "Could not create connection profile for $ssid" >&2
  exit 1
fi

configure_security() {
  local profile_uuid="$1"
  local mode="$2"

  if [[ $mode == "open" ]]; then
    nmcli connection modify uuid "$profile_uuid" remove 802-11-wireless-security >/dev/null 2>&1 || true
    return 0
  elif [[ $mode == "owe" ]]; then
    nmcli connection modify uuid "$profile_uuid" wifi-sec.key-mgmt owe >/dev/null 2>&1
    return $?
  elif [[ $mode == "wep" ]]; then
    nmcli connection modify uuid "$profile_uuid" wifi-sec.key-mgmt none >/dev/null 2>&1 || return 1
    printf 'set 802-11-wireless-security.wep-key0 %s\nsave\nquit\n' "$password" |
      nmcli connection edit uuid "$profile_uuid" >/dev/null 2>&1
    return $?
  else
    nmcli connection modify uuid "$profile_uuid" wifi-sec.key-mgmt "$mode" >/dev/null 2>&1 || return 1
    printf 'set 802-11-wireless-security.psk %s\nsave\nquit\n' "$password" |
      nmcli connection edit uuid "$profile_uuid" >/dev/null 2>&1
    return $?
  fi
}

verified_mode=""
try_mode() {
  local mode="$1"
  configure_security "$target_uuid" "$mode" || return 1
  if nmcli --wait 25 connection up uuid "$target_uuid" ifname "$iface" >/dev/null 2>&1; then
    verified_mode="$mode"
    return 0
  fi
  return 1
}

connected=0
if [[ $security == "OWE" ]]; then
  try_mode "owe" && connected=1
elif [[ $security == "nopass" ]]; then
  if try_mode "open" || try_mode "owe"; then
    connected=1
  fi
elif [[ $security == "WEP" ]]; then
  try_mode "wep" && connected=1
elif [[ $security == "SAE" ]]; then
  try_mode "sae" && connected=1
else
  if try_mode "wpa-psk" || try_mode "sae"; then
    connected=1
  fi
fi

if (( connected )); then
  # If a saved profile for this SSID and adapter already existed, update its
  # credentials in place so band pinning and custom settings are preserved,
  # then remove the temporary verification profile.
  if [[ -n $existing_uuid && $existing_uuid != "$target_uuid" ]]; then
    nmcli connection modify uuid "$existing_uuid" 802-11-wireless.hidden "$hidden" connection.autoconnect yes >/dev/null 2>&1 || true
    if configure_security "$existing_uuid" "$verified_mode" &&
      nmcli --wait 25 connection up uuid "$existing_uuid" ifname "$iface" >/dev/null 2>&1; then
      nmcli connection delete uuid "$target_uuid" >/dev/null 2>&1 || true
      exit 0
    fi
  fi
  nmcli connection modify uuid "$target_uuid" connection.autoconnect yes >/dev/null 2>&1 || true
  exit 0
fi

nmcli connection delete uuid "$target_uuid" >/dev/null 2>&1 || true
echo "Could not connect to $ssid" >&2
exit 1
