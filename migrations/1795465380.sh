echo "Pin Electron and Cursor password stores to gnome-libsecret on Hyprland"

# Electron cannot tell Hyprland from a desktop with no keyring. Shared Electron
# apps, and x86_64 Cursor, read electron-flags.conf unless a versioned
# electronN-flags.conf shadows it. aarch64 cursor-bin keeps Cursor's bundled
# launcher, which never reads those files. argv.json is what both Cursor
# launchers honor, so an existing file is updated and a missing one is created
# only when Cursor is installed.

omarchy-cmd-electron-password-store
omarchy-cmd-cursor-password-store --if-installed
