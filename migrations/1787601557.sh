echo "Retry the Copy URL shortcut repair after install-time migration stamping"

# Retry for existing installs that already stamped the original migration.
# First-run and login cover profiles that arrive after this migration runs.
omarchy-cmd-repair-chromium-copy-url --prompt
