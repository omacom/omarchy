# A VM usually renders on the CPU, where animations and transparency cost
# every frame, so start it without them. omarchy-toggle-animations brings them
# back. This runs before any Hyprland session exists, so place the flag
# directly rather than through omarchy-hyprland-toggle, which reloads Hyprland.
if omarchy-hw-vm; then
  echo "Detected a virtual machine. Turning off animations and transparency."
  mkdir -p "$HOME/.local/state/omarchy/toggles/hypr"
  cp "$OMARCHY_PATH/default/hypr/toggles/no-animations.lua" "$HOME/.local/state/omarchy/toggles/hypr/"
fi
