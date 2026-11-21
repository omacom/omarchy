echo "Refresh theme files to style locked Hyprland groups"

theme_name_path="$HOME/.local/state/omarchy/current/theme.name"

[[ -s $theme_name_path ]] || exit 0

theme_name=$(<"$theme_name_path")

# A theme removed while it was current leaves nothing to re-stage from, and failing here would hold every later migration.
[[ -d $OMARCHY_PATH/themes/$theme_name || -d $HOME/.config/omarchy/themes/$theme_name ]] || exit 0

omarchy-theme-refresh
