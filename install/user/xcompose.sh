# Set default XCompose that is triggered with Shift + CapsLock
omarchy-refresh-xcompose

tee ~/.XCompose >/dev/null <<EOF
# Run omarchy-restart-xcompose to apply changes

# Include fast emoji access
include "%H/.XCompose.omarchy"

# Identification
<Multi_key> <space> <n> : "$OMARCHY_USER_NAME"
<Multi_key> <space> <e> : "$OMARCHY_USER_EMAIL"
EOF
