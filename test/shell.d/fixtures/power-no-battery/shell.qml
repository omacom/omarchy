import QtQuick
import Quickshell
import "power"

// The real power panel with no battery behind it (the test runs with a
// dead system bus, so UPower has no display device): opening it must
// settle closed again without a binding loop, on laptops too, where
// the runtime smoke check cannot reach this path.
ShellRoot {
  id: test
  property bool failed: false

  function check(ok, message) {
    if (!ok) {
      failed = true
      console.log("RESULT fail " + message)
    }
  }

  Panel {
    id: panel
  }

  Timer {
    interval: 300
    running: true
    onTriggered: {
      test.check(panel.batteryPresent === false, "fixture has no battery")
      panel.open()
    }
  }

  Timer {
    interval: 900
    running: true
    onTriggered: {
      test.check(panel.opened === false, "panel without a battery settles closed after open")
      console.log(test.failed ? "RESULT fail" : "RESULT pass")
      Qt.quit()
    }
  }
}
