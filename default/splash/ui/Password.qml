import QtQuick

// The password typed into Splash.qml's field, and its line editing, which the
// boot splash (shell.qml) and the login screen (greeter.qml) share so that a
// password types the same at both. Each shell keeps one for all its screens.
QtObject {
  id: password

  // Whether keys edit the password: while the field is up.
  property bool editable: false
  property string text: ""
  // The last attempt failed; typing clears it.
  property bool failed: false
  // Shown rather than dots, when toggled with the eye or Tab, or while Alt+F8
  // is held.
  property bool revealed: false
  // True while Alt+F8 is holding the password open, pausing the inactivity hide.
  property bool revealHeld: false
  property int revealTimeoutMs: 15000

  // Shared across all screens so typing on one monitor resets the inactivity
  // deadline everywhere instead of another monitor hiding it early.
  readonly property Timer _hideRevealTimer: Timer {
    interval: password.revealTimeoutMs
    running: password.revealed && !password.revealHeld
    onTriggered: password.revealed = false
  }

  function touchReveal() {
    if (_hideRevealTimer.running) _hideRevealTimer.restart()
  }

  // Plymouth's line editing, plus Tab to toggle visibility, Shift+Tab to cycle
  // layouts, and Alt+F8 to hold-reveal. Returns the action for Splash.qml's
  // key handler so key routing can be tested without a Wayland window.
  function actionForKey(key, modifiers, text, isAutoRepeat, fieldVisible, layoutCount) {
    const extraModifiers = modifiers & (Qt.ControlModifier | Qt.AltModifier | Qt.MetaModifier)
    const backtab = key === Qt.Key_Backtab || (key === Qt.Key_Tab && (modifiers & Qt.ShiftModifier))
    if (backtab && !extraModifiers) {
      return !isAutoRepeat && fieldVisible && layoutCount > 1 ? "nextLayout" : "ignore"
    }
    if (key === Qt.Key_Tab && !extraModifiers) {
      return !isAutoRepeat && fieldVisible ? "toggleReveal" : "ignore"
    }
    if (key === Qt.Key_F8 && (modifiers & Qt.AltModifier)) {
      return "reveal"
    }
    if (key === Qt.Key_Escape || text === "\x1b") {
      return "dismiss"
    }
    if (key === Qt.Key_Return || key === Qt.Key_Enter || text === "\n" || text === "\r") {
      return "submit"
    }
    if (key === Qt.Key_Backspace || key === Qt.Key_Delete || text === "\x7f") {
      return "removeLast"
    }
    if (text === "\x15" || text === "\x17" || text === "\x03" || text === "\x04") {
      return "clear"
    }
    return "append"
  }

  // Plymouth's line editing, applied to what the keymap typed. Only the last
  // character can be removed, so keys that move a cursor do nothing. Control
  // characters (C0, DEL and C1) never go in: a shown password can't show them.
  function append(typed) {
    const kept = typed.replace(/[\x00-\x1f\x7f-\x9f]/g, "")
    if (!editable || kept === "") return
    text += kept
    failed = false
    touchReveal()
  }

  function removeLast() {
    if (!editable) return
    const characters = [...text]
    characters.pop()
    text = characters.join("")
    touchReveal()
  }

  function clear() {
    if (!editable) return
    text = ""
    touchReveal()
  }

  // The password, for an attempt, leaving the field empty.
  function take() {
    const taken = text
    text = ""
    failed = false
    revealed = false
    revealHeld = false
    return taken
  }
}
