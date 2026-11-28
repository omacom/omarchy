echo "Stop Ghostty toasts on theme changes and clipboard copies"

ghostty_config="$HOME/.config/ghostty/config"

if [[ -f $ghostty_config ]] && ! grep -q '^app-notifications' "$ghostty_config"; then
  sed -i --follow-symlinks '/^resize-overlay = never$/a # No toast on each config reload (every theme change) or clipboard copy\napp-notifications = no-clipboard-copy,no-config-reload' "$ghostty_config"
  grep -q '^app-notifications' "$ghostty_config" || printf '\n# No toast on each config reload (every theme change) or clipboard copy\napp-notifications = no-clipboard-copy,no-config-reload\n' >>"$ghostty_config"
fi
