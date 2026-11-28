# Set default XCompose that is triggered with Shift + CapsLock
tee ~/.XCompose >/dev/null <<'EOF'
# Run omarchy-restart-xcompose to apply changes

# Include fast emoji access
include "/usr/share/omarchy/default/xcompose"

# Run omarchy setup git to add name and email shortcuts.
EOF
