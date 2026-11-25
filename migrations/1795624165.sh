echo "Use the Persian font for Arabic-script text where Persian is the language or keyboard layout"

language=$(cat "${XDG_CONFIG_HOME:-$HOME/.config}/omarchy/language" 2>/dev/null || true)
# Without a running Hyprland there is no live layout to read; the language still counts.
layouts=$(hyprctl -j getoption input:kb_layout 2>/dev/null | jq -r '.str // empty' 2>/dev/null || true)

if [[ $language == "fa" ]] || [[ ,$layouts, == *,ir,* && ,$layouts, != *,ara,* ]]; then
  omarchy-font-persian --seed on
fi
