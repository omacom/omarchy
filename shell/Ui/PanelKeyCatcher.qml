import QtQuick

// Drop-in key dispatcher for keyboard-driven panels. Wraps panel content
// and emits semantic signals so each panel keeps its own state machine
// (focusSection, selectedIndex, action rules) while the boilerplate
// key handling lives here.
//
// Usage:
//   Common.KeyboardPanel {
//     ...
//     PanelKeyCatcher {
//       anchors.fill: parent
//       onMoveRequested: function(dx, dy) { root.moveCursor(dx, dy) }
//       onActivateRequested: root.activateCursor()
//       onCloseRequested: root.close()
//       onDeleteRequested: root.deleteSelected()
//       onTextKey: function(t, modifiers) { if (t === "r") root.refresh() }
//
//       Column { ... panel content ... }
//     }
//   }
//
// Keys.priority: Keys.BeforeItem means this handler gets keys first,
// even when a descendant has activeFocus. That's what lets Up/Down
// arrows drive the cursor instead of being consumed by an inner
// Flickable's built-in scroll handling. When a panel has an inline
// editor (wifi passphrase, gallery TextField demo) the panel must
// set `blocked: editor.activeFocus` so this handler short-circuits
// and the editor receives keys normally.
//
// blocked: when true, ALL keys are forwarded to descendants without
// triggering signals.
Item {
  id: root

  property bool blocked: false
  // Panels that let items be reordered set this, and Ctrl+Up/Down (or
  // Ctrl+k/j) then asks to move the current item instead of the cursor.
  property bool reorderable: false

  signal moveRequested(int dx, int dy)
  signal reorderRequested(int dy)
  signal activateRequested()
  signal returnRequested()
  signal closeRequested()
  signal deleteRequested()
  signal tabRequested(int direction)
  // The held modifiers ride along, so a panel can tell Alt+T from T.
  signal textKey(string text, int modifiers)

  focus: true
  Keys.priority: Keys.BeforeItem
  Keys.onPressed: function(event) {
    if (blocked) return

    if (event.key === Qt.Key_Escape) {
      closeRequested(); event.accepted = true; return
    }
    if (event.key === Qt.Key_Tab || event.key === Qt.Key_Backtab) {
      tabRequested((event.modifiers & Qt.ShiftModifier) || event.key === Qt.Key_Backtab ? -1 : 1)
      event.accepted = true
      return
    }
    if (reorderable && (event.modifiers & Qt.ControlModifier)) {
      var up = event.key === Qt.Key_Up || event.key === Qt.Key_K
      var down = event.key === Qt.Key_Down || event.key === Qt.Key_J
      if (up || down) {
        reorderRequested(down ? 1 : -1); event.accepted = true; return
      }
    }
    if (event.key === Qt.Key_Down || event.text === "j") {
      moveRequested(0, 1); event.accepted = true; return
    }
    if (event.key === Qt.Key_Up || event.text === "k") {
      moveRequested(0, -1); event.accepted = true; return
    }
    if (event.key === Qt.Key_Right || event.text === "l") {
      moveRequested(1, 0); event.accepted = true; return
    }
    if (event.key === Qt.Key_Left || event.text === "h") {
      moveRequested(-1, 0); event.accepted = true; return
    }
    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
      returnRequested()
      activateRequested(); event.accepted = true; return
    }
    if (event.key === Qt.Key_Space) {
      activateRequested(); event.accepted = true; return
    }
    if (event.key === Qt.Key_Delete || event.text === "x" || event.text === "X") {
      deleteRequested(); event.accepted = true; return
    }
    if (event.text && event.text.length === 1) {
      textKey(event.text, event.modifiers)
    }
  }
}
