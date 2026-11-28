import QtQuick

// The password typed into Splash.qml's field, and its line editing, which the
// boot splash (shell.qml) and the login screen (greeter.qml) share so that a
// password types the same at both. Each shell keeps one for all its screens.
QtObject {
  // Whether keys edit the password: while the field is up.
  property bool editable: false
  property string text: ""
  // The last attempt failed; typing clears it.
  property bool failed: false
  // Shown rather than dots, while Splash.qml's eye or Alt+F8 is held.
  property bool revealed: false

  // Plymouth's line editing, applied to what the keymap typed. Only the last
  // character can be removed, so keys that move a cursor do nothing. Control
  // characters (C0, DEL and C1) never go in: a shown password can't show them.
  function append(typed) {
    const kept = typed.replace(/[\x00-\x1f\x7f-\x9f]/g, "")
    if (!editable || kept === "") return
    text += kept
    failed = false
  }

  function removeLast() {
    if (!editable) return
    const characters = [...text]
    characters.pop()
    text = characters.join("")
  }

  function clear() {
    if (editable) text = ""
  }

  // The password, for an attempt, leaving the field empty.
  function take() {
    const taken = text
    text = ""
    failed = false
    return taken
  }
}
