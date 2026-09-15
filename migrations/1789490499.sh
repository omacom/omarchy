echo "Restore the input group for users who opted into Voxtype's evdev hotkey"

# 1787865477 dropped the blanket input grant, which was right: membership gives
# raw read/write access to /dev/input/event*, so any process running as the user
# can capture keystrokes. It kept the group for the two opt-in features that
# need it, Xbox controllers and ydotool, but Voxtype's own hotkey is a third and
# was missed (#12013).
#
# Omarchy's Voxtype setup does not regress: default/voxtype/config.toml ships
# `[hotkey] enabled = false` and binds dictation through the compositor, which
# needs no membership. Someone who set `enabled = true` reads /dev/input
# directly, so their hotkey stopped responding while the daemon kept running and
# reporting itself ready. A bare modifier such as RIGHTCTRL cannot be bound in
# Hyprland at all, so that configuration has no compositor-side fallback.
#
# Gated on the opt-in rather than on the package: restoring the grant for every
# Voxtype user would hand raw input access back to the majority who never
# needed it.

if omarchy-cmd-present voxtype &&
  ! id -nG "$USER" | grep -qw input &&
  [[ $(voxtype config get hotkey.enabled 2>/dev/null) == "true" ]]; then
  sudo gpasswd -a "$USER" input >/dev/null
  echo "Restored $USER to the input group for the Voxtype hotkey. Log out and back in to apply."
  omarchy-state set reboot-required
fi
