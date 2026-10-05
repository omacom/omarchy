import Quickshell
import QtQuick
import "background"

ShellRoot {
  BackgroundVariantCatalog {
    path: Quickshell.env("VARIANT_TEST_DIR") + "/design.png"
    timeoutSeconds: 1
    onResolved: {
      if (busy || candidates.length !== 2 || candidates[1].width !== 210) {
        console.error("FAIL partial variant catalog: " + JSON.stringify(candidates))
      } else {
        console.log("PASS partial variant catalog")
      }
      Qt.quit()
    }
  }

  Timer {
    running: true
    interval: 5000
    onTriggered: {
      console.error("FAIL partial variant catalog: timeout")
      Qt.quit()
    }
  }
}
