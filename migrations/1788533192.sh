echo "Install a local speech backend so Web Speech works in Brave"

# Chromium ships Google cloud voices; only Brave needs the local backend.
# Skip machines that never installed Brave through Omarchy.
if omarchy-pkg-missing brave-bin && omarchy-pkg-missing brave-origin-bin; then
  exit 0
fi

source "$OMARCHY_PATH/install/helpers/brave-web-speech.sh"
omarchy_ensure_brave_web_speech
