import QtQuick
import Quickshell.Io

// An IpcHandler the shell can also answer over its own socket (see
// IpcRegistry), so omarchy-shell reaches it without a qs ipc client. qs ipc
// still reaches it as before.
IpcHandler {
  id: handler

  Component.onCompleted: IpcRegistry.register(handler)
  Component.onDestruction: IpcRegistry.unregister(handler)
}
