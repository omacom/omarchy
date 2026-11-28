echo "Match Tokyo Night's boot splash and login screen colors to Plymouth's"

# The current theme is a copy staged by omarchy-theme-set, so Tokyo Night's
# splash_* overrides only reach it (and the ESP / login color files) once it is
# refreshed.
theme=$(cat "$HOME/.local/state/omarchy/current/theme.name" 2>/dev/null || true)
if [[ $theme == "tokyo-night" ]]; then
  omarchy-theme-refresh
fi
