echo "Keep windows opaque where animations are turned off"

# Turning animations off used to make windows opaque too. It no longer touches
# transparency, so drop that rule from the saved flag, where it would keep
# windows opaque whatever Appearance > Window Transparency says, and carry it
# over as Window Transparency > Opaque for anyone who has not picked one yet.
# omarchy-hyprland-toggle saved flags under ~/.local/state whatever
# XDG_STATE_HOME said, while Hyprland reads them from XDG_STATE_HOME, so both
# are fixed.
for state_home in "$HOME/.local/state" "${XDG_STATE_HOME:-}"; do
  [[ -n $state_home ]] || continue
  toggles_dir="$state_home/omarchy/toggles/hypr"
  [[ -f $toggles_dir/no-animations.lua ]] || continue

  sed -i '/^o\.window("\.\*", { opacity = "1 1" })$/d' "$toggles_dir/no-animations.lua"

  if [[ ! -f $toggles_dir/window-opaque.lua && ! -f $toggles_dir/window-glassy.lua ]]; then
    cp "$OMARCHY_PATH/default/hypr/toggles/window-opaque.lua" "$toggles_dir/"
  fi
done
