import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Commons
import qs.Ui
import "Services"
import "Ward/RequestFeedback.js" as RequestFeedback

// Evaluated only inside the restricted worker, never by the desktop shell.
ShellRoot {
  id: root
  property var manifest: null
  property var context: null
  property var grants: null
  property bool loaded: false
  property string pendingSettings: ""
  property string requestError: ""
  property var views: []
  property var activeView: null
  readonly property var api: shellApi
  readonly property var panel: overlayLoader.item || (activeView ? activeView.item : null)
  readonly property bool opened: panel && panel.opened === true
  property int panelSerial: 0
  property string sentPanelState: ""
  readonly property string panelState: panelSerial + ":" + opened
  onPanelStateChanged: Qt.callLater(reportPanelState)
  readonly property string section: manifest && manifest.barWidget
    ? (manifest.barWidget.defaultSection || "center") : "center"
  readonly property var barPlacement: activeView ? activeView.placement : null
  Component { id: widgetViewComponent; WidgetView {} }

  function syncViews() {
    if (!loaded) return
    const legacy = !Array.isArray(context.views)
    const desired = legacy ? [{id: 1, output: 0, bar: context.bar}] : context.views
    const previous = views.slice()
    const next = []
    for (const allocation of desired) {
      let view = previous.find(view => view.allocation.id === allocation.id)
      if (view) view.allocation = allocation
      else view = widgetViewComponent.createObject(root, {runtime: root, allocation: allocation, legacy: legacy})
      if (!view) { console.error("Could not create plugin widget view"); Qt.quit(); return }
      next.push(view)
    }
    for (const view of previous) {
      if (next.indexOf(view) !== -1) continue
      view.close()
      if (activeView === view) activeView = null
      view.destroy()
    }
    views = next
    if (!activeView && next.length) activeView = next[0]
  }
  function syncSettings() { for (const view of views) view.syncSettings() }
  function claimView(view) {
    if (activeView !== view && overlayLoader.item && typeof overlayLoader.item.close === "function") overlayLoader.item.close()
    activeView = view
    for (const other of views) if (other !== view) other.close()
  }
  function switchPanel(direction) {
    if (!opened || panelSwitchProcess.running) return false
    panelSwitchProcess.command = ["/bootstrap", "--switch-panel", direction < 0 ? "-1" : "1"]
    panelSwitchProcess.running = true
    return true
  }

  function entryUrl(path) {
    return "file:///plugin/" + path.split("/").map(encodeURIComponent).join("/")
  }

  function inject(item) {
    if ("shell" in item) item.shell = shellApi
    if ("manifest" in item) item.manifest = manifest
    if ("omarchyPath" in item) item.omarchyPath = Quickshell.env("OMARCHY_PATH")
  }

  function checkLoader(loader) {
    if (loader.status === Loader.Error) {
      console.error("Shared plugin entry failed: " + loader.source)
      Qt.quit()
    }
  }

  function loadEntries() {
    if (loaded || !manifest || !context || !grants) return
    loaded = true
    var entries = manifest.entryPoints
    if (entries.service) serviceLoader.source = entryUrl(entries.service)
    if (entries.overlay) overlayLoader.source = entryUrl(entries.overlay)
    syncViews()
    Qt.callLater(applyPanel)
    Qt.callLater(reportPanelState)
  }

  function applyPanel() {
    var command = context ? context.panel : null
    if (!loaded || !command || command.serial === panelSerial) return
    if (command.open && command.view) {
      const view = views.find(view => view.allocation.id === command.view && view.allocation.output === command.output)
      if (!view || (!view.item && !overlayLoader.item) || !view.screen) return
      claimView(view)
    }
    if (!panel) return
    panelSerial = command.serial
    if (command.open) shellApi._summon(shellApi.pluginId, command.payload)
    else shellApi._hide(shellApi.pluginId)
  }

  function reportPanelState() {
    if (!loaded || panelStateProcess.running || sentPanelState === panelState) return
    sentPanelState = panelState
    panelStateProcess.command = ["/bootstrap", "--panel-state", String(panelSerial), String(opened)]
    panelStateProcess.running = true
  }

  Process {
    id: panelStateProcess
    onExited: function(code) {
      if (code !== 0) root.sentPanelState = ""
      panelStateRetry.restart()
    }
  }
  Timer { id: panelStateRetry; interval: 100; onTriggered: root.reportPanelState() }

  Process { id: panelSwitchProcess }

  FileView {
    path: "/context/state.json"
    watchChanges: true
    onFileChanged: reload()
    onLoaded: {
      root.context = JSON.parse(text())
      var theme = root.context.theme
      if (theme) {
        Color.foreground = theme.foreground
        Color.background = theme.background
        Color.accent = theme.accent
        Color.urgent = theme.urgent
        Color.muted = theme.muted
        Color.shellValues = theme.shellValues
        Style.applyShellValues(theme.shellValues)
        Style.cornerRadius = theme.cornerRadius
        Style.gapsOut = theme.gapsOut
        Style.resolvedFontFamily = theme.fontFamily
      }
      root.loadEntries()
      root.syncViews()
      root.syncSettings()
      root.applyPanel()
    }
    onLoadFailed: Qt.quit()
  }

  FileView {
    path: "/run/plugin/grants.json"
    onLoaded: { root.grants = JSON.parse(text()); root.loadEntries() }
    onLoadFailed: Qt.quit()
  }

  FileView {
    path: "/plugin/manifest.json"
    onLoaded: {
      root.manifest = JSON.parse(text())
      root.loadEntries()
    }
    onLoadFailed: Qt.quit()
  }

  PluginShellApi {
    id: shellApi
    readonly property var desktopGeometry: root.context ? root.context.geometry : null
    pluginId: root.manifest ? root.manifest.id : ""
    _serviceLookup: id => id === pluginId ? serviceLoader.item : null
    _summon: (id, payload) => {
      if (id !== pluginId || !root.panel || typeof root.panel.open !== "function") return false
      root.panel.open(payload)
      return true
    }
    _hide: id => {
      if (id !== pluginId || !root.panel || typeof root.panel.close !== "function") return false
      root.panel.close()
      return true
    }
    _toggle: (id, payload) => root.opened ? _hide(id) : _summon(id, payload)
    _isOpen: id => id === pluginId && root.opened
    _updateSettings: (id, settings) => {
      if (id !== pluginId || !settings || typeof settings !== "object" || Array.isArray(settings)) return false
      var patch = {}
      var writable = root.grants.settings.write
      for (var key of Object.keys(settings)) {
        if (key === "id" && settings[key] === pluginId) continue
        if (writable.indexOf(key) !== -1) patch[key] = settings[key]
        else if (JSON.stringify(settings[key]) !== JSON.stringify(root.context.settings[key])) {
          root.requestError = "Setting is not writable: " + key
          root.syncSettings()
          errorTimer.restart()
          return false
        }
      }
      root.pendingSettings = JSON.stringify(patch)
      settingsTimer.restart()
      return true
    }
  }

  Timer {
    id: settingsTimer
    interval: 300
    onTriggered: {
      if (settingsProcess.running || !root.pendingSettings) return
      settingsProcess.command = ["/bootstrap", "--settings", root.pendingSettings]
      root.pendingSettings = ""
      root.requestError = ""
      settingsProcess.running = true
    }
  }
  Process {
    id: settingsProcess
    onExited: function(code) {
      if (code !== 0) {
        root.requestError = "Settings were not saved. Review plugin access or retry."
        root.syncSettings()
        errorTimer.restart()
      }
      if (root.pendingSettings) settingsTimer.restart()
    }
  }
  IpcHandler {
    target: "ward-runtime"
    function linkFailed(status: string): void {
      root.requestError = RequestFeedback.linkError(status)
      errorTimer.restart()
    }
  }
  Timer { id: errorTimer; interval: 5000; onTriggered: root.requestError = "" }
  PanelWindow {
    readonly property var placement: RequestFeedback.placement(root.barPlacement, Style.gapsOut, Style.bar.sizeHorizontal)
    visible: root.requestError !== ""
    anchors { top: true; right: true }
    margins { top: placement.top; right: placement.right }
    implicitWidth: Math.min(Style.space(340), screen ? screen.width - 2 * Style.gapsOut : 340)
    implicitHeight: saveError.implicitHeight + 2 * Style.spacing.popupPadding
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    mask: Region {}
    BorderSurface {
      anchors.fill: parent
      color: Color.popups.background
      radius: Style.cornerRadius
      borderSpec: Border.surfaceSpec("popups", "border", Color.popups.border, 1)
      Text {
        id: saveError
        anchors.centerIn: parent
        width: parent.width - 2 * Style.spacing.popupPadding
        text: root.requestError
        textFormat: Text.PlainText
        color: Color.popups.text
        font.family: Style.font.family
        font.pixelSize: Style.font.body
        wrapMode: Text.WordWrap
      }
    }
  }

  Item {
    visible: false
    Loader {
      id: serviceLoader
      onLoaded: root.inject(item)
      onStatusChanged: root.checkLoader(this)
    }
    Loader {
      id: overlayLoader
      onLoaded: root.inject(item)
      onStatusChanged: root.checkLoader(this)
    }
  }

}
