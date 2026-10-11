import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Commons as Commons
import qs.Ui

// One per-app scroll speed: a window class pattern and its multiplier on top
// of the global scroll speed. The pattern commits when editing finishes, so
// half-typed classes never reach Hyprland.
Item {
  id: root

  property var app: ({ match: "", scroll: 1 })
  property bool divided: false
  property Item scroller: null
  property color foreground: Commons.Color.foreground
  property color accent: Commons.Color.accent
  property color background: Commons.Color.background

  readonly property bool editing: matchField.activeFocus
  readonly property var spec: ({ type: "number", min: 0.1, max: 5, step: 0.1, decimals: 1, suffix: "×", fallback: 1 })

  signal edited(string field, var value)
  signal removed()

  // Rows are reused as the list changes, and typing breaks the field's text
  // binding, so resync whenever this row is handed a different app.
  onAppChanged: if (!matchField.activeFocus) matchField.text = app.match

  implicitHeight: layout.implicitHeight + Style.spacing.lg * 2

  Rectangle {
    visible: root.divided
    anchors.top: parent.top
    width: parent.width
    height: 1
    color: Util.alpha(root.foreground, 0.08)
  }

  RowLayout {
    id: layout
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.verticalCenter: parent.verticalCenter
    spacing: Style.spacing.xxl

    TextField {
      id: matchField
      text: root.app.match
      placeholderText: "Window class, e.g. firefox"
      foreground: root.foreground
      accent: root.accent
      Layout.preferredWidth: Style.space(220)
      Layout.minimumWidth: Style.space(120)
      onEditingFinished: {
        var next = text.trim()
        if (next !== "" && next !== root.app.match) root.edited("match", next)
        else text = root.app.match
      }
      Keys.onEscapePressed: function(event) {
        text = root.app.match
        focus = false
        event.accepted = true
      }
    }

    Setting {
      Layout.fillWidth: true
      Layout.preferredWidth: 0
      Layout.minimumWidth: Style.space(120)
      spec: root.spec
      value: root.app.scroll
      scroller: root.scroller
      foreground: root.foreground
      accent: root.accent
      background: root.background
      onChanged: function(v) { root.edited("scroll", v) }
    }

    Button {
      iconText: "󰆴"
      tooltipText: "Remove"
      focusable: true
      foreground: root.foreground
      accent: root.accent
      horizontalPadding: Style.spacing.md
      onClicked: root.removed()
    }
  }
}
