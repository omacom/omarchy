import QtQuick
import Quickshell
import "power"

// The real power panel with no battery behind it (the test runs with a
// dead system bus, so UPower has no display device), as on a desktop: the
// widget must stay on the bar and open its panel for the power profile
// picker, with the battery parts hidden and no binding loop.
ShellRoot {
  id: test
  property bool failed: false

  function check(ok, message) {
    if (!ok) {
      failed = true
      console.log("RESULT fail " + message)
    }
  }

  // The few bar properties the panel reads; a real bar provides many more.
  QtObject {
    id: fakeBar
    property color foreground: "white"
    property string fontFamily: "monospace"
    property bool vertical: false
  }

  Panel {
    id: panel
    bar: fakeBar
  }

  Timer {
    interval: 300
    running: true
    onTriggered: {
      test.check(panel.batteryPresent === false, "fixture has no battery")
      test.check(panel.visible && panel.implicitWidth > 0, "widget without a battery stays on the bar")
      panel.open()
    }
  }

  Timer {
    interval: 900
    running: true
    onTriggered: {
      test.check(panel.opened === true, "panel without a battery stays open for the profile picker")
      console.log(test.failed ? "RESULT fail" : "RESULT pass")
      Qt.quit()
    }
  }
}
