pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Hyprland

// Caps Lock turning on or off, which Hyprland raises no event for: it only
// reports the lock when asked, through hyprctl devices. default/hypr/input.lua
// binds the key's release, without taking it from apps, to this shortcut, so
// the keyboard widget reads the seat again when the lock may have changed
// rather than asking on a timer. The shortcut is registered here once instead
// of by every monitor's widget.
Singleton {
  id: root

  signal toggled()

  GlobalShortcut {
    appid: "omarchy"
    name: "caps-lock"
    description: "Read the Caps Lock state again"
    // Hyprland hands a release bind's shortcut over as a release; a bind
    // changed to fire on the press would hand over a press instead.
    onPressed: root.toggled()
    onReleased: root.toggled()
  }
}
