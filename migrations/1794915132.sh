echo "Install tiny-dfr to light the Touch Bar on 13-inch Apple Silicon MacBook Pros"

# New installs get tiny-dfr from the Apple Silicon package list. The running
# compositor keeps the Touch Bar's card until its seat rules apply at the next boot.
if omarchy-hw-aarch64-apple && omarchy-hw-match-device-tree apple,j293 apple,j493 && omarchy-pkg-missing tiny-dfr; then
  omarchy-pkg-add tiny-dfr
  omarchy-state set reboot-required
fi
