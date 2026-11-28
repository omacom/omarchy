# Set default XCompose that is triggered with Shift + CapsLock
tee ~/.XCompose >/dev/null <<'EOF'
# Run omarchy-restart-xcompose to apply changes

# Include fast emoji access
include "/usr/share/omarchy/default/xcompose"

# Identification (filled in by `omarchy setup git`)
EOF

# The installer no longer collects a Git identity (Setup > Git does), so the
# variables below are usually unset on a fresh install: seed the shortcuts
# only when a caller still provides one, never as empty Compose rules.
seed_compose_identity() {
  local key=$1 value=${2:-}
  [[ -n ${value//[[:space:]]/} ]] || return 0
  printf '<Multi_key> <space> <%s> : "%s"\n' "$key" "$value" >>~/.XCompose
}
seed_compose_identity n "$OMARCHY_USER_NAME"
seed_compose_identity e "$OMARCHY_USER_EMAIL"
