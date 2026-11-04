// Terminal settings are in points, not the shell theme's pixel-size tokens.
function configPath(terminal) {
  return ({ ghostty: "ghostty/config", kitty: "kitty/kitty.conf", alacritty: "alacritty/alacritty.toml", foot: "foot/foot.ini" })[terminal] || ""
}

function pointSize(terminal, raw) {
  var lines = String(raw || "").split("\n")
  var section = ""
  var size = 9 // Omarchy's shipped terminal setting.
  for (var i = 0; i < lines.length; i++) {
    var line = lines[i].replace(/\s*[#;].*$/, "").trim()
    var heading = /^\[([^\]]+)\]$/.exec(line)
    if (heading) { section = heading[1].trim(); continue }
    var match = null
    if (terminal === "ghostty") match = /^font-size\s*=\s*([0-9]+(?:\.[0-9]+)?)\s*$/.exec(line)
    else if (terminal === "kitty") match = /^font_size\s+([0-9]+(?:\.[0-9]+)?)\s*$/.exec(line)
    else if (terminal === "alacritty" && section === "font") match = /^size\s*=\s*([0-9]+(?:\.[0-9]+)?)\s*$/.exec(line)
    else if (terminal === "foot" && (!section || section === "main")) {
      var font = /^font\s*=\s*([^,]+)/.exec(line)
      if (font) match = /:size=([0-9]+(?:\.[0-9]+)?)(?=:|$)/.exec(font[1])
    }
    if (match && Number(match[1]) > 0) size = Number(match[1])
  }
  return size
}

if (typeof module !== "undefined") module.exports = { configPath: configPath, pointSize: pointSize }
