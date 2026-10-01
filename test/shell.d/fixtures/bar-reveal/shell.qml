import QtQuick
import Quickshell
import qs.Ui
import qs.plugins.bar

ShellRoot {
  id: root
  property var failures: []
  property int step: 0
  property bool suppressed: false
  readonly property bool visual: Quickshell.env("OMARCHY_BAR_REVEAL_VISUAL") === "1"
  readonly property string resultPath: Quickshell.env("OMARCHY_QML_TEST_RESULT")

  function check(condition, message) {
    if (!condition) failures.push(message)
  }

  Component.onCompleted: {
    // PanelWindow has no offscreen backend; compile the production host during
    // visual inspection without instantiating its desktop surfaces.
    if (visual) {
      var barComponent = Qt.createComponent("file://" + Quickshell.env("OMARCHY_PATH") + "/shell/plugins/bar/Bar.qml")
      if (barComponent.status !== Component.Ready) console.error(barComponent.errorString())
    }
  }

  FloatingWindow {
    visible: root.visual
    title: "Omarchy independent bar reveals"
    implicitWidth: 880
    implicitHeight: 180
    color: "#202020"

    Row {
      anchors.centerIn: parent
      spacing: 24
      Surface { id: left; label: "Surface A" }
      Surface { id: right; label: "Surface B" }
    }
  }

  component Surface: Rectangle {
    id: surface
    property string label: ""
    readonly property alias state: state
    readonly property alias tray: trayLoader.item
    width: 400
    height: 110
    color: "#303030"
    BarRevealState { id: state }
    HoverHandler { onHoveredChanged: state.setBarHovered(hovered) }
    PluginBarApi {
      id: api
      pluginId: "test.indicators"
      moduleName: "omarchy.indicators"
      fontFamily: "monospace"
      barForeground: "white"
      barSize: 26
      foregroundAnimationEnabled: false
      centerSectionRevealHeld: state.centerSectionRevealHeld
      _centerHoverRevealSuppressed: root.suppressed
      _setCenterHoverRevealSuppressed: function(value) { root.suppressed = value }
    }
    Text { x: 8; y: 8; color: "white"; text: surface.label + " — empty space holds this reveal" }
    Rectangle {
      anchors.centerIn: parent
      width: 180
      height: 34
      color: "#505050"
      HoverHandler { onHoveredChanged: state.setCenterSectionHovered(hovered) }
      Loader {
        id: trayLoader
        anchors.centerIn: parent
        source: "file://" + Quickshell.env("OMARCHY_PATH") + "/shell/plugins/bar/widgets/Indicators.qml"
        onLoaded: { item.bar = api; item.settings = { items: ["Dnd", "NightLight", "StayAwake"] } }
      }
    }
    Text { x: 8; y: 86; color: "white"; text: "revealed=" + state.centerSectionRevealHeld + "  indicator width=" + Math.round(tray ? tray.implicitWidth : 0) }
  }

  Timer {
    interval: 220
    running: !root.visual
    repeat: true
    onTriggered: {
      switch (root.step++) {
      case 0:
        root.check(left.tray && right.tray, "production indicator widgets load")
        root.check(left.tray.implicitWidth === 0 && right.tray.implicitWidth === 0, "both surfaces start collapsed")
        left.state.setBarHovered(true)
        left.state.setCenterSectionHovered(true)
        break
      case 1:
        root.check(left.tray.implicitWidth > 0 && right.tray.implicitWidth === 0, "center hover reveals only its surface")
        left.state.setCenterSectionHovered(false)
        break
      case 2:
        root.check(left.tray.implicitWidth > 0, "empty-area bar hover holds its own reveal")
        // Enter-before-leave cross-monitor order.
        right.state.setBarHovered(true)
        left.state.setBarHovered(false)
        break
      case 3:
        root.check(left.tray.implicitWidth === 0 && right.tray.implicitWidth === 0, "unrelated bar hover cannot hold or open another reveal")
        right.state.setCenterSectionHovered(true)
        right.state.setCenterSectionHovered(false)
        right.state.setBarHovered(false)
        right.state.setBarHovered(true)
        break
      case 4:
        root.check(right.tray.implicitWidth > 0, "return before delayed collapse holds an existing reveal")
        root.suppressed = true
        break
      case 5:
        root.check(right.tray.implicitWidth === 0, "shared suppression remains effective on a local facade")
        root.suppressed = false
        right.state.setBarHovered(false)
        break
      case 6:
        root.check(right.tray.implicitWidth === 0, "local reveal collapses after leaving")
        // Leave-before-enter order and overlapping handlers on one surface.
        left.state.setBarHovered(true)
        left.state.setCenterSectionHovered(true)
        left.state.setCenterSectionHovered(true)
        left.state.setCenterSectionHovered(false)
        left.state.setBarHovered(false)
        right.state.setBarHovered(true)
        break
      case 7:
        root.check(left.state.centerSectionRevealHeld, "overlapping center handlers cannot clear an active center hover")
        left.state.setCenterSectionHovered(false)
        break
      case 8:
        root.check(!left.state.centerSectionRevealHeld, "leave-before-enter on another surface still collapses locally")
        // Destroy a revealed instance with its timer pending.
        var component = Qt.createComponent("file://" + Quickshell.env("OMARCHY_PATH") + "/shell/plugins/bar/BarRevealState.qml")
        var removed = component.createObject(root)
        removed.setCenterSectionHovered(true)
        removed.setCenterSectionHovered(false)
        removed.destroy()
        break
      case 9:
        root.check(!right.state.centerSectionRevealHeld, "destroyed surface does not strand another surface's reveal")
        var payload = JSON.stringify({ok: failures.length === 0, failures: failures, steps: root.step})
        Quickshell.execDetached(["sh", "-c", "printf '%s' \"$1\" > \"$2\"", "fixture", payload, root.resultPath])
        stop()
        break
      }
    }
  }
}
