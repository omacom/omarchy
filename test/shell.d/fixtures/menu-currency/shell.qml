import QtQuick
import Quickshell
import Quickshell.Io

// Types into the real CurrencyLookup against a stub curl, waiting for each
// query to settle on what the menu should show for it.
ShellRoot {
  id: root

  readonly property string resultPath: Quickshell.env("OMARCHY_QML_TEST_RESULT")
  readonly property string rootPath: Quickshell.env("OMARCHY_PATH")
  property var lookup: null
  property var failures: []
  property int index: -1
  property int waited: 0
  // Query, status, value. The first asks for the list, so a plain search is
  // answered without it; usd falls back to the second host; eur always fails.
  readonly property var steps: [
    ["zen", "", ""],
    ["$5 to INR", "ready", "450"],
    ["100 inr to usd", "ready", "1.11"],
    ["USD 2 in eur", "ready", "1"],
    ["5 cats to dogs", "", ""],
    ["go to settings", "", ""],
    ["5 eur to usd", "failed", ""],
    ["1 usd to inr", "ready", "90"]
  ]

  function next() {
    root.index += 1
    root.waited = 0
    if (root.index >= root.steps.length) {
      root.finish()
      return
    }
    root.lookup.query = root.steps[root.index][0]
    poll.restart()
  }

  function finish() {
    poll.stop()
    writer.command = ["bash", "-c", 'printf "%s" "$2" >"$1"', "bash", root.resultPath,
      JSON.stringify({ ok: root.failures.length === 0, failures: root.failures })]
    writer.running = true
  }

  Timer {
    id: poll
    interval: 50
    repeat: true
    onTriggered: {
      var step = root.steps[root.index]
      if (root.lookup.status === step[1] && root.lookup.value === step[2] && !root.lookup.fetching) {
        stop()
        root.next()
      } else if (++root.waited > 60) {
        stop()
        root.failures = root.failures.concat([step[0] + " settled on " + JSON.stringify([root.lookup.status, root.lookup.value])])
        root.next()
      }
    }
  }

  Process { id: writer }

  Component.onCompleted: {
    var component = Qt.createComponent("file://" + root.rootPath + "/shell/plugins/menu/CurrencyLookup.qml")
    root.lookup = component.createObject(root)
    if (!root.lookup) {
      root.failures = [component.errorString()]
      root.finish()
      return
    }
    root.next()
  }
}
