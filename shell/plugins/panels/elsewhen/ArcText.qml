import QtQuick
import qs.Commons
import qs.Commons as Commons
import "Arc.js" as Arc

// One line of text arched over what sits below it, each character turned to
// follow the curve. A Text per character keeps rendering identical to the
// neighbouring Text items, which a Canvas would not. No eliding.
Item {
  id: root

  property string text: ""
  // How far the ends drop below the middle.
  property real rise: 6
  property string fontFamily: Style.font.family
  property int pixelSize: Style.font.caption
  property color color: Commons.Color.foreground

  FontMetrics {
    id: metrics
    font.family: root.fontFamily
    font.pixelSize: root.pixelSize
  }

  // Right-to-left scripts and scripts whose letters join or stack (Arabic,
  // Hebrew, Indic, Thai, combining accents) cannot be set one code unit at a
  // time: they would come apart or run backwards. Those lines are set flat,
  // as one Text that shapes and orders them properly.
  readonly property bool flat: /[\u0300-\u036F\u0590-\u08FF\u0900-\u0DFF\u0E00-\u0EFF\u1000-\u109F\u1780-\u17FF\uFB1D-\uFDFF\uFE70-\uFEFF\uD800-\uDFFF]/.test(text)

  readonly property var glyphs: flat ? [] : text.split("")

  readonly property var placed: {
    // advanceWidth does not register the font as a dependency.
    var _ = metrics.font.family + metrics.font.pixelSize
    var widths = []
    for (var i = 0; i < glyphs.length; i++) widths.push(metrics.advanceWidth(glyphs[i]))
    return Arc.layout(widths, rise, false)
  }

  // Room for the end characters' corners once they are turned.
  readonly property real slack: Math.round(metrics.height / 2)

  implicitWidth: flat ? Math.ceil(flatText.implicitWidth) + 2 * slack : Math.ceil(placed.width) + 2 * slack
  implicitHeight: flat ? Math.ceil(flatText.implicitHeight) : Math.ceil(placed.height + metrics.height)

  readonly property real originX: (width - placed.width) / 2

  Text {
    id: flatText
    visible: root.flat
    anchors.horizontalCenter: parent.horizontalCenter
    textFormat: Text.PlainText
    text: root.flat ? root.text : ""
    color: root.color
    font.family: root.fontFamily
    font.pixelSize: root.pixelSize
  }

  Repeater {
    model: root.glyphs.length

    Text {
      required property int index
      // The count changes a beat before the arrays behind it do.
      readonly property string glyph: root.glyphs[index] || ""
      readonly property var spot: root.placed.chars[index] || { x: 0, y: 0, rotation: 0 }

      // Exactly one advance wide, so the glyph's middle is where the arc put it.
      width: metrics.advanceWidth(glyph)
      height: metrics.height
      horizontalAlignment: Text.AlignHCenter
      verticalAlignment: Text.AlignVCenter

      x: root.originX + spot.x
      y: spot.y
      rotation: spot.rotation
      transformOrigin: Item.Center

      textFormat: Text.PlainText
      text: glyph
      color: root.color
      font.family: root.fontFamily
      font.pixelSize: root.pixelSize
      renderType: Text.QtRendering  // native rendering ignores the rotation
    }
  }
}
