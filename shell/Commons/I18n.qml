pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "I18nModel.js" as Model

QtObject {
  id: root

  readonly property string locale: Model.catalogLocale({
    LC_ALL: Quickshell.env("LC_ALL"),
    LC_MESSAGES: Quickshell.env("LC_MESSAGES"),
    LANG: Quickshell.env("LANG"),
    LANGUAGE: Quickshell.env("LANGUAGE")
  })
  property var catalog: ({})

  Component.onCompleted: {
    if (locale) catalog = Model.parseCatalog(catalogFile.text())
  }

  function tr(source, args) {
    return Model.translate(catalog, source, args)
  }

  function menuItems(items) {
    return Model.localizeMenu(items, catalog)
  }

  // A single known catalog path, with synchronous initial loading. Missing or
  // invalid data falls back to the source text without chained failed reads.
  property FileView catalogFile: FileView {
    path: root.locale ? Quickshell.env("OMARCHY_PATH") + "/shell/translations/" + root.locale + ".json" : ""
    blockLoading: true
    watchChanges: true
    onFileChanged: reload()
    onLoaded: root.catalog = Model.parseCatalog(text())
    onLoadFailed: root.catalog = ({})
  }
}
