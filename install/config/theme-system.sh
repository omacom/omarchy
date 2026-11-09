# Set links for Nautilus action icons
mkdir -p /usr/share/icons/Yaru/scalable/actions
ln -snf /usr/share/icons/Adwaita/symbolic/actions/go-previous-symbolic.svg \
          /usr/share/icons/Yaru/scalable/actions/go-previous-symbolic.svg
ln -snf /usr/share/icons/Adwaita/symbolic/actions/go-next-symbolic.svg \
          /usr/share/icons/Yaru/scalable/actions/go-next-symbolic.svg
gtk-update-icon-cache /usr/share/icons/Yaru &>/dev/null || true

# Seed the first run of Chrome and Chromium: follow system appearance ("device")
# instead of dark, and skip the terms-of-service dialog Chromium 151 turned on by
# default. Each reads initial_preferences from beside its own binary.
for browser_dir in /opt/google/chrome /usr/lib/chromium; do
  mkdir -p "$browser_dir"
  echo '{"distribution":{"require_eula":false},"browser":{"theme":{"color_scheme":0,"color_scheme2":0}}}' > \
    "$browser_dir/initial_preferences"
done
