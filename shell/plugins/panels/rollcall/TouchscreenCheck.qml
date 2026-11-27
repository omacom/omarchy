import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Commons as Commons
import qs.Ui

// Touches only: each target takes a touchscreen tap and nothing from a mouse
// or touchpad, and a pinch has to come from two fingers on the glass.
ColumnLayout {
  id: root

  property bool active: false
  signal finished(string result, string detail)

  property var hit: ({})
  property bool pinched: false
  readonly property int targetCount: 5
  readonly property int hitCount: Object.keys(hit).length

  onActiveChanged: if (active) { hit = ({}); pinched = false }

  function touch(i) {
    if (hit[i] === true) return
    var copy = Object.assign({}, hit)
    copy[i] = true
    hit = copy
    check()
  }

  function check() {
    if (hitCount === targetCount && pinched) Qt.callLater(function() { root.finished("pass", "5 taps and a pinch") })
  }

  spacing: Style.spacing.rowGap

  Rectangle {
    id: pad
    Layout.fillWidth: true
    implicitHeight: Style.space(200)
    radius: Style.cornerRadius
    color: Style.normalFill
    border.width: 1
    border.color: root.pinched ? Commons.Color.accent : Style.normalBorderColor

    PinchHandler {
      target: null
      acceptedDevices: PointerDevice.TouchScreen
      onActiveScaleChanged: if (Math.abs(activeScale - 1) > 0.25 && !root.pinched) { root.pinched = true; root.check() }
    }

    Repeater {
      model: [Qt.point(0.08, 0.15), Qt.point(0.92, 0.15), Qt.point(0.5, 0.5), Qt.point(0.08, 0.85), Qt.point(0.92, 0.85)]
      Rectangle {
        required property point modelData
        required property int index
        width: Style.space(34); height: width; radius: width / 2
        x: modelData.x * pad.width - width / 2
        y: modelData.y * pad.height - height / 2
        color: root.hit[index] ? Commons.Color.accent : "transparent"
        border.width: 2
        border.color: root.hit[index] ? Commons.Color.accent : Util.alpha(Commons.Color.popups.text, 0.4)
        TapHandler {
          acceptedDevices: PointerDevice.TouchScreen
          enabled: root.active
          onTapped: root.touch(index)
        }
      }
    }
  }

  Text {
    textFormat: Text.PlainText
    text: Commons.I18n.t("rollcall.touchscreenHint")
    color: Util.alpha(Commons.Color.popups.text, 0.6)
    font.family: Style.font.family
    font.pixelSize: Style.font.body
    wrapMode: Text.Wrap
    Layout.fillWidth: true
  }

  Button {
    bordered: true
    text: Commons.I18n.t("rollcall.touchesDead")
    onClicked: root.finished("fail", root.hitCount + " of 5 taps" + (root.pinched ? ", pinch" : ", no pinch"))
  }
}
