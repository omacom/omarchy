echo "Keep a personal Super + Ctrl + X binding ahead of the new agents panel hotkey"

# Super + Ctrl + X now opens the agents panel. Hyprland runs every bind on a key,
# so a personal o.bind there (the legacy dictation toggle 1793477875 added, or
# one of the user's own) would fire alongside the panel. o.rebind replaces the
# default instead, so the user's binding keeps the key on its own.
bindings="$HOME/.config/hypr/bindings.lua"
if [[ -f $bindings ]] && grep -qF 'o.bind("SUPER + CTRL + X"' "$bindings"; then
  sed -i 's/\bo\.bind("SUPER + CTRL + X"/o.rebind("SUPER + CTRL + X"/' "$bindings"
fi
