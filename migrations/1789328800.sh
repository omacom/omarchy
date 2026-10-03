echo "Load the live keybindings registry into the current Hyprland session"

# Hand-edited entrypoints can still set package.path themselves. Explain the
# required bootstrap without guessing where it belongs in arbitrary Lua.
config="$HOME/.config/hypr/hyprland.lua"
if [[ -f $config ]] && ! grep -Fq '/default/hypr/bootstrap.lua' "$config"; then
  echo "Keybindings menu: add this line before any bindings or module imports in $config, then reload Hyprland:"
  echo 'dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/bootstrap.lua")'
fi

# Offline upgrades take effect at login. An inherited signature may refer to
# an exited compositor; that must not block the remaining migrations.
if [[ -n ${HYPRLAND_INSTANCE_SIGNATURE:-} ]]; then
  hyprctl reload >/dev/null 2>&1 || true
fi
