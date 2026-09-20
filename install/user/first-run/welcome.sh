omarchy-notification-send -u critical -g  \
  "$(omarchy-i18n "Learn Keybindings")" \
  "$(omarchy-i18n $'Super + K for cheatsheet.\nSuper + Space for Omarchy Menu.')" \
  --exec omarchy-menu-keybindings
