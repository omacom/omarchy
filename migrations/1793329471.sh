echo "Let the captive portal sign-in window reach the portal over plain HTTP"

source "$OMARCHY_PATH/install/helpers/browser-policy.sh"

# Markers are per-user, so another user may already have installed it; only ask for root when it differs.
for dir in "${BROWSER_POLICY_MANAGED_DIRS[@]}"; do
  if browser_policy_dir_hardened "$dir" && browser_policy_parents_hardened "$dir" &&
    ! cmp -s "$OMARCHY_PATH/default/chromium/policies/omarchy.json" "$dir/omarchy.json"; then
    browser_policy_install_defaults "$dir"
  fi
done
