import Quickshell
import QtQuick
import "background"

ShellRoot {
  BackgroundVariantCatalog {
    id: catalog
    path: Quickshell.env("VARIANT_TEST_DIR") + "/design.png"
    property int step: 0
    onResolved: {
      if (candidates.length !== 2 || candidates[1].width !== 210) {
        console.error("FAIL variant catalog: " + JSON.stringify(candidates))
        Qt.quit()
      } else if (step === 0) {
        step = 1
        // Begin a scan, then supersede it while its Process is still running.
        path = Quickshell.env("VARIANT_TEST_DIR") + "/missing.png"
        catalog.start()
        path = Quickshell.env("VARIANT_TEST_DIR") + "/design.png"
        revision++
      } else {
        console.log("PASS variant catalog")
        Qt.quit()
      }
    }
  }

  Timer {
    running: true
    interval: 12000
    onTriggered: {
      console.error("FAIL variant catalog: timeout")
      Qt.quit()
    }
  }
}
