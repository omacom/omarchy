echo "Keep your own touchpad gestures instead of Omarchy's new defaults"

# Hyprland rejects a second gesture on the same fingers and direction, so
# gestures already set up in ~/.config/hypr would now fail against the defaults.
# Leave those setups as they were by turning the defaults off for them.
hypr_dir="$HOME/.config/hypr"
hyprland="$hypr_dir/hyprland.lua"

[[ -f $hyprland ]] || exit 0
grep -qE '^[[:space:]]*omarchy_default_gestures[[:space:]]*=' "$hyprland" && exit 0
grep -qE '^[[:space:]]*hl\.gesture[[:space:]]*\(' "$hypr_dir"/*.lua 2>/dev/null || exit 0
grep -q '^require("default.hypr.omarchy")' "$hyprland" || exit 0

sed -i 's/^require("default.hypr.omarchy")/-- Your own gestures replace Omarchy'"'"'s defaults.\nomarchy_default_gestures = false\n\n&/' "$hyprland"
