# BCM4350 and BCM43602 Macs can associate without passing traffic until given
# a country hint. Supply it when cfg80211 loads, rather than relying only on
# wireless-regdb's module-add udev rule or country hints from access points.
sys_vendor="$(cat /sys/class/dmi/id/sys_vendor 2>/dev/null || true)"

if [[ $sys_vendor == Apple* ]] &&
  lspci -nn | grep -E '14e4:(43a3|43ba|43bb|43bc)' >/dev/null; then
  # set-wireless-regdom.sh runs first and derives the country from the target
  # timezone only when no country is already configured. Reuse that choice;
  # UTC or an unknown timezone must not turn into a hard-coded country.
  regdom_file=/etc/conf.d/wireless-regdom
  [[ -f $regdom_file ]] || return 0
  country=$(
    unset WIRELESS_REGDOM
    source "$regdom_file"
    printf '%s' "${WIRELESS_REGDOM:-}"
  )
  [[ $country =~ ^[A-Z]{2}$ ]] || return 0

  # Respect administrator overrides in any modprobe drop-in. This also makes
  # rerunning hardware setup a no-op once this quirk has been installed.
  if modprobe --showconfig | grep -E '^options cfg80211 .*\bieee80211_regdom=' >/dev/null; then
    return 0
  fi

  echo "Detected Apple Broadcom Wi-Fi; setting the boot regulatory domain to $country"
  # The ISO builds the final boot image after hardware setup; its modconf hook
  # includes this drop-in if cfg80211 is needed in the initramfs.
  mkdir -p /etc/modprobe.d
  printf '%s\n' \
    '# Country selected during installation for Apple BCM4350/BCM43602 Wi-Fi.' \
    "options cfg80211 ieee80211_regdom=$country" > /etc/modprobe.d/omarchy-brcmfmac-regdom.conf
fi
