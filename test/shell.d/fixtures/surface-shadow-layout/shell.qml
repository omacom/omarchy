import QtQuick
import QtQuick.Window
import Quickshell
import qs.Commons as Commons
import qs.Ui

ShellRoot {
  id: root
  property int stage: 0
  property real originalHeight: 0

  function fail(message) {
    console.log("RESULT fail " + message)
    Qt.quit()
  }

  Window {
    width: 600
    height: 350
    visible: true
    MultiSelect {
      id: picker
      x: 40
      y: 170
      width: 300
      height: 40
      showLabel: false
      options: Array.from({ length: 25 }, function(_, i) { return "Option " + i })
    }
  }

  Timer {
    interval: 150
    running: true
    repeat: true
    onTriggered: {
      if (root.stage === 0) {
        Commons.Color.loadUserShell('[popups]\nshadow-alpha = 0')
        picker.open()
      } else if (root.stage === 1) {
        root.originalHeight = picker.testedPopup.implicitHeight
        Commons.Color.loadUserShell('[popups]\nshadow-alpha = 0.5\nshadow-blur = 64')
      } else if (root.stage === 2) {
        var popup = picker.testedPopup
        if (!picker.popupOpen || popup.implicitHeight >= root.originalHeight
            || popup._anchorY + popup.implicitHeight + popup.bottomMargin > 350.1) {
          root.fail("an open list did not shrink when live shadow clearance increased")
          return
        }
        Commons.Color.loadUserShell('[popups]\nshadow-alpha = 0')
      } else {
        if (!picker.popupOpen || Math.abs(picker.testedPopup.implicitHeight - root.originalHeight) > 0.1) {
          root.fail("an open list did not recover its height after disabling shadows")
          return
        }
        console.log("RESULT pass")
        Qt.quit()
      }
      root.stage++
    }
  }
}
