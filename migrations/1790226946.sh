echo "Install the default Chromium privacy policy"

source "$OMARCHY_PATH/install/helpers/browser-policy.sh"

for dir in "${BROWSER_POLICY_MANAGED_DIRS[@]}"; do
  # Idempotent across users: once one account installs the root-owned file,
  # later runs for other accounts no-op.
  as_root test -f "$dir/privacy.json" || browser_policy_install_privacy "$dir"
done
