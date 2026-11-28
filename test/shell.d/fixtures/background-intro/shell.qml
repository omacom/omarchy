import QtQuick
import Quickshell
import Quickshell.Io
import "services"

// Drives the real BackgroundIntro framePoll/frameStatus loop against a failing
// `owe` stub on PATH, verifying polling cuts off after 5 consecutive failures
// and reveals the theme cover instead of spinning until the 10s fallback, and
// verifies outgoingFrame does not retain one-shot cover snapshots in Qt's
// pixmap cache across transitions.
ShellRoot {
  id: root

  readonly property string resultPath: Quickshell.env("OMARCHY_QML_TEST_RESULT")
  readonly property string snapshotPath: Quickshell.env("OMARCHY_QML_TEST_SNAPSHOT")
  readonly property string snapshotNextPath: Quickshell.env("OMARCHY_QML_TEST_SNAPSHOT_NEXT")
  property var failures: []
  property bool revealed: false
  property bool resultWritten: false
  property string cachePhase: "idle"

  function fail(message) {
    failures.push(String(message))
  }

  function assertTrue(condition, message) {
    if (!condition) fail(message)
  }

  function writeResult() {
    if (resultWritten) return
    resultWritten = true
    cachePhase = "done"
    watchTimer.stop()
    settleTimer.stop()
    cacheWatchTimer.stop()
    var payload = JSON.stringify({
      ok: failures.length === 0,
      failures: failures,
      themeToken: intro.themeToken,
      cover: intro.cover
    })
    intro.cancelTheme()
    if (resultPath) {
      Quickshell.execDetached(["bash", "-c", 'printf "%s" "$1" > "$2"', "_", payload, resultPath])
    }
  }

  function startCacheCheck() {
    if (resultWritten) return
    if (!snapshotPath || !snapshotNextPath) {
      fail("missing OMARCHY_QML_TEST_SNAPSHOT or OMARCHY_QML_TEST_SNAPSHOT_NEXT")
      writeResult()
      return
    }
    fakeBgService.suspended = false
    var sizes = {}
    sizes[snapshotPath] = { width: 4, height: 4 }
    sizes[snapshotNextPath] = { width: 4, height: 4 }
    fakeBgService.nativeSizes = sizes
    fakeBgService.displayedBackground = snapshotPath
    cachePhase = "first"
    cacheWatchTimer.start()
    intro.prepareTheme(snapshotPath, "tok-cache-1", "", "")
    Qt.callLater(checkCachePhase)
  }

  function checkCachePhase() {
    if (resultWritten) return
    if (cachePhase === "first") {
      var firstStatus = intro.themeCoverStatus("tok-cache-1")
      if (firstStatus === "loading") return
      if (firstStatus !== "ready") {
        fail("initial cover snapshot did not become ready (got " + firstStatus + ")")
        writeResult()
        return
      }
      // Replace the cover directly without hiding the cover window so
      // QQuickWindow::releaseResources() does not purge QQuickPixmapCache.
      fakeBgService.displayedBackground = snapshotNextPath
      cachePhase = "second"
      intro.prepareTheme(snapshotNextPath, "tok-cache-2", "", "")
      Qt.callLater(checkCachePhase)
    } else if (cachePhase === "second") {
      var secondStatus = intro.themeCoverStatus("tok-cache-2")
      if (secondStatus === "loading") return
      if (secondStatus !== "ready") {
        fail("replacement cover snapshot did not become ready (got " + secondStatus + ")")
        writeResult()
        return
      }
      cachePhase = "removing"
      removeSnapshotProc.running = true
    } else if (cachePhase === "reload") {
      var reloadStatus = intro.themeCoverStatus("tok-cache-3")
      if (reloadStatus === "loading") return
      assertTrue(reloadStatus === "error", "unlinked cover snapshot must not be served from pixmap cache (got " + reloadStatus + ")")
      writeResult()
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
    onCoverPresented: root.checkCachePhase()
  }

  Process {
    id: removeSnapshotProc
    command: ["rm", "-f", "--", root.snapshotPath]
    onExited: function(exitCode) {
      if (root.resultWritten || root.cachePhase !== "removing") return
      if (exitCode !== 0) {
        root.fail("failed to unlink cover snapshot")
        root.writeResult()
        return
      }
      fakeBgService.displayedBackground = root.snapshotPath
      root.cachePhase = "reload"
      intro.prepareTheme(root.snapshotPath, "tok-cache-3", "", "")
      Qt.callLater(root.checkCachePhase)
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
      root.startCacheCheck()
    }
  }

  Timer {
    id: cacheWatchTimer
    interval: 3000
    repeat: false
    onTriggered: {
      root.fail("cover snapshot cache check timed out in phase " + root.cachePhase)
      root.writeResult()
    }
  }
}
