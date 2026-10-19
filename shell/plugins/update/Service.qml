import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons

// Opens the update window, for `omarchy update` or for a one-click install
// from the menu (omarchy-launch-update, omarchy-launch-install). The work runs
// detached in run.sh, so neither closing the window nor the shell restart that
// ends every update interrupts it: a window opened while something runs
// attaches to it, and a shell that starts while it runs brings it back.
Item {
  id: root

  // Injected by omarchy-shell (the first-party service loader).
  property var shell: null

  property string omarchyPath: Quickshell.env("OMARCHY_PATH")
  readonly property string stateDir: (Quickshell.env("XDG_RUNTIME_DIR") || "/tmp") + "/omarchy-update-window"

  // run.sh writes its pid here for as long as it runs. Read on demand rather
  // than probed with a process, so an idle shell starts nothing.
  FileView {
    id: activeFile
    path: root.stateDir + "/active"
    blockAllReads: true
    printErrors: false
  }

  FileView {
    id: hiddenFile
    path: root.stateDir + "/hidden"
    blockAllReads: true
    printErrors: false
  }

  // A runner killed outright leaves active behind, so only one whose process
  // is still there counts.
  FileView {
    id: procFile
    blockAllReads: true
    printErrors: false
  }

  function running() {
    activeFile.reload()
    var pid = activeFile.text().trim()
    if (!/^[0-9]+$/.test(pid)) return false
    procFile.path = "/proc/" + pid + "/cmdline"
    procFile.reload()
    return procFile.text().indexOf("run.sh") >= 0
  }

  function show(command, attach, hidden) {
    loader.source = ""
    loader.setSource("UpdateWindow.qml", { omarchyPath: omarchyPath, stateDir: stateDir, task: command, attach: attach, startHidden: hidden })
  }

  // command is a one-click install's shell command; empty opens the update.
  function open(command) {
    var w = loader.item
    if (running()) {
      // One at a time: the window shows what runs, and an install asked for
      // meanwhile goes to a terminal, the way it always did.
      if (w) w.present()
      else show("", true, false)
      if (command && !(w && w.task === command)) Util.execArgv(["omarchy-launch-floating-terminal-with-presentation", command])
    } else if (w && w.task === command && w.fresh) {
      w.present()
    } else {
      show(command, false, false)
    }
  }

  Loader {
    id: loader
    asynchronous: false
  }

  Connections {
    target: loader.item
    function onFinished() { loader.source = "" }
  }

  Component.onCompleted: {
    if (!running()) return
    hiddenFile.reload()
    show("", true, hiddenFile.text().trim() === "1")
  }

  ShellIpc {
    target: "update"

    function open(): string {
      root.open("")
      return "ok"
    }

    function install(command: string): string {
      if (!command) return "missing command"
      root.open(command)
      return "ok"
    }
  }
}
