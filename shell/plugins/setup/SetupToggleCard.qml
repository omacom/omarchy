import QtQuick
import qs.Commons
import qs.Commons as Commons
import qs.Ui

// Single-card opt-in switch for optional tour steps (Agent, Local AI,
// Tailscale). Replaces the 50/50 "Not now" card split with one calm,
// self-explanatory feature card whose ToggleSwitch and hero preview stay bound
// to the same staged state.
BorderSurface {
  id: root

  property string label: ""
  property string detail: ""
  property string meta: ""
  property string icon: ""
  property string iconFont: ""
  property string vendor: ""
  property bool enabled: false
  property bool focused: false
  property bool lights: false

  property color foreground: Commons.Color.menu.text
  property color accent: Commons.Color.accent

  signal toggled()

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

  implicitHeight: Math.max(Style.space(86), contentRow.implicitHeight + Style.space(28))
  radius: Style.cornerRadius
  color: enabled ? Util.alpha(foreground, hovered ? 0.14 : 0.1)
    : hovered ? Style.hoverFillFor(foreground, accent)
    : Style.normalFillFor(foreground, accent)
  borderSpec: enabled ? Border.flat(focused ? foreground : Util.alpha(foreground, 0.85), Math.max(1, Style.space(2)))
    : Border.flat(Util.alpha(foreground, focused ? 0.44 : hovered ? 0.34 : 0.18), Style.spacing.hairline)

  Accessible.role: Accessible.CheckBox
  Accessible.name: root.label + (root.detail !== "" ? ", " + root.detail : "")
  Accessible.checked: root.enabled
  Accessible.onPressAction: root.toggled()
  Accessible.onToggleAction: root.toggled()

  Behavior on color { ColorAnimation { duration: Style.duration(120) } }

  Rectangle {
    anchors.fill: parent
    anchors.margins: root.enabled ? Math.max(1, Style.space(2)) : Style.spacing.hairline
    radius: Math.max(0, root.radius - 1)
    color: Util.alpha(root.accent, root.enabled ? 0.06 : 0)
    Behavior on color { ColorAnimation { duration: Style.duration(140) } }
  }

  scale: pointer.pressed ? 0.985 : 1
  Behavior on scale {
    NumberAnimation {
      duration: Style.duration(160)
      easing.type: Easing.Bezier
      easing.bezierCurve: Style.easeOut
    }
  }

  Item {
    id: contentRow
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.leftMargin: Style.space(18)
    anchors.rightMargin: Style.space(18)
    anchors.verticalCenter: parent.verticalCenter
    implicitHeight: Math.max(iconTile.height, textColumn.implicitHeight, toggle.implicitHeight)
    height: implicitHeight

    Rectangle {
      id: iconTile
      width: Style.space(44)
      height: width
      radius: Style.cornerRadius
      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
      color: root.enabled ? Util.alpha(root.accent, 0.18) : Util.alpha(root.foreground, 0.06)
      border.width: Style.spacing.hairline
      border.color: root.enabled ? Util.alpha(root.accent, 0.55) : Util.alpha(root.foreground, 0.16)

      Behavior on color { ColorAnimation { duration: Style.duration(140) } }
      Behavior on border.color { ColorAnimation { duration: Style.duration(140) } }

      Image {
        id: vendorMark
        visible: status === Image.Ready
        width: Style.space(22)
        height: width
        anchors.centerIn: parent
        source: root.vendorSource
        sourceSize.width: width * 2
        sourceSize.height: height * 2
        fillMode: Image.PreserveAspectFit
        onStatusChanged: if (status === Image.Error && root.vendorIdx < root.vendorCandidates.length)
          Qt.callLater(function() { root.vendorIdx++ })
      }

      Text {
        visible: !vendorMark.visible
        textFormat: Text.PlainText
        text: root.icon
        color: root.enabled ? root.accent : Util.alpha(root.foreground, 0.78)
        font.family: root.glyphFont
        font.pixelSize: Style.font.iconLarge
        anchors.centerIn: parent
      }
    }

    Column {
      id: textColumn
      anchors.left: iconTile.right
      anchors.leftMargin: Style.space(16)
      anchors.right: toggle.left
      anchors.rightMargin: Style.space(16)
      anchors.verticalCenter: parent.verticalCenter
      spacing: Style.space(4)

      Text {
        textFormat: Text.PlainText
        text: root.label
        color: root.foreground
        font.family: Style.font.menuFamily
        font.pixelSize: Style.font.subtitle
        font.bold: true
        horizontalAlignment: Text.AlignLeft
        elide: Text.ElideRight
        width: parent.width
      }

      Text {
        visible: text !== ""
        textFormat: Text.PlainText
        text: root.detail
        color: Util.alpha(root.foreground, 0.7)
        font.family: Style.font.menuFamily
        font.pixelSize: Style.font.bodySmall
        lineHeight: 1.3
        horizontalAlignment: Text.AlignLeft
        wrapMode: Text.WordWrap
        width: parent.width
      }

      Text {
        visible: text !== ""
        textFormat: Text.PlainText
        text: root.meta
        color: Util.alpha(root.foreground, 0.52)
        font.family: Style.font.menuFamily
        font.pixelSize: Style.font.caption
        horizontalAlignment: Text.AlignLeft
        wrapMode: Text.WordWrap
        width: parent.width
      }
    }

    ToggleSwitch {
      id: toggle
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      interactive: false
      cursorRing: false
      checked: root.enabled
      foreground: root.foreground
      accent: root.accent
    }
  }

  MouseArea {
    id: pointer
    anchors.fill: parent
    scale: 1 / root.scale
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: root.toggled()
  }
}
