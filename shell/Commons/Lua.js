.pragma library

// Double-quote a string for a Lua expression, which is what string.format("%q")
// does on the Lua side. shellQuote only protects the command hyprctl receives;
// what it carries is Lua, so a name holding a quote, a backslash or a control
// character would end the literal and become code. Kept in a plain module so a
// test can load it without Quickshell.
function quote(value) {
  return "\"" + String(value || "")
    .replace(/\\/g, "\\\\")
    .replace(/"/g, "\\\"")
    .replace(/\n/g, "\\n")
    .replace(/\r/g, "\\r")
    .replace(/\t/g, "\\t")
    .replace(/[\x00-\x1f\x7f]/g, function(character) {
      return "\\" + ("00" + character.charCodeAt(0).toString()).slice(-3)
    }) + "\""
}
