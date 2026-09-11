import QtQuick
import Quickshell
import Quickshell.Io
import "ApiCost.js" as ApiCost

// Owns only the user-editable pricing file. Catalog validation, tariff
// resolution, arithmetic and display formatting live in the public JS module
// that both this QML consumer and the Node behavior tests import.
Item {
  id: root
  visible: false

  readonly property string home: Quickshell.env("HOME") || ""
  readonly property string overridePath:
    (Quickshell.env("XDG_CONFIG_HOME") || home + "/.config") + "/omarchy/agents/pricing.json"

  property var overrides: ApiCost.parseOverrides("")
  property int revision: 0
  property string overrideState: JSON.stringify(overrides)
  property bool active: false
  property bool overrideAvailable: false
  property var presentationCache: ApiCost.createPresentationCache()

  onActiveChanged: if (active) overrideFile.reload()

  FileView {
    id: overrideFile
    path: root.overridePath
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: {
      root.overrideAvailable = true
      root.applyOverrides(text())
    }
    onLoadFailed: {
      root.overrideAvailable = false
      root.applyOverrides("")
    }
  }

  // FileView watches edits and removal once the file exists. While the panel is
  // open, retry a missing file so a first-time pricing.json is noticed too.
  Timer {
    interval: 3000
    running: root.active && !root.overrideAvailable
    repeat: true
    onTriggered: overrideFile.reload()
  }

  function applyOverrides(content) {
    var parsed = ApiCost.parseOverrides(String(content || ""))
    var state = JSON.stringify(parsed)
    if (state === overrideState) return
    overrides = parsed
    overrideState = state
    revision++
    if (parsed.errors && parsed.errors.length > 0)
      console.warn("agents", "Pricing override warnings:", parsed.errors.join("; "))
  }

  function dailyRows(provider, nowMs) {
    var rev = revision
    if (!provider) return []
    return ApiCost.cachedDailyRows(presentationCache, provider, nowMs, overrides, rev)
  }

  function dailyHeading(provider, rows) {
    return ApiCost.dailyHeading(provider ? provider.providerId : "", rows)
  }

  function dailyTooltipDetails(row) { return ApiCost.dailyTooltipDetails(row) }
  function dailyTooltip(row) { return ApiCost.dailyTooltip(row) }

  function modelWindowPresentation(provider, nowMs) {
    var rev = revision
    if (!provider) return ({ models: [], summaries: [] })
    return ApiCost.cachedModelWindowPresentation(presentationCache, provider, nowMs, overrides, rev)
  }
}
