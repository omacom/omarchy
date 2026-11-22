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

  function after(interval, callback) {
    var timer = Qt.createQmlObject("import QtQuick; Timer {}", root)
    timer.interval = interval
    timer.triggered.connect(function() {
      timer.destroy()
      callback()
    })
    timer.start()
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
      tray.setIndicatorAreaHovered(true)

      Qt.callLater(function() {
        root.assertTrue(tray.implicitWidth > 0, "inactive indicator tray expands on hover")
        tray.setIndicatorAreaHovered(false)

        root.after(200, function() {
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
      checkTraySection(function() { checkSectionPeek(writeResult) })
      return
    }
    checkInactiveOrder(cases[0], function() {
      root.checkInactiveOrders(cases.slice(1))
    })
  }

  // A neighbour in the right section, so that section has a still side for the
  // peek to cover once the indicators move to its start.
  Component {
    id: sectionPeekSibling

    Rectangle {
      property var bar: null
      property string moduleName: ""
      property var settings: ({})
      property string fixedEdge: "center"

      implicitWidth: 36
      implicitHeight: 20
      color: "transparent"
    }
  }

  QtObject {
    id: sectionPeekRegistry

    property int revision: 0
    property var widgets: ({})

    function metadataFor(id) {
      return widgets[id] ? { firstParty: true } : null
    }
  }

  QtObject {
    id: sectionPeekHost

    property var config: ({})

    function mutateShellConfig(mutator) {
      var copy = JSON.parse(JSON.stringify(config))
      mutator(copy)
      config = copy
    }
  }

  // Hidden indicators keep hiddenBlockZone underneath the icons so buttons keep
  // their cursor and tooltips. Moving them between two end-anchored sections
  // goes through the bar: WidgetHost supplies the new sectionItem, and the
  // surface peek then covers that section's still side as well as the growth
  // zone. Assigning sectionItem here would pass with that refresh removed.
  function checkSectionPeek(done) {
    notificationService.doNotDisturb = false
    remoteSessionService.active = false
    nightlightService.setNightlight(false)
    idleService.setIdleEnabled(true)

    var settled = false
    var bar = null
    function finish() {
      if (settled) return
      settled = true
      if (bar) {
        var dying = bar
        bar = null
        dying.Component.destruction.connect(function() { Qt.callLater(done) })
        dying.destroy()
        return
      }
      done()
    }

    var indicatorsComponent = Qt.createComponent("file://" + rootPath + "/shell/plugins/bar/widgets/Indicators.qml")
    if (indicatorsComponent.status !== Component.Ready) {
      fail("section peek: Indicators failed to load: " + indicatorsComponent.errorString())
      finish()
      return
    }
    var barComponent = Qt.createComponent("file://" + rootPath + "/shell/plugins/bar/Bar.qml")
    if (barComponent.status !== Component.Ready) {
      fail("section peek: Bar failed to load: " + barComponent.errorString())
      finish()
      return
    }

    sectionPeekRegistry.widgets = {
      "omarchy.indicators": { component: indicatorsComponent },
      "test.sibling": { component: sectionPeekSibling }
    }
    sectionPeekHost.config = {
      bar: {
        position: "top",
        background: "opaque",
        layout: {
          centerBegin: [{ id: "omarchy.indicators", items: ["Dnd", "NightLight", "StayAwake"] }],
          right: [{ id: "test.sibling" }]
        }
      }
    }

    bar = barComponent.createObject(root, {
      barWidgetRegistry: sectionPeekRegistry,
      shell: mockShell,
      barConfig: sectionPeekHost.config.bar
    })
    if (!bar) {
      fail("section peek: Bar failed to instantiate: " + barComponent.errorString())
      finish()
      return
    }
    bar.barConfig = Qt.binding(function() { return sectionPeekHost.config.bar })

    function slotsNamed(name, region, surfaceWindow) {
      return bar.moduleSlots.filter(function(slot) {
        return slot && slot.moduleName === name && (!region || slot.region === region) &&
          (!surfaceWindow || bar.slotWindow(slot) === surfaceWindow)
      })
    }

    function checkCenteredSibling(tray, pool, surfaceWindow) {
      bar.clearIndicatorBarPeek(pool)
      tray.setIndicatorAreaHovered(false)
      tray.setIndicatorItemHovered(false)
      sectionPeekHost.mutateShellConfig(function(config) {
        config.bar.layout.center = config.bar.layout.right
        config.bar.layout.right = []
      })

      function awaitCenter(tries, siblingRegion) {
        var indicators = slotsNamed("omarchy.indicators", "center", surfaceWindow)
        var siblings = slotsNamed("test.sibling", siblingRegion, surfaceWindow)
        if (indicators.length !== 1 || siblings.length !== 1 || indicators[0].activeItem !== tray ||
            !tray.sectionItem || tray.sectionItem.fixedEdge !== "center" || tray.implicitWidth !== 0) {
          if (tries <= 0) {
            fail("center peek (" + siblingRegion + "): indicators did not settle hidden beside a sibling")
            finish()
            return
          }
          root.after(150, function() { awaitCenter(tries - 1, siblingRegion) })
          return
        }

        var sibling = siblings[0]
        var surface = tray.sectionItem.parent
        root.layOut(surface)
        var before = sibling.mapToItem(surface, 0, 0)
        var probe = sibling.mapToItem(surface, sibling.width / 2, sibling.height / 2)
        bar.syncIndicatorBarPeek(indicators[0].pool, surface, probe)
        root.assertTrue(!tray.indicatorBarHovered,
          "center peek (" + siblingRegion + "): hovering a sibling does not reveal indicators")
        root.after(200, function() {
          root.layOut(surface)
          var after = sibling.mapToItem(surface, 0, 0)
          root.assertTrue(tray.implicitWidth === 0 && Math.abs(after.x - before.x) < 1,
            "center peek (" + siblingRegion + "): hovering the sibling keeps its click target still")
          if (siblingRegion === "center") {
            sectionPeekHost.mutateShellConfig(function(config) {
              config.bar.layout.centerEnd = config.bar.layout.center.slice(1)
              config.bar.layout.center = config.bar.layout.center.slice(0, 1)
            })
            root.after(150, function() { awaitCenter(12, "centerEnd") })
          } else {
            finish()
          }
        })
      }

      root.after(150, function() { awaitCenter(12, "center") })
    }

    function awaitPlacement(tries) {
      var indicators = slotsNamed("omarchy.indicators", "centerBegin")
      var siblings = slotsNamed("test.sibling", "right")
      var pair = null
      for (var i = 0; i < indicators.length && !pair; i++) {
        var surface = bar.slotWindow(indicators[i])
        var tray = indicators[i].activeItem
        if (!surface || !tray || tray.sectionItem !== indicators[i].parent) continue
        if (tray.fixedEdge !== "end" || !(tray.inactiveReach > 0) || tray.implicitWidth !== 0) continue
        for (var j = 0; j < siblings.length; j++) {
          if (bar.slotWindow(siblings[j]) !== surface || !siblings[j].parent || !(siblings[j].parent.width > 0)) continue
          if (siblings[j].parent === tray.sectionItem) continue
          pair = { surface: surface, slot: indicators[i], sibling: siblings[j], tray: tray }
          break
        }
      }
      if (!pair) {
        if (tries <= 0) {
          fail("section peek: bar did not place indicators in centerBegin beside a right-section widget (" +
            indicators.length + " indicator slots, " + siblings.length + " siblings)")
          finish()
          return
        }
        root.after(200, function() { awaitPlacement(tries - 1) })
        return
      }

      var tray = pair.tray
      var centerList = tray.sectionItem
      var rightList = pair.sibling.parent
      var indicatorKey = pair.slot.widgetKey
      var surface = pair.surface
      root.layOut(tray)
      var zoneIndex = -1
      var loaderIndex = -1
      for (var c = 0; c < tray.children.length; c++) {
        if (tray.children[c].objectName === "hiddenBlockZone") zoneIndex = c
        else if (tray.children[c].sourceComponent !== undefined) loaderIndex = c
      }
      root.assertTrue(zoneIndex >= 0 && loaderIndex > zoneIndex,
        "section peek: hiddenBlockZone sits underneath the icon loader (" + zoneIndex + " < " + loaderIndex + ")")

      // Live move from centerBegin to right index 0, same fixedEdge "end".
      // The host has to notice: nothing here writes sectionItem.
      sectionPeekHost.mutateShellConfig(function(config) {
        var layout = config.bar.layout
        var moved = (layout.centerBegin || []).filter(function(entry) { return entry.id === "omarchy.indicators" })
        layout.centerBegin = (layout.centerBegin || []).filter(function(entry) { return entry.id !== "omarchy.indicators" })
        layout.right = moved.concat(layout.right || [])
      })

      function awaitMove(tries) {
        var moved = null
        var landed = bar.moduleSlots.filter(function(slot) {
          return slot && slot.widgetKey === indicatorKey && slot.region === "right" && bar.slotWindow(slot) === surface
        })
        if (landed.length === 1 && landed[0].activeItem === tray) moved = landed[0]
        if (!moved) {
          if (tries <= 0) {
            fail("section peek: the bar did not hand the same indicators instance to right index 0")
            finish()
            return
          }
          root.after(150, function() { awaitMove(tries - 1) })
          return
        }

        try {
          root.assertTrue(moved.parent === rightList && tray.sectionItem === rightList && tray.sectionItem !== centerList,
            "section peek: WidgetHost set sectionItem to the right section, got " +
            (tray.sectionItem === centerList ? "the old centerBegin container" : "another container"))
          root.assertTrue(tray.fixedEdge === "end",
            "section peek: indicators keep fixedEdge 'end' in right section, got " + tray.fixedEdge)
          var rightSlots = bar.moduleSlots.filter(function(slot) {
            return slot && slot.region === "right" && bar.slotWindow(slot) === surface
          })
          var movedOrder = -1
          var siblingOrder = -1
          for (var c = 0; c < rightList.children.length; c++) {
            if (rightList.children[c] === moved) movedOrder = c
            else if (rightList.children[c] === pair.sibling) siblingOrder = c
          }
          root.assertTrue(rightSlots.length >= 2 && movedOrder >= 0 && siblingOrder > movedOrder,
            "section peek: indicators moved to right index 0 ahead of sibling (movedOrder=" + movedOrder + ", siblingOrder=" + siblingOrder + ")")
          var surfaceItem = rightList.parent
          root.assertTrue(!!surfaceItem, "section peek: the right section is drawn on a bar surface")
          if (surfaceItem) {
            root.layOut(surfaceItem)
            var origin = rightList.mapToItem(surfaceItem, 0, 0)
            var movedOrigin = moved.mapToItem(surfaceItem, 0, 0)
            var siblingOrigin = pair.sibling.mapToItem(surfaceItem, 0, 0)
            root.assertTrue(movedOrigin.x + moved.width <= siblingOrigin.x + 1,
              "section peek: moved indicator sits left of sibling (" + movedOrigin.x + "+" + moved.width + " <= " + siblingOrigin.x + ")")
            var sectionStart = origin.x
            var sectionEnd = sectionStart + rightList.width
            var span = tray.peekSpanIn(surfaceItem)
            root.assertTrue(span !== null && span.start < sectionStart && span.end >= sectionEnd - 1 && span.end <= sectionEnd + 1,
              "section peek: right index 0 covers growth zone and right section, got " + JSON.stringify(span) +
              " for section " + sectionStart + "-" + sectionEnd)
            // Over the sibling, on the section's still side, strictly right of the collapsed widget.
            var probeX = sectionStart + rightList.width * 0.75
            root.assertTrue(probeX > movedOrigin.x + moved.width,
              "section peek: probe (" + probeX + ") sits to the right of collapsed indicator (" + (movedOrigin.x + moved.width) + ")")
            bar.syncIndicatorBarPeek(moved.pool, surfaceItem, { x: probeX, y: origin.y + rightList.height / 2 })
            root.assertTrue(tray.indicatorBarHovered === true, "section peek: hovering the right section reveals hidden indicators")
            Qt.callLater(function() {
              root.layOut(tray)
              root.assertTrue(tray.implicitWidth > 0, "section peek: the right-section hover grows the hidden indicators, got width " + tray.implicitWidth)
              checkCenteredSibling(tray, moved.pool, surface)
            })
            return
          }
        } catch (e) {
          root.fail("section peek: " + e)
        }
        finish()
      }
      awaitMove(12)
    }

    awaitPlacement(20)
  }

  // In the tray's drawer, an idle widget with its icons hidden takes no room,
  // leaving nothing to hover, so there it shows them without one.
  function checkTraySection(done) {
    notificationService.doNotDisturb = false
    remoteSessionService.active = false
    nightlightService.setNightlight(false)
    idleService.setIdleEnabled(true)

    var component = Qt.createComponent("file://" + rootPath + "/shell/plugins/bar/widgets/Indicators.qml")
    var tray = component.createObject(root)
    if (!tray) {
      fail("tray section: Indicators failed to instantiate: " + component.errorString())
      done()
      return
    }
    tray.fixedEdge = "start"
    tray.inTraySection = true
    tray.bar = mockBar
    tray.moduleName = "omarchy.indicators"
    tray.settings = { items: ["Dnd", "NightLight"] }

    Qt.callLater(function() {
      root.layOut(tray)
      root.assertTrue(tray.implicitWidth > 0, "tray section: idle indicators show without a hover, got width " + tray.implicitWidth)
      tray.destroy()
      done()
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
    tray.setIndicatorAreaHovered(true)

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

    // A span as distances from the fixed edge, which holds still on the bar
    // while the widget grows.
    function fromEdge(itemSpan) {
      return edge === "start" ? itemSpan : { start: extent() - itemSpan.end, end: extent() - itemSpan.start }
    }

    function hiddenBlockZone() {
      var children = tray.children || []
      for (var i = 0; i < children.length; i++) {
        if (children[i].objectName === "hiddenBlockZone") return children[i]
      }
      return null
    }

    function finish() {
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
        var zone = hiddenBlockZone()
        var hiddenZone = zone ? fromEdge(span(zone)) : null
        root.assertTrue(!!zone, label + ": the widget has a hover zone for its hidden icons")
        tray.setIndicatorAreaHovered(true)

        Qt.callLater(function() {
          root.layOut(tray)
          var stayAwake = root.indicatorSlot(tray, "inactive", "StayAwake")
          var revealedDistance = distance(nightLight)
          if (hiddenZone && stayAwake) {
            var revealedAt = fromEdge(span(stayAwake))
            root.assertTrue(hiddenZone.start <= revealedAt.start && hiddenZone.end >= revealedAt.end,
              label + ": hovering where a hidden icon reveals reaches the zone (zone " + hiddenZone.start + "-" + hiddenZone.end +
              ", icon " + revealedAt.start + "-" + revealedAt.end + " from the fixed edge)")
          }
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
          tray.setIndicatorAreaHovered(false)
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
