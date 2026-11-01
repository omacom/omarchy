# The catalog entry holds a real newline, not a literal \n: the card renders the
# body as it arrives, and elides past three lines.
omarchy-notification-send -u critical -g  "$(omarchy-i18n firstRun.keybindingsTitle)" \
  "$(omarchy-i18n firstRun.keybindingsBody)" \
  --exec omarchy-menu-keybindings
