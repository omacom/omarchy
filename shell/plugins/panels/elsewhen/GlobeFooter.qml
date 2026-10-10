import QtQuick
import qs.Commons
import qs.Commons as Commons

// The selected city under the globe: name, local time and badge, then its
// zone and offset. Blank without a selection; the parent reserves the height.
Item {
  id: root

  property var city: null               // [name, zone, lat, lon, rank]
  property bool daylight: false
  property string clock: ""
  property string offsetLabel: ""
  property string badge: ""             // "home", "tracked" or ""
  property real moonPhase: 0.5
  property color foreground: Commons.Color.foreground
  property color dim: Qt.darker(foreground, 1.55)
  property color fainter: Qt.darker(foreground, 2.1)
  property color daylightMarker
  property string fontFamily: Style.font.family

  signal offsetClicked()

  readonly property bool has: city !== null && city !== undefined

  // The mark matches the ink height of the name's capital; a pixel less, since
  // a circle's antialiased edge reads a pixel wider than a glyph's.
  TextMetrics {
    id: capHeight
    font.family: root.fontFamily
    font.pixelSize: Style.font.caption
    font.weight: Font.DemiBold
    text: "M"
  }

  Column {
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.verticalCenter: parent.verticalCenter
    spacing: Style.space(1)
    visible: root.has

    Row {
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: Style.space(7)

      Row {
        anchors.verticalCenter: parent.verticalCenter
        spacing: Style.space(4)

        // A lit dot by day, tonight's moon by night, as on the rows' strips.
        // Placed on the name's baseline by y: anchors.baseline inside a Row loops.
        Rectangle {
          y: cityName.baselineOffset - height
          width: Math.max(6, Math.round(capHeight.tightBoundingRect.height) - 1)
          height: width
          radius: width / 2
          visible: root.has
          color: root.daylight ? root.daylightMarker : "transparent"

          MoonDot {
            anchors.fill: parent
            visible: !root.daylight
            phase: root.moonPhase
            color: root.foreground
          }
        }

        Text {
          id: cityName
          textFormat: Text.PlainText
          text: root.has ? root.city[0] : ""
          color: root.foreground
          font.family: root.fontFamily
          font.pixelSize: Style.font.caption
          font.weight: Font.DemiBold
        }
      }

      Text {
        anchors.verticalCenter: parent.verticalCenter
        textFormat: Text.PlainText
        text: root.clock
        visible: text !== ""
        color: root.dim
        font.family: root.fontFamily
        font.pixelSize: Style.font.caption
      }

      Text {
        anchors.verticalCenter: parent.verticalCenter
        textFormat: Text.PlainText
        text: root.badge
        visible: root.has && text !== ""
        color: Commons.Color.accent
        font.family: root.fontFamily
        font.pixelSize: Style.font.caption
      }
    }

    // Zone and offset together are the toggle, so it survives a blank offset.
    Row {
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: Style.space(6)

      Text {
        textFormat: Text.PlainText
        text: root.has ? root.city[1] : ""
        color: offsetHover.hovered ? root.dim : root.fainter
        font.family: root.fontFamily
        font.pixelSize: Style.font.caption
      }

      Text {
        textFormat: Text.PlainText
        text: root.offsetLabel
        visible: text !== ""
        color: offsetHover.hovered ? root.foreground : root.dim
        font.family: root.fontFamily
        font.pixelSize: Style.font.caption
      }

      HoverHandler {
        id: offsetHover
        cursorShape: Qt.PointingHandCursor
      }
      TapHandler { onTapped: root.offsetClicked() }
    }
  }
}
