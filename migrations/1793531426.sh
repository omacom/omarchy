echo "Enable native close confirmation in unchanged Ghostty configs"

ghostty_config="$HOME/.config/ghostty/config"
[[ -f $ghostty_config ]] || exit 0

# Preserve dotfile managers that own a file or any directory through HOME.
path="$ghostty_config"
while [[ $path != / ]]; do
  if [[ -L $path ]]; then
    echo "Preserving symlink-managed Ghostty config: $path"
    exit 0
  fi
  [[ $path != "$HOME" ]] || break
  path=$(dirname "$path")
done

# Complete stock config shipped by settings 4.0.6, 4.5.0rc2 and edge r7534.
# A matching line alone could be an intentional personal override.
stock_sha="87b7fa254cab399f461e5614a59fed5ac313e013bb1b409cbfbe756eaa439b92"
if [[ $(sha256sum <"$ghostty_config") == "$stock_sha  -" ]]; then
  backup=$(mktemp "$ghostty_config.bak.XXXXXX")
  cp -p "$ghostty_config" "$backup"
  sed -i 's/^confirm-close-surface=false$/confirm-close-surface=true/' "$ghostty_config"
  printf 'Enabled Ghostty close confirmation. Backup saved to:\n  %s\n' "$backup"
fi
