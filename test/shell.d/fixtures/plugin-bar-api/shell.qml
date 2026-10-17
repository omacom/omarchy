import QtQuick
import Quickshell
import qs.Ui

// Recreate Bar.pluginBarApiFor() plus the pre-4.0.3 clone write
// `bar.centerHoverRevealSuppressed = value`, which used to throw.

ShellRoot {
  id: root

  readonly property string resultPath: Quickshell.env("OMARCHY_QML_TEST_RESULT")
  property var failures: []
  property var createdApi: null

  function fail(message) {
    failures.push(String(message))
  }

  function assertTrue(condition, message) {
    if (!condition) fail(message)
  }

  function tryCall(fn) {
    try {
      fn()
      return { threw: false, error: "" }
    } catch (e) {
      return { threw: true, error: e.name + ": " + e.message }
    }
  }

  function shellQuote(value) {
    return "'" + String(value).replace(/'/g, "'\\''") + "'"
  }

  function writeResult() {
    var payload = JSON.stringify({ ok: failures.length === 0, failures: failures })
    if (resultPath)
      Quickshell.execDetached(["bash", "-lc", "printf '%s' " + shellQuote(payload) + " > " + shellQuote(resultPath)])
    Qt.callLater(function() { Qt.quit() })
  }

  QtObject {
    id: hostBar
    property bool centerHoverRevealSuppressed: false
    property int hostWrites: 0
    function setCenterHoverRevealSuppressed(value) {
      hostWrites++
      centerHoverRevealSuppressed = !!value
    }
  }

  Component {
    id: pluginBarApiComponent
    PluginBarApi { }
  }

  QtObject {
    id: clockPanel
    property QtObject bar: null
    property bool hidden: false

    function setCenterHoverRevealSuppressed(value) {
      if (bar && typeof bar.setCenterHoverRevealSuppressed === "function")
        bar.setCenterHoverRevealSuppressed(value)
      else if (bar && "centerHoverRevealSuppressed" in bar)
        bar.centerHoverRevealSuppressed = value
    }

    function closeAssignThenHide() {
      setCenterHoverRevealSuppressed(false)
      hidden = true
    }

    function closeHideThenAssign() {
      hidden = true
      setCenterHoverRevealSuppressed(false)
    }
  }

  Timer {
    interval: 1
    running: true
    repeat: false
    onTriggered: {
      var api = pluginBarApiComponent.createObject(null, {
        pluginId: "repro.clock",
        moduleName: "omarchy.clock",
        _setCenterHoverRevealSuppressed: function(value) {
          hostBar.setCenterHoverRevealSuppressed(!!value)
        }
      })
      createdApi = api
      api._centerHoverRevealSuppressed = Qt.binding(function() { return hostBar.centerHoverRevealSuppressed })
      clockPanel.bar = api

      root.assertTrue(!!api, "PluginBarApi instantiates")
      root.assertTrue(typeof api.setCenterHoverRevealSuppressed === "function", "PluginBarApi exposes setCenterHoverRevealSuppressed")

      var assigned = root.tryCall(function() { api.centerHoverRevealSuppressed = true })
      root.assertTrue(!assigned.threw, "clone assign does not throw: " + assigned.error)
      root.assertTrue(hostBar.centerHoverRevealSuppressed === true, "clone assign reaches the host bar")
      root.assertTrue(api.centerHoverRevealSuppressed === true, "clone assign is visible on the facade")

      hostBar.centerHoverRevealSuppressed = false
      root.assertTrue(api.centerHoverRevealSuppressed === false, "host changes still mirror back after an assign")

      var called = root.tryCall(function() { clockPanel.setCenterHoverRevealSuppressed(true) })
      root.assertTrue(!called.threw, "upstream setX caller does not throw: " + called.error)
      root.assertTrue(hostBar.centerHoverRevealSuppressed === true, "upstream setX caller reaches the host bar")

      hostBar.centerHoverRevealSuppressed = true
      clockPanel.hidden = false
      var closeOld = root.tryCall(function() { clockPanel.closeAssignThenHide() })
      root.assertTrue(!closeOld.threw && clockPanel.hidden === true, "assign-then-hide still completes after the API fix")

      hostBar.centerHoverRevealSuppressed = true
      clockPanel.hidden = false
      var closeNew = root.tryCall(function() { clockPanel.closeHideThenAssign() })
      root.assertTrue(!closeNew.threw && clockPanel.hidden === true, "hide-then-assign completes")
      root.assertTrue(hostBar.centerHoverRevealSuppressed === false, "hide-then-assign still clears the host flag")

      writeResult()
    }
  }
}
