import QtQuick
import QtTest
import "../../../../shell/Ui"

// Panels cloned before 4.0.3 write bar.centerHoverRevealSuppressed directly
// as they close. The facade has to take that write and pass it to the host.
Item {
  id: root

  property bool hostSuppressed: false
  property bool panelOpen: false

  PluginBarApi {
    id: api
    pluginId: "tester.clock"
    moduleName: "tester.clock"
    _centerHoverRevealSuppressed: root.hostSuppressed
    _setCenterHoverRevealSuppressed: function(value) { root.hostSuppressed = value }
  }

  Component {
    id: lateApi
    PluginBarApi {
      _setCenterHoverRevealSuppressed: function(value) { root.hostSuppressed = value }
    }
  }

  // The close() a 4.0.2 clock or weather clone carries.
  function closeLegacyPanel() {
    if ("centerHoverRevealSuppressed" in api) api.centerHoverRevealSuppressed = false
    root.panelOpen = false
  }

  TestCase {
    name: "PluginBarApiCenterHoverReveal"

    function init() {
      root.hostSuppressed = false
      root.panelOpen = false
    }

    function test_legacyCloseFinishes() {
      root.panelOpen = true
      root.hostSuppressed = true
      root.closeLegacyPanel()
      compare(root.panelOpen, false)
      compare(root.hostSuppressed, false)
    }

    function test_writeReachesHost() {
      api.centerHoverRevealSuppressed = true
      compare(root.hostSuppressed, true)
      api.centerHoverRevealSuppressed = false
      compare(root.hostSuppressed, false)
    }

    function test_hostChangeReachesPlugin() {
      api.centerHoverRevealSuppressed = true
      root.hostSuppressed = false
      compare(api.centerHoverRevealSuppressed, false)
      root.hostSuppressed = true
      compare(api.centerHoverRevealSuppressed, true)
    }

    // A write of the value it already holds changes nothing, so it must not
    // stop host changes reaching the plugin or the next write reaching the host.
    function test_sameValueWriteKeepsMirroring() {
      api.centerHoverRevealSuppressed = false
      root.hostSuppressed = true
      compare(api.centerHoverRevealSuppressed, true)
      api.centerHoverRevealSuppressed = false
      compare(root.hostSuppressed, false)
    }

    // Bar.qml creates the facade first and binds the host value after.
    function test_hostAlreadySuppressedAtCreation() {
      root.hostSuppressed = true
      var late = lateApi.createObject(null, { pluginId: "tester.weather", moduleName: "tester.weather" })
      late._centerHoverRevealSuppressed = Qt.binding(function() { return root.hostSuppressed })
      compare(late.centerHoverRevealSuppressed, true)
      compare(root.hostSuppressed, true)
      late.destroy()
    }

    function test_setterStillWorks() {
      api.setCenterHoverRevealSuppressed(true)
      compare(root.hostSuppressed, true)
      compare(api.centerHoverRevealSuppressed, true)
    }
  }
}
