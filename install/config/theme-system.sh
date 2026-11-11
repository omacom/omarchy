# Seed Chromium's first run: follow system appearance ("device") instead of dark,
# and skip the terms-of-service dialog Chromium 151 turned on by default.
mkdir -p /usr/lib/chromium
echo '{"distribution":{"require_eula":false},"browser":{"theme":{"color_scheme":0,"color_scheme2":0}}}' > \
  /usr/lib/chromium/initial_preferences
