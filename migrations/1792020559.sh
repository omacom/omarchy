echo "Theme the Fcitx candidate window with the current Omarchy theme"

# Activation selects the theme; the refresh then renders it, since the current
# theme was staged before its template existed.
omarchy-theme-set-fcitx5 --activate
omarchy-theme-refresh
