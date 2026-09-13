echo "Load the live keybindings registry into the current Hyprland session"

# Existing installs already load bootstrap.lua; no user configuration rewrite
# is needed. Offline upgrades pick up the registry at the next login.
if [[ -n ${HYPRLAND_INSTANCE_SIGNATURE:-} ]]; then
  hyprctl reload
fi
