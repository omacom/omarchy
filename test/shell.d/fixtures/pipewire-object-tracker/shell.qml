import QtQuick
import Quickshell
import qs.Commons

ShellRoot {
  id: root

  readonly property string resultPath: Quickshell.env("OMARCHY_QML_TEST_RESULT")
  property var failures: []

  function fail(message) {
    failures.push(String(message))
  }

  function assertTracked(expected, message) {
    var actual = settled.tracker.objects
    var same = actual.length === expected.length
    for (var i = 0; same && i < expected.length; i++)
      if (actual[i] !== expected[i]) same = false
    if (!same) fail(message + ": tracked " + actual.length + " objects, expected " + expected.length)
  }

  function after(interval, callback) {
    var timer = Qt.createQmlObject("import QtQuick; Timer {}", root)
    timer.interval = interval
    timer.triggered.connect(function() {
      timer.destroy()
      callback()
    })
    timer.start()
  }

  function shellQuote(value) {
    return "'" + String(value).replace(/'/g, "'\\''") + "'"
  }

  function writeResult() {
    var payload = JSON.stringify({ ok: failures.length === 0, failures: failures })
    if (resultPath)
      Quickshell.execDetached(["bash", "-c", "printf '%s' " + shellQuote(payload) + " > " + shellQuote(resultPath)])
  }

  QtObject { id: first }
  QtObject { id: second }
  QtObject { id: third }

  SettledPwObjectTracker {
    id: settled
  }

  Component.onCompleted: after(0, function() {
    assertTracked([], "starts with an empty list")

    // Several changes inside one event, as a registry teardown produces: none
    // may reach the tracker before the event has finished.
    settled.objects = [first]
    settled.objects = [first, second]
    settled.objects = [second, null, third]
    assertTracked([], "holds every change back until the current event finishes")

    after(50, function() {
      assertTracked([second, third], "takes the latest list on the next turn, without empty entries")

      settled.objects = []
      assertTracked([second, third], "holds a cleared list back too")
      after(50, function() {
        assertTracked([], "then drops every object")
        writeResult()
      })
    })
  })
}
