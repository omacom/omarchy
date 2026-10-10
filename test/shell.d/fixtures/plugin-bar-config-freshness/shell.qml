import QtQuick
import Quickshell

// Regression fixture for https://github.com/omacom/omarchy/issues/11505.
// Mirrors shell.qml's shellConfig -> barConfig chain: a derived `barConfig`
// binding plus the two candidate readers. Drives sequential writes and records
// what each reader returns from inside onShellConfigChanged, where QML has
// not re-evaluated dependent bindings yet.
ShellRoot {
  id: root

  readonly property string resultPath: Quickshell.env("OMARCHY_QML_TEST_RESULT")
  property var failures: []
  property var observations: []

  property var shellConfig: ({ bar: { v: 0 } })
  readonly property var barConfig: shellConfig && shellConfig.bar ? shellConfig.bar : ({})

  // Pre-fix publicBarConfig() shape: reads the derived binding (stale here).
  function bindingBarConfig() {
    return JSON.parse(JSON.stringify(root.barConfig || {}))
  }

  // Fixed publicBarConfig() shape (mirrors publicIdleConfigFor): derives from
  // shellConfig directly, so it cannot observe the stale binding.
  function directBarConfig() {
    var config = root.shellConfig && root.shellConfig.bar ? root.shellConfig.bar : ({})
    return JSON.parse(JSON.stringify(config))
  }

  function fail(message) {
    failures.push(String(message))
  }

  function shellQuote(value) {
    return "'" + String(value).replace(/'/g, "'\\''") + "'"
  }

  function writeResult() {
    var lagObserved = false
    for (var i = 0; i < observations.length; i++) {
      if (observations[i].viaBinding !== observations[i].actual) lagObserved = true
    }
    if (!lagObserved)
      fail("expected the derived barConfig binding to lag inside onShellConfigChanged (bug premise); observations=" + JSON.stringify(observations))
    var payload = JSON.stringify({
      ok: failures.length === 0,
      failures: failures,
      observations: observations
    })
    if (resultPath) {
      Quickshell.execDetached(["bash", "-lc", "printf '%s' " + shellQuote(payload) + " > " + shellQuote(resultPath)])
    }
  }

  onShellConfigChanged: {
    var actual = (shellConfig && shellConfig.bar) ? shellConfig.bar.v : -1
    var viaBinding = bindingBarConfig().v
    var viaDirect = directBarConfig().v
    observations.push({ actual: actual, viaBinding: viaBinding, viaDirect: viaDirect })
    if (viaDirect !== actual)
      fail("direct derivation lagged: direct=" + viaDirect + " actual=" + actual)
  }

  Timer {
    interval: 1
    running: true
    repeat: false
    onTriggered: {
      shellConfig = { bar: { v: 1 } }
      shellConfig = { bar: { v: 2 } }
      shellConfig = { bar: { v: 3 } }
      Qt.callLater(function() {
        if (observations.length < 3)
          fail("expected 3 config observations, saw " + observations.length)
        root.writeResult()
      })
    }
  }
}
