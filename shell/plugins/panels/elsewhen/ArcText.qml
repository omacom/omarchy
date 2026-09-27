import QtQuick
import qs.Commons
import "Arc.js" as Arc

// One line of text bent onto a shallow arc, each character turned to follow
// it.
//
// Not a Canvas: the panel's text is real Text items everywhere else, and a
// canvas would render this one line through a different path - its own font
// string, its own hinting, its own idea of the pixel grid - so it would sit
// visibly apart from the title above it at the same size. A character per
// Text item costs a handful of items on a line of thirty and keeps the
// rendering identical to its neighbours.
//
// Styling arrives as `runs` - {text, color, underline} - rather than as
// markup, because there is no per-character position inside a StyledText to
// place a glyph from. The flat version of the same line builds its markup
// from the same runs, so the two cannot drift apart.
//
// There is no eliding. The sentence is short, the panel's width is fixed, and
// an elide on an arc would have to decide what a truncated curve looks like;
// if the text ever outgrows the panel, the flat line is the one that handles
// it.
Item {
  id: root

  // [{ text: string, color: string ("" inherits), underline: bool }]
  property var runs: []

  // How far the ends sit off the middle. Small: this is meant to be noticed
  // as a shape, not read as a curve.
  property real rise: 6
  // Ends up (a shallow smile) or ends down (an arch over what is below it).
  property bool smile: true

  property string fontFamily: Style.font.family
  property int pixelSize: Style.font.caption
  property int weight: Font.Normal
  property color color: Color.foreground

  FontMetrics {
    id: metrics
    font.family: root.fontFamily
    font.pixelSize: root.pixelSize
    font.weight: root.weight
  }

  // Runs flattened to characters, each carrying the run's styling with it.
  readonly property var glyphs: {
    var out = []
    for (var i = 0; i < runs.length; i++) {
      var run = runs[i]
      var text = String(run && run.text !== undefined ? run.text : "")
      for (var j = 0; j < text.length; j++)
        out.push({ ch: text.charAt(j),
                   color: run.color !== undefined ? String(run.color) : "",
                   underline: run.underline === true })
    }
    return out
  }

  readonly property var placed: {
    // FontMetrics does not announce itself as a dependency of advanceWidth,
    // so name the font here or a theme or size change leaves the old layout
    // in place under new glyphs.
    var _ = metrics.font.family + metrics.font.pixelSize + metrics.font.weight
    var widths = []
    for (var i = 0; i < glyphs.length; i++) widths.push(metrics.advanceWidth(glyphs[i].ch))
    return Arc.layout(widths, rise, smile)
  }

  // Turning a box about its centre pushes its corners out by up to half its
  // diagonal, and the end characters are the most turned; half a line height
  // either side covers it at any rise this is used at.
  readonly property real slack: Math.round(metrics.height / 2)

  implicitWidth: Math.ceil(placed.width) + 2 * slack
  implicitHeight: Math.ceil(placed.height + metrics.height)

  // The arc is centred on whatever width it is given, so it stays centred in
  // a panel that is wider than the sentence.
  readonly property real originX: (width - placed.width) / 2

  Repeater {
    model: root.glyphs.length

    Text {
      required property int index
      // The model is a count, and the count changes a beat before the arrays
      // behind it do - every second, as the clock ticks the sentence's length
      // around. Without a fallback that beat is a torrent of TypeErrors from
      // delegates reaching past the end of the old layout.
      readonly property var glyph:
        root.glyphs[index] || { ch: "", color: "", underline: false }
      readonly property var spot:
        root.placed.chars[index] || { x: 0, y: 0, rotation: 0 }

      // The box is exactly one advance wide, so the arc's arithmetic and the
      // glyph agree about where the character's middle is; left-aligned text
      // in a wider box would drift off the curve.
      width: metrics.advanceWidth(glyph.ch)
      height: metrics.height
      horizontalAlignment: Text.AlignHCenter
      verticalAlignment: Text.AlignVCenter

      x: root.originX + spot.x
      y: spot.y
      rotation: spot.rotation
      transformOrigin: Item.Center

      textFormat: Text.PlainText
      text: glyph.ch
      color: glyph.color !== "" ? glyph.color : root.color
      font.family: root.fontFamily
      font.pixelSize: root.pixelSize
      font.weight: root.weight
      // Per character, so the rule follows the curve in short segments that
      // meet at the character boundaries rather than cutting the chord.
      font.underline: glyph.underline
      renderType: Text.QtRendering  // native rendering ignores the rotation
    }
  }
}
