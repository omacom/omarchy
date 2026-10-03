import QtQuick
import QtQuick.Controls
import qs.Commons

// Styled wrapper around Qt Quick Controls ToolTip. Drop-in: declare inside
// the hovered item and bind `visible` to the hover state, e.g.
//   PanelToolTip {
//     visible: mouse.containsMouse
//     text: "Forget network"
//   }
//
// Defaults pull from [tooltip] in shell.toml via Color.tooltip.*. Override
// the panel* properties per-instance only when you need a tooltip that
// intentionally diverges from the theme.
//
// Property names are prefixed `panel*` to avoid clashing with ToolTip's
// built-in `background`/`font` properties.
ToolTip {
  id: root

  property color panelForeground: Color.tooltip.text
  property color panelBackground: Color.tooltip.background
  property color panelBorder: Color.tooltip.border
  property string fontFamily: Style.font.family
  property real fontSize: Style.font.bodySmall

  readonly property var panelBorderSpec: Border.localOrSurfaceSpec("tooltip", "border", panelBorder, Color.tooltip.border, Style.normalBorderWidth)

  // A tooltip is a glance, and an unbounded one stops being readable well
  // before it stops growing. `text` was laid out on a single line at whatever
  // width it asked for, so a long string grew past the panel it belongs to.
  // Bar widget tooltips are drawn by Bar.qml, not here.
  //
  // Capping the control rather than the Text is what makes this safe: the
  // control's implicitWidth still derives from the unwrapped text, so
  // Math.min() reads a value that does not depend on the width it sets, and
  // there is no binding loop. Anything shorter than the cap is untouched.
  property real maximumWidth: Style.space(320)

  delay: 400
  padding: 0
  width: Math.min(implicitWidth, maximumWidth)
  // The style centres on implicitWidth, which stays unwrapped; centre on the capped width.
  x: parent ? Math.round((parent.width - width) / 2) : 0

  background: BorderSurface {
    color: root.panelBackground
    borderSpec: root.panelBorderSpec
    radius: Style.cornerRadius
  }

  contentItem: Text {
    textFormat: Text.PlainText
    text: root.text
    color: root.panelForeground
    font.family: root.fontFamily
    font.pixelSize: root.fontSize
    // The control hands this its width; wrapping is what turns that cap into
    // more lines instead of clipped text.
    wrapMode: Text.Wrap
    leftPadding: Border.left(root.panelBorderSpec) + Style.spacing.controlPaddingX
    rightPadding: Border.right(root.panelBorderSpec) + Style.spacing.controlPaddingX
    topPadding: Border.top(root.panelBorderSpec) + Style.spacing.controlPaddingY
    bottomPadding: Border.bottom(root.panelBorderSpec) + Style.spacing.controlPaddingY
  }
}
