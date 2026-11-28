import QtQuick
import Quickshell
import "services"

// Drives the real BackgroundIntro framePoll/frameStatus loop against a failing
// `owe` stub on PATH, verifying polling cuts off after 5 consecutive failures
// and reveals the theme cover instead of spinning until the 10s fallback.
ShellRoot {
  id: root

  readonly property string resultPath: Quickshell.env("OMARCHY_QML_TEST_RESULT")
  property var failures: []
  property bool revealed: false

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
      failures: failures,
      themeToken: intro.themeToken,
      cover: intro.cover
    })
    if (resultPath) {
      Quickshell.execDetached(["bash", "-lc", "printf '%s' " + shellQuote(payload) + " > " + shellQuote(resultPath)])
    }
  }

  QtObject {
    id: fakeBgService
    property bool suspended: false
    property bool ready: true
    property var nativeSizes: ({})
    property string displayedBackground: ""
  }

  QtObject {
    id: fakeHost
    property var services: ({ "omarchy.background": fakeBgService })
    property bool pluginReloading: false
    property var pluginRegistry: null
    property var bar: ({})
    function firstPartyServiceFor(id) {
      return id === "omarchy.background" ? fakeBgService : null
    }
  }

  BackgroundIntro {
    id: intro
    host: fakeHost
    onThemeTokenChanged: {
      if (themeToken === "" && !root.revealed && watchTimer.running) {
        root.revealed = true
        watchTimer.stop()
        settleTimer.start()
      }
    }
  }

  Timer {
    id: startTimer
    interval: 50
    running: true
    repeat: false
    onTriggered: {
      intro.prepareTheme("", "tok-fail", "", "")
      watchTimer.start()
      fakeBgService.suspended = true
    }
  }

  Timer {
    id: watchTimer
    interval: 2000
    repeat: false
    onTriggered: {
      root.fail("framePoll did not stop and reveal theme within 2000ms after consecutive owe failures")
      root.writeResult()
    }
  }

  // Wait after reveal to ensure no further owe polls fire.
  Timer {
    id: settleTimer
    interval: 300
    repeat: false
    onTriggered: {
      root.assertTrue(intro.themeToken === "", "themeToken cleared after failure cutoff")
      root.assertTrue(!intro.cover, "cover lowered after failure cutoff")
      root.writeResult()
    }
  }
}
