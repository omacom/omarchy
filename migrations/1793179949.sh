echo "Keep your own touchpad gestures instead of Omarchy's new defaults"

# Hyprland rejects a second gesture on the same fingers and direction, so
# gestures already set up in ~/.config/hypr would now fail against the defaults.
# Leave those setups as they were by turning the defaults off for them.
hypr_dir="$HOME/.config/hypr"
hyprland="$hypr_dir/hyprland.lua"

[[ -f $hyprland ]] || exit 0
grep -qE '^[[:space:]]*omarchy_default_gestures[[:space:]]*=' "$hyprland" && exit 0
grep -RqE --include='*.lua' '^[[:space:]]*hl\.gesture[[:space:]]*\(' "$hypr_dir" || exit 0

# The flag has to be set before the defaults load, so it goes above the line
# that requires them, however that is spelled, or at the top of the file.
line=$(grep -nE -m1 "^[[:space:]]*require[[:space:]]*\(?[[:space:]]*[\"']default\.hypr\.omarchy[\"']" "$hyprland" | cut -d: -f1 || true)

# Follow a symlink into a dotfiles repo rather than replacing it with a copy.
sed -i --follow-symlinks "${line:-1}i -- Your own gestures replace Omarchy's defaults.\nomarchy_default_gestures = false\n" "$hyprland"
