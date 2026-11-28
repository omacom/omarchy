import QtQuick
import QtQuick.Shapes
import qs.Commons
import qs.Commons as Commons

// A miniature of the preview strip: one thin slanted slice per window, on
// the icon's inward side. Fixed delegates let closing windows fade away.
Item {
  id: indicator

  property var segments: []
  property real iconSize: 36
  property string position: "bottom"
  readonly property int count: segments.length
  readonly property bool previewing: segments.indexOf("previewed") >= 0
  readonly property real gap: Math.max(2, iconSize / 18)
  readonly property real length: Math.min(iconSize * 0.48,
    (iconSize * 0.9 - Math.max(0, count - 1) * gap) / Math.max(1, count))
  readonly property bool vertical: position === "left" || position === "right"
  property color tint: Commons.Color.accent
  property color backing: Commons.Color.background

  Behavior on tint { ColorAnimation { duration: Style.duration(250) } }
  Behavior on backing { ColorAnimation { duration: Style.duration(250) } }

  Item {
    id: line
    width: indicator.count * indicator.length + Math.max(0, indicator.count - 1) * indicator.gap
    height: Math.max(3, indicator.iconSize / 10)
    x: indicator.vertical
      ? (indicator.position === "left" ? indicator.width / 2 + indicator.iconSize * 0.65 : indicator.width / 2 - indicator.iconSize * 0.65) - width / 2
      : (indicator.width - width) / 2
    y: indicator.vertical ? (indicator.height - height) / 2
      : (indicator.position === "top" ? indicator.height / 2 + indicator.iconSize * 0.65 : indicator.height / 2 - indicator.iconSize * 0.65) - height / 2
    rotation: indicator.vertical ? 90 : 0

    Behavior on width { NumberAnimation { duration: Style.duration(160); easing.type: Easing.Bezier; easing.bezierCurve: Style.easeOut } }

    Repeater {
      model: 6
      delegate: Shape {
        id: segment
        required property int index
        readonly property string kind: indicator.segments[index] || "open"
        x: index * (indicator.length + indicator.gap)
        y: (line.height - height) / 2
        width: Math.max(2, indicator.length)
        // While browsing previews, only the matching window stands forward.
        height: line.height * (kind === "previewed" ? 1.4 : kind === "focused" && !indicator.previewing ? 1 : 0.65)
        opacity: index >= indicator.count ? 0 : kind === "previewed" ? 1
          : kind === "minimized" ? 0.3 : indicator.previewing ? 0.45 : kind === "focused" ? 1 : 0.7
        readonly property real skew: Math.min(width / 3, height * 0.6)
        preferredRendererType: Shape.CurveRenderer
        antialiasing: true

        Behavior on x { NumberAnimation { duration: Style.duration(160); easing.type: Easing.Bezier; easing.bezierCurve: Style.easeOut } }
        Behavior on width { NumberAnimation { duration: Style.duration(160); easing.type: Easing.Bezier; easing.bezierCurve: Style.easeOut } }
        Behavior on height { NumberAnimation { duration: Style.duration(160); easing.type: Easing.Bezier; easing.bezierCurve: Style.easeOut } }
        Behavior on opacity { NumberAnimation { duration: Style.duration(160); easing.type: Easing.OutCubic } }

        ShapePath {
          fillColor: indicator.tint
          strokeColor: Util.alpha(indicator.backing, 0.35)
          strokeWidth: 1
          startX: segment.skew; startY: 0
          PathLine { x: segment.width; y: 0 }
          PathLine { x: segment.width - segment.skew; y: segment.height }
          PathLine { x: 0; y: segment.height }
          PathLine { x: segment.skew; y: 0 }
        }
      }
    }
  }
}
