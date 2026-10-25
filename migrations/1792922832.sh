echo "Move Osaka Jade users to Jade Horse, which replaced it"

# Osaka Jade is no longer bundled, so refreshing a selection of it would fail.
# A user's own copy under ~/.config/omarchy/themes still resolves and is kept.
theme_name_path="$HOME/.local/state/omarchy/current/theme.name"

[[ -s $theme_name_path && $(<"$theme_name_path") == "osaka-jade" ]] || exit 0
[[ -d $HOME/.config/omarchy/themes/osaka-jade ]] && exit 0

OMARCHY_THEME_WAIT=1 omarchy-theme-set jade-horse
