omarchy-input-method configure --seed

# Default input-language switcher shortcut: use the same default as the existing
# binding so the choice file matches what the desktop already listens to.
mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}/omarchy"
if [[ ! -s "${XDG_CONFIG_HOME:-$HOME/.config}/omarchy/keyboard-shortcut" ]]; then
  printf 'SUPER + I\n' > "${XDG_CONFIG_HOME:-$HOME/.config}/omarchy/keyboard-shortcut"
fi
