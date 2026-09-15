import QtQuick
import Quickshell
import Quickshell.Io
import "Services" as Services

ShellRoot {
  id: root
  property int passed: 0
  property var retiredOwner: null
  property bool retiring: false
  function pass() {
    if (++passed === 5) { console.log("portable process QML passed"); Qt.quit() }
  }
  Services.PluginRuntime {
    id: runtime
    pluginId: "test.portable"
    admitted: ({storage: true, filesystem: {notes: {access: "read", target: "directory"}}})
    function localCommand(argv) {
      return ["/usr/bin/python3", Quickshell.env("OMARCHY_TEST_LOCAL_RUNNER")].concat(argv)
    }
  }
  Services.PluginRuntime {
    id: broker
    pluginId: "test.portable"
    function command(argv) {
      if (JSON.stringify(argv) !== JSON.stringify(["--json", "--exec", "named", "literal $HOME; shell punctuation"]))
        throw new Error("exec did not use its declared name and literal argv")
      return ["/usr/bin/printf", "%s", '{"version":1,"status":"completed","exitCode":7,"stdout":{"base64":"/w=="},"stderr":""}']
    }
  }
  Component {
    id: entry
    Item {
      required property var runtime
      Component.onCompleted: {
        runtime.runLocal(["/usr/bin/printf", "%s", "literal $HOME; shell punctuation"], {onFinished: result => {
          if (result.status !== "completed" || result.exitCode !== 0 || result.stdout !== "literal $HOME; shell punctuation")
            throw new Error("local job did not preserve argv and output")
          root.pass()
        }})
      }
    }
  }
  Component.onCompleted: {
    retiredOwner = Qt.createQmlObject('import QtQuick; QtObject {}', root)
    const owned = runtime.scope(retiredOwner)
    owned.launch(["/usr/bin/python3", Quickshell.env("OMARCHY_TEST_LOCAL_RUNNER"), "/usr/bin/python3", "-c",
      'import os,subprocess,time; p=subprocess.Popen(["/usr/bin/sleep","30"]); open(os.environ["OMARCHY_TEST_LIFETIME_MARKER"],"w").write(str(os.getpid())+" "+str(p.pid)); time.sleep(30)'], {}, true)
    if (!entry.createObject(root, {runtime: runtime})) throw new Error("required runtime was not injected")
    broker.exec("named", ["literal $HOME; shell punctuation"], {onFinished: result => {
      if (result.status !== "completed" || result.exitCode !== 7 || result.stdout.base64 !== "/w==")
        throw new Error("structured result lost command status or binary output")
      root.pass()
    }})
    runtime.runLocal(["/usr/bin/sleep", "30"], {onStarted: job => job.cancel(), onFinished: result => {
      if (result.status !== "cancelled") throw new Error("cancelled work claimed completion")
      root.pass()
    }})
    runtime.runLocal(["/nonexistent-plugin-test-command"], {onFinished: result => {
      if (result.status !== "failed") throw new Error("launch failure claimed completion")
      root.pass()
    }})
    if (runtime.filesystemPath("notes") !== "/grants/notes" || runtime.filesystemPath("missing") !== "")
      throw new Error("filesystem path did not reflect admission")
  }
  FileView {
    id: lifetime
    path: Quickshell.env("OMARCHY_TEST_LIFETIME_MARKER")
    onLoaded: if (!root.retiring && text().trim()) {
      root.retiring = true
      root.retiredOwner.destroy()
      lifetimeCheck.start()
    }
  }
  Timer { interval: 50; repeat: true; running: !root.retiring; onTriggered: lifetime.reload() }
  Timer { id: lifetimeCheck; interval: 300; onTriggered: lifetimeVerifier.running = true }
  Process {
    id: lifetimeVerifier
    command: ["/usr/bin/python3", "-c",
      'import os,sys; from pathlib import Path; pids=Path(os.environ["OMARCHY_TEST_LIFETIME_MARKER"]).read_text().split(); live=[p for p in pids if Path("/proc/"+p+"/stat").exists() and Path("/proc/"+p+"/stat").read_text().split(") ",1)[1][0]!="Z"]; sys.exit(bool(live))']
    onExited: code => {
      if (code !== 0) { console.error("entry destruction left its runtime jobs alive"); Qt.quit() }
      else root.pass()
    }
  }
  Timer { interval: 3000; running: true; onTriggered: { console.error("portable process QML timed out"); Qt.quit() } }
}
