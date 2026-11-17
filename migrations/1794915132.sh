echo "Install tiny-dfr to light the Touch Bar on 13-inch Apple Silicon MacBook Pros"

# New installs get tiny-dfr from the Apple Silicon package list. A compositor started before
# its seat rules keeps the Touch Bar's card, including after a hand install, until a reboot.
if omarchy-hw-aarch64-apple && omarchy-hw-match-device-tree apple,j293 apple,j493; then
  omarchy-pkg-add tiny-dfr
  omarchy-state set reboot-required
fi
