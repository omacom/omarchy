import QtQuick
import QtQuick.Shapes
import qs.Commons
import qs.Commons as Commons

Item {
  id: whorl
  implicitWidth: Style.space(264)
  implicitHeight: implicitWidth
  property color tone: Commons.Color.accent

  // The print as five ridges on a 24-unit grid, core first, each one the
  // centre line of a ridge of the Material Design fingerprint icon (Apache
  // 2.0), drawn one unit wide, with its length in those units.
  readonly property var ridges: [
    { length: 8.82, path: "M11.94 14.66C11.94 16.25 12.75 17.7 14.1 18.63C14.9 19.17 15.85 19.44 16.92 19.44C17.2 19.44 17.6 19.4 18.05 19.33" },
    { length: 23.25, path: "M9.75 21.29C8.9 20.4 8.45 19.9 7.83 18.8C7.2 17.65 6.84 16.2 6.84 14.66C6.84 11.96 9.15 9.77 12 9.77C14.85 9.77 17.16 11.96 17.16 14.66" },
    { length: 52.72, path: "M14.91 21.5C13.4 21.08 12.4 20.5 11.4 19.5C10.1 18.2 9.39 16.5 9.39 14.66C9.39 13.3 10.55 12.22 11.97 12.22C13.39 12.22 14.55 13.3 14.55 14.66C14.55 16 15.7 17.1 17.13 17.1C18.56 17.1 19.71 16 19.71 14.66C19.71 10.6 16.25 7.33 12 7.33C8.95 7.33 6.2 9.03 4.94 11.65C4.5 12.55 4.3 13.55 4.3 14.66C4.3 15.5 4.4 16.8 5 18.4" },
    { length: 19.81, path: "M3.5 9.22C4.45 7.9 5.65 6.85 7.07 6.1C10.1 4.55 14 4.55 17 6.1C18.4 6.85 19.6 7.9 20.5 9.22" },
    { length: 12.11, path: "M6.2 3.97C7.9 3 9.9 2.5 12.01 2.5C14.1 2.5 15.9 2.95 17.81 3.97" }
  ]
  readonly property real ridgeTotal: {
    var total = 0
    for (var i = 0; i < ridges.length; i++) total += ridges[i].length
    return total
  }
  // How much of the print is lit, 0 to 1, drawn along the ridges from the
  // core outward. Every accepted touch lights the same length of ridge,
  // however many touches this reader asks for.
  property real filled: 0

  Behavior on filled {
    NumberAnimation { duration: Style.duration(280); easing.type: Easing.OutCubic }
  }

  Repeater {
    model: whorl.ridges

    Shape {
      id: ridge
      required property var modelData
      required property int index
      // The length of ridge before this one, and how much of this one is lit.
      readonly property real before: {
        var sum = 0
        for (var i = 0; i < index; i++) sum += whorl.ridges[i].length
        return sum
      }
      readonly property real lit: Math.max(0, Math.min(modelData.length, whorl.filled * whorl.ridgeTotal - before))

      // Drawn on the 24-unit grid and scaled up, stroke and all.
      width: 24
      height: 24
      transform: Scale { xScale: whorl.width / 24; yScale: whorl.height / 24 }
      preferredRendererType: Shape.CurveRenderer

      ShapePath {
        strokeWidth: 1
        strokeColor: Qt.rgba(1, 1, 1, 0.3)
        fillColor: "transparent"
        capStyle: ShapePath.RoundCap
        PathSvg { path: ridge.modelData.path }
      }
      // The lit length, as the first dash of a pattern whose gap outruns
      // the ridge. Dashes are measured in stroke widths, here one unit.
      ShapePath {
        strokeWidth: 1
        strokeColor: ridge.lit > 0.01 ? whorl.tone : "transparent"
        fillColor: "transparent"
        capStyle: ShapePath.RoundCap
        strokeStyle: ShapePath.DashLine
        dashPattern: [Math.max(0.01, ridge.lit), 1000]
        PathSvg { path: ridge.modelData.path }
      }
    }
  }
}
