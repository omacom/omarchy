import QtQuick
import Quickshell
import qs.Commons

ShellRoot {
  id: root

  readonly property string resultPath: Quickshell.env("OMARCHY_QML_TEST_RESULT")
  readonly property string widgetUrl: Quickshell.env("OMARCHY_QML_MEDIA_WIDGET")
  readonly property string longTitle: "A track title long enough to overflow the media widget and scroll"
  property var failures: []
  property var widget: null
  property var label: null
  property real sampledX: 0
  property int step: 0

  function fail(message) {
    failures.push(String(message))
  }

  function shellQuote(value) {
    return "'" + String(value).replace(/'/g, "'\\''") + "'"
  }

  function writeResult() {
    var payload = JSON.stringify({ ok: failures.length === 0, failures: failures })
    if (resultPath)
      Quickshell.execDetached(["bash", "-lc", "printf '%s' " + shellQuote(payload) + " > " + shellQuote(resultPath)])
  }

  function findLabel(item) {
    if (!item) return null
    if (item.text !== undefined && String(item.text).indexOf(longTitle) === 0 && item.parent && item.parent.clip) return item
    for (var i = 0; i < item.children.length; i++) {
      var found = findLabel(item.children[i])
      if (found) return found
    }
    return null
  }

  Item { id: host }

  QtObject {
    id: player
    property string trackTitle: root.longTitle
    property string trackArtist: "Artist"
    property bool isPlaying: true
    property bool canGoPrevious: false
    property bool canGoNext: false
    property bool canTogglePlaying: true
  }

  QtObject {
    id: mediaService
    property var activePlayer: player
    property var sourcePlayers: [player]
    function playerKey(p) { return "fake" }
    function runAction(action, osd, key) {}
    function selectPlayer(key) {}
  }

  QtObject {
    id: mockShell
    function firstPartyServiceFor(id) { return id === "omarchy.media" ? mediaService : null }
    function serviceFor(id) { return null }
  }

  QtObject {
    id: fakeBar
    property bool vertical: false
    property int barSize: 26
    property string fontFamily: "monospace"
    property color foreground: "white"
    property color barForeground: "white"
    property color background: "black"
    property bool foregroundAnimationEnabled: true
    property var shell: mockShell
    function run(command) {}
    function showTooltip(target, text) {}
    function hideTooltip(target) {}
    function requestPopout(owner) {}
    function releasePopout(owner) {}
    function registerClickTarget(target) {}
    function unregisterClickTarget(target) {}
  }

  // Each step samples the title's offset, then judges it on the next tick.
  Timer {
    id: ticker
    interval: 400
    repeat: true
    onTriggered: {
      var x = root.label.x
      switch (root.step) {
      case 0:
        if (x === root.sampledX) root.fail("the marquee scrolls while the player is playing (x stayed at " + x + ")")
        player.isPlaying = false
        break
      case 1:
        if (x !== 0) root.fail("pausing returns the title to its start (x=" + x + ")")
        break
      case 2:
        if (x !== 0) root.fail("the marquee holds still while the player is paused (x=" + x + ")")
        player.isPlaying = true
        break
      case 3:
        break
      case 4:
        if (x === root.sampledX) root.fail("the marquee scrolls again once playback resumes (x stayed at " + x + ")")
        ticker.stop()
        root.writeResult()
        return
      }
      root.sampledX = root.label.x
      root.step++
    }
  }

  Component.onCompleted: {
    Style.reduceMotion = false
    var component = Qt.createComponent(widgetUrl, Component.PreferSynchronous)
    if (component.status !== Component.Ready) {
      fail("media widget failed to load: " + component.errorString())
      writeResult()
      return
    }
    widget = component.createObject(host, { moduleName: "omarchy.media", settings: {} })
    widget.bar = fakeBar
    label = findLabel(widget)
    if (!label) {
      fail("media widget has a scrolling title label")
      writeResult()
      return
    }
    sampledX = label.x
    ticker.start()
  }
}
