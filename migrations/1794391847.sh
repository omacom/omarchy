echo "Seed the 1Password extension for Google Chrome where Chromium has it"

# 1Password's installer only seeded Chromium's external extensions until Chrome
# became the default, so switching to Chrome left the extension behind. Chrome
# reads its own directory whenever it is installed.
extension=aeblfdkhhhdcdjpifhhbdiojplfjncoa.json
if [[ -f /usr/share/chromium/extensions/$extension && ! -f /usr/share/google-chrome/extensions/$extension ]]; then
  sudo install -D -m 644 "/usr/share/chromium/extensions/$extension" "/usr/share/google-chrome/extensions/$extension"
fi
