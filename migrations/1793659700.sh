echo "Point an installed Bambu Studio at the tooltip workaround"

if omarchy-cmd-missing bambu-studio; then
  exit 0
fi

template="$OMARCHY_PATH/default/applications/BambuStudio.desktop"
[[ -f $template ]] || exit 1

desktop="$HOME/.local/share/applications/BambuStudio.desktop"
replace=0
if [[ ! -f $desktop ]]; then
  replace=1
else
  exec_line=$(grep -m1 '^Exec=' "$desktop" || true)
  if [[ $exec_line == Exec=/usr/bin/bambu-studio* || $exec_line == Exec=bambu-studio* ]]; then
    replace=1
  fi
fi

if (( replace )); then
  mkdir -p "$(dirname "$desktop")"
  cp "$template" "$desktop"
  update-desktop-database "$(dirname "$desktop")" 2>/dev/null || true
fi
