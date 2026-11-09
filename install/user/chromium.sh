# Chrome ships in the base packages, so it never goes through
# omarchy-install-browser, and fresh installs mark every migration as already
# applied. Give it the flags /etc/skel gives Chromium, and register the native
# messaging hosts the bundled extensions talk to.
mkdir -p ~/.config
[[ -f ~/.config/chrome-flags.conf ]] || cp "$OMARCHY_PATH/config/chromium-flags.conf" ~/.config/chrome-flags.conf
omarchy-install-chromium-copy-url
omarchy-install-chromium-ytdlp
