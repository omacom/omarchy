import QtQuick
import Quickshell
import qs.Commons
import qs.Ui as Ui
import "plugin" as Plugin

// Offline listing artwork: actual components, backed by NativePreview fixtures.
FloatingWindow {
  id: window
  required property var backend
  visible: true
  implicitWidth: 1056
  implicitHeight: 650
  color: Color.background

  function capture(done) {
    artwork.grabToImage(result => {
      if (!result.saveToFile(Quickshell.env("KEYBOARD_PREVIEW_OUTPUT") + "/listing.png"))
        throw new Error("Listing screenshot failed")
      window.visible = false
      done()
    })
  }

  Item {
    id: artwork
    anchors.fill: parent
    Rectangle { anchors.fill: parent; color: Color.background }
    Text {
      x: 32; y: 28
      text: "Keyboard Layouts"
      font.family: Style.font.family
      font.pixelSize: 30
      color: Color.popups.text
    }
    Text {
      x: 32; y: 78
      text: "Your languages, login default, and switching shortcut — from the Omarchy bar."
      font.family: Style.font.family
      font.pixelSize: 15
      color: Color.popups.text
    }
    Repeater {
      model: [
        {x: 32, width: 272, title: "Switch from the bar", page: "picker"},
        {x: 328, width: 336, title: "Make it yours", page: "editor"},
        {x: 688, width: 336, title: "Find layouts & variants", page: "search"}
      ]
      delegate: Item {
        required property var modelData
        x: modelData.x; y: 140
        width: modelData.width
        Text {
          text: modelData.title
          font.family: Style.font.family
          font.pixelSize: 16
          color: Color.popups.text
        }
        Plugin.Indicator {
          visible: modelData.page === "picker"
          anchors.right: parent.right
          y: -4
          backend: window.backend
          animate: false
        }
        Ui.BorderSurface {
          y: 42
          width: parent.width
          height: picker.implicitHeight + 28
          color: Color.popups.background
          borderSpec: Border.surfaceSpec("popups", "border", Color.popups.border, 2)
          radius: Style.cornerRadius
          Plugin.Picker {
            id: picker
            x: 14; y: 14
            width: parent.width - 28
            height: implicitHeight
            backend: window.backend
            page: modelData.page
            search: modelData.page === "search" ? "US intl" : ""
          }
        }
      }
    }
    Text {
      x: 32; anchors.bottom: parent.bottom; anchors.bottomMargin: 26
      text: "Native Omarchy UI · Up to four layouts · Changes apply immediately"
      font.family: Style.font.family
      font.pixelSize: 13
      color: Color.popups.text
    }
  }
}
