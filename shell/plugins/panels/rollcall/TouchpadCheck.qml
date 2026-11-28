import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Commons as Commons
import qs.Ui

// The touchpad's gestures as the desktop receives them. Scrolling counts only
// with pixel deltas, which a touchpad sends and a mouse wheel does not, so a
// plugged-in mouse cannot stand in for the built-in pad.
ColumnLayout {
  id: root

  property bool active: false
  signal finished(string result, string detail)

  property var got: ({})
  property real travelled: 0
  // Each direction on its own, so a pad that scrolls only one way cannot pass.
  property var scrolled: ({ up: 0, down: 0, left: 0, right: 0 })
  property point last: Qt.point(-1, -1)
  property bool wheelOnly: false

  readonly property var gestures: ["move", "click", "rightClick", "scrollVertical", "scrollHorizontal", "drag"]
  readonly property int doneCount: gestures.filter(function(g) { return root.got[g] === true }).length

  onActiveChanged: if (active) { got = ({}); travelled = 0; scrolled = ({ up: 0, down: 0, left: 0, right: 0 }); last = Qt.point(-1, -1); wheelOnly = false }

  function mark(name) {
    if (got[name] === true) return
    var copy = Object.assign({}, got)
    copy[name] = true
    got = copy
    if (doneCount === gestures.length) Qt.callLater(function() { root.finished("pass", "move, click, two-finger click, scroll both ways, drag") })
  }

  function label(name) {
    if (name === "move") return Commons.I18n.t("rollcall.gesture.move")
    if (name === "click") return Commons.I18n.t("rollcall.gesture.click")
    if (name === "rightClick") return Commons.I18n.t("rollcall.gesture.rightClick")
    if (name === "scrollVertical") return Commons.I18n.t("rollcall.gesture.scrollVertical")
    if (name === "scrollHorizontal") return Commons.I18n.t("rollcall.gesture.scrollHorizontal")
    return Commons.I18n.t("rollcall.gesture.drag")
  }

  spacing: Style.spacing.rowGap

  Rectangle {
    Layout.fillWidth: true
    implicitHeight: Style.space(170)
    radius: Style.cornerRadius
    color: Style.normalFill
    border.width: 1
    border.color: Style.normalBorderColor

    Text {
      anchors.centerIn: parent
      textFormat: Text.PlainText
      text: root.wheelOnly ? Commons.I18n.t("rollcall.touchpadNotMouse") : Commons.I18n.t("rollcall.touchpadHere")
      color: Util.alpha(Commons.Color.popups.text, 0.45)
      font.family: Style.font.family
      font.pixelSize: Style.font.body
    }

    // The dot to drag into the ring.
    Rectangle {
      id: ring
      width: Style.space(36); height: width; radius: width / 2
      x: parent.width - width - Style.space(24); y: (parent.height - height) / 2
      color: "transparent"
      border.width: 2
      border.color: root.got.drag ? Commons.Color.accent : Util.alpha(Commons.Color.popups.text, 0.4)
    }
    Rectangle {
      id: dot
      width: Style.space(18); height: width; radius: width / 2
      x: Style.space(32); y: (parent.height - height) / 2
      color: Commons.Color.accent
      DragHandler {
        target: dot
        onActiveChanged: {
          if (active) return
          var cx = dot.x + dot.width / 2, cy = dot.y + dot.height / 2
          if (cx > ring.x && cx < ring.x + ring.width && cy > ring.y && cy < ring.y + ring.height) root.mark("drag")
        }
      }
    }

    MouseArea {
      anchors.fill: parent
      z: -1
      enabled: root.active
      hoverEnabled: true
      acceptedButtons: Qt.LeftButton | Qt.RightButton
      onPositionChanged: function(mouse) {
        if (root.last.x >= 0) root.travelled += Math.abs(mouse.x - root.last.x) + Math.abs(mouse.y - root.last.y)
        root.last = Qt.point(mouse.x, mouse.y)
        if (root.travelled > 300) root.mark("move")
      }
      onClicked: function(mouse) { root.mark(mouse.button === Qt.RightButton ? "rightClick" : "click") }
      onWheel: function(wheel) {
        if (wheel.pixelDelta.x === 0 && wheel.pixelDelta.y === 0) { root.wheelOnly = true; return }
        root.wheelOnly = false
        var s = Object.assign({}, root.scrolled)
        if (wheel.pixelDelta.y > 0) s.up += wheel.pixelDelta.y; else s.down -= wheel.pixelDelta.y
        if (wheel.pixelDelta.x > 0) s.left += wheel.pixelDelta.x; else s.right -= wheel.pixelDelta.x
        root.scrolled = s
        if (s.up > 75 && s.down > 75) root.mark("scrollVertical")
        if (s.left > 75 && s.right > 75) root.mark("scrollHorizontal")
      }
    }
  }

  Flow {
    Layout.fillWidth: true
    spacing: Style.spacing.controlGap
    Repeater {
      model: root.gestures
      Text {
        required property string modelData
        textFormat: Text.PlainText
        text: (root.got[modelData] ? "✓ " : "· ") + root.label(modelData)
        color: root.got[modelData] ? Commons.Color.accent : Util.alpha(Commons.Color.popups.text, 0.6)
        font.family: Style.font.family
        font.pixelSize: Style.font.body
      }
    }
  }

  Button {
    bordered: true
    text: Commons.I18n.t("rollcall.gesturesDead")
    onClicked: {
      var missing = root.gestures.filter(function(g) { return root.got[g] !== true })
      root.finished("fail", "never registered: " + missing.join(", "))
    }
  }
}
