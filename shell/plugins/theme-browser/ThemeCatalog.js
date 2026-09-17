// Pure logic for the theme browser: what a catalog entry looks like once
// parsed, and which entries a set of filters leaves on screen. Kept out of the
// QML so test/shell.d/theme-browser-test.sh can load it in Node.

var NEW_WINDOW_DAYS = 14

// A theme name is about to be handed to omarchy-theme-install on a command
// line, so the catalog is held to the same characters that command accepts.
var THEME_NAME = /^[a-z0-9_][a-z0-9._+-]*$/

// Independent toggles, mirroring the flags omarchy-theme-browse takes. Dark and
// light contradict, so turning one on turns the other off.
var TOGGLES = [
  { key: "dark", label: "Dark" },
  { key: "light", label: "Light" },
  { key: "featured", label: "Featured" },
  { key: "onlyNew", label: "New" },
  { key: "installed", label: "Installed" }
]

function emptyFilters() {
  return { search: "", hue: "", dark: false, light: false, featured: false, onlyNew: false, installed: false }
}

function filtersFromPayload(payload) {
  var f = emptyFilters()
  if (!payload || typeof payload !== "object") return f

  f.search = String(payload.search || "")
  f.hue = String(payload.hue || "")
  f.dark = payload.dark === true
  f.light = payload.light === true
  f.featured = payload.featured === true
  f.onlyNew = payload.onlyNew === true
  f.installed = payload.installed === true
  return f
}

function toggleFilter(filters, key) {
  var next = {}
  for (var k in filters) next[k] = filters[k]

  next[key] = !next[key]
  if (key === "dark" && next.dark) next.light = false
  if (key === "light" && next.light) next.dark = false
  return next
}

function activeCount(filters) {
  var n = 0
  for (var i = 0; i < TOGGLES.length; i++) {
    if (filters[TOGGLES[i].key]) n++
  }
  if (filters.hue) n++
  return n
}

// The catalog says `slug` and `author`; the shell says name and artist.
function parseCatalog(raw) {
  var parsed
  try {
    parsed = JSON.parse(String(raw || ""))
  } catch (e) {
    return []
  }

  var themes = (parsed && parsed.themes) || []
  var out = []

  for (var i = 0; i < themes.length; i++) {
    var t = themes[i]
    if (!t || !THEME_NAME.test(String(t.slug || ""))) continue

    var colors = t.colors || {}
    var backgrounds = t.backgrounds || {}

    out.push({
      name: String(t.slug),
      title: String(t.name || t.slug),
      repo: String(t.repo || ""),
      artist: String(typeof t.author === "object" && t.author ? (t.author.login || "") : (t.author || "")),
      description: String(t.description || ""),
      license: String(t.license || ""),
      mode: String(t.mode || ""),
      hue: String(t.hue || ""),
      generation: String(t.generation || ""),
      stars: Number(t.stars || 0),
      addedAt: String(t.added_at || ""),
      commit: String(t.commit || ""),
      featured: t.featured === true,
      accent: String(t.accent || colors.accent || ""),
      background: String(t.background || colors.background || ""),
      palette: paletteOf(colors),
      backgroundCount: Number(backgrounds.count || 0),
      backgroundBytes: Number(backgrounds.total_bytes || 0),
      hasVideo: backgrounds.has_video === true,
      ignoredOnInstall: Array.isArray(t.ignored_on_install) ? t.ignored_on_install : [],
      warnings: Array.isArray(t.warnings) ? t.warnings : []
    })
  }

  return out
}

// Accent and the two grounds first, then the terminal hues in their usual order.
var PALETTE_KEYS = ["accent", "background", "foreground", "red", "yellow", "green", "cyan", "blue", "magenta"]

function paletteOf(colors) {
  var out = []
  for (var i = 0; i < PALETTE_KEYS.length; i++) {
    var value = colors[PALETTE_KEYS[i]]
    if (typeof value === "string" && value) out.push(value)
  }
  return out
}

function isNew(theme, today) {
  if (!theme.addedAt) return false
  var cutoff = new Date((today || new Date()).getTime() - NEW_WINDOW_DAYS * 86400000)
  return theme.addedAt >= cutoff.toISOString().slice(0, 10)
}

// A refresh is judged by whether the registry's build stamp moved, not by
// whether the list did.
function generatedAt(raw) {
  try {
    var parsed = JSON.parse(String(raw || ""))
    return String((parsed && parsed.generated_at) || "")
  } catch (e) {
    return ""
  }
}

function matches(theme, needle) {
  if (!needle) return true
  var haystack = (theme.title + " " + theme.name + " " + theme.artist + " " + theme.hue).toLowerCase()
  return haystack.indexOf(needle) !== -1
}

function passes(theme, filters, installed, today) {
  if (filters.dark && theme.mode !== "dark") return false
  if (filters.light && theme.mode !== "light") return false
  if (filters.featured && !theme.featured) return false
  if (filters.installed && !installed[theme.name]) return false
  if (filters.onlyNew && !isNew(theme, today)) return false
  if (filters.hue && theme.hue !== filters.hue) return false
  return true
}

// Featured first on an unsearched list; once someone is typing, plain
// alphabetical is easier to scan.
function filterThemes(themes, filters, installedNames, today) {
  var needle = String(filters.search || "").trim().toLowerCase()
  var installed = {}
  var list = installedNames || []
  var i

  for (i = 0; i < list.length; i++) installed[list[i]] = true

  var out = []
  for (i = 0; i < themes.length; i++) {
    if (!passes(themes[i], filters, installed, today)) continue
    if (!matches(themes[i], needle)) continue
    out.push(themes[i])
  }

  out.sort(function(a, b) {
    if (!needle && a.featured !== b.featured) return a.featured ? -1 : 1
    return a.title.toLowerCase() < b.title.toLowerCase() ? -1 : 1
  })

  return out
}

// Left and Right wrap around the list; Up and Down clamp, so Down on the last
// row stays put rather than jumping back to the top.
function movedIndex(index, count, delta, wrap) {
  if (count <= 0) return 0
  if (wrap) return (index + delta + count) % count
  var next = index + delta
  if (next < 0) return 0
  if (next >= count) return count - 1
  return next
}

function humanBytes(bytes) {
  if (!bytes) return ""
  var mb = bytes / 1048576
  if (mb < 1) return Math.round(bytes / 1024) + " KB"
  return (mb < 10 ? mb.toFixed(1) : Math.round(mb)) + " MB"
}

var WARNING_LABELS = {
  IGNORED_ON_INSTALL: "ships files Omarchy will not install",
  NON_THEME_PAYLOAD: "carries files that are neither colour nor art",
  VSCODE_EXTENSION: "names a VS Code extension, which is not installed",
  VSCODE_JSON_INVALID: "its vscode.json could not be read",
  PALETTE_PARTIAL: "palette is missing keys, which Omarchy derives",
  PALETTE_UNKNOWN_KEYS: "palette has keys Omarchy does not read",
  PALETTE_LEGACY: "palette comes from an alacritty.toml, not colors.toml",
  MODE_UNDECLARED: "no mode declared; inferred from the palette",
  MODE_MISMATCH: "declared mode disagrees with the palette",
  PREVIEW_ASPECT: "its preview is not the shape the switcher shows",
  BACKGROUNDS_LARGE: "backgrounds are large to download",
  BACKGROUND_HEAVY: "a single background is unusually large",
  BACKGROUND_VIDEO: "includes a video background",
  BACKGROUND_FILENAME: "a background is named in a way Omarchy may not order",
  BACKGROUND_SKIPPED: "a background was skipped as unreadable",
  ICONS_THEME_UNKNOWN: "names an icon theme this machine may not have",
  KEYBOARD_RGB_INVALID: "its keyboard.rgb could not be read",
  UNLOCK_PAIR: "ships only one half of the unlock images",
  NO_LICENSE_FILE: "no LICENSE file",
  REPO_NO_LICENSE: "no licence declared on the repository",
  REPO_NO_TOPIC: "the repository carries no omarchy-theme topic",
  NO_README: "no README"
}

function warningLabel(code) {
  return WARNING_LABELS[code] || String(code)
}

if (typeof module !== "undefined") {
  module.exports = {
    NEW_WINDOW_DAYS: NEW_WINDOW_DAYS,
    TOGGLES: TOGGLES,
    emptyFilters: emptyFilters,
    filtersFromPayload: filtersFromPayload,
    toggleFilter: toggleFilter,
    activeCount: activeCount,
    parseCatalog: parseCatalog,
    generatedAt: generatedAt,
    paletteOf: paletteOf,
    isNew: isNew,
    matches: matches,
    passes: passes,
    filterThemes: filterThemes,
    movedIndex: movedIndex,
    humanBytes: humanBytes,
    warningLabel: warningLabel
  }
}
