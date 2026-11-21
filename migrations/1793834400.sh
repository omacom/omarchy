echo "Update saved single-window-aspect-ratio toggle for scrolling layout"

OMARCHY_PATH="${OMARCHY_PATH:-/usr/share/omarchy}"

# Users who enabled single-window aspect ratio keep a saved copy of
# single-window-aspect-ratio.lua in their state directory. Refresh existing
# enabled copies from the package template so single windows in scrolling layout
# respect column width without needing to cycle the toggle off and on.
for state_home in "$HOME/.local/state" "${XDG_STATE_HOME:-}"; do
  [[ -n $state_home ]] || continue
  flag_file="$state_home/omarchy/toggles/hypr/single-window-aspect-ratio.lua"
  [[ -f $flag_file ]] || continue

  source_toggle="$OMARCHY_PATH/default/hypr/toggles/single-window-aspect-ratio.lua"
  if [[ -f $source_toggle ]]; then
    cp "$source_toggle" "$flag_file"
  else
    cat >"$flag_file" <<'EOF'
hl.config({
  layout = {
    single_window_aspect_ratio = { 1, 1 },
  },

  scrolling = {
    fullscreen_on_one_column = false,
  },
})
EOF
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
