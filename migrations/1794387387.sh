echo "Keep a personal Super + Ctrl + X binding ahead of the new agents panel hotkey"

# Super + Ctrl + X now opens the agents panel. Hyprland runs every bind on a key,
# so a personal binding there (the legacy dictation toggle 1793477875 added, or
# one of the user's own) would fire alongside the panel. One hl.unbind just
# before the first personal binding drops the default and leaves every personal
# action on the key in place. Inserted in that binding's own scope, it only
# takes the panel away where the personal binding is actually bound (the legacy
# toggle sits inside a dictation-installed check).
bindings="$HOME/.config/hypr/bindings.lua"
[[ -f $bindings ]] || exit 0

unbind='hl.unbind("SUPER + CTRL + X")'
keys="[\"'][[:space:]]*(SUPER[[:space:]]*\+[[:space:]]*CTRL|CTRL[[:space:]]*\+[[:space:]]*SUPER)[[:space:]]*\+[[:space:]]*X[[:space:]]*[\"']"
personal="(o\.bind(_hold)?|hl\.bind)[[:space:]]*\([[:space:]]*$keys"

if grep -qiE "$personal" "$bindings" && ! grep -qF "$unbind" "$bindings"; then
  sed -i --follow-symlinks -E "0,/$personal/I s/^([[:space:]]*)(.*$personal)/\1$unbind\n\1\2/I" "$bindings"
fi
