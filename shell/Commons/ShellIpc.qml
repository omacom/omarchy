import QtQuick
import Quickshell.Io

// An IpcHandler the shell can also answer over its own socket (see
// IpcRegistry), so omarchy-shell reaches it without a qs ipc client. qs ipc
// still reaches it as before.
//
// Every bar builds its own copy of a widget, so a target can have one handler
// per monitor. Quickshell answers with the first and warns about every other,
// so only the first live copy for a target enables itself, and the next takes
// over when that one goes. One that shouldn't answer leaves its target empty;
// a property of its own would add a change signal, which Quickshell warns
// about on an IPC handler.
IpcHandler {
  id: handler

  enabled: IpcRegistry.leads(handler, IpcRegistry.revision)

  onTargetChanged: IpcRegistry.touch()
  Component.onCompleted: IpcRegistry.register(handler)
  Component.onDestruction: IpcRegistry.unregister(handler)
}
