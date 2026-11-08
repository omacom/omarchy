echo "Blur only the wallpaper behind the Glassy bar"

# Turning on the Glassy bar copies its toggle into the state directory, so a
# bar that is already glassy keeps the old rule, which re-blurs the whole screen
# whenever a window redraws. Copy the current one over it.
reload=0

for state_home in "$HOME/.local/state" "${XDG_STATE_HOME:-}"; do
  [[ -n $state_home ]] || continue
  flag="$state_home/omarchy/toggles/hypr/bar-glassy.lua"
  [[ -f $flag ]] || continue

  cp "$OMARCHY_PATH/default/hypr/toggles/bar-glassy.lua" "$flag"
  reload=1
done

if (( reload )); then
  hyprctl reload >/dev/null 2>&1 || true
fi
