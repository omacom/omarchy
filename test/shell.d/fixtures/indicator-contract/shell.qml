import QtQuick
import Quickshell
import qs.Commons as Commons

ShellRoot {
  id: root

  property string resultPath: Quickshell.env("OMARCHY_QML_TEST_RESULT")
  property var failures: []
  property var commands: []

  function fail(message) {
    failures.push(String(message))
  }

  function assertTrue(condition, message) {
    if (!condition) fail(message)
  }

  QtObject {
    id: notificationService
    property bool doNotDisturb: false
    function setDoNotDisturb(value) {
      doNotDisturb = !!value
    }
  }

  QtObject {
    id: idleService
    property bool stayAwake: false
    readonly property bool idleEnabled: !stayAwake
    function setIdleEnabled(value) {
      stayAwake = !value
    }
  }

  QtObject {
    id: nightlightService
    property bool enabled: false
    function setNightlight(value) {
      enabled = !!value
    }
  }

  QtObject {
    id: remoteSessionService
    property bool active: false
    property var peers: []
    property int refreshes: 0
    function refresh() {
      refreshes++
    }
  }

  QtObject {
    id: mockShell
    function firstPartyServiceFor(id) {
      if (id === "omarchy.notifications") return notificationService
      if (id === "omarchy.idle") return idleService
      if (id === "omarchy.nightlight") return nightlightService
      if (id === "omarchy.remote-session") return remoteSessionService
      return null
    }
  }

  QtObject {
    id: mockBar
    property bool vertical: false
    property int barSize: 26
    property string fontFamily: "monospace"
    property color barForeground: "white"
    property color urgent: "red"
    property bool foregroundAnimationEnabled: false
    property bool centerSectionRevealHeld: false
    property bool centerHoverRevealSuppressed: false
    property var shell: mockShell
    function run(command) {
      root.commands.push(String(command))
    }
    function showTooltip(target, text) {}
    function hideTooltip(target) {}
    function registerClickTarget(target) {}
    function unregisterClickTarget(target) {}
  }

  QtObject {
    id: indicatorHost
    property bool revealInactiveIndicators: true
    signal refreshRequested()
  }

  function createIndicator(name) {
    var component = Qt.createComponent("file://" + rootPath + "/shell/plugins/bar/indicators/" + name + ".qml")
    if (component.status !== Component.Ready) {
      fail(name + " failed to load: " + component.errorString())
      return null
    }

    var item = component.createObject(root, {
      indicatorHost: indicatorHost,
      indicatorBlock: "inactive",
      activeOverride: null
    })
    if (!item) {
      fail(name + " failed to instantiate: " + component.errorString())
      return null
    }
    return item
  }

  function injectBar(item) {
    assertTrue(item.bar === null || item.bar === undefined, item.moduleName + " starts without bar")
    item.bar = mockBar
    assertTrue(item.bar === mockBar, item.moduleName + " accepts delayed bar injection")
  }

  function commandCount(command) {
    var count = 0
    for (var i = 0; i < commands.length; i++) {
      if (commands[i] === command) count++
    }
    return count
  }

  function writeResult() {
    var payload = JSON.stringify({
      ok: failures.length === 0,
      failures: failures,
      commands: commands,
      dnd: notificationService.doNotDisturb
    })

    if (resultPath) {
      Quickshell.execDetached(["bash", "-lc", "printf '%s' " + shellQuote(payload) + " > " + shellQuote(resultPath)])
    }
  }

  function checkIndicatorTray() {
    idleService.setIdleEnabled(true)

    var component = Qt.createComponent("file://" + rootPath + "/shell/plugins/bar/widgets/Indicators.qml")
    if (component.status !== Component.Ready) {
      fail("Indicators failed to load: " + component.errorString())
      writeResult()
      return
    }

    var tray = component.createObject(root, {
      bar: mockBar,
      settings: { items: ["StayAwake"] }
    })
    if (!tray) {
      fail("Indicators failed to instantiate: " + component.errorString())
      writeResult()
      return
    }

    Qt.callLater(function() {
      root.assertTrue(tray.implicitWidth === 0, "inactive indicator tray starts collapsed")
      mockBar.centerSectionRevealHeld = true

      Qt.callLater(function() {
        root.assertTrue(tray.implicitWidth > 0, "inactive indicator tray expands on center hover")
        mockBar.centerSectionRevealHeld = false

        Qt.callLater(function() {
          root.assertTrue(tray.implicitWidth === 0, "inactive indicator tray collapses after hover")
          tray.destroy()
          root.checkFixedEdges([["start", false], ["end", false], ["start", true], ["end", true]])
        })
      })
    })
  }

  function indicatorSlot(item, block, id) {
    if (!item) return null
    if (item.indicatorBlock === block && item.indicatorId === id) return item
    var children = item.children || []
    for (var i = 0; i < children.length; i++) {
      var found = indicatorSlot(children[i], block, id)
      if (found) return found
    }
    return null
  }

  // Rows and columns lay out on the next frame, and this fixture has no window
  // to draw one. Run the pending layouts innermost first, as a frame would.
  function layOut(item) {
    var children = item.children || []
    for (var i = 0; i < children.length; i++) layOut(children[i])
    if (typeof item.forceLayout === "function") item.forceLayout()
  }

  function checkFixedEdges(cases) {
    if (cases.length === 0) {
      checkInactiveOrders([false, true])
      return
    }
    checkFixedEdge(cases[0][0], cases[0][1], function() {
      root.checkFixedEdges(cases.slice(1))
    })
  }

  function checkInactiveOrders(cases) {
    if (cases.length === 0) {
      writeResult()
      return
    }
    checkInactiveOrder(cases[0], function() {
      root.checkInactiveOrders(cases.slice(1))
    })
  }

  // Facing the other way, the widget mirrors its inactive icons along with its
  // blocks, so they read outward from the active block from either side.
  // Turning around moves the icons; it builds none of them again.
  function checkInactiveOrder(vertical, done) {
    var label = "inactive order " + (vertical ? "vertical" : "horizontal")
    var ids = ["Dnd", "NightLight", "StayAwake"]
    notificationService.doNotDisturb = false
    remoteSessionService.active = false
    nightlightService.setNightlight(false)
    idleService.setIdleEnabled(true)
    mockBar.centerSectionRevealHeld = true
    mockBar.vertical = vertical

    var component = Qt.createComponent("file://" + rootPath + "/shell/plugins/bar/widgets/Indicators.qml")
    var tray = component.createObject(root)
    if (!tray) {
      fail(label + ": Indicators failed to instantiate: " + component.errorString())
      mockBar.vertical = false
      done()
      return
    }
    tray.fixedEdge = "end"
    tray.bar = mockBar
    tray.moduleName = "omarchy.indicators"
    tray.settings = { items: ids }

    function slots() {
      return ids.map(function(id) { return root.indicatorSlot(tray, "inactive", id) })
    }

    function order(found) {
      if (found.some(function(slot) { return !slot })) return "missing"
      var placed = found.map(function(slot, at) {
        var point = slot.mapToItem(tray, 0, 0)
        return { id: ids[at], at: vertical ? point.y : point.x }
      })
      placed.sort(function(a, b) { return a.at - b.at })
      return placed.map(function(item) { return item.id }).join(",")
    }

    function finish() {
      mockBar.centerSectionRevealHeld = false
      mockBar.vertical = false
      tray.destroy()
      done()
    }

    Qt.callLater(function() {
      root.layOut(tray)
      var before = slots()
      var endOrder = order(before)
      root.assertTrue(endOrder === "Dnd,NightLight,StayAwake", label + ": an end-fixed widget shows its inactive icons in layout order, got " + endOrder)
      tray.fixedEdge = "start"

      Qt.callLater(function() {
        root.layOut(tray)
        var after = slots()
        var startOrder = order(after)
        root.assertTrue(startOrder === "StayAwake,NightLight,Dnd", label + ": a start-fixed widget mirrors its inactive icons, got " + startOrder)
        root.assertTrue(after.every(function(slot, at) { return slot === before[at] }), label + ": turning around keeps every inactive icon")
        finish()
      })
    })
  }

  // Revealing the inactive icons, or another one turning active, grows the
  // widget. Whatever was already showing must keep its distance from the edge
  // the bar holds still, or its click target slides out from under the pointer.
  function checkFixedEdge(edge, vertical, done) {
    var label = edge + (vertical ? " vertical" : " horizontal")
    var awayFromEdge = edge === "start" ? "NightLight,StayAwake" : "StayAwake,NightLight"
    notificationService.doNotDisturb = false
    remoteSessionService.active = false
    nightlightService.setNightlight(true)
    idleService.setIdleEnabled(false)
    mockBar.centerSectionRevealHeld = false
    mockBar.vertical = vertical

    var component = Qt.createComponent("file://" + rootPath + "/shell/plugins/bar/widgets/Indicators.qml")
    var tray = component.createObject(root)
    if (!tray) {
      fail(label + ": Indicators failed to instantiate: " + component.errorString())
      mockBar.vertical = false
      done()
      return
    }
    // In the order the bar's slots inject: the edge ahead of the bar, which is
    // what sets the indicators that are already active reporting in.
    tray.fixedEdge = edge
    tray.bar = mockBar
    tray.moduleName = "omarchy.indicators"
    tray.settings = { items: ["NightLight", "StayAwake"] }

    function extent() {
      return vertical ? tray.height : tray.width
    }

    function span(slot) {
      var point = slot.mapToItem(tray, 0, 0)
      var start = vertical ? point.y : point.x
      return { start: start, end: start + (vertical ? slot.height : slot.width) }
    }

    function distance(slot) {
      var slotSpan = span(slot)
      return edge === "start" ? slotSpan.start : extent() - slotSpan.end
    }

    function finish() {
      mockBar.centerSectionRevealHeld = false
      mockBar.vertical = false
      idleService.setIdleEnabled(true)
      tray.destroy()
      done()
    }

    Qt.callLater(function() {
      var startup = tray.activeIndicatorIds.join(",")
      root.assertTrue(startup === awayFromEdge, label + ": indicators already active at startup line up from the fixed edge in layout order, expected " + awayFromEdge + ", got " + startup)
      idleService.setIdleEnabled(true)

      Qt.callLater(function() {
        root.layOut(tray)
        var nightLight = root.indicatorSlot(tray, "active", "NightLight")
        root.assertTrue(!!nightLight, label + ": Night Light shows in the active block")
        if (!nightLight) {
          finish()
          return
        }
        var collapsedExtent = extent()
        var collapsedDistance = distance(nightLight)
        mockBar.centerSectionRevealHeld = true

        Qt.callLater(function() {
          root.layOut(tray)
          var stayAwake = root.indicatorSlot(tray, "inactive", "StayAwake")
          var revealedDistance = distance(nightLight)
          root.assertTrue(extent() > collapsedExtent, label + ": revealing grows the widget")
          root.assertTrue(revealedDistance === collapsedDistance,
            label + ": revealing keeps the active icon " + collapsedDistance + "px from the fixed edge, got " + revealedDistance)
          if (stayAwake) {
            var active = span(nightLight)
            var inactive = span(stayAwake)
            var farSide = edge === "start" ? inactive.start >= active.end : inactive.end <= active.start
            root.assertTrue(farSide, label + ": inactive icons reveal on the far side of the active ones (active " +
              active.start + "-" + active.end + ", inactive " + inactive.start + "-" + inactive.end + ")")
          } else {
            root.fail(label + ": Stay Awake shows in the revealed inactive block")
          }
          mockBar.centerSectionRevealHeld = false
          idleService.setIdleEnabled(false)

          Qt.callLater(function() {
            var actual = tray.activeIndicatorIds.join(",")
            root.assertTrue(actual === awayFromEdge, label + ": a newly active icon lands away from the fixed edge, expected " + awayFromEdge + ", got " + actual)
            finish()
          })
        })
      })
    })
  }

  function shellQuote(value) {
    return "'" + String(value).replace(/'/g, "'\\''") + "'"
  }

  readonly property string rootPath: Quickshell.env("OMARCHY_PATH")

  // Indicator text comes from the catalogs, which load just after the
  // shell starts; check once they have.
  Timer {
    interval: 1
    running: Object.keys(Commons.I18n.strings).length > 0
    repeat: false
    onTriggered: {
      var dnd = root.createIndicator("Dnd")
      if (dnd) {
        dnd.moduleName = "Dnd"
        root.injectBar(dnd)
        notificationService.doNotDisturb = false
        dnd.triggerPress(Qt.LeftButton)
        root.assertTrue(notificationService.doNotDisturb === true, "DND left click toggles notification service")
      }

      var nightLight = root.createIndicator("NightLight")
      if (nightLight) {
        nightLight.moduleName = "NightLight"
        root.injectBar(nightLight)
        nightLight.triggerPress(Qt.LeftButton)
        root.assertTrue(nightlightService.enabled === true, "Night Light left click toggles the nightlight service")
      }

      var screenRecording = root.createIndicator("ScreenRecording")
      if (screenRecording) {
        screenRecording.moduleName = "ScreenRecording"
        root.injectBar(screenRecording)
        screenRecording.triggerPress(Qt.LeftButton)
        root.assertTrue(root.commandCount("omarchy-menu toggle trigger.capture.screenrecord") === 1, "Screen Recording left click opens capture menu when idle")
        screenRecording.recording = true
        screenRecording.triggerPress(Qt.LeftButton)
        root.assertTrue(root.commandCount("omarchy-capture-screenrecording --stop-recording") === 1, "Screen Recording left click stops active recording")
      }

      var remoteSession = root.createIndicator("RemoteSession")
      if (remoteSession) {
        remoteSession.moduleName = "RemoteSession"
        root.injectBar(remoteSession)
        root.assertTrue(remoteSession.active === false, "Remote Session starts inactive without a gliff server")
        remoteSessionService.active = true
        remoteSessionService.peers = ["10.0.0.5"]
        root.assertTrue(remoteSession.active === true, "Remote Session follows the service state")
        root.assertTrue(remoteSession.tooltipText === "Remote session from 10.0.0.5", "Remote Session tooltip names the connected peer")
        indicatorHost.refreshRequested()
        root.assertTrue(remoteSessionService.refreshes === 1, "Remote Session refresh re-probes the service")
      }

      var stayAwake = root.createIndicator("StayAwake")
      if (stayAwake) {
        stayAwake.moduleName = "StayAwake"
        root.injectBar(stayAwake)
        stayAwake.triggerPress(Qt.LeftButton)
        root.assertTrue(idleService.stayAwake === true, "Stay Awake left click toggles the idle service")
      }

      root.checkIndicatorTray()
    }
  }
}
