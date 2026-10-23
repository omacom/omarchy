import QtQuick
import Quickshell
import Quickshell.Io

// Presses the real workspace buttons with the bar's command calls stubbed:
// the active number cycles the layout only while the click is on, and a press
// on another number still asks to focus it either way.
ShellRoot {
  id: root

  readonly property string resultPath: Quickshell.env("OMARCHY_QML_TEST_RESULT")
  readonly property string rootPath: Quickshell.env("OMARCHY_PATH")
  property var failures: []
  property var widgetComponent: null
  property var widget: null
  property var buttons: []
  property var activeButton: null
  property var otherButton: null
  property var steps: []
  property int step: 0

  function check(condition, message) {
    if (!condition) failures = failures.concat([String(message)])
  }

  // The Workspaces widget's only interactive items are its WidgetButtons.
  function collectButtons(item, out) {
    if (!item) return out
    if (typeof item.modelData === "number" && typeof item.shown === "boolean") out.push(item)
    var children = item.children || []
    for (var i = 0; i < children.length; i++) collectButtons(children[i], out)
    return out
  }

  function clearCalls() {
    fakeBar.calls = []
  }

  function lastCall() {
    return fakeBar.calls.length ? fakeBar.calls[fakeBar.calls.length - 1] : ""
  }

  // What a cloned widget sees as its bar: the fields the workspaces widget
  // and its buttons read, and a run() that records instead of acting.
  QtObject {
    id: fakeBar

    property bool cycleLayoutOnClick: true
    property bool vertical: false
    property int barSize: 24
    property color foreground: "#ffffff"
    property color barForeground: "#ffffff"
    property color urgent: "#ff0000"
    property color background: "#000000"
    property string fontFamily: "monospace"
    property bool foregroundAnimationEnabled: false
    property var calls: []

    function run(command) { calls = calls.concat([String(command)]) }
    function hideTooltip(target) {}
  }

  Component.onCompleted: {
    widgetComponent = Qt.createComponent("file://" + root.rootPath + "/shell/plugins/bar/widgets/Workspaces.qml")
    steps = [
      [function() {
        if (!root.widgetComponent) return
        if (root.widgetComponent.status === Component.Error) {
          root.check(false, "Workspaces.qml loads: " + root.widgetComponent.errorString())
          return
        }
        if (root.widgetComponent.status !== Component.Ready) return
        if (!root.widget) root.widget = root.widgetComponent.createObject(root, { bar: fakeBar })
        root.check(root.widget !== null, "the workspaces widget is created")
      }, 1200],

      [function() {
        if (!root.widget) return
        root.check(root.widget.monitor !== null && root.widget.monitor !== undefined, "the widget sees a monitor")
        root.buttons = root.collectButtons(root.widget, [])
        root.check(root.buttons.length > 0, "the widget has workspace buttons: " + root.buttons.length)
        for (var i = 0; i < root.buttons.length; i++) {
          if (root.buttons[i].shown) root.activeButton = root.buttons[i]
          else if (!root.otherButton) root.otherButton = root.buttons[i]
        }
        root.check(root.activeButton !== null, "an active workspace button is there")
        root.check(root.otherButton !== null, "another workspace button is there")
      }, 100],

      // With the click on, the active number runs the layout cycle.
      [function() {
        if (!root.activeButton) return
        root.clearCalls()
        root.activeButton.triggerPress(0)
      }, 150],
      [function() {
        root.check(root.lastCall().indexOf("workspace-layout-toggle") !== -1,
          "the active workspace cycles the layout while the click is on: " + root.lastCall())
      }, 100],

      // And another number still switches, not cycles.
      [function() {
        if (!root.otherButton) return
        root.clearCalls()
        root.otherButton.triggerPress(0)
      }, 150],
      [function() {
        root.check(root.lastCall().indexOf("hyprctl dispatch") !== -1,
          "another workspace number still focuses it: " + root.lastCall())
        root.check(root.lastCall().indexOf("workspace-layout-toggle") === -1,
          "another workspace number does not cycle the layout")
      }, 100],

      // With the click off, the active number is inert.
      [function() {
        fakeBar.cycleLayoutOnClick = false
      }, 100],
      [function() {
        if (!root.activeButton) return
        root.clearCalls()
        root.activeButton.triggerPress(0)
      }, 150],
      [function() {
        root.check(fakeBar.calls.length === 0,
          "the active workspace does nothing while the click is off: " + root.lastCall())
      }, 100],

      // Other numbers still switch.
      [function() {
        if (!root.otherButton) return
        root.clearCalls()
        root.otherButton.triggerPress(0)
      }, 150],
      [function() {
        root.check(root.lastCall().indexOf("hyprctl dispatch") !== -1,
          "another workspace number still focuses it with the click off: " + root.lastCall())
      }, 100]
    ]

    stepper.start()
  }

  Timer {
    id: stepper
    interval: 10
    onTriggered: {
      if (root.step >= root.steps.length) {
        result.setText(JSON.stringify({ ok: root.failures.length === 0, failures: root.failures }))
        quitter.start()
        return
      }
      var current = root.steps[root.step++]
      try {
        current[0]()
      } catch (e) {
        root.check(false, "step " + root.step + " threw: " + e)
      }
      interval = current[1]
      restart()
    }
  }

  FileView {
    id: result
    path: root.resultPath
  }

  Timer {
    id: quitter
    interval: 200
    onTriggered: Qt.quit()
  }
}
