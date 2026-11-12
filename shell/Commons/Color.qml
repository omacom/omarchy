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

  property color foreground: "#cacccc"
  property color background: "#101315"
  property color accent: "#cacccc"
  property color urgent: "#a55555"
  property color muted: "#707880"

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

  // --- Glass ------------------------------------------------------------------
  // Popup cards are drawn see-through while the bar is glassy, so what is behind
  // them is not known. These keep their text readable for any theme without
  // per-theme tuning: the card's opacity is the lowest that holds a minimum
  // contrast against a bright backdrop (a dark one under a light card).
  readonly property real glassBackdrop: 0.75      // how bright a backdrop to plan for, 0..1
  readonly property real glassTextContrast: 3.5   // minimum contrast for dimmed labels
  readonly property real glassTextLift: 1.5       // how far text moves from the card's color
  readonly property real glassAlphaMin: 0.5
  readonly property real glassAlphaMax: 0.8
  // Panels dim their labels as Qt.darker(foreground, 1.4); the same factor here.
  readonly property real glassLabelDim: 1.4

  function luminance(c) {
    function channel(v) { return v <= 0.03928 ? v / 12.92 : Math.pow((v + 0.055) / 1.055, 2.4) }
    return 0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b)
  }

  function contrastRatio(a, b) {
    var la = luminance(a)
    var lb = luminance(b)
    return (Math.max(la, lb) + 0.05) / (Math.min(la, lb) + 0.05)
  }

  // Text on a glass card: further from the card's color, lighter on a dark card
  // and darker on a light one.
  function glassTextFor(text, card) {
    return luminance(text) >= luminance(card) ? Qt.lighter(text, glassTextLift) : Qt.darker(text, glassTextLift)
  }

  // The lowest card alpha, within limits, at which the dimmed label color keeps
  // glassTextContrast over the planned-for backdrop.
  function glassAlphaFor(card, text) {
    var dim = Qt.darker(text, glassLabelDim)
    var backdrop = luminance(card) < 0.5 ? glassBackdrop : 1 - glassBackdrop
    var steps = Math.round((glassAlphaMax - glassAlphaMin) / 0.05)
    for (var i = 0; i <= steps; i++) {
      var a = glassAlphaMin + i * 0.05
      var shown = Qt.rgba(a * card.r + (1 - a) * backdrop, a * card.g + (1 - a) * backdrop, a * card.b + (1 - a) * backdrop, 1)
      if (contrastRatio(dim, shown) >= glassTextContrast) return a
    }
    return glassAlphaMax
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
    // The card and its text while the bar is glassy. The card stays see-through
    // so Hyprland can blur behind it, and only as opaque as it takes to keep the
    // dimmed labels readable over a bright (or, on a light card, dark) backdrop.
    property color glassText: root.glassTextFor(root.bar.text, background)
    property real glassAlpha: root.glassAlphaFor(background, glassText)
    property color glassBackground: Qt.rgba(background.r, background.g, background.b, Math.min(background.a, glassAlpha))
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
    var foundAccent = false
    var foundMuted = false
    var loadedForeground = false
    var loadedBackground = false
    var color0Value = ""
    var color4Value = ""
    var color7Value = ""
    var color8Value = ""
    for (var i = 0; i < lines.length; i++) {
      var match = lines[i].match(/^\s*([A-Za-z0-9_-]+)\s*=\s*["']?(#[0-9A-Fa-f]{6})/)
      if (!match) continue
      if (match[1] === "foreground") { foreground = match[2]; loadedForeground = true }
      else if (match[1] === "background") { background = match[2]; loadedBackground = true }
      // Prefer the explicit `accent` key; only fall back to color4 when the
      // theme doesn't define a separate accent. color4 appears later in the
      // file so the old single-property approach clobbered accent with it.
      else if (match[1] === "accent") { accent = match[2]; foundAccent = true }
      else if (match[1] === "muted") { muted = match[2]; foundMuted = true }
      else if (match[1] === "color0") color0Value = match[2]
      else if (match[1] === "color4") color4Value = match[2]
      else if (match[1] === "color7") color7Value = match[2]
      else if (match[1] === "color8") color8Value = match[2]
      else if (match[1] === "red" || match[1] === "color1") urgent = match[2]
    }
    if (!loadedBackground && color0Value.length > 0) background = color0Value
    if (!loadedForeground && color7Value.length > 0) foreground = color7Value
    if (!foundAccent && color4Value.length > 0) accent = color4Value
    if (!foundMuted) muted = color8Value.length > 0 ? color8Value : foreground
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
