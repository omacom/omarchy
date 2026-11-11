echo "Keep personal Super + Ctrl + X bindings ahead of the new agents panel hotkey"

# Super + Ctrl + X now opens the agents panel. Hyprland runs every bind on a key,
# so a personal binding there would fire alongside the panel. o.unbind_default
# drops the default once per config load and leaves personal bindings in place.
#
# The unbind only ever goes in as a statement on a line of its own, never inside
# one of the user's expressions:
# - The legacy dictation toggle 1793477875 wrote gets it just above, inside the
#   same dictation-installed check, so the panel stays wherever that is false.
# - Any other active personal binding on the key gets it once at the top of the
#   file. A -- before the call means it's commented out.
bindings="$HOME/.config/hypr/bindings.lua"
[[ -f $bindings ]] || exit 0

unbind='o.unbind_default("SUPER + CTRL + X")'
grep -qF "$unbind" "$bindings" && exit 0

legacy='  o.bind("SUPER + CTRL + X", "Toggle dictation", "omarchy-dictation toggle")'
keys="[\"'][[:space:]]*(SUPER[[:space:]]*\+[[:space:]]*CTRL|CTRL[[:space:]]*\+[[:space:]]*SUPER)[[:space:]]*\+[[:space:]]*X[[:space:]]*[\"']"
personal="^([^-]|-[^-])*(o\.bind(_hold)?|hl\.bind)[[:space:]]*\([[:space:]]*$keys"

if grep -qxF "$legacy" "$bindings"; then
  sed -i --follow-symlinks "\\|^  o\\.bind(\"SUPER + CTRL + X\", \"Toggle dictation\", \"omarchy-dictation toggle\")\$|i\\  $unbind" "$bindings"
fi

if grep -vxF "$legacy" "$bindings" | grep -qiE "$personal"; then
  sed -i --follow-symlinks "1i\\$unbind" "$bindings"
fi
