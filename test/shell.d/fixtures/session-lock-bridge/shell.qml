import Quickshell
import Quickshell.Io

ShellRoot {
  id: root

  property bool secureState: true

  SessionLockBridge {
    id: bridge
    secure: root.secureState
  }

  IpcHandler {
    target: "session-lock-bridge-test"

    function setSecure(secure: bool): string {
      root.secureState = secure
      return "ok"
    }

    function status(): string {
      return JSON.stringify({
        secure: root.secureState,
        ready: bridge.ready,
        platform: Quickshell.env("QT_QPA_PLATFORM"),
        waylandDisplay: Quickshell.env("WAYLAND_DISPLAY"),
        x11Display: Quickshell.env("DISPLAY")
      })
    }
  }
}
