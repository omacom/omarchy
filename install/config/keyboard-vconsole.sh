# Ensure the installer's KEYMAP also leaves an XKBLAYOUT for Plymouth/Hyprland.
# configure_keyboard (ISO) and systemd-firstboot usually write both; when the
# map has no row, XKBLAYOUT stays empty and the LUKS prompt falls back to US
# while the passphrase was enrolled under loadkeys (#8196). No UKI rebuild
# here — Limine still builds after this config phase.

source "$OMARCHY_PATH/install/helpers/keyboard-vconsole.sh"

omarchy_ensure_vconsole_xkb
