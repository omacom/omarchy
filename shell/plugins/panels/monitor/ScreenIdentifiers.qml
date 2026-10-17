import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Ui
import qs.Commons
import qs.Commons as Commons

Item {
  id: root
  property bool shown: false
  property var screens: Quickshell.screens
  property var monitors: []

  Variants {
    model: root.shown ? root.screens : []
    delegate: PanelWindow {
      required property var modelData
      readonly property var displayInfo: root.monitors.filter(function(s) { return s.name === modelData.name })[0]
      screen: modelData
      visible: true
      implicitWidth: Math.min(Style.space(320), modelData.width)
      implicitHeight: Style.space(140)
      color: "transparent"
      exclusionMode: ExclusionMode.Ignore
      WlrLayershell.namespace: "omarchy-monitor-identify"
      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
      // Labels never intercept input or move focus away from the Display panel.
      mask: Region {}

      BorderSurface {
        anchors.fill: parent
        color: Commons.Color.popups.background
        borderSpec: Border.surfaceSpec("popups", "border", Commons.Color.accent, Math.max(1, Style.space(2)))
        radius: Style.cornerRadius

        Column {
          anchors.centerIn: parent
          width: Math.max(0, parent.width - Style.space(24))
          spacing: Style.space(8)
          Text {
            width: parent.width
            textFormat: Text.PlainText
            text: displayInfo ? (/^(eDP|LVDS|DSI)/.test(modelData.name) ? Commons.I18n.t("monitor.arrangementBuiltin", "Built-in display") : displayInfo.label) : Commons.I18n.t("monitor.identifyDisplay", "DISPLAY")
            color: Commons.Color.popups.text
            font.family: Style.font.family
            font.pixelSize: Style.font.caption
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
          }
          Text {
            width: parent.width
            textFormat: Text.PlainText
            text: displayInfo ? Commons.I18n.formatNumber(displayInfo.number) : modelData.name
            color: Commons.Color.popups.text
            font.family: Style.font.family
            font.pixelSize: Style.font.displayLarge
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
          }
          Text {
            width: parent.width
            textFormat: Text.PlainText
            text: modelData.name
            color: Commons.Color.popups.text
            font.family: Style.font.family
            font.pixelSize: Style.font.caption
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
          }
        }
      }
    }
  }
}
