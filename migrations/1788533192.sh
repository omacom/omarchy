echo "Install a local speech backend so Web Speech works in Brave"

# Chromium ships Google cloud voices; only Brave needs the local backend.
# Machines that never installed Brave through Omarchy are left alone.
source "$OMARCHY_PATH/install/helpers/brave-web-speech.sh"

if omarchy-pkg-present brave-bin; then
  omarchy_ensure_brave_web_speech "$HOME/.config/brave-flags.conf"
fi

if omarchy-pkg-present brave-origin-bin; then
  omarchy_ensure_brave_web_speech "$HOME/.config/brave-origin-flags.conf"
fi
