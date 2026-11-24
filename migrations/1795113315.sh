echo "Restage the current theme so it picks up its packaged background loops"

# 1795093470 installed omarchy-themes-loops, but the current theme is a copy
# staged by omarchy-theme-set, so its loops only arrive with the next theme
# switch. Refreshing restages it without playing an intro.
theme=$(cat "$HOME/.local/state/omarchy/current/theme.name" 2>/dev/null || true)
staged_backgrounds="$HOME/.local/state/omarchy/current/theme/backgrounds"
if [[ -n $theme && -d /usr/share/omarchy/themes/$theme/backgrounds/loops && -d $staged_backgrounds && ! -d $staged_backgrounds/loops ]]; then
  omarchy-theme-refresh
fi
