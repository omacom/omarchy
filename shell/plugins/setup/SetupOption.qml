import QtQuick
import qs.Commons
import qs.Commons as Commons
import qs.Ui

// A self-explanatory choice card for Workspace Layout and Dictation. Carries
// its own visual mark (miniature layout pictogram or differentiated glyph),
// title, concise subtitle, a pinned "Current" pill for the saved setting, and
// a distinct selection mark for the staged pick.
BorderSurface {
  id: root

  property string label: ""
  property string detail: ""
  property string icon: ""
  property string iconFont: ""
  property string vendor: ""
  property string pictogram: ""
  // Compact layout used only if a user menu extension adds more than 4 choices.
  property bool compact: false
  // Pointer hover lights a card only after the pointer moves.
  property bool lights: false
  // Staged as the step's pick.
  property bool chosen: false
  // Keyboard focus rests on this step's choice controls.
  property bool focused: false
  // Visible focus anchor when no option is staged yet (unmatched saved setting).
  property bool focusedAnchor: false
  // Saved on this machine right now (stays pinned when another choice is staged).
  property bool current: false
  // Recommended hardware blueprint (e.g. omarchy-models `best: true`).
  property bool recommended: false

  property color foreground: Commons.Color.menu.text
  property color accent: Commons.Color.accent

  signal clicked()

  readonly property bool hovered: lights && pointer.containsMouse
  readonly property string glyphFont: iconFont !== "" ? iconFont : Style.font.menuFamily
  readonly property bool lightSurface: (0.2126 * Commons.Color.menu.background.r + 0.7152 * Commons.Color.menu.background.g + 0.0722 * Commons.Color.menu.background.b) >= 0.5
  readonly property var vendorCandidates: {
    if (!/^[a-z0-9-]+$/.test(vendor)) return []
    var list = []
    if (lightSurface) list.push(Qt.resolvedUrl("../agents/assets/" + vendor + "-light.svg"))
    list.push(Qt.resolvedUrl("../agents/assets/" + vendor + ".svg"))
    return list
  }
  property int vendorIdx: 0
  onVendorChanged: vendorIdx = 0
  onLightSurfaceChanged: vendorIdx = 0
  readonly property url vendorSource: vendorIdx < vendorCandidates.length ? vendorCandidates[vendorIdx] : ""

  // Uniform row height for tall cards so wrapped subtitles never misalign neighbors.
  implicitHeight: compact ? Style.space(52) : Style.space(138)
  radius: Style.cornerRadius
  color: chosen ? Util.alpha(foreground, hovered ? 0.14 : 0.1)
    : hovered ? Style.hoverFillFor(foreground, accent)
    : Style.normalFillFor(foreground, accent)
  borderSpec: chosen ? Border.flat(focused ? foreground : Util.alpha(foreground, 0.85), Math.max(1, Style.space(2)))
    : Border.flat(Util.alpha(foreground, focusedAnchor ? 0.52 : hovered ? 0.36 : 0.16), Style.spacing.hairline)

  Accessible.role: Accessible.RadioButton
  Accessible.name: root.label + (root.detail !== "" ? ", " + root.detail : "")
  Accessible.checked: root.chosen
  Accessible.onPressAction: root.clicked()
  Accessible.onToggleAction: root.clicked()

  Behavior on color { ColorAnimation { duration: Style.duration(120) } }

  // Subtle accent wash on the selected card so colorful themes pop without
  // losing legibility on monochrome themes.
  Rectangle {
    anchors.fill: parent
    anchors.margins: root.chosen ? Math.max(1, Style.space(2)) : Style.spacing.hairline
    radius: Math.max(0, root.radius - 1)
    color: Util.alpha(root.accent, root.chosen ? 0.06 : 0)
    Behavior on color { ColorAnimation { duration: Style.duration(140) } }
  }

  scale: pointer.pressed ? 0.975 : 1
  Behavior on scale {
    NumberAnimation {
      duration: Style.duration(160)
      easing.type: Easing.Bezier
      easing.bezierCurve: Style.easeOut
    }
  }

  // Pinned badge marking either what the machine currently uses or the
  // recommended blueprint for this hardware.
  Rectangle {
    id: currentBadge
    visible: (root.current || root.recommended) && !root.compact
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.topMargin: Style.space(9)
    anchors.leftMargin: Style.space(10)
    width: currentLabel.implicitWidth + Style.space(10)
    height: currentLabel.implicitHeight + Style.space(4)
    radius: Style.cornerRadius > 0 ? Math.min(Style.cornerRadius, height / 2) : 0
    color: root.current ? Util.alpha(root.foreground, 0.08) : Util.alpha(root.accent, 0.14)
    border.width: Style.spacing.hairline
    border.color: root.current ? Util.alpha(root.foreground, 0.18) : Util.alpha(root.accent, 0.48)

    Text {
      id: currentLabel
      textFormat: Text.PlainText
      text: root.current ? Commons.I18n.t("setup.current") : Commons.I18n.t("setup.recommended")
      color: root.current ? Util.alpha(root.foreground, 0.72) : root.accent
      font.family: Style.font.menuFamily
      font.pixelSize: Style.font.caption
      anchors.centerIn: parent
    }
  }

  // Distinct selection mark for the staged pick.
  Rectangle {
    id: checkBadge
    visible: root.chosen
    width: Style.space(18)
    height: width
    radius: Style.cornerRadius > 0 ? width / 2 : 0
    color: root.accent
    anchors.right: parent.right
    anchors.rightMargin: Style.space(10)
    anchors.top: root.compact ? undefined : parent.top
    anchors.topMargin: Style.space(9)
    anchors.verticalCenter: root.compact ? parent.verticalCenter : undefined

    Text {
      textFormat: Text.PlainText
      text: "\uf00c"
      color: Commons.Color.menu.background
      font.family: Style.font.menuFamily
      font.pixelSize: Style.font.caption
      font.bold: true
      anchors.centerIn: parent
    }
  }

  // Tall self-explanatory card layout (default for 2-4 choices).
  Column {
    id: tallBody
    visible: !root.compact
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.leftMargin: Style.space(12)
    anchors.rightMargin: Style.space(12)
    anchors.verticalCenter: parent.verticalCenter
    anchors.verticalCenterOffset: Style.space(6)
    spacing: Style.space(8)

    Item {
      width: parent.width
      height: Style.space(38)

      LayoutPictogram {
        visible: root.pictogram !== ""
        anchors.centerIn: parent
        mode: root.pictogram
        active: root.chosen
        foreground: root.foreground
        accent: root.accent
      }

      Image {
        id: tallVendorIcon
        visible: root.pictogram === "" && status === Image.Ready
        anchors.centerIn: parent
        width: Style.space(28)
        height: width
        source: root.vendorSource
        sourceSize.width: width * 2
        sourceSize.height: height * 2
        fillMode: Image.PreserveAspectFit
        opacity: root.chosen ? 1 : 0.88
        onStatusChanged: if (status === Image.Error && root.vendorIdx < root.vendorCandidates.length)
          Qt.callLater(function() { root.vendorIdx++ })
      }

      Text {
        visible: root.pictogram === "" && !tallVendorIcon.visible && root.icon !== ""
        anchors.centerIn: parent
        textFormat: Text.PlainText
        text: root.icon
        color: root.chosen ? root.accent : Util.alpha(root.foreground, 0.8)
        font.family: root.glyphFont
        font.pixelSize: Style.font.display
      }
    }

    Column {
      width: parent.width
      spacing: Style.space(3)

      Text {
        textFormat: Text.PlainText
        text: root.label
        color: root.foreground
        font.family: Style.font.menuFamily
        font.pixelSize: Style.font.body
        font.bold: true
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignHCenter
        width: parent.width
      }

      Text {
        visible: text !== ""
        textFormat: Text.PlainText
        text: root.detail
        color: Util.alpha(root.foreground, 0.62)
        font.family: Style.font.menuFamily
        font.pixelSize: Style.font.bodySmall
        lineHeight: 1.25
        wrapMode: Text.WordWrap
        maximumLineCount: 2
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignHCenter
        width: parent.width
      }
    }
  }

  // Compact layout when an extension adds >4 choices so the grid fits cleanly.
  Row {
    visible: root.compact
    anchors.left: parent.left
    anchors.leftMargin: Style.space(12)
    anchors.right: checkBadge.visible ? checkBadge.left : parent.right
    anchors.rightMargin: Style.space(10)
    anchors.verticalCenter: parent.verticalCenter
    spacing: Style.space(10)

    Image {
      id: compactVendorIcon
      visible: status === Image.Ready
      width: Style.space(22)
      height: width
      source: root.vendorSource
      sourceSize.width: width * 2
      sourceSize.height: height * 2
      fillMode: Image.PreserveAspectFit
      anchors.verticalCenter: parent.verticalCenter
    }

    Text {
      visible: !compactVendorIcon.visible && root.icon !== ""
      textFormat: Text.PlainText
      text: root.icon
      color: root.chosen ? root.accent : Util.alpha(root.foreground, 0.8)
      font.family: root.glyphFont
      font.pixelSize: Style.font.iconLarge
      horizontalAlignment: Text.AlignHCenter
      width: Style.space(22)
      anchors.verticalCenter: parent.verticalCenter
    }

    Column {
      width: parent.width - (root.icon !== "" ? Style.space(32) : 0)
      anchors.verticalCenter: parent.verticalCenter
      spacing: Style.space(2)

      Row {
        width: parent.width
        spacing: Style.space(6)

        Text {
          textFormat: Text.PlainText
          text: root.label
          color: root.foreground
          font.family: Style.font.menuFamily
          font.pixelSize: Style.font.body
          font.bold: root.chosen
          elide: Text.ElideRight
          width: Math.min(implicitWidth, Math.max(0, parent.width - (compactBadge.visible ? compactBadge.implicitWidth + Style.space(6) : 0)))
          anchors.verticalCenter: parent.verticalCenter
        }

        Text {
          id: compactBadge
          visible: root.current || root.recommended
          textFormat: Text.PlainText
          text: "(" + (root.current ? Commons.I18n.t("setup.current") : Commons.I18n.t("setup.recommended")) + ")"
          color: root.current ? Util.alpha(root.foreground, 0.56) : root.accent
          font.family: Style.font.menuFamily
          font.pixelSize: Style.font.caption
          anchors.verticalCenter: parent.verticalCenter
        }
      }

      Text {
        visible: text !== ""
        textFormat: Text.PlainText
        text: root.detail
        color: Util.alpha(root.foreground, 0.62)
        font.family: Style.font.menuFamily
        font.pixelSize: Style.font.bodySmall
        elide: Text.ElideRight
        width: parent.width
      }
    }
  }

  MouseArea {
    id: pointer
    anchors.fill: parent
    scale: 1 / root.scale
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: root.clicked()
  }
}
