import QtQuick
import Quickshell.Io

// An IpcHandler the shell can also answer over its own socket (see
// IpcRegistry), so omarchy-shell reaches it without a qs ipc client. qs ipc
// still reaches it as before.
//
// Every bar builds its own copy of a widget, so a target can have one handler
// per monitor. Quickshell answers with the first and warns about every other,
// so only the first live copy that wants the target enables itself, and the
// next takes over when that one goes. Set `active` where you'd set `enabled`.
IpcHandler {
  id: handler

  property bool active: true

  enabled: active && IpcRegistry.leads(handler, IpcRegistry.revision)

  onActiveChanged: IpcRegistry.touch()
  onTargetChanged: IpcRegistry.touch()
  Component.onCompleted: IpcRegistry.register(handler)
  Component.onDestruction: IpcRegistry.unregister(handler)
}
