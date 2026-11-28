pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "BorderGeometry.js" as Geometry

// Color surfaces for the shell. Foundational palette (foreground, background,
// accent, urgent) comes from theme/colors.toml. Per-surface roles come from
// theme/shell.toml — generated per theme from default/themed/shell.toml.tpl,
// or shipped directly by a theme to replace the generated file. Surfaces that
// don't appear in shell.toml fall back to the foundational palette.
QtObject {
  id: root

  readonly property string home: Quickshell.env("HOME")
  readonly property string stateHome: home + "/.local/state"
  readonly property string currentThemePath: stateHome + "/omarchy/current/theme"

  readonly property var _paletteDefaults: ({
    foreground: "#cacccc",
    background: "#101315",
    accent: "#cacccc",
    urgent: "#a55555",
    warning: "#c4a35a",
    muted: "#707880"
  })

  property color foreground: _paletteDefaults.foreground
  property color background: _paletteDefaults.background
  property color accent: _paletteDefaults.accent
  property color urgent: _paletteDefaults.urgent
  // A caution short of urgent: the theme's yellow.
  property color warning: _paletteDefaults.warning
  property color muted: _paletteDefaults.muted

  // Flat dictionary of "section.key" -> raw string from shell.toml.
  // Reassigning this whole property is what makes surface bindings below
  // re-evaluate when the theme swaps; mutating it in place would not.
  property var shellValues: ({})

  function pick(key, fallback) {
    var v = shellValues[key]
    return (typeof v === "string" && v.length > 0) ? v : fallback
  }

  function pickAlpha(key, fallback) {
    var v = shellValues[key]
    if (typeof v !== "string" || v.length === 0) return fallback
    var n = Number(v)
    if (!isFinite(n)) return fallback
    return Util.clampAlpha(n)
  }

  function firstColorToken(value) {
    var parts = String(value || "").replace(/^\s+|\s+$/g, "").split(/\s+/)
    for (var i = 0; i < parts.length; i++) {
      if (!parts[i].match(/^-?\d+(?:\.\d+)?deg$/)) return parts[i]
    }
    return value
  }

  function flatColor(value, fallback) {
    var seen = Object.create(null)
    var token = firstColorToken(value)
    var role = String(token || "").replace(/^\s+|\s+$/g, "").toLowerCase()
    while (root.shellValues[role] && root.shellValues[role] !== token) {
      if (seen[role]) return fallback
      seen[role] = true
      token = firstColorToken(root.shellValues[role])
      role = String(token || "").replace(/^\s+|\s+$/g, "").toLowerCase()
    }
    if (role === "foreground" || role === "text") return root.foreground
    if (role === "accent") return root.accent
    if (role === "urgent") return root.urgent
    if (role === "muted") return root.muted
    if (role === "background") return root.background
    if (role === "transparent") return Qt.rgba(0, 0, 0, 0)

    var color = Geometry.canonicalColor(token, 1)
    if (typeof color === "string" && color === token && token.charAt(0) !== "#") return fallback
    return color
  }

  // Compose a color from a base-color key and its `-alpha` companion. If the
  // base token is a gradient, color-only consumers use the first stop.
  function composed(colorKey, alphaKey, colorFallback, alphaFallback) {
    return Util.alpha(flatColor(pick(colorKey, colorFallback), colorFallback), pickAlpha(alphaKey, alphaFallback))
  }

  readonly property QtObject bar: QtObject {
    property color background: root.composed("bar.background", "bar.background-alpha", root.background, 1.0)
    property color text: root.pick("bar.text", root.foreground)
    property color active: root.pick("bar.active", root.urgent)
  }
  readonly property QtObject popups: QtObject {
    property color background: root.composed("popups.background", "popups.background-alpha", root.background, 1.0)
    property color text: root.pick("popups.text", root.foreground)
    property color border: root.composed("popups.border", "popups.border-alpha", root.accent, 1.0)
  }
  readonly property QtObject tooltip: QtObject {
    property color background: root.composed("tooltip.background", "tooltip.background-alpha", root.background, 1.0)
    property color text: root.pick("tooltip.text", root.foreground)
    property color border: root.composed("tooltip.border", "tooltip.border-alpha", root.foreground, 1.0)
  }
  readonly property QtObject notifications: QtObject {
    property color background: root.composed("notifications.background", "notifications.background-alpha", root.background, 1.0)
    property color text: root.pick("notifications.text", root.foreground)
    property color border: root.composed("notifications.border", "notifications.border-alpha", root.accent, 1.0)
    property color countdown: root.pick("notifications.countdown", root.accent)
  }
  readonly property QtObject menu: QtObject {
    property color background: root.composed("menu.background", "menu.background-alpha", root.background, 1.0)
    property color text: root.pick("menu.text", root.foreground)
    property color border: root.composed("menu.border", "menu.border-alpha", root.foreground, 1.0)
    property color scrim: root.composed("menu.scrim", "menu.scrim-alpha", root.background, 0.5)
    property color selectedBackground: root.composed("menu.selected-background", "menu.selected-background-alpha", root.foreground, 0.08)
    property color selectedText: root.pick("menu.selected-text", root.accent)
    property color selectedBorder: root.composed("menu.selected-border", "menu.selected-border-alpha", root.foreground, 0.0)
  }
  // polkit + lock share a single border-alpha across border / border-active /
  // border-error: the three states are mutually exclusive in time, so one
  // companion is enough.
  readonly property QtObject polkit: QtObject {
    property color background: root.composed("polkit.background", "polkit.background-alpha", root.background, 1.0)
    property color text: root.pick("polkit.text", root.foreground)
    property color textError: root.pick("polkit.text-error", root.urgent)
    property color border: root.composed("polkit.border", "polkit.border-alpha", root.accent, 1.0)
    property color borderError: root.composed("polkit.border-error", "polkit.border-alpha", root.urgent, 1.0)
    property color accent: root.pick("polkit.accent", root.accent)
    property color scrim: root.composed("polkit.scrim", "polkit.scrim-alpha", root.background, 0.5)
  }
  readonly property QtObject lock: QtObject {
    property color background: root.composed("lock.background", "lock.background-alpha", root.background, 0.8)
    property color text: root.pick("lock.text", root.foreground)
    property color placeholder: root.shellValues["lock.placeholder"] ? root.flatColor(root.shellValues["lock.placeholder"], Util.alpha(root.foreground, 0.66)) : Util.alpha(root.foreground, 0.66)
    property color textError: root.pick("lock.text-error", root.urgent)
    property color border: root.composed("lock.border", "lock.border-alpha", root.foreground, 1.0)
    property color borderActive: root.composed("lock.border-active", "lock.border-alpha", root.accent, 1.0)
    property color borderError: root.composed("lock.border-error", "lock.border-alpha", root.urgent, 1.0)
    property color selection: root.composed("lock.selection", "lock.selection-alpha", root.accent, 0.45)
  }
  // The image picker has no card surface or backdrop; per-slice dim
  // overlays / text outlines use the foundational `background` color directly.
  readonly property QtObject imagePicker: QtObject {
    property color text: root.pick("image-picker.text", root.foreground)
    property color selectedBorder: root.composed("image-picker.selected-border", "image-picker.selected-border-alpha", root.accent, 1.0)
    property color unselectedBorder: root.composed("image-picker.unselected-border", "image-picker.unselected-border-alpha", root.foreground, 0.28)
  }

  function loadColors(raw) {
    var lines = String(raw || "").split("\n")
    var named = Object.create(null)
    var nextUrgent = _paletteDefaults.urgent
    var nextWarning = _paletteDefaults.warning
    for (var i = 0; i < lines.length; i++) {
      var match = lines[i].match(/^\s*([A-Za-z0-9_-]+)\s*=\s*["']?(#[0-9A-Fa-f]{6})/)
      if (!match) continue
      var key = match[1]
      var value = match[2]
      named[key] = value
      if (key === "red" || key === "color1") nextUrgent = value
      else if (key === "yellow" || key === "color3") nextWarning = value
    }
    // Resolve every stop from this file so a missing key cannot retain a color
    // from the previous theme. Explicit foreground, background, and accent
    // take precedence over their Base24 aliases.
    foreground = named.foreground || named.color7 || _paletteDefaults.foreground
    background = named.background || named.color0 || _paletteDefaults.background
    accent = named.accent || named.color4 || _paletteDefaults.accent
    urgent = nextUrgent
    warning = nextWarning
    muted = named.muted || named.color8 || foreground
  }

  // Last theme-supplied and user-supplied shell.toml dicts, kept separate so
  // either can be reloaded without re-reading the other. `shellValues` is
  // always the merge of theme (base) and user (override) — see mergeShell.
  property var themeShellValues: ({})
  property var userShellValues: ({})

  // Single TOML walker for shell.toml. Both Color (surface roles) and Style
  // (typography, spacing, bar, control states) consume the resulting dict.
  // Accepts quoted strings, bare numeric values, bare width lists, and bare
  // role names; tolerates inline comments. Numbers are kept as strings here —
  // readers coerce when they pull a value.
  function parseShell(raw) {
    var parsed = {}
    var text = String(raw || "")
    if (text) {
      var lines = text.split("\n")
      var section = ""
      for (var i = 0; i < lines.length; i++) {
        var line = lines[i].replace(/^\s+|\s+$/g, "")
        if (!line || line.charAt(0) === "#") continue
        var sectionMatch = line.match(/^\[([A-Za-z0-9_-]+)\]\s*(#.*)?$/)
        if (sectionMatch) { section = sectionMatch[1]; continue }
        var stringKv = line.match(/^([A-Za-z0-9_-]+)\s*=\s*["']([^"']+)["']\s*(#.*)?$/)
        var numKv = line.match(/^([A-Za-z0-9_-]+)\s*=\s*(-?\d+(?:\.\d+)?)\s*(#.*)?$/)
        var widthKv = line.match(/^([A-Za-z0-9_-]+)\s*=\s*(-?\d+(?:\.\d+)?(?:\s+-?\d+(?:\.\d+)?){1,3})\s*(#.*)?$/)
        var bareKv = line.match(/^([A-Za-z0-9_-]+)\s*=\s*([A-Za-z][A-Za-z0-9_-]*)\s*(#.*)?$/)
        var kv = stringKv || numKv || widthKv || bareKv
        if (!kv || !section) continue
        parsed[section + "." + kv[1]] = kv[2]
      }
    }
    return parsed
  }

  // Re-derive `shellValues` from theme base + user override and push it to
  // Style. User keys win, so a machine-level `~/.config/omarchy/shell.toml`
  // survives theme switches (which replace only themeShellValues).
  function mergeShell() {
    var merged = {}
    for (var tk in themeShellValues) merged[tk] = themeShellValues[tk]
    for (var uk in userShellValues) merged[uk] = userShellValues[uk]
    shellValues = merged
    Style.applyShellValues(merged)
  }

  function loadShell(raw) {
    themeShellValues = parseShell(raw)
    mergeShell()
  }

  function loadUserShell(raw) {
    userShellValues = parseShell(raw)
    mergeShell()
  }

  // Startup load only. Runtime theme switches push the payload explicitly
  // through shell IPC.
  property FileView colorsFile: FileView {
    id: colorsFile
    path: root.currentThemePath + "/colors.toml"
    watchChanges: false
    printErrors: false
    onLoaded: root.loadColors(text())
  }
  property FileView shellFile: FileView {
    id: shellFile
    path: root.currentThemePath + "/shell.toml"
    watchChanges: false
    printErrors: false
    onLoaded: root.loadShell(text())
    onLoadFailed: root.loadShell("")
  }
  // Machine-level override, layered on top of whatever theme is active. This
  // is where `omarchy display text size` writes `[font] base-size`. Watched so the
  // CLI takes effect live without restarting the shell; absent by default.
  property FileView userShellFile: FileView {
    id: userShellFile
    path: root.home + "/.config/omarchy/shell.toml"
    watchChanges: true
    printErrors: false
    onLoaded: root.loadUserShell(text())
    // Re-read on change (including first creation) before loading — `text()`
    // is stale in the change signal itself, so route both paths through reload
    // → onLoaded to always parse fresh content.
    onFileChanged: reload()
    onLoadFailed: root.loadUserShell("")
  }
}
