import QtQuick
import qs.Commons
import qs.Commons as Commons

// Hosts explicitly opt into a named point. Extensions receive their own shell
// facade and settings, plus the panel's open state; never the owning panel.
FocusScope {
  id: root

  property var shell: null
  property string point: ""
  property bool panelOpen: false
  property color foreground: Commons.Color.foreground
  property string fontFamily: Style.font.family
  signal closeRequested()
  Keys.onEscapePressed: closeRequested()
  readonly property var entries: shell && typeof shell.panelExtensionsFor === "function"
    ? shell.panelExtensionsFor(point) : []

  // Keep delegates keyed by plugin id. Replacing the descriptor array on a
  // settings update must not destroy local edits or focused controls.
  ListModel { id: extensionModel }

  function syncExtensions() {
    if (!extensionModel) return
    var ids = root.entries.map(function(entry) { return entry.id })
    for (var i = extensionModel.count - 1; i >= 0; i--) {
      if (ids.indexOf(extensionModel.get(i).pluginId) === -1) extensionModel.remove(i)
    }
    for (var target = 0; target < ids.length; target++) {
      if (target < extensionModel.count && extensionModel.get(target).pluginId === ids[target]) continue
      var current = target + 1
      while (current < extensionModel.count && extensionModel.get(current).pluginId !== ids[target]) current++
      if (current < extensionModel.count) extensionModel.move(current, target, 1)
      else extensionModel.insert(target, { pluginId: ids[target] })
    }
  }

  onEntriesChanged: syncExtensions()
  Component.onCompleted: syncExtensions()

  implicitHeight: column.implicitHeight

  Column {
    id: column
    width: parent.width
    spacing: Style.space(14)

    Repeater {
      model: extensionModel

      Loader {
        id: extensionLoader
        required property string pluginId
        readonly property var entry: root.entries.find(function(candidate) {
          return candidate.id === extensionLoader.pluginId
        }) || null
        width: root.width
        source: entry ? entry.source : ""
        asynchronous: true
        height: status === Loader.Ready && item !== null ? item.implicitHeight : 0
        clip: true
        // Keep positioners visible for natural sizing, but contain children
        // when the extension reduces its requested height, including to zero.

        onLoaded: {
          if (!item) return
          item.width = Qt.binding(function() { return extensionLoader.width })
          if ("panelOpen" in item) item.panelOpen = Qt.binding(function() { return root.panelOpen })
          if ("foreground" in item) item.foreground = Qt.binding(function() { return root.foreground })
          if ("fontFamily" in item) item.fontFamily = Qt.binding(function() { return root.fontFamily })
          if ("settings" in item) item.settings = Qt.binding(function() { return extensionLoader.entry ? extensionLoader.entry.settings : ({}) })
          root.shell.configurePanelExtension(item, pluginId)
        }
        onStatusChanged: if (status === Loader.Error)
          console.warn("Panel extension failed to load:", pluginId, source)
      }
    }
  }
}
