echo "Add the Omashade extension to Chromium-based browsers"

source "$OMARCHY_PATH/install/helpers/browser-flags.sh"

OMASHADE_EXT="$OMARCHY_PATH/default/chromium/extensions/omashade"

for conf in chromium chrome google-chrome brave brave-beta brave-nightly brave-origin microsoft-edge-stable; do
  file="$HOME/.config/$conf-flags.conf"
  # A file that already names Omashade, even in a comment, was set up by hand.
  if [[ -f $file ]] && ! grep -q "extensions/omashade" "$file"; then
    browser_flags_add_extensions "$file" "$OMASHADE_EXT"
  fi
done

# Register the native messaging host that streams the theme palette to it.
omarchy-install-chromium-omashade
