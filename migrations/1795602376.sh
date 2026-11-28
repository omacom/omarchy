echo "Offer to switch the default browser from Chromium to Google Chrome"

[[ $(omarchy-cmd-default-browser) == "chromium.desktop" ]] || exit 0

# An update from a TTY or SSH has no desktop to show the offer on, so keep it
# pending for the next graphical login without stopping the update.
if ! omarchy-default-browser-switch-to-chrome --offer; then
  echo "No desktop to offer the switch on yet; it will be offered at the next login"
  exit 75
fi
