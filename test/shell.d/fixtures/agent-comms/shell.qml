import QtQuick
import Quickshell
import qs.Commons

ShellRoot {
  id: root

  readonly property string resultPath: Quickshell.env("OMARCHY_QML_TEST_RESULT")
  property var failures: []
  property var timedWidget: null

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
    var payload = JSON.stringify({ ok: failures.length === 0, failures: failures })
    if (resultPath)
      Quickshell.execDetached(["bash", "-lc", "printf '%s' " + shellQuote(payload) + " > " + shellQuote(resultPath)])
  }

  function load(settings) {
    var component = Qt.createComponent(Quickshell.env("OMARCHY_AGENT_COMMS_QML"), Component.PreferSynchronous)
    if (component.status !== Component.Ready) {
      fail("widget failed to load: " + component.errorString())
      return null
    }
    var item = component.createObject(host, {
      moduleName: "omarchy.agent-comms",
      settings: settings || {}
    })
    if (!item) {
      fail("widget failed to instantiate: " + component.errorString())
      return null
    }
    return item
  }

  Item { id: host }

  QtObject {
    id: fakeBar
    property bool vertical: false
    property int barSize: 26
    property string fontFamily: "monospace"
    property color foreground: "white"
    property color background: "black"
  }

  Timer {
    interval: 1
    running: true
    repeat: false
    onTriggered: {
      var item = load()
      if (item) {
        root.assertTrue(item.bar === null || item.bar === undefined, "starts without a bar")
        root.assertTrue(item.revealed === false, "starts hidden")
        root.assertTrue(item.implicitWidth === 0, "hidden tape takes no width")
        item.bar = fakeBar
        root.assertTrue(item.setting("missing", "fallback") === "fallback", "setting fallback works")
        root.assertTrue(item.markText === "comms", "default label is comms")
        root.assertTrue(item.visibleMs === 60000, "default visibility is one minute")
        root.assertTrue(item.maxWidth === 480, "default tape width is 480")

        item.applyFeed("")
        item.applyFeed("not json")
        root.assertTrue(item.primed === false, "an empty or invalid read does not prime")
        item.applyFeed('{"items":[]}')
        root.assertTrue(item.primed === true && item.revealed === false, "an empty snapshot primes without showing")
        item.applyFeed('{"items":[{"ts":5,"agent":"guide","role":"in","text":"ping"}]}')
        root.assertTrue(item.revealed === true, "the first comm after an empty snapshot opens the tape")
        root.assertTrue(item.tapeText.indexOf("you → guide   ping") >= 0, "a line said to the agent is labeled")
        root.assertTrue(item.implicitWidth === 480, "an open horizontal tape uses its max width")
        root.assertTrue(item.implicitHeight === 26, "an open tape uses the bar height")
        fakeBar.vertical = true
        root.assertTrue(item.implicitWidth === 26, "a vertical bar keeps a compact mark")
        fakeBar.vertical = false
      }

      var tuned = load({ maxWidth: 220, label: "tape", visibleSeconds: 15, apps: "muse" })
      if (tuned) {
        tuned.bar = fakeBar
        root.assertTrue(tuned.markText === "tape", "label setting is the bar mark")
        root.assertTrue(tuned.maxWidth === 220, "maxWidth setting sizes the tape")
        root.assertTrue(tuned.visibleMs === 15000, "visibleSeconds setting is the hide delay")
        root.assertTrue(tuned.apps === "muse", "apps setting is passed to the feeder")
        tuned.applyFeed('{"items":[{"ts":10,"agent":"guide","role":"out","text":"old"}]}')
        root.assertTrue(tuned.primed === true && tuned.revealed === false, "history already on disk stays hidden")
        tuned.applyFeed('{"items":[{"ts":10,"agent":"guide","role":"out","text":"old"}]}')
        root.assertTrue(tuned.revealed === false, "an identical republish stays hidden")
        tuned.applyFeed('{"items":[{"ts":10.04,"agent":"guide","role":"out","text":"rapid"}]}')
        root.assertTrue(tuned.revealed === true, "a genuine comm within 50ms opens the tape")
        tuned.conceal()
        tuned.applyFeed('{"items":[{"ts":10.04,"agent":"guide","role":"out","text":"rapid"}]}')
        root.assertTrue(tuned.revealed === false, "republishing a concealed comm does not reopen the tape")
        tuned.applyFeed('{"items":[{"ts":11,"agent":"guide","role":"out","text":"ready"}]}')
        root.assertTrue(tuned.revealed === true, "a newer comm opens the tape")
        root.assertTrue(tuned.tapeText.indexOf("guide → you   ready") >= 0, "an agent line is labeled")
        root.assertTrue(tuned.implicitWidth === 220, "the tuned tape uses its own width")
      }

      timedWidget = load({ visibleSeconds: 5 })
      if (timedWidget) {
        timedWidget.bar = fakeBar
        timedWidget.applyFeed('{"items":[]}')
        timedWidget.applyFeed('{"items":[{"ts":20,"text":"first"}]}')
      }
      rapidTimer.start()
      restartedTimerCheck.start()
      concealedTimerCheck.start()
    }
  }

  Timer {
    id: rapidTimer
    interval: 1200
    onTriggered: if (root.timedWidget)
      root.timedWidget.applyFeed('{"items":[{"ts":20.01,"text":"rapid follow-up"}]}')
  }

  Timer {
    id: restartedTimerCheck
    interval: 5400
    onTriggered: if (root.timedWidget)
      root.assertTrue(root.timedWidget.revealed, "a rapid newer comm restarts the visibility timer")
  }

  Timer {
    id: concealedTimerCheck
    interval: 6800
    onTriggered: {
      if (root.timedWidget)
        root.assertTrue(!root.timedWidget.revealed, "the restarted visibility timer eventually conceals the tape")
      root.writeResult()
    }
  }
}
