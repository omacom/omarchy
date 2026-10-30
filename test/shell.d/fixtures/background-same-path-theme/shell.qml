import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import "plugins/background" as BackgroundPlugin

ShellRoot {
  id: shell
  readonly property string resultPath: Quickshell.env("OMARCHY_QML_TEST_RESULT")
  readonly property string stage: Quickshell.env("BACKGROUND_TEST_STAGE")
  readonly property string themePath: Quickshell.env("HOME") + "/.local/state/omarchy/current/theme/backgrounds/1-same-name.png"

  BackgroundPlugin.Background { id: background }

  // The lock keeps the wallpaper decoded ahead of time under its own version,
  // at the size the desktop decodes it too (here the file's own size).
  Image {
    id: lockPredecode
    visible: false
    source: Util.fileUrl(shell.themePath) + "?v=1"
    sourceSize: Qt.size(128, 128)
    fillMode: Image.PreserveAspectCrop
    asynchronous: true
    cache: true
  }

  function finish(ok, message) {
    var payload = JSON.stringify({ ok: ok, message: message })
    Quickshell.execDetached(["bash", "-c", 'printf "%s" "$1" > "$2"', "result", payload, resultPath])
  }

  function firstBase() {
    for (var i = 0; i < background.data.length; i++) {
      var instances = background.data[i].instances
      if (!instances || instances.length === 0) continue
      var children = instances[0].contentItem.children
      for (var j = 0; j < children.length; j++) {
        if (children[j].path !== undefined && children[j].ready !== undefined) return children[j]
      }
    }
    return null
  }

  // The next theme names its background as the previous theme did, and
  // replaces the file behind that path, as omarchy-theme-set does.
  Process {
    id: swapTheme
    command: ["mv", shell.stage + "/next.png", shell.themePath]
    onExited: background.transitionBackgroundWithTheme("", shell.stage + "/snapshot.png", shell.themePath, "", "")
  }

  Timer {
    interval: 100
    repeat: true
    running: true
    property bool swapped: false
    property int ticks: 0
    onTriggered: {
      ticks += 1
      var base = shell.firstBase()
      if (!swapped) {
        if (base && base.ready && background.displayedBackground === shell.themePath && lockPredecode.status === Image.Ready) {
          swapped = true
          swapTheme.running = true
        } else if (ticks > 50) {
          stop()
          shell.finish(false, "the first theme's background never loaded")
        }
        return
      }
      // The base is grabbed once the transition settles, or as it stands when
      // it never does.
      if ((background.incomingBackground === "" && base.ready) || ticks > 80) {
        stop()
        base.grabToImage(function(result) {
          result.saveToFile(shell.stage + "/base.png")
          shell.finish(true, "grabbed")
        }, Qt.size(16, 16))
      }
    }
  }
}
