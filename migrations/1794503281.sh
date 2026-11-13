echo "Point Google Chrome at the bundled extensions' current ids"

# Moving the CRX signing keys to 1Password gave the extensions new ids. Machines
# that installed Chrome's policy before that still force-install the old ids,
# which updates.xml no longer lists, so Chrome installs none of them.
omarchy-pkg-present google-chrome || exit 0

omarchy-install-browser-extensions chrome
