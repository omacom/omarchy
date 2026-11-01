# Chuwi MiniBook X: show the disk unlock prompt, boot splash and TTYs landscape.
#
# The DSI panel is natively portrait (1200x1920) and mounted sideways. Tell the
# kernel, so everything before Hyprland is drawn the right way up. Hyprland
# ignores this hint; install/user/hardware/chuwi/minibook-x-display.sh rotates
# the desktop.

limine_config_dir=${OMARCHY_MINIBOOK_X_LIMINE_CONFIG_DIR:-/etc/limine-entry-tool.d}

if omarchy-hw-chuwi-minibook-x; then
  mkdir -p "$limine_config_dir"
  cat >"$limine_config_dir/chuwi-minibook-x.conf" <<'CONF'
# Chuwi MiniBook X: the panel is mounted sideways; see
# install/hardware/chuwi/fix-minibook-x-panel.sh.
KERNEL_CMDLINE[default]+=" video=DSI-1:panel_orientation=right_side_up"
CONF
fi
