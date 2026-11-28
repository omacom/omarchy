import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import qs.Commons
import qs.Commons as Commons
import qs.Ui
import "DockModel.js" as DockModel

// One screen's dock. Mapped only while this screen is on a floating workspace
// so tiled workspaces do not hold a live layer surface and dmabuf swapchain.
PanelWindow {
  id: window
  visible: window.shown
  // Right-to-left languages read this window mirrored.
  Binding { target: window.contentItem; property: "LayoutMirroring.enabled"; value: Commons.I18n.rightToLeft }
  Binding { target: window.contentItem; property: "LayoutMirroring.childrenInherit"; value: true }


  property var dock: null

  readonly property string position: dock ? dock.position : "bottom"
  readonly property bool vertical: dock ? dock.vertical : false
  readonly property var monitor: Hyprland.monitorFor(screen)
  readonly property var workspace: monitor ? monitor.activeWorkspace : null
  readonly property int workspaceId: workspace ? workspace.id : -1
  // The most fullscreen window on the workspace, as Hyprland counts it: 1 is
  // maximized, and 2 or 3 fullscreen.
  readonly property int fullscreenMode: {
    var mode = 0
    var toplevels = Hyprland.toplevels.values
    for (var i = 0; i < toplevels.length; i++) {
      var toplevel = toplevels[i]
      if (!toplevel.workspace || toplevel.workspace.id !== workspaceId) continue
      var ipc = toplevel.lastIpcObject
      mode = Math.max(mode, ipc && ipc.fullscreen ? ipc.fullscreen : 0)
    }
    return mode
  }
  readonly property bool shown: !!dock && dock.isFloating(workspaceId) && fullscreenMode < 2
  // With auto-hide on, the dock waits off screen until the pointer reaches its
  // edge, and stays while the pointer, a menu, or a drag still needs it. A
  // maximized window hides the dock the same way, so it can still be called up.
  readonly property bool autohide: !!dock && (dock.autohide || fullscreenMode === 1)
  property bool revealed: false
  readonly property bool menuOpen: menuKey !== "" || settingsMenu
  readonly property bool tucked: autohide && !(revealed || menuOpen || dragging || insertIndex >= 0)
  readonly property bool contentShown: shown && !tucked

  readonly property int gap: Style.spacing.xs
  readonly property int iconSize: Math.round(36 * Style.fontScale)
  // Each app has a square slot with its icon in the middle, and the slots run
  // straight to the edge of the dock.
  readonly property int iconInset: Style.spacing.md
  readonly property int slotSize: iconSize + iconInset * 2
  // An app that is starting pulses down to this, and an app whose windows
  // are all minimized dims slightly so open vs minimized reads at a glance.
  readonly property real pulseOpacity: 0.7
  readonly property real minimizedOpacity: 0.68
  // Room inward of the dock for its menus: the tallest, the apps button's,
  // has five rows.
  readonly property int popupRoom: Style.spacing.popupRowHeight * 5 + Style.spacing.sm * 2 + Style.normalBorderWidth * 2 + gap * 2
  // Icons pop away from the screen edge.
  readonly property int popOrigin: position === "top" ? Item.Top
    : position === "left" ? Item.Left
    : position === "right" ? Item.Right
    : Item.Bottom

  // The app being dragged along the dock, how far the pointer has taken it,
  // and the slot it would land in.
  property int dragIndex: -1
  property int dropIndex: -1
  property real dragOffset: 0
  readonly property bool dragging: dragIndex >= 0
  // Off while a drop resets the slots: they snap to where the reorder puts
  // them rather than sliding back from where they stepped aside. Set before
  // the drag state changes, so the slots never see the reset animated.
  property bool animateShifts: true
  // After a drop the slots have moved under a pointer that has not, so what
  // they think is hovered is stale until it moves again.
  property bool hoverStale: false
  property point dropPoint
  // Where an app dragged in from the app grid would land, or -1.
  property int insertIndex: -1

  // Lookup key rather than object snapshot so hover tooltips and popup menus
  // stay synchronized across live Hyprland window updates.
  property string hoveredKey: ""
  property Item hoveredSlot: null
  property string menuKey: ""
  property Item menuSlot: null
  // The apps button's menu: where the dock sits and whether it hides.
  property bool settingsMenu: false
  // Right-click opens the full window menu; left-click on multi-window opens the compact list.
  property bool fullMenu: false
  property string selectedAddress: ""

  // Where this window sits on its screen, which a point from the app grid's
  // fullscreen surface is given in: against its edge, clear of the space
  // other surfaces such as the bar reserve. Hyprland lists that space as
  // left, top, right, bottom.
  function origin() {
    var reserved = monitor && monitor.lastIpcObject && monitor.lastIpcObject.reserved ? monitor.lastIpcObject.reserved : [0, 0, 0, 0]
    var left = reserved[0] || 0, top = reserved[1] || 0, right = reserved[2] || 0, bottom = reserved[3] || 0
    var x = window.position === "right" ? screen.width - right - window.width : left
    var y = window.position === "bottom" ? screen.height - bottom - window.height : top
    return Qt.point(x, y)
  }

  // An app from the app grid lands where the pointer is, once it is over the
  // dock or close to it on the inward side.
  function moveExternalDrag(screenX, screenY) {
    var at = window.origin()
    var point = Qt.point(screenX - at.x - body.x, screenY - at.y - body.y)
    var reach = window.slotSize
    var along = window.vertical ? point.y : point.x
    var across = window.vertical ? point.x : point.y
    var length = window.vertical ? body.height : body.width
    var depth = window.vertical ? body.width : body.height
    var near = along >= -window.slotSize && along <= length + window.slotSize && across >= -reach && across <= depth + reach
    if (window.shown && window.autohide && near) window.revealed = true
    window.insertIndex = window.shown && near ? window.slotIndexAt(point) : -1
  }

  function dropExternalDrag(screenX, screenY, key) {
    window.moveExternalDrag(screenX, screenY)
    window.settleShifts()
    if (window.insertIndex >= 0 && key && window.dock) window.dock.pinAt(key, window.insertIndex)
    window.endExternalDrag()
  }

  function endExternalDrag() {
    window.insertIndex = -1
    if (window.autohide) hideTimer.restart()
  }

  // The slot a point along the dock falls before, counting from the first app.
  function slotIndexAt(point) {
    var along = window.vertical ? point.y : point.x
    var first = window.slotSize + (window.vertical ? body.contentTopInset : body.contentLeftInset)
    var count = window.dock ? window.dock.itemModel.count : 0
    return Math.max(0, Math.min(count, Math.round((along - first) / window.slotSize)))
  }

  onWorkspaceIdChanged: if (dock) dock.readMode(workspaceId)
  onShownChanged: {
    if (shown) return
    closeMenu()
    window.hoveredKey = ""
    window.hoveredSlot = null
    window.revealed = false
  }
  Component.onCompleted: if (dock) dock.readMode(workspaceId)

  function openMenu(key, slot, full) {
    window.settingsMenu = false
    window.menuKey = String(key || "")
    window.fullMenu = !!full
    window.selectedAddress = ""
    window.menuSlot = slot
    if (window.dock && window.menuKey) window.dock.inspectPidsForItem(window.menuKey)
  }

  function openSettingsMenu(slot) {
    window.menuKey = ""
    window.fullMenu = false
    window.selectedAddress = ""
    window.settingsMenu = true
    window.menuSlot = slot
  }

  function settleShifts() {
    window.animateShifts = false
    Qt.callLater(function() { window.animateShifts = true })
  }

  function endDrag() {
    window.settleShifts()
    window.hoverStale = true
    window.dragIndex = -1
    window.dropIndex = -1
    window.dragOffset = 0
  }

  function closeMenu() {
    window.menuKey = ""
    window.fullMenu = false
    window.selectedAddress = ""
    window.settingsMenu = false
    window.menuSlot = null
    if (window.autohide) hideTimer.restart()
  }

  // Places the menu inward of the dock, centered on a slot.
  function popupX(slot, popup) {
    if (!slot) return window.gap
    var center = slot.mapToItem(window.contentItem, slot.width / 2, 0).x
    if (window.position === "left") return body.x + body.width + window.gap
    if (window.position === "right") return Math.max(window.gap, body.x - window.gap - popup.width)
    return Math.max(window.gap, Math.min(window.width - popup.width - window.gap, center - popup.width / 2))
  }

  function popupY(slot, popup) {
    if (!slot) return window.gap
    var center = slot.mapToItem(window.contentItem, 0, slot.height / 2).y
    if (window.position === "top") return body.y + body.height + window.gap
    if (window.position === "bottom") return Math.max(window.gap, body.y - window.gap - popup.height)
    return Math.max(window.gap, Math.min(window.height - popup.height - window.gap, center - popup.height / 2))
  }

  color: "transparent"
  WlrLayershell.namespace: "omarchy-dock"
  WlrLayershell.layer: WlrLayer.Top
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
  // Kept clear of the bar's reserved edge, without reserving one of its own:
  // floating windows go where they are put.
  exclusionMode: ExclusionMode.Normal
  exclusiveZone: 0

  anchors {
    top: window.position !== "bottom"
    bottom: window.position !== "top"
    left: window.position !== "right"
    right: window.position !== "left"
  }

  readonly property real activePopupHeight: menu.visible ? menu.height : (hoverTip.visible ? hoverTip.height : 0)
  readonly property real activePopupWidth: menu.visible ? menu.width : (hoverTip.visible ? hoverTip.width : 0)

  implicitWidth: window.vertical
    ? window.gap * 2 + body.width + Math.max(window.popupRoom, activePopupWidth + window.gap * 2)
    : 0
  implicitHeight: window.vertical
    ? 0
    : window.gap * 2 + body.height + Math.max(window.popupRoom, activePopupHeight + window.gap * 2)

  mask: Region {
    item: window.contentShown ? body : null

    Region { item: window.shown && window.autohide ? edgeTrigger : null }
    Region { item: menu.visible ? menu : null }
  }

  onAutohideChanged: window.revealed = false

  Timer {
    id: hideTimer
    // Long enough to cross a gap between the edge and the icons, no longer.
    interval: 150
    onTriggered: {
      if (!bodyHover.hovered && !edgeHover.hovered && !window.menuOpen && !window.dragging) window.revealed = false
    }
  }

  // The strip along the screen edge that brings an auto-hidden dock back.
  Item {
    id: edgeTrigger

    readonly property int depth: window.gap + Style.spacing.xxs

    x: window.position === "left" ? 0 : window.position === "right" ? window.width - depth : body.x
    y: window.position === "top" ? 0 : window.position === "bottom" ? window.height - depth : body.y
    width: window.vertical ? depth : body.width
    height: window.vertical ? body.height : depth

    HoverHandler {
      id: edgeHover
      onHoveredChanged: {
        if (hovered) window.revealed = true
        else hideTimer.restart()
      }
    }
  }

  HyprlandFocusGrab {
    active: window.menuOpen
    windows: [window]
    onCleared: window.closeMenu()
  }

  BorderSurface {
    id: body

    // The strip keeps its order in every language, like the bar: drags and
    // drops reckon slots along x from the first app. Only the menu mirrors.
    LayoutMirroring.enabled: false
    LayoutMirroring.childrenInherit: true

    padding: Style.spacing.xs
    radius: Math.max(Style.cornerRadius, Style.space(10))
    color: Util.alpha(Commons.Color.popups.background, 0.88)
    borderSpec: Border.surfaceSpec("popups", "border", Util.alpha(Commons.Color.popups.border, 0.45), Style.normalBorderWidth)

    width: slots.implicitWidth + contentLeftInset + contentRightInset
    height: slots.implicitHeight + contentTopInset + contentBottomInset
    // How far the dock is tucked past its edge. Auto-hide slides it, but only
    // while the dock is on screen: arriving on a floating workspace shows it
    // where it belongs at once.
    property real tuck: window.tucked ? (window.vertical ? width : height) + window.gap * 2 : 0

    // Tucking away is quicker than coming back. A gentler curve than
    // Style.easeOut, which crosses the short slide in a frame or two.
    Behavior on tuck {
      id: tuckMotion
      enabled: window.shown
      NumberAnimation {
        duration: Style.duration(tuckMotion.targetValue > 0 ? 120 : 180)
        easing.type: Easing.OutCubic
      }
    }

    x: window.position === "left" ? window.gap - tuck
      : window.position === "right" ? window.width - width - window.gap + tuck
      : Math.round((window.width - width) / 2)
    y: window.position === "top" ? window.gap - tuck
      : window.position === "bottom" ? window.height - height - window.gap + tuck
      : Math.round((window.height - height) / 2)

    HoverHandler {
      id: bodyHover
      onHoveredChanged: if (!hovered && window.autohide) hideTimer.restart()
      // Only a real move clears it: the release itself reports the pointer too.
      onPointChanged: {
        if (!window.hoverStale || window.dragging) return
        var at = point.position
        if (Math.hypot(at.x - window.dropPoint.x, at.y - window.dropPoint.y) > Style.space(4)) window.hoverStale = false
      }
    }

    Grid {
      id: slots
      x: body.contentLeftInset
      y: body.contentTopInset
      columns: window.vertical ? 1 : Math.max(1, appRepeater.count + 1)

      AppsSlot {}

      Repeater {
        id: appRepeater
        model: window.dock ? window.dock.itemModel : null

        delegate: AppSlot {}
      }
    }
  }

  component Slot: Item {
    id: slot

    // Only the dragged icon is lifted while a drag is on; none of the others
    // pop as it passes over them.
    property bool hovered: mouse.containsMouse && !window.hoverStale && !window.dragging
    property bool pressed: mouse.pressed
    property alias mouse: mouse

    width: window.slotSize
    height: window.slotSize

    MouseArea {
      id: mouse
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
    }
  }

  component AppsSlot: Slot {
    id: appsSlot

    property real displayedShift: window.insertIndex >= 0 ? -window.slotSize / 2 : 0

    Behavior on displayedShift {
      enabled: window.animateShifts
      NumberAnimation { duration: Style.duration(150); easing.type: Easing.Bezier; easing.bezierCurve: Style.easeOut }
    }

    transform: Translate {
      x: window.vertical ? 0 : appsSlot.displayedShift
      y: window.vertical ? appsSlot.displayedShift : 0
    }

    mouse.onClicked: function(event) {
      if (event.button === Qt.RightButton) {
        window.openSettingsMenu(appsSlot)
        return
      }
      window.closeMenu()
      if (window.dock) window.dock.openApps()
    }

    // A grid of app squares reads as "all apps" in any icon theme. Drawn
    // rather than taken from a font, so its edges stay crisp on the
    // transparent dock and it fills its slot like the app icons beside it.
    Item {
      x: window.iconInset
      y: window.iconInset
      width: window.iconSize
      height: window.iconSize
      scale: appsSlot.hovered ? 1.15 : 1
      transformOrigin: window.popOrigin

      Behavior on scale { NumberAnimation { duration: Style.duration(120); easing.type: Easing.OutCubic } }

      Grid {
        readonly property int square: Math.round(window.iconSize * 0.22)
        // A theme change fades it with the bar's palette.
        property color tint: Commons.Color.bar.text

        Behavior on tint { ColorAnimation { duration: Style.duration(250); easing.type: Easing.OutCubic } }

        anchors.centerIn: parent
        columns: 3
        spacing: Math.round(window.iconSize * 0.1)

        Repeater {
          model: 9

          delegate: Rectangle {
            width: parent.square
            height: parent.square
            radius: Math.max(1, Math.round(parent.square * 0.2))
            color: parent.tint
          }
        }
      }
    }
  }

  component AppSlot: Slot {
    id: appSlot

    required property int index
    required property string key
    readonly property var modelData: window.dock ? window.dock.itemFor(key) : null
    readonly property int windowCount: modelData ? modelData.windows.length : 0
    readonly property var stats: DockModel.itemStats(modelData ? modelData.windows : [])
    readonly property var dotWindows: DockModel.representativeDots(modelData ? modelData.windows : [], 4)
    readonly property bool launching: !!window.dock && window.dock.isLaunching(key)
    readonly property bool lifted: window.dragIndex === index
    property point pressPoint
    property bool dragged: false
    property real pulse: 1

    // Slots between where the dragged app was and where it would land step
    // aside to make room; the dragged one follows the pointer.
    readonly property real shift: window.insertIndex >= 0 ? (index >= window.insertIndex ? 1 : -1) * window.slotSize / 2
      : !window.dragging ? 0
      : lifted ? window.dragOffset
      : (window.dragIndex < index && index <= window.dropIndex) ? -window.slotSize
      : (window.dropIndex <= index && index < window.dragIndex) ? window.slotSize
      : 0
    property real displayedShift: shift

    // Only while dragging: once the drop reorders the slots, they are already
    // where they were shown.
    Behavior on displayedShift {
      enabled: window.animateShifts && ((window.dragging && !appSlot.lifted) || window.insertIndex >= 0)
      NumberAnimation { duration: Style.duration(150); easing.type: Easing.Bezier; easing.bezierCurve: Style.easeOut }
    }

    z: lifted ? 1 : 0

    // The slot, and the pointer handling in it, stays where it is; only the
    // icon moves. Reading the pointer through a slot that moves with it would
    // feed each move back into the next.
    function bodyPoint(event) {
      return appSlot.mapToItem(body, event.x, event.y)
    }

    mouse.onEntered: {
      if (!window.dragging && !window.hoverStale) {
        window.hoveredKey = appSlot.key
        window.hoveredSlot = appSlot
      }
    }

    mouse.onExited: {
      if (window.hoveredSlot === appSlot) {
        window.hoveredKey = ""
        window.hoveredSlot = null
      }
    }

    mouse.onPressed: function(event) {
      appSlot.dragged = false
      window.hoveredKey = ""
      window.hoveredSlot = null
      if (event.button === Qt.LeftButton) appSlot.pressPoint = appSlot.bodyPoint(event)
    }

    mouse.onPositionChanged: function(event) {
      if (!(appSlot.mouse.pressedButtons & Qt.LeftButton)) return
      var point = appSlot.bodyPoint(event)
      var delta = window.vertical ? point.y - appSlot.pressPoint.y : point.x - appSlot.pressPoint.x
      // A press that wanders is a drag in the making, not a click.
      if (Math.hypot(point.x - appSlot.pressPoint.x, point.y - appSlot.pressPoint.y) > Style.space(4)) appSlot.dragged = true
      if (!window.dragging) {
        if (Math.abs(delta) < Style.space(6)) return
        window.closeMenu()
        // The landing slot first: with the dragged slot set and no landing
        // slot yet, every slot before it would count as in between and step
        // aside for a moment.
        window.dropIndex = appSlot.index
        window.dragIndex = appSlot.index
      }
      if (!appSlot.lifted) return
      window.dragOffset = delta
      window.dropIndex = DockModel.dropIndex(appSlot.index, delta, window.slotSize, appRepeater.count)
    }

    mouse.onReleased: function(event) {
      if (!appSlot.lifted) return
      window.dropPoint = appSlot.mapToItem(body, event.x, event.y)
      var from = window.dragIndex
      var to = window.dropIndex
      appSlot.dragged = true
      window.endDrag()
      window.dock.moveItem(from, to)
    }

    mouse.onCanceled: if (appSlot.lifted) window.endDrag()

    mouse.onClicked: function(event) {
      // A drag ends in a release over the app, which is not a click on it.
      if (appSlot.dragged) {
        appSlot.dragged = false
        return
      }
      if (event.button === Qt.RightButton) {
        window.openMenu(appSlot.key, appSlot, true)
        return
      }
      if (!window.dock) return
      if (event.button === Qt.MiddleButton) {
        window.closeMenu()
        if (appSlot.modelData) window.dock.launch(appSlot.modelData)
        return
      }
      var clickMode = window.dock.clickModeFor(appSlot.key)
      if (appSlot.windowCount > 1 && clickMode !== "new" && clickMode !== "workspace") {
        if (window.menuKey === appSlot.key && !window.settingsMenu && !window.fullMenu) window.closeMenu()
        else window.openMenu(appSlot.key, appSlot, false)
        return
      }
      window.closeMenu()
      if (appSlot.modelData) window.dock.activate(appSlot.modelData, window.workspaceId)
    }

    readonly property real iconOpacity: appSlot.launching
      ? appSlot.pulse
      : (appSlot.windowCount > 0 && appSlot.stats.open === 0 ? window.minimizedOpacity : 1)

    // Pinned unrunning apps are drawn solid, launching apps pulse, and
    // all-minimized apps dim slightly so minimized state reads at a glance.
    AppIcon {
      x: window.iconInset
      y: window.iconInset
      width: window.iconSize
      height: window.iconSize
      source: window.dock && appSlot.modelData ? window.dock.iconFor(appSlot.modelData) : ""
      opacity: appSlot.iconOpacity
      transform: Translate {
        x: window.vertical ? 0 : appSlot.displayedShift
        y: window.vertical ? appSlot.displayedShift : 0
      }
      scale: appSlot.lifted || appSlot.hovered ? 1.15 : 1
      transformOrigin: window.popOrigin

      Behavior on scale { NumberAnimation { duration: Style.duration(120); easing.type: Easing.OutCubic } }
    }

    // Running / focused / minimized indicator bar along the screen edge.
    Row {
      visible: appSlot.windowCount > 0 && !window.vertical
      spacing: Style.space(3)
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.bottom: window.position === "bottom" ? parent.bottom : undefined
      anchors.top: window.position === "top" ? parent.top : undefined
      anchors.margins: Style.space(2)
      transform: Translate { x: appSlot.displayedShift }

      Repeater {
        model: 4
        delegate: Rectangle {
          required property int index
          readonly property var win: index < appSlot.dotWindows.length ? appSlot.dotWindows[index] : null
          readonly property bool isActivated: !!win && !!win.activated
          readonly property bool isMinimized: !!win && !!win.minimized
          visible: !!win
          width: isActivated ? Style.space(12) : Style.space(5)
          height: Style.space(4)
          radius: Style.space(2)
          color: isMinimized ? "transparent" : (isActivated ? Commons.Color.accent : Commons.Color.popups.text)
          border.width: isMinimized ? 1 : 0
          border.color: Commons.Color.accent
          opacity: isActivated ? 1 : 0.9
        }
      }
    }

    Column {
      visible: appSlot.windowCount > 0 && window.vertical
      spacing: Style.space(3)
      anchors.verticalCenter: parent.verticalCenter
      anchors.left: window.position === "left" ? parent.left : undefined
      anchors.right: window.position === "right" ? parent.right : undefined
      anchors.margins: Style.space(2)
      transform: Translate { y: appSlot.displayedShift }

      Repeater {
        model: 4
        delegate: Rectangle {
          required property int index
          readonly property var win: index < appSlot.dotWindows.length ? appSlot.dotWindows[index] : null
          readonly property bool isActivated: !!win && !!win.activated
          readonly property bool isMinimized: !!win && !!win.minimized
          visible: !!win
          width: Style.space(4)
          height: isActivated ? Style.space(12) : Style.space(5)
          radius: Style.space(2)
          color: isMinimized ? "transparent" : (isActivated ? Commons.Color.accent : Commons.Color.popups.text)
          border.width: isMinimized ? 1 : 0
          border.color: Commons.Color.accent
          opacity: isActivated ? 1 : 0.9
        }
      }
    }

    // Count / minimized badge when multiple windows are open or any are minimized.
    Rectangle {
      visible: appSlot.stats.minimized > 0 || appSlot.stats.total > 1
      anchors.top: parent.top
      anchors.right: parent.right
      anchors.topMargin: Style.space(2)
      anchors.rightMargin: Style.space(2)
      height: Math.max(Style.space(15), badgeText.implicitHeight + Style.space(2))
      width: Math.max(height, badgeText.implicitWidth + Style.space(6))
      radius: height / 2
      color: appSlot.stats.minimized > 0 ? Commons.Color.accent : Commons.Color.popups.background
      border.width: 1
      border.color: appSlot.stats.minimized > 0 ? Commons.Color.accent : Util.alpha(Commons.Color.popups.text, 0.45)
      transform: Translate {
        x: window.vertical ? 0 : appSlot.displayedShift
        y: window.vertical ? appSlot.displayedShift : 0
      }

      Text {
        id: badgeText
        anchors.centerIn: parent
        textFormat: Text.PlainText
        text: {
          var totalStr = Commons.I18n.formatNumber(appSlot.stats.total)
          if (appSlot.stats.minimized > 0 && appSlot.stats.open === 0)
            return appSlot.stats.total > 1 ? (totalStr + "↓") : "↓"
          if (appSlot.stats.minimized > 0)
            return totalStr + "·" + Commons.I18n.formatNumber(appSlot.stats.minimized) + "↓"
          return totalStr
        }
        color: appSlot.stats.minimized > 0 ? Commons.Color.background : Commons.Color.popups.text
        font.family: Style.font.family
        font.pixelSize: Math.max(9, Style.font.caption - 2)
        font.bold: true
      }
    }

    // With animations off it holds still rather than spinning through
    // zero-length steps.
    SequentialAnimation {
      running: appSlot.launching && !Style.reduceMotion
      loops: Animation.Infinite
      onRunningChanged: if (!running) appSlot.pulse = 1

      NumberAnimation { target: appSlot; property: "pulse"; from: 1; to: window.pulseOpacity; duration: Style.duration(500); easing.type: Easing.InOutSine }
      NumberAnimation { target: appSlot; property: "pulse"; to: 1; duration: Style.duration(500); easing.type: Easing.InOutSine }
    }
  }

  // A theme switch redraws Omarchy's app icons. The icon on screen stays until
  // its successor has loaded, rather than blanking while it loads, and the new
  // one fades in over it like the bar's palette.
  component AppIcon: Item {
    id: appIcon

    property url source

    function reveal() {
      if (current.status !== Image.Loading && previous.source.toString() !== "") fadeIn.restart()
    }

    onSourceChanged: {
      fadeIn.stop()
      // Set while the current image still holds it, so it comes from the
      // cache. One still loading leaves the icon on screen where it is.
      if (current.status === Image.Ready) previous.source = current.source
      current.opacity = previous.source.toString() !== "" ? 0 : 1
      current.source = appIcon.source
      appIcon.reveal()
    }
    Component.onCompleted: current.source = appIcon.source

    Image {
      id: previous
      anchors.fill: parent
      sourceSize: current.sourceSize
      fillMode: Image.PreserveAspectFit
      asynchronous: true
      smooth: true
      mipmap: true
    }

    Image {
      id: current
      anchors.fill: parent
      sourceSize: Qt.size(window.iconSize * 2, window.iconSize * 2)
      fillMode: Image.PreserveAspectFit
      asynchronous: true
      smooth: true
      mipmap: true
      onStatusChanged: appIcon.reveal()
    }

    NumberAnimation {
      id: fadeIn
      target: current
      property: "opacity"
      to: 1
      duration: Style.duration(250)
      easing.type: Easing.OutCubic
      onFinished: previous.source = ""
    }
  }

  BorderSurface {
    id: hoverTip

    readonly property var item: (window.hoveredKey && window.dock) ? window.dock.itemFor(window.hoveredKey) : null
    readonly property var stats: DockModel.itemStats(item ? item.windows : [])
    readonly property string titleText: {
      if (!item || !window.dock) return ""
      var name = window.dock.displayNameFor(item)
      if (stats.total === 0) return name
      if (stats.minimized > 0 && stats.open > 0) {
        return name + " (" + Commons.I18n.t("dock.tooltipOpenAndMinimized")
          .arg(Commons.I18n.formatNumber(stats.open))
          .arg(Commons.I18n.formatNumber(stats.minimized)) + ")"
      }
      if (stats.minimized > 0) {
        return name + " (" + Commons.I18n.t("dock.tooltipMinimized").arg(Commons.I18n.formatNumber(stats.minimized)) + ")"
      }
      if (stats.total > 1) return name + " (" + Commons.I18n.formatNumber(stats.total) + ")"
      return name
    }

    visible: window.contentShown && !window.dragging && !window.menuOpen && !!item && !!window.hoveredSlot && titleText !== ""
    width: Math.min(Style.space(280), tipLabel.implicitWidth + Style.spacing.controlPaddingX * 2 + padding * 2)
    height: tipLabel.implicitHeight + Style.space(8) + padding * 2
    x: window.popupX(window.hoveredSlot, hoverTip)
    y: window.popupY(window.hoveredSlot, hoverTip)
    radius: Style.cornerRadius
    color: Commons.Color.popups.background
    borderSpec: Border.surfaceSpec("popups", "border", Commons.Color.popups.border, Style.normalBorderWidth)
    padding: Style.spacing.xs

    Text {
      id: tipLabel
      anchors.centerIn: parent
      width: Math.min(implicitWidth, parent.width - parent.padding * 2 - Style.spacing.controlPaddingX * 2)
      textFormat: Text.PlainText
      elide: Text.ElideRight
      text: hoverTip.titleText
      color: Commons.Color.popups.text
      font.family: Style.font.family
      font.pixelSize: Style.font.caption
    }
  }

  BorderSurface {
    id: menu

    readonly property var item: (window.menuKey && window.dock) ? window.dock.itemFor(window.menuKey) : null
    readonly property bool hasEntry: !!item && !!window.dock && !!window.dock.entryFor(item)
    readonly property bool running: !!item && item.windows.length > 0
    readonly property bool showFullActions: window.fullMenu && running && !!targetWindow
    readonly property var targetWindow: {
      if (!running || !item) return null
      var wins = item.windows
      if (window.selectedAddress) {
        for (var i = 0; i < wins.length; i++) {
          if (wins[i].address === window.selectedAddress) return wins[i]
        }
      }
      return wins.length > 0 ? wins[0] : null
    }
    readonly property int monitorBlock: window.workspaceId >= 1 ? Math.floor((window.workspaceId - 1) / 10) : 0
    readonly property real maxMenuHeight: Math.max(Style.space(260), Math.round((window.screen ? window.screen.height : 900) * 0.72))

    visible: window.contentShown && (!!item || window.settingsMenu)
    width: running ? Style.space(330) : Math.max(Style.space(180), menuColumn.implicitWidth) + padding * 2
    height: Math.min(menuColumn.implicitHeight, maxMenuHeight) + padding * 2
    x: window.popupX(window.menuSlot, menu)
    y: window.popupY(window.menuSlot, menu)
    radius: Style.cornerRadius
    color: Commons.Color.popups.background
    borderSpec: Border.surfaceSpec("popups", "border", Commons.Color.popups.border, Style.normalBorderWidth)
    padding: Style.spacing.sm

    Flickable {
      id: menuFlick
      x: menu.contentLeftInset
      y: menu.contentTopInset
      width: menu.width - menu.contentLeftInset - menu.contentRightInset
      height: menu.height - menu.contentTopInset - menu.contentBottomInset
      contentWidth: width
      contentHeight: menuColumn.implicitHeight
      clip: true
      boundsBehavior: Flickable.StopAtBounds
      ScrollBar.vertical: ScrollBar {
        policy: menuFlick.contentHeight > menuFlick.height ? ScrollBar.AlwaysOn : ScrollBar.AsNeeded
      }

      Column {
        id: menuColumn
        width: menuFlick.width

        Repeater {
          model: [["top", Commons.I18n.t("dock.positionTop")], ["bottom", Commons.I18n.t("dock.positionBottom")], ["left", Commons.I18n.t("dock.positionLeft")], ["right", Commons.I18n.t("dock.positionRight")]]

          // Each row acts, then closes the menu: the actions read its item.
          delegate: PopupMenuRow {
            required property var modelData

            visible: window.settingsMenu
            text: modelData[1]
            checked: window.position === modelData[0]
            onTriggered: {
              Util.execDetached("omarchy-dock position " + modelData[0])
              window.closeMenu()
            }
          }
        }

        PopupMenuRow {
          visible: window.settingsMenu
          text: Commons.I18n.t("dock.autoHide")
          checked: window.autohide
          onTriggered: {
            Util.execDetached("omarchy-dock autohide " + (window.autohide ? "off" : "on"))
            window.closeMenu()
          }
        }

        Flickable {
          id: winFlick
          visible: menu.running
          width: menuColumn.width
          height: visible ? Math.min(winListCol.implicitHeight, window.fullMenu ? Style.space(180) : Style.space(260)) : 0
          contentWidth: width
          contentHeight: winListCol.implicitHeight
          clip: true
          boundsBehavior: Flickable.StopAtBounds
          ScrollBar.vertical: ScrollBar {
            policy: winFlick.contentHeight > winFlick.height ? ScrollBar.AlwaysOn : ScrollBar.AsNeeded
          }

          Column {
            id: winListCol
            width: winFlick.width
            spacing: Style.space(2)

            Repeater {
              model: menu.running && menu.item ? menu.item.windows : []

              delegate: Rectangle {
                required property var modelData
                readonly property bool isActivated: !!modelData.activated
                readonly property bool isMinimized: !!modelData.minimized
                readonly property bool isTarget: !!menu.targetWindow && menu.targetWindow.address === modelData.address
                readonly property int originWs: isMinimized ? DockModel.minimizedOriginWorkspace(modelData.tags) : -1
                readonly property string wsBadge: {
                  if (isMinimized) {
                    return originWs >= 1
                      ? Commons.I18n.t("dock.minimizedFrom").arg(Commons.I18n.formatNumber(DockModel.slotOf(originWs)))
                      : Commons.I18n.t("dock.minimized")
                  }
                  var slot = DockModel.slotOf(modelData.workspaceId)
                  return Commons.I18n.t("dock.ws").arg(Commons.I18n.formatNumber(slot >= 1 ? slot : modelData.workspaceId))
                }
                readonly property string rowLabel: window.dock ? window.dock.formatWindowLabel(modelData, window.menuKey) : String(modelData.title || "")

                width: winListCol.width
                height: Style.spacing.popupRowHeight
                radius: Style.cornerRadius
                color: (winRowMouse.containsMouse || winCloseMouse.containsMouse || targetPickMouse.containsMouse)
                  ? Style.hoverFill
                  : (window.fullMenu && menu.item && menu.item.windows.length > 1 && isTarget ? Util.alpha(Commons.Color.accent, 0.12) : "transparent")

                MouseArea {
                  id: winRowMouse
                  anchors.fill: parent
                  hoverEnabled: true
                  cursorShape: Qt.PointingHandCursor
                  onClicked: {
                    if (window.dock) window.dock.bringForward(modelData, window.workspaceId)
                    window.closeMenu()
                  }
                }

                Item {
                  id: statusDotBox
                  anchors.left: parent.left
                  anchors.leftMargin: Style.space(6)
                  anchors.verticalCenter: parent.verticalCenter
                  width: Style.space(18)
                  height: Style.space(18)

                  Rectangle {
                    anchors.centerIn: parent
                    width: isTarget && window.fullMenu && menu.item && menu.item.windows.length > 1 ? Style.space(8) : Style.space(6)
                    height: width
                    radius: width / 2
                    color: isActivated ? Commons.Color.accent : (isMinimized ? "transparent" : Util.alpha(Commons.Color.popups.text, 0.65))
                    border.width: isMinimized || (isTarget && window.fullMenu && menu.item && menu.item.windows.length > 1) ? 1.5 : 0
                    border.color: Commons.Color.accent
                  }

                  MouseArea {
                    id: targetPickMouse
                    anchors.fill: parent
                    visible: window.fullMenu && !!menu.item && menu.item.windows.length > 1
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: window.selectedAddress = modelData.address
                  }
                }

                Text {
                  anchors.left: statusDotBox.right
                  anchors.leftMargin: Style.space(4)
                  anchors.right: badgePill.left
                  anchors.rightMargin: Style.space(6)
                  anchors.verticalCenter: parent.verticalCenter
                  textFormat: Text.PlainText
                  elide: Text.ElideRight
                  text: rowLabel
                  color: Commons.Color.popups.text
                  font.family: Style.font.family
                  font.pixelSize: Style.font.body
                  font.bold: isActivated
                }

                Rectangle {
                  id: badgePill
                  anchors.right: winCloseBtn.left
                  anchors.rightMargin: Style.space(4)
                  anchors.verticalCenter: parent.verticalCenter
                  height: badgeLabel.implicitHeight + Style.space(4)
                  width: badgeLabel.implicitWidth + Style.space(8)
                  radius: Math.max(Style.cornerRadius, Style.space(4))
                  color: isMinimized ? Util.alpha(Commons.Color.accent, 0.2) : Util.alpha(Commons.Color.popups.text, 0.1)

                  Text {
                    id: badgeLabel
                    anchors.centerIn: parent
                    textFormat: Text.PlainText
                    text: wsBadge
                    color: isMinimized ? Commons.Color.accent : Util.alpha(Commons.Color.popups.text, 0.78)
                    font.family: Style.font.family
                    font.pixelSize: Math.max(9, Style.font.caption - 1)
                    font.bold: isMinimized
                  }
                }

                Rectangle {
                  id: winCloseBtn
                  anchors.right: parent.right
                  anchors.rightMargin: Style.space(4)
                  anchors.verticalCenter: parent.verticalCenter
                  width: Style.space(20)
                  height: Style.space(20)
                  radius: Style.cornerRadius
                  color: winCloseMouse.containsMouse ? Util.alpha(Commons.Color.urgent, 0.25) : "transparent"

                  Text {
                    anchors.centerIn: parent
                    textFormat: Text.PlainText
                    text: "×"
                    color: winCloseMouse.containsMouse ? Commons.Color.urgent : Util.alpha(Commons.Color.popups.text, 0.6)
                    font.family: Style.font.family
                    font.pixelSize: Style.font.body
                  }

                  MouseArea {
                    id: winCloseMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                      if (window.dock) window.dock.closeWindow(modelData)
                    }
                  }
                }
              }
            }
          }
        }

        // Target label when multiple windows share the slot in right-click menu.
        Text {
          visible: menu.showFullActions && !!menu.item && menu.item.windows.length > 1
          width: menuColumn.width
          leftPadding: Style.spacing.controlPaddingX
          rightPadding: Style.spacing.controlPaddingX
          topPadding: Style.space(4)
          textFormat: Text.PlainText
          elide: Text.ElideRight
          text: menu.targetWindow
            ? Commons.I18n.t("dock.targetPrefix").arg(window.dock ? window.dock.formatWindowLabel(menu.targetWindow, window.menuKey) : menu.targetWindow.title)
            : ""
          color: Util.alpha(Commons.Color.popups.text, 0.62)
          font.family: Style.font.family
          font.pixelSize: Math.max(9, Style.font.caption - 1)
        }

        MenuDivider { visible: menu.showFullActions }

        // Move to Workspace pills: [1] [2] [3] [4] [5] [Here]
        Item {
          visible: menu.showFullActions
          width: menuColumn.width
          height: visible ? Style.spacing.popupRowHeight : 0

          Row {
            anchors.fill: parent
            anchors.leftMargin: Style.spacing.controlPaddingX
            anchors.rightMargin: Style.spacing.controlPaddingX
            spacing: Style.space(6)

            Text {
              anchors.verticalCenter: parent.verticalCenter
              textFormat: Text.PlainText
              text: Commons.I18n.t("dock.moveToWs")
              color: Util.alpha(Commons.Color.popups.text, 0.72)
              font.family: Style.font.family
              font.pixelSize: Style.font.caption
            }

            Row {
              anchors.verticalCenter: parent.verticalCenter
              spacing: Style.space(4)

              Repeater {
                model: [1, 2, 3, 4, 5]
                delegate: Rectangle {
                  required property int modelData
                  readonly property int destWs: menu.monitorBlock * 10 + modelData
                  readonly property bool isCurrentWs: !!menu.targetWindow && !menu.targetWindow.minimized && menu.targetWindow.workspaceId === destWs
                  width: Style.space(22)
                  height: Style.space(20)
                  radius: Style.cornerRadius
                  color: isCurrentWs ? Commons.Color.accent : (wsBtnMouse.containsMouse ? Style.hoverFill : Util.alpha(Commons.Color.popups.text, 0.08))
                  border.width: 1
                  border.color: isCurrentWs ? Commons.Color.accent : Util.alpha(Commons.Color.popups.text, 0.2)

                  Text {
                    anchors.centerIn: parent
                    textFormat: Text.PlainText
                    text: Commons.I18n.formatNumber(modelData)
                    color: isCurrentWs ? Commons.Color.background : Commons.Color.popups.text
                    font.family: Style.font.family
                    font.pixelSize: Style.font.caption
                    font.bold: isCurrentWs
                  }

                  MouseArea {
                    id: wsBtnMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                      if (window.dock && menu.targetWindow) window.dock.moveWindowToWorkspace(menu.targetWindow, destWs, false)
                      window.closeMenu()
                    }
                  }
                }
              }

              Rectangle {
                visible: !!menu.targetWindow && (menu.targetWindow.minimized || menu.targetWindow.workspaceId !== window.workspaceId) && window.workspaceId >= 1
                height: Style.space(20)
                width: hereTxt.implicitWidth + Style.space(10)
                radius: Style.cornerRadius
                color: hereMouse.containsMouse ? Style.hoverFill : Util.alpha(Commons.Color.accent, 0.16)
                border.width: 1
                border.color: Commons.Color.accent

                Text {
                  id: hereTxt
                  anchors.centerIn: parent
                  textFormat: Text.PlainText
                  text: Commons.I18n.t("dock.here")
                  color: Commons.Color.accent
                  font.family: Style.font.family
                  font.pixelSize: Style.font.caption
                  font.bold: true
                }

                MouseArea {
                  id: hereMouse
                  anchors.fill: parent
                  hoverEnabled: true
                  cursorShape: Qt.PointingHandCursor
                  onClicked: {
                    if (window.dock && menu.targetWindow) {
                      if (menu.targetWindow.minimized) window.dock.bringForward(menu.targetWindow, window.workspaceId)
                      else window.dock.moveWindowToWorkspace(menu.targetWindow, window.workspaceId, true)
                    }
                    window.closeMenu()
                  }
                }
              }
            }
          }
        }

        // Move / Place pills: [Left] [Center] [Right]
        Item {
          visible: menu.showFullActions
          width: menuColumn.width
          height: visible ? Style.spacing.popupRowHeight : 0

          Row {
            anchors.fill: parent
            anchors.leftMargin: Style.spacing.controlPaddingX
            anchors.rightMargin: Style.spacing.controlPaddingX
            spacing: Style.space(8)

            Text {
              anchors.verticalCenter: parent.verticalCenter
              textFormat: Text.PlainText
              text: Commons.I18n.t("dock.place")
              color: Util.alpha(Commons.Color.popups.text, 0.72)
              font.family: Style.font.family
              font.pixelSize: Style.font.caption
            }

            Row {
              anchors.verticalCenter: parent.verticalCenter
              spacing: Style.space(4)

              Repeater {
                model: [
                  { id: "left", label: Commons.I18n.t("dock.placeLeft") },
                  { id: "center", label: Commons.I18n.t("dock.placeCenter") },
                  { id: "right", label: Commons.I18n.t("dock.placeRight") }
                ]
                delegate: Rectangle {
                  required property var modelData
                  height: Style.space(20)
                  width: placeTxt.implicitWidth + Style.space(12)
                  radius: Style.cornerRadius
                  color: placeMouse.containsMouse ? Style.hoverFill : Util.alpha(Commons.Color.popups.text, 0.08)
                  border.width: 1
                  border.color: Util.alpha(Commons.Color.popups.text, 0.2)

                  Text {
                    id: placeTxt
                    anchors.centerIn: parent
                    textFormat: Text.PlainText
                    text: modelData.label
                    color: Commons.Color.popups.text
                    font.family: Style.font.family
                    font.pixelSize: Style.font.caption
                  }

                  MouseArea {
                    id: placeMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                      if (window.dock && menu.targetWindow) window.dock.placeWindow(menu.targetWindow, modelData.id, window.monitor, window.workspaceId)
                      window.closeMenu()
                    }
                  }
                }
              }
            }
          }
        }

        MenuDivider { visible: menu.showFullActions }

        PopupMenuRow {
          visible: menu.showFullActions && !!menu.targetWindow && menu.targetWindow.minimized
          text: Commons.I18n.t("dock.restore")
          onTriggered: {
            if (window.dock && menu.targetWindow) window.dock.bringForward(menu.targetWindow, window.workspaceId)
            window.closeMenu()
          }
        }

        PopupMenuRow {
          visible: menu.showFullActions && !!menu.targetWindow && !menu.targetWindow.minimized && !!window.dock && window.dock.isFloating(menu.targetWindow.workspaceId)
          text: Commons.I18n.t("dock.minimize")
          onTriggered: {
            if (window.dock && menu.targetWindow) window.dock.minimizeWindow(menu.targetWindow)
            window.closeMenu()
          }
        }

        PopupMenuRow {
          visible: menu.showFullActions
          text: Commons.I18n.t("dock.maximize")
          checked: !!menu.targetWindow && menu.targetWindow.fullscreen === 1
          onTriggered: {
            if (window.dock && menu.targetWindow) window.dock.toggleMaximize(menu.targetWindow, window.workspaceId)
            window.closeMenu()
          }
        }

        PopupMenuRow {
          visible: menu.showFullActions
          text: Commons.I18n.t("dock.fullscreen")
          checked: !!menu.targetWindow && menu.targetWindow.fullscreen >= 2
          onTriggered: {
            if (window.dock && menu.targetWindow) window.dock.toggleFullscreen(menu.targetWindow, window.workspaceId)
            window.closeMenu()
          }
        }

        PopupMenuRow {
          visible: menu.showFullActions
          text: Commons.I18n.t("dock.floating")
          checked: !!menu.targetWindow && !!menu.targetWindow.floating
          onTriggered: {
            if (window.dock && menu.targetWindow) window.dock.toggleFloating(menu.targetWindow, window.workspaceId)
            window.closeMenu()
          }
        }

        PopupMenuRow {
          visible: menu.showFullActions
          text: Commons.I18n.t("dock.pin")
          checked: !!menu.targetWindow && !!menu.targetWindow.pinned
          onTriggered: {
            if (window.dock && menu.targetWindow) window.dock.togglePin(menu.targetWindow, window.workspaceId)
            window.closeMenu()
          }
        }

        PopupMenuRow {
          visible: menu.showFullActions
          text: Commons.I18n.t("dock.scratchpad")
          onTriggered: {
            if (window.dock && menu.targetWindow) window.dock.moveWindowToScratchpad(menu.targetWindow)
            window.closeMenu()
          }
        }

        PopupMenuRow {
          visible: menu.showFullActions && Quickshell.screens.length > 1
          text: Commons.I18n.t("dock.nextMonitor")
          onTriggered: {
            if (window.dock && menu.targetWindow) window.dock.moveWindowToNextMonitor(menu.targetWindow, window.monitor)
            window.closeMenu()
          }
        }

        MenuDivider { visible: menu.running }

        PopupMenuRow {
          visible: menu.hasEntry && (window.fullMenu || !menu.running)
          text: Commons.I18n.t("dock.newWindow")
          onTriggered: {
            if (window.dock && menu.item) window.dock.launch(menu.item)
            window.closeMenu()
          }
        }

        PopupMenuRow {
          visible: menu.hasEntry && window.fullMenu
          text: menu.item && menu.item.pinned ? Commons.I18n.t("dock.removeFromDock") : Commons.I18n.t("dock.keepInDock")
          onTriggered: {
            if (window.dock && menu.item) window.dock.setPinned(menu.item.key, !menu.item.pinned)
            window.closeMenu()
          }
        }

        PopupMenuRow {
          visible: menu.showFullActions && !!menu.targetWindow
          text: Commons.I18n.t("dock.closeWindow")
          onTriggered: {
            if (window.dock && menu.targetWindow) window.dock.closeWindow(menu.targetWindow)
            window.closeMenu()
          }
        }

        PopupMenuRow {
          visible: window.fullMenu && menu.running && (!menu.item || menu.item.windows.length > 1)
          text: menu.item
            ? Commons.I18n.t("dock.quitAll").arg(Commons.I18n.formatNumber(menu.item.windows.length))
            : Commons.I18n.t("dock.quit")
          onTriggered: {
            if (window.dock && menu.item) window.dock.quit(menu.item)
            window.closeMenu()
          }
        }
      }
    }
  }

  component MenuDivider: Item {
    width: menuColumn.width
    height: visible ? Style.space(5) : 0

    PanelSeparator {
      anchors.verticalCenter: parent.verticalCenter
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.leftMargin: Style.spacing.controlPaddingX
      anchors.rightMargin: Style.spacing.controlPaddingX
      foreground: Commons.Color.popups.text
      strength: 0.15
    }
  }
}
