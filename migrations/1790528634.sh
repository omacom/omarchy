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
  ' "$config_file" >"$tmp"
  mv "$tmp" "$config_file"
fi

# Dev checkouts found the packaged plugin through this link; one the user made
# elsewhere is left alone.
user_plugin="$HOME/.config/omarchy/plugins/omacom.elsewhen"
if [[ -L $user_plugin && $(readlink "$user_plugin") == /usr/share/omarchy/* ]]; then
  rm "$user_plugin"
fi

rm -rf "${XDG_CACHE_HOME:-$HOME/.cache}/omacom-elsewhen"

# Checkouts that installed elsewhen before it moved here got the omarchy package
# as its dependency, and dropping elsewhen recursively would remove the desktop.
mapfile -t core_packages < <(pacman -Qqd omarchy omarchy-settings 2>/dev/null)

if (( ${#core_packages[@]} )); then
  sudo pacman -D --asexplicit "${core_packages[@]}"
fi

omarchy-pkg-drop elsewhen
