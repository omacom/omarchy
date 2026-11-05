import QtQuick
import Quickshell
import qs.Commons
import qs.Commons as Commons

ShellRoot {
  id: root

  property string resultPath: Quickshell.env("OMARCHY_QML_TEST_RESULT")
  property var failures: []

  function shellQuote(value) {
    return "'" + String(value).replace(/'/g, "'\\''") + "'"
  }

  function expect(raw, wanted, label) {
    Commons.Color.loadShell(raw)
    if (Style.bar.style !== wanted) failures.push(label + ": got " + Style.bar.style)
  }

  function run() {
    expect("", "strip", "no [bar] style")
    expect("[bar]\nstyle = \"islands\"\n", "islands", "quoted islands")
    expect("[bar]\nstyle = islands # floating\n", "islands", "bare islands with comment")
    expect("[bar]\nstyle = \"capsules\"\n", "strip", "unknown style")
    expect("[font]\nstyle = \"islands\"\n", "strip", "style outside [bar]")

    var payload = JSON.stringify({ ok: failures.length === 0, failures: failures })
    if (resultPath) Quickshell.execDetached(["bash", "-lc", "printf '%s' " + shellQuote(payload) + " > " + shellQuote(resultPath)])
  }

  // Run once the engine is up; Commons is ready by then.
  Component.onCompleted: Qt.callLater(run)
}
