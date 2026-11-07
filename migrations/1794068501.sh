echo "Point menu overrides and Hyprland bindings at omarchy-system for logout, reboot and shutdown"

# 4.5 folded omarchy-system-logout, -reboot and -shutdown into one
# omarchy-system command (#15231). A menu override that copied a shipped
# system row, or a binding written against the old names, still calls a
# command that no longer exists, so choosing it does nothing (#17975).
# Replace only those exact command names and keep the rest of each file.
legacy='omarchy-system-(logout|reboot|shutdown)([^[:alnum:]_-]|$)'

for file in "$HOME/.config/omarchy/extensions/omarchy-menu.jsonc" "$HOME"/.config/hypr/*.lua "$HOME"/.config/hypr/*.conf; do
  [[ -f $file ]] || continue

  if grep -Eq "$legacy" "$file"; then
    sed -E -i --follow-symlinks "s/$legacy/omarchy-system \\1\\2/g" "$file"
  fi
done
