pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "Plural.js" as Plural
import "Numbers.js" as Numbers
import "I18nModel.js" as Model
import "I18nSystem.js" as System

// Display-language strings for the shell. The selected code lives in
// ~/.config/omarchy/language (omarchy-language owns it); a missing file
// means English. Strings come from default/i18n/<code>/shell.json layered
// over the English catalog, so a missing translation falls back to English
// per string. Use as I18n.t("common.search"), with .arg(...) for %1 holes,
// and I18n.tn(key, count).arg(I18n.formatNumber(count)) for an
// entry with plural forms.
// The language file is watched, so switching language under Setup
// re-renders the shell without a restart.
//
// Runtime translation by English source string (tr, trc, ntr) is the
// second half of this file, for text the shell does not own: labels a
// plugin hands to the Ui kit. Button, Toggle, PanelToolTip, PanelHero and
// PanelActionButton wrap their label bindings in I18n.tr(), so a plugin
// built on qs.Ui translates without changes to its source. Sources, lowest
// to highest precedence:
//   1. Startup snapshot: the merge from the previous session, read
//      synchronously so the first frame is already translated
//   2. System gettext catalogs (gtk30, gtk40, glib20, ...) read through
//      msgunfmt for the picked language: the common desktop vocabulary
//   3. A plugin's own i18n.json, registered by shell.qml, for the strings
//      the system catalogs do not cover
// All lookup logic lives in I18nModel.js and I18nSystem.js, which the Node
// tests in test/shell.d/i18n-runtime-test.sh load directly. English has
// no candidates, so with English picked every tr() returns its source.
QtObject {
  id: root

  readonly property string omarchyPath: Quickshell.env("OMARCHY_PATH")
  readonly property string configHome: Quickshell.env("XDG_CONFIG_HOME") || (Quickshell.env("HOME") + "/.config")

  readonly property string language: languageCode(languageFile.text())
  readonly property var localeSettings: parseCatalog(registryFile.text())[root.language] || ({})
  readonly property string formatLocale: localeSettings.formatLocale || "en-US"
  // From the registry: how numbers are written and which way text runs.
  readonly property string decimal: localeSettings.decimal || "."
  readonly property string zeroDigit: localeSettings.zeroDigit || "0"
  readonly property bool rightToLeft: localeSettings.direction === "rtl"

  // Reading text() makes blockLoading take effect on the first lookup.
  // These bindings also rebuild the maps when a watched catalog changes.
  readonly property var englishStrings: parseCatalog(englishCatalogFile.text())
  readonly property var languageStrings: parseCatalog(languageCatalogFile.text())
  readonly property var strings: {
    var merged = ({})
    for (var k in root.englishStrings) merged[k] = root.englishStrings[k]
    for (var k2 in root.languageStrings) merged[k2] = root.languageStrings[k2]
    return merged
  }

  // The optional fallback is what imperative callers (the JS models) pass
  // as their English text: for a key the catalogs do not carry, they keep
  // sensible English instead of a raw key.
  function t(key, fallback) {
    var value = root.strings[key]
    if (value && typeof value === "object") value = value.other
    if (typeof value === "string" && value.length > 0) return value
    return fallback !== undefined ? fallback : key
  }

  // The form of a plural entry for count, by the language's plural rules
  // (Plural.js). The English entry answers when the translation has none.
  function tn(key, count, fallback) {
    var value = Plural.pick(root.languageStrings[key], root.language, count)
    if (typeof value !== "string" || value.length === 0) value = Plural.pick(root.englishStrings[key], "en", count)
    if (typeof value === "string" && value.length > 0) return value
    return fallback !== undefined ? fallback : key
  }

  // A number with the language's decimal separator and digits, ungrouped:
  // formatNumber(13.14, 1) is "13,1" in Danish. Pass decimals to round;
  // without them the value is written as it is.
  function formatNumber(value, decimals) {
    return Numbers.format(value, decimals, root.decimal, root.zeroDigit)
  }

  function parseCatalog(raw) {
    try {
      var parsed = JSON.parse(raw || "{}")
      return (parsed && typeof parsed === "object" && !Array.isArray(parsed)) ? parsed : ({})
    } catch (e) {
      return ({})
    }
  }

  function languageCode(raw) {
    var code = String(raw || "").trim()
    if (!/^[a-z]{2,3}(-[A-Za-z]{2})?$/.test(code)) code = "en"
    return code
  }

  // The catalogs are small local files, read synchronously so the first
  // binding to call t() already gets the string rather than the raw key.
  property FileView languageFile: FileView {
    // OMARCHY_LANGUAGE_FILE overrides the location, as it does for
    // omarchy-i18n, so tests can pin a language whatever the machine uses.
    path: Quickshell.env("OMARCHY_LANGUAGE_FILE") || (root.configHome + "/omarchy/language")
    watchChanges: true
    printErrors: false
    blockLoading: true
    onFileChanged: reload()
  }

  property FileView englishCatalogFile: FileView {
    path: root.omarchyPath + "/default/i18n/en/shell.json"
    watchChanges: true
    printErrors: false
    blockLoading: true
    onFileChanged: reload()
  }

  property FileView languageCatalogFile: FileView {
    path: root.omarchyPath + "/default/i18n/" + root.language + "/shell.json"
    watchChanges: true
    printErrors: false
    blockLoading: true
    onFileChanged: reload()
  }

  property FileView registryFile: FileView {
    path: root.omarchyPath + "/default/i18n/locales.json"
    watchChanges: true
    printErrors: false
    blockLoading: true
    onFileChanged: reload()
  }

  // ---------------------------------------------------------------------
  // Runtime translation by source string

  // gettext locale names for the picked language, most preferred first:
  // ["pt_BR", "pt"], ["nb_NO", "nb"]. Empty for English.
  readonly property var candidates: Model.languageCandidates(root.language, root.localeSettings.locale)
  readonly property string candidatesKey: candidates.join(" ")

  // Bumped on every registry change. Read inside every lookup so bindings
  // that call tr() depend on it and repaint when catalogs change.
  property int revision: 0
  property var _registry: Model.createRegistry()

  function _lookup(source, options) {
    void root.revision
    return root._registry.translate(source, options)
  }

  function _lookupPlural(count, singular, plural, options) {
    void root.revision
    return root._registry.translatePlural(count, singular, plural, options)
  }

  // I18n.tr("Connect"), I18n.trc("verb", "Open"),
  // I18n.ntr(n, "%1 city", "%1 cities", [n]). %1-style args are filled in
  // one pass, so an argument holding "%2" is inserted verbatim.
  function tr(source, args) {
    return _lookup(source, { args: args })
  }

  function trc(context, source, args) {
    return _lookup(source, { context: context, args: args })
  }

  function ntr(count, singular, plural, args) {
    return _lookupPlural(count, singular, plural, { args: args })
  }

  // Marks a string for extraction without translating it, for strings
  // defined away from where they are shown (a model returning a status).
  function noop(source) {
    return source
  }

  // A translator bound to one domain: lookups walk the domain, its linked
  // parents, then the global merge.
  function domain(id) {
    var d = String(id === undefined || id === null ? "" : id)
    return {
      id: d,
      tr: function(source, args) {
        return root._lookup(source, { domain: d, args: args })
      },
      trc: function(context, source, args) {
        return root._lookup(source, { domain: d, context: context, args: args })
      },
      ntr: function(count, singular, plural, args) {
        return root._lookupPlural(count, singular, plural, { domain: d, args: args })
      },
      noop: function(source) { return source }
    }
  }

  // Replace an owner's whole contribution atomically.
  //   catalogs  { domain: catalog }   one po2json-shaped object per domain
  //   options   { links: { childDomain: parentDomain }, precedence: int }
  function setCatalogs(ownerId, catalogs, options) {
    var result = root._registry.setCatalogs(String(ownerId), catalogs, options)
    root._changed()
    return result
  }

  // Register an i18n.json-shaped object ({ "<locale>": catalog }) under one
  // domain: every catalog matching a candidate, in preference order, so a
  // string missing from es_MX falls back to es. Returns how many locales
  // were registered; with none, the owner's earlier catalogs are cleared.
  function setLocaleCatalogs(ownerId, domainId, byLocale, precedence) {
    var list = Model.selectLocaleCatalogs(byLocale, root.candidates)
    var count = root._registry.setLocaleCatalogs(String(ownerId), String(domainId), list, { precedence: precedence })
    root._changed()
    return count
  }

  function clearCatalogs(ownerId) {
    var removed = root._registry.clearOwner(String(ownerId))
    if (removed) root._changed()
    return removed
  }

  // Once every live source has had its chance (the plugin scan finished),
  // drop cached domains no source will refresh: a plugin removed or
  // disabled since the snapshot was written.
  function settleCache(keepDomains) {
    if (root._registry.settleCache(keepDomains)) root._changed()
  }

  function _changed() {
    root.revision++
    root.cacheWriteTimer.restart()
  }

  // ---------------------------------------------------------------------
  // System gettext catalogs
  //
  // One msgunfmt run per language: every candidate locale that ships any
  // of the desktop domains becomes its own layer under "omarchy.system",
  // precedence 200 and down, below a plugin's i18n.json (100) so an author
  // can still override a string. Re-run when the language changes.

  readonly property string systemDomain: "omarchy.system"

  function _reloadSystemCatalogs() {
    root.systemCatalogProcess.running = false
    var command = System.catalogCommand(root.candidates)
    if (command.length === 0) return
    root.systemCatalogProcess.command = command
    // Started on the next tick so a run stopped above has exited first;
    // its late reply carries the old request and is dropped.
    Qt.callLater(function() { root.systemCatalogProcess.running = true })
  }

  function _systemCatalogsLoaded(output) {
    var result = System.buildLocaleCatalogs(output)
    // A reply for a language that is no longer picked.
    if (result.request === null || result.request !== System.requestKey(root.candidates)) return
    if (result.catalogs.length === 0) {
      root.clearCatalogs("system:gettext")
      if (root._registry.retireCached([root.systemDomain])) root._changed()
      return
    }
    var entries = 0
    for (var i = 0; i < result.catalogs.length; i++) entries += result.catalogs[i].entries
    console.log("I18n: system gettext catalogs for " + root.candidatesKey + " (" + entries + " entries)")
    root._registry.setLocaleCatalogs("system:gettext", root.systemDomain, result.catalogs, { precedence: 200 })
    root._changed()
  }

  // The reply is read when stdout ends, not on exit: the collector can
  // finish after the process has exited. A run that finds no catalog still
  // prints its request line, which settles the cached system domain.
  property Process systemCatalogProcess: Process {
    running: false
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root._systemCatalogsLoaded(text || "")
    }
  }

  // ---------------------------------------------------------------------
  // Startup snapshot, per language: $XDG_CACHE_HOME/omarchy/i18n/<code>.json

  readonly property string cacheDir: {
    var xdg = Quickshell.env("XDG_CACHE_HOME")
    var base = xdg ? String(xdg) : String(Quickshell.env("HOME")) + "/.cache"
    return base.replace(/\/$/, "") + "/omarchy/i18n"
  }
  // Set by _applyLanguage rather than bound: a binding here could still
  // hold the previous language when candidatesKeyChanged runs, and the
  // snapshot would then be read from, and written to, the wrong file.
  property string cachePath: ""

  // The path is set by _applyLanguage, which then reads the file itself:
  // blockLoading makes text() synchronous, so the snapshot is in place
  // before the first frame, and always lands in the registry for the
  // language it belongs to. A missing file reads as empty: English until a
  // source registers.
  property FileView cacheFile: FileView {
    blockLoading: true
    atomicWrites: true
    printErrors: false
  }

  function _loadCache(raw) {
    var text = String(raw || "").trim()
    if (!text) return
    try {
      if (root._registry.loadSnapshot(JSON.parse(text))) root.revision++
    } catch (error) {
      console.warn("I18n: ignoring unreadable cache at " + root.cachePath + ": " + error)
    }
  }

  // Registrations arrive in bursts (one per plugin, a rescan); coalesce
  // them into one write.
  property Timer cacheWriteTimer: Timer {
    interval: 250
    repeat: false
    onTriggered: root._writeCache()
  }

  function _writeCache() {
    if (!root.cachePath) return
    root.cacheFile.setText(JSON.stringify(root._registry.snapshot()) + "\n")
  }

  // Runs at startup and on every language switch. A switch starts a fresh
  // registry, since the old language's catalogs and snapshot no longer
  // apply; shell.qml re-registers plugin catalogs on candidatesKeyChanged.
  property bool _applied: false

  function _applyLanguage() {
    root.cacheWriteTimer.stop()
    if (root._applied) {
      root._registry = Model.createRegistry()
      root.revision++
    }
    root._applied = true
    root.cachePath = root.candidates.length > 0 ? root.cacheDir + "/" + root.language + ".json" : ""
    if (root.cacheFile.path !== root.cachePath) root.cacheFile.path = root.cachePath
    else if (root.cachePath) root.cacheFile.reload()
    if (root.cachePath) root._loadCache(root.cacheFile.text())
    root._reloadSystemCatalogs()
  }

  onCandidatesKeyChanged: if (root._applied) root._applyLanguage()

  Component.onCompleted: root._applyLanguage()
}
