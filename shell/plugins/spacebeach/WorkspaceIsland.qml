import QtQuick
import QtQuick.Layouts
import qs.Commons

Item {
  id: root

  property var workspaceData: ({})
  property color accentColor: Color.accent
  property color inkColor: Color.foreground
  property color baseColor: Color.background
  property color mutedColor: Color.muted
  property int selectedWindowIndex: -1
  property bool reduceMotion: false
  signal windowChosen(int flatIndex)

  readonly property var windows: Array.isArray(workspaceData.windows) ? workspaceData.windows : []
  readonly property string workspaceName: String(workspaceData.name || workspaceData.id || "?")
  readonly property bool focused: workspaceData.focused === true
  readonly property int windowCapacity: Math.max(1, Math.min(3, Math.floor((width + 7) / 81)))
  readonly property var displayedWindows: root.visibleWindowSlice()
  property real bob: 0

  function workspaceSalt(value) {
    var numeric = Number(value)
    if (isFinite(numeric)) return numeric
    var text = String(value || "")
    var hash = 0
    for (var i = 0; i < text.length; i++) hash = (hash * 31 + text.charCodeAt(i)) % 997
    return hash / 37
  }

  function visibleWindowSlice() {
    if (root.windows.length <= root.windowCapacity) return root.windows
    var selected = -1
    for (var i = 0; i < root.windows.length; i++) {
      if (Number(root.windows[i]._flatIndex) === root.selectedWindowIndex) {
        selected = i
        break
      }
    }
    var start = selected < 0 ? 0 : Math.max(0, Math.min(root.windows.length - root.windowCapacity, selected - 1))
    return root.windows.slice(start, start + root.windowCapacity)
  }

  Timer {
    running: root.visible && root.focused && !root.reduceMotion
    repeat: true
    interval: 60
    onTriggered: root.bob = (root.bob + 0.035) % (Math.PI * 2)
  }

  Canvas {
    id: island
    anchors.fill: parent
    anchors.topMargin: 22

    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
    Component.onCompleted: requestPaint()

    Connections {
      target: root
      function onFocusedChanged() { island.requestPaint() }
      function onBobChanged() { island.requestPaint() }
      function onWorkspaceDataChanged() { island.requestPaint() }
      function onAccentColorChanged() { island.requestPaint() }
      function onInkColorChanged() { island.requestPaint() }
      function onReduceMotionChanged() { island.requestPaint() }
    }

    onPaint: {
      var ctx = getContext("2d")
      var w = width
      var h = height
      if (w <= 0 || h <= 0) return
      ctx.reset()
      ctx.clearRect(0, 0, w, h)
      var lift = root.reduceMotion ? 0 : Math.sin(root.bob + root.workspaceSalt(root.workspaceData.id)) * 2
      var cy = h * 0.62 + lift
      var rx = w * 0.46
      var ry = Math.max(34, h * 0.24)

      ctx.globalAlpha = root.focused ? 0.16 : 0.07
      ctx.fillStyle = root.focused ? root.accentColor : root.inkColor
      ctx.beginPath()
      ctx.ellipse(w / 2 - rx, cy + 8 - ry, rx * 2, ry * 2)
      ctx.fill()

      for (var ring = 0; ring < 5; ring++) {
        ctx.globalAlpha = (root.focused ? 0.34 : 0.16) - ring * 0.025
        ctx.strokeStyle = ring === 0 && root.focused ? root.accentColor : root.inkColor
        ctx.lineWidth = ring === 0 ? 1.5 : 0.7
        ctx.beginPath()
        var ringRx = rx - ring * 9
        var ringRy = Math.max(8, ry - ring * 7)
        ctx.ellipse(w / 2 - ringRx, cy + ring * 5 - ringRy, ringRx * 2, ringRy * 2)
        ctx.stroke()
      }
      ctx.globalAlpha = 1
    }
  }

  RowLayout {
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    spacing: 8

    Text {
      text: "ISLAND " + root.workspaceName
      textFormat: Text.PlainText
      color: root.focused ? root.accentColor : root.inkColor
      font.family: Style.font.family
      font.pixelSize: Style.font.caption
      font.letterSpacing: 1.5
      font.weight: Font.DemiBold
    }

    Rectangle {
      Layout.fillWidth: true
      Layout.preferredHeight: 1
      color: Qt.rgba(root.inkColor.r, root.inkColor.g, root.inkColor.b, 0.16)
    }

    Text {
      text: String(root.windows.length).padStart(2, "0")
      textFormat: Text.PlainText
      color: root.mutedColor
      font.family: Style.font.family
      font.pixelSize: Style.font.caption
    }
  }

  Flow {
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.verticalCenter: parent.verticalCenter
    anchors.verticalCenterOffset: -5
    spacing: 7

    Repeater {
      model: root.displayedWindows

      delegate: WindowCard {
        required property var modelData
        width: Math.max(62, (root.width - (root.displayedWindows.length - 1) * 7) / Math.max(1, root.displayedWindows.length))
        height: 78
        compact: true
        windowData: modelData
        selected: Number(modelData._flatIndex) === root.selectedWindowIndex
        accentColor: root.accentColor
        inkColor: root.inkColor
        baseColor: root.baseColor
        mutedColor: root.mutedColor
        onChosen: root.windowChosen(Number(modelData._flatIndex))
      }
    }

    Text {
      visible: root.windows.length === 0
      text: "quiet water"
      textFormat: Text.PlainText
      color: Qt.rgba(root.mutedColor.r, root.mutedColor.g, root.mutedColor.b, 0.72)
      font.family: Style.font.family
      font.pixelSize: Style.font.bodySmall
      font.italic: true
    }
  }

  Text {
    visible: root.windows.length > root.displayedWindows.length
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    text: "+" + (root.windows.length - root.displayedWindows.length) + " BEYOND · ↑↓ REVEALS SELECTION"
    textFormat: Text.PlainText
    color: root.mutedColor
    font.family: Style.font.family
    font.pixelSize: Math.max(8, Style.font.caption - 1)
    font.letterSpacing: 0.5
  }
}
