echo "Leave Firefox and Zen updates to pacman instead of their own updater"

source "$OMARCHY_PATH/install/helpers/browser-policy.sh"

for dir in "${BROWSER_POLICY_FIREFOX_DIRS[@]}"; do
  if browser_policy_firefox_hardened "$dir"; then
    browser_policy_firefox_disable_app_update "$dir"
  fi
done
