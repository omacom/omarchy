echo "Replace omazed with native Zed theming"

marker_start="# >>> omazed hook - do not edit >>>"
marker_end="# <<< omazed hook - do not edit <<<"
hook_file="$HOME/.config/omarchy/hooks/theme-set"
hook_dir="$HOME/.config/omarchy/hooks/theme-set.d"
font_hook_dir="$HOME/.config/omarchy/hooks/font-set.d"

# Keep the old integration working until the replacement is ready. In
# particular, a failed refresh must not remove the selected Omazed theme.
omarchy-theme-refresh
omarchy-theme-set-zed --migrate

# A hook named omazed might have been customized. Only retire the exact
# commands Omazed installed; leave any other user hook alone.
is_omazed_hook() {
  local file="$1" command="$2"
  [[ -f $file ]] || return 1
  awk -v command="$command" '
    /^[[:space:]]*(#|$)/ { next }
    {
      line = $0
      sub(/^[[:space:]]+/, "", line)
      sub(/[[:space:]]+$/, "", line)
      if (line == command) found++
      else unknown = 1
    }
    END { exit !(found == 1 && !unknown) }
  ' "$file"
}

if [[ -f $hook_file ]] && awk -v start="$marker_start" -v end="$marker_end" '
  $0 == start { found_start = 1 }
  found_start && $0 == end { found_end = 1; exit }
  END { exit !(found_start && found_end) }
' "$hook_file"; then
  sed -i --follow-symlinks "/^$marker_start$/,/^$marker_end$/d" "$hook_file"
fi

if is_omazed_hook "$hook_dir/omazed" 'omazed set "$1"'; then
  rm -f "$hook_dir/omazed"
fi

# Omazed 2.2 also installed a font hook. Preserve its opt-in before removing
# the known hook; other Zed users should retain their own font choice.
if is_omazed_hook "$font_hook_dir/omazed" 'omazed set-font "$1"'; then
  font_sync_marker="$HOME/.local/state/omarchy/zed/font-sync"
  mkdir -p "${font_sync_marker%/*}"
  touch "$font_sync_marker"
  rm -f "$font_hook_dir/omazed"
fi

# The package and generated theme are left in place: other users migrate at
# their own login, and a workspace may still reference the Omazed theme.
