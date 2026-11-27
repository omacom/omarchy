# Seed the first run of Chrome and Chromium: follow system appearance ("device")
# instead of dark, and skip the terms-of-service dialog Chromium 151 turned on by
# default. Each reads initial_preferences from beside its own binary.
for browser_dir in /opt/google/chrome /usr/lib/chromium; do
  mkdir -p "$browser_dir"
  echo '{"distribution":{"require_eula":false},"browser":{"theme":{"color_scheme":0,"color_scheme2":0}}}' > \
    "$browser_dir/initial_preferences"
done
