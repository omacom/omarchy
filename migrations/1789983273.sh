echo "Disable fcitx5 QuickPhrase's Super+grave trigger"

# fcitx5 ships Super+grave as QuickPhrase's compiled-in global trigger.
# Omarchy's Quake console binds Super+grave; the consuming Hyprland bind then
# makes QuickPhrase silently stop answering the chord with no indication why.
# Blank TriggerKey with the same override style clipboard.conf already ships.
# Only seed, so a user who set their own QuickPhrase trigger keeps it.
conf="fcitx5/conf/quickphrase.conf"
if [[ ! -f "$HOME/.config/$conf" ]]; then
  omarchy-refresh-config "$conf"
  systemctl --user try-restart omarchy-fcitx5.service 2>/dev/null || true
fi
