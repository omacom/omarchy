import QtQuick
import Quickshell.Io
import "Plural.js" as Plural

// Strings for a plugin that ships its own catalogs, following the language
// picked under Setup > Language the same way the shell's I18n does. Point it
// at a directory of flat JSON catalogs, one per registry code (en.json,
// da.json, pt-BR.json, ...):
//
//   Commons.Translations { id: strings; directory: Qt.resolvedUrl("i18n") }
//   Text { text: strings.t("panel.title") }
//   Text { text: strings.tn("panel.items", count).arg(Commons.I18n.formatNumber(count)) }
//
// A catalog value is a string, or an object of plural forms keyed by CLDR
// category ({"one": "%1 item", "other": "%1 items"}) for strings that count.
//
// A string missing from the current language falls back to its base
// language (pt-BR to pt), then to en.json, then to the key itself, so a
// plugin can ship English alone and gain languages one file at a time.
// Switching language re-renders bindings that call t() without a restart.
QtObject {
  id: root

  // A filesystem path or file:// URL (Qt.resolvedUrl("i18n") from the plugin).
  property var directory: ""

  readonly property string language: I18n.language
  readonly property string baseLanguage: language.split("-")[0]
  readonly property string directoryPath: String(directory).replace(/^file:\/\//, "").replace(/\/+$/, "")

  // Reassigned whole on every load (never mutated in place) so bindings that
  // called t() re-evaluate when the language or a catalog changes.
  property var strings: ({})
  property var englishStrings: ({})
  property var baseStrings: ({})
  property var languageStrings: ({})

  function t(key, fallback) {
    var value = root.strings[key]
    if (value && typeof value === "object") value = value.other
    if (typeof value === "string" && value.length > 0) return value
    return fallback !== undefined ? fallback : key
  }

  // The form of a plural entry for count, by the language's plural rules.
  // The layer that carries the entry decides which language's rules apply.
  function tn(key, count, fallback) {
    var layers = [[root.languageStrings, root.language], [root.baseStrings, root.baseLanguage], [root.englishStrings, "en"]]
    for (var i = 0; i < layers.length; i++) {
      var value = Plural.pick(layers[i][0][key], layers[i][1], count)
      if (typeof value === "string" && value.length > 0) return value
    }
    return fallback !== undefined ? fallback : key
  }

  function parseCatalog(raw) {
    try {
      var parsed = JSON.parse(raw || "{}")
      return (parsed && typeof parsed === "object" && !Array.isArray(parsed)) ? parsed : ({})
    } catch (e) {
      return ({})
    }
  }

  function rebuildStrings() {
    var merged = ({})
    var layers = [root.englishStrings, root.baseStrings, root.languageStrings]
    for (var i = 0; i < layers.length; i++)
      for (var key in layers[i])
        if (typeof layers[i][key] === "string" || (layers[i][key] && typeof layers[i][key] === "object")) merged[key] = layers[i][key]
    root.strings = merged
  }

  function catalogPath(code) {
    return root.directoryPath !== "" ? root.directoryPath + "/" + code + ".json" : ""
  }

  property FileView englishFile: FileView {
    path: root.catalogPath("en")
    watchChanges: true
    printErrors: false
    blockLoading: true
    onLoaded: { root.englishStrings = root.parseCatalog(text()); root.rebuildStrings() }
    onLoadFailed: { root.englishStrings = ({}); root.rebuildStrings() }
    onFileChanged: reload()
  }

  // Only read for a regional code; for "da" the language file covers it.
  property FileView baseFile: FileView {
    path: root.baseLanguage !== root.language && root.baseLanguage !== "en" ? root.catalogPath(root.baseLanguage) : ""
    watchChanges: true
    printErrors: false
    blockLoading: true
    onLoaded: { root.baseStrings = root.parseCatalog(text()); root.rebuildStrings() }
    onLoadFailed: { root.baseStrings = ({}); root.rebuildStrings() }
    onPathChanged: if (path === "") { root.baseStrings = ({}); root.rebuildStrings() }
    onFileChanged: reload()
  }

  property FileView languageFile: FileView {
    path: root.language !== "en" ? root.catalogPath(root.language) : ""
    watchChanges: true
    printErrors: false
    blockLoading: true
    onLoaded: { root.languageStrings = root.parseCatalog(text()); root.rebuildStrings() }
    onLoadFailed: { root.languageStrings = ({}); root.rebuildStrings() }
    onPathChanged: if (path === "") { root.languageStrings = ({}); root.rebuildStrings() }
    onFileChanged: reload()
  }
}
