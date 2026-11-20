import QtQuick
import qs.Commons
import qs.Commons as Commons

// Plugins are what the bar is made of. One of its pieces, and the panel that
// hangs from it, is switched on, switched off, brought in, copied or taken
// out, as the row under the cursor would do. Switched off it stays in the bar,
// dimmed; taken out it leaves no trace.
Desk {
  id: root

  // The row under the cursor, as SetupModel.optionFor describes it.
  property var option: null

  // The last part of the row's id: enable, disable, add, clone or remove.
  readonly property string verb: option ? String(option.id).replace(/^.*\./, "") : ""
  readonly property bool gone: verb === "remove"
  readonly property bool on: !gone && verb !== "disable"
  readonly property bool copied: verb === "clone"
  // How far in a plugin being added has come: 0 on its way, 1 in place.
  property real arrival: 1

  readonly property real unit: Util.clamp(root.stage.height * 0.12, Style.space(14), Style.space(26))
  readonly property real step: unit + Style.space(5)

  onVerbChanged: if (verb === "add") arrive.restart()

  NumberAnimation {
    id: arrive
    target: root
    property: "arrival"
    from: 0
    to: 1
    duration: Style.duration(260)
    easing.type: Easing.Bezier
    easing.bezierCurve: Style.easeOut
  }

  component Piece: Rectangle {
    width: root.unit
    height: root.unit
    radius: Style.cornerRadius
    color: Util.alpha(root.foreground, 0.14)
  }

  // The bar, larger than life.
  Rectangle {
    id: strip
    x: root.gap / 2
    y: root.gap / 2
    width: parent.width - root.gap
    height: root.unit + Style.space(10)
    color: Commons.Color.menu.background
    radius: Style.cornerRadius
    border.width: Style.spacing.hairline
    border.color: Util.alpha(root.foreground, 0.3)

    Row {
      anchors.left: parent.left
      anchors.leftMargin: Style.space(5)
      anchors.verticalCenter: parent.verticalCenter
      spacing: Style.space(5)

      Repeater {
        model: 3
        Piece {}
      }
    }

    Rectangle {
      anchors.centerIn: parent
      width: root.unit * 2.6
      height: Style.space(4)
      color: Util.alpha(root.foreground, 0.3)
    }

    Row {
      anchors.right: parent.right
      anchors.rightMargin: Style.space(5)
      anchors.verticalCenter: parent.verticalCenter
      spacing: Style.space(5)

      Repeater {
        model: 2
        Piece {}
      }
    }

    // A copy of it, which is the user's own to change.
    Rectangle {
      x: plugin.x - (root.copied ? root.step : 0)
      y: plugin.y
      width: root.unit
      height: root.unit
      radius: Style.cornerRadius
      opacity: root.copied ? 1 : 0
      color: Util.alpha(root.accent, 0.3)
      border.width: Style.spacing.hairline
      border.color: root.accent

      Behavior on x { NumberAnimation { duration: Style.duration(240); easing.type: Easing.Bezier; easing.bezierCurve: Style.easeOut } }
      Behavior on opacity { NumberAnimation { duration: Style.duration(root.copied ? 180 : 120); easing.type: Easing.OutCubic } }
    }

    Rectangle {
      id: plugin
      x: parent.width - Style.space(5) - root.step * 2 - root.unit
      y: (parent.height - height) / 2 - (1 - root.arrival) * root.unit
      width: root.unit
      height: root.unit
      radius: Style.cornerRadius
      opacity: root.gone ? 0 : root.arrival
      color: root.on ? root.accent : "transparent"
      border.width: Style.spacing.hairline
      border.color: root.on ? root.accent : Util.alpha(root.foreground, 0.5)

      Behavior on color { ColorAnimation { duration: Style.duration(160) } }
      Behavior on opacity {
        enabled: !arrive.running
        NumberAnimation { duration: Style.duration(root.gone ? 120 : 180); easing.type: Easing.OutCubic }
      }

      // The row's own mark: a check for on, a cross for off.
      Text {
        textFormat: Text.PlainText
        text: root.option ? root.option.icon : ""
        color: root.on ? Commons.Color.menu.background : Util.alpha(root.foreground, 0.6)
        font.family: root.option && root.option.iconFont !== "" ? root.option.iconFont : Style.font.menuFamily
        font.pixelSize: root.unit * 0.62
        anchors.centerIn: parent
      }
    }
  }

  // The panel the plugin opens, hanging from it as panels do from the bar.
  Win {
    readonly property real under: strip.x + plugin.x + root.unit / 2 - (root.copied ? root.step : 0)

    x: Util.clamp(under - width / 2, root.gap / 2, parent.width - width - root.gap / 2)
    y: strip.y + strip.height + Style.space(6)
    width: parent.width * 0.3
    height: (parent.height - y) * 0.82
    opacity: root.on ? root.arrival : 0
    scale: root.on ? 1 : 0.97
    transformOrigin: Item.Top
    active: true
    foreground: root.foreground
    accent: root.accent

    Behavior on x { NumberAnimation { duration: Style.duration(240); easing.type: Easing.Bezier; easing.bezierCurve: Style.easeOut } }
    Behavior on opacity {
      enabled: !arrive.running
      NumberAnimation { duration: Style.duration(root.on ? 180 : 120); easing.type: Easing.OutCubic }
    }
    Behavior on scale { NumberAnimation { duration: Style.duration(root.on ? 180 : 120); easing.type: Easing.Bezier; easing.bezierCurve: Style.easeOut } }
  }
}
