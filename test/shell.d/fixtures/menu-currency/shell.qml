import QtQuick
import Quickshell
import Quickshell.Io

// Types into the real CurrencyLookup against a stub curl, waiting for each
// query to settle on what the menu should show for it. The steps, as
// [query, status, value, amount, date], come from the test.
ShellRoot {
  id: root

  readonly property string resultPath: Quickshell.env("OMARCHY_QML_TEST_RESULT")
  readonly property string rootPath: Quickshell.env("OMARCHY_PATH")
  readonly property var steps: JSON.parse(Quickshell.env("MENU_CURRENCY_STEPS"))
  property var lookup: null
  property var failures: []
  property int index: -1
  property int waited: 0

  function matches(step) {
    return root.lookup.status === step[1] && root.lookup.value === step[2]
      && (step[3] === undefined || root.lookup.amount === step[3])
      && (step[4] === undefined || root.lookup.date === step[4])
  }

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
      if (root.matches(step) && !root.lookup.fetching) {
        stop()
        root.next()
      } else if (++root.waited > 60) {
        stop()
        root.failures = root.failures.concat([step[0] + " settled on " + JSON.stringify([root.lookup.status, root.lookup.value, root.lookup.amount, root.lookup.date])])
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
    var lifetime = Quickshell.env("MENU_CURRENCY_LIFETIME_MS")
    if (lifetime) root.lookup.ratesLifetimeMs = Number(lifetime)
    var retry = Quickshell.env("MENU_CURRENCY_RETRY_MS")
    if (retry) root.lookup.retryAfterMs = Number(retry)
    root.next()
  }
}
