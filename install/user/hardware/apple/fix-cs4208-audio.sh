# Use software volume for the CS4208 speaker path on 12-inch MacBooks.

product_name="${OMARCHY_MACBOOK12_AUDIO_MODEL:-$(cat /sys/class/dmi/id/product_name 2>/dev/null)}"
if [[ $product_name == "MacBook9,1" || $product_name == "MacBook10,1" ]]; then
  config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
  state_home="${XDG_STATE_HOME:-$HOME/.local/state}"
  source_config="$OMARCHY_PATH/default/wireplumber/wireplumber.conf.d/51-macbook-cs4208-softvol.conf"
  target_config="$config_home/wireplumber/wireplumber.conf.d/51-macbook-cs4208-softvol.conf"
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

fi
