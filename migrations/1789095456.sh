echo "Remove automatic project bin directories from PATH"

# The repair lives in omarchy-mise-remove-work-bin-path so a machine without
# Mise still finishes it. A leftover Work trust grant keeps this migration
# pending until Mise can revoke it.
omarchy-mise-remove-work-bin-path
