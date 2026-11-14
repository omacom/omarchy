echo "Point Voxtype evdev hotkey users at the Hyprland dictation binds"

# 1787865477 dropped the blanket input grant: membership gives raw read/write
# access to /dev/input/event*, so any process running as the user can capture
# keystrokes. Someone who set Voxtype's `[hotkey] enabled = true` read
# /dev/input through that grant, so their hotkey stopped responding while the
# daemon kept running and reporting itself ready (#12013).
#
# Told, not regranted: Hyprland now binds hold Right Alt for push-to-talk and
# Alt + Space to toggle, neither of which needs the group.
# Handing input back through sudo on the strength of user-writable config would
# undo 1787865477 for a feature that no longer needs it.

if omarchy-cmd-present voxtype &&
  ! id -nG "$USER" | grep -qw input &&
  [[ $(RUST_LOG=off voxtype config get hotkey.enabled 2>/dev/null) == "true" ]]; then
  message="Voxtype's own hotkey can no longer read the keyboard. Hold Right Alt to dictate, or toggle with Alt + Space, and set [hotkey] enabled = false in ~/.config/voxtype/config.toml."
  echo "  $message"
  omarchy-notification-send -u critical "Voxtype hotkey stopped working" "$message" || true
fi
