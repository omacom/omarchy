import QtQuick
import Quickshell
import Quickshell.Hyprland
import Omarchy.Ward
import qs.Commons
import "../PluginInput.js" as PluginInput

// One logical plugin. Outputs and bar placements are disposable views of it.
QtObject {
  id: root
  required property string pluginId
  required property string store
  required property string controller
  readonly property string runtimeDirectory: Quickshell.env("OMARCHY_WARD_RUNTIME")
    || Quickshell.env("OMARCHY_PATH") + "/lib/ward-runtime"
  property var settings: ({})
  property var geometrySource: null
  property string overlayOutputs: "owner"
  property string overlayMode: "none"
  property var screenRows: []
  property var placements: []
  property int nextOutputId: 0
  property int nextViewId: 0
  property int epoch: 0
  property int activeViewId: 0
  property int activeOutputId: 0
  property var panelCommand: null
  property string localError: ""
  property string sentTopology: ""
  property bool started: false
  property bool startupComplete: false
  property bool panelAuthorized: false
  readonly property var nativeSession: session
  readonly property var activeRow: screenRows.find(row => row.id === activeOutputId) || null
  readonly property int overlayOutputId: activeRow ? activeOutputId : screenRows.length ? screenRows[0].id : 0
  readonly property var activePlacement: placements.find(row => row.id === activeViewId) || null
  readonly property var barOwner: activePlacement ? activePlacement.owner : null
  readonly property bool focusHeld: activeRow ? activeRow.surface.focusHeld : false
  readonly property bool reportedOpen: !error && (panelCommand && panelCommand.serial !== session.panelSerial ? panelCommand.open : session.panelOpen)
  readonly property bool opened: panelAuthorized && reportedOpen
  onReportedOpenChanged: { if (!reportedOpen) panelAuthorized = false }
  readonly property string error: localError || session.error
  readonly property string state: error ? "error" : session.ready && (startupComplete || screenRows.some(row => row.surface.presented)) ? "running" : "starting"
  signal statusChanged()
  signal panelSwitchRequested(int direction)
  signal operationBlocked(int action)
  onStateChanged: {
    // Latch outside the state binding's evaluation; the latch itself is one
    // of that binding's inputs and must not synchronously re-enter it.
    if (state === "running" && !startupComplete) Qt.callLater(() => { root.startupComplete = true })
    statusChanged()
  }
  onOpenedChanged: {
    panelGestureTimer.stop()
    if (opened && activeRow) Qt.callLater(() => {
      // Let the output's host input policy observe the new authorization first.
      if (root.opened && root.activeRow) root.activeRow.surface.primeFocus(false)
    })
    else {
      for (const row of screenRows) row.surface.clearFocus()
    }
  }
  onOverlayOutputsChanged: { for (const row of screenRows) row.surface.updateMask() }

  property PluginSession session: PluginSession {
    id: session
    onOperationBlocked: action => root.operationBlocked(action)
  }
  property Timer startupDeadline: Timer {
    interval: 8000
    running: !root.startupComplete && root.state === "starting"
    onTriggered: {
      root.localError = "Ward plugin startup timed out before presenting content"
      root.stop()
    }
  }
  property Timer panelGestureTimer: Timer {
    interval: 1000
    onTriggered: { if (!root.opened) root.panelAuthorized = false }
  }
  property var surfaceComponent: Qt.createComponent("SandboxedOutputSurface.qml")
  property Connections outputsChanged: Connections {
    target: Quickshell
    function onScreensChanged() { root.refreshScreens() }
  }
  readonly property string outputSpecJson: JSON.stringify(screenRows.map(row => ({
    id: row.id, x: Math.round(row.screen.x), y: Math.round(row.screen.y),
    width: Math.round(row.screen.width), height: Math.round(row.screen.height),
    scaleFixed: Math.round(row.screen.devicePixelRatio * 120)
  })))
  onOutputSpecJsonChanged: Qt.callLater(configure)
  readonly property string contextJson: {
    const screen = activeRow ? activeRow.screen : screenRows.length ? screenRows[0].screen : null
    const geometry = geometrySource ? geometrySource.forScreen(screen) : null
    const geometryOutputs = {}
    if (geometry) for (const row of screenRows) {
      const observed = geometrySource.forScreen(row.screen)
      if (observed) geometryOutputs[String(row.id)] = observed.viewport
    }
    const context = {
      settings: settings, panel: panelCommand, bar: null,
      views: placements.map(row => ({id: row.id, output: row.output, bar: row.bar})),
      geometry: geometry, geometryOutputs: geometryOutputs,
      theme: {
        foreground: String(Color.foreground), background: String(Color.background),
        accent: String(Color.accent), urgent: String(Color.urgent), muted: String(Color.muted),
        shellValues: Color.shellValues, cornerRadius: Style.cornerRadius,
        gapsOut: Style.gapsOut, fontFamily: Style.resolvedFontFamily
      }
    }
    let json = JSON.stringify(context)
    if (context.geometry && encodeURIComponent(json).replace(/%[0-9A-F]{2}/g, "x").length > 65536) {
      context.geometry = null
      context.geometryOutputs = {}
      json = JSON.stringify(context)
    }
    return json
  }
  onContextJsonChanged: Qt.callLater(updateContext)
  function updateContext() { if (started && !error) session.setContext(contextJson) }

  function refreshScreens() {
    if (Quickshell.screens.length > 8) { localError = "Ward supports at most eight presentation outputs"; stop(); return }
    const previous = screenRows
    const removed = previous.filter(row => !Quickshell.screens.some(screen => screen === row.screen))
    if (removed.some(row => row.id === activeOutputId)) dismiss()
    // Detach importers synchronously before creating replacements. QML destroy
    // is deferred, and must not make an eight-output hotplug exceed the budget.
    for (const row of removed) { row.surface.retire(); row.surface.destroy() }
    const next = []
    for (const screen of Quickshell.screens) {
      let row = previous.find(row => row.screen === screen)
      if (!row) {
        if (nextOutputId >= 2147483647) { localError = "Output identity limit reached"; stop(); return }
        const id = ++nextOutputId
        const surface = surfaceComponent.createObject(root, {owner: root, outputId: id, targetScreen: screen})
        if (!surface) { localError = "Could not create native output surface: " + surfaceComponent.errorString(); stop(); return }
        row = {id: id, screen: screen, surface: surface}
      }
      next.push(row)
    }
    placements = placements.filter(view => next.some(row => row.id === view.output))
    screenRows = next
    Qt.callLater(configure)
  }
  function configure() {
    if (error || outputSpecJson === sentTopology) return
    if (epoch >= 2147483647) { localError = "Presentation generation limit reached"; stop(); return }
    sentTopology = outputSpecJson
    const topology = JSON.stringify({version: 1, generation: ++epoch, outputs: JSON.parse(outputSpecJson)})
    if (!started) {
      started = true
      session.start(store, pluginId, controller, topology, contextJson, runtimeDirectory)
    } else session.configure(topology)
  }
  function outputFor(screen) { return screenRows.find(row => row.screen === screen) || null }
  function placementFor(owner) { return placements.find(view => view.owner === owner) || null }
  function widgetSize(id) {
    const size = session.widgetSizes[String(id)]
    return size || Qt.size(0, 0)
  }
  function updatePlacement(owner, screen, bar) {
    const output = outputFor(screen)
    if (!output || !bar) return 0
    let view = placementFor(owner)
    if (!view) {
      if (placements.length >= 32 || nextViewId >= 2147483647) return 0
      view = {id: ++nextViewId, owner: owner, output: output.id, bar: bar}
    } else {
      if (view.output !== output.id && view.id === activeViewId) dismiss()
      view = Object.assign({}, view, {output: output.id, bar: bar})
    }
    placements = placements.some(value => value.id === view.id)
      ? placements.map(value => value.id === view.id ? view : value) : placements.concat([view])
    return view.id
  }
  function removePlacement(owner) {
    const view = placementFor(owner)
    if (!view) return
    if (view.id === activeViewId) dismiss()
    placements = placements.filter(value => value.id !== view.id)
  }
  function claimOutput(outputId, point) {
    const output = screenRows.find(row => row.id === outputId)
    if (!output) return false
    const candidates = placements.filter(view => view.output === outputId)
    let view = candidates.find(view => {
      const slot = PluginInput.barSlots([view.bar], output.screen.width, output.screen.height)[0]
      return slot && point && point.x >= slot.x && point.y >= slot.y && point.x < slot.x + slot.width && point.y < slot.y + slot.height
    })
    // A roaming pointer press has no fallback placement or keyboard authority.
    if (!view) return false
    if (activeOutputId && activeOutputId !== outputId) {
      for (const row of screenRows) if (row.id !== outputId) row.surface.clearFocus()
    }
    activeOutputId = outputId
    activeViewId = view.id
    panelAuthorized = true
    if (!opened) panelGestureTimer.restart()
    return true
  }
  function setPanel(open, payload, owner) {
    if (error) return false
    const text = open ? String(payload || "") : ""
    try { if (encodeURIComponent(text).replace(/%[0-9A-F]{2}/g, "x").length > 4096) return false }
    catch (error) { return false }
    if (open) {
      let view = owner ? placementFor(owner) : null
      const focused = Hyprland.focusedMonitor
      const output = view ? screenRows.find(row => row.id === view.output)
        : screenRows.find(row => focused && row.screen.name === focused.name)
          || screenRows.find(row => placements.some(view => view.output === row.id && view.owner)) || screenRows[0]
      if (!output) return false
      view = view || placements.find(view => view.output === output.id)
      if (!view) {
        if (placements.length >= 32 || nextViewId >= 2147483647) return false
        view = {id: ++nextViewId, owner: null, output: output.id, bar: {x: 0, y: 0, width: 0, height: 0, size: 32, position: "top", visible: false}}
        placements = placements.concat([view])
      }
      for (const row of screenRows) if (row.id !== output.id) row.surface.clearFocus()
      activeOutputId = output.id
      activeViewId = view.id
    }
    panelGestureTimer.stop()
    panelAuthorized = open === true
    panelCommand = {serial: (panelCommand ? panelCommand.serial : 0) % 2147483647 + 1, open: open, payload: text, view: activeViewId, output: activeOutputId}
    if (open && activeRow) {
      const command = panelCommand
      Qt.callLater(() => {
        if (root.opened && root.panelCommand === command && root.activeRow) root.activeRow.surface.primeFocus(true)
      })
    }
    else for (const row of screenRows) row.surface.clearFocus()
    return true
  }
  function dismiss() { return setPanel(false, "", null) }
  function close() { dismiss() }
  function stop() { session.stop() }
  Component.onCompleted: refreshScreens()
  Component.onDestruction: stop()
}
