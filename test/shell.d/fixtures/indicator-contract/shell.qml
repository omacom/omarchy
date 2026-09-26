import QtQuick
import Quickshell
import qs.Commons

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
    id: mockShell
    property var shell: mockShell
    property var pluginRegistry: registry
    property var clonedServices: []
    property var _services: {
      var services = {notifications: notificationService, idle: idleService, nightlight: nightlightService, media: mediaService}
      var result = {}
      for (var name in services)
        result[(clonedServices.indexOf(name) !== -1 ? "tester." : "omarchy.") + name] = services[name]
      return result
    }
    // SERVICE_LOOKUP_METHODS
  }

  QtObject {
    id: registry
    property var installedPlugins: ({
      "tester.notifications": { omarchy: { clonedFrom: "omarchy.notifications" } },
      "tester.idle": { omarchy: { clonedFrom: "omarchy.idle" } },
      "tester.nightlight": { omarchy: { clonedFrom: "omarchy.nightlight" } },
      "tester.media": { omarchy: { clonedFrom: "omarchy.media" } }
    })
    function isEnabled(id) { return mockShell.clonedServices.indexOf(id.replace("tester.", "")) !== -1 }
    // RESOLVE_ENABLED_ID_METHOD
  }

  QtObject {
    id: player
    property string trackTitle: "Lookup test"
    property string trackArtist: "Test artist"
    property bool isPlaying: false
    property bool canGoPrevious: true
    property bool canGoNext: true
    property bool canTogglePlaying: true
    property bool canPlay: true
    property bool canPause: true
  }

  QtObject {
    id: mediaService
    property var activePlayer: player
    property var sourcePlayers: [player]
    function runAction(action, notify, key) {
      root.commands.push("media:" + action)
      if (action === "playPause") player.isPlaying = !player.isPlaying
    }
    function playerKey(value) { return "test-player" }
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
          root.writeResult()
        })
      })
    })
  }

  function shellQuote(value) {
    return "'" + String(value).replace(/'/g, "'\\''") + "'"
  }

  function checkCloneConsumers() {
    var items = [root.createIndicator("StayAwake"), root.createIndicator("NightLight"), root.createIndicator("Dnd")]
    for (var item of items) if (item) root.injectBar(item)
    var mediaComponent = Qt.createComponent("file://" + rootPath + "/shell/plugins/services/media/BarWidget.qml")
    var audioComponent = Qt.createComponent("file://" + rootPath + "/shell/plugins/panels/audio/Panel.qml")
    var media = mediaComponent.status === Component.Ready ? mediaComponent.createObject(root, {bar: mockBar}) : null
    var audio = audioComponent.status === Component.Ready ? audioComponent.createObject(root, {bar: mockBar}) : null
    root.assertTrue(media !== null, "media widget loads: " + mediaComponent.errorString())
    root.assertTrue(audio !== null, "audio panel loads: " + audioComponent.errorString())

    function clickMediaButtons(item, seen) {
      if (!item || seen.indexOf(item) !== -1) return
      seen.push(item)
      if ("iconText" in item && typeof item.clicked === "function") item.clicked()
      for (var property of ["data", "children", "contentItem"]) {
        var children = item[property]
        if (!children) continue
        if (typeof children.length === "number") {
          for (var child of children) clickMediaButtons(child, seen)
        }
      }
    }

    function check(phase) {
      idleService.setIdleEnabled(true)
      nightlightService.setNightlight(false)
      notificationService.setDoNotDisturb(false)
      for (var item of items) {
        if (!item) continue
        root.assertTrue(!item.active, phase + ": external state clears indicator")
        item.triggerPress(Qt.LeftButton)
        root.assertTrue(item.active, phase + ": click activates indicator")
      }
      root.assertTrue(idleService.stayAwake, phase + ": idle receives click")
      root.assertTrue(nightlightService.enabled, phase + ": nightlight receives click")
      root.assertTrue(notificationService.doNotDisturb, phase + ": notifications receives click")
      if (media && audio) {
        root.assertTrue(media.mediaService === mediaService, phase + ": media widget resolves service")
        root.assertTrue(audio.mediaService === mediaService, phase + ": audio panel resolves service")
        root.assertTrue(media.activePlayer === player && audio.activeMediaPlayer === player, phase + ": both consumers expose player")
        player.trackTitle = phase
        root.assertTrue(media.title === phase, phase + ": media title updates")
        mediaService.activePlayer = null
        root.assertTrue(media.activePlayer === null && audio.activeMediaPlayer === null, phase + ": both consumers clear removed player")
        mediaService.activePlayer = player
        var before = root.commands.length
        var wasPlaying = player.isPlaying
        clickMediaButtons(media, [])
        var actions = root.commands.slice(before)
        for (var action of ["previous", "playPause", "next"])
          root.assertTrue(actions.indexOf("media:" + action) !== -1, phase + ": media " + action + " reaches service")
        root.assertTrue(player.isPlaying !== wasPlaying, phase + ": playback action updates player")
      }
    }

    var phases = [[], ["idle"], ["nightlight"], ["notifications"], ["media"], ["idle", "nightlight", "notifications", "media"], []]
    function nextPhase(index) {
      mockShell.clonedServices = phases[index]
      Qt.callLater(function() {
        check(index === 0 ? "original" : index === phases.length - 1 ? "restored" : "cloned " + phases[index].join(","))
        if (index + 1 < phases.length) {
          nextPhase(index + 1)
          return
        }
        for (var item of items) if (item) item.destroy()
        if (media) media.destroy()
        if (audio) audio.destroy()
        root.checkIndicatorTray()
      })
    }
    nextPhase(0)
  }

  readonly property string rootPath: Quickshell.env("OMARCHY_PATH")

  Timer {
    interval: 1
    running: true
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

      var dictation = root.createIndicator("Dictation")
      if (dictation) {
        dictation.moduleName = "Dictation"
        root.injectBar(dictation)
        dictation.triggerPress(Qt.LeftButton)
        dictation.triggerPress(Qt.RightButton)
        root.assertTrue(root.commandCount("omarchy-voxtype-config") === 2, "Dictation clicks run config command")
        root.assertTrue(root.commandCount("omarchy-voxtype-model") === 0, "Dictation clicks do not run model command")
      }

      var stayAwake = root.createIndicator("StayAwake")
      if (stayAwake) {
        stayAwake.moduleName = "StayAwake"
        root.injectBar(stayAwake)
        stayAwake.triggerPress(Qt.LeftButton)
        root.assertTrue(idleService.stayAwake === true, "Stay Awake left click toggles the idle service")
      }

      root.checkCloneConsumers()
    }
  }
}
