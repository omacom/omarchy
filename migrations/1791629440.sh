echo "Drop the unknown BrowserColorScheme key from Chromium browser policies"

source "$OMARCHY_PATH/install/helpers/browser-policy.sh"

# Chromium has no BrowserColorScheme policy, so chrome://policy flags the key as
# an error. Rewriting the theme color writes the policy without it.
for dir in "${BROWSER_POLICY_MANAGED_DIRS[@]}"; do
  if [[ -f $dir/color.json ]] && grep -Fq '"BrowserColorScheme"' "$dir/color.json"; then
    omarchy-theme-set-browser || true
    break
  fi
done
