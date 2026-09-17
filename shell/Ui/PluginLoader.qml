import QtQuick

// setSource supplies required properties before Component.onCompleted runs.
Loader {
  id: root
  property string entryUrl: ""
  property var runtime: null
  property var initialProperties: ({})
  property var prepare: null
  property bool ready: false
  property var entryRuntime: null

  function loadEntry() {
    if (!ready) return
    setSource("")
    if (entryRuntime) { entryRuntime.destroy(); entryRuntime = null }
    if (!active || !entryUrl) return
    const properties = Object.assign({}, prepare ? prepare() : initialProperties)
    const provider = properties.runtime || runtime
    if (provider) {
      entryRuntime = provider.scope(root)
      if (!entryRuntime) { console.error("Could not create plugin runtime"); return }
      properties.runtime = entryRuntime
    }
    setSource(entryUrl, properties)
  }
  onEntryUrlChanged: loadEntry()
  onRuntimeChanged: loadEntry()
  onActiveChanged: loadEntry()
  Component.onCompleted: { ready = true; loadEntry() }
}
