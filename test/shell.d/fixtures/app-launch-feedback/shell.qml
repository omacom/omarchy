import QtQuick
import Quickshell
import qs.Commons

// The launch OSD's deadline: a second launch while it is up keeps the first
// launch's deadline, and a launch after it expired gets a fresh one. The
// library's 2s delay and 15s timeout are shortened to 100ms and 1s so the
// whole run takes under three seconds.
ShellRoot {
  id: root

  readonly property string resultPath: Quickshell.env("OMARCHY_QML_TEST_RESULT")
  readonly property string rootPath: Quickshell.env("OMARCHY_PATH")
  property var failures: []
  property var library: null
  property real started: 0
  property var pending: []

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

  function timerWithInterval(owner, interval) {
    for (var i = 0; i < owner.data.length; i++) {
      var child = owner.data[i]
      if (child && child.interval === interval && "triggeredOnStart" in child) return child
    }
    return null
  }

  QtObject {
    id: mockShell
    property int summons: 0
    function summon(id, payloadJson) { summons++; return true }
    function hide(id) { return true }
  }

  Item { id: host }

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
    timeout.interval = 1000
    return true
  }

  // [ms after the first launch, action]
  readonly property var script: [
    [0, function() { library.beginLaunchFeedback("First") }],
    [400, function() {
      if (!library.launchOsdOpen || mockShell.summons < 1) fail("the launch OSD opens after its delay")
    }],
    [600, function() { library.beginLaunchFeedback("Second") }],
    [1350, function() {
      if (library.launchOsdOpen) fail("a second launch extended the first launch's deadline")
    }],
    [1450, function() { library.beginLaunchFeedback("Third") }],
    [2150, function() {
      if (!library.launchOsdOpen) fail("a launch after the deadline expired did not reopen the OSD")
    }],
    [2750, function() {
      if (library.launchOsdOpen) fail("a launch after the deadline expired did not get a fresh deadline")
    }]
  ]

  Timer {
    interval: 25
    running: true
    repeat: true
    onTriggered: {
      if (root.started === 0) {
        if (!root.setUp()) {
          stop()
          root.writeResult()
          return
        }
        root.started = Date.now()
        root.pending = root.script.slice()
      }
      var elapsed = Date.now() - root.started
      while (root.pending.length > 0 && root.pending[0][0] <= elapsed) root.pending.shift()[1]()
      if (root.pending.length === 0) {
        stop()
        root.writeResult()
      }
    }
  }
}
