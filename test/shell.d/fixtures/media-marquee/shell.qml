import QtQuick
import Quickshell
import qs.Commons

ShellRoot {
  id: root

  readonly property string resultPath: Quickshell.env("OMARCHY_QML_TEST_RESULT")
  readonly property string rootPath: Quickshell.env("OMARCHY_PATH")
  readonly property string longTitle: "A title long enough to overflow the media label"
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

  // Style probes Hyprland's animations setting asynchronously and again on
  // every reload, so pinning reduceMotion once can be undone mid-test.
  Connections {
    target: Style
    function onReduceMotionChanged() { if (Style.reduceMotion) Style.reduceMotion = false }
  }

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
  property int scrollStarts: 0
  property int polls: 0
  property var firstX: undefined

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
        label.needsScrollChanged.connect(function() { if (label.needsScroll) root.scrollStarts++ })

        root.play("Taught early", "MILASH")
        root.assertTrue(label.implicitWidth > firstWidth, "second title is wider than the first, got " + label.implicitWidth + " vs " + firstWidth)
        root.assertTrue(label.implicitWidth < cap, "grown title still fits the label cap, got " + label.implicitWidth)
        settleFitting.start()
      } catch (error) {
        root.fail("media marquee fixture threw: " + error)
        root.finish()
      }
    }
  }

  // A few frames on, so a marquee started and stopped within one pass has had
  // the chance to leave the label somewhere else.
  Timer {
    id: settleFitting
    interval: 200
    onTriggered: {
      var label = root.label
      root.assertTrue(root.scrollStarts === 0, "a title that grows but still fits never reads as overflowing, did " + root.scrollStarts + " times")
      root.assertTrue(label.x === 0, "a title that grows but still fits stays at x 0, got " + label.x)

      // An empty title first, as after a shell restart or between tracks: the
      // clip is 0 wide when the long title lands.
      root.play("", "")
      root.play(root.longTitle, "Some Artist")
      root.assertTrue(label.needsScroll, "an overflowing title needs to scroll")
      scrolling.start()
    }
  }

  // The long title must actually move, well inside the 6s a degenerate
  // animation sits still for, before it is replaced mid-scroll.
  Timer {
    id: scrolling
    interval: 50
    repeat: true
    onTriggered: {
      try {
        var label = root.label
        if (root.firstX === undefined) root.firstX = label.x
        var moved = label.x !== root.firstX
        var inView = label.x < label.parent.width / 2 && label.x + label.implicitWidth > 0
        if (!(moved && inView && label.x !== 0)) {
          if (++root.polls < 60) return
          stop()
          root.fail("a long title after an empty one never scrolled into view, x stayed at " + label.x + " from " + root.firstX)
          root.finish()
          return
        }

        stop()
        root.play("short", "A")
        root.assertTrue(!label.needsScroll, "a short title after a long one stops scrolling")
        root.assertTrue(label.x === 0, "a short title replacing one mid-scroll resets to x 0, got " + label.x)
        settleShort.start()
      } catch (error) {
        stop()
        root.fail("media marquee fixture threw: " + error)
        root.finish()
      }
    }
  }

  Timer {
    id: settleShort
    interval: 200
    onTriggered: {
      root.assertTrue(root.label.x === 0, "a short title stays at x 0 once the marquee has stopped, got " + root.label.x)
      root.finish()
    }
  }
}
