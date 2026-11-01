echo "Add an example for opting applications in to transparency"

looknfeel="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/looknfeel.lua"
if [[ -f $looknfeel ]] && ! rg -Fq 'o.transparent_window("my-app")' "$looknfeel"; then
  cat >>"$looknfeel" <<'LUA'

-- Opt another application in to Omarchy's standard transparency.
-- Find its class with: hyprctl clients
-- o.transparent_window("my-app")
-- o.transparent_window("my-app", "0.9 0.85") -- Custom active/inactive opacity.
LUA
fi
