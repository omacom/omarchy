# Set default XCompose that is triggered with Shift + CapsLock. A home adopted
# from another drive keeps the one its owner already has.
if [[ ${OMARCHY_ADOPTED_HOME:-0} == "1" && -e ~/.XCompose ]]; then
  return 0
fi

tee ~/.XCompose >/dev/null <<EOF
# Run omarchy-restart-xcompose to apply changes

# Include fast emoji access
include "/usr/share/omarchy/default/xcompose"

# Identification
<Multi_key> <space> <n> : "$OMARCHY_USER_NAME"
<Multi_key> <space> <e> : "$OMARCHY_USER_EMAIL"
EOF
