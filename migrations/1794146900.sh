echo "Blur the Glassy bar from the cached wallpaper blur"

# omarchy-bar copies the Glassy bar's rule only when the copy is missing, so a
# bar that is already glassy keeps the old rule. Replace a copy that is exactly
# the rule shipped before xray, and leave hand-edited copies alone.
toggle="${XDG_STATE_HOME:-$HOME/.local/state}/omarchy/toggles/hypr/bar-glassy.lua"

if [[ $(omarchy-bar background) == "glassy" ]] && [[ -f $toggle ]] &&
  [[ $(sha256sum "$toggle" | cut -d' ' -f1) == "033a5926a32c2992d18b4d2cca393119abe1a0cca67266383167af27f5bf9e6b" ]]; then
  rm -f "$toggle"
  omarchy-bar sync-glass
fi
