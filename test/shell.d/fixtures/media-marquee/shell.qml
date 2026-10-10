import QtQuick
import Quickshell
import qs.Commons

ShellRoot {
  id: root

  readonly property string resultPath: Quickshell.env("OMARCHY_QML_TEST_RESULT")
  readonly property string rootPath: Quickshell.env("OMARCHY_PATH")
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
    var payload = JSON.stringify({
      ok: failures.length === 0,
      failures: failures
    })

    if (resultPath) {
      Quickshell.execDetached(["bash", "-lc", "printf '%s' " + shellQuote(payload) + " > " + shellQuote(resultPath)])
    }
  }

  function findLabel(item) {
    if (!item) return null
    if (item.parent && item.parent.clip && item.text !== undefined && item.needsScroll !== undefined) return item
    var children = item.children || []
    for (var i = 0; i < children.length; i++) {
      var found = findLabel(children[i])
      if (found) return found
    }
    return null
  }

  function play(title, artist) {
    player.trackTitle = title
    player.trackArtist = artist
  }

  Item { id: host; width: 800; height: 40 }

  QtObject {
    id: player
    property string trackTitle: ""
    property string trackArtist: ""
    property string trackAlbum: ""
    property string trackArtUrl: ""
    property bool isPlaying: true
    property bool canGoPrevious: false
    property bool canGoNext: false
    property bool canPlay: false
    property bool canPause: false
    property bool canTogglePlaying: false
  }

  QtObject {
    id: mediaService
    property var activePlayer: player
    property var sourcePlayers: [player]
    function playerKey(p) { return "test" }
    function runAction(action, osd, key) {}
    function selectPlayer(key) {}
  }

  QtObject {
    id: mockShell
    function firstPartyServiceFor(id) { return id === "omarchy.media" ? mediaService : null }
  }

  QtObject {
    id: fakeBar
    property bool vertical: false
    property int barSize: 26
    property string fontFamily: "monospace"
    property color foreground: "white"
    property color barForeground: "white"
    property bool foregroundAnimationEnabled: false
    property var shell: mockShell
    function showTooltip(target, text) {}
    function hideTooltip(target) {}
    function requestPopout(owner) {}
    function releasePopout(owner) {}
  }

  property var widget: null
  property var label: null
  property int midScrollPolls: 0

  function finish() {
    if (widget) widget.destroy()
    writeResult()
  }

  Timer {
    interval: 1
    running: true
    repeat: false
    onTriggered: {
      try {
        var component = Qt.createComponent("file://" + root.rootPath + "/shell/plugins/services/media/BarWidget.qml", Component.PreferSynchronous)
        if (component.status !== Component.Ready) {
          root.fail("media BarWidget failed to load: " + component.errorString())
          root.finish()
          return
        }

        Style.reduceMotion = false
        root.play("Painted on", "Lizer")
        root.widget = component.createObject(host, { bar: fakeBar })
        if (!root.widget) {
          root.fail("media BarWidget failed to instantiate: " + component.errorString())
          root.finish()
          return
        }

        var label = root.findLabel(root.widget)
        if (!label) {
          root.fail("media label not found")
          root.finish()
          return
        }
        root.label = label

        var cap = root.widget.maxLabelWidth
        root.assertTrue(label.implicitWidth < cap, "first title fits the label cap, got " + label.implicitWidth)
        root.assertTrue(label.x === 0, "a fitting title starts at x 0, got " + label.x)

        var firstWidth = label.implicitWidth
        var scrollStarts = 0
        label.needsScrollChanged.connect(function() { if (label.needsScroll) scrollStarts++ })

        root.play("Taught early", "MILASH")
        root.assertTrue(label.implicitWidth > firstWidth, "second title is wider than the first, got " + label.implicitWidth + " vs " + firstWidth)
        root.assertTrue(label.implicitWidth < cap, "grown title still fits the label cap, got " + label.implicitWidth)
        root.assertTrue(scrollStarts === 0, "a title that grows but still fits never starts scrolling, started " + scrollStarts + " times")
        root.assertTrue(label.x === 0, "a title that grows but still fits stays at x 0, got " + label.x)

        root.play("A title long enough to overflow the media label", "Some Artist")
        root.assertTrue(label.needsScroll, "an overflowing title scrolls")
        midScroll.start()
      } catch (error) {
        root.fail("media marquee fixture threw: " + error)
        root.finish()
      }
    }
  }

  Timer {
    id: midScroll
    interval: 50
    repeat: true
    onTriggered: {
      try {
        var label = root.label
        var clipWidth = label.parent.width
        if (label.x > clipWidth / 2) {
          if (++root.midScrollPolls < 100) return
          root.fail("the marquee never scrolled into view, x stuck at " + label.x)
          stop()
          root.finish()
          return
        }

        stop()
        root.assertTrue(label.x + label.implicitWidth > 0, "the long title is still mid-scroll, got x " + label.x)

        root.play("short", "A")
        root.assertTrue(!label.needsScroll, "a short title after a long one stops scrolling")
        root.assertTrue(label.x === 0, "a short title after a mid-scroll one resets to x 0, got " + label.x)
      } catch (error) {
        stop()
        root.fail("media marquee fixture threw: " + error)
      }
      root.finish()
    }
  }
}
