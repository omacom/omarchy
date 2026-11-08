echo "Point menu overrides and Hyprland bindings at omarchy-system for logout, reboot and shutdown"

# 4.5 folded omarchy-system-logout, -reboot and -shutdown into one
# omarchy-system command (#15231). A menu override that copied a shipped
# system row, or a binding written against the old names, still calls a
# command that no longer exists, so choosing it does nothing (#17975).
# Replace only those exact command names, bare or behind a path, and keep the
# rest of each file, including a user's own command that merely ends in one.
legacy='(^|[^[:alnum:]_.-])omarchy-system-(logout|reboot|shutdown)([^[:alnum:]_-]|$)'

for file in "$HOME/.config/omarchy/extensions/omarchy-menu.jsonc" "$HOME"/.config/hypr/*.lua "$HOME"/.config/hypr/*.conf; do
  [[ -f $file ]] || continue

  # Repeat on each line: one match takes the character after it, which a
  # second call right behind it needs as its own boundary.
  if grep -Eq "$legacy" "$file"; then
    sed -E -i --follow-symlinks -e ':again' -e "s/$legacy/\\1omarchy-system \\2\\3/" -e 't again' "$file"
  fi
done
