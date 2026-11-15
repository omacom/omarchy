echo "Require an unlocked compositor for Polkit authentication"

sudo env OMARCHY_PATH="$OMARCHY_PATH" "$OMARCHY_PATH/bin/omarchy-apply-polkit"
