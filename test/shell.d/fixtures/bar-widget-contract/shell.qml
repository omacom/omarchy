import QtQuick
import Quickshell
import qs.Commons
import qs.Ui

ShellRoot {
  id: root

  readonly property string resultPath: Quickshell.env("OMARCHY_QML_TEST_RESULT")
  readonly property string rootPath: Quickshell.env("OMARCHY_PATH")
  property var failures: []
  property var createdIds: []
  property var createdObjects: []

  function fail(message) {
    failures.push(String(message))
  }

  function assertTrue(condition, message) {
    if (!condition) fail(message)
  }

  function assertEqual(actual, expected, message) {
    if (actual !== expected) fail(message + " expected=" + expected + " actual=" + actual)
  }

  function shellQuote(value) {
    return "'" + String(value).replace(/'/g, "'\\''") + "'"
  }

  function writeResult() {
    var payload = JSON.stringify({
      ok: failures.length === 0,
      failures: failures,
      created: createdIds
    })

    if (resultPath) {
      Quickshell.execDetached(["bash", "-lc", "printf '%s' " + shellQuote(payload) + " > " + shellQuote(resultPath)])
    }
  }

  function widgets() {
    try {
      return JSON.parse(Qt.atob(Quickshell.env("OMARCHY_QML_BAR_WIDGETS") || "W10="))
    } catch (error) {
      fail("bar widget list failed to parse: " + error)
      return []
    }
  }

  function safeCall(item, method, entry) {
    if (!item || typeof item[method] !== "function") return
    try {
      item[method]()
    } catch (error) {
      fail(entry.id + " " + method + "() threw: " + error)
    }
  }

  function finiteDimension(value) {
    var n = Number(value)
    return isFinite(n) && n >= 0
  }

  function calendarOf(item) {
    for (var i = 0; i < item.children.length; i++) {
      var child = item.children[i]
      if (child && child.item && ("viewMonth" in child.item)) return child.item
    }
    return null
  }

  // The WallClock a QML object declares, found by the properties only it has.
  function wallClockOf(item) {
    for (var i = 0; i < item.data.length; i++) {
      var child = item.data[i]
      if (child && ("step" in child) && ("date" in child) && typeof child.arm === "function") return child
    }
    return null
  }

  function trayChevronOf(item) {
    if (!item) return null
    if (typeof item.triggerPress === "function" && (item.text === "\uf054" || item.text === "\uf053")) return item
    var hit = item.item ? trayChevronOf(item.item) : null
    if (hit) return hit
    for (var i = 0; i < (item.children || []).length; i++) {
      hit = trayChevronOf(item.children[i])
      if (hit) return hit
    }
    return null
  }

  function assertTrayChevronTogglesManage(item, label) {
    var chevron = trayChevronOf(item)
    root.assertTrue(chevron !== null, label + " exposes its expand chevron")
    if (!chevron) return
    var buttons = [Qt.LeftButton, Qt.RightButton]
    for (var i = 0; i < buttons.length; i++) {
      chevron.triggerPress(buttons[i])
      root.assertEqual(item.managePopupOpen, true, label + " button " + buttons[i] + " opens manage popup")
      chevron.triggerPress(buttons[i])
      root.assertEqual(item.managePopupOpen, false, label + " button " + buttons[i] + " closes manage popup")
    }
  }

  // A wake leaves WallClock counting down an interval it started before the
  // sleep. Resyncing is what re-reads the time, so the catch-up the system
  // clock timer asks for has to update both the label's clock and the
  // calendar's, and has to do it without sending a browsed month back to today.
  function findDescendant(node, predicate, seen) {
    if (!node) return null
    if (!seen) seen = []
    if (seen.indexOf(node) !== -1) return null
    seen.push(node)
    if (predicate(node)) return node
    var lists = []
    if (node.children) lists.push(node.children)
    if (node.data) lists.push(node.data)
    if (node.contentItem && node.contentItem.length !== undefined) lists.push(node.contentItem)
    else if (node.contentItem) lists.push([node.contentItem])
    for (var i = 0; i < lists.length; i++) {
      for (var j = 0; j < lists[i].length; j++) {
        var hit = findDescendant(lists[i][j], predicate, seen)
        if (hit) return hit
      }
    }
    return null
  }

  function verifyMediaIdleAndPopup(item, done) {
    var popup = findDescendant(item, function(n) { return ("open" in n) && ("anchorItem" in n) && ("contentWidth" in n) })
    var popupCard = findDescendant(popup, function(n) { return ("shown" in n) && ("opacity" in n) && ("padding" in n) })
    var albumArt = findDescendant(item, function(n) { return ("crop" in n) && ("cache" in n) && ("url" in n) })
    root.assertTrue(popup !== null && popupCard !== null && albumArt !== null, "omarchy.media exposes popup, card, and album art")
    if (!popup || !popupCard || !albumArt) { done(); return }

    var prevReduceMotion = Style.reduceMotion
    Style.reduceMotion = false
    item.parent = mediaWindowHost
    mockMediaService.activePlayer = mockMediaPlayer

    root.assertEqual(albumArt.cache, false, "omarchy.media disables pixmap caching for track art")
    root.assertEqual(popup.visible, false, "omarchy.media popup starts hidden")
    root.assertEqual(String(albumArt.url), "", "omarchy.media skips loading album art while closed")
    root.assertEqual(item.scrolling, true, "omarchy.media scrolls a long playing title on a visible bar")

    item.underFullscreen = true
    root.assertEqual(item.scrolling, false, "omarchy.media pauses scrolling behind fullscreen")
    item.underFullscreen = false
    fakeBar.sessionLocked = true
    root.assertEqual(item.scrolling, false, "omarchy.media pauses scrolling while locked")
    fakeBar.sessionLocked = false
    fakeBar.barHidden = true
    root.assertEqual(item.scrolling, false, "omarchy.media pauses scrolling while hidden")
    fakeBar.barHidden = false
    root.assertEqual(item.scrolling, true, "omarchy.media resumes scrolling when visible again")

    // Scoped PluginBarApi (used by cloned widgets) forwards barHidden and sessionLocked.
    item.bar = scopedBarApi
    root.assertEqual(item.scrolling, true, "omarchy.media scrolls via PluginBarApi when visible")
    scopedBarApi.sessionLocked = true
    root.assertEqual(item.scrolling, false, "omarchy.media pauses via PluginBarApi while locked")
    scopedBarApi.sessionLocked = false
    root.assertEqual(item.scrolling, true, "omarchy.media resumes via PluginBarApi when unlocked")
    scopedBarApi.barHidden = true
    root.assertEqual(item.scrolling, false, "omarchy.media pauses via PluginBarApi while hidden")
    scopedBarApi.barHidden = false
    root.assertEqual(item.scrolling, true, "omarchy.media resumes via PluginBarApi when shown")
    item.bar = fakeBar

    Style.reduceMotion = false
    item.popupOpen = true
    root.assertEqual(item.scrolling, false, "omarchy.media pauses scrolling while popup is open")
    mediaWaitTimer.waitFor(
      function() {
        Style.reduceMotion = false
        return popup.visible && popupCard.opacity >= 0.5 && String(albumArt.url) === mockMediaPlayer.trackArtUrl && albumArt.status === Image.Ready
      },
      2000,
      function(openedOk) {
        root.assertTrue(openedOk, "omarchy.media loads album art once popup opens")
        Style.reduceMotion = false
        item.popupOpen = false
        root.assertEqual(popup.visible, true, "omarchy.media popup stays visible during close fade")
        root.assertEqual(String(albumArt.url), mockMediaPlayer.trackArtUrl, "omarchy.media keeps art during close fade")
        mediaWaitTimer.waitFor(
          function() { return !popup.visible && String(albumArt.url) === "" },
          1000,
          function(closedOk) {
            root.assertTrue(closedOk, "omarchy.media clears album art once popup hides")
            item.parent = host
            mockMediaService.activePlayer = null
            Style.reduceMotion = prevReduceMotion
            mediaWindow.visible = false
            done()
          }
        )
      }
    )
  }

  function assertClockResyncs(item) {
    var calendar = calendarOf(item)
    root.assertTrue(calendar !== null, "omarchy.clock loads its calendar")
    if (!calendar) return

    var labelClock = wallClockOf(item)
    var calendarClock = wallClockOf(calendar)
    root.assertTrue(labelClock !== null && calendarClock !== null, "omarchy.clock and its calendar each run a WallClock")
    if (!labelClock || !calendarClock) return

    root.assertTrue(typeof item.resync === "function", "omarchy.clock answers a resync request")
    if (typeof item.resync !== "function") return

    calendar.viewMonth = (calendar.viewMonth + 3) % 12
    var browsed = calendar.viewMonth

    var stale = new Date(Date.now() - 5 * 60 * 1000)
    labelClock.date = stale
    calendarClock.date = stale
    item.resync()

    root.assertTrue(Math.abs(labelClock.date.getTime() - Date.now()) < 2000, "omarchy.clock catches its label up when the system clock jumps")
    root.assertTrue(Math.abs(calendarClock.date.getTime() - Date.now()) < 2000, "omarchy.clock catches its calendar up when the system clock jumps")
    root.assertEqual(calendar.viewMonth, browsed, "omarchy.clock leaves a browsed month alone when the system clock jumps")
  }

  function loadWidget(entry) {
    var component = Qt.createComponent(entry.url, Component.PreferSynchronous)
    if (component.status !== Component.Ready) {
      fail(entry.id + " failed to load: " + component.errorString())
      return
    }

    var item = component.createObject(host, {
      moduleName: entry.id,
      settings: {}
    })
    if (!item) {
      fail(entry.id + " failed to instantiate without bar: " + component.errorString())
      return
    }

    if ("bar" in item) {
      root.assertTrue(item.bar === null || item.bar === undefined, entry.id + " starts without injected bar")
      item.bar = fakeBar
      root.assertTrue(item.bar === fakeBar, entry.id + " accepts delayed bar injection")
    }
    if ("moduleName" in item) {
      item.moduleName = entry.id
      root.assertEqual(item.moduleName, entry.id, entry.id + " accepts moduleName injection")
    }
    if ("settings" in item) {
      item.settings = {}
      root.assertTrue(item.settings !== null && item.settings !== undefined, entry.id + " accepts settings injection")
    }
    if ("fixedEdge" in item) {
      item.fixedEdge = "start"
      root.assertEqual(item.fixedEdge, "start", entry.id + " accepts fixedEdge injection")
    }
    if (typeof item.setting === "function") {
      root.assertEqual(item.setting("missing", "fallback"), "fallback", entry.id + " exposes setting fallback")
    }
    if (entry.id === "omarchy.agents") {
      root.assertTrue(typeof item.iconCandidatesForProvider === "function", entry.id + " resolves provider marks by convention")
      var darkIcons = item.iconCandidatesForProvider({ providerId: "codex" }, Qt.color("#1a1b26")).join(" ")
      var lightIcons = item.iconCandidatesForProvider({ providerId: "codex" }, Qt.color("#ffffff")).join(" ")
      root.assertTrue(darkIcons.indexOf("codex.svg") >= 0 && darkIcons.indexOf("codex-light.svg") < 0, entry.id + " uses the dark-theme Codex icon on dark surfaces")
      root.assertTrue(lightIcons.indexOf("codex-light.svg") >= 0, entry.id + " prefers the light-theme Codex icon on light surfaces")
    }

    safeCall(item, "refresh", entry)
    safeCall(item, "close", entry)

    createdObjects.push(item)
    createdIds.push(entry.id)
  }

  Item { id: host }

  PanelWindow {
    id: mediaWindow
    visible: true
    color: "transparent"
    implicitWidth: 320
    implicitHeight: 40
    Item { id: mediaWindowHost; anchors.fill: parent }
  }

  Timer {
    id: mediaWaitTimer
    property var checkFn: null
    property var doneFn: null
    property double deadline: 0
    interval: 20
    repeat: true
    function waitFor(predicate, timeoutMs, callback) {
      checkFn = predicate
      doneFn = callback
      deadline = Date.now() + timeoutMs
      start()
    }
    onTriggered: {
      var ok = checkFn && checkFn()
      if (!ok && Date.now() < deadline) return
      stop()
      var cb = doneFn
      checkFn = null
      doneFn = null
      if (cb) cb(!!ok)
    }
  }

  QtObject {
    id: mockMediaPlayer
    property string trackTitle: "A Very Long Media Track Title That Exceeds The Maximum Marquee Width"
    property string trackArtist: "Test Artist"
    property string trackAlbum: ""
    property string trackArtUrl: "file://" + root.rootPath + "/themes/tokyo-night/preview.png"
    property bool isPlaying: true
    property bool canGoPrevious: false
    property bool canGoNext: false
    property bool canPlay: true
    property bool canPause: true
    property bool canTogglePlaying: true
  }

  QtObject {
    id: mockMediaService
    property var activePlayer: null
    property var sourcePlayers: []
    function playerKey(player) { return "mock" }
    function runAction(action, feedback, key) {}
    function selectPlayer(key) {}
  }

  PluginBarApi {
    id: scopedBarApi
    pluginId: "clone.media"
    moduleName: "clone.media"
    shell: mockShell
    foreground: "white"
    barForeground: "white"
    background: "black"
    urgent: "red"
    fontFamily: "monospace"
    barSize: 26
  }

  QtObject {
    id: mockShell
    property var bar: fakeBar
    property var barConfig: ({ position: "top" })
    property var shellConfig: ({ version: 1, idle: {}, plugins: [], bar: { layout: { left: [], center: [], right: [] } } })
    function firstPartyServiceFor(id) { return id === "omarchy.media" ? mockMediaService : null }
    function serviceFor(id) { return null }
    function summon(id, payloadJson) { return true }
    function hide(id) { return true }
    function toggle(id, payloadJson) { return true }
    function updateEntryInline(moduleName, settings) { return true }
  }

  QtObject {
    id: fakeBar
    property bool vertical: false
    property bool barHidden: false
    property bool sessionLocked: false
    property int barSize: 26
    property string omarchyPath: root.rootPath
    property string fontFamily: "monospace"
    property color foreground: "white"
    property color barForeground: "white"
    property bool foregroundAnimationEnabled: true
    property color background: "black"
    property color urgent: "red"
    property var shell: mockShell
    function run(command) {}
    function showTooltip(target, text) {}
    function hideTooltip(target) {}
    function requestPopout(owner) {}
    function releasePopout(owner) {}
    function registerClickTarget(target) {}
    function unregisterClickTarget(target) {}
  }

  Timer {
    interval: 1
    running: true
    repeat: false
    onTriggered: {
      var entries = widgets()
      root.assertTrue(entries.length > 0, "bar widget list is not empty")
      for (var i = 0; i < entries.length; i++) root.loadWidget(entries[i])

      Qt.callLater(function() {
        var mediaItem = null
        for (var j = 0; j < root.createdObjects.length; j++) {
          var item = root.createdObjects[j]
          var id = root.createdIds[j]
          root.assertTrue(root.finiteDimension(item.implicitWidth), id + " has a finite implicitWidth")
          root.assertTrue(root.finiteDimension(item.implicitHeight), id + " has a finite implicitHeight")
          if (id === "omarchy.clock") root.assertClockResyncs(item)
          if (id === "omarchy.active-window")
            root.assertTrue("tooltipHovered" in item && item.tooltipHovered === false, id + " exposes tooltipHovered for bar tooltips")
          if (id === "omarchy.tray") root.assertTrayChevronTogglesManage(item, id + " horizontal")
          if (id === "omarchy.media") mediaItem = item
        }

        function runVerticalChecks() {
          fakeBar.vertical = true
          fakeBar.barSize = Style.bar.sizeVertical

          Qt.callLater(function() {
            for (var k = 0; k < root.createdObjects.length; k++) {
              var verticalItem = root.createdObjects[k]
              var verticalId = root.createdIds[k]
              if (verticalId === "omarchy.clock")
                root.assertEqual(verticalItem.implicitHeight, Style.bar.iconSlot * 3, verticalId + " uses one slot per line")
              else if (verticalId === "omarchy.weather" || verticalId === "omarchy.system-update")
                root.assertEqual(verticalItem.implicitHeight, Style.bar.statusSlot, verticalId + " uses one compact status slot")
              else if (verticalId === "omarchy.tray")
                root.assertTrayChevronTogglesManage(verticalItem, verticalId + " vertical")
              if (verticalItem && typeof verticalItem.destroy === "function") verticalItem.destroy()
            }
            root.assertTrue(root.createdIds.length === entries.length, "all bar widgets instantiate")
            root.writeResult()
          })
        }

        if (mediaItem) root.verifyMediaIdleAndPopup(mediaItem, runVerticalChecks)
        else runVerticalChecks()
      })
    }
  }
}
