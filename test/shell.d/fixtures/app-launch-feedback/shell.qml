import QtQuick
import Quickshell
import qs.Commons

// The launch OSD's deadline: a second launch while it is up keeps the first
// launch's deadline, and a launch after it expired gets a fresh one. The
// library's 2s delay and 15s timeout are shortened to 100ms and 2s. The
// checks compare when the OSD actually closed with when each launch began,
// so a slow machine moves both together.
ShellRoot {
  id: root

  readonly property string resultPath: Quickshell.env("OMARCHY_QML_TEST_RESULT")
  readonly property string rootPath: Quickshell.env("OMARCHY_PATH")
  readonly property int timeoutMs: 2000
  property var failures: []
  property var library: null
  property int phase: 0
  property real firstLaunch: 0
  property real secondLaunch: 0
  property real thirdLaunch: 0
  property real openedAt: 0
  property real closedAt: 0
  property real deadline: 0

  function fail(message) {
    failures.push(String(message))
  }

  function shellQuote(value) {
    return "'" + String(value).replace(/'/g, "'\\''") + "'"
  }

  function writeResult() {
    var payload = JSON.stringify({ ok: failures.length === 0, failures: failures })
    if (resultPath) Quickshell.execDetached(["bash", "-lc", "printf '%s' " + shellQuote(payload) + " > " + shellQuote(resultPath)])
  }

  function finish() {
    poll.stop()
    writeResult()
  }

  function timerWithInterval(owner, interval) {
    for (var i = 0; i < owner.data.length; i++) {
      var child = owner.data[i]
      if (child && child.interval === interval && "triggeredOnStart" in child) return child
    }
    return null
  }

  QtObject {
    id: mockShell
    function summon(id, payloadJson) { return true }
    function hide(id) { return true }
  }

  Item { id: host }

  Connections {
    target: root.library
    function onLaunchOsdOpenChanged() {
      if (root.library.launchOsdOpen) root.openedAt = Date.now()
      else root.closedAt = Date.now()
    }
  }

  function setUp() {
    var component = Qt.createComponent(rootPath + "/shell/services/AppLibrary.qml", Component.PreferSynchronous)
    if (component.status !== Component.Ready) {
      fail("app library failed to load: " + component.errorString())
      return false
    }
    library = component.createObject(host, { shell: mockShell })
    if (!library) {
      fail("app library failed to instantiate: " + component.errorString())
      return false
    }
    var delay = timerWithInterval(library, 2000)
    var timeout = timerWithInterval(library, 15000)
    if (!delay || !timeout) {
      fail("app library launch timers not found")
      return false
    }
    delay.interval = 100
    timeout.interval = timeoutMs
    return true
  }

  Timer {
    id: poll
    interval: 25
    running: true
    repeat: true
    onTriggered: {
      var now = Date.now()
      if (root.phase === 0) {
        if (!root.setUp()) return root.finish()
        root.deadline = now + 10000
        root.firstLaunch = now
        root.library.beginLaunchFeedback("First")
        root.phase = 1
        return
      }
      if (now > root.deadline) {
        root.fail("the launch OSD did not open and close within 10s (phase " + root.phase + ")")
        return root.finish()
      }

      if (root.phase === 1 && root.openedAt > 0 && now - root.firstLaunch >= root.timeoutMs / 2) {
        // Halfway through the first deadline, launch again.
        root.secondLaunch = now
        root.library.beginLaunchFeedback("Second")
        root.phase = 2
      } else if (root.phase === 2 && root.closedAt > 0) {
        // Closed at the first launch's deadline, not the second's.
        var sinceFirst = root.closedAt - root.firstLaunch
        var sinceSecond = root.closedAt - root.secondLaunch
        if (sinceSecond >= root.timeoutMs * 0.9)
          root.fail("a second launch extended the first launch's deadline (closed " + sinceFirst + "ms after the first launch, " + sinceSecond + "ms after the second)")
        root.openedAt = 0
        root.closedAt = 0
        root.thirdLaunch = now
        root.library.beginLaunchFeedback("Third")
        root.phase = 3
      } else if (root.phase === 3 && root.closedAt > 0) {
        // A launch after the deadline expired gets a whole deadline of its own.
        if (root.openedAt === 0) root.fail("a launch after the deadline expired did not reopen the OSD")
        var lasted = root.closedAt - root.thirdLaunch
        if (lasted < root.timeoutMs * 0.9)
          root.fail("a launch after the deadline expired did not get a fresh deadline (closed after " + lasted + "ms)")
        root.finish()
      }
    }
  }
}
