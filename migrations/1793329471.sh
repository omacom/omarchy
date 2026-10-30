echo "Let the captive portal sign-in window reach the portal over plain HTTP"

source "$OMARCHY_PATH/install/helpers/browser-policy.sh"

for dir in "${BROWSER_POLICY_MANAGED_DIRS[@]}"; do
  if browser_policy_dir_hardened "$dir" && browser_policy_parents_hardened "$dir"; then
    browser_policy_install_defaults "$dir"
  fi
done
