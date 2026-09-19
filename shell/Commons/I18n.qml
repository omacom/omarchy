pragma Singleton
import QtQuick
import Quickshell
import "I18nModel.js" as Model
import "i18n/zh_CN.js" as ZhCN

QtObject {
  id: root

  readonly property var candidates: Model.localeCandidates({
    OMARCHY_UI_LANGUAGE: Quickshell.env("OMARCHY_UI_LANGUAGE"),
    LANGUAGE: Quickshell.env("LANGUAGE"),
    LC_ALL: Quickshell.env("LC_ALL"),
    LC_MESSAGES: Quickshell.env("LC_MESSAGES"),
    LANG: Quickshell.env("LANG")
  })

  readonly property string language: candidates.length > 0 ? candidates[0].split("_")[0] : "en"
  readonly property string activeLocale: _registry.resolveLocale(candidates)
  readonly property bool isSimplifiedChinese: activeLocale === "zh_CN" || activeLocale === "zh_SG" || activeLocale === "zh_Hans"

  property var _registry: {
    var reg = Model.createRegistry()
    reg.registerCatalog("zh_CN", ZhCN.catalog, ["zh_SG", "zh_Hans"])
    return reg
  }

  function tr(source, args) {
    return root._registry.translate(source, { candidates: root.candidates, args: args })
  }

  function trc(context, source, args) {
    return root._registry.translate(source, { context: context, candidates: root.candidates, args: args })
  }

  function translate(source) {
    return tr(source)
  }
}
