# Only augment Arch's stock service. Replacing a customized ExecStart would
# discard administrator flags or an existing -m configuration.
configure_wifi_direct() {
  local config=/etc/wpa_supplicant/wifi-direct-pc.conf
  local dropin=/etc/systemd/system/wpa_supplicant.service.d/50-wifi-direct-pc.conf
  local defaults="$OMARCHY_PATH/default"
  local stock='ExecStart=/usr/bin/wpa_supplicant -u -s -O /run/wpa_supplicant'
  local file

  if cmp -s "$config" "$defaults/wpa_supplicant/wifi-direct-pc.conf" &&
    cmp -s "$dropin" "$defaults/systemd/wpa_supplicant.service.d/50-wifi-direct-pc.conf"; then
    return 0
  fi

  for file in "$config" "$dropin"; do
    if [[ -e $file || -L $file ]]; then
      if [[ $file == "$config" && ! -L $file ]] && cmp -s "$file" "$defaults/wpa_supplicant/wifi-direct-pc.conf"; then
        continue
      fi
      if [[ $file == "$dropin" && ! -L $file ]] && cmp -s "$file" "$defaults/systemd/wpa_supplicant.service.d/50-wifi-direct-pc.conf"; then
        continue
      fi
      echo "Preserving existing Wi-Fi Direct configuration: $file"
      echo "For LG full-screen sharing, set device_type=1-0050F204-1 in the configuration loaded by wpa_supplicant -m."
      return 0
    fi
  done

  if [[ ! -f /usr/lib/systemd/system/wpa_supplicant.service ]] ||
    [[ $(grep '^ExecStart=' /usr/lib/systemd/system/wpa_supplicant.service) != "$stock" ]]; then
    echo "Preserving non-stock wpa_supplicant service; add the Wi-Fi Direct -m configuration manually."
    return 0
  fi

  # Include runtime overrides and type-wide service drop-ins as well as the
  # usual administrator directory. Never replace a custom or masked unit.
  for file in /etc/systemd/system/wpa_supplicant.service /run/systemd/system/wpa_supplicant.service \
    /{etc,run,usr/lib}/systemd/system/{wpa_supplicant.service,service}.d/*.conf; do
    [[ $file == "$dropin" ]] && continue
    if [[ -e $file || -L $file ]]; then
      if [[ $file == */wpa_supplicant.service ]] || grep -Eq '^[[:space:]]*ExecStart[[:space:]]*=' "$file"; then
        echo "Preserving custom wpa_supplicant service flags in $file; add -m manually."
        return 0
      fi
    fi
  done

  install -Dm644 "$defaults/wpa_supplicant/wifi-direct-pc.conf" "$config"
  install -Dm644 "$defaults/systemd/wpa_supplicant.service.d/50-wifi-direct-pc.conf" "$dropin"
  echo "Wi-Fi Direct PC identity installed; reboot to activate it."
  echo "To activate now, run sudo systemctl daemon-reload and sudo systemctl restart wpa_supplicant. Restarting temporarily disconnects Wi-Fi."
}

configure_wifi_direct
