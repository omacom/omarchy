import QtQuick
import QtTest
import Quickshell
import qs.Commons

// Types real key events into the lock view, tied to the real lock service
// with every display command stubbed: a key at a dark panel only wakes it,
// and keys typed after the panel came on by other means reach the field.
ShellRoot {
  id: root

  readonly property string rootPath: Quickshell.env("OMARCHY_PATH")
  readonly property string resultPath: Quickshell.env("OMARCHY_QML_TEST_RESULT")
  property var failures: []
  property int checks: 0
  property var service: null
  property var view: null
  property var steps: []
  property int step: 0

  function check(condition, message) {
    checks += 1
    if (!condition) failures.push(String(message))
  }

  function load(file, parent, properties) {
    var component = Qt.createComponent("file://" + rootPath + "/shell/plugins/lock/" + file, Component.PreferSynchronous)
    if (component.status !== Component.Ready) throw new Error(component.errorString())
    var object = component.createObject(parent, properties)
    if (!object) throw new Error(component.errorString())
    return object
  }

  function child(test, name) {
    var objects = service.data || []
    for (var i = 0; i < objects.length; i++) {
      if (test(objects[i])) return objects[i]
    }
    throw new Error("Missing " + name)
  }

  function process(fragment) {
    return child(function(object) {
      return String(object.command || "").indexOf(fragment) !== -1
    }, "process running " + fragment)
  }

  function timer(interval, repeat) {
    return child(function(object) {
      return object.interval === interval && object.repeat === repeat && object.armedAt === undefined && object.ticksLeft === undefined
    }, "timer " + interval)
  }

  function type(keys) {
    for (var i = 0; i < keys.length; i++) tc.keyClick(keys[i])
  }

  // Blanks the panel through the lock and clears the field, ready for a key.
  function blank() {
    view.passwordTextEdited("")
    service.runBlank()
    blankCountdown.stop()
  }

  property var blankCountdown: null

  function setUp() {
    service = load("Service.qml", host, { omarchyPath: rootPath })
    // The real commands would drive the displays.
    process("omarchy-system-wake").command = ["true"]
    process("omarchy-brightness-display off").command = ["true"]
    process("monitors").command = ["true"]
    blankCountdown = child(function(object) { return object.armedAt !== undefined }, "blank countdown")
    service.lockRequested = true

    view = load("LockView.qml", surface.contentItem, { width: 800, height: 600, loadBackground: false })
    view.displaysBlank = Qt.binding(function() { return service.displaysBlank })
    view.passwordText = Qt.binding(function() { return service.enteredPassword })
    view.passwordTextEdited.connect(function(password) { service.enteredPassword = password })
    view.wakeRequested.connect(function() {
      service.runWake()
      blankCountdown.stop()
    })
    view.forcePasswordFocus()
  }

  Component.onCompleted: {
    steps = [
      [function() { root.setUp() }, 300],
      [function() {
        root.blank()
        root.type([Qt.Key_A, Qt.Key_B, Qt.Key_C])
        root.check(root.service.enteredPassword === "bc", "the key that wakes a dark panel is not typed: '" + root.service.enteredPassword + "'")
        root.check(!root.service.displaysBlank, "the wake key lights the panel")

        // An outside wake, a bound key or the pointer, as the idle monitor
        // reports it: the settle runs, and the keys typed after it all count.
        root.blank()
        root.timer(150, false).restart()
      }, 400],
      [function() {
        root.check(!root.service.displaysBlank, "input that lit the panel elsewhere clears the blank state once settled")
        root.type([Qt.Key_A, Qt.Key_B, Qt.Key_C])
        root.check(root.service.enteredPassword === "abc", "keys typed after an outside wake all reach the field: '" + root.service.enteredPassword + "'")

        // Hyprland reporting a display lit, as the poll reads it.
        root.blank()
        root.service.applyDisplayState(JSON.stringify([{ name: "eDP-1", dpmsStatus: true }]))
        root.type([Qt.Key_X])
        root.check(root.service.enteredPassword === "x", "a display Hyprland reports lit stops the swallow: '" + root.service.enteredPassword + "'")

        // A display still off, and one disabled, leave the next key a wake key.
        root.blank()
        root.service.applyDisplayState(JSON.stringify([{ name: "eDP-1", dpmsStatus: false }, { name: "DP-1", disabled: true, dpmsStatus: true }]))
        root.type([Qt.Key_Y, Qt.Key_Z])
        root.check(root.service.enteredPassword === "z", "a display still off keeps the next key a wake key: '" + root.service.enteredPassword + "'")

        // A blank after a pending settle starts clean.
        root.service.runWake()
        root.blankCountdown.stop()
        root.timer(150, false).restart()
        root.blank()
      }, 400],
      [function() {
        root.check(root.service.displaysBlank, "a new blank is not undone by input from before it")
      }, 1]
    ]
    next.start()
  }

  Timer {
    id: next
    interval: 1
    onTriggered: {
      try {
        if (root.step < root.steps.length) {
          var current = root.steps[root.step++]
          current[0]()
          interval = current[1]
          if (root.step < root.steps.length) { start(); return }
        }
      } catch (error) {
        root.failures.push(String(error))
      }
      root.finish()
    }
  }

  function finish() {
    try {
      if (service) {
        service.lockRequested = false
        service.resetAuthenticationState()
      }
    } catch (error) {
      failures.push(String(error))
    }
    var payload = JSON.stringify({ ok: failures.length === 0, checks: checks, failures: failures })
    var quoted = "'" + payload.replace(/'/g, "'\\''") + "'"
    Quickshell.execDetached(["bash", "-c", "printf '%s' " + quoted + " > \"$1\"", "_", resultPath])
  }

  Item { id: host }

  FloatingWindow {
    id: surface
    implicitWidth: 800
    implicitHeight: 600
    visible: true
    color: "black"

    TestCase {
      id: tc
      name: "lock-wake-key"
      when: false
    }
  }
}
