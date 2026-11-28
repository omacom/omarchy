echo "Keep 1Password display scaling consistent at login"

if omarchy-pkg-present 1password; then
  "$OMARCHY_PATH/bin/omarchy-refresh-1password-autostart"
fi
