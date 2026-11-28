pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "InputMethodProfile.js" as InputMethodProfile

Singleton {
  id: root
  property var state: ({})
  property bool profileResolved: false
  property string resolvedProfilePath: ""
  property bool watcherForced: false
  property bool profileNeedsWatcher: false
  property bool restartPending: false
  property string pendingCycle: ""

  readonly property bool shouldRunWatcher: watcherForced || profileNeedsWatcher

  // Parse the resolved Fcitx profile so single-layout installs avoid keeping
  // the 19 MiB Python+GLib indicator.py process resident when there is nothing
  // to switch between. Any profile with multiple groups, multiple methods, or
  // a non-keyboard composition engine starts the live watcher.
  function applyProfile(raw) {
    var parsed = InputMethodProfile.parseProfile(raw)
    root.profileNeedsWatcher = parsed.needsWatcher
    if (!parsed.needsWatcher && !root.shouldRunWatcher) {
      root.state = {
        methods: parsed.methods,
        current: parsed.methods[0],
        name: "",
        label: "",
        language: ""
      }
    }
  }

  function refreshProfilePath() {
    if (!resolveProfile.running) resolveProfile.running = true
  }

  function cycle(back) {
    var cmd = back ? "cycle back\n" : "cycle\n"
    if (watcher.running) {
      if (root.watcherForced) forcedIdleTimer.restart()
      watcher.write(cmd)
      return true
    }
    // Start the watcher on demand (e.g. Super+I cycling multiple Hyprland XKB
    // layouts on a single-IM Fcitx profile) and flush the cycle once up.
    root.pendingCycle = cmd
    root.restartPending = false
    root.watcherForced = true
    forcedIdleTimer.restart()
    return true
  }

  // Follow org.fcitx.Fcitx5 starting or restarting (e.g. after login startup
  // ordering, a service drop-in changing FCITX_CONFIG_HOME, or relinked
  // dotfiles) without keeping Python resident (~240 KiB PSS vs 19 MiB).
  Process {
    id: ownerWatch
    command: [
      "setpriv", "--pdeathsig", "TERM",
      "dbus-monitor", "--session",
      "type='signal',sender='org.freedesktop.DBus',interface='org.freedesktop.DBus',member='NameOwnerChanged',arg0='org.fcitx.Fcitx5'"
    ]
    running: !root.shouldRunWatcher
    stdout: SplitParser {
      onRead: data => {
        if (String(data).indexOf("member=NameOwnerChanged") !== -1)
          root.refreshProfilePath()
      }
    }
  }

  // Locate Fcitx's actual profile path from the bus owner's environment (so a
  // service drop-in that moves FCITX_CONFIG_HOME/XDG_CONFIG_HOME is followed),
  // falling back to the shell's environment, and resolve symlinks so FileView
  // catches atomic saves that replace a dotfiles symlink target.
  Process {
    id: resolveProfile
    command: [
      "bash", "-c",
      'pid=$(busctl --user --timeout=1s call org.freedesktop.DBus /org/freedesktop/DBus org.freedesktop.DBus GetConnectionUnixProcessID s org.fcitx.Fcitx5 2>/dev/null | awk "{print \\$2}")\n' +
      'home=$HOME\n' +
      'fcitx_home=${FCITX_CONFIG_HOME:-}\n' +
      'xdg_home=${XDG_CONFIG_HOME:-}\n' +
      'if [[ $pid =~ ^[0-9]+$ && -r /proc/$pid/environ ]]; then\n' +
      '  fcitx_home=""\n' +
      '  xdg_home=""\n' +
      '  while IFS= read -r -d "" entry; do\n' +
      '    case $entry in\n' +
      '      HOME=*) home=${entry#HOME=} ;;\n' +
      '      FCITX_CONFIG_HOME=*) fcitx_home=${entry#FCITX_CONFIG_HOME=} ;;\n' +
      '      XDG_CONFIG_HOME=*) xdg_home=${entry#XDG_CONFIG_HOME=} ;;\n' +
      '    esac\n' +
      '  done <"/proc/$pid/environ"\n' +
      'fi\n' +
      'if [[ -n $fcitx_home ]]; then\n' +
      '  [[ $fcitx_home == /* ]] || fcitx_home="$home/$fcitx_home"\n' +
      '  profile="$fcitx_home/profile"\n' +
      'else\n' +
      '  if [[ -n $xdg_home ]]; then\n' +
      '    [[ $xdg_home == /* ]] || xdg_home="$home/$xdg_home"\n' +
      '  else\n' +
      '    xdg_home="$home/.config"\n' +
      '  fi\n' +
      '  profile="$xdg_home/fcitx5/profile"\n' +
      'fi\n' +
      'readlink -f "$profile" 2>/dev/null || printf "%s\\n" "$profile"\n'
    ]
    running: true
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        var resolved = String(text || "").trim()
        root.profileResolved = true
        if (resolved) {
          if (root.resolvedProfilePath === resolved) profileFile.reload()
          else root.resolvedProfilePath = resolved
        } else {
          root.profileNeedsWatcher = true
        }
      }
    }
    onExited: function(code) {
      if (!root.profileResolved) {
        root.profileResolved = true
        if (!root.resolvedProfilePath) root.profileNeedsWatcher = true
      }
    }
  }

  FileView {
    id: profileFile
    path: root.resolvedProfilePath
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
    running: root.shouldRunWatcher && !root.restartPending
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
      root.pendingCycle = ""
      if (root.shouldRunWatcher) {
        root.state = ({})
        root.restartPending = true
        restart.restart()
      } else {
        root.applyProfile(profileFile.text())
        root.refreshProfilePath()
      }
    }
  }

  Timer {
    id: restart
    interval: 5000
    onTriggered: root.restartPending = false
  }

  // Release an on-demand Super+I watcher once idle so a single accidental press
  // on a single-layout machine does not keep indicator.py resident all session.
  Timer {
    id: forcedIdleTimer
    interval: 30000
    onTriggered: root.watcherForced = false
  }

  Component.onDestruction: {
    restart.stop()
    forcedIdleTimer.stop()
    ownerWatch.running = false
    root.watcherForced = false
    root.profileNeedsWatcher = false
  }
}
