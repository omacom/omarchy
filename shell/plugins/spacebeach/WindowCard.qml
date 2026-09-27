import QtQuick
import QtQuick.Layouts
import qs.Commons

Rectangle {
  id: root

  property var windowData: ({})
  property bool selected: false
  property bool liveNow: windowData && windowData._liveNow === true
  property bool compact: false
  property bool interactive: true
  property color accentColor: Color.accent
  property color inkColor: Color.foreground
  property color baseColor: Color.background
  property color mutedColor: Color.muted
  property string fidelity: String(windowData && windowData._fidelity || (liveNow ? "LIVE" : (hasIdentity ? "LAYOUT ONLY" : "LOST"))).toUpperCase()
  signal chosen()

  readonly property string address: String(windowData && (windowData.address || windowData.id) || "")
  readonly property string appId: String(windowData && (windowData.appId || windowData.class || windowData.initialClass) || "unknown")
  readonly property string label: String(windowData && (windowData.title || windowData.label || appId) || "private vessel")
  readonly property bool hasIdentity: appId !== "" && appId !== "unknown"

  function activate() {
    if (root.interactive && root.enabled && root.visible) root.chosen()
  }

  activeFocusOnTab: interactive && enabled && visible
  Accessible.ignored: !interactive
  Accessible.role: Accessible.Button
  Accessible.name: label
  Accessible.description: appId + ", " + fidelity
  Accessible.focusable: interactive && enabled && visible
  Accessible.focused: interactive && activeFocus
  Accessible.selected: interactive && selected
  Accessible.onPressAction: root.activate()
  Keys.onReturnPressed: if (root.interactive) root.activate()
  Keys.onEnterPressed: if (root.interactive) root.activate()
  Keys.onSpacePressed: if (root.interactive) root.activate()
  radius: compact ? 7 : 10
  color: Qt.rgba(baseColor.r, baseColor.g, baseColor.b, selected ? 0.88 : 0.68)
  border.width: selected || activeFocus ? 2 : 1
  border.color: selected || activeFocus ? accentColor : Qt.rgba(inkColor.r, inkColor.g, inkColor.b, 0.18)
  clip: true

  Rectangle {
    anchors.fill: parent
    color: "transparent"

    Canvas {
      id: hatch
      anchors.fill: parent
      opacity: 0.7
      onWidthChanged: requestPaint()
      onHeightChanged: requestPaint()
      Component.onCompleted: requestPaint()

      Connections {
        target: root
        function onSelectedChanged() { hatch.requestPaint() }
        function onAccentColorChanged() { hatch.requestPaint() }
        function onMutedColorChanged() { hatch.requestPaint() }
      }

      onPaint: {
        var ctx = getContext("2d")
        ctx.reset()
        ctx.clearRect(0, 0, width, height)
        ctx.strokeStyle = root.selected ? root.accentColor : Qt.rgba(root.mutedColor.r, root.mutedColor.g, root.mutedColor.b, 0.6)
        ctx.lineWidth = 1
        for (var i = -height; i < width + height; i += 13) {
          ctx.beginPath()
          ctx.moveTo(i, height)
          ctx.lineTo(i + height, 0)
          ctx.stroke()
        }
      }
    }

    Text {
      anchors.centerIn: parent
      text: root.appId ? root.appId.charAt(0).toUpperCase() : "·"
      textFormat: Text.PlainText
      color: Qt.rgba(root.inkColor.r, root.inkColor.g, root.inkColor.b, 0.66)
      font.family: Style.font.family
      font.pixelSize: root.compact ? Style.font.heading : Style.font.displayLarge
      font.weight: Font.Light
    }
  }

  Rectangle {
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    height: root.compact ? 25 : 42
    color: Qt.rgba(root.baseColor.r, root.baseColor.g, root.baseColor.b, 0.92)

    ColumnLayout {
      anchors.fill: parent
      anchors.leftMargin: 8
      anchors.rightMargin: 8
      spacing: 0

      Text {
        Layout.fillWidth: true
        text: root.label
        textFormat: Text.PlainText
        elide: Text.ElideRight
        maximumLineCount: 1
        color: root.inkColor
        font.family: Style.font.family
        font.pixelSize: root.compact ? Style.font.caption : Style.font.bodySmall
      }

      Text {
        Layout.fillWidth: true
        visible: !root.compact
        text: root.appId + "  /  " + root.fidelity
        textFormat: Text.PlainText
        elide: Text.ElideRight
        color: root.fidelity === "LOST" ? Color.urgent : ((root.fidelity === "EXACT" || root.fidelity === "LIVE") ? root.accentColor : root.mutedColor)
        font.family: Style.font.family
        font.pixelSize: Style.font.caption
        font.letterSpacing: 1.1
      }
    }
  }

  Rectangle {
    width: 7
    height: 7
    radius: 4
    anchors.top: parent.top
    anchors.right: parent.right
    anchors.margins: 7
    color: root.liveNow ? root.accentColor : root.mutedColor
    border.width: 1
    border.color: root.baseColor
  }

  MouseArea {
    anchors.fill: parent
    enabled: root.interactive && root.enabled
    cursorShape: Qt.PointingHandCursor
    onClicked: {
      root.forceActiveFocus()
      root.activate()
    }
  }
}
