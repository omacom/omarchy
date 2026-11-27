// Parse an Fcitx5 profile file to decide whether the long-running Python
// indicator.py watcher is needed. Single-group, single-keyboard-* profiles
// have nothing to switch between and stay in-process until the profile changes.
function parseProfile(raw) {
  var text = String(raw || "")
  if (!text.trim()) return { needsWatcher: true, methods: [] }

  var section = ""
  var groupCount = 0
  var methods = []
  var lines = text.split("\n")
  for (var i = 0; i < lines.length; i++) {
    var line = lines[i].trim()
    if (!line || line.charAt(0) === "#") continue
    if (line.charAt(0) === "[" && line.charAt(line.length - 1) === "]") {
      section = line.slice(1, -1)
      if (/^Groups\/\d+$/.test(section)) groupCount += 1
      continue
    }
    if (/^Groups\/0\/Items\/\d+$/.test(section) && line.indexOf("Name=") === 0) {
      var name = line.slice(5).trim()
      if (name && methods.indexOf(name) === -1) methods.push(name)
    }
  }

  var singleKeyboard = groupCount <= 1 && methods.length === 1 && methods[0].indexOf("keyboard-") === 0
  return { needsWatcher: !singleKeyboard, methods: methods }
}

if (typeof module !== "undefined") {
  module.exports = { parseProfile: parseProfile }
}
