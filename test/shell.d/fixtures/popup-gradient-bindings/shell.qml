import QtQuick
import Quickshell
import qs.Commons as Commons
import qs.Ui

ShellRoot {
  id: root
  property int stage: 0

  function fail(message) {
    console.log("RESULT fail " + message)
    Qt.quit()
  }

  PanelSlider {
    id: solidHost
    width: 200
    tickCount: 7
  }
  PanelSlider {
    id: popupHost
    width: 200
    tickCount: 7
    surfaceFillSpec: Commons.Color.popups.backgroundSpec
  }

  Timer {
    interval: 100
    running: true
    repeat: true
    onTriggered: {
      if (root.stage === 0) {
        Commons.Color.loadUserShell('[popups]\nbackground = "#112233 #445566 90deg"')
      } else if (root.stage === 1) {
        if (solidHost.gradientCard || !popupHost.gradientCard) {
          root.fail("a solid host inherited unrelated popup gradient styling")
          return
        }
        solidHost.surfaceFillSpec = { gradient: { enabled: false } }
      } else if (root.stage === 2) {
        if (solidHost.gradientCard || !popupHost.gradientCard) {
          root.fail("an explicit solid host inherited unrelated popup gradient styling")
          return
        }
        Commons.Color.loadUserShell('[popups]\nbackground = "#112233"')
      } else {
        if (solidHost.gradientCard || popupHost.gradientCard) {
          root.fail("solid popup hosts did not restore solid slider styling")
          return
        }
        console.log("RESULT pass")
        Qt.quit()
      }
      root.stage++
    }
  }
}
