import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Commons as Commons
import qs.Ui
import "ActiveWindowModel.js" as ActiveWindowModel

BarWidget {
  id: root
  moduleName: "omarchy.active-window"

  readonly property var toplevel: ToplevelManager.activeToplevel

  readonly property var terminalEntries: {
    try {
      var apps = DesktopEntries && DesktopEntries.applications ? DesktopEntries.applications.values : []
      var values = apps || []
      var out = []
      for (var i = 0; i < values.length; i++) {
        var entry = values[i]
        if (entry && (entry.runInTerminal || String(entry.execString || "").indexOf("--app-id=") >= 0))
          out.push({ id: entry.id, execString: entry.execString, command: entry.command, runInTerminal: entry.runInTerminal })
      }
      return out
    } catch (e) {
      return []
    }
  }

  readonly property string rawAppId: toplevel ? String(toplevel.appId || "") : ""
  readonly property string rawTitle: toplevel ? String(toplevel.title || "") : ""

  readonly property string appName: toplevel ? ActiveWindowModel.resolveAppName(rawAppId, DesktopEntries, terminalEntries) : ""
  readonly property string mode: String(setting("mode", "appName"))
  readonly property string displayText: ActiveWindowModel.labelText(mode, appName, rawTitle)
  readonly property int maxLabelWidth: Number(setting("maxWidth", 280))
  readonly property bool bold: setting("bold", mode === "appName") !== false

  readonly property string tooltipText: {
    if (!toplevel) return ""
    if (rawTitle && appName && rawTitle.toLowerCase() !== appName.toLowerCase())
      return appName + " — " + rawTitle
    return rawTitle || appName
  }

  visible: displayText !== "" && !vertical
  implicitWidth: visible ? Math.min(maxLabelWidth, labelText.implicitWidth) + Style.spacing.controlPaddingX * 2 : 0
  implicitHeight: barSize

  Behavior on implicitWidth {
    NumberAnimation { duration: Style.duration(180); easing.type: Easing.OutCubic }
  }

  Item {
    anchors.fill: parent
    anchors.leftMargin: Style.space(8)
    anchors.rightMargin: Style.space(8)
    clip: true

    Text {
      id: labelText
      textFormat: Text.PlainText
      anchors.verticalCenter: parent.verticalCenter
      anchors.left: parent.left
      width: parent.width
      text: root.displayText
      color: root.bar ? root.bar.barForeground : Commons.Color.foreground
      font.family: root.bar ? root.bar.fontFamily : Style.font.family
      font.pixelSize: Style.font.body
      font.bold: root.bold
      elide: Text.ElideRight
      opacity: root.bold ? 1.0 : 0.85
    }
  }

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
    cursorShape: Qt.PointingHandCursor

    onClicked: function(mouse) {
      if (!root.toplevel) return
      if (mouse.button === Qt.MiddleButton || mouse.button === Qt.RightButton) {
        root.toplevel.close()
      } else {
        root.toplevel.activate()
      }
    }
    onEntered: if (root.bar && root.tooltipText) root.bar.showTooltip(root, root.tooltipText)
    onExited: if (root.bar) root.bar.hideTooltip(root)
  }
}
