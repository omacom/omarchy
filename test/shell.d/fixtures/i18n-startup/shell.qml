import QtQuick
import Quickshell
import Quickshell.Io
import "Commons" as Commons

ShellRoot {
  id: root

  // Remember the first binding evaluation, even if a later file load repairs it.
  property var first: ({})
  function remember(key, value) {
    if (root.first[key] === undefined) root.first[key] = value
    return value
  }

  property string language: remember("language", Commons.I18n.language)
  property string locale: remember("locale", Commons.I18n.formatLocale)
  property string number: remember("number", Commons.I18n.formatNumber(13.5, 1))
  property bool rtl: remember("rtl", Commons.I18n.rightToLeft)
  property string shellText: remember("shellText", Commons.I18n.t("test.hello").arg("Ada"))
  property string shellPlural: remember("shellPlural", Commons.I18n.tn("test.items", 2).arg(Commons.I18n.formatNumber(2)))
  property string shellFallback: remember("shellFallback", Commons.I18n.t("test.englishOnly", "missing English"))
  property string unknown: remember("unknown", Commons.I18n.t("test.unknown", "explicit fallback"))
  property string unknownPlural: remember("unknownPlural", Commons.I18n.tn("test.unknown", 2, "plural fallback"))
  property string pluginText: remember("pluginText", strings.t("test.hello").arg("Ada"))
  property string pluginPlural: remember("pluginPlural", strings.tn("test.items", 2).arg(Commons.I18n.formatNumber(2)))
  property string pluginBase: remember("pluginBase", strings.t("test.baseOnly"))
  property string pluginFallback: remember("pluginFallback", strings.t("test.englishOnly"))
  property string pluginUnknown: remember("pluginUnknown", strings.t("test.unknown", "plugin fallback"))

  function snapshot() {
    return {
      language: language, locale: locale, number: number, rtl: rtl,
      shellText: shellText, shellPlural: shellPlural, shellFallback: shellFallback,
      unknown: unknown, unknownPlural: unknownPlural,
      pluginText: pluginText, pluginPlural: pluginPlural, pluginBase: pluginBase,
      pluginFallback: pluginFallback, pluginUnknown: pluginUnknown
    }
  }

  function report() {
    result.setText(JSON.stringify({first: root.first, current: snapshot()}))
  }

  onLanguageChanged: Qt.callLater(report)
  onLocaleChanged: Qt.callLater(report)
  onNumberChanged: Qt.callLater(report)
  onRtlChanged: Qt.callLater(report)
  onShellTextChanged: Qt.callLater(report)
  onShellPluralChanged: Qt.callLater(report)
  onShellFallbackChanged: Qt.callLater(report)
  onPluginTextChanged: Qt.callLater(report)
  onPluginPluralChanged: Qt.callLater(report)
  onPluginBaseChanged: Qt.callLater(report)
  onPluginFallbackChanged: Qt.callLater(report)
  Component.onCompleted: report()

  Commons.Translations {
    id: strings
    directory: pluginDirectory.text().trim()
  }

  FileView {
    id: pluginDirectory
    path: Quickshell.env("OMARCHY_TEST_PLUGIN_DIRECTORY")
    blockLoading: true
    watchChanges: true
    onFileChanged: reload()
  }

  FileView {
    id: result
    path: Quickshell.env("OMARCHY_TEST_RESULT")
    preload: false
    printErrors: false
    blockWrites: true
  }
}
