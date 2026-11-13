echo "Separate window borders from saved window gaps toggles"

# Turning window gaps off used to hide borders too (border_size = 0). It no longer
# touches borders, so drop that rule from any saved window-no-gaps flag, and carry
# it over as window-no-borders so borders stay off until explicitly turned on.
for state_home in "$HOME/.local/state" "${XDG_STATE_HOME:-}"; do
  [[ -n $state_home ]] || continue
  toggles_dir="$state_home/omarchy/toggles/hypr"
  gaps_file="$toggles_dir/window-no-gaps.lua"
  [[ -f $gaps_file ]] || continue

  if grep -q '[[:space:]]*border_size[[:space:]]*=[[:space:]]*0' "$gaps_file"; then
    borders_file="$toggles_dir/window-no-borders.lua"
    if [[ ! -f $borders_file ]]; then
      source_toggle="${OMARCHY_PATH:-/usr/share/omarchy}/default/hypr/toggles/window-no-borders.lua"
      if [[ -f $source_toggle ]]; then
        cp "$source_toggle" "$borders_file"
      else
        cat >"$borders_file" <<'EOF'
-- Remove all window borders.
hl.config({
  general = {
    border_size = 0,
  },
})
EOF
      fi
    fi

    sed -i '/[[:space:]]*border_size[[:space:]]*=[[:space:]]*0,\?/d' "$gaps_file"
    sed -i 's/-- Remove all window gaps and borders\./-- Remove all window gaps\./' "$gaps_file"
  fi
done

# Skip reloading when Hyprland was replaced during an update or when upgrading
# live to Quattro so the running compositor is not loaded with newer configs.
if [[ ${OMARCHY_UPGRADE_TO_QUATTRO_LIVE:-0} != "1" ]] &&
  ! (command -v omarchy-hyprland-reload-guard >/dev/null && omarchy-hyprland-reload-guard paused); then
  replaced_hyprland=false
  for pid in $(pgrep -x Hyprland 2>/dev/null || true); do
    if [[ $(readlink "/proc/$pid/exe" 2>/dev/null) == *"(deleted)"* ]]; then
      replaced_hyprland=true
      break
    fi
  done

  if [[ $replaced_hyprland == "false" ]]; then
    omarchy-restart-hyprctl
  fi
fi
