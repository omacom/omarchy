echo "Give GTK apps the backdrop blur the see-through windows ask the compositor for"

# GTK 4.24 blurs a window only where the app asks for it, and GTK asks for
# nothing without a CSS backdrop-filter, so GTK apps stopped being blurred
# behind see-through windows. Omarchy imports that backdrop blur for Glassy
# only, so it missed every machine that chooses its own transparency; it
# follows see-through windows now. Reapply it for the mode already in use,
# which leaves an opaque machine and a theme that owns the file alone.
# Theme switches and window mode changes rewrite the same files under this lock.
flock "${XDG_RUNTIME_DIR:-/tmp}/omarchy-theme-set.lock" omarchy-theme-set-glass
