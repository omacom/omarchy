# Set default XCompose that is triggered with CapsLock
user_name=${OMARCHY_USER_NAME:-}
user_email=${OMARCHY_USER_EMAIL:-}

# A runtime refresh (omarchy-provision-user --force) runs without install
# inputs; rewriting then would blank the identification lines of an existing
# file, so leave it alone.
if [[ ! -s ~/.XCompose || -n ${user_name//[[:space:]]/} || -n ${user_email//[[:space:]]/} ]]; then
  tee ~/.XCompose >/dev/null <<EOF
# Run omarchy-restart-xcompose to apply changes

# Include fast emoji access
include "/usr/share/omarchy/default/xcompose"

# Identification
<Multi_key> <space> <n> : "$user_name"
<Multi_key> <space> <e> : "$user_email"
EOF
fi
