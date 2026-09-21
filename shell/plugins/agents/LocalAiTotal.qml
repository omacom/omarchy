import QtQuick
import qs.Commons
import qs.Ui
import "LocalAi.js" as Ui

// Same geometry, type and proportional fill as Agents' native ModelRow.
Item {
  id: root
  required property var r
  required property var p
  readonly property var usage: r.history || ({total:0, since:""})
  implicitHeight: name.implicitHeight + Style.spacing.lg
  Accessible.role: Accessible.StaticText
  Accessible.name: r.label + ", " + total.text + " generated tokens in available history"
  Rectangle { anchors.fill: parent; radius: Style.cornerRadius; color: Util.alpha(p.ink, 0.05) }
  Rectangle {
    anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
    width: parent.width * Math.max(0, Math.min(1, r.share || 0))
    radius: Style.cornerRadius; color: Util.alpha(p.ink, 0.14)
    Behavior on width { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
  }
  Text {
    textFormat: Text.PlainText
    id: name
    anchors { left: parent.left; leftMargin: Style.space(8); right: total.left; rightMargin: Style.space(8); verticalCenter: parent.verticalCenter }
    text: r.label; color: r.urgent ? p.urgent : p.ink
    font.family: p.mono; font.pixelSize: Style.font.bodySmall; elide: Text.ElideRight
  }
  Text {
    textFormat: Text.PlainText
    id: total
    anchors { right: parent.right; rightMargin: Style.space(8); verticalCenter: parent.verticalCenter }
    text: root.usage.since ? (root.usage.estimated ? "≈" : "") + Ui.kmg(Math.round(root.usage.total)) : "—"
    color: p.dim; font.family: p.mono; font.pixelSize: Style.font.bodySmall; font.bold: true
  }
  MouseArea {
    id: hover
    anchors.fill: parent; hoverEnabled: true; acceptedButtons: Qt.NoButton
  }
  PanelToolTip {
    visible: hover.containsMouse
    text: (root.usage.since ? Math.round(root.usage.total).toLocaleString() + " generated tokens · " + Ui.kmg(Math.round(root.usage.today || 0)) + " today" + (root.usage.estimated ? " (estimated)" : "") : "Usage unavailable")
    fontFamily: p.mono
  }
}
