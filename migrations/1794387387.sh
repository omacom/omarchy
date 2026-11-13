echo "Keep the legacy Super + Ctrl + X dictation toggle ahead of the new agents panel hotkey"

# Super + Ctrl + X now opens the agents panel. Hyprland runs every bind on a key,
# so the legacy dictation toggle 1793477875 wrote would fire alongside the panel.
# o.rebind replaces the default instead. That migration only added the toggle to
# a file with no other Super + Ctrl + X binding, appended at the end, so the
# rebind drops nothing personal, and it stays inside the dictation-installed
# check, so the panel keeps the key wherever that is false. Only that exact line
# is changed; bindings written by hand are left as written, like any personal
# binding that shares a key with a new default.
bindings="$HOME/.config/hypr/bindings.lua"
legacy='  o.bind("SUPER + CTRL + X", "Toggle dictation", "omarchy-dictation toggle")'

if [[ -f $bindings ]] && grep -qxF "$legacy" "$bindings"; then
  sed -i --follow-symlinks 's/^  o\.bind("SUPER + CTRL + X", "Toggle dictation", "omarchy-dictation toggle")$/  o.rebind("SUPER + CTRL + X", "Toggle dictation", "omarchy-dictation toggle")/' "$bindings"
fi
