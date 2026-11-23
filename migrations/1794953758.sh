echo "Remove the launcher left by an earlier Hermes Desktop removal"

wrapper="$HOME/.local/bin/hermes"
launcher="${XDG_DATA_HOME:-$HOME/.local/share}/applications/hermes.desktop"

if omarchy-pkg-missing hermes-desktop && [[ ! -e $wrapper && ! -L $wrapper ]]; then
  launcher_exec=$(sed -n '/^\[Desktop Entry\]$/,/^\[/s/^Exec=//p' "$launcher" 2>/dev/null | head -1 || true)
  if [[ $launcher_exec == "$wrapper desktop" || $launcher_exec == "\"$wrapper\" desktop" ]]; then
    rm -f "$launcher"
  fi
fi
