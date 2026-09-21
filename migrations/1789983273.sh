echo "Disable fcitx5 QuickPhrase's Super+grave trigger"

# fcitx5 ships Super+grave and Super+semicolon as QuickPhrase's global triggers.
# Omarchy's Quake console binds Super+grave; the consuming Hyprland bind then
# makes QuickPhrase silently stop answering the chord with no indication why.
# Keep Super+semicolon, and preserve any trigger list the user explicitly set.
conf="fcitx5/conf/quickphrase.conf"
user_config="$HOME/.config/$conf"
config_changed=false

if [[ ! -f $user_config ]]; then
  omarchy-refresh-config "$conf"
  config_changed=true
elif ! grep -Eq '^[[:space:]]*(TriggerKey=|\[TriggerKey\][[:space:]]*$)' "$user_config"; then
  [[ ! -s $user_config ]] || printf '\n' >>"$user_config"
  cat "$OMARCHY_PATH/config/$conf" >>"$user_config"
  config_changed=true
fi

if [[ $config_changed == "true" ]]; then
  systemctl --user try-restart omarchy-fcitx5.service 2>/dev/null || true
fi
