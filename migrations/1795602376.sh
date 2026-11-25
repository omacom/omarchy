echo "Offer to switch the default browser from Chromium to Google Chrome"

[[ $(omarchy-cmd-default-browser) == "chromium.desktop" ]] || exit 0

# The offer waits for the update running this to finish, so it must not hold
# the update's lock open.
[[ -z ${OMARCHY_UPDATE_LOCK_FD:-} ]] || exec {OMARCHY_UPDATE_LOCK_FD}>&-
setsid -f omarchy-default-browser-switch-to-chrome --offer </dev/null >/dev/null 2>&1
