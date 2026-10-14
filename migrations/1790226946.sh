echo "Install the default Chromium privacy policy"

source "$OMARCHY_PATH/install/helpers/browser-policy.sh"

for dir in "${BROWSER_POLICY_MANAGED_DIRS[@]}"; do
  # [[ -f ]] reads the directory directly, so the common "already installed"
  # and "directory absent" cases cost no sudo at all; privilege is only
  # needed to actually write the file.
  [[ -f $dir/privacy.json ]] || browser_policy_install_privacy "$dir"
done
