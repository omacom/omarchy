import QtQuick
import QtTest
import Quickshell
import Quickshell.Io

// Drags widgets along the real bar through its own pointer handlers, and
// checks where they land and that each arrives as the very instance that was
// dragged: two entries alike in every way stay apart, and nothing is built
// again.
ShellRoot {
  id: root

  readonly property string resultPath: Quickshell.env("OMARCHY_QML_TEST_RESULT")
  readonly property string rootPath: Quickshell.env("OMARCHY_PATH")
  property var failures: []
  property var made: ({})
  property var gone: ({})
  property var bar: null
  // The bar surface the drags happen on, the first there is.
  property var surface: null
  property var firstTwin: null
  property var secondTwin: null
  property var shown: null
  // The slot the pointer is holding.
  property var held: null
  property string counts: ""
  property var steps: []
  property int step: 0

  function check(condition, message) {
    if (!condition) failures = failures.concat([String(message)])
  }

  function bump(map, name) {
    var next = Object.assign({}, root[map])
    next[name] = (next[name] || 0) + 1
    root[map] = next
  }

  function countsNow() {
    return JSON.stringify(made) + JSON.stringify(gone)
  }

  function ids(region) {
    var layout = host.config.bar.layout
    var list = region.indexOf("drawer:") === 0 ? (layout.drawers || {})[region.slice(7)] : layout[region]
    return (list || []).map(function(entry) { return entry.id })
  }

  // A widget's slots on the surface, along the bar.
  function slotsOf(name) {
    var found = bar.moduleSlots.filter(function(slot) {
      return slot && slot.moduleName === name && root.bar.slotWindow(slot) === root.surface
    })
    found.sort(function(a, b) { return root.along(a) - root.along(b) })
    return found
  }

  function slotOf(name, region) {
    return slotsOf(name).filter(function(slot) { return slot.region === region })[0] || null
  }

  function along(item) {
    return item.mapToItem(null, 0, 0).x
  }

  // Presses a widget and pulls it past the drag threshold.
  function lift(slot) {
    held = slot
    tc.mousePress(slot, slot.width / 2, slot.height / 2)
    tc.mouseMove(slot, slot.width / 2 + 24, slot.height / 2, -1, Qt.LeftButton)
  }

  // Moves the held pointer to `fraction` of the way along `over`.
  function pointAt(over, fraction) {
    var point = held.mapFromItem(over, over.width * fraction, over.height / 2)
    tc.mouseMove(held, point.x, point.y, -1, Qt.LeftButton)
  }

  function letGo(over, fraction) {
    var point = held.mapFromItem(over, over.width * fraction, over.height / 2)
    tc.mouseRelease(held, point.x, point.y)
  }

  // Counts every instance built and torn down. The two test.twin entries are
  // alike in every setting, so only the instances can tell them apart.
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
      onModuleNameChanged: if (moduleName) root.bump("made", moduleName)
      Component.onDestruction: root.bump("gone", moduleName)
    }
  }

  // A tray as far as the bar sees one: it hosts the tray section, and says
  // which edge the section's widgets grow from.
  Component {
    id: testTray

    Item {
      property var bar: null
      property string moduleName: ""
      property var settings: ({})
      property string fixedEdge: "center"
      property Item sectionHost: section
      readonly property string sectionEdge: fixedEdge === "start" ? "start" : "end"

      implicitWidth: 30 + section.implicitWidth
      implicitHeight: 20

      Item {
        id: section
        x: 30
        implicitWidth: childrenRect.width
        implicitHeight: childrenRect.height
      }
    }
  }

  QtObject {
    id: registry

    property int revision: 0
    property var widgets: ({
      "test.a": { component: testWidget },
      "test.b": { component: testWidget },
      "test.c": { component: testWidget },
      "test.d": { component: testWidget },
      "test.clock": { component: testWidget },
      "test.twin": { component: testWidget },
      "test.inner": { component: testWidget },
      "test.tray": { component: testTray }
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
          right: [{ id: "test.twin" }, { id: "test.b" }, { id: "test.twin" }, { id: "test.c" }]
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
    name: "bar-drag"
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

      // Two twins in the right section, each marked from inside.
      [function() {
        var a = root.bar.moduleSlots.filter(function(slot) { return slot && slot.moduleName === "test.a" })[0]
        root.surface = a ? root.bar.slotWindow(a) : null
        var twins = root.slotsOf("test.twin")
        root.check(twins.length === 2, "the bar shows both twins")
        if (twins.length !== 2) return
        root.firstTwin = twins[0].activeItem
        root.secondTwin = twins[1].activeItem
        root.firstTwin.objectName = "first"
        root.secondTwin.objectName = "second"
        root.counts = root.countsNow()
        root.lift(twins[0])
      }, 300],
      [function() { root.pointAt(root.slotOf("test.a", "left"), 0.8) }, 300],
      [function() { root.letGo(root.slotOf("test.a", "left"), 0.8) }, 700],
      [function() {
        root.check(JSON.stringify(root.ids("left")) === JSON.stringify(["test.a", "test.twin"]), "the first twin lands after test.a: " + JSON.stringify(root.ids("left")))
        root.check(JSON.stringify(root.ids("right")) === JSON.stringify(["test.b", "test.twin", "test.c"]), "the right section keeps the other twin: " + JSON.stringify(root.ids("right")))
        var moved = root.slotOf("test.twin", "left")
        var stayed = root.slotOf("test.twin", "right")
        root.check(moved && moved.activeItem === root.firstTwin && moved.activeItem.objectName === "first", "the dragged twin arrives as the very instance dragged")
        root.check(stayed && stayed.activeItem === root.secondTwin && stayed.activeItem.objectName === "second", "the other twin keeps its own instance where it was")
        root.check(root.countsNow() === root.counts, "no widget is built again or torn down: " + root.countsNow())

        // Back into the right section, just before its twin.
        root.lift(moved)
      }, 300],
      [function() { root.pointAt(root.slotOf("test.twin", "right"), 0.2) }, 300],
      [function() { root.letGo(root.slotOf("test.twin", "right"), 0.2) }, 700],
      [function() {
        root.check(JSON.stringify(root.ids("right")) === JSON.stringify(["test.b", "test.twin", "test.twin", "test.c"]), "the twin lands just before its twin: " + JSON.stringify(root.ids("right")))
        var twins = root.slotsOf("test.twin")
        root.check(twins.length === 2 && twins[0].activeItem === root.firstTwin && twins[1].activeItem === root.secondTwin, "side by side, each twin is still its own instance, in the order they were put")
        root.check(root.countsNow() === root.counts, "still nothing is built again or torn down: " + root.countsNow())

        // A widget that shows itself mid-drag can be dropped beside.
        root.shown = root.slotOf("test.c", "right").activeItem
        root.shown.visible = false
      }, 300],
      [function() { root.lift(root.slotOf("test.b", "right")) }, 200],
      [function() { root.shown.visible = true }, 300],
      [function() { root.pointAt(root.slotOf("test.c", "right"), 0.8) }, 300],
      [function() { root.letGo(root.slotOf("test.c", "right"), 0.8) }, 700],
      [function() {
        root.check(JSON.stringify(root.ids("right")) === JSON.stringify(["test.twin", "test.twin", "test.c", "test.b"]), "a widget dropped beside one that showed itself mid-drag lands there: " + JSON.stringify(root.ids("right")))
        root.check(root.countsNow() === root.counts, "the drag builds nothing again: " + root.countsNow())

        // The tray section's widgets grow from the edge the tray anchors the
        // section by, wherever the tray goes.
        host.mutateShellConfig(function(config) {
          config.bar.layout.right.push({ id: "test.tray" })
          config.bar.layout.tray = [{ id: "test.inner" }]
        })
      }, 400],
      [function() {
        var inner = root.slotsOf("test.inner")[0]
        root.check(inner && inner.activeItem.fixedEdge === "end", "a tray in the right section has the widgets in its section grow from its end: " + (inner ? inner.activeItem.fixedEdge : "none shown"))
        host.mutateShellConfig(function(config) {
          config.bar.layout.right = config.bar.layout.right.filter(function(entry) { return entry.id !== "test.tray" })
          config.bar.layout.left.push({ id: "test.tray" })
        })
      }, 400],
      [function() {
        var inner = root.slotsOf("test.inner")[0]
        root.check(inner && inner.activeItem.fixedEdge === "start", "moved to the left section, the tray has them grow from its start: " + (inner ? inner.activeItem.fixedEdge : "none shown"))

        // A drawer holds widgets of its own, the section drawer:<id>, drawn
        // inside it as the tray section is inside the tray.
        host.mutateShellConfig(function(config) {
          config.bar.layout.right.push({ id: "box", type: "drawer", collapsed: false })
          config.bar.layout.drawers = { box: [{ id: "test.d" }] }
        })
      }, 600],
      [function() {
        var box = root.slotOf("box", "right")
        var inside = root.slotOf("test.d", "drawer:box")
        root.check(box && box.hostsSection && box.hostedSection === "drawer:box", "a drawer on the bar hosts its own section")
        root.check(!!inside, "the drawer shows its widget")
        root.check(inside && inside.activeItem.fixedEdge === "end", "a drawer in the right section opens toward the middle, its widgets growing from its end: " + (inside ? inside.activeItem.fixedEdge : "none shown"))
        if (!inside) return
        root.shown = inside.activeItem
        root.counts = root.countsNow()
        root.lift(inside)
      }, 300],
      [function() { root.pointAt(root.slotOf("test.a", "left"), 0.8) }, 300],
      [function() { root.letGo(root.slotOf("test.a", "left"), 0.8) }, 700],
      [function() {
        root.check(JSON.stringify(root.ids("left")) === JSON.stringify(["test.a", "test.d", "test.tray"]), "a widget dragged out of a drawer lands on the bar: " + JSON.stringify(root.ids("left")))
        root.check(JSON.stringify(root.ids("drawer:box")) === "[]", "and leaves the drawer: " + JSON.stringify(root.ids("drawer:box")))
        var moved = root.slotOf("test.d", "left")
        root.check(moved && moved.activeItem === root.shown, "it arrives as the very instance dragged")
        root.check(root.countsNow() === root.counts, "nothing is built again: " + root.countsNow())
        if (moved) root.lift(moved)
      }, 300],
      // While a widget is dragged the drawer opens, empty, and a drop over it
      // goes in.
      [function() { root.pointAt(root.slotOf("box", "right"), 0.5) }, 400],
      [function() {
        var box = root.slotOf("box", "right")
        root.check(root.bar.barDragRegion === "drawer:box", "over an empty drawer, the drop would go into it: " + root.bar.barDragRegion)
        root.letGo(box, 0.5)
      }, 700],
      [function() {
        root.check(JSON.stringify(root.ids("drawer:box")) === JSON.stringify(["test.d"]), "a widget dropped over a drawer lands in it: " + JSON.stringify(root.ids("drawer:box")))
        var back = root.slotOf("test.d", "drawer:box")
        root.check(back && back.activeItem === root.shown, "it is still the instance dragged")
        root.check(root.countsNow() === root.counts, "still nothing is built again: " + root.countsNow())
        // The drawer itself never goes into a drawer.
        root.lift(root.slotOf("box", "right"))
      }, 300],
      [function() { root.pointAt(root.slotOf("box", "right"), 0.5) }, 400],
      [function() {
        root.check(root.bar.barDragRegion !== "drawer:box", "a drawer is never dropped into itself: " + root.bar.barDragRegion)
        root.letGo(root.slotOf("box", "right"), 0.5)
      }, 700],
      [function() {
        root.check(JSON.stringify(root.ids("drawer:box")) === JSON.stringify(["test.d"]), "the drawer keeps its widget: " + JSON.stringify(root.ids("drawer:box")))
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
