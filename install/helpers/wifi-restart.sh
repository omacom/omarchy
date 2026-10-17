#!/bin/bash

# Shared restart implementation. The privileged entry point supplies the fixed
# sysfs root; unprivileged tests source this with a fixture tree and stub tools.
wifi_restart() {
  local target="" iface driver seen=" " reload_failed=0 nm_failed=0 other state
  local -a unload=()
  if (( $# != 0 )); then
    [[ $# == 2 && $1 == "--interface" && $2 =~ ^[[:alnum:]_][[:alnum:]_.:-]{0,63}$ ]] || return 64
    target=$2
    iface="$NET_ROOT/$target"
    [[ -d $iface/wireless || -d $iface/phy80211 ]] || return 1
    [[ -L $iface/device/driver ]] || return 1
    for state in "$iface"/phy80211/rfkill*/soft "$iface"/phy80211/rfkill*/hard; do
      [[ ! -r $state || $(<"$state") == "0" ]] || return 1
    done
    driver=$(basename "$(readlink "$iface/device/driver")")
    # Module reload is shared by every physical radio using that module. Refuse
    # automatic reload when it would affect a sibling, including a blocked one.
    for other in "$NET_ROOT"/*; do
      [[ $other != "$iface" && (-d $other/wireless || -d $other/phy80211) ]] || continue
      [[ -L $other/device/driver ]] || continue
      [[ $(basename "$(readlink "$other/device/driver")") == "$driver" ]] || continue
      if [[ -e $iface/phy80211 && -e $other/phy80211 && $(readlink -f "$iface/phy80211") == "$(readlink -f "$other/phy80211")" ]]; then
        continue
      fi
      echo "Automatic Wi-Fi reload would affect another radio; use omarchy restart wifi explicitly." >&2
      return 1
    done
  fi
  echo -e "Restarting wifi...\n"

  if [[ -z $target ]]; then
    rfkill unblock wifi
  fi

  seen=" "
  reload_failed=0
  for iface in "$NET_ROOT"/*; do
    [[ -z $target || ${iface##*/} == "$target" ]] || continue
    [[ -d $iface/wireless || -d $iface/phy80211 ]] || continue
    [[ -L $iface/device/driver ]] || continue

    driver=$(basename "$(readlink "$iface/device/driver")")
    [[ -n $driver ]] || continue
    [[ $seen == *" $driver "* ]] && continue
    seen+="$driver "

    unload=()
    if [[ $driver == iwlwifi ]]; then
      # iwlmld (BE200+), iwlmvm (AX210), iwldvm and iwlmei all hold iwlwifi.
      for helper in iwlmld iwlmvm iwldvm iwlmei; do
        if lsmod | grep -q "^${helper}[[:space:]]"; then
          unload+=("$helper")
        fi
      done
    fi
    unload+=("$driver")

    echo "Reloading ${unload[*]}..."
    if ! sudo modprobe -r -- "${unload[@]}"; then
      reload_failed=1
      continue
    fi
    if ! sudo modprobe -- "$driver"; then
      # A PCI device that has just been torn down needs a moment before it
      # will take firmware again; an instant retry asks the same question.
      sleep 1
      if sudo modprobe -- "$driver"; then
        : # retry recovered the radio
      else
        reload_failed=1
        echo "omarchy-restart-wifi: $driver left unloaded; run: sudo modprobe $driver" >&2
      fi
    fi
  done

  nm_failed=0
  if [[ -n $target ]]; then
    # Automatic recovery never changes the global radio or networking switches.
    timeout "${OMARCHY_RESTART_WIFI_NM_TIMEOUT:-20}" nmcli device wifi rescan ifname "$target" 2>/dev/null || true
  else
    if ! timeout "${OMARCHY_RESTART_WIFI_NM_TIMEOUT:-20}" nmcli networking on; then nm_failed=1; fi
    if ! timeout "${OMARCHY_RESTART_WIFI_NM_TIMEOUT:-20}" nmcli radio wifi on; then nm_failed=1; fi
    nmcli device wifi rescan 2>/dev/null || true
  fi
  rfkill list wifi

  # The watcher toasts on exit 0, so a run NetworkManager refused must not
  # report success: the radio is no more back than a failed modprobe leaves it.
  if ((reload_failed != 0 || nm_failed != 0)); then
    return 1
  fi
  return 0
}
