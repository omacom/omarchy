echo "Move the keyboard layout widget to the right side of the bar"

# An earlier migration put the widget just right of the clock. It now leads the
# right-hand cluster. A widget the user moved out of the center stays put.
omarchy-bar move omarchy.keyboard-layout --from-section center --section right --index 0 || true
