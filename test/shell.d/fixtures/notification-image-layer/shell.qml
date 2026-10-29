import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import "plugins/notifications"

ShellRoot {
  id: root
  property var picture: null
  property int ticks: 0
  property bool reloading: false
  property int loads: 0
  property int dropped: 0

  function findImage(item) {
    if (item.sourceSize !== undefined && item.status !== undefined) return item
    for (var child of item.children || []) {
      var found = findImage(child)
      if (found) return found
    }
    return null
  }

  FileView { id: result; path: Quickshell.env("OMARCHY_QML_TEST_RESULT") }
  FloatingWindow {
    implicitWidth: 500
    implicitHeight: 180
    visible: true
    Toast {
      id: toast
      row: ({ app: "Image test", summary: "Reloading a notification image", body: "Keep its effect alive", image: Quickshell.env("OMARCHY_NOTIFICATION_TEST_IMAGE") })
    }
  }

  Timer {
    interval: 50
    running: true
    repeat: true
    onTriggered: {
      root.ticks++
      if (!root.picture) root.picture = root.findImage(toast)
      var picture = root.picture
      if (root.ticks > 80) {
        result.setText(JSON.stringify({ ok: false, reason: "Notification image did not reload" }))
        stop()
        quitter.start()
      } else if (picture && picture.status === Image.Ready) {
        if (!root.reloading) {
          if (Style.cornerRadius !== 8) return
          picture.layer.enabledChanged.connect(function() {
            if (!picture.layer.enabled) root.dropped++
          })
          picture.statusChanged.connect(function() {
            if (picture.status === Image.Loading) root.loads++
          })
          root.reloading = true
          // A DPR change changes sourceSize on the real Toast Image. Its
          // asynchronous reload must not destroy the effect while Qt is
          // walking the image's siblings to deliver that same DPR change.
          picture.sourceSize = Qt.size(picture.sourceSize.width + 1, picture.sourceSize.height + 1)
        } else {
          result.setText(JSON.stringify({ ok: root.loads > 0 && root.dropped === 0 && picture.layer.enabled,
                                          reloads: root.loads, disabledDuringReload: root.dropped }))
          stop()
          quitter.start()
        }
      }
    }
  }
  Timer { id: quitter; interval: 100; onTriggered: Qt.quit() }
}
