import QtQuick
import Quickshell
import "background" as BackgroundPlugin

ShellRoot {
  id: shell
  readonly property string fill: Quickshell.env("FILL_SETTING")

  function panels() {
    for (var child of background.data)
      if (child && child.instances !== undefined) return child.instances
    return []
  }

  BackgroundPlugin.Background {
    id: background
    shell: ({ shellConfig: shell.fill ? { background: { fill: shell.fill } } : {} })
  }

  Timer {
    interval: 1200
    running: true
    onTriggered: {
      var want = shell.fill || "cover"
      var path = background.displayedBackground
      var native = background.nativeSizes[path]
      var panel = shell.panels()[0]
      if (background.fill !== want) console.log("RESULT fail fill is " + background.fill + ", wanted " + want)
      else if (!native || !panel) console.log("RESULT fail no panel or native size yet")
      else {
        var size = panel.decodeSize(path)
        // Only cover may decode below the file's own size, because Qt
        // special-cases PreserveAspectCrop.
        var atNative = size.width === native.width && size.height === native.height
        if (want === "cover" ? atNative : !atNative) console.log("RESULT fail decode " + size.width + "x" + size.height + " for " + want)
        else console.log("RESULT pass")
      }
      Qt.quit()
    }
  }
}
