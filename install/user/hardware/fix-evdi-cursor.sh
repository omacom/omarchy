# Disable hardware cursors when DisplayLink's evdi driver is in use.
#
# Hyprland's automatic cursor mode (the default, 2) keeps hardware cursors on
# evdi outputs. Moving between two DisplayLink monitors then leaves a stale
# cursor on the output the pointer left, until something forces a redraw.
# Software cursors avoid the duplicate on every output.
evdi_module="${OMARCHY_EVDI_MODULE_PATH:-/sys/module/evdi}"

if [[ -d $evdi_module ]]; then
  looknfeel="$HOME/.config/hypr/looknfeel.lua"

  if [[ -f $looknfeel ]] && ! grep -q 'no_hardware_cursors' "$looknfeel"; then
    echo "Detected the evdi/DisplayLink driver. Forcing software cursors to avoid a stale duplicate cursor."

    cat >>"$looknfeel" <<'LUA'

-- evdi/DisplayLink outputs keep a hardware cursor plane that leaves a stale
-- cursor on the monitor the pointer left. Render one software cursor instead.
hl.config({
  cursor = {
    no_hardware_cursors = true,
  },
})
LUA
  fi
fi
