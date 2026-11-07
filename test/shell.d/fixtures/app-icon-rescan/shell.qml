import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons

// The real AppLibrary with its first icon scan held at its last root by the
// test's find stub: an icon added behind the scan and a refresh asked for while
// it runs must still reach the index once the scan is let go.
ShellRoot {
  id: root

  readonly property string rootPath: Quickshell.env("OMARCHY_PATH")
  readonly property string resultPath: Quickshell.env("OMARCHY_QML_TEST_RESULT")
  property var library: null
  property bool done: false

  Item { id: host }

  function finish(ok, message) {
    if (root.done) return
    root.done = true
    var payload = JSON.stringify({ ok: ok, message: message })
    var quoted = "'" + payload.replace(/'/g, "'\\''") + "'"
    Quickshell.execDetached(["bash", "-c", "printf '%s' " + quoted + " > \"$1\"", "_", root.resultPath])
  }

  // Waits until the first scan is held, then adds an icon to a root it has
  // already walked.
  Process {
    id: addIcon
    command: ["bash", "-c", 'until [[ -s $SCAN_LOG ]]; do sleep 0.02; done; mkdir -p "$HOME/.icons/hicolor/apps"; : >"$HOME/.icons/hicolor/apps/omarchy-rescan-probe.svg"']
    onExited: {
      root.library.refreshIcons()
      releaseScan.running = true
    }
  }

  Process {
    id: releaseScan
    command: ["bash", "-c", 'rm -f "$SCAN_GATE"']
    onExited: poll.running = true
  }

  Timer {
    id: poll
    interval: 100
    repeat: true
    onTriggered: {
      if (root.library.iconIndex["omarchy-rescan-probe"] !== undefined) root.finish(true, "the queued rescan indexed the new icon")
    }
  }

  Timer {
    interval: 8000
    running: true
    onTriggered: root.finish(false, "a refresh asked for during a running scan never reached the icon index")
  }

  Component.onCompleted: {
    var component = Qt.createComponent("file://" + rootPath + "/shell/services/AppLibrary.qml", Component.PreferSynchronous)
    if (component.status !== Component.Ready) {
      root.finish(false, component.errorString())
      return
    }
    root.library = component.createObject(host)
    if (!root.library) {
      root.finish(false, component.errorString())
      return
    }
    addIcon.running = true
  }
}
