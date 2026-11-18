echo "Install the live background loops for the built-in themes"

omarchy-pkg-add omarchy-themes-loops

# The current theme was staged before its loops were installed. The refresh
# stages them beside its stills. A theme the user removed can't be refreshed;
# its loops come with the next theme they pick.
theme=$(cat "$HOME/.local/state/omarchy/current/theme.name" 2>/dev/null || true)
if [[ -n $theme && ( -d $OMARCHY_PATH/themes/$theme || -d $HOME/.config/omarchy/themes/$theme ) ]]; then
  omarchy-theme-refresh
fi
