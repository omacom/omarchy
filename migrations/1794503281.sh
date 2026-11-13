echo "Point Google Chrome at the bundled extensions' current ids"

# Moving the CRX signing keys to 1Password gave the extensions new ids. Machines
# that installed Chrome's policy before that still force-install the old ids,
# which updates.xml no longer lists, so Chrome installs none of them.
omarchy-pkg-present google-chrome || exit 0

source "$OMARCHY_PATH/install/helpers/browser-policy.sh"

dir=/etc/opt/chrome/policies/managed
if browser_policy_dir_hardened "$dir" && browser_policy_parents_hardened "$dir"; then
  browser_policy_install_defaults "$dir"
fi

# The native hosts must admit the new ids too, or Copy URL and yt-dlp can't reach them.
omarchy-install-chromium-copy-url
omarchy-install-chromium-ytdlp
