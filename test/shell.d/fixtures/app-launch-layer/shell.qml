import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "services"

ShellRoot {
  id: test
  property var failures: []
  property int step: 0
  property double waitDeadline: 0

  function check(condition, message) {
    if (!condition) failures = failures.concat([message])
  }

  AppLibrary { id: library }
  PanelWindow {
    id: unrelated
    visible: false
    implicitWidth: 32
    implicitHeight: 32
    WlrLayershell.namespace: "fixture.unrelated"
  }
  PanelWindow {
    id: matching
    visible: false
    implicitWidth: 32
    implicitHeight: 32
    WlrLayershell.namespace: "fixture.desktop"
  }
  PanelWindow {
    id: startup
    visible: false
    implicitWidth: 32
    implicitHeight: 32
    WlrLayershell.namespace: "fixture.startup"
  }
  PanelWindow {
    id: previous
    visible: false
    implicitWidth: 32
    implicitHeight: 32
    WlrLayershell.namespace: "fixture.previous"
  }
  PanelWindow {
    id: current
    visible: false
    implicitWidth: 32
    implicitHeight: 32
    WlrLayershell.namespace: "fixture.current"
  }
  FloatingWindow {
    id: ordinary
    visible: false
    implicitWidth: 64
    implicitHeight: 64
  }

  readonly property var steps: [
    { delay: 300, run: function() {
      library.beginLaunchFeedback("Layer app", { id: "fixture.desktop.desktop", startupClass: "" })
      unrelated.visible = true
    } },
    { delay: 2200, run: function() {
      test.check(library.launchOsdOpen, "an unrelated layer does not cancel launch feedback")
      unrelated.visible = false
      matching.visible = true
    } },
    { delay: 200, ready: function() { return !library.launchOsdOpen }, run: function() {
      test.check(!library.launchOsdOpen, "a matching desktop-id layer dismisses visible feedback")
      matching.visible = false
      library.beginLaunchFeedback("Startup class", { id: "fixture.other", startupClass: "fixture.startup" })
      startup.visible = true
    } },
    { delay: 2200, run: function() {
      test.check(!library.launchOsdOpen, "a matching startup class prevents delayed feedback")
      startup.visible = false
      library.beginLaunchFeedback("Previous", { id: "fixture.previous", startupClass: "" })
      library.beginLaunchFeedback("Current", { id: "fixture.current", startupClass: "" })
      previous.visible = true
    } },
    { delay: 2200, run: function() {
      test.check(library.launchOsdOpen, "a previous launch's layer does not finish the current launch")
      current.visible = true
    } },
    { delay: 200, ready: function() { return !library.launchOsdOpen }, run: function() {
      test.check(!library.launchOsdOpen, "the current launch's layer dismisses feedback")
      previous.visible = false
      current.visible = false
      library.beginLaunchFeedback("Ordinary window", { id: "fixture.window", startupClass: "" })
      ordinary.visible = true
    } },
    { delay: 2200, run: function() {
      test.check(!library.launchOsdOpen, "ordinary toplevel windows still complete launch feedback")
      ordinary.visible = false
    } },
    { delay: 300, run: function() {
      library.beginLaunchFeedback("Missing desktop entry", null)
      unrelated.visible = true
    } },
    { delay: 2200, run: function() {
      test.check(library.launchOsdOpen, "an unknown desktop entry keeps its feedback without a matching layer")
      library.closeLaunchFeedback(library.launchSerial)
      result.setText(JSON.stringify({ ok: test.failures.length === 0, failures: test.failures }))
      quitTimer.start()
    } }
  ]

  Timer {
    interval: test.steps[0].delay
    running: true
    onTriggered: {
      var current = test.steps[test.step]
      if (current.ready && !current.ready()) {
        if (!test.waitDeadline) test.waitDeadline = Date.now() + 1000
        if (Date.now() < test.waitDeadline) {
          interval = 20
          start()
          return
        }
      }
      test.waitDeadline = 0
      test.steps[test.step].run()
      test.step++
      if (test.step < test.steps.length) {
        interval = test.steps[test.step].delay
        start()
      }
    }
  }
  FileView { id: result; path: Quickshell.env("OMARCHY_QML_TEST_RESULT") }
  Timer { id: quitTimer; interval: 200; onTriggered: Qt.quit() }
}
