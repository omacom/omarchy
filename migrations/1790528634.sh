echo "Move Elsewhen, the world clock, into Omarchy as omarchy.elsewhen"

# The widget keeps its entry, and with it the cities and settings stored there.
config_file="$HOME/.config/omarchy/shell.json"
if [[ -s $config_file ]]; then
  tmp=$(mktemp)
  jq '
    def rename:
      if . == "omacom.elsewhen" then "omarchy.elsewhen"
      elif type == "object" and .id == "omacom.elsewhen" then .id = "omarchy.elsewhen"
      end;

    if (.bar.layout | type) == "object" then .bar.layout |= map_values(if type == "array" then map(rename) end) end
    | if (.bar.centerAnchor | type) == "string" then .bar.centerAnchor |= rename end
    | if (.plugins | type) == "array" then .plugins |= map(rename) end
    | if (.disabledPlugins | type) == "array" then .disabledPlugins |= map(rename) end
  ' "$config_file" >"$tmp" || { rm -f "$tmp"; exit 1; }
  if ! jq -e --slurpfile new "$tmp" '. == $new[0]' "$config_file" >/dev/null; then
    omarchy-config-replace "$tmp" "$config_file" || { rm -f "$tmp"; exit 1; }
  fi
  rm -f "$tmp"
fi

# Dev checkouts found the packaged plugin through this link; one the user made
# elsewhere is left alone.
user_plugin="$HOME/.config/omarchy/plugins/omacom.elsewhen"
if [[ -L $user_plugin && $(readlink "$user_plugin") == /usr/share/omarchy/* ]]; then
  rm "$user_plugin"
fi

rm -rf "${XDG_CACHE_HOME:-$HOME/.cache}/omacom-elsewhen"

omarchy-pkg-drop elsewhen
