import QtQuick
import Quickshell.Io

// An IpcHandler the shell can also answer over its own socket (see
// IpcRegistry), so omarchy-shell reaches it without a qs ipc client. qs ipc
// still reaches it as before.
//
// Quickshell uses only the first enabled handler of a target, and it writes a
// warning for each other enabled handler of that target. The bar makes a copy
// of each widget for each screen, so ShellIpc enables only one handler of a
// target (see IpcRegistry.holds). When the shell destroys that handler, the
// next handler becomes enabled. To disable a handler, set active to false,
// not enabled.
IpcHandler {
  id: handler

  property bool active: true

  enabled: IpcRegistry.holds(handler)

  Component.onCompleted: IpcRegistry.register(handler)
  Component.onDestruction: IpcRegistry.unregister(handler)
}
