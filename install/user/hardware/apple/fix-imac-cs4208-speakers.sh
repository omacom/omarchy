# Late 2015 21.5-inch iMacs (iMac16,1 / iMac16,2) drive the built-in speakers
# as four digital CS4208 channels. Analog Stereo is the headphone DAC and is
# silent on those speakers, and Master hardware volume does not affect them.

if omarchy-hw-imac-cs4208; then
  config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
  state_home="${XDG_STATE_HOME:-$HOME/.local/state}"
  source_config="$OMARCHY_PATH/default/wireplumber/wireplumber.conf.d/imac-cs4208-speakers.conf"
  target_config="$config_home/wireplumber/wireplumber.conf.d/imac-cs4208-speakers.conf"
  if [[ -e $target_config || -L $target_config ]]; then
    if [[ -L $target_config || ! -f $target_config ]] || ! cmp -s "$source_config" "$target_config"; then
      echo "Preserving customized audio configuration: $target_config; reconcile it manually before retrying." >&2
      return 1
    fi
    return 0
  fi
  routes="$state_home/wireplumber/default-routes"
  if [[ -e $routes || -L $routes ]]; then
    if [[ -e $routes.pre-omarchy-cs4208 || -L $routes.pre-omarchy-cs4208 ]]; then
      echo "Preserving both existing routes and backup: $routes; reconcile them manually before retrying." >&2
      return 1
    fi
    mv -T "$routes" "$routes.pre-omarchy-cs4208" || return 1
  fi
  install -Dm644 "$source_config" "$target_config"

  # Leave the hardware mixer wide open so software volume is the only attenuation.
  card=$(aplay -l 2>/dev/null | grep -i "CS4208 Analog" | head -1 | sed 's/card \([0-9]*\).*/\1/')
  if [[ -n $card ]]; then
    amixer -c "$card" set Master 100% unmute 2>/dev/null || true
    amixer -c "$card" set PCM 100% 2>/dev/null || true
  fi
fi
