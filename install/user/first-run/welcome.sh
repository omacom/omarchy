# A platform without a keyboard-first workflow, such as a phone, marks
# welcome-keybindings-not-applicable from its setup-user, which first run calls
# before this step.
omarchy-done check welcome-keybindings-not-applicable && exit 0

# Real newlines, not a literal \n: the card renders the body as it arrives, and
# elides past three lines.
omarchy-notification-send -u critical -g  "Learn Keybindings" \
  $'Super + K for cheatsheet.\nSuper + Space for Omarchy Menu.' \
  --exec omarchy-menu-keybindings
