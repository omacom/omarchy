import QtQuick
import QtQml.Models
import Quickshell
import "BarModel.js" as BarModel

ShellRoot {
  id: root
  property int created: 0
  ListModel { id: entries }
  Item {
    Repeater {
      id: widgets
      model: entries
      Item {
        required property string entryJson
        property var settings: JSON.parse(entryJson)
        Component.onCompleted: root.created++
      }
    }
  }
  function check(value, message) {
    if (!value) throw new Error(message)
  }
  Timer {
    interval: 1
    running: true
    onTriggered: {
      try {
        var clock = {id: "clock", format: "HH:mm"}
        var sound = {id: "groups", groupId: "sound", items: ["audio"]}
        var devices = {id: "groups", groupId: "devices", items: ["bluetooth"]}
        BarModel.syncEntries(entries, [clock, sound, devices, "divider", "divider"])
        var clockItem = widgets.itemAt(0)
        var soundItem = widgets.itemAt(1)
        var devicesItem = widgets.itemAt(2)
        var dividerA = widgets.itemAt(3)
        var dividerB = widgets.itemAt(4)
        var initialCreated = root.created
        BarModel.syncEntries(entries, [clock, sound, devices, "divider", "divider"])
        check(root.created === initialCreated, "identical config recreated delegates")
        var movedSound = {id: "groups", groupId: "sound", items: ["audio", {id: "network", nested: {values: [1, 2]}}]}
        BarModel.syncEntries(entries, [devices, clock, movedSound, "divider", "divider", "network"])
        check(widgets.itemAt(0) === devicesItem && widgets.itemAt(1) === clockItem
          && widgets.itemAt(2) === soundItem, "reorder/settings change lost widget identity")
        check(widgets.itemAt(3) === dividerA && widgets.itemAt(4) === dividerB,
          "duplicate entries lost their occurrence identity")
        check(root.created === initialCreated + 1, "insertion recreated existing delegates")
        check(Array.isArray(soundItem.settings.items)
          && soundItem.settings.items[1].nested.values[1] === 2, "nested settings changed shape")
        BarModel.syncEntries(entries, [devices, clock, movedSound])
        check(widgets.count === 3 && widgets.itemAt(2) === soundItem
          && widgets.itemAt(1) === clockItem, "removal recreated surviving delegates")
        BarModel.syncEntries(entries, [devices, {id: "clock", format: "ss"}, movedSound])
        check(widgets.itemAt(1) === clockItem && clockItem.settings.format === "ss",
          "settings did not update the existing widget")
        BarModel.syncEntries(entries, [])
        check(widgets.count === 0, "empty layout retained delegates")
        BarModel.syncEntries(entries, ["clock"])
        check(widgets.count === 1 && widgets.itemAt(0).settings === "clock", "empty layout cannot be populated again")
        console.log("BAR_LAYOUT_MODEL_OK")
      } catch (error) {
        console.error("BAR_LAYOUT_MODEL_FAIL: " + error)
      }
      Qt.quit()
    }
  }
}
