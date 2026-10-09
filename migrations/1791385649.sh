echo "Save the history of your Omarchy configs (omarchy dots)"

# Stands down quietly when another dotfile manager keeps these files, when the
# user turned dots off, or when mise is too old; never stops the update.
omarchy-dots-enable --auto || echo "Omarchy dots stayed off; turn them on later with: omarchy dots enable"
