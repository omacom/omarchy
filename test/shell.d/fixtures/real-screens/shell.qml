import QtQuick
import Quickshell
import qs.Commons as Commons

ShellRoot {
  id: test
  property bool failed: false

  function check(ok, message) {
    if (!ok) {
      failed = true
      console.log("RESULT fail " + message)
    }
  }

  // Quit from a timer, as the other fixtures do: Qt.quit() has no receiver
  // yet while the root is still completing.
  Timer {
    interval: 50
    running: true
    onTriggered: {
      var placeholder = { name: "", width: 0, height: 0 }
      var fallback = { name: "FALLBACK", width: 0, height: 0 }
      var nameless = { name: "", width: 1920, height: 1080 }
      var real = { name: "HDMI-A-1", width: 3440, height: 1440 }

      test.check(!Commons.Screens.isReal(null), "a missing screen is not real")
      test.check(!Commons.Screens.isReal(placeholder), "Qt's nameless placeholder screen is not real")
      test.check(!Commons.Screens.isReal(fallback), "a zero-sized output is not real")
      test.check(!Commons.Screens.isReal(nameless), "an output without a name is not real")
      test.check(Commons.Screens.isReal(real), "a named output with a size is real")

      var filtered = Commons.Screens.filter([placeholder, real, fallback])
      test.check(filtered.length === 1 && filtered[0] === real, "filter keeps only the real outputs, in order")
      test.check(Commons.Screens.filter(null).length === 0, "filter tolerates a missing list")

      // Headless, Qt reports exactly the placeholder this guards against.
      var live = Commons.Screens.real
      for (var i = 0; i < live.length; i++) {
        test.check(Commons.Screens.isReal(live[i]), "every live real screen is real: " + live[i].name)
    }
    test.check(Commons.Screens.any === (live.length > 0), "any mirrors the real list")

      console.log("RESULT " + (test.failed ? "fail" : "pass") + " screens=" + Quickshell.screens.length + " real=" + live.length)
      Qt.quit()
    }
  }
}
