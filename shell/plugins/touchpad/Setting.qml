import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Commons as Commons
import qs.Ui

// One setting row: title and description on the left, the control for the
// spec's type (switch, choice chips, or slider) on the right or underneath.
// The row is stateless: it shows `value` and emits `changed` / `reset`, and
// the window decides what that does to the saved document.
//
// `saved` marks a value the user set in this window, which earns a reset
// button back to the default. `external` marks an option the user's own
// ~/.config/hypr/input.lua also sets; a value saved here still wins, and the
// row says so, because a reset hands the option back to that file.
Item {
  id: root

  property var spec: ({})
  property var value
  property bool saved: false
  property bool external: false
  readonly property string externalText: saved
    ? "Overrides ~/.config/hypr/input.lua"
    : "From ~/.config/hypr/input.lua; change it to override"
  property string note: ""
  // Hairline above the row, for every row but a card's first.
  property bool divided: false
  property color foreground: Commons.Color.foreground
  property color accent: Commons.Color.accent
  property color background: Commons.Color.background
  // The page's Flickable, which receives wheel events over the slider.
  property Item scroller: null

  // Sliders and choice chips sit under the text so long option rows never
  // squeeze the description; switches stay at the end of the row.
  readonly property bool stacked: spec.type === "number"
  readonly property bool chips: spec.type === "choice"
  readonly property color dim: Qt.darker(foreground, 1.5)

  signal changed(var value)
  signal reset()

  implicitHeight: layout.implicitHeight + Style.spacing.lg * 2
  implicitWidth: Style.space(480)

  // PanelSlider takes its palette from a bar-shaped object.
  readonly property QtObject palette: QtObject {
    readonly property color foreground: root.foreground
    readonly property color background: root.background
  }

  function formatted(v) {
    if (spec.type !== "number" || v === undefined) return ""
    var decimals = spec.decimals !== undefined ? spec.decimals : 2
    var text = Number(v).toFixed(decimals)
    if (spec.signed && Number(v) > 0) text = "+" + text
    return text + (spec.suffix || "")
  }

  function stepped(v) {
    var step = spec.step || 0.05
    var snapped = Math.round((v - spec.min) / step) * step + spec.min
    snapped = Math.max(spec.min, Math.min(spec.max, snapped))
    var decimals = spec.decimals !== undefined ? spec.decimals : 2
    return Number(snapped.toFixed(decimals))
  }

  Rectangle {
    visible: root.divided
    anchors.top: parent.top
    width: parent.width
    height: 1
    color: Util.alpha(root.foreground, 0.08)
  }

  ColumnLayout {
    id: layout
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.verticalCenter: parent.verticalCenter
    spacing: Style.spacing.md

    RowLayout {
      Layout.fillWidth: true
      spacing: Style.spacing.xxl

      ColumnLayout {
        Layout.fillWidth: true
        Layout.preferredWidth: 0
        Layout.minimumWidth: 0
        spacing: Style.spacing.xs

        RowLayout {
          spacing: Style.spacing.md

          Text {
            textFormat: Text.PlainText
            text: root.spec.label || ""
            color: root.foreground
            font.family: Style.font.family
            font.pixelSize: Style.font.subtitle
            font.bold: true
          }

          // Changed from the default in this window.
          Rectangle {
            visible: root.saved
            width: Style.space(6)
            height: width
            radius: width / 2
            color: root.accent
            Layout.alignment: Qt.AlignVCenter
          }
        }

        Text {
          textFormat: Text.PlainText
          visible: text !== ""
          text: root.external ? root.externalText : (root.note || root.spec.description || "")
          color: root.external ? root.accent : root.dim
          font.family: Style.font.family
          font.pixelSize: Style.font.caption
          wrapMode: Text.WordWrap
          Layout.fillWidth: true
        }
      }

      Text {
        visible: root.stacked
        textFormat: Text.PlainText
        text: root.formatted(slider.liveValue)
        color: root.foreground
        font.family: Style.font.family
        font.pixelSize: Style.font.body
        font.bold: true
        Layout.alignment: Qt.AlignVCenter
      }

      Button {
        visible: root.saved
        iconText: "󰑓"
        tooltipText: "Reset to default"
        foreground: root.foreground
        accent: root.accent
        focusable: true
        horizontalPadding: Style.spacing.md
        Layout.alignment: Qt.AlignVCenter
        onClicked: root.reset()
      }

      // Switch: a focusable wrapper so Tab lands on it and Space flips it.
      Item {
        id: switchControl
        visible: root.spec.type === "bool"
        implicitWidth: toggle.implicitWidth
        implicitHeight: toggle.implicitHeight
        activeFocusOnTab: visible && enabled
        Layout.alignment: Qt.AlignVCenter

        Keys.onSpacePressed: root.changed(!root.value)
        Keys.onReturnPressed: root.changed(!root.value)
        Keys.onEnterPressed: root.changed(!root.value)

        ToggleSwitch {
          id: toggle
          anchors.fill: parent
          checked: root.value === true
          hasCursor: switchControl.activeFocus
          foreground: root.foreground
          accent: root.accent
          onToggled: root.changed(!root.value)
        }
      }
    }

    ButtonGroup {
      visible: root.chips
      focusable: visible && enabled
      opacity: enabled ? 1 : 0.45
      options: root.spec.options || []
      value: root.value === undefined ? "" : String(root.value)
      foreground: root.foreground
      background: root.background
      accent: root.accent
      onChanged: function(v) { root.changed(root.spec.integer ? Number(v) : v) }
    }

    // Slider: Left/Right (or h/l) step it from the keyboard, the wheel
    // nudges it, and a drag only saves when released.
    Item {
      id: sliderControl
      visible: root.stacked
      Layout.fillWidth: true
      implicitHeight: slider.implicitHeight
      activeFocusOnTab: visible && enabled

      function nudge(direction) {
        var base = root.value === undefined ? root.spec.fallback : root.value
        var next = root.stepped(Number(base) + direction * (root.spec.step || 0.05))
        if (next !== root.value) root.changed(next)
      }

      Keys.onPressed: function(event) {
        if (event.key === Qt.Key_Left || event.key === Qt.Key_H) {
          nudge(-1)
          event.accepted = true
        } else if (event.key === Qt.Key_Right || event.key === Qt.Key_L) {
          nudge(1)
          event.accepted = true
        }
      }

      BorderSurface {
        anchors.fill: parent
        anchors.margins: -Style.spacing.sm
        visible: sliderControl.activeFocus
        color: Style.focusFillFor(root.foreground, root.accent)
        radius: Style.cornerRadius
        borderSpec: Border.controlSpec("focus", root.foreground, root.accent)
      }

      PanelSlider {
        id: slider
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        bar: root.palette
        minimum: root.spec.min !== undefined ? root.spec.min : 0
        maximum: root.spec.max !== undefined ? root.spec.max : 1
        step: root.spec.step || 0.05
        integer: root.spec.integer === true
        value: root.value === undefined ? (root.spec.fallback || 0) : root.value
        onReleased: function(v) {
          var next = root.stepped(v)
          if (next !== root.value) root.changed(next)
        }
      }

      // Scrolling the page with the touchpad sweeps the pointer across the
      // sliders, and PanelSlider turns every wheel event into a new value.
      // Take the wheel here and scroll the page instead.
      MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        onWheel: function(wheel) {
          if (root.scroller) root.scroller.scrollBy(wheel)
          wheel.accepted = true
        }
      }
    }
  }
}
