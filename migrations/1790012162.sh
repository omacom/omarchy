echo "Move Hermes to the self-updating runtime under ~/.hermes"

# The stub that built Hermes through mise had no checkout for `hermes update`
# to move. The installer retires it, and where that Hermes was in use, sets the
# runtime up the way the desktop app does.
omarchy-install-hermes-cli --migrate
