# Set links for Nautilus action icons
mkdir -p /usr/share/icons/Yaru/scalable/actions
ln -snf /usr/share/icons/Adwaita/symbolic/actions/go-previous-symbolic.svg \
          /usr/share/icons/Yaru/scalable/actions/go-previous-symbolic.svg
ln -snf /usr/share/icons/Adwaita/symbolic/actions/go-next-symbolic.svg \
          /usr/share/icons/Yaru/scalable/actions/go-next-symbolic.svg
gtk-update-icon-cache /usr/share/icons/Yaru &>/dev/null || true

# Seed Brave Origin's first run to follow system appearance ("device").
mkdir -p /opt/brave-origin-bin
echo '{"distribution":{"require_eula":false},"browser":{"theme":{"color_scheme":0,"color_scheme2":0}}}' > \
  /opt/brave-origin-bin/initial_preferences
