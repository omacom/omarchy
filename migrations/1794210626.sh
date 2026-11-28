echo "Install Omarchy's browser extensions in Google Chrome, which ignores --load-extension"

# Only for machines that already chose Chrome: Chromium and every other browser
# stay exactly as they are, and nobody is moved to Chrome.
omarchy-pkg-present google-chrome || exit 0

source "$OMARCHY_PATH/install/helpers/browser-policy.sh"

dir=/etc/opt/chrome/policies/managed
if browser_policy_dir_hardened "$dir" && browser_policy_parents_hardened "$dir"; then
  browser_policy_install_defaults "$dir"
fi

# The native hosts in Chrome's profile are copies that admit only the Chromium
# ids, so rewrite them to admit the CRXs' ids as well.
omarchy-install-chromium-copy-url
omarchy-install-chromium-ytdlp
