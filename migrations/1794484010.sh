echo "Draw Omarchy's own app icons in the current theme's colors"

# The refresh draws the icons in the current theme's colors and links them over
# the packaged ones. A theme the user removed can't be refreshed; its icons come
# with the next theme they pick.
theme=$(cat "$HOME/.local/state/omarchy/current/theme.name" 2>/dev/null || true)
if [[ -n $theme && ( -d $OMARCHY_PATH/themes/$theme || -d $HOME/.config/omarchy/themes/$theme ) ]]; then
  omarchy-theme-refresh
fi
