echo "Offer to switch the default browser from Chromium to Google Chrome"

if [[ $(omarchy-cmd-default-browser) == "chromium.desktop" ]]; then
  omarchy-default-browser-switch-to-chrome --offer
fi
