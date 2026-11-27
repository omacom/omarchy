import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Commons as Commons
import qs.Ui

// Every key on the main block, by physical position: Qt's native scan code is
// the evdev code plus 8 on Wayland, so this holds for any layout, Latin or not.
// Keys a laptop may lack (right Ctrl, the ISO and JIS extras) light up when
// pressed but are not required.
ColumnLayout {
  id: root

  property bool active: false
  signal finished(string result, string detail)

  property var seen: ({})
  readonly property int requiredCount: required.length
  readonly property int seenCount: required.filter(function(code) { return root.seen[code] === true }).length

  // Rows of [evdev code, width in key units, required].
  readonly property var rows: [
    [[1, 1.25, true], [41, 1, true], [2, 1, true], [3, 1, true], [4, 1, true], [5, 1, true], [6, 1, true], [7, 1, true], [8, 1, true], [9, 1, true], [10, 1, true], [11, 1, true], [12, 1, true], [13, 1, true], [14, 1.75, true]],
    [[15, 1.5, true], [16, 1, true], [17, 1, true], [18, 1, true], [19, 1, true], [20, 1, true], [21, 1, true], [22, 1, true], [23, 1, true], [24, 1, true], [25, 1, true], [26, 1, true], [27, 1, true], [43, 1.5, false]],
    [[58, 1.75, true], [30, 1, true], [31, 1, true], [32, 1, true], [33, 1, true], [34, 1, true], [35, 1, true], [36, 1, true], [37, 1, true], [38, 1, true], [39, 1, true], [40, 1, true], [28, 2.25, true]],
    [[42, 1.25, true], [86, 1, false], [44, 1, true], [45, 1, true], [46, 1, true], [47, 1, true], [48, 1, true], [49, 1, true], [50, 1, true], [51, 1, true], [52, 1, true], [53, 1, true], [54, 2, true]],
    [[29, 1.25, true], [56, 1.25, true], [57, 6, true], [100, 1.25, false], [97, 1.25, false], [105, 1, true], [103, 1, true], [108, 1, true], [106, 1, true]]
  ]
  readonly property var required: {
    var out = []
    for (var r = 0; r < rows.length; r++)
      for (var k = 0; k < rows[r].length; k++)
        if (rows[r][k][2]) out.push(rows[r][k][0])
    return out
  }

  onActiveChanged: {
    if (!active) return
    seen = ({})
    Qt.callLater(function() { if (root.active) catcher.forceActiveFocus() })
  }

  function press(event) {
    var code = event.nativeScanCode - 8
    if (code <= 0) return
    if (seen[code] !== true) {
      var copy = Object.assign({}, seen)
      copy[code] = true
      seen = copy
    }
    event.accepted = true
    if (seenCount === requiredCount)
      Qt.callLater(function() { root.finished("pass", requiredCount + " keys") })
  }

  spacing: Style.spacing.rowGap

  Item {
    id: catcher
    focus: root.active
    Layout.fillWidth: true
    implicitHeight: board.implicitHeight
    Keys.onPressed: function(event) { root.press(event) }

    readonly property real unit: (width - Style.space(2) * 15) / 15.5

    Column {
      id: board
      spacing: Style.space(2)
      LayoutMirroring.enabled: false

      Repeater {
        model: root.rows
        Row {
          required property var modelData
          spacing: Style.space(2)
          Repeater {
            model: modelData
            Rectangle {
              required property var modelData
              readonly property bool lit: root.seen[modelData[0]] === true
              width: catcher.unit * modelData[1] + Style.space(2) * (modelData[1] - 1)
              height: catcher.unit * 0.8
              radius: Style.cornerRadius
              color: lit ? Commons.Color.accent : (modelData[2] ? Style.normalFill : "transparent")
              border.width: 1
              border.color: modelData[2] ? Style.normalBorderColor : Util.alpha(Commons.Color.popups.text, 0.15)
              Behavior on color { ColorAnimation { duration: Style.duration(120) } }
            }
          }
        }
      }
    }
  }

  Text {
    textFormat: Text.PlainText
    text: Commons.I18n.t("rollcall.keysSeen").arg(Commons.I18n.formatNumber(root.seenCount)).arg(Commons.I18n.formatNumber(root.requiredCount))
    color: Util.alpha(Commons.Color.popups.text, 0.6)
    font.family: Style.font.family
    font.pixelSize: Style.font.body
  }

  Button {
    bordered: true
    text: Commons.I18n.t("rollcall.keysDead")
    onClicked: root.finished("fail", (root.requiredCount - root.seenCount) + " of " + root.requiredCount + " keys never registered")
  }
}
