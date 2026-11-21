import QtQuick
import QtTest
import Quickshell
import Quickshell.Io

// Double-clicks the empty space on the real bar through its own pointer
// handlers: with the click on the background steps once; with the click turned
// off in shell.json the same double-click steps nothing; and the drag off that
// same empty space still moves the bar, so only the cycle answers the switch.
// The cycle calls go through a logged omarchy-bar stub; the test script counts
// them.
ShellRoot {
  id: root

  readonly property string resultPath: Quickshell.env("OMARCHY_QML_TEST_RESULT")
  readonly property string rootPath: Quickshell.env("OMARCHY_PATH")
  property var failures: []
  property var bar: null
  // The bar surface the clicks happen on.
  property var surface: null
  property var gestureArea: null
  // A point over empty bar space, between the left section and the centered
  // box, in the gesture area's own coordinates.
  property real patchX: 0
  property real patchY: 0
  // How many background cycles the bar has asked for so far.
  property int cycles: -1
  property var steps: []
  property int step: 0

  function check(condition, message) {
    if (!condition) failures = failures.concat([String(message)])
  }

  // The gesture area under the whole bar: the one MouseArea with a hand-set
  // pressAndHoldInterval, so a walk of the bar window's content finds it
  // wherever the sections place it.
  function findGestureArea(item) {
    if (typeof item.pressAndHoldInterval === "number" && item.pressAndHoldInterval === 200 && typeof item.suppressClick === "boolean")
      return item
    for (var i = 0; i < item.children.length; i++) {
      var found = findGestureArea(item.children[i])
      if (found) return found
    }
    return null
  }

  // How many times the bar asked omarchy-bar to cycle the background.
  Process {
    id: counter

    stdout: StdioCollector {
      onStreamFinished: {
        var count = parseInt(text.trim(), 10)
        root.cycles = isNaN(count) ? 0 : count
      }
    }
  }

  function countCycles() {
    counter.command = ["bash", "-c", "grep -cx 'background cycle' \"$OMARCHY_CYCLE_LOG\" || true"]
    counter.running = true
  }

  Component {
    id: testWidget

    Rectangle {
      property var bar: null
      property string moduleName: ""
      property var settings: ({})
      property string fixedEdge: "center"

      implicitWidth: 30
      implicitHeight: 20
      color: "steelblue"
    }
  }

  QtObject {
    id: registry

    property int revision: 0
    property var widgets: ({
      "test.a": { component: testWidget },
      "test.clock": { component: testWidget },
      "test.b": { component: testWidget }
    })

    function metadataFor(id) {
      return widgets[id] ? { firstParty: true } : null
    }
  }

  QtObject {
    id: host

    property var config: ({
      bar: {
        position: "top",
        background: "opaque",
        layout: {
          left: [{ id: "test.a" }],
          center: [{ id: "test.clock" }],
          right: [{ id: "test.b" }]
        }
      }
    })

    function mutateShellConfig(mutator) {
      var copy = JSON.parse(JSON.stringify(config))
      mutator(copy)
      config = copy
    }
  }

  TestCase {
    id: tc
    name: "bar-clicks"
    when: false
  }

  FileView {
    id: result
    path: root.resultPath
  }

  Component.onCompleted: {
    steps = [
      [function() {
        var component = Qt.createComponent("file://" + root.rootPath + "/shell/plugins/bar/Bar.qml")
        if (component.status !== Component.Ready) {
          root.check(false, "Bar.qml loads: " + component.errorString())
          return
        }
        root.bar = component.createObject(root, { barWidgetRegistry: registry, shell: host, barConfig: host.config.bar })
        root.bar.barConfig = Qt.binding(function() { return host.config.bar })
      }, 1200],

      [function() {
        root.check(root.bar.cycleBackgroundOnClick === true, "a config without clicks keeps the background cycle on")
        root.check(root.bar.cycleLayoutOnClick === true, "a config without clicks keeps the layout cycle on")
        var a = root.bar.moduleSlots.filter(function(slot) { return slot && slot.moduleName === "test.a" })[0]
        root.surface = a ? root.bar.slotWindow(a) : null
        root.check(root.surface && root.surface.contentItem, "the bar surface is there")
        if (!root.surface || !root.surface.contentItem) return
        root.gestureArea = root.findGestureArea(root.surface.contentItem)
        root.check(root.gestureArea, "the empty-space gesture area is there")
        if (!root.gestureArea) return
        root.patchX = root.gestureArea.width * 0.2
        root.patchY = root.gestureArea.height / 2
        tc.mouseDoubleClickSequence(root.gestureArea, root.patchX, root.patchY)
      }, 300],

      [function() {
        root.countCycles()
      }, 400],
      [function() {
        root.check(root.cycles === 1, "one cycle from the empty-space double-click with the click on: " + root.cycles)
      }, 100],

      // Turning the clicks off in shell.json reaches the bar, and the same
      // double-click steps nothing now.
      [function() {
        host.mutateShellConfig(function(config) {
          config.bar.clicks = { background: false, layout: false }
        })
      }, 400],
      [function() {
        root.check(root.bar.cycleBackgroundOnClick === false, "a clicks false turns the background cycle off")
        root.check(root.bar.cycleLayoutOnClick === false, "the same write turns the layout cycle off")
        tc.mouseDoubleClickSequence(root.gestureArea, root.patchX, root.patchY)
      }, 400],
      [function() {
        root.countCycles()
      }, 400],
      [function() {
        root.check(root.cycles === 1, "no further cycle with the click off: " + root.cycles)

        // The switch leaves the drag alone: the bar still follows a drag off
        // the same empty space and lands at the pointer's edge.
        tc.mousePress(root.gestureArea, root.patchX, root.patchY)
      }, 100],
      [function() {
        tc.mouseMove(root.gestureArea, root.patchX, Quickshell.screens[0].height - 8, -1, Qt.LeftButton)
      }, 300],
      [function() {
        root.check(root.bar.barMoveActive === true, "a drag with the clicks off still starts a bar move")
        tc.mouseRelease(root.gestureArea, root.patchX, Quickshell.screens[0].height - 8)
      }, 700],
      [function() {
        root.check(host.config.bar.position === "bottom", "the bar lands at the bottom edge: " + host.config.bar.position)
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

  Timer {
    id: quitter
    interval: 200
    onTriggered: Qt.quit()
  }
}
