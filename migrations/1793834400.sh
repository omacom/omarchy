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

omarchy-restart-hyprctl
