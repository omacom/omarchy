import QtQuick
import Quickshell
import qs.Commons
import qs.Ui

ShellRoot {
  id: root

  readonly property string resultPath: Quickshell.env("OMARCHY_QML_TEST_RESULT")
  property var failures: []

  function fail(message) {
    failures.push(String(message))
  }

  function assertEqual(actual, expected, message) {
    if (actual !== expected) fail(message + " expected=" + expected + " actual=" + actual)
  }

  function shellQuote(value) {
    return "'" + String(value).replace(/'/g, "'\\''") + "'"
  }

  function writeResult() {
    var payload = JSON.stringify({ ok: failures.length === 0, failures: failures })
    Quickshell.execDetached(["bash", "-lc", "printf '%s' " + shellQuote(payload) + " > " + shellQuote(resultPath)])
  }

  function enabledHandlers(target) {
    return IpcRegistry.handlers.filter(function(handler) {
      return handler && handler.enabled && handler.target === target
    }).length
  }

  // One bar per monitor: each lists its copy of a module as a slot.
  QtObject {
    id: fakeBar
    property var moduleSlots: []
    function moduleWidgets(id) {
      return moduleSlots.filter(function(slot) { return slot.moduleName === id })
        .map(function(slot) { return slot.activeItem })
    }
  }

  Component { id: panelComponent; Panel { ipcTarget: "test.panel" } }
  Component { id: widgetComponent; Widget {} }

  Item { id: host }

  Timer {
    interval: 1
    running: true
    onTriggered: {
      var panels = [panelComponent.createObject(host), panelComponent.createObject(host)]
      var widgets = [widgetComponent.createObject(host), widgetComponent.createObject(host)]
      var copies = [
        { moduleName: "test.panel", items: panels },
        { moduleName: "test.widget", items: widgets }
      ]

      root.assertEqual(root.enabledHandlers("test.panel"), 0, "a panel registers nothing before the bar injects it")
      root.assertEqual(root.enabledHandlers("test.widget"), 0, "a widget registers nothing before the bar injects it")

      // The bar registers each slot, then injects bar and moduleName.
      var slots = []
      copies.forEach(function(copy) {
        copy.items.forEach(function(item) { slots.push({ moduleName: copy.moduleName, activeItem: item }) })
      })
      fakeBar.moduleSlots = slots
      copies.forEach(function(copy) {
        copy.items.forEach(function(item) {
          item.bar = fakeBar
          item.moduleName = copy.moduleName
        })
      })

      root.assertEqual(root.enabledHandlers("test.panel"), 1, "two panel copies register their target once")
      root.assertEqual(root.enabledHandlers("test.widget"), 1, "two widget copies register their target once")
      root.assertEqual(panels[0].ipcOwner, true, "the first panel copy owns the target")
      root.assertEqual(widgets[0].ipcOwner, true, "the first widget copy owns the target")

      // The first monitor goes away; the copy left takes the target over.
      fakeBar.moduleSlots = slots.filter(function(slot) {
        return slot.activeItem !== panels[0] && slot.activeItem !== widgets[0]
      })
      panels[0].destroy()
      widgets[0].destroy()

      Qt.callLater(function() {
        root.assertEqual(panels[1].ipcOwner, true, "the remaining panel copy takes the target over")
        root.assertEqual(widgets[1].ipcOwner, true, "the remaining widget copy takes the target over")
        root.assertEqual(root.enabledHandlers("test.panel"), 1, "the panel target stays registered once")
        root.assertEqual(root.enabledHandlers("test.widget"), 1, "the widget target stays registered once")
        root.writeResult()
      })
    }
  }
}
