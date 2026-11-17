echo "Refresh the current theme so new Foot windows report its color mode"

foot_ini="$HOME/.local/state/omarchy/current/theme/foot.ini"
theme=$(cat "$HOME/.local/state/omarchy/current/theme.name" 2>/dev/null || true)

if [[ -f $foot_ini && -n $theme && ( -d $OMARCHY_PATH/themes/$theme || -d $HOME/.config/omarchy/themes/$theme ) ]] &&
  ! grep -q '^[[:space:]]*initial-color-theme[[:space:]]*=' "$foot_ini"; then
  omarchy-theme-refresh
fi
