echo "Keep XCompose includes readable inside application sandboxes"

# Repair the include without restarting fcitx5; existing XIM clients retain
# objects owned by that process. The next login reads the repaired table.
omarchy-refresh-xcompose
