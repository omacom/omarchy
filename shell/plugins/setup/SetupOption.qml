import QtQuick
import qs.Commons
import qs.Commons as Commons
import qs.Ui

// One thing to pick on a page: a row of the menu, drawn as a card.
BorderSurface {
  id: root

  property string label: ""
  property string icon: ""
  property string iconFont: ""
  // A few options get tall cards with the icon above the label.
  property bool large: false
  // What a small card sets its label in, which the page decides for all of
  // its cards together.
  property real labelSize: Style.font.body
  // Under the pointer or the keyboard cursor.
  property bool cursor: false
  // Picked in the tour, to be set up when it finishes.
  property bool chosen: false
  // What the machine has now.
  property bool current: false
  // Already installed, so there is nothing to pick.
  property bool installed: false

  property color foreground: Commons.Color.menu.text
  property color accent: Commons.Color.accent

  signal clicked()
  // The pointer moved over it, in its own coordinates.
  signal pointed(var mouse)

  // The pick is drawn in the text color: an accent quieter than the text
  // would make the chosen card the faintest one on the page.
  readonly property color ink: foreground
  readonly property string glyphFont: iconFont !== "" ? iconFont : Style.font.menuFamily

  implicitHeight: large ? Style.space(78) : Style.space(32)
  radius: Style.cornerRadius
  opacity: installed ? 0.5 : 1
  color: chosen ? Util.alpha(foreground, cursor ? 0.16 : 0.11)
    : cursor ? Style.hoverFillFor(foreground, accent)
    : Style.normalFillFor(foreground, accent)
  borderSpec: chosen ? Border.flat(foreground, Math.max(1, Style.space(2)))
    : Border.flat(Util.alpha(foreground, cursor ? 0.4 : 0.16), Style.spacing.hairline)

  Behavior on color { ColorAnimation { duration: Style.duration(120) } }

  // Held down, it gives a little, as a Button does.
  scale: pointer.pressed && !installed ? 0.97 : 1
  Behavior on scale {
    NumberAnimation {
      duration: Style.duration(160)
      easing.type: Easing.Bezier
      easing.bezierCurve: Style.easeOut
    }
  }

  // Where the cursor is: the ring the card's buttons wear, so the keyboard's
  // place and the tour's pick are never mistaken for each other.
  Rectangle {
    visible: root.cursor
    anchors.fill: parent
    anchors.margins: -Style.space(3)
    radius: root.radius > 0 ? root.radius + Style.space(3) : 0
    color: "transparent"
    border.width: Style.spacing.hairline
    border.color: Util.alpha(root.foreground, 0.7)
  }

  // The check the menu gives the current choice, and software already here.
  Text {
    id: mark
    visible: root.current || root.installed
    textFormat: Text.PlainText
    text: "\uf00c"
    color: root.ink
    opacity: 0.8
    font.family: Style.font.menuFamily
    font.pixelSize: Style.font.bodySmall
    anchors.right: parent.right
    anchors.rightMargin: Style.space(9)
    anchors.top: root.large ? parent.top : undefined
    anchors.topMargin: Style.space(8)
    anchors.verticalCenter: root.large ? undefined : parent.verticalCenter
  }

  Row {
    visible: !root.large
    anchors.left: parent.left
    anchors.leftMargin: Style.space(10)
    anchors.right: mark.visible ? mark.left : parent.right
    anchors.rightMargin: Style.space(8)
    anchors.verticalCenter: parent.verticalCenter
    spacing: Style.space(8)

    Text {
      id: glyph
      visible: root.icon !== ""
      textFormat: Text.PlainText
      text: root.icon
      color: root.ink
      font.family: root.glyphFont
      font.pixelSize: Style.font.icon
      horizontalAlignment: Text.AlignHCenter
      width: Style.space(18)
      anchors.verticalCenter: parent.verticalCenter
    }

    Text {
      textFormat: Text.PlainText
      text: root.label
      color: root.ink
      font.family: Style.font.menuFamily
      font.pixelSize: root.labelSize
      font.bold: root.chosen
      // A name too long even for the page's size gets a little smaller
      // before it gets cut short.
      fontSizeMode: Text.HorizontalFit
      minimumPixelSize: Math.round(Style.font.body * 0.8)
      elide: Text.ElideRight
      width: parent.width - (glyph.visible ? glyph.width + parent.spacing : 0)
      anchors.verticalCenter: parent.verticalCenter
    }
  }

  Column {
    visible: root.large
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.margins: Style.space(8)
    anchors.verticalCenter: parent.verticalCenter
    spacing: Style.space(7)

    Text {
      visible: root.icon !== ""
      textFormat: Text.PlainText
      text: root.icon
      color: root.ink
      font.family: root.glyphFont
      font.pixelSize: Style.font.display
      horizontalAlignment: Text.AlignHCenter
      width: parent.width
    }

    Text {
      textFormat: Text.PlainText
      text: root.label
      color: root.ink
      font.family: Style.font.menuFamily
      font.pixelSize: Style.font.body
      font.bold: root.chosen
      elide: Text.ElideRight
      horizontalAlignment: Text.AlignHCenter
      width: parent.width
    }
  }

  MouseArea {
    id: pointer
    anchors.fill: parent
    // Undoes the press scale, so a press near the edge still counts.
    scale: 1 / root.scale
    hoverEnabled: true
    cursorShape: root.installed ? Qt.ArrowCursor : Qt.PointingHandCursor
    onPositionChanged: function(mouse) { root.pointed(mouse) }
    onClicked: if (!root.installed) root.clicked()
  }
}
