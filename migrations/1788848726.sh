echo "Retire the stock user icon font missed by the Quattro upgrade"

legacy_font="$HOME/.local/share/fonts/omarchy.ttf"

# The upgrader treated this as ~/.config/omarchy.ttf and left the old family
# registered alongside the packaged font. Preserve custom fonts and symlinks.
if [[ -f $legacy_font && ! -L $legacy_font ]]; then
  legacy_hash=$(sha256sum "$legacy_font")
  if [[ ${legacy_hash%% *} == "e55e67119e82f56f92d90cbf54b7ccc1b2946b32c535a29370439d7ef5215966" ]]; then
    if [[ ! -f /usr/share/fonts/omarchy/omarchy.ttf ]]; then
      echo "Packaged Omarchy icon font is missing; keeping the legacy font." >&2
      exit 1
    fi

    rm "$legacy_font"
  fi
fi

# Also refresh on retries after removal succeeded but the cache refresh failed.
# The normal update restarts the shell, which reloads Qt's font database.
fc-cache -f
