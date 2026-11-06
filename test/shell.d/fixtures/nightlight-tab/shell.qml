import QtQuick
import Quickshell
import Quickshell.Io

ShellRoot {
  id: root

  readonly property string rootPath: Quickshell.env("OMARCHY_PATH")
  readonly property string resultPath: Quickshell.env("OMARCHY_QML_TEST_RESULT")
  property var bar: null
  property int attempts: 0

  function findNightlight(item) {
    if (!item) return null
    if (item.moduleName === "NightLight" && typeof item.switchPanel === "function") return item
    var children = item.children || []
    for (var i = 0; i < children.length; i++) {
      var found = findNightlight(children[i])
      if (found) return found
    }
    return null
  }

  function finish(ok, message) {
    result.setText(JSON.stringify({ ok: ok, failures: ok ? [] : [message] }))
  }

  FileView {
    id: result
    path: root.resultPath
  }

  QtObject {
    id: nightlightService
    property bool enabled: false
    property bool scheduled: false
    property string scheduleTimezone: ""
    property string nextEvent: ""
    property string nextEventAt: ""
    function setNightlight(value) { enabled = value }
    function setScheduleEnabled(value) { scheduled = value }
  }

  Component {
    id: neighbour
    Item {
      id: neighbourWidget
      property var bar: null
      property string moduleName: ""
      property var settings: ({})
      property bool opened: false
      implicitWidth: 40
      implicitHeight: 26
      function open() {
        if (bar) bar.requestPopout(neighbourWidget)
        opened = true
      }
      function close() {
        opened = false
        if (bar) bar.releasePopout(neighbourWidget)
      }
    }
  }

  QtObject {
    id: registry
    property var widgets: ({})
    property int revision: 0
    function metadataFor(id) { return widgets[id] ? { firstParty: true } : null }
  }

  QtObject {
    id: host
    property var config: ({
      bar: {
        position: "top",
        background: "opaque",
        layout: {
          left: [],
          centerBegin: [{ id: "omarchy.indicators", items: ["NightLight"] }],
          center: [{ id: "test.neighbour" }],
          centerEnd: [],
          right: []
        }
      }
    })
    function firstPartyServiceFor(id) { return id === "omarchy.nightlight" ? nightlightService : null }
  }

  Component.onCompleted: {
    var indicators = Qt.createComponent("file://" + rootPath + "/shell/plugins/bar/widgets/Indicators.qml")
    var barComponent = Qt.createComponent("file://" + rootPath + "/shell/plugins/bar/Bar.qml")
    if (indicators.status !== Component.Ready || barComponent.status !== Component.Ready) {
      finish(false, "components failed to load: " + indicators.errorString() + " " + barComponent.errorString())
      return
    }
    registry.widgets = {
      "omarchy.indicators": { component: indicators },
      "test.neighbour": { component: neighbour }
    }
    root.bar = barComponent.createObject(root, {
      barWidgetRegistry: registry,
      shell: host,
      barConfig: host.config.bar
    })
    root.bar.barConfig = Qt.binding(function() { return host.config.bar })
    probe.start()
  }

  Timer {
    id: probe
    interval: 50
    repeat: true
    onTriggered: {
      root.attempts++
      var slots = root.bar ? root.bar.moduleSlots : []
      var indicators = slots.filter(function(slot) { return slot && slot.moduleName === "omarchy.indicators" })[0]
      var neighbourSlot = slots.filter(function(slot) { return slot && slot.moduleName === "test.neighbour" })[0]
      var nightlight = indicators && root.findNightlight(indicators.activeItem)
      if (!nightlight || !neighbourSlot || !neighbourSlot.activeItem || indicators.width <= 0 || neighbourSlot.width <= 0) {
        if (root.attempts < 80) return
        stop()
        root.finish(false, "bar indicators and neighbour did not load")
        return
      }
      stop()
      nightlight.open()
      Qt.callLater(function() {
        if (root.bar.activePopout !== indicators.activeItem || !indicators.panelOpen) {
          root.finish(false, "Night Light did not register its bar widget as the popup owner")
          return
        }
        if (!nightlight.opened || !nightlight.switchPanel(1) || !neighbourSlot.activeItem.opened || nightlight.opened) {
          root.finish(false, "Tab from Night Light did not open the neighbouring panel")
          return
        }
        if (!root.bar.switchPanelFrom(neighbourSlot.activeItem, -1) || !nightlight.opened || neighbourSlot.activeItem.opened) {
          root.finish(false, "Shift+Tab from the neighbour did not reopen Night Light")
          return
        }
        nightlight.close()
        if (!root.bar.summonBarWidget("omarchy.indicators") || !nightlight.opened) {
          root.finish(false, "the Night Light panel cannot be summoned by its bar widget")
          return
        }
        indicators.activeItem.settings = { items: ["Dnd"] }
        Qt.callLater(function() {
          root.finish(root.bar.findPanelWidget("omarchy.indicators") === null && root.bar.activePopout !== indicators.activeItem,
            "removing Night Light must release its popup and navigation target")
        })
      })
    }
  }
}
