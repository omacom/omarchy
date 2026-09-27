import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick

// The only place SpaceBeach touches a live Wayland handle for presentation.
// Hyprland owns the Repeater model, so destruction removes the delegate and
// its capture before the wrapper can escape into persistent UI state.
Item {
  id: root

  property string address: ""
  property string appId: ""
  property bool active: false

  function canonicalAddress(value) {
    return String(value || "").toLowerCase().replace(/^0x/, "")
  }

  function observedAppId(toplevel) {
    try {
      var ipc = toplevel.lastIpcObject || ({})
      var value = ipc.class || ipc.initialClass || (toplevel.wayland ? toplevel.wayland.appId : "")
      return String(value || "").replace(/[\u0000-\u001f\u007f]+/g, " ").replace(/\s+/g, " ").trim().slice(0, 160)
    } catch (error) {
      return ""
    }
  }

  Repeater {
    model: root.active ? (Hyprland.toplevels.values || []) : []

    delegate: Item {
      id: candidate
      required property var modelData
      anchors.fill: parent
      readonly property bool matches: root.active
        && root.canonicalAddress(modelData.address) !== ""
        && root.canonicalAddress(modelData.address) === root.canonicalAddress(root.address)
        && root.appId !== "" && root.observedAppId(modelData) === root.appId

      Loader {
        anchors.fill: parent
        active: candidate.matches && candidate.modelData.wayland !== null
        sourceComponent: ScreencopyView {
          captureSource: candidate.modelData.wayland
          live: candidate.matches && root.active
          paintCursor: false
          constraintSize: Qt.size(Math.max(1, candidate.width), Math.max(1, candidate.height))
        }
      }
    }
  }
}
