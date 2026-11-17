echo "Blur popups for existing Glassy bars and windows"

updated=0

for state_home in "$HOME/.local/state" "${XDG_STATE_HOME:-}"; do
  [[ -n $state_home ]] || continue

  for toggle in bar-glassy window-glassy; do
    flag="$state_home/omarchy/toggles/hypr/$toggle.lua"
    [[ -f $flag ]] || continue

    cp "$OMARCHY_PATH/default/hypr/toggles/$toggle.lua" "$flag"
    updated=1
  done
done

if (( updated )); then
  omarchy-restart-hyprctl
fi
