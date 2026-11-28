import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Io
import qs.Commons
import qs.Commons as Commons
import qs.Ui
import "OverviewModel.js" as OverviewModel

Item {
  id: root
  property var shell: null
  property var manifest: null
  property bool opened: false
  property bool requested: false
  property string monitorName: ""
  property int workspaceId: -1
  property int viewedWorkspaceId: -1
  property int selectedIndex: -1
  property var windows: []
  property var monitorBlocks: ({})
  property var pendingMoves: ({})

  property bool dragActive: false
  property var draggedWindow: null
  property string dragAddress: ""
  property int dragSourceWorkspaceId: -1
  property point dragPoint: Qt.point(0, 0)
  property int hoveredDropWorkspaceId: -1
  property bool pendingRefresh: false

  property bool wsDragActive: false
  property var draggedWorkspaceEntry: null
  property int draggedWorkspaceId: -1
  property int wsDragFromIndex: -1
  property int wsDragTargetIndex: -1
  property int wsDragTargetId: -1
  property point wsDragPoint: Qt.point(0, 0)
  property int stripAutoScrollDir: 0
  property int optimisticActiveWorkspaceId: -1
  property double optimisticActiveAt: 0
  property double ignoreWorkspaceEventsUntil: 0

  readonly property int hyprlandActiveWorkspaceId: {
    var monitors = Hyprland.monitors.values
    for (var i = 0; i < monitors.length; i++) {
      if (monitors[i].name === root.monitorName && monitors[i].activeWorkspace)
        return Number(monitors[i].activeWorkspace.id)
    }
    return root.workspaceId
  }

  readonly property int activeHyprlandWorkspaceId: optimisticActiveWorkspaceId > 0
    ? optimisticActiveWorkspaceId
    : hyprlandActiveWorkspaceId

  readonly property var monitorBounds: {
    var m = panel.targetMonitor
    var ipc = m && m.lastIpcObject ? m.lastIpcObject : null
    if (!ipc) return { x: 0, y: 0, width: Math.max(1, panel.width), height: Math.max(1, panel.height) }
    var scale = Math.max(0.25, Number(ipc.scale || 1))
    var rotated = (Number(ipc.transform || 0) % 2) === 1
    var w = Number(rotated ? ipc.height : ipc.width) / scale
    var h = Number(rotated ? ipc.width : ipc.height) / scale
    return { x: Number(ipc.x || 0), y: Number(ipc.y || 0), width: Math.max(1, w), height: Math.max(1, h) }
  }

  readonly property var workspaceEntries: requested
    ? OverviewModel.workspaceEntries(
        Hyprland.workspaces.values,
        Hyprland.toplevels.values,
        monitorName,
        monitorBlocks,
        activeHyprlandWorkspaceId,
        pendingMoves)
    : []
  onWorkspaceEntriesChanged: syncDisplayWorkspaceEntries()

  // Keep the repeater's array instance stable during a workspace drag so the
  // pressed card delegate stays alive until release completes the reorder.
  property var displayWorkspaceEntries: []

  function syncDisplayWorkspaceEntries() {
    if (wsDragActive) return
    if (displayWorkspaceEntries !== workspaceEntries) displayWorkspaceEntries = workspaceEntries
  }

  Component.onCompleted: syncDisplayWorkspaceEntries()

  // A window can change workspace without changing the global toplevel list.
  // Keep the filter bound to each window's workspace while the overview is requested.
  readonly property var matchingWindows: requested
    ? OverviewModel.windowsOnWorkspace(Hyprland.toplevels.values, viewedWorkspaceId, pendingMoves) : []
  onMatchingWindowsChanged: if (opened) refresh()

  function workspaceEntryById(id) {
    var list = displayWorkspaceEntries
    for (var i = 0; i < list.length; i++) {
      if (list[i].id === id) return list[i]
    }
    return null
  }

  function workspaceLabel(entry, fallbackId) {
    if (entry && entry.slot > 0) return Commons.I18n.formatNumber(entry.slot)
    if (fallbackId > 0) return Commons.I18n.formatNumber(fallbackId)
    return ""
  }

  function appIconFor(window) {
    var appId = window && window.wayland ? String(window.wayland.appId || "") : ""
    if (!appId) return ""
    var entry = DesktopEntries.heuristicLookup(appId)
    var icon = entry && entry.icon ? entry.icon : appId
    if (root.shell && root.shell.appLibrary) return root.shell.appLibrary.iconSource(icon)
    return Quickshell.iconPath(icon, true)
  }

  function resetInteractionState() {
    dragActive = false
    draggedWindow = null
    dragAddress = ""
    dragSourceWorkspaceId = -1
    hoveredDropWorkspaceId = -1
    wsDragActive = false
    draggedWorkspaceEntry = null
    draggedWorkspaceId = -1
    wsDragFromIndex = -1
    wsDragTargetIndex = -1
    wsDragTargetId = -1
    stripAutoScrollDir = 0
    pendingRefresh = false
    syncDisplayWorkspaceEntries()
  }

  onOpenedChanged: if (opened) Qt.callLater(function() { revealWorkspaceCard(viewedWorkspaceId) })
  onViewedWorkspaceIdChanged: if (opened) Qt.callLater(function() { revealWorkspaceCard(viewedWorkspaceId) })

  function scrollStripTo(nextX) {
    workspaceStripViewport.contentX = Math.max(0, Math.min(workspaceStripViewport.maxContentX, nextX))
  }

  function scrollStripBy(delta) {
    scrollStripTo(workspaceStripViewport.contentX + delta)
  }

  function revealWorkspaceCard(targetId) {
    if (!workspaceStripShell.overflows) {
      workspaceStripViewport.contentX = 0
      return
    }
    var targetItem = null
    for (var i = 0; i < workspaceRepeater.count; i++) {
      var item = workspaceRepeater.itemAt(i)
      if (item && item.workspaceId === targetId) {
        targetItem = item
        break
      }
    }
    if (!targetItem) {
      scrollStripTo(workspaceRow.LayoutMirroring.enabled ? workspaceStripViewport.maxContentX : 0)
      return
    }
    var left = targetItem.x
    var right = targetItem.x + targetItem.width
    var viewLeft = workspaceStripViewport.contentX
    var viewRight = viewLeft + workspaceStripViewport.width
    if (left < viewLeft) scrollStripTo(left)
    else if (right > viewRight) scrollStripTo(right - workspaceStripViewport.width)
    else scrollStripTo(viewLeft)
  }

  function dragStripAutoScrollDir(pointInCatcher) {
    if (!workspaceStripShell.overflows || (!dragActive && !wsDragActive)) return 0
    var vp = workspaceStripViewport.mapFromItem(keyCatcher, pointInCatcher.x, pointInCatcher.y)
    if (vp.y < -Style.space(48) || vp.y > workspaceStripViewport.height + Style.space(64)) return 0
    var zone = Math.min(Style.space(56), workspaceStripViewport.width * 0.25)
    var outer = workspaceStripShell.scrollButtonWidth + workspaceStripShell.scrollButtonGap + Style.space(24)
    if (vp.x >= -outer && vp.x <= zone && workspaceStripViewport.contentX > 0.5) return -1
    if (vp.x >= workspaceStripViewport.width - zone && vp.x <= workspaceStripViewport.width + outer
        && workspaceStripViewport.contentX < workspaceStripViewport.maxContentX - 0.5) return 1
    return 0
  }

  function open(payloadJson) {
    var monitor = Hyprland.focusedMonitor
    if (!monitor || !monitor.activeWorkspace || modeRead.running) return
    monitorName = monitor.name
    workspaceId = Number(monitor.activeWorkspace.id)
    if (workspaceId < 1) return
    viewedWorkspaceId = workspaceId
    pendingMoves = ({})
    optimisticActiveWorkspaceId = -1
    optimisticActiveAt = 0
    ignoreWorkspaceEventsUntil = 0
    resetInteractionState()
    requested = true
    Hyprland.refreshWorkspaces()
    Hyprland.refreshToplevels()
    modeRead.command = ["omarchy-hyprland-workspace-layout-current", String(workspaceId)]
    modeRead.running = true
  }
  function close() {
    requested = false
    opened = false
    resetInteractionState()
    pendingMoves = ({})
    optimisticActiveWorkspaceId = -1
    optimisticActiveAt = 0
    ignoreWorkspaceEventsUntil = 0
    windows = []
  }
  function refresh() {
    if (dragActive || wsDragActive) {
      pendingRefresh = true
      return
    }
    syncDisplayWorkspaceEntries()
    var next = matchingWindows
    selectedIndex = OverviewModel.selectionAfterChange(windows, selectedIndex, next)
    windows = next
  }
  function choose(index) {
    var window = windows[index]
    if (!window || !window.wayland || !matchingWindows.includes(window)) return
    close()
    Qt.callLater(function() { if (window.wayland) window.wayland.activate() })
  }

  function selectWorkspace(targetId) {
    switchToWorkspace(targetId)
  }

  function switchToWorkspace(targetId) {
    if (!(targetId >= 1)) return
    var entry = workspaceEntryById(targetId)
    var targetMonitorName = monitorName
    close()
    Qt.callLater(function() {
      if (entry && !entry.guest && targetMonitorName) {
        Hyprland.dispatch("o.workspaces.focus(" + entry.slot + ", " + JSON.stringify(targetMonitorName) + ")")
      } else {
        Hyprland.dispatch("hl.dsp.focus({ workspace = " + JSON.stringify(String(targetId)) + " })")
      }
    })
  }

  function beginDrag(window, pointInCatcher) {
    if (!window || wsDragActive) return
    draggedWindow = window
    dragAddress = OverviewModel.normalizeAddress(window.address)
    dragSourceWorkspaceId = OverviewModel.effectiveWorkspaceId(window, pendingMoves)
    dragPoint = pointInCatcher
    dragActive = true
    updateDropTarget(pointInCatcher)
    stripAutoScrollDir = dragStripAutoScrollDir(pointInCatcher)
  }

  function updateDrag(pointInCatcher) {
    if (!dragActive) return
    dragPoint = pointInCatcher
    updateDropTarget(pointInCatcher)
    stripAutoScrollDir = dragStripAutoScrollDir(pointInCatcher)
  }

  function updateDropTarget(pointInCatcher) {
    var hitId = -1
    var bestDistance = Infinity
    var pad = Style.space(6)
    if (workspaceStripShell.overflows) {
      var vp = workspaceStripViewport.mapFromItem(keyCatcher, pointInCatcher.x, pointInCatcher.y)
      if (vp.x < -pad || vp.x > workspaceStripViewport.width + pad
          || vp.y < -pad || vp.y > workspaceStripViewport.height + pad) {
        hoveredDropWorkspaceId = -1
        return
      }
    }
    for (var i = 0; i < workspaceRepeater.count; i++) {
      var item = workspaceRepeater.itemAt(i)
      if (!item) continue
      var local = item.mapFromItem(keyCatcher, pointInCatcher.x, pointInCatcher.y)
      if (local.x >= -pad && local.x <= item.width + pad
          && local.y >= -pad && local.y <= item.height + pad) {
        var distance = Math.abs(local.x - item.width / 2)
        if (distance < bestDistance) {
          bestDistance = distance
          hitId = item.workspaceId
        }
      }
    }
    hoveredDropWorkspaceId = hitId
  }

  function cancelDrag() {
    dragActive = false
    draggedWindow = null
    dragAddress = ""
    dragSourceWorkspaceId = -1
    hoveredDropWorkspaceId = -1
    stripAutoScrollDir = 0
    if (pendingRefresh && opened) {
      pendingRefresh = false
      refresh()
    }
  }

  function finishDrag() {
    if (!dragActive) return
    var win = draggedWindow
    var targetId = hoveredDropWorkspaceId
    var sourceId = dragSourceWorkspaceId
    cancelDrag()
    if (win && targetId > 0 && targetId !== sourceId) {
      moveWindowToWorkspace(win, targetId)
    }
  }

  function beginWorkspaceDrag(entry, index, pointInCatcher) {
    if (!entry || entry.guest || entry.isNewSlot || dragActive) return
    draggedWorkspaceEntry = entry
    draggedWorkspaceId = entry.id
    wsDragFromIndex = index
    wsDragPoint = pointInCatcher
    wsDragActive = true
    updateWorkspaceDropTarget(pointInCatcher)
    stripAutoScrollDir = dragStripAutoScrollDir(pointInCatcher)
  }

  function updateWorkspaceDrag(pointInCatcher) {
    if (!wsDragActive) return
    wsDragPoint = pointInCatcher
    updateWorkspaceDropTarget(pointInCatcher)
    stripAutoScrollDir = dragStripAutoScrollDir(pointInCatcher)
  }

  function updateWorkspaceDropTarget(pointInCatcher) {
    if (workspaceStripShell.overflows) {
      var vp = workspaceStripViewport.mapFromItem(keyCatcher, pointInCatcher.x, pointInCatcher.y)
      var edgeMargin = workspaceStripShell.scrollButtonWidth + workspaceStripShell.scrollButtonGap + Style.space(24)
      if (vp.x < -edgeMargin || vp.x > workspaceStripViewport.width + edgeMargin) {
        wsDragTargetIndex = -1
        wsDragTargetId = -1
        return
      }
    }
    var local = workspaceRow.mapFromItem(keyCatcher, pointInCatcher.x, pointInCatcher.y)
    var target = OverviewModel.workspaceDropTarget(
      displayWorkspaceEntries,
      local.x,
      local.y,
      workspaceRow.width,
      workspaceRow.height,
      workspaceRow.cardWidth,
      workspaceRow.spacing,
      workspaceRow.LayoutMirroring.enabled,
      Style.space(64),
      Style.space(80))
    wsDragTargetIndex = target.index
    wsDragTargetId = target.id
  }

  function cancelWorkspaceDrag() {
    wsDragActive = false
    draggedWorkspaceEntry = null
    draggedWorkspaceId = -1
    wsDragFromIndex = -1
    wsDragTargetIndex = -1
    wsDragTargetId = -1
    stripAutoScrollDir = 0
    syncDisplayWorkspaceEntries()
    if (pendingRefresh && opened) {
      pendingRefresh = false
      refresh()
    }
  }

  function finishWorkspaceDrag() {
    if (!wsDragActive) return
    var sourceId = draggedWorkspaceId
    var targetId = wsDragTargetId
    cancelWorkspaceDrag()
    if (sourceId > 0 && targetId > 0 && sourceId !== targetId) {
      reorderWorkspace(sourceId, targetId)
    }
  }

  function moveWindowToWorkspace(window, targetWorkspaceId) {
    var addr = OverviewModel.normalizeAddress(window && window.address)
    var wsId = Number(targetWorkspaceId)
    if (!addr || !(wsId >= 1)) return
    var next = Object.assign({}, pendingMoves)
    next[addr] = { targetWorkspaceId: wsId, at: Date.now() }
    pendingMoves = next
    pendingRefresh = false
    refresh()
    Hyprland.dispatch("hl.dsp.window.move({ window = " + JSON.stringify("address:" + addr) + ", workspace = " + JSON.stringify(String(wsId)) + ", follow = false })")
    moveSettleTimer.restart()
    windowRefresh.restart()
  }

  function reorderWorkspace(sourceWorkspaceId, targetWorkspaceId) {
    var plan = OverviewModel.reorderWorkspacePlan(
      workspaceEntries,
      sourceWorkspaceId,
      targetWorkspaceId,
      Hyprland.workspaces.values,
      Hyprland.toplevels.values,
      pendingMoves)
    if (!plan) return

    var now = Date.now()
    pendingMoves = OverviewModel.applyWindowMoves(pendingMoves, plan.windowMoves, now)
    var currentActive = activeHyprlandWorkspaceId
    var nextActive = plan.idMap[currentActive]
    if (nextActive > 0 && nextActive !== currentActive) {
      optimisticActiveWorkspaceId = nextActive
      optimisticActiveAt = now
    }
    if (plan.idMap[workspaceId] > 0) workspaceId = plan.idMap[workspaceId]
    if (plan.idMap[viewedWorkspaceId] > 0) viewedWorkspaceId = plan.idMap[viewedWorkspaceId]
    ignoreWorkspaceEventsUntil = now + 500
    selectedIndex = -1
    pendingRefresh = false
    refresh()

    Hyprland.dispatch(plan.luaDispatch)
    moveSettleTimer.restart()
    windowRefresh.restart()
  }

  function reconcilePendingMoves() {
    var now = Date.now()
    if (optimisticActiveWorkspaceId > 0) {
      if (hyprlandActiveWorkspaceId === optimisticActiveWorkspaceId || (now - optimisticActiveAt) >= 1500) {
        optimisticActiveWorkspaceId = -1
        optimisticActiveAt = 0
      }
    }
    var keys = Object.keys(pendingMoves)
    if (!keys.length) return
    var byAddr = {}
    var toplevels = Hyprland.toplevels.values
    for (var i = 0; i < toplevels.length; i++) {
      var norm = OverviewModel.normalizeAddress(toplevels[i].address)
      if (norm) byAddr[norm] = toplevels[i]
    }
    var next = {}
    var changed = false
    for (var j = 0; j < keys.length; j++) {
      var addr = keys[j]
      var move = pendingMoves[addr]
      var win = byAddr[addr]
      var actual = win && win.workspace ? Number(win.workspace.id) : -1
      if (win && actual !== move.targetWorkspaceId && (now - move.at) < 1500) {
        next[addr] = move
      } else {
        changed = true
      }
    }
    if (changed) pendingMoves = next
  }

  component MiniDesktopPreview: Item {
    id: miniRoot
    property var rects: []
    Repeater {
      model: miniRoot.rects
      delegate: Rectangle {
        required property var modelData
        x: Math.round(modelData.x * miniRoot.width)
        y: Math.round(modelData.y * miniRoot.height)
        width: Math.max(Style.space(8), Math.round(modelData.width * miniRoot.width))
        height: Math.max(Style.space(6), Math.round(modelData.height * miniRoot.height))
        radius: Math.max(2, Math.min(4, Style.cornerRadius))
        color: Util.alpha(Commons.Color.foreground, 0.16)
        border.color: Util.alpha(Commons.Color.foreground, 0.42)
        border.width: 1
        Rectangle {
          anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
          height: Math.min(2, parent.height)
          color: Util.alpha(Commons.Color.accent, 0.55)
        }
      }
    }
  }

  component WindowCardContent: Item {
    id: content
    property var windowData: null
    property bool liveCapture: false
    property real padding: Style.space(8)
    property real footerHeight: Style.space(36)
    property real fallbackIconMax: Style.space(56)
    property int titlePixelSize: Style.font.body
    property bool showFooterIcon: true
    readonly property string iconSrc: windowData ? root.appIconFor(windowData) : ""

    ScreencopyView {
      id: preview
      captureSource: content.liveCapture && content.windowData ? content.windowData.wayland : null
      live: content.liveCapture
      readonly property real ratio: sourceSize.height > 0 ? sourceSize.width / sourceSize.height : 1.6
      width: Math.min(content.width - content.padding * 2, Math.max(1, content.height - content.footerHeight - content.padding) * ratio)
      height: width / ratio
      anchors.horizontalCenter: parent.horizontalCenter
      y: content.padding
    }
    Image {
      visible: content.liveCapture && (!preview.hasContent || preview.sourceSize.width <= 0) && content.iconSrc.length > 0
      source: content.iconSrc
      width: Math.min(content.fallbackIconMax, Math.max(Style.space(24), content.height * 0.34))
      height: width
      sourceSize: Qt.size(width * 2, height * 2)
      anchors.horizontalCenter: parent.horizontalCenter
      y: Math.max(content.padding, (content.height - content.footerHeight - height) / 2)
      fillMode: Image.PreserveAspectFit
      smooth: true
      mipmap: true
    }
    Row {
      anchors.left: parent.left; anchors.right: parent.right; anchors.bottom: parent.bottom
      anchors.margins: content.padding + Style.space(2)
      spacing: Style.space(6)
      Image {
        id: footerIcon
        visible: content.showFooterIcon && content.iconSrc.length > 0
        source: content.iconSrc
        width: Style.space(16); height: Style.space(16)
        sourceSize: Qt.size(32, 32)
        anchors.verticalCenter: parent.verticalCenter
        fillMode: Image.PreserveAspectFit
        smooth: true
        mipmap: true
      }
      Text {
        width: parent.width - (footerIcon.visible ? footerIcon.width + parent.spacing : 0)
        anchors.verticalCenter: parent.verticalCenter
        text: content.windowData && content.windowData.wayland ? content.windowData.wayland.title : ""
        textFormat: Text.PlainText
        color: Commons.Color.foreground
        font.family: Style.font.family
        font.pixelSize: content.titlePixelSize
        elide: Text.ElideRight
        horizontalAlignment: footerIcon.visible ? Text.AlignLeft : Text.AlignHCenter
      }
    }
  }

  FileView {
    path: (Quickshell.env("XDG_STATE_HOME") || Quickshell.env("HOME") + "/.local/state") + "/omarchy/monitors/workspaces"
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: root.monitorBlocks = OverviewModel.parseMonitorBlocks(text())
    onLoadFailed: root.monitorBlocks = ({})
  }

  Timer {
    id: windowRefresh
    interval: 80
    onTriggered: {
      Hyprland.refreshMonitors()
      Hyprland.refreshWorkspaces()
      Hyprland.refreshToplevels()
    }
  }

  Timer {
    id: moveSettleTimer
    interval: 400
    repeat: true
    running: Object.keys(root.pendingMoves).length > 0 || root.optimisticActiveWorkspaceId > 0
    onTriggered: root.reconcilePendingMoves()
  }

  Connections {
    target: Hyprland.toplevels
    function onValuesChanged() { root.reconcilePendingMoves() }
  }

  Timer {
    id: stripAutoScrollTimer
    interval: 16
    repeat: true
    running: root.opened && workspaceStripShell.overflows && (root.dragActive || root.wsDragActive) && root.stripAutoScrollDir !== 0
    onTriggered: {
      var step = Math.max(4, Math.round(Style.space(10)))
      root.scrollStripBy(root.stripAutoScrollDir * step)
      if (root.dragActive) root.updateDropTarget(root.dragPoint)
      else if (root.wsDragActive) root.updateWorkspaceDropTarget(root.wsDragPoint)
      root.stripAutoScrollDir = root.dragStripAutoScrollDir(root.dragActive ? root.dragPoint : root.wsDragPoint)
    }
  }

  Process {
    id: modeRead
    stdout: StdioCollector {
      onStreamFinished: {
        var monitor = Hyprland.focusedMonitor
        if (!root.requested || text.trim() !== "floating" || !monitor
            || monitor.name !== root.monitorName || !monitor.activeWorkspace
            || Number(monitor.activeWorkspace.id) !== root.workspaceId) return
        root.refresh()
        root.opened = true
        Qt.callLater(function() { keyCatcher.forceActiveFocus() })
      }
    }
  }
  Connections {
    target: Hyprland
    function onFocusedMonitorChanged() {
      if (Hyprland.focusedMonitor && Hyprland.focusedMonitor.name !== root.monitorName) root.close()
    }
    function onRawEvent(event) {
      if (!root.opened && !root.requested) return
      var name = event ? String(event.name) : ""
      if ((name === "workspace" || name === "workspacev2") && Date.now() < root.ignoreWorkspaceEventsUntil) {
        windowRefresh.restart()
      } else if (name === "workspace" || name === "workspacev2" || name === "monitorremoved") {
        root.close()
      } else if (name === "movewindow" || name === "movewindowv2" || name === "openwindow"
          || name === "closewindow" || name === "createworkspace" || name === "destroyworkspace"
          || name === "changeworkspaceid" || name === "moveworkspacev2") {
        windowRefresh.restart()
      }
    }
  }

  OverlayWindow {
    id: panel
    shown: root.opened
    WlrLayershell.namespace: "omarchy-window-overview"
    Rectangle {
      anchors.fill: parent
      color: Qt.rgba(Commons.Color.background.r, Commons.Color.background.g, Commons.Color.background.b, 0.94)
    }
    MouseArea {
      anchors.fill: parent
      onClicked: if (!root.dragActive && !root.wsDragActive) root.close()
    }
    FocusScope {
      id: keyCatcher
      anchors.fill: parent
      focus: true
      Keys.onPressed: function(event) {
        var key = Util.readingKey(event)
        if (key === Qt.Key_Escape) {
          if (root.dragActive) root.cancelDrag()
          else if (root.wsDragActive) root.cancelWorkspaceDrag()
          else root.close()
        } else if (key === Qt.Key_Return || key === Qt.Key_Enter) {
          if (root.windows.length) root.choose(root.selectedIndex)
          else if (root.viewedWorkspaceId > 0) root.switchToWorkspace(root.viewedWorkspaceId)
        } else if (root.windows.length && [Qt.Key_Left, Qt.Key_Right, Qt.Key_Up, Qt.Key_Down, Qt.Key_Tab, Qt.Key_Backtab].indexOf(key) >= 0) {
          var step = key === Qt.Key_Up ? -layout.columns : key === Qt.Key_Down ? layout.columns
            : key === Qt.Key_Left || key === Qt.Key_Backtab || (key === Qt.Key_Tab && event.modifiers & Qt.ShiftModifier) ? -1 : 1
          root.selectedIndex = OverviewModel.moveSelection(root.selectedIndex, step, root.windows.length)
        } else return
        event.accepted = true
      }

      Column {
        id: workspaceStripArea
        anchors.top: parent.top
        anchors.topMargin: layout.snap(Style.space(24))
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: layout.snap(Style.space(10))

        Item {
          id: workspaceStripShell
          anchors.horizontalCenter: parent.horizontalCenter
          readonly property real maxWidth: Math.max(1, panel.width - Math.min(Style.space(80), Math.round(panel.width * 0.1)))
          readonly property bool overflows: workspaceRow.totalWidth > maxWidth + 0.5
          readonly property real scrollButtonWidth: overflows ? layout.snap(Style.space(28)) : 0
          readonly property real scrollButtonGap: overflows ? layout.snap(Style.space(8)) : 0
          readonly property real viewportMaxWidth: Math.max(1, maxWidth - 2 * (scrollButtonWidth + scrollButtonGap))
          width: Math.min(maxWidth, workspaceStripViewport.width + 2 * (scrollButtonWidth + scrollButtonGap))
          height: workspaceStripViewport.height

          BorderSurface {
            id: leftScrollButton
            visible: workspaceStripShell.overflows
            x: 0
            y: workspaceStripViewport.vPad
            width: workspaceStripShell.scrollButtonWidth
            height: workspaceRow.cardHeight
            radius: Style.cornerRadius
            antialiasing: true
            border.pixelAligned: false
            readonly property bool canScroll: workspaceStripViewport.contentX > 0.5
            opacity: canScroll ? (leftScrollMouse.containsMouse ? 1.0 : 0.85) : 0.35
            Behavior on opacity {
              NumberAnimation { duration: Style.duration(140); easing.type: Easing.OutCubic }
            }
            color: leftScrollMouse.containsMouse && canScroll
              ? Util.alpha(Commons.Color.foreground, 0.10)
              : Commons.Color.popups.background
            borderSpec: leftScrollMouse.containsMouse && canScroll
              ? Border.surfaceSpec("hyprland", "inactive-border", Commons.Color.foreground, Style.normalBorderWidth)
              : Border.surfaceSpec("hyprland", "inactive-border", Commons.Color.muted, Style.normalBorderWidth)
            Text {
              anchors.centerIn: parent
              text: "‹"
              textFormat: Text.PlainText
              color: leftScrollButton.canScroll ? Commons.Color.foreground : Commons.Color.muted
              font.family: Style.font.family
              font.pixelSize: Style.font.heading
            }
            MouseArea {
              id: leftScrollMouse
              anchors.fill: parent
              hoverEnabled: true
              enabled: leftScrollButton.canScroll
              cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
              onClicked: root.scrollStripBy(-workspaceStripViewport.scrollStep)
            }
          }

          Flickable {
            id: workspaceStripViewport
            readonly property real vPad: workspaceStripShell.overflows ? layout.snap(Style.space(4)) : 0
            readonly property real maxContentX: Math.max(0, contentWidth - width)
            readonly property real scrollStep: Math.max(workspaceRow.cardWidth + workspaceRow.spacing, Math.round(width * 0.65))
            x: workspaceStripShell.overflows ? (workspaceStripShell.scrollButtonWidth + workspaceStripShell.scrollButtonGap) : 0
            y: 0
            width: Math.min(workspaceRow.totalWidth, workspaceStripShell.viewportMaxWidth)
            height: workspaceRow.cardHeight + vPad * 2
            contentWidth: workspaceRow.totalWidth
            contentHeight: height
            clip: workspaceStripShell.overflows
            boundsBehavior: Flickable.StopAtBounds
            flickableDirection: Flickable.HorizontalFlick
            interactive: workspaceStripShell.overflows && !root.dragActive && !root.wsDragActive
            onMaxContentXChanged: root.scrollStripTo(contentX)

            WheelHandler {
              enabled: workspaceStripShell.overflows
              acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
              onWheel: function(event) {
                var pixel = Math.abs(event.pixelDelta.x) > Math.abs(event.pixelDelta.y)
                  ? event.pixelDelta.x : event.pixelDelta.y
                var angle = Math.abs(event.angleDelta.x) > Math.abs(event.angleDelta.y)
                  ? event.angleDelta.x : event.angleDelta.y
                var delta = pixel !== 0 ? -pixel : -angle * 0.6
                if (delta === 0) return
                root.scrollStripBy(delta)
                event.accepted = true
              }
            }

            Row {
              id: workspaceRow
              x: 0
              y: workspaceStripViewport.vPad
              spacing: layout.snap(Style.space(12))
              readonly property int entryCount: Math.max(1, root.displayWorkspaceEntries.length)
              readonly property real maxWidth: workspaceStripShell.maxWidth
              readonly property real cardWidth: layout.snap(Math.min(Style.space(156), Math.max(Style.space(88), (maxWidth - spacing * (entryCount - 1)) / entryCount)))
              readonly property real cardHeight: layout.snap(Math.round(cardWidth * 0.62))
              readonly property real totalWidth: entryCount * cardWidth + Math.max(0, entryCount - 1) * spacing

              Repeater {
                id: workspaceRepeater
                model: root.displayWorkspaceEntries
                delegate: BorderSurface {
                  id: wsCard
                  required property var modelData
                  required property int index
                  readonly property int workspaceId: modelData.id
                  readonly property bool isViewed: workspaceId === root.viewedWorkspaceId
                  readonly property bool isCurrentDesktop: workspaceId === root.activeHyprlandWorkspaceId
                  readonly property bool isDropTarget: root.dragActive && root.hoveredDropWorkspaceId === workspaceId && workspaceId !== root.dragSourceWorkspaceId
                  readonly property bool isReorderSource: root.wsDragActive && workspaceId === root.draggedWorkspaceId
                  readonly property bool isReorderTarget: isReorderSource && root.wsDragTargetIndex >= 0 && root.wsDragTargetIndex !== root.wsDragFromIndex
                  readonly property bool isHovered: wsMouse.containsMouse && !root.dragActive && !root.wsDragActive
                  readonly property int reorderShiftSlots: root.wsDragActive && !modelData.guest && !modelData.isNewSlot
                    ? OverviewModel.reorderShiftSlots(
                        index,
                        root.wsDragFromIndex,
                        root.wsDragTargetIndex >= 0 ? root.wsDragTargetIndex : root.wsDragFromIndex)
                    : 0
                  readonly property var wsWindows: root.opened
                    ? OverviewModel.windowsOnWorkspace(Hyprland.toplevels.values, workspaceId, root.pendingMoves) : []
                  readonly property var miniRects: OverviewModel.miniWindowRects(wsWindows, root.monitorBounds)

                  property point wsPressPoint
                  property bool wsDragMoved: false

                  width: workspaceRow.cardWidth
                  height: workspaceRow.cardHeight
                  radius: Style.cornerRadius
                  antialiasing: true
                  border.pixelAligned: false
                  opacity: isReorderSource
                    ? (isReorderTarget ? 0.55 : 0.25)
                    : (isDropTarget || isViewed || isHovered || modelData.occupied ? 1.0 : 0.72)
                  scale: isDropTarget ? 1.06 : (isReorderSource ? 0.96 : 1.0)
                  transform: Translate {
                    x: (workspaceRow.LayoutMirroring.enabled ? -1 : 1) * wsCard.reorderShiftSlots * (workspaceRow.cardWidth + workspaceRow.spacing)
                    Behavior on x {
                      enabled: root.wsDragActive
                      NumberAnimation { duration: Style.duration(140); easing.type: Easing.Bezier; easing.bezierCurve: Style.easeOut }
                    }
                  }
                  Behavior on scale {
                    NumberAnimation { duration: Style.duration(140); easing.type: Easing.Bezier; easing.bezierCurve: Style.easeOut }
                  }
                  Behavior on opacity {
                    NumberAnimation { duration: Style.duration(140); easing.type: Easing.OutCubic }
                  }
                  color: isDropTarget
                    ? Util.alpha(Commons.Color.accent, 0.22)
                    : isReorderTarget
                      ? Util.alpha(Commons.Color.accent, 0.14)
                      : isViewed
                        ? Util.alpha(Commons.Color.accent, 0.10)
                        : isHovered
                          ? Util.alpha(Commons.Color.foreground, 0.08)
                          : Commons.Color.popups.background
                  borderSpec: isDropTarget || isReorderTarget
                    ? Border.hyprlandActiveSpec(Commons.Color.accent, Math.max(2, Style.normalBorderWidth + 1))
                    : isViewed
                      ? Border.hyprlandActiveSpec(Commons.Color.accent, Style.normalBorderWidth)
                      : isHovered
                        ? Border.surfaceSpec("hyprland", "inactive-border", Commons.Color.foreground, Style.normalBorderWidth)
                        : Border.surfaceSpec("hyprland", "inactive-border", Commons.Color.muted, Style.normalBorderWidth)
                  clip: true

                  MiniDesktopPreview {
                    anchors.fill: parent
                    anchors.margins: Style.space(6)
                    visible: !wsCard.isReorderSource
                    rects: wsCard.miniRects
                  }

                  Text {
                    anchors.centerIn: parent
                    visible: !wsCard.isReorderSource && wsCard.wsWindows.length === 0
                    text: (wsCard.modelData.isNewSlot || wsCard.isDropTarget) ? "+" : root.workspaceLabel(wsCard.modelData)
                    textFormat: Text.PlainText
                    color: wsCard.isDropTarget ? Commons.Color.accent : Commons.Color.muted
                    opacity: wsCard.isDropTarget ? 1.0 : 0.65
                    font.family: Style.font.family
                    font.pixelSize: Style.font.heading
                    font.bold: wsCard.isDropTarget
                  }

                  Rectangle {
                    visible: !wsCard.isReorderSource
                    anchors.left: parent.left; anchors.bottom: parent.bottom
                    anchors.margins: Style.space(6)
                    width: wsBadgeRow.implicitWidth + Style.space(10)
                    height: wsBadgeRow.implicitHeight + Style.space(4)
                    radius: Math.max(3, Style.cornerRadius)
                    color: wsCard.isDropTarget
                      ? Commons.Color.accent
                      : Util.alpha(Commons.Color.background, 0.82)
                    Row {
                      id: wsBadgeRow
                      anchors.centerIn: parent
                      spacing: Style.space(4)
                      Rectangle {
                        visible: wsCard.isCurrentDesktop
                        width: Style.space(5); height: Style.space(5)
                        radius: width / 2
                        anchors.verticalCenter: parent.verticalCenter
                        color: wsCard.isDropTarget ? Commons.Color.background : Commons.Color.accent
                      }
                      Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: (wsCard.modelData.isNewSlot ? "+ " : "") + root.workspaceLabel(wsCard.modelData)
                        textFormat: Text.PlainText
                        color: wsCard.isDropTarget
                          ? Commons.Color.background
                          : wsCard.isViewed ? Commons.Color.accent : Commons.Color.foreground
                        font.family: Style.font.family
                        font.pixelSize: Style.font.caption
                        font.bold: wsCard.isViewed || wsCard.isDropTarget
                      }
                    }
                  }

                  Rectangle {
                    visible: !wsCard.isReorderSource && wsCard.modelData.windowCount > 0
                    anchors.right: parent.right; anchors.bottom: parent.bottom
                    anchors.margins: Style.space(6)
                    width: wsCountText.implicitWidth + Style.space(8)
                    height: wsCountText.implicitHeight + Style.space(4)
                    radius: Math.max(3, Style.cornerRadius)
                    color: Util.alpha(Commons.Color.background, 0.78)
                    Text {
                      id: wsCountText
                      anchors.centerIn: parent
                      text: Commons.I18n.formatNumber(wsCard.modelData.windowCount)
                      textFormat: Text.PlainText
                      color: Commons.Color.muted
                      font.family: Style.font.family
                      font.pixelSize: Style.font.caption
                    }
                  }

                  MouseArea {
                    id: wsMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    preventStealing: true
                    cursorShape: wsCard.isReorderSource ? Qt.ClosedHandCursor : Qt.PointingHandCursor
                    onPressed: function(event) {
                      if (event.button !== Qt.LeftButton) return
                      wsCard.wsDragMoved = false
                      wsCard.wsPressPoint = Qt.point(event.x, event.y)
                    }
                    onPositionChanged: function(event) {
                      if (!(pressedButtons & Qt.LeftButton)) return
                      if (wsCard.modelData.guest || wsCard.modelData.isNewSlot) return
                      if (!wsCard.wsDragMoved && Math.hypot(event.x - wsCard.wsPressPoint.x, event.y - wsCard.wsPressPoint.y) >= Style.space(10)) {
                        wsCard.wsDragMoved = true
                        root.beginWorkspaceDrag(wsCard.modelData, wsCard.index, wsCard.mapToItem(keyCatcher, event.x, event.y))
                      }
                      if (wsCard.wsDragMoved) root.updateWorkspaceDrag(wsCard.mapToItem(keyCatcher, event.x, event.y))
                    }
                    onReleased: function(event) {
                      if (wsCard.wsDragMoved && event.button === Qt.LeftButton) root.finishWorkspaceDrag()
                    }
                    onCanceled: if (wsCard.wsDragMoved) root.cancelWorkspaceDrag()
                    onClicked: if (!wsCard.wsDragMoved && !root.dragActive && !root.wsDragActive) root.switchToWorkspace(wsCard.workspaceId)
                  }
            }
          }
            }
          }

          BorderSurface {
            id: rightScrollButton
            visible: workspaceStripShell.overflows
            x: workspaceStripViewport.x + workspaceStripViewport.width + workspaceStripShell.scrollButtonGap
            y: workspaceStripViewport.vPad
            width: workspaceStripShell.scrollButtonWidth
            height: workspaceRow.cardHeight
            radius: Style.cornerRadius
            antialiasing: true
            border.pixelAligned: false
            readonly property bool canScroll: workspaceStripViewport.contentX < workspaceStripViewport.maxContentX - 0.5
            opacity: canScroll ? (rightScrollMouse.containsMouse ? 1.0 : 0.85) : 0.35
            Behavior on opacity {
              NumberAnimation { duration: Style.duration(140); easing.type: Easing.OutCubic }
            }
            color: rightScrollMouse.containsMouse && canScroll
              ? Util.alpha(Commons.Color.foreground, 0.10)
              : Commons.Color.popups.background
            borderSpec: rightScrollMouse.containsMouse && canScroll
              ? Border.surfaceSpec("hyprland", "inactive-border", Commons.Color.foreground, Style.normalBorderWidth)
              : Border.surfaceSpec("hyprland", "inactive-border", Commons.Color.muted, Style.normalBorderWidth)
            Text {
              anchors.centerIn: parent
              text: "›"
              textFormat: Text.PlainText
              color: rightScrollButton.canScroll ? Commons.Color.foreground : Commons.Color.muted
              font.family: Style.font.family
              font.pixelSize: Style.font.heading
            }
            MouseArea {
              id: rightScrollMouse
              anchors.fill: parent
              hoverEnabled: true
              enabled: rightScrollButton.canScroll
              cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
              onClicked: root.scrollStripBy(workspaceStripViewport.scrollStep)
            }
          }
        }

        Text {
          anchors.horizontalCenter: parent.horizontalCenter
          readonly property var hoveredEntry: root.workspaceEntryById(root.hoveredDropWorkspaceId)
          readonly property var viewedEntry: root.workspaceEntryById(root.viewedWorkspaceId)
          readonly property var targetWsEntry: root.wsDragTargetId > 0 ? root.workspaceEntryById(root.wsDragTargetId) : null
          readonly property bool showDropLabel: root.dragActive && !!hoveredEntry && root.hoveredDropWorkspaceId !== root.dragSourceWorkspaceId
          readonly property bool showReorderLabel: root.wsDragActive && !!root.draggedWorkspaceEntry
          readonly property bool showReorderTarget: showReorderLabel && !!targetWsEntry && root.wsDragTargetIndex !== root.wsDragFromIndex
          text: {
            if (showDropLabel) {
              var hoveredLabel = root.workspaceLabel(hoveredEntry)
              return hoveredEntry.isNewSlot
                ? Commons.I18n.t("overview.newWorkspace").arg(hoveredLabel)
                : Commons.I18n.t("overview.moveToWorkspace").arg(hoveredLabel)
            }
            if (showReorderTarget) {
              return Commons.I18n.t("overview.reorderWorkspace").arg(root.workspaceLabel(root.draggedWorkspaceEntry)).arg(root.workspaceLabel(targetWsEntry))
            }
            if (showReorderLabel) {
              return Commons.I18n.t("overview.reorderingWorkspace").arg(root.workspaceLabel(root.draggedWorkspaceEntry))
            }
            return Commons.I18n.t("overview.workspace").arg(root.workspaceLabel(viewedEntry, Math.max(1, root.viewedWorkspaceId)))
          }
          textFormat: Text.PlainText
          color: (showDropLabel || showReorderTarget) ? Commons.Color.accent : Commons.Color.muted
          font.family: Style.font.family
          font.pixelSize: Style.font.bodySmall
        }
      }

      Text {
        visible: root.windows.length === 0
        readonly property real topReserved: workspaceStripArea.y + workspaceStripArea.height + Style.space(20)
        anchors.horizontalCenter: parent.horizontalCenter
        y: layout.snap(topReserved + Math.max(0, (panel.height - topReserved - height) / 2))
        text: Commons.I18n.t("overview.empty")
        textFormat: Text.PlainText
        color: Commons.Color.foreground
        font.family: Style.font.family
        font.pixelSize: Style.font.heading
      }

      Grid {
        id: layout
        // Align every card edge to physical pixels on fractional-scale outputs.
        readonly property real pixelRatio: Math.max(1, panel.devicePixelRatio)
        function snap(value) { return Math.round(value * pixelRatio) / pixelRatio }
        readonly property real topReserved: workspaceStripArea.y + workspaceStripArea.height + Style.space(20)
        readonly property real availWidth: Math.max(1, panel.width - Style.space(80))
        readonly property real availHeight: Math.max(1, panel.height - topReserved - Style.space(36))
        x: snap((parent.width - width) / 2)
        y: snap(topReserved + Math.max(0, (availHeight - height) / 2))
        columns: Math.max(1, Math.ceil(Math.sqrt(root.windows.length * availWidth / Math.max(1, availHeight))))
        readonly property int rowCount: Math.max(1, Math.ceil(root.windows.length / columns))
        spacing: snap(Style.space(20))
        readonly property real cellWidth: snap(Math.max(1, Math.min(Style.space(480), (availWidth - spacing * (columns - 1)) / columns)))
        readonly property real cellHeight: snap(Math.max(1, Math.min(cellWidth * 0.7, (availHeight - spacing * (rowCount - 1)) / rowCount)))
        Repeater {
          model: root.windows
          delegate: BorderSurface {
            id: tile
            required property var modelData
            required property int index
            readonly property bool beingDragged: root.dragActive && tile.modelData === root.draggedWindow
            property point pressPoint
            property bool dragMoved: false

            width: layout.cellWidth
            height: layout.cellHeight
            radius: Style.cornerRadius
            antialiasing: true
            border.pixelAligned: false
            opacity: beingDragged ? 0.28 : 1.0
            scale: beingDragged ? 0.96 : 1.0
            Behavior on opacity {
              NumberAnimation { duration: Style.duration(120); easing.type: Easing.OutCubic }
            }
            Behavior on scale {
              NumberAnimation { duration: Style.duration(120); easing.type: Easing.Bezier; easing.bezierCurve: Style.easeOut }
            }
            color: Commons.Color.popups.background
            borderSpec: index === root.selectedIndex
              ? Border.hyprlandActiveSpec(Commons.Color.accent, Style.normalBorderWidth)
              : Border.surfaceSpec("hyprland", "inactive-border", Commons.Color.muted, Style.normalBorderWidth)
            clip: true

            WindowCardContent {
              anchors.fill: parent
              windowData: tile.modelData
              liveCapture: root.opened
            }
            MouseArea {
              anchors.fill: parent
              hoverEnabled: true
              preventStealing: true
              cursorShape: tile.beingDragged ? Qt.ClosedHandCursor : Qt.PointingHandCursor
              onEntered: if (!root.dragActive && !root.wsDragActive) root.selectedIndex = tile.index
              onPressed: function(event) {
                tile.dragMoved = false
                tile.pressPoint = Qt.point(event.x, event.y)
                root.selectedIndex = tile.index
              }
              onPositionChanged: function(event) {
                if (!(pressedButtons & Qt.LeftButton)) return
                if (!tile.dragMoved && Math.hypot(event.x - tile.pressPoint.x, event.y - tile.pressPoint.y) > Style.space(6)) {
                  tile.dragMoved = true
                  root.beginDrag(tile.modelData, tile.mapToItem(keyCatcher, event.x, event.y))
                }
                if (tile.dragMoved) root.updateDrag(tile.mapToItem(keyCatcher, event.x, event.y))
              }
              onReleased: function(event) {
                if (tile.dragMoved && event.button === Qt.LeftButton) root.finishDrag()
              }
              onCanceled: if (tile.dragMoved) root.cancelDrag()
              onClicked: if (!tile.dragMoved && !root.wsDragActive) root.choose(tile.index)
            }
          }
        }
      }

      BorderSurface {
        id: wsDragProxy
        z: 100
        visible: root.wsDragActive && !!root.draggedWorkspaceEntry
        readonly property var targetEntry: root.wsDragTargetId > 0 ? root.workspaceEntryById(root.wsDragTargetId) : null
        readonly property bool hasValidTarget: !!targetEntry && root.wsDragTargetIndex >= 0 && root.wsDragTargetIndex !== root.wsDragFromIndex
        readonly property var draggedWindows: visible
          ? OverviewModel.windowsOnWorkspace(Hyprland.toplevels.values, root.draggedWorkspaceId, root.pendingMoves) : []
        width: workspaceRow.cardWidth
        height: workspaceRow.cardHeight
        x: Math.round(root.wsDragPoint.x - width / 2)
        y: Math.round(root.wsDragPoint.y - height / 2)
        scale: 1.06
        opacity: 0.96
        radius: Style.cornerRadius
        antialiasing: true
        border.pixelAligned: false
        color: Commons.Color.popups.background
        borderSpec: Border.hyprlandActiveSpec(Commons.Color.accent, Math.max(2, Style.normalBorderWidth + 1))
        clip: true

        MiniDesktopPreview {
          anchors.fill: parent
          anchors.margins: Style.space(6)
          rects: OverviewModel.miniWindowRects(wsDragProxy.draggedWindows, root.monitorBounds)
        }
        Text {
          anchors.centerIn: parent
          visible: wsDragProxy.draggedWindows.length === 0 && !!root.draggedWorkspaceEntry
          text: root.workspaceLabel(root.draggedWorkspaceEntry)
          textFormat: Text.PlainText
          color: Commons.Color.muted
          font.family: Style.font.family
          font.pixelSize: Style.font.heading
        }
        Rectangle {
          anchors.left: parent.left; anchors.bottom: parent.bottom
          anchors.margins: Style.space(6)
          width: wsProxyBadge.implicitWidth + Style.space(10)
          height: wsProxyBadge.implicitHeight + Style.space(4)
          radius: Math.max(3, Style.cornerRadius)
          color: Commons.Color.accent
          Row {
            id: wsProxyBadge
            anchors.centerIn: parent
            spacing: Style.space(4)
            Rectangle {
              visible: root.draggedWorkspaceId === root.activeHyprlandWorkspaceId
              width: Style.space(5); height: Style.space(5)
              radius: width / 2
              anchors.verticalCenter: parent.verticalCenter
              color: Commons.Color.background
            }
            Text {
              anchors.verticalCenter: parent.verticalCenter
              text: root.workspaceLabel(root.draggedWorkspaceEntry)
              textFormat: Text.PlainText
              color: Commons.Color.background
              font.family: Style.font.family
              font.pixelSize: Style.font.caption
              font.bold: true
            }
          }
        }
        Rectangle {
          visible: wsDragProxy.hasValidTarget
          anchors.top: parent.top; anchors.right: parent.right
          anchors.margins: Style.space(6)
          width: wsTargetBadgeText.implicitWidth + Style.space(10)
          height: wsTargetBadgeText.implicitHeight + Style.space(4)
          radius: Math.max(3, Style.cornerRadius)
          color: Commons.Color.accent
          Text {
            id: wsTargetBadgeText
            anchors.centerIn: parent
            text: wsDragProxy.targetEntry ? (Commons.I18n.rightToLeft ? "← " : "→ ") + root.workspaceLabel(wsDragProxy.targetEntry) : ""
            textFormat: Text.PlainText
            color: Commons.Color.background
            font.family: Style.font.family
            font.pixelSize: Style.font.caption
            font.bold: true
          }
        }
      }

      BorderSurface {
        id: dragProxy
        z: 100
        visible: root.dragActive && !!root.draggedWindow
        readonly property var targetEntry: root.workspaceEntryById(root.hoveredDropWorkspaceId)
        readonly property bool hasValidTarget: !!targetEntry && root.hoveredDropWorkspaceId !== root.dragSourceWorkspaceId
        width: Math.min(Style.space(220), Math.max(Style.space(150), layout.cellWidth * 0.58))
        height: Math.round(width * 0.65)
        x: Math.round(root.dragPoint.x - width / 2)
        y: Math.round(root.dragPoint.y - height / 2)
        radius: Style.cornerRadius
        antialiasing: true
        border.pixelAligned: false
        color: Commons.Color.popups.background
        borderSpec: hasValidTarget
          ? Border.hyprlandActiveSpec(Commons.Color.accent, Math.max(2, Style.normalBorderWidth + 1))
          : Border.hyprlandActiveSpec(Commons.Color.accent, Style.normalBorderWidth)
        clip: true

        WindowCardContent {
          anchors.fill: parent
          windowData: root.draggedWindow
          liveCapture: dragProxy.visible
          padding: Style.space(6)
          footerHeight: Style.space(28)
          fallbackIconMax: Style.space(36)
          titlePixelSize: Style.font.bodySmall
          showFooterIcon: false
        }
        Rectangle {
          visible: dragProxy.hasValidTarget
          anchors.top: parent.top; anchors.right: parent.right
          anchors.margins: Style.space(6)
          width: targetBadgeText.implicitWidth + Style.space(10)
          height: targetBadgeText.implicitHeight + Style.space(4)
          radius: Math.max(3, Style.cornerRadius)
          color: Commons.Color.accent
          Text {
            id: targetBadgeText
            anchors.centerIn: parent
            text: dragProxy.targetEntry ? (Commons.I18n.rightToLeft ? "← " : "→ ") + root.workspaceLabel(dragProxy.targetEntry) : ""
            textFormat: Text.PlainText
            color: Commons.Color.background
            font.family: Style.font.family
            font.pixelSize: Style.font.caption
            font.bold: true
          }
        }
      }
    }
  }
}
