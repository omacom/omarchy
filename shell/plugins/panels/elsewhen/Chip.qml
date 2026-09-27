import QtQuick
import qs.Commons

// A small dark label that floats over the row: sunrise, sunset, the moon's
// phase. Always an answer to something just clicked, never part of the resting
// state of the panel.
//
// Its two colours are literal rather than theme roles. This is a tooltip, and
// tooltips are inverted everywhere - a dark chip with light text is the same
// shape in a light theme as in a dark one, while the theme's own foreground
// would put dark text on a dark chip half the time.
//
// It is opaque on purpose. It sits over the date line and the offset, and text
// over text is unreadable whatever the two colours are.
Rectangle {
  id: chip

  property string label: ""
  property string fontFamily: Style.font.family
  property bool shown: false

  // Where the chip wants to be centred, in the parent's coordinates. Held
  // inside the parent by the binding below: a sunrise a few minutes after
  // midnight would otherwise hang its chip off the left edge of the row.
  property real centreX: 0

  width: chipText.implicitWidth + Style.space(10)
  height: chipText.implicitHeight + Style.space(5)
  radius: Style.space(3)
  color: "#0B0D11"

  x: Math.round(Math.max(0, Math.min(parent.width - width, centreX - width / 2)))

  opacity: shown ? 1 : 0
  visible: opacity > 0
  Behavior on opacity { NumberAnimation { duration: 120 } }

  Text {
    id: chipText
    anchors.centerIn: parent
    textFormat: Text.PlainText
    text: chip.label
    color: "#EDE7DA"
    font.family: chip.fontFamily
    font.pixelSize: Style.font.caption
  }
}
