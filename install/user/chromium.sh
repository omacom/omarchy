# Chrome ships in the base packages, so it never goes through
# omarchy-install-browser, and fresh installs mark every migration as already
# applied. /etc/skel gives it its flags, but the native messaging hosts the
# bundled extensions talk to have to be registered here.
omarchy-install-chromium-copy-url
omarchy-install-chromium-ytdlp
