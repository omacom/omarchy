echo "Let the captive portal sign-in window reach the portal over plain HTTP"

source "$OMARCHY_PATH/install/helpers/browser-policy.sh"

# Markers are per-user, so another user may already have installed it exactly as install would.
policy_installed() {
  local file=$1/omarchy.json

  [[ -f $file && ! -L $file ]] &&
    [[ $(stat -c '%U:%G %a' "$file") == "root:root 644" ]] &&
    cmp -s "$OMARCHY_PATH/default/chromium/policies/omarchy.json" "$file"
}

for dir in "${BROWSER_POLICY_MANAGED_DIRS[@]}"; do
  if browser_policy_dir_hardened "$dir" && browser_policy_parents_hardened "$dir" && ! policy_installed "$dir"; then
    browser_policy_install_defaults "$dir"
  fi
done
