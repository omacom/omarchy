import QtQuick
import QtQuick.Controls
import qs.Commons

// Single-line text input with the kit's focus + selection styling. Inherits
// from Qt Quick Controls TextField so the underlying type's API (text,
// placeholderText, accepted, editingFinished, validator, ...) is available
// to callers without re-exposing each property.
//
// Defaults bind to qs.Commons.Color so a caller with no theme overrides
// just works; foreground / accent / selectionTint can be overridden per
// instance. activeFocus and mouse hover / panel cursor use the same
// hover-cursor defaults, so text inputs match Button, Toggle, and Dropdown.
//
// Sizing is driven by font.pixelSize + verticalPadding. The default 30px
// implicitHeight fits dialog forms; inline callers (wifi's row-embedded
// passphrase prompt) drop verticalPadding to match a 22-26px row.
TextField {
  id: root

  property color foreground: Color.foreground
  property color accent: Color.accent
  property color selectionTint: Style.selectionFillFor(foreground, accent)
  property bool password: false
  // Opt-in reveal control for masked fields: renders an eye button inside the
  // field's right padding that flips masking off. Only drawn when `password`
  // is set, so a plain field never grows an inert button. `revealed` resets
  // whenever the field is hidden, so a prompt reopened later always starts
  // masked.
  property bool revealable: false
  property bool revealed: false
  property real horizontalPadding: Style.spacing.controlPaddingX
  property real verticalPadding: Style.spacing.inputPaddingY

  readonly property bool _hasReveal: password && revealable

  // Panel-cursor flag. When true (and the field isn't already focused),
  // the background paints the shared hover/cursor state.
  // For mouse-enter/leave the consumer reads QQC TextField's inherited
  // `hovered` property (via onHoveredChanged) — we don't add a sibling
  // signal because the inherited property would shadow it.
  property bool hasCursor: false

  readonly property bool _focused: activeFocus
  readonly property bool _hot: hovered || hasCursor
  readonly property var _borderSpec: Border.controlSpec(_focused ? "focus" : (_hot ? "hover-cursor" : "normal"), root.foreground, root.accent)

  echoMode: (password && !revealed) ? TextInput.Password : TextInput.Normal
  font.family: Style.font.family
  font.pixelSize: Style.font.body
  color: foreground
  selectionColor: selectionTint
  selectedTextColor: foreground
  placeholderTextColor: Qt.darker(foreground, 1.6)

  leftPadding: horizontalPadding + Border.left(_borderSpec)
  rightPadding: horizontalPadding + Border.right(_borderSpec) + (_hasReveal ? revealButton.width : 0)
  topPadding: verticalPadding + Border.top(_borderSpec)
  bottomPadding: verticalPadding + Border.bottom(_borderSpec)

  background: BorderSurface {
    color: Style.controlFill(root._focused, root._hot, root.foreground, root.accent)
    borderSpec: root._borderSpec
    radius: Style.cornerRadius
  }

  onVisibleChanged: if (!visible) revealed = false

  // Sized off the body font rather than the icon font so the button stays
  // inside the 22-26px inline fields; `focusable` stays false because the
  // field itself owns the keys while it is open.
  PanelActionButton {
    id: revealButton
    visible: root._hasReveal
    anchors.right: parent.right
    anchors.rightMargin: Border.right(root._borderSpec)
    anchors.verticalCenter: parent.verticalCenter
    fontSize: Style.font.body
    iconText: root.revealed ? "󰈉" : "󰈈"
    tooltipText: root.revealed ? "Hide" : "Show"
    foreground: root.foreground
    onClicked: root.revealed = !root.revealed
  }
}
