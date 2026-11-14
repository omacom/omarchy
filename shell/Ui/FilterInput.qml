import QtQuick

// The search line of a keyboard-driven panel. It is a TextInput because Qt
// hands input-method text (fcitx5 composing Japanese, Chinese or Korean) only
// to text-input items; a Text fed by Keys.onPressed never receives it.
TextInput {
  id: root

  // Sees every key first; whatever it leaves unaccepted is typed here.
  property Item keyHandler: null

  focus: true
  clip: true
  Keys.priority: Keys.BeforeItem
  // The selection is only ever the whole query (Ctrl+A), and erasing it is the
  // line's job: the panel would take Backspace one character at a time.
  Keys.forwardTo: keyHandler ? [selectionEraser, keyHandler] : [selectionEraser]
  // Alt and Super chords are shortcuts, never text.
  Keys.onPressed: function(event) {
    if (event.modifiers & (Qt.AltModifier | Qt.MetaModifier)) event.accepted = true
  }

  // Append-only: the panel owns Left and Right, so the caret stays hidden at
  // the end. An empty delegate holds it hidden; cursorVisible returns on focus.
  // Ctrl+A may select the whole query, so typing replaces it; nothing less.
  cursorDelegate: Item {}
  onCursorPositionChanged: if (cursorPosition !== length) cursorPosition = length
  onSelectedTextChanged: if (selectedText && selectedText !== text) deselect()

  Item {
    id: selectionEraser
    Keys.onPressed: function(event) {
      if (event.key === Qt.Key_Backspace && root.selectedText && !root.readOnly
          && !(event.modifiers & (Qt.AltModifier | Qt.MetaModifier))) {
        root.remove(root.selectionStart, root.selectionEnd)
        event.accepted = true
      }
    }
  }
}
