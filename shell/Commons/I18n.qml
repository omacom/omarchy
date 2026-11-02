pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "Plural.js" as Plural
import "Numbers.js" as Numbers

// Display-language strings for the shell. The selected code lives in
// ~/.config/omarchy/language (omarchy-language owns it); a missing file
// means English. Strings come from default/i18n/<code>/shell.json layered
// over the English catalog, so a missing translation falls back to English
// per string. Use as I18n.t("common.search"), with .arg(...) for %1 holes,
// and I18n.tn(key, count).arg(I18n.formatNumber(count)) for an
// entry with plural forms.
// The language file is watched, so switching language under Setup
// re-renders the shell without a restart.
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
}
