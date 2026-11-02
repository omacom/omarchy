import QtQuick
import Quickshell
import Quickshell.Io as Io
import qs.Commons

ShellRoot {
  id: root

  readonly property string resultPath: Quickshell.env("OMARCHY_QML_TEST_RESULT")
  readonly property string rootPath: Quickshell.env("OMARCHY_PATH")
  readonly property string scratch: Quickshell.env("OMARCHY_QML_TEST_SCRATCH")
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
    var payload = JSON.stringify({ ok: failures.length === 0, failures: failures })
    if (resultPath) {
      Quickshell.execDetached(["bash", "-lc", "printf '%s' " + shellQuote(payload) + " > " + shellQuote(resultPath)])
    }
  }

  Item { id: host; width: 900; height: 700 }

  property var marketplace: null
  property string firstDone: ""
  property string secondDone: ""
  property string selectionFile: ""
  property string pendingMessage: ""

  // The overlay protocol is: a summon writes its selection and touches its done
  // file, and the command that summoned it waits on that done file. A second
  // summon must finish the request the first one left open, or that command
  // waits forever on an overlay it will never see again.
  Component.onCompleted: {
    var component = Qt.createComponent("file://" + root.rootPath + "/shell/plugins/plugin-marketplace/PluginMarketplace.qml", Component.PreferSynchronous)
    if (component.status !== Component.Ready) {
      root.fail("PluginMarketplace failed to load: " + component.errorString())
      root.finish()
      return
    }
    root.marketplace = component.createObject(host, {})
    if (!root.marketplace) {
      root.fail("PluginMarketplace failed to instantiate: " + component.errorString())
      root.finish()
      return
    }
    root.firstDone = root.scratch + "/first.done"
    root.secondDone = root.scratch + "/second.done"
    root.selectionFile = root.scratch + "/selection"
    root.marketplace.open(JSON.stringify({
      plugins: [{ id: "acme.one", name: "Acme One", repo: "https://example.com/acme.git", description: "One" }],
      selectionFile: root.selectionFile,
      doneFile: root.firstDone
    }))
    waitForCatalog.attempts = 0
    waitForCatalog.running = true
  }

  // The overlay finishes a request through execDetached, so the file lands just
  // after open() returns; ask the filesystem rather than assume it ran.
  function probe(command, message, next) {
    root.pendingMessage = message
    probeProcess.next = next
    probeProcess.command = ["bash", "-c", command]
    probeProcess.running = true
  }

  function finish() {
    if (root.marketplace) root.marketplace.destroy()
    root.writeResult()
  }

  Io.Process {
    id: probeProcess
    property string next: ""
    onExited: function(exitCode) {
      if (exitCode !== 0) {
        root.fail(root.pendingMessage)
        root.finish()
        return
      }
      if (probeProcess.next === "second-summon") {
        root.marketplace.open(JSON.stringify({
          plugins: [{ id: "acme.one", name: "Acme One", repo: "https://example.com/acme.git", description: "One" }],
          selectionFile: root.selectionFile,
          doneFile: root.secondDone
        }))
        // open() finishes the first request through a detached process, so wait
        // for the file instead of assuming it already landed.
        root.probe("for _ in $(seq 40); do test -e " + shellQuote(root.firstDone) + " && exit 0; sleep 0.05; done; exit 1",
          "a second summon finishes the request the first one left open", "done")
        return
      }
      root.pass()
    }
  }

  function pass() {
    root.finish()
  }

  // The catalog is read from disk through a FileView, so it lands a tick after
  // open() returns.
  Timer {
    id: waitForCatalog
    property int attempts: 0
    interval: 20
    repeat: true
    running: false
    onTriggered: {
      if (root.marketplace && root.marketplace.plugins.length === 1) {
        running = false
        root.probe("test ! -e " + shellQuote(root.firstDone), "a summon alone writes no done file before a choice", "second-summon")
        return
      }
      if (++attempts > 100) {
        running = false
        root.fail("the summoned overlay reads its catalog")
        root.finish()
      }
    }
  }

  Io.FileView { id: unused; watchChanges: false }
}
