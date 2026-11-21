echo "Point menu overrides and Hyprland bindings at omarchy-system for logout, reboot and shutdown"

# 4.5 folded omarchy-system-logout, -reboot and -shutdown into one
# omarchy-system command (#15231). A menu override that copied a shipped
# system row, or a binding written against the old names, still calls a
# command that no longer exists, so choosing it does nothing (#17975).
# Replace only those exact command names, bare or behind a path, and keep the
# rest of each file, including a user's own command or script whose name merely
# contains one.
name='(^|[^[:alnum:]_.-])omarchy-system-(logout|reboot|shutdown)'
legacy="$name([^[:alnum:]_.-]|\$)"

for file in "$HOME/.config/omarchy/extensions/omarchy-menu.jsonc" "$HOME"/.config/hypr/*.lua "$HOME"/.config/hypr/*.conf; do
  [[ -f $file ]] || continue
  grep -Eq "$legacy" "$file" || continue

  # When a shell quote wraps just the command, it has to close before the new
  # argument, or the shell still reads "omarchy-system shutdown" as one
  # command. A quoted script handed to bash -c or sh -c is different: the
  # action has to stay inside it. Only quotes the shell sees count, not the
  # quotes around a JSON or Lua string.
  case $file in
    *.jsonc) quote=\''|\\"' ;;
    *.lua) quote='\\["'\'']' ;;
    *) quote='["'\'']' ;;
  esac

  # A path may hold spaces when it starts the quoted word with /, ~ or $,
  # as in '/home/Jane Doe/...', but never shell operators.
  path='([^[:space:]"'\''\\]*\/|[\/~$][^"'\''\\;&|<>()]*\/)?'
  retired="($quote)${path}omarchy-system-(logout|reboot|shutdown)($quote)"

  # Repeat on each line: one match takes the character after it, which a
  # second call right behind it needs as its own boundary.
  sed -E -i --follow-symlinks \
    -e ':wrapped' -e "s/(^|[[:space:]])(-[[:alpha:]]*c[[:space:]]+)$retired/\\1\\2\\3\\4omarchy-system \\5\\6/" -e 't wrapped' \
    -e ':quoted' -e "s/$retired/\\1\\2omarchy-system\\4 \\3/" -e 't quoted' \
    -e ':bare' -e "s/$legacy/\\1omarchy-system \\2\\3/" -e 't bare' \
    "$file"
done
