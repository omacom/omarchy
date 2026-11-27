// Pure-JS parser for ~/.config/fcitx5/profile, kept Qt-free so it can be unit
// tested under node alongside KeyboardLayoutModel.js.
//
// Determines whether a Fcitx5 profile has only a single direct-input keyboard
// method in a single group (matching Indicator.switchable() in indicator.py).
// When it does, Quickshell skips spawning the long-running Python/PyGObject
// indicator process until the profile gains another method, a composition
// engine, or a second group.
function parseProfile(raw) {
  var text = String(raw || "")
  if (!text.trim()) return { valid: false, switchable: true, methods: [], groups: 0 }

  var groups = {}
  var itemsByGroup = {}
  var section = ""
  var lines = text.split(/\r?\n/)

  for (var i = 0; i < lines.length; i++) {
    var line = lines[i].trim()
    if (!line || line.charAt(0) === "#") continue
    var sec = /^\[([^\]]+)\]$/.exec(line)
    if (sec) {
      section = sec[1]
      var groupMatch = /^Groups\/(\d+)$/.exec(section)
      if (groupMatch) groups[groupMatch[1]] = true
      continue
    }
    var itemMatch = /^Groups\/(\d+)\/Items\/(\d+)$/.exec(section)
    if (itemMatch) {
      var kv = /^Name\s*=\s*(.+)$/.exec(line)
      if (kv) {
        var gid = itemMatch[1]
        var idx = parseInt(itemMatch[2], 10)
        groups[gid] = true
        if (!itemsByGroup[gid]) itemsByGroup[gid] = []
        itemsByGroup[gid].push({ index: idx, name: kv[1].trim() })
      }
    }
  }

  var groupIds = Object.keys(groups)
  if (groupIds.length === 0) return { valid: false, switchable: true, methods: [], groups: 0 }

  var methods = []
  var seen = {}
  var firstGroup = itemsByGroup[groupIds[0]] || []
  firstGroup.sort(function(a, b) { return a.index - b.index })
  for (var j = 0; j < firstGroup.length; j++) {
    var name = firstGroup[j].name
    if (name && !seen[name]) {
      seen[name] = true
      methods.push(name)
    }
  }

  if (methods.length === 0) return { valid: false, switchable: true, methods: [], groups: groupIds.length }

  var switchable = groupIds.length > 1 || methods.length > 1 || methods[0].indexOf("keyboard-") !== 0
  return { valid: true, switchable: switchable, methods: methods, groups: groupIds.length }
}

if (typeof module !== "undefined") {
  module.exports = {
    parseProfile: parseProfile
  }
}
