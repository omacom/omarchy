pragma Singleton
import Quickshell
import QtQuick

// The outputs the shell may put windows on.
//
// Qt reports a nameless, zero-sized placeholder QScreen while the compositor
// has no outputs (the only monitor dropped its link in standby, say), and
// Hyprland's headless FALLBACK output comes and goes around it. A layer-shell
// window created on either has no real wl_output behind it: Quickshell logs
// "Layershell screen does not correspond to a real screen", the compositor
// picks whatever it has, and when that output is removed the EGL surface
// fails and Qt takes the whole Wayland connection down ("The Wayland
// connection experienced a fatal error"), killing the shell. Every Variants
// that maps a window per output therefore reads `real` rather than
// `Quickshell.screens`, and the lock service asks the same question before
// it locks.
QtObject {
  id: root

  function isReal(screen) {
    return !!(screen && screen.name && screen.width > 0 && screen.height > 0)
  }

  function filter(screens) {
    var list = screens || []
    var real = []
    for (var i = 0; i < list.length; i++) {
      if (isReal(list[i])) real.push(list[i])
    }
    return real
  }

  readonly property var real: filter(Quickshell.screens)
  readonly property bool any: real.length > 0
}
