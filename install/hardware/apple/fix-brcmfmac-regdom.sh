# BCM4350 and BCM43602 Macs can associate without passing traffic until given
# a country hint. Supply it when cfg80211 loads, rather than relying only on
# wireless-regdb's module-add udev rule or country hints from access points.
sys_vendor="$(cat /sys/class/dmi/id/sys_vendor 2>/dev/null || true)"

if [[ $sys_vendor == Apple* ]] &&
  lspci -nn | grep -E '14e4:(43a3|43ba|43bb|43bc)' >/dev/null; then
  # Sort before administrator drop-ins so later choices take precedence.
  boot_conf=/etc/modprobe.d/00-omarchy-brcmfmac-regdom.conf
  legacy_conf=/etc/modprobe.d/omarchy-brcmfmac-regdom.conf
  owned_configs=()
  owned_options=()
  boot_conf_owned=false
  for config in "$boot_conf" "$legacy_conf"; do
    # Only replace/remove our exact generated files, never edited files or masks.
    [[ -f $config && ! -L $config ]] || continue
    saved_country=$(sed -n 's/^options cfg80211 ieee80211_regdom=\([A-Z][A-Z]\)$/\1/p' "$config")
    [[ $saved_country =~ ^[A-Z]{2}$ ]] || continue
    if cmp -s "$config" <(printf '%s\n' \
      '# Country selected during installation for Apple BCM4350/BCM43602 Wi-Fi.' \
      "options cfg80211 ieee80211_regdom=$saved_country"); then
      owned_configs+=("$config")
      owned_options+=("options cfg80211 ieee80211_regdom=$saved_country")
      if [[ $config == "$boot_conf" ]]; then
        boot_conf_owned=true
      fi
    fi
  done

  # Keep modprobe's parsing and directory precedence. Subtract one option entry
  # per owned file; an identical entry from an administrator still counts.
  if modprobe --showconfig | awk -v ignored="$(printf '%s\n' "${owned_options[@]}")" '
    BEGIN { count = split(ignored, entries, "\n"); for (i = 1; i <= count; i++) owned[entries[i]]++ }
    ($0 in owned) && owned[$0] > 0 { owned[$0]--; next }
    { print }
  ' | grep -E '^options cfg80211 .*\bieee80211_regdom=' >/dev/null; then
    # Retire our old late-sorting file too, so it cannot override that choice.
    if (( ${#owned_configs[@]} )); then
      rm -f -- "${owned_configs[@]}"
    fi
    return 0
  fi

  # set-wireless-regdom.sh runs first and derives the country from the target
  # timezone only when no country is already configured. Reuse that choice;
  # UTC or an unknown timezone must not turn into a hard-coded country.
  regdom_file=/etc/conf.d/wireless-regdom
  country=""
  if [[ -f $regdom_file ]]; then
    country=$(
      unset WIRELESS_REGDOM
      source "$regdom_file"
      printf '%s' "${WIRELESS_REGDOM:-}"
    )
  fi
  if [[ ! $country =~ ^[A-Z]{2}$ ]]; then
    if (( ${#owned_configs[@]} )); then
      rm -f -- "${owned_configs[@]}"
    fi
    return 0
  fi

  # A file edited by an administrator (even without a country option), or a
  # /dev/null mask, is no longer ours to replace.
  if [[ -e $boot_conf || -L $boot_conf ]] &&
    [[ $boot_conf_owned != "true" ]]; then
    return 0
  fi

  echo "Detected Apple Broadcom Wi-Fi; setting the boot regulatory domain to $country"
  # The ISO builds the final boot image after hardware setup; its modconf hook
  # includes this drop-in if cfg80211 is needed in the initramfs.
  mkdir -p /etc/modprobe.d
  printf '%s\n' \
    '# Country selected during installation for Apple BCM4350/BCM43602 Wi-Fi.' \
    "options cfg80211 ieee80211_regdom=$country" > "$boot_conf"
  for config in "${owned_configs[@]}"; do
    if [[ $config == "$legacy_conf" ]]; then
      rm -f -- "$config"
    fi
  done
fi
