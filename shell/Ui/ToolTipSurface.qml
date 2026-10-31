import QtQuick
import "../Commons"
import "../Commons" as Commons

// Shared by Qt Controls tooltips and the bar's separate Wayland popup.
BorderSurface {
  id: root
  property string text: ""
  property color foreground: Commons.Color.tooltip.text
  property string fontFamily: Style.font.family
  property real fontSize: Style.font.bodySmall
  property real maximumWidth: Style.space(360)

  color: Commons.Color.tooltip.background
  property var themeBorderSpec: Border.surfaceSpec("tooltip", "border", Commons.Color.tooltip.border, Style.normalBorderWidth)
  borderSpec: ToolTipStyle.borderSpec(themeBorderSpec)
  radius: ToolTipStyle.radius(Style.cornerRadius)
  leftPadding: Style.spacing.controlPaddingX
  rightPadding: Style.spacing.controlPaddingX
  topPadding: Style.spacing.controlPaddingY
  bottomPadding: Style.spacing.controlPaddingY
  implicitWidth: Math.min(maximumWidth, label.implicitWidth + contentLeftInset + contentRightInset)
  implicitHeight: label.implicitHeight + contentTopInset + contentBottomInset

  Text {
    id: label
    x: root.contentLeftInset
    y: root.contentTopInset
    width: Math.max(1, root.width - root.contentLeftInset - root.contentRightInset)
    textFormat: Text.PlainText
    text: root.text
    color: root.foreground
    font.family: root.fontFamily
    font.pixelSize: root.fontSize
    wrapMode: Text.Wrap
  }
}
