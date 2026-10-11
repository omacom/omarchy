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
  property bool searchable: false

  signal handleCustomKeys(KeyEvent event)
  signal moveRequested(int dx, int dy)
  signal pageUp(KeyEvent event);
  signal pageDown(KeyEvent event);
  signal reorderRequested(int dy)
  signal activateRequested()
  signal returnRequested(KeyEvent event)
  signal goBack(KeyEvent event)
  signal closeRequested()
  signal deleteRequested(KeyEvent event)
  signal tabRequested(int direction)
  // The held modifiers ride along, so a panel can tell Alt+T from T.
  signal textKey(string text, int modifiers)

  focus: true
  Keys.priority: Keys.BeforeItem
  Keys.onPressed: function(event) {
    if (blocked) return

    handleCustomKeys(event)
    if (event.accepted) {
      return
    }

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
    if (event.key === Qt.Key_PageUp) {
      pageUp(event); return
    }
    if (event.key === Qt.Key_PageDown) {
      pageDown(event); return
    }
    if (event.key === Qt.Key_Down || isVimMotion(event, Qt.Key_J)) {
      moveRequested(0, 1); event.accepted = true; return
    }
    if (event.key === Qt.Key_Up || isVimMotion(event, Qt.Key_K)) {
      moveRequested(0, -1); event.accepted = true; return
    }
    if (event.key === Qt.Key_Right || isVimMotion(event, Qt.Key_L)) {
      moveRequested(1, 0); event.accepted = true; return
    }
    if (event.key === Qt.Key_Left || isVimMotion(event, Qt.Key_H)) {
      moveRequested(-1, 0); event.accepted = true; return
    }
    if (event.key === Qt.Key_Backspace) {
      goBack(event); event.accepted = true; return
    }
    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
      returnRequested(event)
      activateRequested(); event.accepted = true; return
    }
    if (!searchable && event.key === Qt.Key_Space) {
      activateRequested(); event.accepted = true; return
    }
    if (event.key === Qt.Key_Delete || (!searchable && isKeyAllowShift(Qt.Key_X, event))) {
      deleteRequested(event); event.accepted = true; return
    }
    if (isTextKey(event)) {
      textKey(event.text, event.modifiers)
    }
  }

  function isTextKey(event) {
    const allowedModifiers = Qt.ShiftModifier | Qt.KeypadModifier
    return event.text
      && event.text.length === 1
      && event.text.charCodeAt(0) >= 32
      && event.text.charCodeAt(0) !== 127
      && (event.modifiers & ~allowedModifiers) === 0
  }

  function isKeyAllowShift(key, event) {
    return event.key === key
      && ((event.modifiers === Qt.NoModifier) || (event.modifiers === Qt.ShiftModifier))
  }

  function isVimMotion(event, key) {
    if (event.key != key) {
      return false
    }

    const modifier = searchable
      ? Qt.CTRL
      : Qt.NoModifier

    return event.modifiers === modifier
  }
}
