echo "Point a stock Voxtype config at a whisper model that speaks the desktop language"

# Fresh configs are handled at install. This only rewrites a file that is
# still the English-only template, and only when the desktop is not English.
if [[ -f ${XDG_CONFIG_HOME:-$HOME/.config}/voxtype/config.toml ]]; then
  omarchy-voxtype-language apply-stock
fi
