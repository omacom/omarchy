import QtQuick
import Quickshell
import qs.Commons

ShellRoot {
  id: root

  readonly property string rootPath: Quickshell.env("OMARCHY_PATH")
  readonly property string resultPath: Quickshell.env("OMARCHY_QML_TEST_RESULT")
  property var failures: []
  property int checks: 0

  Item { id: host; width: 800; height: 600 }

  function check(condition, message) {
    checks += 1
    if (!condition) failures.push(message)
  }

  function load(file, properties) {
    var component = Qt.createComponent("file://" + rootPath + "/shell/plugins/lock/" + file, Component.PreferSynchronous)
    if (component.status !== Component.Ready) throw new Error(component.errorString())
    var object = component.createObject(host, properties)
    if (!object) throw new Error(component.errorString())
    return object
  }

  function child(service, test, name) {
    var objects = service.data || []
    for (var i = 0; i < objects.length; i++) {
      if (test(objects[i])) return objects[i]
    }
    throw new Error("Missing " + name)
  }

  function process(service, fragment) {
    return child(service, function(object) {
      return String(object.command || "").indexOf(fragment) !== -1
    }, "process running " + fragment)
  }

  function runView() {
    var view = load("LockView.qml", { width: 800, height: 600, loadBackground: false })
    try {
      var wakes = 0
      // The service clears the blank state when the view asks for a wake.
      view.wakeRequested.connect(function() {
        wakes += 1
        view.displaysBlank = false
      })

      view.displaysBlank = true
      check(view.takeWakeKey(), "a key at a dark panel is the wake key")
      check(wakes === 1, "the wake key asks for the wake")
      check(!view.takeWakeKey(), "the next key, at a lit panel, is typed")
      check(wakes === 2, "a key at a lit panel still restarts the blank countdown")
    } finally {
      view.destroy()
    }
  }

  function runService() {
    var service = load("Service.qml", { omarchyPath: rootPath })
    try {
      // The real commands would drive the displays, so each is stood in for
      // by one that touches nothing.
      var wake = process(service, "omarchy-system-wake")
      var blank = process(service, "omarchy-brightness-display off")
      var state = process(service, "monitors")
      wake.command = ["true"]
      blank.command = ["true"]
      state.command = ["true"]
      var blankTimer = child(service, function(object) {
        return object.armedAt !== undefined
      }, "blank countdown")
      var resumeWatch = child(service, function(object) {
        return object.ticksLeft !== undefined
      }, "resume watch")
      var lit = JSON.stringify([{ name: "eDP-1", dpmsStatus: true }])
      var dark = JSON.stringify([{ name: "eDP-1", dpmsStatus: false }, { name: "DP-1", disabled: true, dpmsStatus: true }])

      service.lockRequested = true
      check(!service.displaysBlank, "a fresh lock has its displays lit")

      service.runBlank()
      check(service.displaysBlank, "blanking marks the displays as off")
      service.runWake()
      blankTimer.stop()
      check(!service.displaysBlank, "the lock's own wake marks them as lit")

      service.runBlank()
      service.applyDisplayState(dark)
      check(service.displaysBlank, "displays Hyprland reports off stay marked off, a disabled one aside")
      service.applyDisplayState("not json")
      check(service.displaysBlank, "an unreadable answer changes nothing")
      service.applyDisplayState(lit)
      check(!service.displaysBlank, "a display relit behind the lock's back stops the swallow")

      // An answer still in flight when the lock went away is stale.
      service.runBlank()
      service.lockRequested = false
      service.applyDisplayState(lit)
      check(service.displaysBlank, "an answer landing after the poll stopped is dropped")
      service.lockRequested = true

      // The resume lights the panel without runWake, so it clears the state too.
      service.fingerprintConfigured = true
      service.pauseFingerprint()
      service.noteSleepRequested()
      resumeWatch.lastTickMs = Date.now() - 60000
      resumeWatch.triggered()
      blankTimer.stop()
      check(wake.running, "a resume lights the panel")
      check(!service.displaysBlank, "the first key after a resume is typed, not swallowed")
    } finally {
      service.lockRequested = false
      service.resetAuthenticationState()
      service.destroy()
    }
  }

  Timer {
    interval: 1
    running: true
    onTriggered: {
      try {
        root.runView()
        root.runService()
      } catch (error) {
        root.failures.push(String(error))
      }
      var payload = JSON.stringify({ ok: root.failures.length === 0, checks: root.checks, failures: root.failures })
      var quoted = "'" + payload.replace(/'/g, "'\\''") + "'"
      Quickshell.execDetached(["bash", "-c", "printf '%s' " + quoted + " > \"$1\"", "_", root.resultPath])
    }
  }
}
