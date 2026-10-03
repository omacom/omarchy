import QtQuick
import Quickshell

ShellRoot {
  id: root

  readonly property string resultPath: Quickshell.env("OMARCHY_QML_TEST_RESULT")
  readonly property string clockUrl: Quickshell.env("OMARCHY_QML_CLOCK_URL")
  property var failures: []

  function fail(message) {
    failures.push(String(message))
  }

  function assertTrue(condition, message) {
    if (!condition) fail(message)
  }

  function shellQuote(value) {
    return "'" + String(value).replace(/'/g, "'\\''") + "'"
  }

  function writeResult() {
    var payload = JSON.stringify({ ok: failures.length === 0, failures: failures })
    if (resultPath) {
      Quickshell.execDetached(["bash", "-c", "printf '%s' " + shellQuote(payload) + " > " + shellQuote(resultPath)])
    }
  }

  Item { id: host }

  Timer {
    interval: 1
    running: true
    repeat: false
    onTriggered: {
      var component = Qt.createComponent(root.clockUrl, Component.PreferSynchronous)
      if (component.status !== Component.Ready) {
        root.fail("clock widget failed to load: " + component.errorString())
        root.writeResult()
        return
      }

      var item = component.createObject(host, {
        moduleName: "omarchy.clock",
        settings: { format: "dddd" }
      })
      if (!item) {
        root.fail("clock widget failed to instantiate: " + component.errorString())
        root.writeResult()
        return
      }

      // 2024-01-01 is a Monday. The system locale is forced to German by the
      // test runner, so a locale-aware formatter must print "Montag", never
      // the English "Monday" that Qt.formatDateTime() always produces.
      var monday = new Date(2024, 0, 1)
      var label = item.formatted(monday)

      root.assertTrue(label === "Montag", "clock renders the weekday name in the active system locale, got: " + label)
      root.assertTrue(label !== "Monday", "clock does not fall back to an English weekday name under a German locale")

      root.writeResult()
    }
  }
}
