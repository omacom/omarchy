pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
  id: root
  property var state: ({})
  property bool watcherForced: false
  property bool profileNeedsWatcher: false
  property string pendingCycle: ""

  readonly property string fcitxConfigHome: Quickshell.env("FCITX_CONFIG_HOME")
  readonly property string xdgConfigHome: Quickshell.env("XDG_CONFIG_HOME") || (Quickshell.env("HOME") + "/.config")
  readonly property string profilePath: fcitxConfigHome ? (fcitxConfigHome + "/profile") : (xdgConfigHome + "/fcitx5/profile")
  readonly property bool shouldRunWatcher: watcherForced || fcitxConfigHome !== "" || profileNeedsWatcher

  // Parse ~/.config/fcitx5/profile to avoid keeping the 19 MiB Python+GLib
  // indicator.py process resident on single-layout installs where there is
  // nothing to switch between. Any profile with multiple groups, multiple
  // methods, or a non-keyboard composition engine starts the live watcher.
  function applyProfile(raw) {
    var text = String(raw || "")
    if (!text.trim()) {
      root.profileNeedsWatcher = true
      return
    }

    var section = ""
    var groupCount = 0
    var methods = []
    var lines = text.split("\n")
    for (var i = 0; i < lines.length; i++) {
      var line = lines[i].trim()
      if (!line || line.charAt(0) === "#") continue
      if (line.charAt(0) === "[" && line.charAt(line.length - 1) === "]") {
        section = line.slice(1, -1)
        if (/^Groups\/\d+$/.test(section)) groupCount += 1
        continue
      }
      if (/^Groups\/0\/Items\/\d+$/.test(section) && line.indexOf("Name=") === 0) {
        var name = line.slice(5).trim()
        if (name && methods.indexOf(name) === -1) methods.push(name)
      }
    }

    var singleKeyboard = groupCount <= 1 && methods.length === 1 && methods[0].indexOf("keyboard-") === 0
    root.profileNeedsWatcher = !singleKeyboard
    if (singleKeyboard && !watcher.running) {
      root.state = {
        methods: methods,
        current: methods[0],
        name: "",
        label: "",
        language: ""
      }
    }
  }

  function cycle(back) {
    var cmd = back ? "cycle back\n" : "cycle\n"
    if (watcher.running) {
      watcher.write(cmd)
      return true
    }
    // Start the watcher on demand (e.g. Super+I cycling multiple Hyprland XKB
    // layouts on a single-IM Fcitx profile) and flush the cycle once up.
    root.pendingCycle = cmd
    root.watcherForced = true
    return true
  }

  FileView {
    id: profileFile
    path: root.profilePath
    watchChanges: true
    printErrors: false
    onLoaded: root.applyProfile(text())
    onLoadFailed: root.profileNeedsWatcher = true
    onFileChanged: reload()
  }

  // One reader and pending selection for every monitor's keyboard widget.
  Process {
    id: watcher
    command: ["/usr/bin/python3", Quickshell.env("OMARCHY_PATH") + "/default/input-methods/indicator.py"]
    running: root.shouldRunWatcher
    stdinEnabled: true
    onRunningChanged: {
      if (running && root.pendingCycle !== "") {
        var cmd = root.pendingCycle
        root.pendingCycle = ""
        watcher.write(cmd)
      }
    }
    stdout: SplitParser {
      onRead: data => {
        try { root.state = JSON.parse(data) } catch (e) {}
      }
    }
    onExited: {
      if (root.shouldRunWatcher) {
        root.state = ({})
        restart.restart()
      }
    }
  }

  Timer {
    id: restart
    interval: 5000
    onTriggered: {
      if (root.shouldRunWatcher) watcher.running = true
    }
  }

  Component.onDestruction: {
    restart.stop()
    watcher.running = false
  }
}
