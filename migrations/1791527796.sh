echo "Re-stage the current theme so dark themes use the dark Yaru icons"

# Dark stock themes named the light Yaru variants, whose panel icons are drawn
# dark for a light bar. They now ship the -dark variant, but a staged theme keeps
# the old name until something re-applies it.
current="$HOME/.local/state/omarchy/current"
theme_name_path="$current/theme.name"
staged="$current/theme/icons.theme"

[[ -s $theme_name_path && -f $staged ]] || exit 0

theme_name=$(<"$theme_name_path")
shipped="$OMARCHY_PATH/themes/$theme_name/icons.theme"

# An icons.theme the user put in their own overlay is theirs to keep.
[[ -f $shipped && ! -f $HOME/.config/omarchy/themes/$theme_name/icons.theme ]] || exit 0

mode=$(omarchy-theme-color --file "$current/theme/colors.toml" mode)

if [[ $mode == "dark" && $(<"$shipped") == "$(<"$staged")-dark" ]]; then
  omarchy-theme-refresh
fi
