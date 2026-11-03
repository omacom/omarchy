echo "Re-stage the active theme with its background effects"

theme_name_path="$HOME/.local/state/omarchy/current/theme.name"

[[ -s $theme_name_path ]] || exit 0

theme_name=$(<"$theme_name_path")
[[ $theme_name =~ ^[[:alnum:]_][[:alnum:].+_-]*$ ]] || exit 0
[[ -d $OMARCHY_PATH/themes/$theme_name/backgrounds/effects ]] || exit 0
[[ ! -d $HOME/.local/state/omarchy/current/theme/backgrounds/effects ]] || exit 0

omarchy-theme-refresh
