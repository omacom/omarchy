echo "Add Kagi to the Firefox and Zen search engine list"

source "$OMARCHY_PATH/install/helpers/browser-policy.sh"

for distribution in "${BROWSER_POLICY_FIREFOX_DIRS[@]}"; do
  # Only rewrite policy Omarchy owns; an administrator's own file is left alone.
  browser_policy_firefox_hardened "$distribution" || continue

  if grep -qF 'kagi.com/search' "$distribution/policies.json"; then
    continue
  fi

  browser_policy_install_firefox_policies "$distribution"
done
