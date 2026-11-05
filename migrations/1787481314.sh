echo "Reinstall Osaka Jade for anyone left on it with no palette"

# Osaka Jade left the bundled themes, but omarchy-themes-intros kept shipping its
# intro, so the theme refresh re-staged the leftover directory with no colors.toml
# and every terminal include pointed at a file that was never generated. The theme
# lives on as its own repo, under the same name, so install it from there.
theme_name_path="$HOME/.local/state/omarchy/current/theme.name"

[[ -s $theme_name_path && $(<"$theme_name_path") == "osaka-jade" ]] || exit 0

for theme_path in "$OMARCHY_PATH/themes/osaka-jade" "$HOME/.config/omarchy/themes/osaka-jade"; do
  [[ -f $theme_path/colors.toml || -f $theme_path/alacritty.toml ]] && exit 0
done

if ! GIT_TERMINAL_PROMPT=0 omarchy-theme-install https://github.com/omacom/omarchy-osaka-jade-theme; then
  echo "Could not install Osaka Jade; applying Jade Horse, which replaced it"
  omarchy-theme-set "Jade Horse"
fi
