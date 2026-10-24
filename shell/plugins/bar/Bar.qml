import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQml.Models
import qs.Commons
import qs.Commons as Commons
import qs.Ui
import "BarModel.js" as BarModel

Item {
  id: root

  // The omarchy-shell host injects omarchyPath from OMARCHY_PATH.
  property string omarchyPath: Quickshell.env("OMARCHY_PATH")
  // Injected by the host shell so bar slots can resolve enabled widgets.
  property var barWidgetRegistry: fallbackBarWidgetRegistry
  // Read-only registry view for third-party full bars; the built-in bar does
  // not otherwise need it, but declaring it keeps clone construction atomic.
  property var pluginRegistry: null
  // Injected by the host shell every time shell.json is reloaded. Holds the
  // `bar:` subtree: position, background, layout. The host owns file IO;
  // the bar just renders whatever it's handed. The bar font follows the
  // OS-level fontconfig monospace binding — it is not stored in shell.json.
  property var barConfig: ({})
  // Injected by the host shell. Used for shell-wide actions such as opening
  // settings and persisting inline widget state.
  property var shell: null
  // Manifest for the active bar option. Present for custom bars and useful for
  // diagnostics; the built-in bar does not otherwise need it.
  property var manifest: null
  QtObject {
    id: fallbackBarWidgetRegistry
    property var widgets: ({})
    property int revision: 0
    function metadataFor(id) { return null }
  }
  // Mirrors the on-disk `bar-off` flag so the user can hide the bar without
  // killing the entire shell. Hidden panels stay mapped but park off-screen
  // without an exclusion zone; updated by the FileView watcher further down.
  property bool barHidden: false
  property string home: Quickshell.env("HOME")
  property string stateHome: home + "/.local/state"
  property string omarchyConfigDir: home + "/.config/omarchy"
  property var fallbackBarConfig: ({
    position: "top",
    background: "opaque",
    layout: { left: [], centerBegin: [], center: [], centerEnd: [], right: [] }
  })
  property var layoutConfig: fallbackBarConfig.layout
  property bool requestedTransparent: false
  property bool useTransparentForeground: false
  property bool transparent: false
  // A see-through bar that Hyprland blurs behind (the bar-glassy toggle), so
  // its theme background stays faintly. A transparent bar wins over it.
  property bool glassy: false
  // The look the blur behind the bar was last synced for. A background set by
  // editing shell.json skips the CLI, so the bar syncs Hyprland's blur itself.
  property string glassSyncedLook: ""
  // One bar surface exists per monitor and each reports into this count, so a
  // pointer crossing from one monitor's bar to another's stays counted however
  // the enter and leave interleave. A single shared bool would be left false by
  // whichever event landed last.
  property int barHoverCount: 0
  // True while the pointer is over any bar, widgets included.
  readonly property bool barHovered: barHoverCount > 0
  // The indicator peek, open while the pointer is on any bar. Plugins read it
  // by this name through their bar API.
  property bool centerSectionRevealHeld: false
  property bool centerHoverRevealSuppressed: false
  property int barConfigSerial: 0
  property string position: "top"
  // Resolves through fontconfig at paint time (Style.font.family defaults
  // to "monospace"), so changing the system font (via `omarchy-font-set`)
  // updates the bar without a reload.
  property string fontFamily: Style.font.family
  // Bound to the central Color singleton so the bar tracks shell.toml's
  // [bar] section. Property names kept for the rest of this file's bindings.
  property color themeForeground: Commons.Color.bar.text
  property color themeContrastForeground: Commons.Color.background
  property color transparentForeground: Commons.Color.bar.text
  property color foreground: themeForeground
  property color barForeground: useTransparentForeground ? transparentForeground : themeForeground
  property bool foregroundAnimationEnabled: true
  property color background: Commons.Color.bar.background
  readonly property color glassBackground: Qt.rgba(background.r, background.g, background.b, Math.min(background.a, 0.35))
  property color urgent: Commons.Color.bar.active

  // A theme change cross-fades the bar's colors. Cycling the background
  // between opaque, glassy and clear jumps, text color included.
  Behavior on barForeground { enabled: root.foregroundAnimationEnabled; ColorAnimation { duration: Style.duration(250); easing.type: Easing.OutCubic } }
  Behavior on background { ColorAnimation { duration: Style.duration(250); easing.type: Easing.OutCubic } }
  Behavior on urgent { ColorAnimation { duration: Style.duration(250); easing.type: Easing.OutCubic } }
  property var tooltipTarget: null
  property var pendingTooltipTarget: null
  property string tooltipText: ""
  property string pendingTooltipText: ""
  property bool tooltipShown: false
  property int tooltipRequest: 0
  property var activePopout: null
  // Where the open panel's card stands, and in which section of the bar, so
  // a panel taking over in the same section can start its card from there.
  property var popoutCard: null

  // The section a panel's widget sits in, the center's pieces counted as one,
  // as keyboard switching between panels counts them.
  function popoutSectionOf(owner) {
    for (var i = 0; i < moduleSlots.length; i++) {
      var slot = moduleSlots[i]
      if (slot && slot.activeItem === owner) return BarModel.navigationRegions(slot.region).join(" ")
    }
    return ""
  }

  // Reported by the open panel. Only a screen name and four numbers are kept,
  // whoever reports them; the section comes from the bar's own layout.
  function notePopoutCard(card) {
    popoutCard = card ? { screen: String(card.screen || ""), section: popoutSectionOf(activePopout),
                          x: Number(card.x) || 0, y: Number(card.y) || 0,
                          width: Number(card.width) || 0, height: Number(card.height) || 0 } : null
  }

  // The last card, copied, for a panel taking over in the same section: one
  // switching across the bar opens fresh instead of flying the card over it.
  function popoutCardFor(owner) {
    var card = popoutCard
    if (!card || !card.section || card.section !== popoutSectionOf(owner)) return null
    return { screen: card.screen, x: card.x, y: card.y, width: card.width, height: card.height }
  }
  // A widget is being dragged that could go into the tray section, so the
  // tray's drawer opens to show where.
  readonly property bool traySectionDragActive: !!barDragSource && !barDragSource.hostsTraySection
  // An open panel from a widget in the tray section keeps the tray's drawer
  // open, so the panel's widget stays on screen under it.
  readonly property bool traySectionPopoutOpen: {
    var owner = activePopout
    if (!owner) return false
    for (var i = 0; i < moduleSlots.length; i++) {
      var slot = moduleSlots[i]
      if (slot && slot.activeItem === owner) return slot.region === "tray"
    }
    return false
  }
  property var barDragSource: null
  // Where the dragged widget would land: { slot, after } beside a widget, or
  // { region, after } at an end of a section (see BarModel.centerDropTarget
  // and BarModel.traySectionDropTarget).
  property var barDragTarget: null
  readonly property string barDragRegion: barDragTarget ? (barDragTarget.slot ? barDragTarget.slot.region : barDragTarget.region) : ""
  // Where room is open for the dragged widget (BarModel.dropRoom), and that
  // room's length along the bar.
  property var barDragRoom: null
  property real barDragExtent: 0
  // The room as the dragged widget's ghost draws it: its length along the
  // bar, and across it the widget's own size, as its spacers have.
  readonly property real barDragGhostWidth: vertical ? (barDragSource ? barDragSource.widgetWidth : 0) : barDragExtent
  readonly property real barDragGhostHeight: vertical ? barDragExtent : (barDragSource ? barDragSource.widgetHeight : 0)
  // How much of the room each place holds, keyed "region:index"
  // (BarModel.fadeShares), and so its length there in whole pixels
  // (BarModel.roomLengths). The places holding some of it, as one string,
  // change only as a place opens or closes, so a section's rows aren't worked
  // out again on every frame of a move. The dragged widget's own place is
  // `barDragHome`, where it keeps its room in its slot.
  property var barDragShares: ({})
  readonly property var barDragLengths: BarModel.roomLengths(barDragExtent, barDragShares)
  readonly property string barDragPlaces: Object.keys(barDragShares).filter(function(place) { return barDragShares[place] > 0 }).sort().join(",")
  property string barDragHome: ""
  // The keys each section showed as the drag started (layoutWidgets). They
  // hold while no widget moves about.
  property string barDragKeys: ""
  // The spacers a drag has put in the sections, where a released widget can
  // land (DragSpacer).
  property var dragSpacers: []
  // A released widget's ghost gliding from the pointer to where it lands
  // (settleBarDrag), and how far along it is.
  property var barSettle: null
  property real barSettleProgress: 0
  property var barDragWindow: null
  property var barDragScreen: null
  property url barDragImageUrl: ""
  property real barDragSceneX: 0
  property real barDragSceneY: 0
  property real barDragScreenX: 0
  property real barDragScreenY: 0
  property real barDragOffsetX: 0
  property real barDragOffsetY: 0
  // True once the drag has pulled far enough off the bar that letting go
  // removes the widget instead of moving it. Its room closes meanwhile, as
  // though it were gone already (fadeDragRoom).
  property bool barDragRemoveArmed: false
  // Pulling a widget this far past the bar arms its removal. Generous enough
  // that overshooting a drop keeps reading as a move.
  readonly property real barDragRemoveDistance: Style.spaceReal(48)
  // A widget let go of past that, until its entry is written out of the
  // layout once its poof has played: { key, region, id }.
  property var barRemoval: null
  // The poof a removed widget vanishes in, while it plays: { screen, x, y,
  // width, height, image, seed }, the ghost as it was let go (its center,
  // size and picture) and a seed that lays each poof out a little
  // differently.
  property var barPoof: null
  property bool barMoveActive: false
  property string barMoveCandidate: ""
  property var barMoveWindow: null
  property var barMoveScreen: null
  property var clickTargets: []
  // Every widget's place on every bar surface (ModuleSlot), and every widget
  // itself (WidgetHost), which its slot borrows from its surface's pool.
  property var moduleSlots: []
  property var widgetHosts: []
  property var centerBoxes: []
  property var pluginBarApis: ({})
  // target -> { target, pluginId, clickTarget, popout }. Keyed by object so a
  // registration edits one entry in place instead of copying and rescanning an
  // array in QML; Qt's Map still finds a key by a native linear scan.
  readonly property var pluginObjectOwners: new Map()
  property bool pluginBarApiSyncQueued: false

  Component {
    id: pluginBarApiComponent
    PluginBarApi { }
  }

  function publicLayoutConfig() {
    return JSON.parse(JSON.stringify(root.layoutConfig || {}))
  }

  function bindPluginBarApi(api) {
    if (!api) return
    api.foreground = Qt.binding(function() { return root.foreground })
    api.barForeground = Qt.binding(function() { return root.barForeground })
    api.background = Qt.binding(function() { return root.background })
    api.urgent = Qt.binding(function() { return root.urgent })
    api.fontFamily = Qt.binding(function() { return root.fontFamily })
    api.position = Qt.binding(function() { return root.position })
    api.vertical = Qt.binding(function() { return root.vertical })
    api.barSize = Qt.binding(function() { return root.barSize })
    api.transparent = Qt.binding(function() { return root.transparent })
    api.foregroundAnimationEnabled = Qt.binding(function() { return root.foregroundAnimationEnabled })
    api.centerSectionRevealHeld = Qt.binding(function() { return root.centerSectionRevealHeld })
    api._centerHoverRevealSuppressed = Qt.binding(function() { return root.centerHoverRevealSuppressed })
    api.traySectionDragActive = Qt.binding(function() { return root.traySectionDragActive })
    api.traySectionPopoutOpen = Qt.binding(function() { return root.traySectionPopoutOpen })
    root.syncPluginBarApiObjects(api)
  }

  // Each api keeps its own detached copy of the layout. A flush serialises
  // the layout once and passes the string in so it is not re-serialised for
  // every plugin.
  function syncPluginBarApiObjects(api, layoutSnapshot) {
    if (!api) return
    api.activePopout = root.pluginOwnsBarObject(api.pluginId, root.activePopout)
      ? root.activePopout : (root.activePopout ? api.foreignPopoutMarker : null)
    api.clickTargets = root.pluginClickTargets(api.pluginId)
    api.layoutConfig = layoutSnapshot !== undefined
      ? JSON.parse(layoutSnapshot) : root.publicLayoutConfig()
  }

  function pluginObjectRecord(target) {
    return target ? (pluginObjectOwners.get(target) || null) : null
  }

  function markPluginObject(pluginId, target, role) {
    var key = String(pluginId || "")
    if (!key || !target) return false
    var record = root.pluginObjectRecord(target)
    if (record && record.pluginId !== key) return false
    if (!record) {
      record = { target: target, pluginId: key, clickTarget: false, popout: false }
      pluginObjectOwners.set(target, record)
    }
    record[role] = true
    return true
  }

  function unmarkPluginObject(pluginId, target, role) {
    var key = String(pluginId || "")
    var record = root.pluginObjectRecord(target)
    if (!record || record.pluginId !== key) return
    record[role] = false
    if (!record.clickTarget && !record.popout) pluginObjectOwners.delete(target)
  }

  function pluginOwnsBarObject(pluginId, target) {
    var record = target ? root.pluginObjectRecord(target) : null
    return !!record && record.pluginId === String(pluginId || "")
  }

  function pluginClickTargets(pluginId) {
    var out = []
    for (var i = 0; i < root.clickTargets.length; i++) {
      var target = root.clickTargets[i]
      if (root.pluginOwnsBarObject(pluginId, target)) out.push(target)
    }
    return out
  }

  // Every click target registration, popout change and layout change used to
  // resync every plugin api synchronously. Startup alone is hundreds of
  // registrations, each walking every api and every target, so coalesce them
  // into one resync per event-loop turn (as onWidgetHostsChanged already does
  // for prunePluginBarApis). bindPluginBarApi still syncs a brand-new api
  // directly so a widget never sees an empty api on its first read.
  function schedulePluginBarApiSync() {
    if (pluginBarApiSyncQueued) return
    pluginBarApiSyncQueued = true
    Qt.callLater(root.syncAllPluginBarApiObjects)
  }

  function syncAllPluginBarApiObjects() {
    pluginBarApiSyncQueued = false
    var layoutSnapshot = JSON.stringify(root.layoutConfig || {})
    for (var id in pluginBarApis) {
      var api = pluginBarApis[id]
      if (api) root.syncPluginBarApiObjects(api, layoutSnapshot)
    }
  }

  function registerPluginClickTarget(pluginId, target) {
    if (!root.markPluginObject(pluginId, target, "clickTarget")) return
    root.registerClickTarget(target)
  }

  function unregisterPluginClickTarget(pluginId, target) {
    if (!root.pluginOwnsBarObject(pluginId, target)) return
    root.unregisterClickTarget(target)
    root.unmarkPluginObject(pluginId, target, "clickTarget")
  }

  // A plugin may read api.activePopout right after asking for its popout, so
  // its own api is brought up to date inline; everyone else waits for the
  // coalesced resync.
  function requestPluginPopout(pluginId, owner) {
    if (!root.markPluginObject(pluginId, owner, "popout")) return
    root.requestPopout(owner)
    root.syncPluginBarApiObjects(pluginBarApis[String(pluginId || "")])
  }

  function releasePluginPopout(pluginId, owner) {
    if (!root.pluginOwnsBarObject(pluginId, owner)) return
    root.releasePopout(owner)
    root.unmarkPluginObject(pluginId, owner, "popout")
    root.syncPluginBarApiObjects(pluginBarApis[String(pluginId || "")])
  }

  function pluginBarApiFor(pluginId, moduleName, registered) {
    var key = String(pluginId || "")
    if (!key) return null

    var pluginShell = null
    if (registered && root.shell && typeof root.shell.pluginShellForId === "function") {
      // Only the trusted built-in bar receives ShellRoot and can request a
      // service-capable facade for the widget it is instantiating.
      pluginShell = root.shell.pluginShellForId(moduleName)
    } else if (root.shell && typeof root.shell.pluginShellForBarEntry === "function") {
      // Replacement bars receive a service-less entry facade. Giving an
      // untrusted bar a generic facade factory would let it retrieve another
      // third-party plugin's live service object.
      pluginShell = root.shell.pluginShellForBarEntry(key, moduleName)
    }

    if (pluginBarApis[key]) {
      pluginBarApis[key].shell = pluginShell
      return pluginBarApis[key]
    }

    var api = pluginBarApiComponent.createObject(null, {
      pluginId: key,
      moduleName: String(moduleName || ""),
      shell: pluginShell,
      _showTooltip: function(target, text) { root.showTooltip(target, text) },
      _hideTooltip: function(target) { root.hideTooltip(target) },
      _registerClickTarget: function(target) { root.registerPluginClickTarget(key, target) },
      _unregisterClickTarget: function(target) { root.unregisterPluginClickTarget(key, target) },
      _requestPopout: function(owner) { root.requestPluginPopout(key, owner) },
      _releasePopout: function(owner) { root.releasePluginPopout(key, owner) },
      _switchPanelFrom: function(owner, direction) { return root.switchPanelFrom(owner, direction) },
      _notePopoutCard: function(card) { root.notePopoutCard(card) },
      _popoutCardFor: function(owner) { return root.popoutCardFor(owner) },
      _targetBelongsToWindow: function(target, window) { return root.targetBelongsToWindow(target, window) },
      _moduleWidgets: function(requestedId) {
        return String(requestedId || "") === String(moduleName || "")
          ? root.moduleWidgets(moduleName) : []
      },
      _run: function(command) { root.run(command) },
      _setCenterHoverRevealSuppressed: function(value) {
        root.centerHoverRevealSuppressed = !!value
      }
    })
    if (!api) return null
    root.bindPluginBarApi(api)

    var next = ({})
    for (var id in pluginBarApis) next[id] = pluginBarApis[id]
    next[key] = api
    pluginBarApis = next
    return api
  }

  function pluginBarApiUsed(pluginId) {
    for (var i = 0; i < widgetHosts.length; i++) {
      var host = widgetHosts[i]
      if (host && host.pluginApiId === pluginId) return true
    }
    return false
  }

  function releasePluginObjects(pluginId) {
    var owned = Array.from(pluginObjectOwners.values())
    for (var i = 0; i < owned.length; i++) {
      var record = owned[i]
      if (!record || record.pluginId !== pluginId) continue
      if (record.clickTarget) root.unregisterClickTarget(record.target)
      if (record.popout && root.activePopout === record.target) root.releasePopout(record.target)
      pluginObjectOwners.delete(record.target)
    }
  }

  function prunePluginBarApis() {
    var next = ({})
    for (var id in pluginBarApis) {
      var api = pluginBarApis[id]
      if (root.pluginBarApiUsed(id)) {
        next[id] = api
        continue
      }
      root.releasePluginObjects(id)
      if (api && typeof api.destroy === "function") api.destroy()
    }
    pluginBarApis = next
  }

  onActivePopoutChanged: schedulePluginBarApiSync()
  onClickTargetsChanged: schedulePluginBarApiSync()
  onLayoutConfigChanged: schedulePluginBarApiSync()
  // A layout written from elsewhere that moves widgets about mid-drag leaves
  // the drag's room in the wrong places, so the drag lets go and the layout
  // stands as written. A widget whose settings change keeps its key
  // (BarModel.layoutWidgets), so that alone leaves the drag be. Later, since
  // the change is still reaching the sections' models.
  onLayoutWidgetsChanged: if (barDragSource && JSON.stringify(layoutWidgets.sections) !== barDragKeys) Qt.callLater(clearBarDrag)
  onWidgetHostsChanged: Qt.callLater(prunePluginBarApis)

  Component.onDestruction: {
    for (var id in pluginBarApis) {
      root.releasePluginObjects(id)
      if (pluginBarApis[id] && typeof pluginBarApis[id].destroy === "function")
        pluginBarApis[id].destroy()
    }
    pluginBarApis = ({})
  }

  function registerClickTarget(target) {
    if (!target || clickTargets.indexOf(target) !== -1) return
    var next = clickTargets.slice()
    next.push(target)
    clickTargets = next
  }

  function unregisterClickTarget(target) {
    var next = clickTargets.filter(function(item) { return item !== target })
    clickTargets = next
  }

  function registerModuleSlot(slot) {
    if (!slot || moduleSlots.indexOf(slot) !== -1) return
    var next = moduleSlots.slice()
    next.push(slot)
    moduleSlots = next
  }

  function unregisterModuleSlot(slot) {
    var next = moduleSlots.filter(function(item) { return item !== slot })
    moduleSlots = next
  }

  function registerWidgetHost(host) {
    if (!host || widgetHosts.indexOf(host) !== -1) return
    widgetHosts = widgetHosts.concat([host])
  }

  function unregisterWidgetHost(host) {
    widgetHosts = widgetHosts.filter(function(item) { return item !== host })
  }

  function registerCenterBox(box) {
    if (!box || centerBoxes.indexOf(box) !== -1) return
    centerBoxes = centerBoxes.concat([box])
  }

  function unregisterCenterBox(box) {
    centerBoxes = centerBoxes.filter(function(item) { return item !== box })
  }

  // The center box drawn on a bar surface. Each surface declares one in the
  // middle of the bar and one beside the right section, and draws one of them.
  function centerBoxFor(window) {
    for (var i = 0; i < centerBoxes.length; i++) {
      var box = centerBoxes[i]
      if (box && box.active && root.sameWindow(box.window, window)) return box
    }
    return null
  }

  // Where a drop lands in the box, in scene coordinates. During a drag it
  // takes in any room the box has opened for the dragged widget, so a drop
  // that lands in the box keeps landing there until the pointer leaves that
  // room, and it reaches the bar's thickness at least, so an empty box,
  // which takes no room, can still be hit.
  function centerBoxDropRect(box) {
    if (!box) return null
    try {
      var point = box.mapToItem(null, 0, 0)
      return BarModel.centerDropZone({ x: point.x, y: point.y, width: box.width, height: box.height }, box.crossSize, root.vertical)
    } catch (e) {
      return null
    }
  }

  function debugBarGeometry() {
    var out = []
    for (var i = 0; i < moduleSlots.length; i++) {
      var slot = moduleSlots[i]
      if (!slot || !slot.activeItem) continue
      var point = { x: slot.x, y: slot.y }
      try {
        point = slot.mapToItem(null, 0, 0)
      } catch (e) {
      }
      out.push({
        id: slot.moduleName,
        section: slot.region,
        x: Math.round(point.x),
        y: Math.round(point.y),
        width: Math.round(slot.width),
        height: Math.round(slot.height),
        visible: slot.visible === true && slot.width > 0 && slot.height > 0,
        itemVisible: slot.activeItem.visible === true,
        itemWidth: Math.round(slot.activeItem.implicitWidth || 0),
        itemHeight: Math.round(slot.activeItem.implicitHeight || 0)
      })
    }
    return out
  }

  function targetWindow(target) {
    return target && target.QsWindow ? target.QsWindow.window : null
  }

  function targetBelongsToWindow(target, window) {
    return !!target && !!window && targetWindow(target) === window
  }

  function slotWindow(slot) {
    if (!slot) return null
    return targetWindow(slot.activeItem) || targetWindow(slot)
  }

  function sameScreen(left, right) {
    if (!left || !right) return false
    if (left === right) return true
    return !!left.name && !!right.name && left.name === right.name
  }

  function sameWindow(left, right) {
    if (!left || !right) return false
    if (left === right) return true
    return sameScreen(left.screen, right.screen)
  }

  function targetTooltipHovered(target) {
    return !!target && target.visible !== false && target.opacity !== 0 && target.tooltipHovered === true
  }

  function clearTooltip() {
    tooltipTimer.stop()
    if (tooltipShown) tooltipWarmTimer.restart()
    pendingTooltipTarget = null
    pendingTooltipText = ""
    tooltipTarget = null
    tooltipText = ""
    tooltipShown = false
  }

  function clearBarDrag() {
    barDragSource = null
    barDragWindow = null
    barDragScreen = null
    barDragImageUrl = ""
    barDragTarget = null
    barDragRoom = null
    barDragExtent = 0
    barDragKeys = ""
    barDragRemoveArmed = false
    barDragRegrab.stop()
    barSettle = null
    barSettleAnimation.stop()
    // The room closes at once: a drop now fills it, and anything else is
    // already back in place.
    barDragShares = {}
    barDragHome = ""
    roomFader.stop()
    barDragSceneX = 0
    barDragSceneY = 0
    barDragScreenX = 0
    barDragScreenY = 0
    barDragOffsetX = 0
    barDragOffsetY = 0
  }

  function windowScreenPoint(scenePoint, window) {
    var x = scenePoint ? scenePoint.x : 0
    var y = scenePoint ? scenePoint.y : 0
    if (!window || !window.screen) return { x: x, y: y }

    if (root.position === "bottom")
      y += Math.max(0, window.screen.height - window.height)
    else if (root.position === "right")
      x += Math.max(0, window.screen.width - window.width)

    return { x: x, y: y }
  }

  function barDragScreenPoint(scenePoint) {
    return windowScreenPoint(scenePoint, barDragWindow)
  }

  // Split the screen along its diagonals (in normalized space, so widescreens
  // don't bias toward left/right): whichever triangle holds the cursor names
  // the candidate edge.
  function nearestScreenEdge(point, screen) {
    var nx = screen.width > 0 ? Util.clamp(point.x / screen.width, 0, 1) : 0.5
    var ny = screen.height > 0 ? Util.clamp(point.y / screen.height, 0, 1) : 0.5

    var edge = "top"
    var best = ny
    if (1 - ny < best) { edge = "bottom"; best = 1 - ny }
    if (nx < best) { edge = "left"; best = nx }
    if (1 - nx < best) { edge = "right"; best = 1 - nx }
    return edge
  }

  function beginBarMove(window) {
    barMoveWindow = window
    barMoveScreen = window ? window.screen : null
    barMoveCandidate = position
    barMoveActive = true
  }

  function updateBarMove(screenPoint) {
    if (!barMoveActive || !barMoveScreen) return
    barMoveCandidate = nearestScreenEdge(screenPoint, barMoveScreen)
  }

  function clearBarMove() {
    barMoveActive = false
    barMoveCandidate = ""
    barMoveWindow = null
    barMoveScreen = null
  }

  function finishBarMove() {
    var edge = barMoveCandidate
    if (!barMoveActive || !edge || edge === position) {
      clearBarMove()
      return
    }

    clearBarMove()
    setBarPosition(edge)
  }

  function setBarPosition(value) {
    var next = normalizePosition(value)
    if (root.shell && typeof root.shell.mutateShellConfig === "function") {
      root.shell.mutateShellConfig(function(config) {
        if (!Util.isPlainObject(config.bar)) config.bar = {}
        config.bar.position = next
      })
    } else {
      root.position = next
    }
  }

  // A copy of the widget for its ghost and its room to show. A widget that
  // changes size mid-drag is copied again, keeping the last copy until then.
  function captureBarDragGhost(slot) {
    var item = slot && slot.activeItem ? slot.activeItem : null
    if (!item || typeof item.grabToImage !== "function") return

    var grabWidth = Math.max(1, Math.ceil(slot.widgetWidth))
    var grabHeight = Math.max(1, Math.ceil(slot.widgetHeight))
    item.grabToImage(function(result) {
      if (root.barDragSource !== slot || !result || !result.url) return
      root.barDragImageUrl = result.url
    }, Qt.size(grabWidth, grabHeight))
  }

  function requestPopout(owner) {
    if (activePopout === owner) return
    if (activePopout) {
      if ("closeForPopoutSwitch" in activePopout) activePopout.closeForPopoutSwitch()
      else if ("close" in activePopout) activePopout.close()
    }
    activePopout = owner
  }

  function releasePopout(owner) {
    if (activePopout === owner) activePopout = null
  }

  readonly property bool vertical: position === "left" || position === "right"
  readonly property int barSize: vertical ? Style.bar.sizeVertical : Style.bar.sizeHorizontal

  // Display cutouts (a camera notch) the platform's own package describes in
  // the fixed platform root, which no environment variable moves. Most machines
  // have none. It is read as the shell starts (blockLoading), so a bar surface
  // knows before it maps whether its screen may have one. See
  // BarModel.parseCutouts.
  // Read synchronously at startup (the FileView blocks loading, so the bar
  // knows before it maps whether its screen may have a cutout), then kept
  // current by its load handlers below. Binding this to the missing flag
  // the handlers write — as it was — loops on every shell start.
  property var displayCutouts: BarModel.parseCutouts(displayCutoutsFile.text())
  FileView {
    id: displayCutoutsFile

    // A file that went away describes nothing, whatever text() still holds.
    property bool missing: false

    path: "/usr/share/omarchy-platform/display-cutouts.json"
    blockLoading: true
    watchChanges: true
    printErrors: false
    onLoaded: {
      missing = false
      root.displayCutouts = BarModel.parseCutouts(text())
    }
    onLoadFailed: {
      missing = true
      root.displayCutouts = []
    }
    onFileChanged: reload()
  }

  // The physical mode Hyprland reports for a screen, as hyprctl monitors does.
  // Qt's whole-number devicePixelRatio can't rebuild it at a fractional scale.
  function panelModeFor(screen) {
    var monitor = screen ? Hyprland.monitorFor(screen) : null
    return monitor ? ({
      width: monitor.width,
      height: monitor.height,
      transform: monitor.lastIpcObject ? monitor.lastIpcObject.transform : 0
    }) : null
  }

  // How thick the bar is on a screen. A top bar shorter than a panel's camera
  // cutout leaves a sliver of every window peeking out beside the camera, so
  // the cutout is this panel's minimum sensible top-bar height. An
  // intentionally taller bar still wins.
  function thicknessFor(screen) {
    if (root.vertical || !screen) return root.barSize
    return Math.max(root.barSize, BarModel.notchFloor(root.displayCutouts, root.position, screen.name, screen.width, screen.height, screen.devicePixelRatio, root.panelModeFor(screen), Style.bar.notchHeight))
  }

  // Each screen's bar thickness, by screen name: barSize, or more where a notch
  // floor raises a top bar. Toasts and plugins clear the bar by it; barSize
  // stays the configured size the widgets are drawn at.
  readonly property var screenBarSizes: {
    var sizes = ({})
    var screens = Quickshell.screens
    for (var i = 0; i < screens.length; i++) sizes[screens[i].name] = root.thicknessFor(screens[i])
    return sizes
  }

  function barSizeFor(screenName) {
    return BarModel.barSizeFor(root.screenBarSizes, screenName, root.barSize)
  }

  function normalizePosition(value) {
    return BarModel.normalizePosition(value)
  }

  // The shared layout normalization, so the bar host and scriptable config
  // helpers can't drift on entry shape.
  function normalizeLayout(layout) {
    return Util.normalizeLayout(Util.isPlainObject(layout) ? layout : fallbackBarConfig.layout)
  }

  function applyBarConfig() {
    var config = Util.isPlainObject(barConfig) ? barConfig : fallbackBarConfig

    position = normalizePosition(config.position)
    // opaque, glassy or none; a config from before background says
    // transparent instead.
    var look = config.background || (config.transparent === true ? "none" : "opaque")
    setRequestedTransparency(look === "none")
    // A bar going clear waits for its text color before dropping its
    // background, so a glassy one stays glassy until then rather than
    // flashing opaque. Once clear, transparent wins over a stale glassy.
    if (look !== "none") glassy = look === "glassy"
    if (look !== glassSyncedLook) {
      glassSyncedLook = look
      Util.execDetached("omarchy-bar sync-glass")
    }

    // Each widget keeps its key while it stays in the layout, wherever it
    // moves and whatever its settings, so a config write builds just the
    // widgets it adds (layoutWidgets).
    layoutConfig = normalizeLayout(config.layout)
    barConfigSerial++
  }

  // Every widget on the bar, each under a key it keeps wherever it moves
  // (BarModel.layoutWidgets): the keys each section shows, in order, and each
  // key's entry. Every bar surface keeps one widget per key in its pool and
  // hands it to the slot of whichever section shows it (WidgetPool).
  property var widgetMemo: ({})
  readonly property var layoutWidgets: BarModel.layoutWidgets(layoutConfig, widgetMemo)

  onBarConfigChanged: applyBarConfig()

  function layoutEntries(region) {
    var serial = barConfigSerial
    var entries = layoutConfig ? layoutConfig[region] : null
    return Array.isArray(entries) ? entries : []
  }

  // Tab order for the panels in one bar region, with the three center
  // sections taken as one. Scoped to a single bar surface so tabbing walks the
  // bar the open panel belongs to instead of hopping the panel to another
  // monitor's copy of the same widget.
  function panelNavigationSlots(region, window) {
    var regions = BarModel.navigationRegions(region)
    var slots = []
    for (var r = 0; r < regions.length; r++) {
      var entries = layoutEntries(regions[r])
      for (var i = 0; i < entries.length; i++) {
        var id = entryId(entries[i])
        for (var j = 0; j < moduleSlots.length; j++) {
          var slot = moduleSlots[j]
          if (!slot || slot.region !== regions[r] || slot.moduleName !== id) continue
          if (window && !sameWindow(slotWindow(slot), window)) continue
          var item = slot.activeItem
          if (!item || item.visible !== true || slot.visible !== true || slot.width <= 0 || slot.height <= 0) continue
          if (typeof item.open !== "function" || typeof item.close !== "function" || item.opened === undefined) continue
          slots.push(slot)
          break
        }
      }
    }
    return slots
  }

  // The Nth panel in a bar region, counted the way the bar reads: layout order,
  // and only the panels actually on screen. A widget with no panel (the tray)
  // and one that is hiding itself are passed over, so the number lands on the
  // Nth panel icon the user can see rather than the Nth layout entry.
  // One-based, because it exists for hotkeys; anything else lands on no slot.
  //
  // Counting any bar surface is enough: every monitor lays its bar out from the
  // one layout, and summoning the id routes through pickPanelSlot, which opens
  // the focused monitor's copy whichever surface was counted.
  function panelWidgetIdAt(region, index) {
    var slots = panelNavigationSlots(String(region || ""), null)
    var slot = slots[Math.round(Number(index)) - 1]
    return slot ? String(slot.moduleName || "") : ""
  }

  function switchPanelFrom(owner, direction) {
    if (!owner) return false

    var currentSlot = null
    for (var i = 0; i < moduleSlots.length; i++) {
      var slot = moduleSlots[i]
      if (slot && slot.activeItem === owner) {
        currentSlot = slot
        break
      }
    }
    if (!currentSlot) return false

    var slots = panelNavigationSlots(currentSlot.region, slotWindow(currentSlot))
    if (slots.length < 2) return false

    var currentIndex = -1
    for (var j = 0; j < slots.length; j++) {
      if (slots[j] === currentSlot) {
        currentIndex = j
        break
      }
    }
    if (currentIndex < 0) return false

    var step = direction < 0 ? -1 : 1
    var nextSlot = slots[(currentIndex + step + slots.length) % slots.length]
    if (!nextSlot || !nextSlot.activeItem || nextSlot.activeItem === owner) return false

    nextSlot.activeItem.open()
    return true
  }

  // Every live instance of a widget id. A bar surface is built per monitor, so
  // a widget that appears once in the layout is still live once per screen.
  function moduleWidgets(pluginId) {
    var id = String(pluginId || "")
    var items = []
    if (!id) return items
    for (var i = 0; i < widgetHosts.length; i++) {
      var host = widgetHosts[i]
      if (!host || !host.activeItem || host.moduleName !== id) continue
      items.push(host.activeItem)
    }
    return items
  }

  function slotScreenName(slot) {
    var window = slotWindow(slot)
    return window && window.screen ? String(window.screen.name || "") : ""
  }

  // The output Hyprland has focused, which is where a keyboard-summoned panel
  // belongs. Empty until Hyprland reports one, which leaves panel routing on
  // its per-monitor fallback rather than guessing at an output.
  function focusedScreenName() {
    var monitor = Hyprland.focusedMonitor
    return monitor ? String(monitor.name || "") : ""
  }

  // Resolve the live bar-widget instance for a plugin id (e.g. "omarchy.bluetooth").
  // Only widgets that expose popup open/close methods count; plain indicators
  // (clock, workspaces, tray) return null. Used by shell.summon/toggle so
  // panel hotkeys route through the bar instead of a per-target IPC handler
  // that only reaches whichever per-monitor instance claimed the target.
  function findPanelWidget(pluginId) {
    var id = String(pluginId || "")
    if (!id) return null
    var candidates = []
    for (var i = 0; i < moduleSlots.length; i++) {
      var slot = moduleSlots[i]
      if (!slot || !slot.activeItem) continue
      if (slot.moduleName !== id) continue
      var item = slot.activeItem
      if (typeof item.open !== "function" || typeof item.close !== "function" || item.opened === undefined) continue
      candidates.push({ slot: slot, screenName: slotScreenName(slot), opened: item.opened === true })
    }
    // One copy per monitor, some of which may not be drawn. See
    // BarModel.pickPanelSlot for which one a hotkey acts on.
    var chosen = BarModel.pickPanelSlot(candidates, focusedScreenName())
    return chosen ? chosen.activeItem : null
  }

  function summonBarWidget(pluginId) {
    var item = findPanelWidget(pluginId)
    if (!item || typeof item.open !== "function") return false
    item.open()
    return true
  }

  function hideBarWidget(pluginId) {
    var item = findPanelWidget(pluginId)
    if (!item || typeof item.close !== "function") return false
    item.close()
    return true
  }

  function isBarWidgetOpen(pluginId) {
    var item = findPanelWidget(pluginId)
    return !!item && item.opened === true
  }

  function entrySettings(entry) {
    return BarModel.entrySettings(entry)
  }

  function entryId(entry) {
    return BarModel.entryId(entry)
  }

  function moduleString(entry, key, fallback) {
    return BarModel.moduleString(entry, key, fallback)
  }

  function canonicalWidgetId(name) {
    return Util.canonicalWidgetId(name)
  }

  function expandPath(path) {
    return BarModel.expandPath(path, home)
  }

  function customModuleSafeName(name) {
    return BarModel.customModuleSafeName(name)
  }

  function customModuleType(entry) {
    return BarModel.customModuleType(entry)
  }

  function customModuleSource(entry) {
    var source = BarModel.customModulePath(entry, home, omarchyConfigDir)
    return source ? Util.fileUrl(source) : ""
  }

  Component.onCompleted: applyBarConfig()

  // The indicator peek opens as the pointer comes onto the bar and holds until
  // it leaves, or crosses onto the clock at the start of the center box
  // (BarModel.peeksAt). Revealing the indicators widens their section, which
  // can slide a widget under a stationary pointer, so nothing narrower than the
  // stretch of bar up to that edge, held still while the peek is open
  // (BarModel.nextPeekEdge), can hold it without opening and closing it in a
  // loop.
  function setBarHovered(hovered) {
    barHoverCount = Math.max(0, barHoverCount + (hovered ? 1 : -1))
    if (barHoverCount > 0) {
      centerSectionRevealTimer.stop()
      centerSectionRevealHeld = true
    } else {
      centerSectionRevealTimer.restart()
    }
  }

  function setCenterHoverRevealSuppressed(value) {
    centerHoverRevealSuppressed = !!value
  }

  Timer {
    id: centerSectionRevealTimer
    interval: 120
    // A pointer that dips off the bar and straight back leaves the peek open.
    onTriggered: if (!root.barHovered) root.centerSectionRevealHeld = false
  }

  function run(command) {
    if (!command) return

    Util.execDetached(command)
  }

  // Steps the bar background from clear to glassy to opaque and around. Through
  // omarchy-bar, which keeps Hyprland's blur behind a glassy bar in step.
  function cycleBackground() {
    Util.execDetached("omarchy-bar background cycle")
  }

  function moduleDropAtScene(scenePoint, sourceSlot) {
    var sourceWindow = root.slotWindow(sourceSlot) || root.barDragWindow
    // A drop lands only over the bar strip. The window spans its whole
    // screen, so its own bounds are not the bar's.
    if (moduleRemoveDistance(windowScreenPoint(scenePoint, sourceWindow)) > 0) return null

    // The tray cannot go into its own drawer.
    var intoTraySection = !sourceSlot || !sourceSlot.hostsTraySection
    var traySlot = null
    // Each widget's own room; spacers are not widgets. The dragged widget
    // counts too: over its own room it would land back there, and folded
    // away, it still answers at the point it left, which the section's layout
    // keeps placing.
    var candidates = []
    for (var i = 0; i < moduleSlots.length; i++) {
      var slot = moduleSlots[i]
      if (!slot || !slot.visible || slot.widgetWidth <= 0 || slot.widgetHeight <= 0) continue
      if (sourceWindow && !root.sameWindow(root.slotWindow(slot), sourceWindow)) continue
      if (slot.region === "tray" && !intoTraySection) continue
      if (intoTraySection && slot.hostsTraySection) traySlot = slot

      var slotPoint = { x: slot.x, y: slot.y }
      try {
        slotPoint = slot.mapToItem(null, 0, 0)
      } catch (e) {
      }

      candidates.push({
        slot: slot,
        region: slot.region,
        x: slotPoint.x,
        y: slotPoint.y,
        width: slot.width,
        height: slot.height
      })
    }

    // The tray's drawer section works as the center box does: over it, a
    // drop lands among the widgets in it, or in it, and off it they are out
    // of reach.
    var drawer = BarModel.traySectionDropTarget(candidates, root.traySectionDropRect(traySlot, sourceWindow), scenePoint, root.vertical, sourceSlot)
    if (drawer) return drawer
    var onBar = candidates.filter(function(row) { return row.region !== "tray" })
    var box = sourceWindow ? root.centerBoxFor(sourceWindow) : null
    return BarModel.centerDropTarget(onBar, root.centerBoxDropRect(box), scenePoint, root.vertical, sourceSlot)
  }

  // Where a drop lands in the tray's drawer section on a bar surface, in
  // scene coordinates: the section, any room a drag has opened there
  // included, reaching past it by half the bar's thickness either way, short
  // of the tray's own ends (BarModel.sectionDropZone).
  function traySectionDropRect(slot, window) {
    var shown = slot ? slot.traySectionNow() : null
    if (!shown || !window || !window.contentItem) return null
    try {
      var area = slot.widgetRoom
      var origin = area.mapToItem(null, shown.x, shown.y)
      var section = { x: origin.x, y: origin.y, width: shown.width, height: shown.height }
      var corner = area.mapToItem(null, 0, 0)
      var tray = { x: corner.x, y: corner.y, width: area.width, height: area.height }
      var reach = thicknessFor(window.screen)
      return BarModel.sectionDropZone(section, reach, vertical, tray)
    } catch (e) {
      return null
    }
  }

  // Lifts a widget off the bar by the point it was pressed at. Its room is the
  // length the section's layout gives it, which is whole pixels. Its panel
  // closes: placed when it opened, it wouldn't follow the widget anywhere.
  function beginBarDrag(sourceSlot, pressX, pressY) {
    // A widget still poofing away is written out first, so the drag starts
    // from the layout as it will be.
    commitBarRemoval()
    var item = sourceSlot.activeItem
    if (item && item.opened === true && typeof item.close === "function") item.close()
    barDragWindow = targetWindow(sourceSlot.activeItem) || targetWindow(sourceSlot)
    barDragScreen = barDragWindow ? barDragWindow.screen : null
    barDragOffsetX = pressX
    barDragOffsetY = pressY
    captureBarDragGhost(sourceSlot)
    barDragExtent = Math.ceil(vertical ? sourceSlot.widgetHeight : sourceSlot.widgetWidth)
    startDragRoom(sourceSlot)
    barDragSource = sourceSlot
  }

  // A dragged widget that changes size, as a clock ticking over or the
  // indicator peek does, takes its room and its ghost with it. The ghost's
  // copy of it is taken again once the size settles, rather than on every
  // frame of a widget animating its size.
  function resizeBarDrag() {
    var slot = barDragSource
    if (!slot) return
    var extent = Math.ceil(vertical ? slot.widgetHeight : slot.widgetWidth)
    if (extent === barDragExtent) return
    barDragExtent = extent
    barDragRegrab.restart()
  }

  Timer {
    id: barDragRegrab
    interval: 120
    onTriggered: root.captureBarDragGhost(root.barDragSource)
  }

  Connections {
    target: root.barDragSource
    function onWidgetWidthChanged() { root.resizeBarDrag() }
    function onWidgetHeightChanged() { root.resizeBarDrag() }
  }

  // The room opens where the dragged widget is, which keeps all of it until
  // the room moves away.
  function startDragRoom(sourceSlot) {
    barDragKeys = JSON.stringify(layoutWidgets.sections)
    barDragRoom = BarModel.dropRoom(null, { key: sourceSlot.widgetKey, region: sourceSlot.region }, layoutWidgets.sections, drawnKeys(barDragWindow))
    barDragHome = dragShareKey(barDragRoom)
    var shares = {}
    shares[barDragHome] = 1
    barDragShares = shares
  }

  // Moves the room for the dragged widget to where a drop would land. The
  // place it leaves hands its room over to the new one (fadeDragRoom).
  function moveDragRoom(drop) {
    var source = barDragSource
    if (!source) return
    var next = BarModel.dropRoom(drop, { key: source.widgetKey, region: source.region }, layoutWidgets.sections, drawnKeys(barDragWindow))
    var last = barDragRoom
    barDragRoom = next
    // A widget showing itself just before the dragged one moves where home is.
    if (next.home) barDragHome = dragShareKey(next)
    if (!next || (last && dragShareKey(last) === dragShareKey(next))) return
    fadeDragRoom(0)
    roomFader.start()
  }

  // The keys of the widgets a bar surface draws, as they are now.
  function drawnKeys(window) {
    var drawn = {}
    for (var i = 0; i < moduleSlots.length; i++) {
      var slot = moduleSlots[i]
      if (slot && slot.visible && slot.widgetWidth > 0 && slot.widgetHeight > 0 && sameWindow(slotWindow(slot), window)) drawn[slot.widgetKey] = true
    }
    return drawn
  }

  function dragShareKey(room) {
    return room ? room.region + ":" + room.index : ""
  }

  // A frame of the room moving, at an even pace: a place hands over the
  // whole room in 120ms.
  // Armed for removal, there is no target: every place gives its room up.
  function fadeDragRoom(seconds) {
    var duration = Style.duration(120)
    var step = duration > 0 ? seconds * 1000 / duration : 1
    var target = barDragRemoveArmed ? "" : dragShareKey(barDragRoom)
    barDragShares = BarModel.fadeShares(barDragShares, target, step)
    if (target ? barDragShares[target] >= 1 : Object.keys(barDragShares).length === 0) roomFader.stop()
  }

  FrameAnimation {
    id: roomFader
    onTriggered: root.fadeDragRoom(frameTime)
  }

  // Where a section's list on a bar surface opens room for the dragged
  // widget, while it is dragged on that surface: each place holding some of
  // the room but the dragged widget's own, which keeps its room in its slot.
  function sectionSpacers(region, window) {
    if (!barDragSource || !barDragPlaces || !window || !sameWindow(barDragWindow, window)) return []
    var places = []
    var held = barDragPlaces.split(",")
    for (var i = 0; i < held.length; i++) {
      var split = held[i].lastIndexOf(":")
      if (held[i] !== barDragHome && held[i].slice(0, split) === region) places.push(Number(held[i].slice(split + 1)))
    }
    return places
  }

  function registerDragSpacer(spacer) {
    dragSpacers = dragSpacers.concat([spacer])
  }

  function unregisterDragSpacer(spacer) {
    dragSpacers = dragSpacers.filter(function(item) { return item !== spacer })
  }

  // Where a released widget lands: the room its drop opened, or its own room
  // when it goes back where it was.
  function dropLandingItem(sourceSlot, room) {
    if (!sourceSlot) return null
    if (!room || room.home) return sourceSlot.widgetRoom
    var sourceWindow = slotWindow(sourceSlot) || barDragWindow
    for (var i = 0; i < dragSpacers.length; i++) {
      var spacer = dragSpacers[i]
      if (spacer && spacer.region === room.region && spacer.place === room.index && sameWindow(spacer.window, sourceWindow)) return spacer
    }
    return null
  }

  // Where letting go of the dragged widget now would move its entry
  // (BarModel.moveEntry): to before the widget the room is before, or the end
  // of the section. Null when it would go back where it was.
  function dragMove() {
    var room = barDragRoom
    var source = barDragSource
    if (!room || room.home || !source) return null
    var sections = layoutWidgets.sections
    var count = (sections[room.region] || []).length
    return {
      key: source.widgetKey,
      from: { region: source.region, index: (sections[source.region] || []).indexOf(source.widgetKey), id: entryId(source.entry) },
      to: { region: room.region, index: room.index < count ? room.index : -1 },
      keys: barDragKeys
    }
  }

  // Lets go of a dragged widget: its ghost glides from the pointer into where
  // it lands, and the move is written once it gets there, so the widget takes
  // its place from where it was let go rather than sliding in from the side.
  function settleBarDrag(sourceSlot) {
    var move = dragMove()
    if (Style.duration(180) === 0) {
      landBarDrag(move)
      return
    }
    barSettle = { source: sourceSlot, move: move, room: move ? barDragRoom : null, fromX: barDragScreenX, fromY: barDragScreenY }
    barSettleProgress = 0
    barSettleAnimation.restart()
  }

  // The ghost follows the landing as it moves, so it arrives where the room
  // ends up even while the room is still moving there. Until the room
  // reaches the landing place, which has no spacer yet, it holds still.
  onBarSettleProgressChanged: {
    var settle = barSettle
    if (!settle) return
    var landing = dropLandingItem(settle.source, settle.room)
    if (!landing) return
    var center = null
    try {
      center = barDragScreenPoint(landing.mapToItem(null, landing.width / 2, landing.height / 2))
    } catch (e) {
      return
    }
    var toX = center.x - barDragGhostWidth / 2 + barDragOffsetX
    var toY = center.y - barDragGhostHeight / 2 + barDragOffsetY
    barDragScreenX = settle.fromX + (toX - settle.fromX) * barSettleProgress
    barDragScreenY = settle.fromY + (toY - settle.fromY) * barSettleProgress
  }

  NumberAnimation {
    id: barSettleAnimation
    target: root
    property: "barSettleProgress"
    from: 0
    to: 1
    duration: Style.duration(180)
    easing.type: Easing.OutCubic
    onFinished: root.finishBarSettle()
  }

  // Lands a settling widget now: when its ghost arrives, or when a new press
  // can't wait for it.
  function finishBarSettle() {
    var settle = barSettle
    if (!settle) return
    barSettle = null
    barSettleAnimation.stop()
    landBarDrag(settle.move)
  }

  // Writes where a dragged widget landed, unless widgets have moved about
  // since the drag started: a write from elsewhere that the drag hasn't let
  // go for yet (onLayoutWidgetsChanged) would put it in the wrong place. Every
  // widget keeps its own instance through the move, the dragged one too,
  // whatever else shares its id (BarModel.layoutWidgets).
  function landBarDrag(move) {
    clearBarDrag()
    if (!move || JSON.stringify(layoutWidgets.sections) !== move.keys) return
    var expected = JSON.parse(move.keys)
    var into = expected[move.to.region]
    var before = move.to.index >= 0 ? into[move.to.index] : null
    expected[move.from.region].splice(move.from.index, 1)
    into.splice(before ? into.indexOf(before) : into.length, 0, move.key)
    writeLayout(expected, function(config) {
      BarModel.moveEntry(config, move, function(entry) { return Util.normalizeLayoutEntry(entry) })
    })
  }

  // Writes a layout edit to shell.json. Widgets keep their instances through
  // the write as long as the sections come out as `expected`.
  function writeLayout(expected, edit) {
    if (!root.shell || typeof root.shell.mutateShellConfig !== "function") return
    widgetMemo.expected = expected
    try {
      root.shell.mutateShellConfig(edit)
    } finally {
      widgetMemo.expected = null
    }
  }

  // How far past the bar the drag point sits, in screen coordinates: past
  // the strip its screen's bar surface draws, thickness deep along its edge.
  // The strip, not the window, is the boundary: the window spans the whole
  // screen (BarPanel).
  function moduleRemoveDistance(screenPoint) {
    var screen = barDragScreen
    if (!screen) return 0
    var thickness = thicknessFor(screen)
    var x = screenPoint.x
    var y = screenPoint.y
    if (vertical) {
      if (position === "right") x -= Math.max(0, screen.width - thickness)
      return BarModel.dragDistanceOutside({ x: x, y: y }, thickness, screen.height)
    }
    if (position === "bottom") y -= Math.max(0, screen.height - thickness)
    return BarModel.dragDistanceOutside({ x: x, y: y }, screen.width, thickness)
  }

  // Arming closes the dragged widget's room, and disarming opens it again
  // where a drop would land, as a move of the room does (moveDragRoom).
  function setBarDragRemoveArmed(armed) {
    if (barDragRemoveArmed === armed) return
    barDragRemoveArmed = armed
    fadeDragRoom(0)
    roomFader.start()
  }

  // Lets go of a widget pulled off the bar. It vanishes in a poof where it
  // was let go, its slot closing at once (ModuleSlot.removalPending), and
  // its entry leaves the layout once the poof has played.
  function removeBarDrag(sourceSlot) {
    barRemoval = { key: sourceSlot.widgetKey, region: sourceSlot.region, id: entryId(sourceSlot.entry) }
    // Up before the drag clears, so the ghost's surface never unmaps
    // between the ghost and the poof.
    playPoof()
    clearBarDrag()
    if (!barPoof) commitBarRemoval()
  }

  // Writes a removed widget out of the layout. Every other widget keeps its
  // instance through the write (BarModel.layoutWidgets), as with a move.
  function commitBarRemoval() {
    var removal = barRemoval
    barRemoval = null
    if (!removal) return
    var expected = JSON.parse(JSON.stringify(layoutWidgets.sections))
    var list = expected[removal.region] || []
    var index = list.indexOf(removal.key)
    if (index < 0) return
    list.splice(index, 1)
    writeLayout(expected, function(config) {
      BarModel.removeEntry(config, { region: removal.region, index: index, id: removal.id }, function(entry) { return Util.normalizeLayoutEntry(entry) })
    })
  }

  // Bursts out of the ghost where it was let go, so it runs before
  // clearBarDrag wipes the drag. With motion reduced there is nothing to play.
  function playPoof() {
    if (Style.duration(620) === 0) return
    barPoof = {
      screen: barDragScreen,
      x: barDragScreenX - barDragOffsetX + barDragGhostWidth / 2,
      y: barDragScreenY - barDragOffsetY + barDragGhostHeight / 2,
      width: barDragGhostWidth,
      height: barDragGhostHeight,
      image: barDragImageUrl,
      seed: Math.random()
    }
    poofTimer.restart()
  }

  // Outlives the poof's animation a little so its last frames aren't cut
  // off by the ghost's surface unmapping, and only then writes the removal:
  // persisting shell.json stalls the render loop for long enough to swallow
  // a poof still playing.
  Timer {
    id: poofTimer
    interval: Style.duration(620)
    onTriggered: {
      root.barPoof = null
      root.commitBarRemoval()
    }
  }

  function isPendingRemoval(key) {
    return !!barRemoval && barRemoval.key === key
  }

  function moduleTargetClickable(target) {
    return target
      && target.visible !== false
      && target.opacity !== 0
      && target.interactive !== false
      && target.pressable !== false
      && target.concealed !== true
      && typeof target.triggerPress === "function"
  }

  function moduleClickTargetAt(slot, localX, localY) {
    for (var i = clickTargets.length - 1; i >= 0; i--) {
      var target = clickTargets[i]
      if (!moduleTargetClickable(target)) continue

      if (Util.itemContainsPoint(target, slot, localX, localY)) {
        return target
      }
    }

    if (moduleTargetClickable(slot.activeItem)) return slot.activeItem
    return null
  }

  function pressModuleClickTarget(slot, button, localX, localY) {
    var target = moduleClickTargetAt(slot, localX, localY)
    if (!target) return false

    target.triggerPress(button)
    return true
  }

  function colorHex(colorValue) {
    var c = colorValue
    if (typeof c === "string") c = Qt.color(c)
    function hexChannel(value) {
      var s = Math.round(Util.clamp(value, 0, 1) * 255).toString(16)
      return s.length < 2 ? "0" + s : s
    }
    return "#" + hexChannel(c.r) + hexChannel(c.g) + hexChannel(c.b)
  }

  function setRequestedTransparency(value) {
    var nextTransparent = value === true
    requestedTransparent = nextTransparent
    if (!nextTransparent) {
      foregroundAnimationEnabled = false
      useTransparentForeground = false
      transparent = false
      transparentForeground = themeForeground
      restoreForegroundAnimation()
      return
    }
    scheduleTransparentForegroundRefresh()
  }

  function restoreForegroundAnimation() {
    Qt.callLater(function() {
      Qt.callLater(function() { root.foregroundAnimationEnabled = true })
    })
  }

  function scheduleTransparentForegroundRefresh() {
    if (!requestedTransparent) {
      transparentForeground = themeForeground
      return
    }
    transparentForegroundTimer.restart()
  }

  function refreshTransparentForeground() {
    if (!requestedTransparent || transparentForegroundProc.running) return

    transparentForegroundProc.command = [
      "omarchy-bar-text-color",
      root.position,
      String(root.barSize),
      colorHex(root.themeForeground),
      colorHex(root.themeContrastForeground)
    ]
    transparentForegroundProc.running = true
  }

  onRequestedTransparentChanged: scheduleTransparentForegroundRefresh()
  onPositionChanged: scheduleTransparentForegroundRefresh()
  onThemeForegroundChanged: scheduleTransparentForegroundRefresh()
  onThemeContrastForegroundChanged: scheduleTransparentForegroundRefresh()

  Timer {
    id: transparentForegroundTimer
    interval: 120
    repeat: false
    onTriggered: root.refreshTransparentForeground()
  }

  Process {
    id: transparentForegroundProc
    stdout: SplitParser {
      onRead: function(line) {
        var value = String(line || "").trim()
        if (!/^#[0-9A-Fa-f]{6}$/.test(value)) return

        root.foregroundAnimationEnabled = false
        root.transparentForeground = value
        if (root.requestedTransparent) {
          root.useTransparentForeground = true
          root.transparent = true
        }
        root.restoreForegroundAnimation()
      }
    }
  }

  FileView {
    path: root.stateHome + "/omarchy/current"
    watchChanges: true
    printErrors: false
    onFileChanged: root.scheduleTransparentForegroundRefresh()
  }

  function runProcess(process) {
    if (!process.running)
      process.running = true
  }

  function showTooltip(target, text) {
    // The delay only guards the first tooltip against a passing pointer. Once
    // one is up, or was a moment ago, the next icon's shows at once, so
    // sliding along the bar reads each label without waiting on every one.
    var warm = tooltipShown || tooltipWarmTimer.running
    clearTooltip()

    if (!targetTooltipHovered(target) || !text) {
      tooltipRequest += 1
      return
    }

    var request = tooltipRequest + 1
    tooltipRequest = request
    pendingTooltipTarget = target
    pendingTooltipText = text

    Qt.callLater(function() {
      if (request !== tooltipRequest) return
      if (!targetTooltipHovered(pendingTooltipTarget)) {
        clearTooltip()
        return
      }
      tooltipTarget = pendingTooltipTarget
      tooltipText = pendingTooltipText
      pendingTooltipTarget = null
      pendingTooltipText = ""
      if (warm) tooltipShown = true
      else tooltipTimer.restart()
    })
  }

  function hideTooltip(target) {
    if (tooltipTarget !== target && pendingTooltipTarget !== target) return

    tooltipRequest += 1
    clearTooltip()
  }

  Timer {
    id: tooltipTimer
    interval: 400
    onTriggered: {
      if (root.targetTooltipHovered(root.tooltipTarget)) root.tooltipShown = true
      else root.clearTooltip()
    }
  }

  // How long after a tooltip hides the next one still skips the delay. Long
  // enough to cross the gap between two icons, short enough that coming back
  // to the bar later waits again.
  Timer {
    id: tooltipWarmTimer
    interval: 400
  }

  Timer {
    interval: 100
    running: root.tooltipShown
    repeat: true
    onTriggered: if (!root.targetTooltipHovered(root.tooltipTarget)) root.hideTooltip(root.tooltipTarget)
  }

  // Presence of the `bar-off` flag = bar hidden. Watching the parent toggles
  // directory because FileView can't observe a file that doesn't exist yet,
  // and the flag is created/removed by `omarchy-toggle-bar`.
  Process {
    id: barHiddenProbe
    running: true
    command: ["bash", "-c", "[[ -f $HOME/.local/state/omarchy/toggles/bar-off ]] && echo yes || echo no"]
    stdout: SplitParser { onRead: function(line) { root.barHidden = String(line).trim() === "yes" } }
  }
  FileView {
    path: root.home + "/.local/state/omarchy/toggles"
    watchChanges: true
    printErrors: false
    onFileChanged: barHiddenProbe.running = true
  }

  // The directory watch can permanently stop delivering events after flag
  // changes land in quick succession, stranding the bar off screen until the
  // shell restarts. `omarchy-toggle-bar` nudges this after flipping the flag
  // so the probe re-reads it even when the watch has gone quiet.
  ShellIpc {
    target: "omarchy.bar"

    // Start rather than restart: a probe already in flight was launched by the
    // directory watch after the flag flipped, so its answer is current, and
    // killing it here can swallow the result entirely.
    function syncHidden(): void {
      barHiddenProbe.running = true
    }
  }

  Variants {
    model: Quickshell.screens

    delegate: Component {
      BarPanel {
        required property var modelData

        screen: modelData
      }
    }
  }

  Variants {
    model: Quickshell.screens

    delegate: Component {
      DragGhostPanel {
        required property var modelData

        screen: modelData
        ghostScreen: modelData
      }
    }
  }

  Variants {
    model: Quickshell.screens

    delegate: Component {
      BarMoveGhostPanel {
        required property var modelData

        screen: modelData
        ghostScreen: modelData
      }
    }
  }

  component BarPanel: PanelWindow {
    id: barWindow

    // Hiding parks the bar just past its screen edge instead of unmapping it.
    // Unmapping frees the layer surface and the whole scene graph, so every
    // reveal has to rebuild them — new surface, re-shaped glyphs, re-uploaded
    // textures — which measures ~150ms against ~20ms to tear down. Parking
    // keeps the surface alive, so showing is only a margin change.
    //
    // A top bar that can't tell its notch floor yet waits for Hyprland's mode
    // before it maps (see BarModel.cutoutPending), so it maps at its floor
    // instead of growing once the windows are laid out. The wait ends once, for
    // good: when the mode settles it, or after two seconds without one.
    visible: !remapGuard.remapping && (cutoutWaitOver || !cutoutPending)
    // An explicit zone instead of Auto: the reserved area stays the strip's
    // thickness though the window spans its screen.
    exclusionMode: root.barHidden ? ExclusionMode.Ignore : ExclusionMode.Normal
    exclusiveZone: thickness

    // While this window's widget or bar-move drag is live, the whole surface
    // takes input (mask below), so the pointer never leaves the bar surface
    // however far the drag goes. That is what keeps the gesture alive: while
    // nothing on the workspace holds keyboard focus (an empty workspace),
    // Hyprland picks a pointer target again on a surface commit, and a
    // pointer that has strayed onto another surface is pulled off the bar
    // mid-drag, ending the gesture with a synthesized release.
    // sameWindow, not identity: the drag records the QsWindow interface of
    // the slot's window, which is not this PanelWindow object itself.
    readonly property bool dragActive: (root.barDragSource !== null && root.sameWindow(root.barDragWindow, barWindow)) ||
      (root.barMoveActive && root.sameWindow(root.barMoveWindow, barWindow))

    ScreenMoveRemap {
      id: remapGuard
      window: barWindow
    }

    // Parked by the whole surface, which spans its screen, so none of it
    // stays on screen: not the strip, however thick a notch floor makes it,
    // nor the clear rest that a drag takes input on.
    readonly property real parkDistance: root.vertical ? implicitWidth : implicitHeight
    margins {
      top: root.barHidden && root.position === "top" ? -barWindow.parkDistance : 0
      bottom: root.barHidden && root.position === "bottom" ? -barWindow.parkDistance : 0
      left: root.barHidden && root.position === "left" ? -barWindow.parkDistance : 0
      right: root.barHidden && root.position === "right" ? -barWindow.parkDistance : 0
    }

    anchors {
      top: root.position === "top" || root.vertical
      bottom: root.position === "bottom" || root.vertical
      left: root.position === "left" || !root.vertical
      right: root.position === "right" || !root.vertical
    }

    readonly property var panelMode: root.panelModeFor(screen)

    readonly property bool centerBesideRight: BarModel.centerBesideRight(root.displayCutouts, root.position, screen.name, screen.width, screen.height, screen.devicePixelRatio, panelMode)

    readonly property bool cutoutPending: BarModel.cutoutPending(root.displayCutouts, root.position, screen.name, screen.width, screen.height, screen.devicePixelRatio, panelMode)
    property bool cutoutWaitOver: false
    onCutoutPendingChanged: if (!cutoutPending) cutoutWaitOver = true
    Component.onCompleted: if (!cutoutPending) cutoutWaitOver = true

    Timer {
      interval: 2000
      running: barWindow.cutoutPending && !barWindow.cutoutWaitOver
      onTriggered: barWindow.cutoutWaitOver = true
    }

    // The same thickness the bar publishes for its screen (screenBarSizes).
    readonly property int thickness: root.thicknessFor(screen)
    // Where the center box starts along the bar, set by the drawn center
    // sections. Hovering past it, over the clock, its trailing widgets and the
    // right section, leaves the indicator peek shut.
    property real peekEdge: 0

    // The surface spans its screen at all times, transparent past the strip
    // it paints; a drag toggles only its input region. Growing the surface
    // for a drag instead flashes the strip's stale buffer stretched across
    // the new size until the next frame lands, and the size can't come from
    // anchoring all four edges either, which would void the exclusive zone
    // (layer-shell reserves space from the one anchored edge) and drop tiled
    // windows behind the bar. Glassy blur stays on the strip: Hyprland's
    // ignore_alpha leaves the clear rest of the surface unblurred.
    implicitWidth: root.vertical ? (screen ? screen.width : thickness) : 0
    implicitHeight: root.vertical ? 0 : (screen ? screen.height : thickness)
    color: "transparent"
    surfaceFormat.opaque: false
    WlrLayershell.namespace: "omarchy-bar"
    WlrLayershell.layer: WlrLayer.Top

    // Idle, only the strip takes input, so the clear expanse passes clicks
    // through to the windows and desktop below.
    mask: dragActive ? null : stripInputRegion

    Region {
      id: stripInputRegion
      item: barStrip
    }

    // The bar itself, along its screen edge.
    Item {
      id: barStrip

      x: root.position === "right" ? parent.width - barWindow.thickness : 0
      y: root.position === "bottom" ? parent.height - barWindow.thickness : 0
      width: root.vertical ? barWindow.thickness : parent.width
      height: root.vertical ? parent.height : barWindow.thickness

      Rectangle {
        anchors.fill: parent
        color: root.transparent ? "transparent" : (root.glassy ? root.glassBackground : root.background)
      }

      Loader {
        anchors.fill: parent
        sourceComponent: root.vertical ? verticalBar : horizontalBar

        // A child of the loader, not a sibling of the sections: an ancestor stays
        // hovered while the pointer is over a widget, where a sibling would lose
        // hover to the section the pointer entered.
        HoverHandler {
          readonly property bool peeking: hovered && BarModel.peeksAt(point.position, barWindow.peekEdge, root.vertical)
          onPeekingChanged: root.setBarHovered(peeking)
          // Unplugging a monitor destroys its bar without a leave event, which
          // would strand this surface's tally and hold the peek open for good.
          Component.onDestruction: if (peeking) root.setBarHovered(false)
        }
      }
    }

    PopupWindow {
      id: tooltipWindow

      visible: root.tooltipShown && root.tooltipTarget !== null && root.tooltipText !== "" && root.targetBelongsToWindow(root.tooltipTarget, barWindow)
      color: "transparent"
      implicitWidth: Math.ceil(tooltipBubble.implicitWidth)
      implicitHeight: Math.ceil(tooltipBubble.implicitHeight)

      anchor {
        id: tooltipAnchor
        window: barWindow
        adjustment: PopupAdjustment.Slide
        edges: Edges.Top | Edges.Left
        gravity: Edges.Bottom | Edges.Right
        rect.width: 1
        rect.height: 1

        onAnchoring: {
          var target = root.tooltipTarget
          if (!root.targetBelongsToWindow(target, barWindow)) return

          var popupWidth = tooltipWindow.implicitWidth
          var popupHeight = tooltipWindow.implicitHeight
          var localX = target.width / 2 - popupWidth / 2
          var localY = target.height + 6

          if (root.position === "bottom") {
            localY = -popupHeight - 6
          } else if (root.position === "left") {
            localX = target.width + 6
            localY = target.height / 2 - popupHeight / 2
          } else if (root.position === "right") {
            localX = -popupWidth - 6
            localY = target.height / 2 - popupHeight / 2
          }

          var point = barWindow.contentItem.mapFromItem(target, localX, localY)
          tooltipAnchor.rect.x = Math.round(point.x)
          tooltipAnchor.rect.y = Math.round(point.y)
        }
      }

      BorderSurface {
        id: tooltipBubble
        implicitWidth: tooltipLabel.implicitWidth + 20
        implicitHeight: tooltipLabel.implicitHeight + 14
        color: Commons.Color.tooltip.background
        borderSpec: Border.surfaceSpec("tooltip", "border", Commons.Color.tooltip.border, 1)
        radius: Style.cornerRadius

        Text {
          id: tooltipLabel
          textFormat: Text.PlainText
          anchors.centerIn: parent
          text: root.tooltipText
          color: Commons.Color.tooltip.text
          font.family: root.fontFamily
          font.pixelSize: Style.font.body
          horizontalAlignment: Text.AlignHCenter
          verticalAlignment: Text.AlignVCenter
        }
      }
    }

    Component {
      id: horizontalBar

      Item {
        anchors.fill: parent

        WidgetPool { id: horizontalPool }

        CenterModules {
          anchors.fill: parent
          window: barWindow
          pool: horizontalPool
          drawn: !barWindow.centerBesideRight
        }

        LeftModules {
          window: barWindow
          pool: horizontalPool
          anchors.left: parent.left
          anchors.leftMargin: Style.space(8)
          anchors.verticalCenter: parent.verticalCenter
        }

        RightModules {
          window: barWindow
          pool: horizontalPool
          id: rightModules
          anchors.right: parent.right
          anchors.rightMargin: Style.space(8)
          anchors.verticalCenter: parent.verticalCenter
        }

        // Where a display notch covers the middle of the bar, the center
        // sections run on just left of the right one. They keep their regions,
        // so settings pushes, drag and drop, and panel routing still address
        // them. The gap lets a drop at the seam land in the section the pointer
        // is nearer to.
        CenterSections {
          window: barWindow
          pool: horizontalPool
          active: barWindow.centerBesideRight
          besideRight: true
          anchors.right: rightModules.left
          anchors.rightMargin: Style.space(4)
          anchors.top: parent.top
          anchors.bottom: parent.bottom
        }
      }
    }

    Component {
      id: verticalBar

      Item {
        anchors.fill: parent

        WidgetPool { id: verticalPool }

        CenterModules {
          anchors.fill: parent
          window: barWindow
          pool: verticalPool
        }

        LeftModules {
          window: barWindow
          pool: verticalPool
          anchors.top: parent.top
          anchors.topMargin: Style.space(8)
          anchors.horizontalCenter: parent.horizontalCenter
        }

        RightModules {
          window: barWindow
          pool: verticalPool
          anchors.bottom: parent.bottom
          anchors.bottomMargin: Style.space(8)
          anchors.horizontalCenter: parent.horizontalCenter
        }
      }
    }
  }

  Component { id: emptyModuleComponent; Item { implicitWidth: 0; implicitHeight: 0; visible: false } }

  component DragGhostPanel: PanelWindow {
    id: ghostWindow

    required property var ghostScreen
    readonly property bool active: !!root.barDragSource && root.sameScreen(root.barDragScreen, ghostScreen)
    readonly property var sourceItem: root.barDragSource ? root.barDragSource.activeItem : null
    readonly property bool poofShown: !!root.barPoof && root.sameScreen(root.barPoof.screen, ghostScreen)

    visible: (active && sourceItem !== null) || poofShown
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "omarchy-bar-drag-ghost"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    anchors {
      top: true
      bottom: true
      left: true
      right: true
    }

    // Visual-only drag feedback. Keep the input region empty so the ghost can
    // sit under the cursor without stealing the MouseArea's active pointer grab.
    mask: Region {}

    // The widget at its size in the bar, outlined like the room it leaves
    // and the room it would land in (DragSpacer).
    Item {
      visible: ghostWindow.active && ghostWindow.sourceItem !== null
      x: Math.round(root.barDragScreenX - root.barDragOffsetX)
      y: Math.round(root.barDragScreenY - root.barDragOffsetY)
      width: root.barDragGhostWidth
      height: root.barDragGhostHeight
      // Pulled past the removal threshold, the ghost shrinks and dims: let
      // go now and the widget poofs away instead of moving.
      scale: root.barDragRemoveArmed ? 0.82 : 1
      opacity: root.barDragRemoveArmed ? 0.55 : 1

      Behavior on scale { NumberAnimation { duration: Style.duration(140); easing.type: Easing.OutCubic } }
      Behavior on opacity { NumberAnimation { duration: Style.duration(140); easing.type: Easing.OutCubic } }

      RoomOutline { opacity: root.transparent ? 0.45 : 0.94 }

      Image {
        anchors.fill: parent
        source: root.barDragImageUrl
        fillMode: Image.Stretch
        smooth: true
        opacity: 0.84
      }
    }

    // The puff of smoke a widget pulled off the bar vanishes in. Its ghost
    // pops, swelling as it fades, while a cloud billows out of the space it
    // filled and thins away, throwing off a few specks. The cloud takes the
    // widget's own footprint, so a wide widget leaves a wide cloud, and is
    // laid out afresh for each poof so no two look alike.
    Item {
      id: poof

      // 0 to 1 through the poof. Each part runs on its own stretch of it.
      property real progress: 1
      // The poof playing here, kept through its last frames.
      property var spec: ({ x: 0, y: 0, width: 0, height: 0, image: "", seed: 0 })

      readonly property real spanX: Math.max(Style.spaceReal(16), poof.spec.width / 2)
      readonly property real spanY: Math.max(Style.spaceReal(16), poof.spec.height / 2)
      readonly property real puffSize: Util.clamp(Math.min(poof.spec.width, poof.spec.height) * 1.1, Style.spaceReal(16), Style.spaceReal(34))
      // Room around the puffs at their furthest, so the blur isn't clipped.
      readonly property real margin: puffSize * 1.4 + Style.spaceReal(16)

      // A steady pseudo-random 0 to 1 for part n of this poof.
      function noise(n) {
        var v = Math.sin(n * 12.9898 + poof.spec.seed * 78.233) * 43758.5453
        return v - Math.floor(v)
      }
      // How far along a part starting `from` and ending `to` is.
      function phase(from, to) {
        return Util.clamp((progress - from) / (to - from), 0, 1)
      }
      function outCubic(t) { return 1 - Math.pow(1 - t, 3) }
      function outBack(t) { return 1 + 2.4 * Math.pow(t - 1, 3) + 1.4 * Math.pow(t - 1, 2) }

      visible: ghostWindow.poofShown
      x: Math.round(poof.spec.x)
      y: Math.round(poof.spec.y)

      Connections {
        target: root
        function onBarPoofChanged() {
          if (!root.barPoof || !root.sameScreen(root.barPoof.screen, ghostWindow.ghostScreen)) return
          poof.spec = root.barPoof
          poofAnimation.restart()
        }
      }

      NumberAnimation {
        id: poofAnimation
        target: poof
        property: "progress"
        from: 0
        to: 1
        duration: Style.duration(560)
      }

      // The ghost, picking up as the drag left it.
      Image {
        readonly property real t: poof.outCubic(poof.phase(0, 0.3))

        width: poof.spec.width
        height: poof.spec.height
        x: -width / 2
        y: -height / 2
        source: poof.spec.image
        fillMode: Image.Stretch
        smooth: true
        scale: 0.82 + 0.45 * t
        opacity: 0.84 * 0.55 * (1 - t)
      }

      // Overlapping puffs blurred into one soft cloud, ringed faintly in the
      // bar's background so it reads over light windows and dark alike.
      Item {
        id: cloud

        width: (poof.spanX + poof.margin) * 2
        height: (poof.spanY + poof.margin) * 2
        x: -width / 2
        y: -height / 2
        // Built with the ghost's surface rather than at the release, which
        // would cost the poof its first frames while the effect sets up.
        // Until the poof plays the cloud holds nothing to draw.
        layer.enabled: ghostWindow.visible
        layer.effect: MultiEffect {
          blurEnabled: true
          blur: 0.6
          blurMax: 20
          shadowEnabled: true
          shadowColor: root.background
          shadowBlur: 0.9
          shadowOpacity: 0.7
          shadowHorizontalOffset: 0
          shadowVerticalOffset: 0
        }

        Repeater {
          model: 14

          Rectangle {
            required property int index
            // The first sits in the middle; the rest ring it unevenly.
            readonly property real angle: Math.PI * 2 * (index + poof.noise(index) * 0.7) / 13
            readonly property real reach: index === 0 ? 0 : 0.3 + 0.7 * poof.noise(index + 20)
            readonly property real begin: index === 0 ? 0 : 0.1 * poof.noise(index + 40)
            readonly property real end: 0.82 + 0.18 * poof.noise(index + 60)
            readonly property real t: poof.phase(begin, end)
            // Billows out fast, overshooting a touch, then drifts, rises and
            // swells as it thins, the way smoke spreads.
            readonly property real grow: poof.outBack(Math.min(1, t / 0.4))
            readonly property real size: poof.puffSize * (index === 0 ? 1.25 : 0.6 + 0.55 * poof.noise(index + 80)) * (0.3 + 0.8 * grow + 0.4 * t)
            readonly property real drift: 0.55 + 0.55 * poof.outCubic(t)

            width: size
            height: size
            radius: size / 2
            x: cloud.width / 2 + Math.cos(angle) * poof.spanX * reach * drift - size / 2
            y: cloud.height / 2 + Math.sin(angle) * poof.spanY * reach * drift - Style.spaceReal(10) * poof.outCubic(t) - size / 2
            color: root.barForeground
            // In at once, holding while it billows, thinning away after.
            opacity: Math.min(1, t / 0.08) * (1 - Math.pow(Math.max(0, t - 0.3) / 0.7, 1.4)) * 0.9
          }
        }
      }

      Repeater {
        model: 7

        Rectangle {
          required property int index
          readonly property real angle: Math.PI * 2 * (index + 0.5 + poof.noise(index + 100) * 0.6) / 7
          readonly property real reach: 1.15 + 0.6 * poof.noise(index + 120)
          readonly property real t: poof.phase(0.04, 0.7 + 0.2 * poof.noise(index + 140))
          readonly property real fly: poof.outCubic(t)
          readonly property real size: Style.spaceReal(2) + Style.spaceReal(1.5) * poof.noise(index + 160)

          width: size
          height: size
          radius: size / 2
          x: Math.cos(angle) * (poof.spanX + poof.puffSize * 0.6) * reach * fly - size / 2
          y: Math.sin(angle) * (poof.spanY + poof.puffSize * 0.6) * reach * fly - size / 2
          color: root.barForeground
          opacity: (t > 0 ? 1 : 0) * (1 - t) * 0.9
        }
      }
    }
  }

  component BarMoveGhostPanel: PanelWindow {
    id: moveGhostWindow

    required property var ghostScreen
    visible: root.barMoveActive && root.sameScreen(root.barMoveScreen, ghostScreen)
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "omarchy-bar-move-ghost"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    anchors {
      top: true
      bottom: true
      left: true
      right: true
    }

    // Visual-only preview of the candidate edge. Keep the input region empty
    // so the overlay never steals the gesture area's active pointer grab.
    mask: Region {}

    // One fixed-geometry slab per edge, crossfaded on candidate changes.
    // Resizing a single slab between edges repaints mid-transition and
    // flickers; fading between static ones does not.
    Repeater {
      model: ["top", "bottom", "left", "right"]

      BorderSurface {
        id: edgeSlab

        required property string modelData
        readonly property bool edgeVertical: modelData === "left" || modelData === "right"
        readonly property int edgeSize: edgeVertical ? Style.bar.sizeVertical : Style.bar.sizeHorizontal

        x: modelData === "right" ? parent.width - edgeSize : 0
        y: modelData === "bottom" ? parent.height - edgeSize : 0
        width: edgeVertical ? edgeSize : parent.width
        height: edgeVertical ? parent.height : edgeSize
        color: root.transparent ? "transparent" : root.background
        borderSpec: Border.flat(root.barForeground, 1)
        visible: opacity > 0
        opacity: root.barMoveCandidate === modelData ? (root.transparent ? 0.45 : 0.7) : 0

        Behavior on opacity {
          NumberAnimation { duration: Style.duration(140); easing.type: Easing.OutCubic }
        }
      }
    }
  }

  component LeftModules: ModuleList {
    keys: root.layoutWidgets.sections.left
    region: "left"
    fixedEdge: "start"
  }

  component RightModules: ModuleList {
    keys: root.layoutWidgets.sections.right
    region: "right"
    fixedEdge: "end"
  }

  // The gesture area under the whole bar, with the center sections drawn over
  // it in the middle of it.
  component CenterModules: Item {
    id: centerRoot

    property var window: null
    property var pool: null
    // False where a display notch has moved the center sections beside the
    // right one.
    property bool drawn: true

    CenterGestureArea { anchors.fill: parent }

    CenterSections {
      anchors.fill: parent
      window: centerRoot.window
      pool: centerRoot.pool
      active: centerRoot.drawn
    }
  }

  // The center box and the two sections hanging off its edges. In the middle
  // of the bar the box is centered, and centerBegin and centerEnd grow away
  // from it. Beside the right section the three run on as one, growing toward
  // the start of the bar. Placed by hand rather than by a Row or Column, which
  // cannot center one child and hang the others off it.
  component CenterSections: Item {
    id: sections

    property var window: null
    property var pool: null
    // Only one set of center sections per bar surface is active; the other
    // shows nothing.
    property bool active: true
    property bool besideRight: false

    implicitWidth: root.vertical ? root.barSize : beginList.width + centerBox.width + endList.width
    implicitHeight: root.vertical ? beginList.height + centerBox.height + endList.height : root.barSize

    // Both placements sit at the bar surface's origin or anchor off its edge,
    // so the box's start in the sections is its start on the surface.
    readonly property real boxStart: root.vertical ? y + centerBox.y : x + centerBox.x
    onBoxStartChanged: syncPeekEdge()
    onActiveChanged: syncPeekEdge()
    onWindowChanged: syncPeekEdge()
    Component.onCompleted: syncPeekEdge()

    function syncPeekEdge() {
      if (active && window) window.peekEdge = BarModel.nextPeekEdge(window.peekEdge, boxStart, root.centerSectionRevealHeld)
    }

    Connections {
      target: root
      function onCenterSectionRevealHeldChanged() { sections.syncPeekEdge() }
    }

    ModuleList {
      id: beginList
      keys: sections.active ? root.layoutWidgets.sections.centerBegin : []
      window: sections.active ? sections.window : null
      pool: sections.pool
      region: "centerBegin"
      fixedEdge: "end"
      x: root.vertical ? Math.round((sections.width - width) / 2) : centerBox.x - width
      y: root.vertical ? centerBox.y - height : Math.round((sections.height - height) / 2)
    }

    ModuleList {
      id: endList
      keys: sections.active ? root.layoutWidgets.sections.centerEnd : []
      window: sections.active ? sections.window : null
      pool: sections.pool
      region: "centerEnd"
      fixedEdge: sections.besideRight ? "end" : "start"
      x: root.vertical ? Math.round((sections.width - width) / 2) : centerBox.x + centerBox.width
      y: root.vertical ? centerBox.y + centerBox.height : Math.round((sections.height - height) / 2)
    }

    CenterBox {
      id: centerBox
      window: sections.window
      pool: sections.pool
      active: sections.active
      fixedEdge: sections.besideRight ? "end" : "center"
      crossSize: root.vertical ? sections.width : sections.height
      x: root.vertical ? 0 : (sections.besideRight ? beginList.width : Math.round((sections.width - width) / 2))
      y: root.vertical ? Math.round((sections.height - height) / 2) : 0
    }
  }

  // The middle of the bar: the center section's widgets, centered as one
  // group. Empty, it takes no room and the sections beside it meet in the
  // middle of the bar. During a drag on its bar it is outlined like the
  // widgets, around what it holds, a spacer for the dragged widget included,
  // and empty it shows as a line across the bar. A drop lands in it anywhere
  // within the bar's thickness of its middle (BarModel.centerDropZone).
  component CenterBox: Item {
    id: box

    property var window: null
    property var pool: null
    property bool active: true
    property string fixedEdge: "center"
    // The bar's thickness: the least length along the bar a drop into the
    // box reaches.
    property real crossSize: 0
    readonly property bool dragHere: active && !!root.barDragSource && root.sameWindow(root.barDragWindow, window)
    readonly property bool dropInto: dragHere && root.barDragRegion === "center"
    readonly property real extent: root.vertical ? boxList.height : boxList.width

    width: root.vertical ? crossSize : extent
    height: root.vertical ? extent : crossSize

    Component.onCompleted: root.registerCenterBox(box)
    Component.onDestruction: root.unregisterCenterBox(box)

    ModuleList {
      id: boxList
      keys: box.active ? root.layoutWidgets.sections.center : []
      window: box.active ? box.window : null
      pool: box.pool
      region: "center"
      fixedEdge: box.fixedEdge
      firstEdge: box.fixedEdge === "center" ? "end" : ""
      lastEdge: box.fixedEdge === "center" ? "start" : ""
      x: Math.round((box.width - width) / 2)
      y: Math.round((box.height - height) / 2)
    }

    DropOutline {
      visible: box.dragHere
      length: box.extent
      dropInto: box.dropInto
      x: root.vertical ? Math.round((box.width - across) / 2) : 0
      y: root.vertical ? 0 : Math.round((box.height - across) / 2)
    }
  }

  // The outline of a dragged widget's room, inset from its edges: on the
  // ghost, on the room it leaves, and on the room it would land in.
  component RoomOutline: BorderSurface {
    anchors.fill: parent
    anchors.margins: Style.space(1)
    color: root.transparent ? "transparent" : root.background
    borderSpec: Border.flat(root.barForeground, 1)
    radius: Math.min(Style.cornerRadius, Math.min(width, height) / 2)
    opacity: root.transparent ? 0.22 : 0.32
  }

  // The outline of a section a drop can go into, the center box or the tray
  // section, during a drag: as wide across the bar as the dragged widget's
  // outline, and `length` along it, or a line where that is nothing.
  component DropOutline: BorderSurface {
    property real length: 0
    property bool dropInto: false
    readonly property real across: Math.max(1, (root.vertical ? root.barDragGhostWidth : root.barDragGhostHeight) - Style.space(1) * 2)

    width: root.vertical ? across : Math.max(1, length)
    height: root.vertical ? Math.max(1, length) : across
    color: "transparent"
    borderSpec: Border.flat(dropInto ? Commons.Color.accent : root.barForeground, 1)
    radius: Math.min(Style.cornerRadius, Math.min(width, height) / 2)
    opacity: dropInto ? 1 : 0.5
  }

  // A section's share of the room a drag has opened at one place, with a
  // faint copy of the dragged widget in it. It lives in the section's model
  // only while the room covers its place, and its length follows the room.
  component DragSpacer: Item {
    id: spacer

    required property var modelData
    property string region: ""
    property var window: null
    readonly property int place: modelData.place
    readonly property var dragged: root.barDragSource
    // How much of the room is open here, along the bar.
    readonly property real length: dragged ? (root.barDragLengths[region + ":" + place] || 0) : 0

    clip: true
    implicitWidth: root.vertical ? (dragged ? dragged.widgetWidth : 0) : length
    implicitHeight: root.vertical ? length : (dragged ? dragged.widgetHeight : 0)
    Layout.preferredWidth: implicitWidth
    Layout.preferredHeight: implicitHeight
    Layout.alignment: Qt.AlignLeft | Qt.AlignTop

    Component.onCompleted: root.registerDragSpacer(spacer)
    Component.onDestruction: root.unregisterDragSpacer(spacer)

    RoomOutline {}

    Image {
      anchors.centerIn: parent
      width: spacer.dragged ? spacer.dragged.widgetWidth : 0
      height: spacer.dragged ? spacer.dragged.widgetHeight : 0
      source: root.barDragImageUrl
      fillMode: Image.Stretch
      smooth: true
      opacity: 0.22
    }
  }

  component CenterGestureArea: MouseArea {
    id: gestureArea

    property bool dragging: false
    property bool suppressClick: false
    property real pressedX: 0
    property real pressedY: 0
    readonly property real dragThreshold: Style.space(4)

    acceptedButtons: Qt.LeftButton
    cursorShape: dragging ? Qt.ClosedHandCursor : Qt.ArrowCursor
    pressAndHoldInterval: 200

    function startDrag(x, y) {
      if (dragging) return
      dragging = true
      root.beginBarMove(root.targetWindow(gestureArea))
      var scenePoint = gestureArea.mapToItem(null, x, y)
      root.updateBarMove(root.windowScreenPoint(scenePoint, root.barMoveWindow))
    }

    onPressed: function(mouse) {
      dragging = false
      suppressClick = false
      pressedX = mouse.x
      pressedY = mouse.y
    }

    onPressAndHold: function(mouse) {
      // A widget above us propagates its composed press-and-hold down here without
      // ever handing over the grab, so we'd get no release or cancel to end the move.
      if (!gestureArea.pressed) return
      startDrag(mouse.x, mouse.y)
    }

    onPositionChanged: function(mouse) {
      if (!(mouse.buttons & Qt.LeftButton)) return

      if (!dragging) {
        var distance = Math.abs(mouse.x - pressedX) + Math.abs(mouse.y - pressedY)
        if (distance < dragThreshold) return
        startDrag(mouse.x, mouse.y)
        return
      }

      var scenePoint = gestureArea.mapToItem(null, mouse.x, mouse.y)
      root.updateBarMove(root.windowScreenPoint(scenePoint, root.barMoveWindow))
    }

    onReleased: function(mouse) {
      if (!dragging) return
      dragging = false
      suppressClick = true
      root.finishBarMove()
      mouse.accepted = true
    }

    onCanceled: {
      dragging = false
      suppressClick = false
      root.clearBarMove()
    }

    onClicked: function(mouse) {
      if (suppressClick) {
        suppressClick = false
        mouse.accepted = true
      }
    }

    onDoubleClicked: function(mouse) {
      if (suppressClick) {
        suppressClick = false
        return
      }
      if (mouse.button === Qt.LeftButton) {
        root.cycleBackground()
        mouse.accepted = true
      }
    }
  }

  // A layout rather than a Row or Column: sizes drive it, so spacers and a
  // folding dragged widget move their neighbours as they grow and shrink,
  // and it keeps placing a widget folded to nothing where it left.
  component ModuleList: GridLayout {
    id: moduleListRoot

    // The widgets the list shows, by their keys (root.layoutWidgets).
    property var keys: []
    property string region: ""
    // The edge of each module that stays put when the module grows: the side
    // this list is anchored by. The centered box grows both ways.
    property string fixedEdge: "center"
    // The edges the first and last of several modules grow from instead, if
    // not the list's own: the centered box's outer modules grow away from the
    // middle of the bar, as centerBegin's and centerEnd's do
    // (BarModel.slotEdge).
    property string firstEdge: ""
    property string lastEdge: ""
    // The bar surface the list is drawn on, where a drag opens room in it.
    // Null for a list that isn't drawn.
    property var window: null
    // The bar surface's widgets, which the list's slots show (WidgetPool).
    property var pool: null
    // Kept between updates, so a row stays the same object for as long as it
    // is shown (BarModel.sectionRows).
    property var rowMemo: ({})
    readonly property var listRows: BarModel.sectionRows(keys, root.sectionSpacers(region, window), rowMemo)

    visible: listRows.length > 0
    flow: root.vertical ? GridLayout.TopToBottom : GridLayout.LeftToRight
    rowSpacing: 0
    columnSpacing: 0

    Repeater {
      // Keyed rows, so a config change or a drag only adds, moves and removes
      // the slots and spacers that changed. A list makes no slots while it is
      // hidden, where they would hold their widgets out of sight, or before it
      // has the pool its slots take their widgets from, as the tray's drawer
      // section until its slot hands it one.
      model: ScriptModel {
        objectProp: "key"
        values: moduleListRoot.visible && moduleListRoot.pool ? moduleListRoot.listRows : []
      }

      delegate: DelegateChooser {
        role: "kind"

        DelegateChoice {
          roleValue: "spacer"

          DragSpacer {
            region: moduleListRoot.region
            window: moduleListRoot.window
          }
        }

        DelegateChoice {
          ModuleSlot {
            required property var modelData
            widgetKey: modelData.key
            region: moduleListRoot.region
            fixedEdge: BarModel.slotEdge(moduleListRoot.keys.length, moduleListRoot.keys.indexOf(modelData.key), moduleListRoot.fixedEdge, moduleListRoot.firstEdge, moduleListRoot.lastEdge)
            pool: moduleListRoot.pool
            window: moduleListRoot.window
          }
        }
      }
    }
  }

  // The tray section's list, which the tray's slot draws inside the tray's
  // drawer and hands its bar surface's pool and window.
  Component {
    id: traySectionComponent

    ModuleList {
      keys: root.layoutWidgets.sections.tray
      region: "tray"
    }
  }

  // A bar surface's widgets: one for each entry in the layout, under the key
  // it keeps wherever it moves (root.layoutWidgets), and lent to the slot
  // that shows it in whichever section that is. A widget moved to another
  // section goes from the slot it leaves to the one made for it there,
  // rather than being built again. Between the two, as one section's list
  // lets go of it and the other's takes it up, it waits here, out of sight
  // and out of the pointer's way. It goes when its entry leaves the layout,
  // and with its bar surface.
  component WidgetPool: Item {
    id: widgetPool

    // Key -> its WidgetHost, and the ModuleSlot showing it.
    property var hosts: ({})
    property var slots: ({})

    width: 0
    height: 0
    clip: true

    // A slot for a key takes its widget, from the pool or from the slot that
    // had it, whichever of the two lists changes first.
    function claim(slot) {
      var key = slot.widgetKey
      var last = slots[key]
      if (last && last !== slot) last.host = null
      slots[key] = slot
      var host = hosts[key] || null
      slot.host = host
      if (host) host.owner = slot
    }

    function release(slot) {
      var key = slot.widgetKey
      if (slots[key] !== slot) return
      delete slots[key]
      slot.host = null
      if (hosts[key]) hosts[key].owner = null
    }

    function addHost(host) {
      hosts[host.key] = host
      var slot = slots[host.key] || null
      host.owner = slot
      if (slot) slot.host = host
    }

    function removeHost(host) {
      if (hosts[host.key] !== host) return
      delete hosts[host.key]
      var slot = slots[host.key]
      if (slot) slot.host = null
    }

    // Keys alone, in a fixed order: a widget's row never moves or changes,
    // and is added and removed with its entry.
    Instantiator {
      model: ScriptModel { values: root.layoutWidgets.keys }
      delegate: WidgetHost { pool: widgetPool }
    }
  }

  // One widget on a bar surface, loaded from its entry, and drawn in the slot
  // that holds it (WidgetPool). It hands the widget its settings, the bar,
  // and the edge its slot's section grows from.
  component WidgetHost: Item {
    id: host

    required property string modelData
    property var pool: null
    readonly property string key: modelData
    readonly property var entry: root.layoutWidgets.entries[key] || null
    // The slot showing it, set by the pool; null while it waits there.
    property var owner: null
    // Whether a slot has held it yet. The widget is loaded only then, so it
    // knows the edge its section grows from before it has a bar.
    property bool placed: false
    readonly property bool dragSource: !!owner && owner.dragSource
    // The edge it grows from, as the slot that last held it says.
    property string fixedEdge: "center"
    readonly property string moduleName: root.entryId(entry)
    readonly property var moduleSettings: root.entrySettings(entry)
    readonly property string customType: root.customModuleType(entry)
    readonly property var registryMetadata: root.barWidgetRegistry.metadataFor(root.canonicalWidgetId(moduleName))
    readonly property bool firstParty: registryMetadata && registryMetadata.firstParty === true
    readonly property string pluginApiId: registered ? root.canonicalWidgetId(moduleName) : "bar-entry:" + moduleName
    // Re-evaluate when the registry mutates (Component reference changes,
    // plugin enabled/disabled, etc.). Reading the `widgets` property creates
    // the binding dependency — the wrapped function call alone wouldn't.
    readonly property var registryComponent: {
      var w = root.barWidgetRegistry.widgets
      if (customType) return null
      var registryName = root.canonicalWidgetId(moduleName)
      return w[registryName] ? w[registryName].component : null
    }
    readonly property bool qmlCustom: customType === "qml"
    readonly property bool commandCustom: customType === "command"
    readonly property bool registered: registryComponent !== null
    readonly property var activeItem: {
      if (registered) return registryLoader.item
      if (qmlCustom) return qmlLoader.item
      return componentLoader.item
    }
    readonly property real widgetWidth: activeItem && activeItem.visible ? (root.vertical ? root.barSize : activeItem.implicitWidth) : 0
    readonly property real widgetHeight: activeItem && activeItem.visible ? activeItem.implicitHeight : 0

    parent: owner ? owner.widgetHolder : pool
    width: widgetWidth
    height: widgetHeight

    Component.onCompleted: {
      if (pool) pool.addHost(host)
      root.registerWidgetHost(host)
    }
    Component.onDestruction: {
      if (pool) pool.removeHost(host)
      root.unregisterWidgetHost(host)
    }

    // Waiting in the pool, it keeps the edge it had, so a widget handed from
    // one section to another hears only of the edge it lands with.
    onOwnerChanged: {
      if (!owner) {
        unplaced.restart()
        return
      }
      fixedEdge = owner.fixedEdge
      placed = true
    }
    // One no slot takes up again by the time the update is over, as one in
    // the tray's drawer while the tray is off the bar, is unloaded rather
    // than left running where nothing shows it, and loaded again when a slot
    // holds it.
    Timer {
      id: unplaced
      interval: 0
      onTriggered: if (!host.owner) host.placed = false
    }
    Connections {
      target: host.owner
      function onFixedEdgeChanged() { host.fixedEdge = host.owner.fixedEdge }
    }

    Loader {
      id: componentLoader
      active: host.placed && !host.qmlCustom && !host.registered
      sourceComponent: host.commandCustom ? customCommandModuleComponent : emptyModuleComponent
      width: host.widgetWidth
      height: host.widgetHeight
      opacity: host.dragSource ? 0.22 : 1.0
      onLoaded: {
        host.injectProps()
        Qt.callLater(host.injectProps)
      }
    }

    Loader {
      id: registryLoader
      active: host.placed && host.registered
      sourceComponent: host.registered ? host.registryComponent : null
      width: host.widgetWidth
      height: host.widgetHeight
      opacity: host.dragSource ? 0.22 : 1.0
      onLoaded: {
        host.injectProps()
        Qt.callLater(host.injectProps)
      }
    }

    Loader {
      id: qmlLoader
      active: host.placed && host.qmlCustom
      source: host.qmlCustom ? root.customModuleSource(host.entry) : ""
      width: host.widgetWidth
      height: host.widgetHeight
      opacity: host.dragSource ? 0.22 : 1.0
      onLoaded: {
        host.injectProps()
        Qt.callLater(host.injectProps)
      }
    }

    onActiveItemChanged: Qt.callLater(injectProps)
    onModuleSettingsChanged: injectProps()
    onFixedEdgeChanged: injectProps()

    function injectProps() {
      var target = activeItem
      if (!target) return
      // Ahead of bar: a widget can start laying itself out the moment it has
      // a bar, as the indicators do by reporting which are already active.
      if ("fixedEdge" in target) target.fixedEdge = fixedEdge
      if ("bar" in target) target.bar = firstParty
        ? root : root.pluginBarApiFor(pluginApiId, moduleName, registered)
      if ("moduleName" in target) target.moduleName = moduleName
      if ("settings" in target) target.settings = moduleSettings
    }

    Component {
      id: customCommandModuleComponent
      CustomCommandModule { entry: host.entry }
    }
  }

  // A widget's place in its section. It shows the widget its bar surface
  // keeps under its key, lent by the pool (WidgetPool), is sized by it, and
  // takes the pointer: clicks, the open-panel mark, and drags.
  component ModuleSlot: Item {
    id: slot

    property string widgetKey: ""
    property string region: ""
    property string fixedEdge: "center"
    property var pool: null
    // The bar surface its section is drawn on.
    property var window: null
    // The widget, while the slot holds it (WidgetPool.claim).
    property var host: null
    readonly property var entry: host ? host.entry : null
    readonly property string moduleName: host ? host.moduleName : ""
    readonly property var activeItem: host ? host.activeItem : null
    readonly property bool hovered: moduleHover.hovered
    readonly property bool dragSource: root.barDragSource === slot
    // A widget let go of past the removal threshold leaves the bar the
    // moment its poof starts, though its entry stays in the layout until
    // the poof has played.
    readonly property bool removalPending: root.isPendingRemoval(widgetKey)
    readonly property bool panelOpen: root.activePopout === slot.activeItem
    // Modules bigger than the mark they want (a text label in a padded slot,
    // a multi-line stack on a vertical bar) can say how long the open-panel
    // dot should be along the bar, so it tracks what the module paints
    // instead of a fraction of whatever slot it happens to fill.
    readonly property real panelIndicatorExtent: {
      var mark = panelIndicatorItem
      if (mark) return Math.max(Style.space(10), Math.round((root.vertical ? mark.height : mark.width) * 0.55))
      var key = root.vertical ? "openPanelIndicatorHeight" : "openPanelIndicatorWidth"
      var hint = activeItem && key in activeItem ? activeItem[key] : undefined
      if (hint !== undefined && hint !== null && hint > 0) return Math.round(hint)
      return Math.max(Style.space(10), Math.round((root.vertical ? slot.widgetHeight : slot.widgetWidth) * 0.55))
    }
    // A module holding several things a panel can open from (the tray's
    // icons) names the one whose panel is open, and the mark sits under it
    // rather than under the middle of the module.
    readonly property Item panelIndicatorItem: activeItem && "openPanelIndicatorItem" in activeItem ? activeItem.openPanelIndicatorItem : null
    readonly property real panelIndicatorCenter: {
      var mark = panelIndicatorItem
      if (!mark) return (root.vertical ? widgetArea.height : widgetArea.width) / 2
      // A menu opened while the drawer is still sliding open moves with it;
      // mapToItem alone would not re-run as the item moves.
      var reveal = "revealProgress" in activeItem ? activeItem.revealProgress : 0
      var point = mark.mapToItem(widgetArea, mark.width / 2, mark.height / 2)
      return root.vertical ? point.y : point.x
    }
    // The tray, or a clone of it, hosts the tray section in its drawer; one
    // inside the drawer does not, so the section never holds itself.
    readonly property bool hostsTraySection: region !== "tray" && !!activeItem && "sectionHost" in activeItem
    // Its drawer section is outlined while a widget that could go in it is
    // dragged on this bar, as the center box is.
    readonly property bool traySectionShown: hostsTraySection && root.traySectionDragActive && root.sameWindow(root.barDragWindow, window)
    // The part of the section the drawer shows, in the slot's widget area,
    // or null while the drawer hides all of it (the tray's sectionShown).
    readonly property var traySectionGeometry: {
      var shown = hostsTraySection ? activeItem.sectionShown : null
      if (!shown) return null
      return { x: holder.x + shown.x, y: holder.y + shown.y, width: shown.width, height: shown.height }
    }
    // Where the section is now, for a drop: as traySectionGeometry, or for a
    // tray cloned before trays said how much of it shows, the whole section.
    function traySectionNow() {
      if (!hostsTraySection) return null
      if ("sectionShown" in activeItem) return traySectionGeometry
      var area = activeItem.sectionHost
      if (!area) return null
      var point = area.mapToItem(widgetArea, 0, 0)
      return { x: point.x, y: point.y, width: area.width, height: area.height }
    }

    function traySectionContains(x, y) {
      var area = hostsTraySection ? activeItem.sectionHost : null
      if (!area || !area.visible || area.width <= 0 || area.height <= 0) return false
      var point = slot.mapToItem(area, x, y)
      return point.x >= 0 && point.y >= 0 && point.x <= area.width && point.y <= area.height
    }
    readonly property real widgetWidth: host ? host.widgetWidth : 0
    readonly property real widgetHeight: host ? host.widgetHeight : 0
    // Its length along the bar. The dragged widget keeps its place's share
    // of the room: all of it until the room moves away.
    readonly property real alongLength: removalPending ? 0 : dragSource
      ? (root.barDragLengths[root.barDragHome] || 0)
      : (root.vertical ? widgetHeight : widgetWidth)

    // Where the dragged widget lands when it goes back where it was.
    readonly property Item widgetRoom: widgetArea
    // Where the pool puts the widget.
    readonly property Item widgetHolder: holder
    // The section's layout sizes the slot by these, and lines slots up at
    // their start across the bar rather than centering them.
    // Handed to it as preferred sizes, since a layout left to read a size
    // that drops from a fraction of a pixel to nothing keeps the old size,
    // leaving a hole where a widget hid itself.
    implicitWidth: root.vertical ? widgetWidth : alongLength
    implicitHeight: root.vertical ? alongLength : widgetHeight
    Layout.preferredWidth: implicitWidth
    Layout.preferredHeight: implicitHeight
    Layout.alignment: Qt.AlignLeft | Qt.AlignTop
    z: modulePointer.dragging ? 100 : 0

    Component.onCompleted: {
      if (pool) pool.claim(slot)
      root.registerModuleSlot(slot)
    }
    Component.onDestruction: {
      // Later, since a slot goes while its section's model is being changed,
      // which the drag's room feeds.
      if (root.barDragSource === slot) Qt.callLater(root.clearBarDrag)
      if (pool) pool.release(slot)
      root.unregisterModuleSlot(slot)
    }

    HoverHandler { id: moduleHover }

    // The widget at its own size. Lifted out by a drag, it folds away with
    // its room.
    Item {
      id: widgetArea

      width: root.vertical ? slot.widgetWidth : slot.alongLength
      height: root.vertical ? slot.alongLength : slot.widgetHeight
      clip: slot.dragSource || slot.removalPending

      RoomOutline { visible: slot.dragSource }

      // Folding away under a drag, the slot keeps the widget centred, like
      // the copy in the room it opens (DragSpacer).
      Item {
        id: holder
        anchors.centerIn: parent
        width: slot.widgetWidth
        height: slot.widgetHeight
      }

      // The tray section's outline, as the center box's: around what it
      // holds, the room for the dragged widget included, or a line where it
      // holds nothing. Drawn over the tray rather than in its drawer, whose
      // clip would hide an empty section's line.
      DropOutline {
        readonly property var section: slot.traySectionGeometry || { x: 0, y: 0, width: 0, height: 0 }

        visible: slot.traySectionShown && !!slot.traySectionGeometry
        length: root.vertical ? section.height : section.width
        dropInto: root.barDragRegion === "tray"
        x: root.vertical ? Math.round((parent.width - across) / 2) : section.x
        y: root.vertical ? section.y : Math.round((parent.height - across) / 2)
        z: 40
      }

      Rectangle {
        id: openPanelIndicator

        readonly property int inset: Style.space(2)

        visible: opacity > 0
        opacity: slot.panelOpen && !slot.dragSource ? 0.9 : 0
        color: Commons.Color.accent
        radius: Math.min(width, height) / 2
        width: root.vertical ? Style.space(2) : slot.panelIndicatorExtent
        height: root.vertical ? slot.panelIndicatorExtent : Style.space(2)
        // The mark sits on the module's inner edge — the one facing the
        // desktop — so it underlines a top bar, overlines a bottom one, and
        // points inward from a left or right one. It reads as pointing at the
        // panel that opens on that side.
        // Snap toward the start of the slot, matching native glyph rendering.
        x: root.vertical
          ? (root.position === "left" ? parent.width - width - inset : inset)
          : Math.floor(slot.panelIndicatorCenter - width / 2)
        y: root.vertical
          ? Math.floor(slot.panelIndicatorCenter - height / 2)
          : (root.position === "top" ? parent.height - height - inset : inset)
        z: 50

        Behavior on opacity {
          NumberAnimation { duration: Style.duration(120); easing.type: Easing.OutCubic }
        }
      }
    }

    // The tray section's widgets, drawn inside the tray's drawer. They are
    // ordinary module slots of their own region, so they open panels, drag
    // and keep settings the way widgets on the bar do.
    // Built through a Component outside ModuleSlot: a module list holds
    // module slots, so one declared in here would make the types a cycle.
    Loader {
      id: traySectionLoader
      readonly property Item host: slot.hostsTraySection ? slot.activeItem.sectionHost : null
      parent: host || slot
      active: !!host
      sourceComponent: traySectionComponent
    }
    Binding { target: traySectionLoader.item; property: "window"; value: slot.window }
    Binding { target: traySectionLoader.item; property: "pool"; value: slot.pool }
    // Its widgets grow from the edge the tray anchors the section by.
    Binding { target: traySectionLoader.item; property: "fixedEdge"; value: slot.hostsTraySection && slot.activeItem.sectionEdge || "center" }

    MouseArea {
      id: modulePointer

      property bool dragging: false
      property bool suppressClick: false
      // This area sits over the slot's widget and takes its press, so the
      // widget never sees itself held; it's told, for its press feedback.
      property var heldTarget: null
      property real pressedX: 0
      property real pressedY: 0
      readonly property bool canReorder: root.shell && typeof root.shell.mutateShellConfig === "function"
      readonly property real dragThreshold: Style.space(4)

      anchors.fill: parent
      acceptedButtons: Qt.LeftButton
      // Sized by the widget, not the slot, which a drag can shrink to nothing
      // under the pointer that holds it.
      enabled: slot.visible && slot.widgetWidth > 0 && slot.widgetHeight > 0
      propagateComposedEvents: true
      // Only the hovered slot needs the hit test; without the guard every
      // slot on every monitor re-ran it on each click target change.
      cursorShape: moduleHover.hovered && root.moduleClickTargetAt(slot, mouseX, mouseY) ? Qt.PointingHandCursor : Qt.ArrowCursor
      // Do not assign drag.target here: the section's layout places
      // ModuleSlot, and moving slot.x/slot.y by hand fights it. The ghost
      // follows the pointer instead.

      onPressed: function(mouse) {
        // A press on a widget in the tray's drawer belongs to that widget's
        // own slot, underneath this one, so it drags that widget, not the tray.
        if (slot.traySectionContains(mouse.x, mouse.y)) {
          mouse.accepted = false
          return
        }
        dragging = false
        suppressClick = false
        pressedX = mouse.x
        pressedY = mouse.y
        hold(root.moduleClickTargetAt(slot, mouse.x, mouse.y))
        root.finishBarSettle()
        root.clearBarDrag()
      }

      function hold(target) {
        if (heldTarget && heldTarget !== target && "held" in heldTarget) heldTarget.held = false
        heldTarget = target && "held" in target ? target : null
        if (heldTarget) heldTarget.held = true
      }

      onPositionChanged: function(mouse) {
        if (!canReorder || !(mouse.buttons & Qt.LeftButton)) return

        var distance = Math.abs(mouse.x - pressedX) + Math.abs(mouse.y - pressedY)
        if (distance >= dragThreshold) {
          if (!dragging) root.beginBarDrag(slot, pressedX, pressedY)
          dragging = true
          hold(null)
          root.hideTooltip(slot.activeItem)
        }

        // A drag let go of from elsewhere (onLayoutWidgetsChanged) stays let
        // go of until the button comes up.
        if (dragging && root.barDragSource === slot) {
          var scenePoint = slot.mapToItem(null, mouse.x, mouse.y)
          var screenPoint = root.barDragScreenPoint(scenePoint)
          root.barDragSceneX = scenePoint.x
          root.barDragSceneY = scenePoint.y
          root.barDragScreenX = screenPoint.x
          root.barDragScreenY = screenPoint.y

          var drop = root.moduleDropAtScene(scenePoint, slot)
          root.barDragTarget = drop
          root.moveDragRoom(drop)
          root.setBarDragRemoveArmed(!drop && root.moduleRemoveDistance(screenPoint) >= root.barDragRemoveDistance)
        }
      }

      onReleased: function(mouse) {
        var wasDragging = dragging
        hold(null)

        dragging = false

        if (wasDragging) {
          suppressClick = true
          if (root.barDragSource === slot && root.barDragRemoveArmed) root.removeBarDrag(slot)
          else if (root.barDragSource === slot) root.settleBarDrag(slot)
          mouse.accepted = true
        } else {
          root.clearBarDrag()
          mouse.accepted = false
        }
      }

      onCanceled: {
        dragging = false
        suppressClick = false
        hold(null)
        root.clearBarDrag()
      }

      onClicked: function(mouse) {
        if (suppressClick) {
          suppressClick = false
          mouse.accepted = true
          return
        }

        if (!root.pressModuleClickTarget(slot, mouse.button, mouse.x, mouse.y)) mouse.accepted = false
      }
    }
  }

  component CustomCommandModule: WidgetButton {
    id: customRoot

    required property var entry
    // Writable, as on any widget: its host hands it the same values.
    property string moduleName: root.entryId(entry)
    property var settings: root.entrySettings(entry)
    property string outputText: ""
    property string outputTooltip: ""
    property bool outputActive: false

    function setting(name, fallback) {
      var value = settings ? settings[name] : undefined
      return value === undefined || value === null ? fallback : value
    }

    function update(raw) {
      var data = Util.parseModuleJson(raw)
      var klass = data.class || data.alt || ""

      outputText = data.text || String(raw || "").trim()
      outputTooltip = data.tooltip || String(setting("tooltip", ""))
      outputActive = klass === "active" || (Array.isArray(klass) && klass.indexOf("active") !== -1)
    }

    bar: root
    text: outputText || String(setting("text", ""))
    tooltipText: outputTooltip || String(setting("tooltip", ""))
    active: outputActive
    keepSpace: setting("keepSpace", false) === true
    horizontalMargin: Number(setting("horizontalMargin", 7.5))
    verticalPadding: Number(setting("verticalPadding", 6))
    fontSize: Number(setting("fontSize", 12))

    onPressed: function(button) {
      var command = ""
      if (button === Qt.RightButton)
        command = String(setting("onRightClick", ""))
      else if (button === Qt.MiddleButton)
        command = String(setting("onMiddleClick", ""))
      else
        command = String(setting("onClick", ""))

      if (command) root.run(command)
    }

    Process {
      id: customProc
      command: ["bash", "-lc", String(customRoot.setting("exec", ""))]
      stdout: StdioCollector {
        waitForEnd: true
        onStreamFinished: customRoot.update(text)
      }
    }

    Timer {
      interval: Math.max(1, Number(customRoot.setting("interval", 5))) * 1000
      running: String(customRoot.setting("exec", "")) !== ""
      repeat: true
      triggeredOnStart: true
      onTriggered: root.runProcess(customProc)
    }
  }
}
