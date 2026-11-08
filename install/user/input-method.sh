omarchy-input-method configure --seed

# Default input-language switcher shortcut: use the same default as the existing
# binding so the choice file matches what the desktop already listens to.
mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}/omarchy"
if [[ ! -s "${XDG_CONFIG_HOME:-$HOME/.config}/omarchy/keyboard-shortcut" ]]; then
  # Use the shipped default so new users get it; existing users keep their config.
  cp "$OMARCHY_PATH/config/omarchy/defaults/keyboard-shortcut" "${XDG_CONFIG_HOME:-$HOME/.config}/omarchy/keyboard-shortcut"
fi
