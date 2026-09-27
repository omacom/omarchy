import QtQuick
import qs.Commons
import qs.Ui
import "DeepTime.js" as Deep

// One more row, whose city is the planet.
//
// The list is a column of places each answering "what time is it there". This
// row answers it for the Earth: its day is the whole 4.54 billion years, so
// its clock stands a minute short of midnight and its strip is banded by eon
// rather than by daylight. Everything else about it is deliberately the same
// as a city - the same padding, the same type, the same strip, the same
// marker - because the joke only works if it arrives looking like a row and
// only turns out to be the planet on the second read.
//
// It is built as its own file rather than as another entry in the list model:
// the model is cities, with a `date` probe, a drag handle, a remove button,
// weather and a currency behind each one, and none of that means anything
// here. Sharing the delegate would have meant a special case in every one of
// those, which is more code than this file and worse code than this file.
//
// Nothing on it moves. The minute hand last changed 3.15 million years ago
// and will not change again for another 3.15 million; a row that cannot tick
// is a strange thing to put in a clock, which is the entire reason it is
// worth putting in a clock.
Rectangle {
  id: earth

  property string fontFamily: Style.font.family
  property color foreground: Color.foreground
  property color dim: Color.foreground
  property color fainter: Color.foreground
  // The resting and hovered surfaces, passed in so this row picks up the same
  // mix against the panel's background as its neighbours rather than
  // recomputing it from a different base.
  property color fill: "transparent"
  property color fillHover: "transparent"
  property bool hour24: false
  // The top of the name's cap, so the text sits on the same line as the rows
  // above it rather than a pixel or two lower.
  property real capGap: 0
  property real moonPhase: 0.5

  readonly property var face: Deep.clockAt(0)
  readonly property var here: Deep.breadcrumb(0)

  readonly property string timeText: {
    var h = hour24 ? face.hour : ((face.hour % 12 === 0) ? 12 : face.hour % 12)
    var m = face.minute
    return h + ":" + (m < 10 ? "0" : "") + m
  }
  readonly property string meridiem: hour24 ? "" : (face.hour >= 12 ? "PM" : "AM")

  // Where we are in the Earth's own calendar, which is what the date line on
  // a city row is. The full chain runs Phanerozoic > Cenozoic > Quaternary >
  // Holocene > Meghalayan and does not come close to fitting, so it is cut to
  // the two divisions that are actually about us: the epoch since the ice,
  // and the age since the drought that ended several civilisations at once.
  readonly property string epochText: here.slice(-2).join("  ·  ")

  // The key to reading the row at all, and the reason it is worth a hover:
  // one minute of this clock is the entire genus Homo.
  readonly property string scaleText: "one minute = 3.15 Myr"

  readonly property int pad: Style.space(15)
  readonly property int stripGap: Style.space(9)


  implicitHeight: (pad - capGap) + labels.implicitHeight + stripGap + strip.height + pad
  radius: Style.cornerRadius
  color: hover.hovered ? fillHover : fill
  border.width: 0

  HoverHandler { id: hover }

  Column {
    id: labels
    anchors.left: parent.left
    anchors.leftMargin: Style.space(12)
    anchors.right: timeBlock.left
    anchors.rightMargin: Style.space(10)
    anchors.top: parent.top
    anchors.topMargin: earth.pad - earth.capGap
    spacing: Style.space(2)

    Row {
      spacing: Style.space(7)

      Text {
        id: earthName
        text: "Earth"
        color: earth.foreground
        font.family: earth.fontFamily
        font.pixelSize: Style.font.subtitle
        font.weight: Font.DemiBold
      }

      // Where a city carries its temperature: the one number about this place
      // that matters, in the same slot as the one number about theirs.
      Text {
        anchors.baseline: earthName.baseline
        text: "4.54 Ga"
        color: earth.dim
        font.family: earth.fontFamily
        font.pixelSize: Style.font.caption
      }
    }

    // The epoch line, and the scale it is drawn at, stacked in one slot the
    // way the city rows stack their date and their greeting.
    Item {
      width: parent.width
      implicitHeight: epochLine.implicitHeight

      Text {
        id: epochLine
        textFormat: Text.PlainText
        text: earth.epochText
        opacity: hover.hovered ? 0 : 1
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: 110 } }
        color: earth.dim
        font.family: earth.fontFamily
        font.pixelSize: Style.font.caption
      }

      Text {
        textFormat: Text.PlainText
        text: earth.scaleText
        opacity: hover.hovered ? 1 : 0
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: 110 } }
        color: earth.foreground
        font.family: earth.fontFamily
        font.pixelSize: Style.font.caption
      }
    }
  }

  Column {
    id: timeBlock
    anchors.right: parent.right
    anchors.rightMargin: Style.space(12)
    anchors.verticalCenter: labels.verticalCenter
    spacing: Style.space(1)

    Row {
      anchors.right: parent.right
      spacing: Style.space(3)

      Text {
        id: bigTime
        textFormat: Text.PlainText
        text: earth.timeText
        color: earth.foreground
        font.family: earth.fontFamily
        font.pixelSize: Style.font.heading
        font.weight: Font.DemiBold
      }

      Text {
        anchors.baseline: bigTime.baseline
        textFormat: Text.PlainText
        text: earth.meridiem
        visible: text !== ""
        color: earth.dim
        font.family: earth.fontFamily
        font.pixelSize: Style.font.caption
      }
    }

    // Where a city puts its zone abbreviation and offset, this puts the scale
    // that makes the time above it mean anything. It is the row's legend, and
    // it belongs in the slot that is already the legend on every other row.
    Text {
      anchors.right: parent.right
      text: "24h = 4.54 Ga"
      color: earth.fainter
      font.family: earth.fontFamily
      font.pixelSize: Style.font.caption
    }
  }

  // ---- The strip: the same 24 hours as every other row, banded by eon
  // instead of by daylight. It brightens toward the present, so the deep past
  // falls away into the dark rather than being colour-coded at the reader -
  // and the four eons are, by luck, all wide enough to see: the shortest of
  // them, the Phanerozoic, is still an eighth of the day.
  Rectangle {
    id: strip
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    anchors.leftMargin: Style.space(12)
    anchors.rightMargin: Style.space(12)
    anchors.bottomMargin: earth.pad
    height: Math.max(2, Style.space(3))
    radius: height / 2
    color: Qt.rgba(earth.foreground.r, earth.foreground.g, earth.foreground.b, 0.10)

    Repeater {
      model: Deep.bands()

      Rectangle {
        required property var modelData
        required property int index

        x: Math.round(strip.width * modelData.x0)
        // A pixel of overlap, so the seams between bands do not show as
        // hairlines of the darker strip underneath them.
        width: Math.round(strip.width * (modelData.x1 - modelData.x0)) + (index < 3 ? 1 : 0)
        height: strip.height
        radius: strip.radius
        color: Qt.rgba(earth.foreground.r, earth.foreground.g, earth.foreground.b,
                       [0.05, 0.11, 0.19, 0.32][index])
      }
    }

    // Now, in the same marker the city rows use - and by their own rule it is
    // the moon, because the Earth's clock says a minute to midnight. It hangs
    // half off the end of the strip, which is exactly where we are.
    Rectangle {
      id: nowMarker
      width: Math.max(8, Style.space(10))
      height: width
      radius: width / 2
      x: Math.round(strip.width - width / 2)
      y: (strip.height - height) / 2
      color: "transparent"

      MoonDot {
        anchors.fill: parent
        phase: earth.moonPhase
        color: earth.foreground
      }
    }
  }
}
