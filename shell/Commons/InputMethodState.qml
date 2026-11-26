pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "InputMethodProfile.js" as InputMethodProfile

Singleton {
  id: root
  property var state: ({})

  readonly property string profilePath: {
    var fcitxHome = Quickshell.env("FCITX_CONFIG_HOME")
    if (fcitxHome) return fcitxHome.replace(/\/+$/, "") + "/profile"
    var xdgConfig = Quickshell.env("XDG_CONFIG_HOME") || (Quickshell.env("HOME") + "/.config")
    return xdgConfig.replace(/\/+$/, "") + "/fcitx5/profile"
  }

  readonly property var parsedProfile: InputMethodProfile.parseProfile(profileFile.text)
  // A single direct-input keyboard method in one group has nothing for Fcitx to
  // switch between, so watch the profile file in-process instead of keeping a
  // Python/PyGObject reader resident.
  readonly property bool needsWatcher: parsedProfile.switchable

  onParsedProfileChanged: syncStaticState()
  Component.onCompleted: syncStaticState()

  function syncStaticState() {
    if (!needsWatcher && parsedProfile.valid && parsedProfile.methods.length === 1) {
      var method = parsedProfile.methods[0]
      root.state = ({ methods: [method], current: method, name: "", label: "", language: "" })
    }
  }

  function cycle(back) {
    profileFile.reread()
    if (watcher.running) {
      watcher.write(back ? "cycle back\n" : "cycle\n")
      return true
    }
    if (!needsWatcher) {
      Quickshell.execDetached([
        "/usr/bin/python3",
        Quickshell.env("OMARCHY_PATH") + "/default/input-methods/indicator.py",
        back ? "--cycle-back" : "--cycle"
      ])
      return true
    }
    return false
  }

  WatchedFile {
    id: profileFile
    path: root.profilePath
  }

  // One reader and pending selection for every monitor's keyboard widget,
  // started only when the Fcitx profile has switchable methods or cannot be
  // read directly.
  Process {
    id: watcher
    command: ["/usr/bin/python3", Quickshell.env("OMARCHY_PATH") + "/default/input-methods/indicator.py"]
    running: root.needsWatcher
    stdinEnabled: true
    stdout: SplitParser {
      onRead: data => {
        try { root.state = JSON.parse(data) } catch (e) {}
      }
    }
    onExited: {
      if (root.needsWatcher) {
        root.state = ({})
        restart.restart()
      } else {
        root.syncStaticState()
      }
    }
  }

  Timer {
    id: restart
    interval: 5000
    onTriggered: if (root.needsWatcher) watcher.running = true
  }

  Component.onDestruction: {
    restart.stop()
    watcher.running = false
  }
}
