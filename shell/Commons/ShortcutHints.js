function displayKey(key) {
  var normalized = String(key || "").trim().toUpperCase()
  var names = {
    SPACE: "Space", RETURN: "Enter", ESCAPE: "Esc", BACKSPACE: "Backspace",
    DELETE: "Delete", INSERT: "Insert", HOME: "Home", END: "End",
    PAGE_UP: "Page Up", PAGE_DOWN: "Page Down", TAB: "Tab",
    COMMA: ",", PERIOD: ".", MINUS: "-", EQUAL: "=", SLASH: "/",
    GRAVE: "~", LEFT: "Left", RIGHT: "Right", UP: "Up", DOWN: "Down"
  }
  if (names[normalized]) return names[normalized]
  if (/^[A-Z0-9]$/.test(normalized)) return normalized
  return ""
}

function formatBinding(binding) {
  if (!binding) return ""
  var key = String(binding.key || "")
  if (key.indexOf("+") >= 0) key = key.slice(key.lastIndexOf("+") + 1).trim()
  if (!key) {
    var keycode = Number(binding.keycode)
    if (keycode >= 10 && keycode <= 19) key = String((keycode - 10 + 1) % 10)
  }
  var codeMatch = /^code:(\d+)$/i.exec(key)
  if (codeMatch && Number(codeMatch[1]) >= 10 && Number(codeMatch[1]) <= 19) {
    key = String((Number(codeMatch[1]) - 10 + 1) % 10)
  }
  key = displayKey(key)
  if (!key) return ""

  var mask = Number(binding.modmask) || 0
  var modifiers = []
  if (mask & 64) modifiers.push("Super")
  if (mask & 4) modifiers.push("Ctrl")
  if (mask & 8) modifiers.push("Alt")
  if (mask & 1) modifiers.push("Shift")
  modifiers.push(key)
  return modifiers.join(" + ")
}

function forAction(bindings, description) {
  if (!Array.isArray(bindings) || !description) return ""
  for (var i = 0; i < bindings.length; i++) {
    if (String(bindings[i].description || "") !== String(description)) continue
    var shortcut = formatBinding(bindings[i])
    if (shortcut) return shortcut
  }
  return ""
}

if (typeof module !== "undefined") {
  module.exports = {
    displayKey: displayKey,
    formatBinding: formatBinding,
    forAction: forAction
  }
}
