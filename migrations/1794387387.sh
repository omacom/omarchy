echo "Keep personal Super + Ctrl + X bindings ahead of the new agents panel hotkey"

# Super + Ctrl + X now opens the agents panel. Hyprland runs every bind on a key,
# so a personal binding there (the legacy dictation toggle 1793477875 added, or
# one of the user's own) would fire alongside the panel. o.unbind_default goes
# in just before each active personal binding, in that binding's own scope: it
# drops the default the first time one of them runs and leaves every personal
# action in place, while a binding in a false condition (the legacy toggle sits
# inside a dictation-installed check) keeps the panel. Commented-out lines are
# left alone.
bindings="$HOME/.config/hypr/bindings.lua"
[[ -f $bindings ]] || exit 0

unbind='o.unbind_default("SUPER + CTRL + X")'
keys="[\"'][[:space:]]*(SUPER[[:space:]]*\+[[:space:]]*CTRL|CTRL[[:space:]]*\+[[:space:]]*SUPER)[[:space:]]*\+[[:space:]]*X[[:space:]]*[\"']"
personal="^([[:space:]]*)((o\.bind(_hold)?|hl\.bind)[[:space:]]*\([[:space:]]*$keys)"

if grep -qiE "$personal" "$bindings" && ! grep -qF "$unbind" "$bindings"; then
  sed -i --follow-symlinks -E "s/$personal/\1$unbind\n\1\2/I" "$bindings"
fi
