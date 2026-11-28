import QtQuick
import QtQuick.Controls
import qs.Commons
import qs.Commons as Commons

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

  property color foreground: Commons.Color.foreground
  property color accent: Commons.Color.accent
  property color selectionTint: Style.selectionFillFor(foreground, accent)
  property bool password: false
  // Shows a password field's text in the clear (a "show password" toggle).
  property bool revealed: false
  property real horizontalPadding: Style.spacing.controlPaddingX
  property real trailingPadding: 0
  property real verticalPadding: Style.spacing.inputPaddingY

  // Panel-cursor flag. When true (and the field isn't already focused),
  // the background paints the shared hover/cursor state.
  // For mouse-enter/leave the consumer reads QQC TextField's inherited
  // `hovered` property (via onHoveredChanged) — we don't add a sibling
  // signal because the inherited property would shadow it.
  property bool hasCursor: false

  readonly property bool _focused: activeFocus
  readonly property bool _hot: hovered || hasCursor
  readonly property var _borderSpec: Border.controlSpec(_focused ? "focus" : (_hot ? "hover-cursor" : "normal"), root.foreground, root.accent)

  readonly property bool _masked: password && !revealed

  // The password dot (U+25CF) is wider than a monospace cell, so masked
  // text runs together. Space the dots apart, as the lock screen does, but
  // only while there are dots so the placeholder keeps its normal spacing.
  echoMode: _masked ? TextInput.Password : TextInput.Normal
  passwordCharacter: "\u25CF"
  font.family: Style.font.family
  font.pixelSize: Style.font.body
  font.letterSpacing: _masked && text.length > 0 ? Math.round(font.pixelSize * 0.25) : 0
  color: foreground
  selectionColor: selectionTint
  selectedTextColor: foreground
  placeholderTextColor: Qt.darker(foreground, 1.6)

  readonly property real _trailingPadding: Math.max(horizontalPadding, trailingPadding)
  leftPadding: (LayoutMirroring.enabled ? _trailingPadding : horizontalPadding) + Border.left(_borderSpec)
  rightPadding: (LayoutMirroring.enabled ? horizontalPadding : _trailingPadding) + Border.right(_borderSpec)
  topPadding: verticalPadding + Border.top(_borderSpec)
  bottomPadding: verticalPadding + Border.bottom(_borderSpec)

  background: BorderSurface {
    color: Style.controlFill(root._focused, root._hot, root.foreground, root.accent)
    borderSpec: root._borderSpec
    radius: Style.cornerRadius
  }
}
