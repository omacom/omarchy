echo "Let a lone Shift switch out of an input method and back"

# An earlier migration wrote this list empty. Fill only that empty list: a
# missing one already falls back to Fcitx's Shift_L, and a filled one is the
# user's choice.
config="$HOME/.config/fcitx5/config"
if [[ -f $config ]] && awk '/^\[Hotkey\/AltTriggerKeys\]$/ { in_list = 1; found = 1; next } /^\[/ { in_list = 0 } in_list && /=/ { filled = 1 } END { exit !(found && !filled) }' "$config"; then
  sed -i --follow-symlinks '/^\[Hotkey\/AltTriggerKeys\]$/a 0=Shift_L' "$config"
  busctl --user call org.fcitx.Fcitx5 /controller org.fcitx.Fcitx.Controller1 ReloadConfig 2>/dev/null || true
fi
