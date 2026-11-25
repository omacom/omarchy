import QtQuick
import Quickshell
import Quickshell.Io
import "lock" as Lock
ShellRoot {
  id: test
  property int attempts: 0
  LockPreloads { id: preloads }
  PanelWindow {
    anchors { top: true; bottom: true; left: true; right: true }
    Lock.LockView {
      id: preparedView
      width: parent.width / 2; height: parent.height
      preparedBackground: preloads.instances.length ? preloads.instances[0].resolution : null
      backgroundPath: Quickshell.env("LOCK_CANONICAL")
      inputEnabled: false
    }
    Lock.LockView {
      id: independentView
      x: parent.width / 2; width: parent.width / 2; height: parent.height
      backgroundPath: Quickshell.env("LOCK_CANONICAL")
      inputEnabled: false
    }
  }
  function wallpaperReady(item) {
    if (item.objectName === "lockWallpaper") return item.ready
    for (var i = 0; i < item.children.length; i++) if (wallpaperReady(item.children[i])) return true
    return false
  }
  Timer {
    interval: 100; running: true; repeat: true
    onTriggered: {
      test.attempts += 1
      if (preparedView.resolution.canonicalOnly && independentView.resolution.canonicalOnly &&
          preparedView.resolution.resolvedPath === Quickshell.env("LOCK_CANONICAL") &&
          independentView.resolution.resolvedPath === Quickshell.env("LOCK_CANONICAL") &&
          test.wallpaperReady(preparedView) && test.wallpaperReady(independentView)) {
        stop()
        console.log("RESULT pass lock preload and standalone lock view recover canonical pixels")
        if (Quickshell.env("LOCK_CAPTURE")) capture.running = true
        else Qt.quit()
      } else if (test.attempts > 40) {
        console.log("RESULT fail lock recovery timed out")
        Qt.quit()
      }
    }
  }
  Process { id: capture; command: ["grim", Quickshell.env("LOCK_CAPTURE")]; onExited: Qt.quit() }
}
