import QtQuick
import Quickshell
import qs.plugins.bar

ShellRoot {
  id: root
  property var failures: []
  property int step: 0
  property var surfaces: []
  property var retainedTargets: []
  property var removedApi: null
  property var survivorApi: null
  property var survivorTarget: null
  property var removedSurface: null
  property var sharedTarget: null
  readonly property string resultPath: Quickshell.env("OMARCHY_QML_TEST_RESULT")

  function check(condition, message) {
    if (!condition) failures.push(message)
  }
  function slots(name) {
    return host.moduleSlots.filter(function(slot) { return slot.moduleName === name && slot.activeItem && slot.visible })
  }
  function writeResult() {
    var payload = JSON.stringify({ok: failures.length === 0, failures: failures, steps: step})
    Quickshell.execDetached(["sh", "-c", "printf '%s' \"$1\" > \"$2\"", "fixture", payload, resultPath])
  }

  Component {
    id: registeredTarget
    Item { property bool tooltipHovered: false }
  }
  Component {
    id: thirdPartyWidget
    Item {
      property var bar: null
      property string moduleName: ""
      property var settings: ({})
      property var target: null
      implicitWidth: 30
      implicitHeight: 26
      onBarChanged: {
        if (!bar || target) return
        // Deliberately retain the target outside this widget and omit widget
        // destruction cleanup: the host must retire its surface registrations.
        target = registeredTarget.createObject(root)
        root.retainedTargets.push(target)
        bar.registerClickTarget(target)
      }
    }
  }
  Component {
    id: firstPartyWidget
    Item {
      property var bar: null
      property string moduleName: ""
      property var settings: ({})
      readonly property bool revealed: bar ? bar.centerSectionRevealFor(this) : false
      implicitWidth: 30
      implicitHeight: 26
    }
  }
  QtObject {
    id: registry
    property var widgets: ({
      "test.third-party": {component: thirdPartyWidget},
      "test.first-party": {component: firstPartyWidget}
    })
    property int revision: 0
    function metadataFor(id) { return {firstParty: id === "test.first-party"} }
  }

  Bar {
    id: host
    barWidgetRegistry: registry
    barConfig: ({position: "top", transparent: false, centerAnchor: "test.first-party", layout: {
      left: ["test.third-party"], center: ["test.first-party"], right: []
    }})
  }

  Timer {
    interval: 250
    running: true
    repeat: true
    onTriggered: {
      try {
        var third = root.slots("test.third-party")
        var first = root.slots("test.first-party")
        switch (root.step++) {
        case 0:
          root.check(Quickshell.screens.length === 2, "isolated compositor provides two outputs")
          root.check(third.length === 2 && first.length === 2, "production BarPanel creates both widget kinds on two outputs")
          if (third.length !== 2 || first.length !== 2) { root.writeResult(); stop(); return }
          surfaces = third.map(function(slot) { return host.targetWindow(slot) })
          root.check(surfaces[0] !== surfaces[1], "production lookup resolves separate actual PanelWindows")
          root.check(surfaces[0].pluginApiScope && surfaces[1].pluginApiScope && surfaces[0].pluginApiScope !== surfaces[1].pluginApiScope, "actual BarPanel initializes independent lifetime scopes")
          root.check(third[0].activeItem.bar && third[1].activeItem.bar && third[0].activeItem.bar !== third[1].activeItem.bar, "actual ModuleSlot reinjects independent facades after scope initialization")
          root.check(third[0].activeItem.bar.pluginId === "test.third-party", "actual facade preserves plugin ownership ID")
          surfaces[0].centerRevealState.setBarHovered(true)
          surfaces[0].centerRevealState.setCenterSectionHovered(true)
          break
        case 1:
          for (var i = 0; i < third.length; i++) {
            var sameSurface = host.targetWindow(third[i]) === surfaces[0]
            root.check(third[i].activeItem.bar.centerSectionRevealHeld === sameSurface, "actual third-party facade binds local reveal")
          }
          for (var j = 0; j < first.length; j++) {
            root.check(first[j].activeItem.revealed === (host.targetWindow(first[j]) === surfaces[0]), "actual first-party lookup binds local reveal")
          }
          surfaces[0].centerRevealState.setCenterSectionHovered(false)
          surfaces[1].centerRevealState.setBarHovered(true)
          surfaces[0].centerRevealState.setBarHovered(false)
          break
        case 2:
          root.check(!surfaces[0].centerRevealState.centerSectionRevealHeld, "production surface collapses despite unrelated surface hover")
          // Reinjection uses the real ModuleSlot method and its live window.
          var priorApi = third[0].activeItem.bar
          third[0].activeItem.bar = null
          third[0].injectProps()
          root.check(third[0].activeItem.bar === priorApi, "actual ModuleSlot reinjection keeps its correctly scoped facade")
          break
        case 3:
          removedSurface = host.targetWindow(third[0])
          removedApi = third[0].activeItem.bar
          survivorApi = third[1].activeItem.bar
          survivorTarget = third[1].activeItem.target
          sharedTarget = registeredTarget.createObject(root)
          removedApi.registerClickTarget(sharedTarget)
          survivorApi.registerClickTarget(sharedTarget)
          root.check(host.pluginObjectOwners.filter(function(record) { return record.target === sharedTarget }).length === 2, "same-plugin objects may remain shared across surfaces")
          removedApi.requestPopout(third[0].activeItem.target)
          removedApi.unregisterClickTarget(survivorTarget)
          survivorApi.releasePopout(third[0].activeItem.target)
          root.check(host.clickTargets.indexOf(survivorTarget) !== -1, "one facade cannot unregister another surface's target")
          root.check(host.activePopout === third[0].activeItem.target, "one facade cannot release another surface's popout")
          // Simulate a screen-list removal in the production Variants. Its
          // normal delegate teardown destroys the actual panel and slots.
          var barVariants = null
          for (var k = 0; k < host.data.length; k++) {
            var node = host.data[k]
            if (node && "instances" in node && node.instances.length && "centerRevealState" in node.instances[0]) barVariants = node
          }
          root.check(barVariants !== null, "production screen Variants is accessible for simulated hot-unplug")
          if (!barVariants) { root.writeResult(); stop(); return }
          barVariants.model = [host.targetWindow(third[1]).screen]
          break
        case 4:
          root.check(third.length === 1 && third[0].activeItem.bar === survivorApi, "removing an actual BarPanel keeps the other facade live")
          root.check(host.clickTargets.length === 2 && host.clickTargets.indexOf(survivorTarget) !== -1 && host.clickTargets.indexOf(sharedTarget) !== -1, "removed PanelWindow registrations are pruned without widget unregister")
          root.check(host.activePopout === null, "removed PanelWindow popout ownership is released")
          root.check(host.pluginObjectOwners.every(function(record) { return (record.target === survivorTarget || record.target === sharedTarget) && record.scopeKey === third[0].pluginApiKey }), "only surviving surface ownership records remain")
          root.writeResult()
          stop()
          break
        }
      } catch (error) {
        failures.push(String(error)); root.writeResult(); stop()
      }
    }
  }
}
