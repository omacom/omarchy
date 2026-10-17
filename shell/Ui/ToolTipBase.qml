import QtQuick
import QtQuick.Window
import QtQuick.Templates as T
import "../Commons"
import "../Commons" as Commons

// Also backs the shell-wide Controls style without importing Controls again.
T.ToolTip {
  id: root
  property color panelForeground: Commons.Color.tooltip.text
  property color panelBackground: Commons.Color.tooltip.background
  property color panelBorder: Commons.Color.tooltip.border
  property string fontFamily: Style.font.family
  property real fontSize: Style.font.bodySmall
  property real maximumWidth: Style.space(360)
  readonly property var panelBorderSpec: Border.localOrSurfaceSpec("tooltip", "border", panelBorder, Commons.Color.tooltip.border, Style.normalBorderWidth)

  x: parent ? Math.round((parent.width - width) / 2) : 0
  y: -height - margins
  margins: Style.spacing.sm
  padding: 0
  delay: 400
  timeout: -1
  focus: false
  closePolicy: T.Popup.CloseOnEscape | T.Popup.CloseOnPressOutsideParent
  implicitWidth: Math.min(implicitContentWidth, parent && parent.Window.window ? Math.max(1, parent.Window.window.width - margins * 2) : maximumWidth)
  implicitHeight: implicitContentHeight

  contentItem: ToolTipSurface {
    text: root.text
    foreground: root.panelForeground
    color: root.panelBackground
    themeBorderSpec: root.panelBorderSpec
    fontFamily: root.fontFamily
    fontSize: root.fontSize
    maximumWidth: root.maximumWidth
  }
  enter: Transition {
    NumberAnimation { property: "opacity"; from: 0; to: 1; duration: Style.duration(120) }
  }
  exit: Transition {
    NumberAnimation { property: "opacity"; from: 1; to: 0; duration: Style.duration(80) }
  }
}
