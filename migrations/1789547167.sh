echo "Import saved iwd Wi-Fi networks into NetworkManager"

# The Quattro upgrade swaps iwd for NetworkManager but left every saved network
# behind in /var/lib/iwd, so machines rebooted into Omarchy 4 with no Wi-Fi
# passwords (#8996). Recreate open and WPA-Personal networks as NetworkManager
# profiles. The iwd store is left untouched.
iwd_dir="${OMARCHY_IWD_DIR:-/var/lib/iwd}"
nm_dir="${OMARCHY_NM_CONNECTIONS_DIR:-/etc/NetworkManager/system-connections}"
machine_marker="${OMARCHY_IWD_IMPORT_MARKER:-/var/lib/omarchy/migrations/1789547167}"

# The import is machine-wide, so a second user must not bring back a network the
# first user deleted after it was imported. Fresh installs never had iwd.
[[ ! -e $machine_marker ]] || exit 0
[[ -d $iwd_dir ]] || exit 0

# Prints the settings this import reads as tab-separated group, key and raw
# value, following ell's parser: lines starting with a blank or # are skipped and
# blanks after = are dropped, while escapes stay for the caller to decode.
read_iwd_settings() {
  awk '
    /^[ \t#]/ { next }
    /^\[/ { group = substr($0, 2, index($0, "]") - 2); next }
    index($0, "=") > 1 {
      key = substr($0, 1, index($0, "=") - 1)
      value = substr($0, index($0, "=") + 1)
      sub(/[ \t]+$/, "", key)
      sub(/^[ \t]+/, "", value)
      printf "%s\t%s\t%s\n", group, key, value
    }
  '
}

# ell and NetworkManager's keyfiles share the \s \n \t \r \\ escapes, but only
# ell keeps a value's trailing blanks, so decode the passphrase and escape every
# blank again. WPA passphrases are 8-63 printable ASCII characters.
keyfile_passphrase() {
  LC_ALL=C awk '
    {
      raw = $0; out = ""
      for (i = 1; i <= length(raw); i++) {
        c = substr(raw, i, 1)
        if (c == "\\") {
          c = substr(raw, ++i, 1)
          if (c == "s") c = " "
          else if (c != "\\") exit 1
        }
        if (c < " " || c > "~") exit 1
        out = out c
      }
      if (length(out) < 8 || length(out) > 63) exit 1
      gsub(/\\/, "\\\\", out)
      gsub(/ /, "\\s", out)
      print out
    }
  '
}

# Reads one setting from the current network's parsed settings.
setting() {
  awk -F '\t' -v group="$1" -v key="$2" '$1 == group && $2 == key { value = substr($0, length($1 $2) + 3) } END { printf "%s", value }' <<<"$settings"
}

# NetworkManager only reports the profiles it knows while it is running. When it
# is not, nothing has used it since iwd was retired, so there is nothing to match.
nm_running=false
known_ssids=()
if nmcli -t general status >/dev/null 2>&1; then
  nm_running=true
  while IFS=: read -r type uuid; do
    [[ $type == "802-11-wireless" ]] || continue
    known_ssids+=("$(nmcli --escape no -g 802-11-wireless.ssid connection show "$uuid")")
  done < <(nmcli -t -f TYPE,UUID connection show)
fi

imported=()
mapfile -t network_files < <(sudo find "$iwd_dir" -maxdepth 1 -type f \( -name '*.psk' -o -name '*.open' -o -name '*.8021x' \) -printf '%f\n' | sort)

for network_file in "${network_files[@]}"; do
  security=${network_file##*.}
  encoded_name=${network_file%.*}

  # iwd names a file after its SSID when that is only letters, digits, spaces,
  # _ and -, and after = and the hex-encoded SSID otherwise.
  if [[ $encoded_name == =* ]]; then
    ssid_hex=${encoded_name#=}
  else
    ssid_hex=$(printf '%s' "$encoded_name" | od -An -v -tx1 | tr -d ' \n')
  fi
  if [[ ! $ssid_hex =~ ^([0-9a-fA-F]{2}){1,32}$ ]]; then
    echo "Skipping $network_file: not a saved iwd network name"
    continue
  fi
  ssid_hex=${ssid_hex,,}

  # A NUL or trailing newline cannot survive in a shell string; those SSIDs get a
  # hex name instead, and the profile still carries their exact bytes.
  ssid=$(printf '%b' "$(sed 's/../\\x&/g' <<<"$ssid_hex")" 2>/dev/null)
  if [[ $(printf '%s' "$ssid" | od -An -v -tx1 | tr -d ' \n') == "$ssid_hex" ]] &&
    printf '%s' "$ssid" | iconv -f UTF-8 -t UTF-8 >/dev/null 2>&1; then
    connection_name=$ssid
  else
    connection_name="Wi-Fi $ssid_hex"
  fi

  if [[ $security == "8021x" ]]; then
    echo "Skipping $connection_name: add enterprise networks again from the Wi-Fi menu"
    continue
  fi

  already_known=false
  for known_ssid in "${known_ssids[@]}"; do
    [[ $known_ssid == "$ssid" ]] && already_known=true
  done
  profile="$nm_dir/iwd-$ssid_hex.nmconnection"
  if [[ $already_known == true ]] || sudo test -e "$profile"; then
    continue
  fi

  settings=$(sudo cat "$iwd_dir/$network_file" | read_iwd_settings)

  ssid_bytes=""
  for ((i = 0; i < ${#ssid_hex}; i += 2)); do
    ssid_bytes+="$((16#${ssid_hex:i:2}));"
  done

  wifi_security=""
  if [[ $security == "psk" ]]; then
    if passphrase=$(setting Security Passphrase | keyfile_passphrase) && [[ -n $passphrase ]]; then
      psk=$passphrase
    elif [[ $(setting Security PreSharedKey) =~ ^[0-9a-fA-F]{64}$ ]]; then
      psk=$(setting Security PreSharedKey)
    else
      echo "Skipping $connection_name: no usable saved password"
      continue
    fi
    # iwd uses one .psk file for WPA2 and WPA3 alike. wpa-psk joins WPA2 and
    # transition networks; a WPA3-only network has to be joined again.
    wifi_security=$'\n[wifi-security]\nkey-mgmt=wpa-psk\npsk='"$psk"$'\n'
  fi

  autoconnect=true
  [[ $(setting Settings AutoConnect) == "false" ]] && autoconnect=false
  hidden=false
  [[ $(setting Settings Hidden) == "true" ]] && hidden=true

  if grep -Eq $'^(IPv4|IPv6)\t|^Settings\t(AddressOverride|AlwaysRandomizeAddress)\t' <<<"$settings"; then
    echo "Importing $connection_name without its custom addressing; set that again in NetworkManager"
  fi

  # nmcli sets the name with keyfile escaping and rejects a profile that
  # NetworkManager could not load. Secrets only ever travel through pipes.
  keyfile=$(printf '[connection]\nuuid=%s\ntype=wifi\nautoconnect=%s\n\n[wifi]\nmode=infrastructure\nssid=%s\nhidden=%s\n%s\n[ipv4]\nmethod=auto\n\n[ipv6]\nmethod=auto\n' \
    "$(cat /proc/sys/kernel/random/uuid)" "$autoconnect" "$ssid_bytes" "$hidden" "$wifi_security" |
    nmcli --offline connection modify connection.id "$connection_name") || {
    echo "Skipping $connection_name: NetworkManager rejected the converted profile"
    continue
  }

  printf '%s\n' "$keyfile" | sudo install -D -m 600 /dev/stdin "$profile"
  imported+=("$profile")
  echo "Imported $connection_name"
done

# A stopped NetworkManager reads the new profiles when it starts. During the live
# Quattro upgrade iwd still carries the connection, and an autoconnecting profile
# would have NetworkManager fight it for the adapter, so leave those to the reboot.
if (( ${#imported[@]} > 0 )) && [[ $nm_running == true && ${OMARCHY_UPGRADE_TO_QUATTRO_LIVE:-0} != "1" ]]; then
  sudo nmcli connection load "${imported[@]}"
fi

sudo install -Dm644 /dev/null "$machine_marker"
