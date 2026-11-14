// I18nSystem.js — system gettext catalogs as an Omarchy translation source.
//
// Linux distributions already ship translations for the common UI vocabulary
// ("Save", "Open", "Close", …) in /usr/share/locale/<locale>/LC_MESSAGES/*.mo.
// This module turns the PO text produced by `msgunfmt` into the po2json-shaped
// catalog the I18n registry understands, so the shell uses those translations
// by default. Plugin authors only ship an i18n.json for strings the system
// catalogs do not cover.
//
// No Qt or QML dependencies: QML loads it with `import "I18nSystem.js" as
// System`, tests require it under node. The Qt-side Process that runs
// msgunfmt lives in I18n.qml.
//
// Catalog build rules:
//   - fuzzy and untranslated entries (every form empty) are dropped
//   - GTK/Qt accelerator markers are normalized: "_Save" and "&Save" also
//     register under "Save" (plain keys win when both exist)
//   - the first domain wins on conflicts; later domains only fill gaps
//   - the gettext header (plural rules) of the first domain is kept

"use strict"

// ---------------------------------------------------------------------------
// Minimal PO reader (msgunfmt output): msgctxt, msgid, msgid_plural,
// msgstr[n], multi-line strings, flags.

function parsePoEntries(text) {
  var entries = []
  var cur = null
  var target = null // "msgid" | "msgid_plural" | "msgctxt" | "msgstr" | "msgstr[n]"

  function flush() {
    if (cur && (cur.msgid !== "" || cur.msgctxt !== null || cur.msgstr.length > 0)) {
      if (!cur.obsolete) entries.push(cur)
    }
    cur = null
  }

  function unescape(s) {
    return s.replace(/\\(n|t|r|"|\\)/g, function(_, c) {
      return { n: "\n", t: "\t", r: "\r", '"': '"', "\\": "\\" }[c]
    })
  }

  var lines = String(text || "").replace(/\r\n/g, "\n").split("\n")
  var pendingFlags = []
  for (var i = 0; i < lines.length; i++) {
    var line = lines[i]

    if (line.indexOf("#~") === 0) { if (cur) cur.obsolete = true; continue }
    if (line.indexOf("#") === 0) {
      // Comments (incl. flags) always precede the entry they describe:
      // finish any pending entry so flags never leak into the previous one.
      flush()
      if (line.indexOf("#,") === 0) {
        var flagParts = line.slice(2).trim().split(/\s*,\s*/)
        for (var fp = 0; fp < flagParts.length; fp++) {
          if (flagParts[fp]) pendingFlags.push(flagParts[fp])
        }
      }
      continue
    }

    function makeEntry() {
      var e = { msgctxt: null, msgid: "", msgid_plural: null, msgstr: [], flags: [], obsolete: false }
      for (var pf = 0; pf < pendingFlags.length; pf++) e.flags.push(pendingFlags[pf])
      pendingFlags = []
      return e
    }

    var m
    if ((m = line.match(/^msgctxt\s+"(.*)"\s*$/))) {
      flush()
      cur = makeEntry()
      cur.msgctxt = unescape(m[1])
      target = "msgctxt"
    } else if ((m = line.match(/^msgid\s+"(.*)"\s*$/))) {
      if (!cur || cur.msgid !== "" || cur.msgctxt === null) {
        flush()
        cur = makeEntry()
        cur.msgid = unescape(m[1])
      } else {
        cur.msgid = unescape(m[1])
      }
      target = "msgid"
    } else if ((m = line.match(/^msgid_plural\s+"(.*)"\s*$/))) {
      if (cur) { cur.msgid_plural = unescape(m[1]); target = "msgid_plural" }
    } else if ((m = line.match(/^msgstr\[(\d+)\]\s+"(.*)"\s*$/))) {
      if (cur) { cur.msgstr[Number(m[1])] = unescape(m[2]); target = "msgstr[" + m[1] + "]" }
    } else if ((m = line.match(/^msgstr\s+"(.*)"\s*$/))) {
      if (cur) { cur.msgstr[0] = unescape(m[1]); target = "msgstr[0]" }
    } else if ((m = line.match(/^"(.*)"\s*$/))) {
      if (cur && target) {
        var value = unescape(m[1])
        if (target === "msgid") cur.msgid += value
        else if (target === "msgid_plural") cur.msgid_plural += value
        else if (target === "msgctxt") cur.msgctxt += value
        else if (target.slice(0, 6) === "msgstr") cur.msgstr[Number(target.slice(7, -1))] += value
      }
    }
  }
  flush()
  return entries
}

// ---------------------------------------------------------------------------
// Accelerator normalization. GTK marks mnemonics with an underscore anywhere
// in the string ("_Save", "Sa_ve"); Qt/KDE prefix an ampersand ("&Save").
// The translated string keeps its own marker — only the lookup key changes.

function stripAccelerators(msgid) {
  var s = String(msgid)
  if (s.charAt(0) === "&") s = s.slice(1)
  return s.split("_").join("")
}

// ---------------------------------------------------------------------------
// Catalog builder. texts is an array of PO document strings (one per system
// domain, most preferred first). Returns the po2json-shaped catalog.

function buildCatalog(texts) {
  var catalog = {}
  var headerDone = false

  for (var t = 0; t < texts.length; t++) {
    var entries = parsePoEntries(texts[t])
    for (var i = 0; i < entries.length; i++) {
      var e = entries[i]
      if (e.msgctxt) continue // contextual entries are not reachable via tr()
      if (e.flags.indexOf("fuzzy") !== -1) continue
      if (e.msgid === "") {
        // Gettext header: keep the first one (plural rules, language).
        if (!headerDone && e.msgstr[0]) {
          var header = {}
          e.msgstr[0].split("\n").forEach(function(row) {
            var idx = row.indexOf(": ")
            if (idx > 0) header[row.slice(0, idx)] = row.slice(idx + 2)
          })
          if (header["Content-Type"]) delete header["Content-Type"]
          catalog[""] = header
          headerDone = true
        }
        continue
      }
      var translated = false
      for (var f = 0; f < e.msgstr.length; f++) if (e.msgstr[f]) translated = true
      if (!translated) continue

      if (e.msgid_plural) {
        var forms = []
        for (var k = 0; k < e.msgstr.length; k++) forms.push(e.msgstr[k] || "")
        if (catalog[e.msgid] === undefined) catalog[e.msgid] = { msgid_plural: e.msgid_plural, msgstr: forms }
        // Plain variant without accelerators, on both msgid and msgstr:
        // "Pane" must yield "Panel"/"Paneles", not accelerator-marked text.
        var plainP = stripAccelerators(e.msgid)
        if (plainP !== e.msgid && plainP && catalog[plainP] === undefined) {
          catalog[plainP] = {
            msgid_plural: stripAccelerators(e.msgid_plural),
            msgstr: forms.map(function(s) { return stripAccelerators(s) })
          }
        }
      } else {
        var value = e.msgstr[0]
        if (catalog[e.msgid] === undefined) catalog[e.msgid] = value
        // Plain variant: "Save" must yield "Guardar", not "_Guardar" — the
        // mnemonic marker lives in both the msgid and the msgstr.
        var plain = stripAccelerators(e.msgid)
        if (plain !== e.msgid && plain && catalog[plain] === undefined) {
          var plainValue = stripAccelerators(value)
          if (plainValue) catalog[plain] = plainValue
        }
      }
    }
  }

  if (!headerDone) delete catalog[""]
  return catalog
}

// ---------------------------------------------------------------------------
// The msgunfmt run. One bash process walks every candidate locale in
// preference order and prints each locale's domains as one PO document
// behind a marker line, so the registry can fall back per string from a
// partial regional catalog (es_MX) to the language (es) and on down a
// LANGUAGE list. Locales are passed as arguments, never spliced into the
// script. The first line echoes the request so a reply that arrives after
// the language changed can be recognized and dropped. Exits 1 when no
// locale had any catalog.

var REQUEST_MARKER = "X-OMARCHY-SYSTEM-REQUEST: "
var LOCALE_MARKER = "X-OMARCHY-SYSTEM-LOCALE: "
var DOMAINS = ["gtk30", "gtk40", "glib20", "gdk-pixbuf", "gnome-desktop-3.0"]

function catalogCommand(candidates, localeDir) {
  var locales = []
  var list = Array.isArray(candidates) ? candidates : []
  for (var i = 0; i < list.length; i++) {
    // /usr/share/locale directories never carry an encoding suffix.
    var bare = String(list[i]).replace(/\..*$/, "")
    if (/^[a-z]{2,3}(_[A-Z]{2}|_[0-9]{3})?$/.test(bare) && locales.indexOf(bare) === -1) locales.push(bare)
  }
  if (locales.length === 0) return []
  var script = ""
    + "dir=$1; shift\n"
    + "domains=(" + DOMAINS.join(" ") + ")\n"
    + "printf '" + REQUEST_MARKER + "%s\\n' \"$*\"\n"
    + "found=0\n"
    + "for loc in \"$@\"; do\n"
    + "  files=()\n"
    + "  for d in \"${domains[@]}\"; do\n"
    + "    f=\"$dir/$loc/LC_MESSAGES/$d.mo\"\n"
    + "    [[ -f $f ]] && files+=(\"$f\")\n"
    + "  done\n"
    + "  (( ${#files[@]} )) || continue\n"
    + "  printf '" + LOCALE_MARKER + "%s\\n' \"$loc\"\n"
    + "  msgunfmt --no-wrap \"${files[@]}\" && found=1\n"
    + "done\n"
    + "(( found ))\n"
  return ["bash", "-c", script, "bash", String(localeDir || "/usr/share/locale")].concat(locales)
}

function requestKey(candidates) {
  var command = catalogCommand(candidates)
  return command.slice(5).join(" ")
}

// Splits the command's output into { request, sections: [{ locale, text }] }.
function parseCatalogOutput(output) {
  var lines = String(output || "").replace(/\r\n/g, "\n").split("\n")
  var result = { request: null, sections: [] }
  var current = null
  for (var i = 0; i < lines.length; i++) {
    var line = lines[i]
    if (result.request === null && line.indexOf(REQUEST_MARKER) === 0) {
      result.request = line.slice(REQUEST_MARKER.length)
      continue
    }
    if (line.indexOf(LOCALE_MARKER) === 0) {
      current = { locale: line.slice(LOCALE_MARKER.length), lines: [] }
      result.sections.push(current)
      continue
    }
    if (current) current.lines.push(line)
  }
  for (var s = 0; s < result.sections.length; s++) {
    result.sections[s] = { locale: result.sections[s].locale, text: result.sections[s].lines.join("\n") }
  }
  return result
}

// One catalog per locale section, most preferred first, ready for
// registry.setLocaleCatalogs. Sections that yield nothing are dropped.
function buildLocaleCatalogs(output) {
  var parsed = parseCatalogOutput(output)
  var list = []
  for (var i = 0; i < parsed.sections.length; i++) {
    var catalog = buildCatalog([parsed.sections[i].text])
    var entries = Object.keys(catalog).length - (catalog[""] ? 1 : 0)
    if (entries > 0) list.push({ locale: parsed.sections[i].locale, catalog: catalog, entries: entries })
  }
  return { request: parsed.request, catalogs: list }
}

var api = {
  DOMAINS: DOMAINS,
  parsePoEntries: parsePoEntries,
  stripAccelerators: stripAccelerators,
  buildCatalog: buildCatalog,
  catalogCommand: catalogCommand,
  requestKey: requestKey,
  parseCatalogOutput: parseCatalogOutput,
  buildLocaleCatalogs: buildLocaleCatalogs
}

if (typeof module !== "undefined" && module.exports) module.exports = api
