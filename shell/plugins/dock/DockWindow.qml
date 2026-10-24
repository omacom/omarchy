import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import qs.Commons
import qs.Commons as Commons
import qs.Ui
import "DockModel.js" as DockModel

// One screen's dock. It stays mapped and only hides its contents, so switching
// to a floating workspace does not wait on a fresh layer surface. While hidden the
// mask is empty and clicks fall through to the windows below.
PanelWindow {
  id: window
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
  readonly property bool menuOpen: menuItem !== null || settingsMenu
  readonly property bool tucked: autohide && !(revealed || menuOpen || dragging || insertIndex >= 0)
  readonly property bool contentShown: shown && !tucked

  readonly property int gap: Style.spacing.xs
  readonly property int iconSize: Math.round(36 * Style.fontScale)
  // Each app has a square slot with its icon in the middle, and the slots run
  // straight to the edge of the dock.
  readonly property int iconInset: Style.spacing.lg
  readonly property int slotSize: iconSize + iconInset * 2
  // The dock sits on a rounded panel, with this much of it around the slots.
  readonly property int pad: Style.spacing.xs
  readonly property int panelThickness: slotSize + pad * 2
  // A pinned app that is not running is drawn faded; one whose windows are all
  // minimized is open, so it sits between that and a running app.
  readonly property real idleOpacity: 0.55
  readonly property real minimizedOpacity: 0.8
  // The thumbnails a hovered app shows: one per window, in a row along a
  // horizontal dock and in a column beside a vertical one.
  readonly property bool previews: !!dock && dock.previews
  readonly property int previewWidth: Math.round(190 * Style.fontScale)
  readonly property int previewHeight: Math.round(previewWidth * 0.6)
  readonly property int previewLimit: vertical ? 3 : 4
  // Room inward of the dock for its menus: the tallest, the apps button's,
  // has five rows.
  readonly property int menuRoom: Style.spacing.popupRowHeight * 5 + Style.spacing.sm * 2 + Style.normalBorderWidth * 2 + gap * 2
  // ...and for the previews, which reach as far inward as one thumbnail is
  // deep (with the app's name above it) or wide. The dock's surface is only
  // as big as this, so anything taller would be cut off.
  readonly property int previewRoom: !previews ? 0
    : (vertical ? previewWidth + Style.space(40) : previewHeight + Style.space(96)) + gap * 2
  readonly property int popupRoom: Math.max(menuRoom, previewRoom)
  // Which way is inward from the screen edge, along the axis across the dock.
  readonly property int inward: position === "top" || position === "left" ? 1 : -1
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
    var first = window.slotSize + window.pad
    var count = window.dock ? window.dock.itemModel.count : 0
    return Math.max(0, Math.min(count, Math.round((along - first) / window.slotSize)))
  }
  property var menuItem: null
  property Item menuSlot: null
  // The apps button's menu: where the dock sits and whether it hides.
  property bool settingsMenu: false

  // The label that names an icon under the pointer. It waits a moment before
  // the first one shows, and follows the pointer from icon to icon without
  // waiting again.
  property var tipSlot: null
  property var pendingTipSlot: null
  property bool tipWarm: false

  function showTip(slot) {
    if (!slot || !slot.tip) return
    tipLeaveTimer.stop()
    window.pendingTipSlot = slot
    // A label still up, held for the pointer to reach it, moves on at once.
    if (window.tipWarm || window.tipSlot) window.tipSlot = slot
    else tipTimer.restart()
  }

  function hideTip(slot) {
    if (window.pendingTipSlot !== slot) return
    window.pendingTipSlot = null
    tipTimer.stop()
    if (window.tipSlot !== slot) return
    // The previews can be clicked, so they wait a moment for the pointer to
    // cross from the icon onto them.
    if (tip.previewing && tip.wanted) tipLeaveTimer.restart()
    else window.clearTip()
  }

  function clearTip() {
    window.tipSlot = null
    window.tipWarm = true
    tipWarmTimer.restart()
  }

  // A press on an icon is the pointer acting on it, so the label gets out of
  // the way. It comes back once the pointer has left and returned.
  function dismissTip() {
    window.pendingTipSlot = null
    tipTimer.stop()
    tipLeaveTimer.stop()
    window.tipSlot = null
  }

  // The tooltip keeps drawing the last slot it named while it fades out. With
  // no slot it would collapse to an empty box and slide to the corner.
  onTipSlotChanged: if (tipSlot) tip.lastSlot = tipSlot

  Timer {
    id: tipTimer
    interval: 350
    onTriggered: window.tipSlot = window.pendingTipSlot
  }

  Timer {
    id: tipWarmTimer
    interval: 400
    onTriggered: window.tipWarm = false
  }

  // Ends the wait for the pointer to reach the previews, unless it has.
  Timer {
    id: tipLeaveTimer
    interval: 250
    onTriggered: if (!tipHover.hovered && window.tipSlot !== null) window.clearTip()
  }

  onWorkspaceIdChanged: if (dock) dock.readMode(workspaceId)
  onShownChanged: {
    if (shown) return
    closeMenu()
    window.tipSlot = null
    window.pendingTipSlot = null
    window.revealed = false
  }
  Component.onCompleted: if (dock) dock.readMode(workspaceId)

  function openMenu(item, slot) {
    window.settingsMenu = false
    window.menuItem = item
    window.menuSlot = slot
  }

  function openSettingsMenu(slot) {
    window.menuItem = null
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
    window.menuItem = null
    window.settingsMenu = false
    window.menuSlot = null
    if (window.autohide) hideTimer.restart()
  }

  // Places the menu inward of the dock, centered on a slot.
  function popupX(slot, popup) {
    if (!slot) return 0
    var center = slot.mapToItem(window.contentItem, slot.width / 2, 0).x
    if (window.position === "left") return body.x + body.width + window.gap
    if (window.position === "right") return body.x - window.gap - popup.width
    return Math.max(window.gap, Math.min(window.width - popup.width - window.gap, center - popup.width / 2))
  }

  function popupY(slot, popup) {
    if (!slot) return 0
    var center = slot.mapToItem(window.contentItem, 0, slot.height / 2).y
    if (window.position === "top") return body.y + body.height + window.gap
    if (window.position === "bottom") return body.y - window.gap - popup.height
    return Math.max(window.gap, Math.min(window.height - popup.height - window.gap, center - popup.height / 2))
  }

  visible: !remapGuard.remapping
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

  implicitWidth: window.vertical ? window.gap + window.panelThickness + window.popupRoom : 0
  implicitHeight: window.vertical ? 0 : window.gap + window.panelThickness + window.popupRoom

  mask: Region {
    item: window.contentShown ? body : null

    Region { item: window.shown && window.autohide ? edgeTrigger : null }
    Region { item: menu.visible ? menu : null }
    // The previews take clicks; a plain name label does not.
    Region { item: tip.wanted && tip.previewing ? tip : null }
  }

  onAutohideChanged: window.revealed = false

  Timer {
    id: hideTimer
    // Long enough to cross a gap between the edge and the icons, no longer.
    interval: 150
    onTriggered: {
      if (!bodyHover.hovered && !edgeHover.hovered && !tipHover.hovered && !window.menuOpen && !window.dragging) window.revealed = false
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

  ScreenMoveRemap {
    id: remapGuard
    window: window
  }

  HyprlandFocusGrab {
    active: window.menuOpen
    windows: [window]
    onCleared: window.closeMenu()
  }

  Item {
    id: body

    // The strip keeps its order in every language, like the bar: drags and
    // drops reckon slots along x from the first app. Only the menu mirrors.
    LayoutMirroring.enabled: false
    LayoutMirroring.childrenInherit: true

    width: slots.implicitWidth + window.pad * 2
    height: slots.implicitHeight + window.pad * 2
    // How far the dock is tucked past its edge. Auto-hide slides it, but only
    // while the dock is on screen: arriving on a floating workspace shows it
    // where it belongs at once.
    property real tuck: window.tucked ? window.panelThickness + window.gap : 0

    Behavior on tuck {
      enabled: window.shown
      NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
    }

    x: window.position === "left" ? window.gap - tuck
      : window.position === "right" ? window.width - width - window.gap + tuck
      : Math.round((window.width - width) / 2)
    y: window.position === "top" ? window.gap - tuck
      : window.position === "bottom" ? window.height - height - window.gap + tuck
      : Math.round((window.height - height) / 2)
    // Switching between tiled and floating workspaces shows and hides the dock
    // at once, with nothing to watch in between. Hidden by opacity rather than
    // visibility, so the icons keep their textures and are drawn on the first
    // frame back instead of being uploaded again.
    opacity: window.shown ? 1 : 0

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

    // The dock's panel, in the same look as its menus.
    BorderSurface {
      anchors.fill: parent
      radius: Style.cornerRadius
      color: Commons.Color.popups.background
      borderSpec: Border.surfaceSpec("popups", "border", Commons.Color.popups.border, Style.normalBorderWidth)
    }

    Grid {
      id: slots
      anchors.centerIn: parent
      columns: window.vertical ? 1 : appRepeater.count + 1

      AppsSlot {}

      Repeater {
        id: appRepeater
        model: window.dock ? window.dock.itemModel : null

        delegate: AppSlot {}
      }
    }

    // A hairline between the apps button and the apps. It takes no room of its
    // own, and steps out of the way while icons are being moved.
    Rectangle {
      readonly property int thickness: Math.max(1, Style.space(1))
      readonly property int length: Math.round(window.slotSize * 0.46)
      readonly property int along: window.pad + window.slotSize

      visible: appRepeater.count > 0
      opacity: window.dragging || window.insertIndex >= 0 ? 0 : 1
      width: window.vertical ? length : thickness
      height: window.vertical ? thickness : length
      x: window.vertical ? Math.round((body.width - width) / 2) : along - Math.floor(thickness / 2)
      y: window.vertical ? along - Math.floor(thickness / 2) : Math.round((body.height - height) / 2)
      color: Util.alpha(Commons.Color.popups.text, 0.22)

      Behavior on opacity { NumberAnimation { duration: 120 } }
    }
  }

  component Slot: Item {
    id: slot

    // Only the dragged icon is lifted while a drag is on; none of the others
    // pop as it passes over them.
    property bool hovered: mouse.containsMouse && !window.hoverStale && !window.dragging
    property bool pressed: mouse.pressed
    property alias mouse: mouse
    // What the label names this slot, and for an app, its windows (for the
    // previews) and the icon shown until a window's picture arrives.
    property string tip: ""
    property var tipWindows: []
    property string tipIcon: ""
    onHoveredChanged: if (hovered) window.showTip(slot); else window.hideTip(slot)
    onPressedChanged: if (pressed) window.dismissTip()

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

    tip: Commons.I18n.t("dock.apps", "Apps")

    Rectangle {
      x: window.iconInset / 2
      y: window.iconInset / 2
      width: window.slotSize - window.iconInset
      height: window.slotSize - window.iconInset
      radius: Style.cornerRadius
      color: appsSlot.pressed ? Style.pressedFill : appsSlot.hovered ? Style.hoverFill : "transparent"

      Behavior on color { ColorAnimation { duration: 120 } }
    }

    Behavior on displayedShift {
      enabled: window.animateShifts
      NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
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

      Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }

      Grid {
        readonly property int square: Math.round(window.iconSize * 0.22)

        anchors.centerIn: parent
        columns: 3
        spacing: Math.round(window.iconSize * 0.1)

        Repeater {
          model: 9

          delegate: Rectangle {
            width: parent.square
            height: parent.square
            radius: Math.max(1, Math.round(parent.square * 0.2))
            color: Commons.Color.popups.text
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
    readonly property bool launching: !!window.dock && window.dock.isLaunching(key)
    readonly property bool lifted: window.dragIndex === index
    property point pressPoint
    property bool dragged: false
    readonly property int windowCount: modelData ? modelData.windows.length : 0
    readonly property string dockState: window.dock ? window.dock.stateFor(modelData) : "idle"
    readonly property var counts: window.dock ? window.dock.countsFor(modelData) : ({ total: 0, minimized: 0, visible: 0 })
    // One of the app's windows has the focus.
    readonly property bool focused: {
      if (!modelData) return false
      for (var i = 0; i < modelData.windows.length; i++) {
        if (modelData.windows[i].toplevel.activated) return true
      }
      return false
    }
    // Slides in when the app joins the dock, and bounces while it launches.
    property real appear: 0
    property real bounce: 0

    NumberAnimation on appear { from: 0; to: 1; duration: 220; easing.type: Easing.OutCubic }

    tip: window.dock ? window.dock.labelFor(modelData) : ""
    tipWindows: modelData ? modelData.windows : []
    tipIcon: window.dock && modelData ? window.dock.iconFor(modelData) : ""

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
      NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
    }

    z: lifted ? 1 : 0

    // The slot, and the pointer handling in it, stays where it is; only the
    // icon moves. Reading the pointer through a slot that moves with it would
    // feed each move back into the next.
    function bodyPoint(event) {
      return appSlot.mapToItem(body, event.x, event.y)
    }

    mouse.onPressed: function(event) {
      appSlot.dragged = false
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
        window.openMenu(appSlot.modelData, appSlot)
        return
      }
      window.closeMenu()
      if (event.button === Qt.MiddleButton) window.dock.newWindow(appSlot.modelData)
      else window.dock.activate(appSlot.modelData)
    }

    // The plate behind the icon: faint under the pointer, firmer while pressed,
    // and tinted with the accent on the app that has the focus.
    Rectangle {
      x: window.iconInset / 2
      y: window.iconInset / 2
      width: window.slotSize - window.iconInset
      height: window.slotSize - window.iconInset
      radius: Style.cornerRadius
      color: appSlot.pressed && !appSlot.lifted ? Style.pressedFill
        : appSlot.focused ? Style.selectedAccentFill
        : (appSlot.hovered || appSlot.lifted) ? Style.hoverFill
        : "transparent"
      opacity: appSlot.appear
      transform: Translate {
        x: window.vertical ? 0 : appSlot.displayedShift
        y: window.vertical ? appSlot.displayedShift : 0
      }

      Behavior on color { ColorAnimation { duration: 120 } }
    }

    // Running apps are drawn in full, apps whose windows are all minimized a
    // little softer, and pinned ones that are not running faded.
    Image {
      x: window.iconInset
      y: window.iconInset
      width: window.iconSize
      height: window.iconSize
      sourceSize: Qt.size(window.iconSize * 2, window.iconSize * 2)
      source: window.dock && appSlot.modelData ? window.dock.iconFor(appSlot.modelData) : ""
      fillMode: Image.PreserveAspectFit
      asynchronous: true
      smooth: true
      mipmap: true
      opacity: appSlot.appear * (appSlot.launching || appSlot.dockState === "running" ? 1
        : appSlot.dockState === "minimized" ? window.minimizedOpacity
        : window.idleOpacity)
      transform: [
        Translate {
          x: window.vertical ? 0 : appSlot.displayedShift
          y: window.vertical ? appSlot.displayedShift : 0
        },
        Translate {
          x: window.vertical ? appSlot.bounce * window.inward : 0
          y: window.vertical ? 0 : appSlot.bounce * window.inward
        }
      ]
      scale: (0.6 + 0.4 * appSlot.appear) * (appSlot.lifted || appSlot.hovered ? (appSlot.pressed && !appSlot.lifted ? 1.05 : 1.15) : 1)
      transformOrigin: window.popOrigin

      Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
      Behavior on opacity { NumberAnimation { duration: 150 } }
    }

    // On the edge of the slot toward the screen edge: a dot for each window in
    // view, a ring for each minimized one, three at most. The focused app's
    // first dot stretches into a pill in the accent color.
    Item {
      id: dots

      readonly property int size: Math.max(4, Math.round(window.iconSize * 0.12))
      readonly property int step: size + Math.max(2, Math.round(size * 0.75))
      readonly property int shown: Math.min(3, appSlot.counts.total)
      readonly property int filled: Math.min(appSlot.counts.visible, shown - (appSlot.counts.minimized > 0 ? 1 : 0))
      readonly property int stretch: appSlot.focused && filled > 0 ? Math.round(size * 1.8) : 0
      // Kept clear of the icon: it sits under the icon's plate, in the strip
      // between the plate and the slot's edge, so the gap to the icon is the
      // plate's own margin plus a little air, and it stays put whether or not
      // the plate is showing.
      readonly property int edge: Math.max(0, Math.round(window.iconInset / 2) - size - Math.max(1, Style.space(2)))
      readonly property int run: shown > 0 ? size + stretch + (shown - 1) * step : 0
      readonly property color tone: appSlot.focused ? Commons.Color.accent : Util.alpha(Commons.Color.popups.text, 0.7)

      visible: shown > 0
      opacity: appSlot.appear
      width: window.vertical ? size : run
      height: window.vertical ? run : size
      x: window.position === "left" ? edge
        : window.position === "right" ? appSlot.width - width - edge
        : Math.round((appSlot.width - width) / 2)
      y: window.position === "top" ? edge
        : window.position === "bottom" ? appSlot.height - height - edge
        : Math.round((appSlot.height - height) / 2)
      transform: Translate {
        x: window.vertical ? 0 : appSlot.displayedShift
        y: window.vertical ? appSlot.displayedShift : 0
      }

      Repeater {
        model: dots.shown

        delegate: Rectangle {
          required property int index
          readonly property bool ring: index >= dots.filled
          readonly property bool pill: index === 0 && dots.stretch > 0
          readonly property int along: index * dots.step + (index > 0 ? dots.stretch : 0)

          x: window.vertical ? 0 : along
          y: window.vertical ? along : 0
          width: window.vertical ? dots.size : dots.size + (pill ? dots.stretch : 0)
          height: window.vertical ? dots.size + (pill ? dots.stretch : 0) : dots.size
          radius: dots.size / 2
          color: ring ? "transparent" : dots.tone
          border.width: ring ? Math.max(1, Math.round(dots.size * 0.25)) : 0
          border.color: dots.tone

          Behavior on width { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
          Behavior on height { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
        }
      }
    }

    SequentialAnimation {
      running: appSlot.launching
      loops: Animation.Infinite
      onRunningChanged: if (!running) appSlot.bounce = 0

      NumberAnimation { target: appSlot; property: "bounce"; to: Math.round(window.slotSize * 0.28); duration: 240; easing.type: Easing.OutQuad }
      NumberAnimation { target: appSlot; property: "bounce"; to: 0; duration: 240; easing.type: Easing.InQuad }
      PauseAnimation { duration: 300 }
    }
  }

  // Names the app under the pointer. A running app also shows a live picture
  // of each of its windows (the first few), the focused one outlined in the
  // accent and a minimized one dimmed. With previews off, or for an app that
  // is not running, it is just the name.
  BorderSurface {
    id: tip

    // The slot the label last named, kept through the fade-out.
    property var lastSlot: null

    readonly property var windows: lastSlot ? lastSlot.tipWindows : []
    readonly property bool previewing: window.previews && windows.length > 0
    readonly property var listing: DockModel.windowRows(windows, window.previewLimit)
    readonly property int cards: Math.max(1, listing.rows.length)
    readonly property bool wanted: window.contentShown && window.tipSlot !== null && !window.menuOpen
      && !window.dragging && window.insertIndex < 0
    // Along a horizontal dock the thumbnails share the screen's width, so they
    // narrow when there are many and the screen is small.
    readonly property int cardWidth: window.vertical ? window.previewWidth
      : Math.max(Style.space(96), Math.min(window.previewWidth,
          Math.floor((window.width - window.gap * 2 - contentLeftInset - contentRightInset - Style.spacing.sm * (cards - 1)) / cards)))

    visible: opacity > 0
    opacity: wanted ? 1 : 0
    leftPadding: Style.spacing.controlPaddingX
    rightPadding: Style.spacing.controlPaddingX
    topPadding: Style.spacing.controlPaddingY
    bottomPadding: Style.spacing.controlPaddingY
    width: tipColumn.implicitWidth + contentLeftInset + contentRightInset
    height: tipColumn.implicitHeight + contentTopInset + contentBottomInset
    x: window.popupX(lastSlot, tip)
    y: window.popupY(lastSlot, tip)
    radius: Style.cornerRadius
    color: Commons.Color.tooltip.background
    borderSpec: Border.surfaceSpec("tooltip", "border", Commons.Color.tooltip.border, Style.normalBorderWidth)

    Behavior on opacity { NumberAnimation { duration: 110 } }

    // The pointer on the previews keeps the label up, and keeps an auto-hidden
    // dock out.
    HoverHandler {
      id: tipHover
      onHoveredChanged: {
        if (hovered) return
        tipLeaveTimer.restart()
        if (window.autohide) hideTimer.restart()
      }
    }

    Column {
      id: tipColumn
      x: tip.contentLeftInset
      y: tip.contentTopInset
      spacing: Style.spacing.sm

      Text {
        id: tipHeading
        textFormat: Text.PlainText
        text: tip.lastSlot ? tip.lastSlot.tip : ""
        color: Commons.Color.tooltip.text
        font.family: Style.font.family
        font.pixelSize: Style.font.bodySmall
        font.bold: tip.previewing
        elide: Text.ElideRight
      }

      Binding {
        target: tipHeading
        property: "width"
        value: Math.max(0, window.popupRoom - tip.contentLeftInset - tip.contentRightInset)
        when: window.vertical
      }

      Grid {
        visible: tip.previewing
        columns: window.vertical ? 1 : tip.cards
        spacing: Style.spacing.sm

        Repeater {
          model: tip.previewing ? tip.listing.rows : []

          delegate: PreviewCard {
            // Capturing stops once the label has faded out.
            active: tip.visible
            cardWidth: tip.cardWidth
            icon: tip.lastSlot ? tip.lastSlot.tipIcon : ""
            // Picking a window brings that one forward, as a click on the
            // icon would for the app's first.
            onPicked: {
              window.dismissTip()
              if (window.dock) window.dock.bringForward(modelData)
            }
          }
        }
      }

      Text {
        visible: tip.previewing && tip.listing.hidden > 0
        textFormat: Text.PlainText
        text: "+" + tip.listing.hidden
        color: Commons.Color.tooltip.text
        opacity: 0.55
        font.family: Style.font.family
        font.pixelSize: Style.font.bodySmall
      }
    }
  }

  // One window's thumbnail. The picture is the compositor's own
  // capture of the window; until it arrives, or where the compositor has none
  // (a minimized window can be one), the app's icon stands in.
  component PreviewCard: Item {
    id: card

    required property var modelData
    property bool active: false
    property int cardWidth: window.previewWidth
    property string icon: ""
    signal picked()

    readonly property var toplevel: modelData ? modelData.toplevel : null
    readonly property bool minimized: !!modelData && modelData.minimized === true
    readonly property bool focused: !!toplevel && toplevel.activated
    readonly property int thumbHeight: Math.round(cardWidth * window.previewHeight / window.previewWidth)

    width: cardWidth
    height: thumb.height

    Item {
      id: thumb
      width: card.cardWidth
      height: card.thumbHeight
      clip: true

      Rectangle {
        anchors.fill: parent
        color: Util.alpha(Commons.Color.tooltip.text, 0.08)
      }

      Image {
        anchors.centerIn: parent
        width: Math.round(parent.height * 0.4)
        height: width
        sourceSize: Qt.size(width * 2, height * 2)
        source: card.icon
        fillMode: Image.PreserveAspectFit
        asynchronous: true
        smooth: true
        mipmap: true
        visible: !view.hasContent
        opacity: card.minimized ? 0.55 : 1
      }

      // Fitted inside the box, keeping the window's own proportions.
      ScreencopyView {
        id: view
        anchors.centerIn: parent
        visible: hasContent
        opacity: card.minimized ? 0.55 : 1
        captureSource: card.active ? card.toplevel : null
        live: true
        paintCursor: false
        constraintSize: Qt.size(thumb.width, thumb.height)
      }

      // Lightens under the pointer, and a little more while pressed.
      Rectangle {
        anchors.fill: parent
        color: pick.pressed ? Style.pressedFill : pick.containsMouse ? Style.hoverFill : "transparent"

        Behavior on color { ColorAnimation { duration: 120 } }
      }

      Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.width: Math.max(1, Style.space(1))
        border.color: card.focused ? Commons.Color.accent
          : pick.containsMouse ? Util.alpha(Commons.Color.tooltip.text, 0.6)
          : Util.alpha(Commons.Color.tooltip.text, 0.25)
      }
    }

    // The whole card is the target.
    MouseArea {
      id: pick
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onClicked: card.picked()
    }
  }

  BorderSurface {
    id: menu

    readonly property var item: window.menuItem
    readonly property bool hasEntry: !!item && !!window.dock && !!window.dock.entryFor(item)
    readonly property bool running: !!item && item.windows.length > 0
    readonly property bool inView: !!item && !!window.dock && item.windows.some(function(other) {
      return !other.minimized && other.workspaceId === window.dock.minimizeWorkspaceId()
    })

    visible: window.contentShown && (!!item || window.settingsMenu)
    width: Math.max(Style.space(140), menuColumn.implicitWidth) + padding * 2
    height: menuColumn.implicitHeight + padding * 2
    x: window.popupX(window.menuSlot, menu)
    y: window.popupY(window.menuSlot, menu)
    radius: Style.cornerRadius
    color: Commons.Color.popups.background
    borderSpec: Border.surfaceSpec("popups", "border", Commons.Color.popups.border, Style.normalBorderWidth)
    padding: Style.spacing.sm

    Column {
      id: menuColumn
      x: menu.contentLeftInset
      y: menu.contentTopInset
      width: menu.width - menu.contentLeftInset - menu.contentRightInset

      Repeater {
        model: [["top", Commons.I18n.t("dock.positionTop")], ["bottom", Commons.I18n.t("dock.positionBottom")], ["left", Commons.I18n.t("dock.positionLeft")], ["right", Commons.I18n.t("dock.positionRight")]]

        delegate: MenuRow {
          required property var modelData

          visible: window.settingsMenu
          text: modelData[1]
          checked: window.position === modelData[0]
          onTriggered: Util.execDetached("omarchy-dock position " + modelData[0])
        }
      }

      MenuRow {
        visible: window.settingsMenu
        text: Commons.I18n.t("dock.autoHide")
        checked: window.autohide
        onTriggered: Util.execDetached("omarchy-dock autohide " + (window.autohide ? "off" : "on"))
      }

      MenuRow {
        visible: menu.hasEntry && menu.running
        text: Commons.I18n.t("dock.newWindow")
        onTriggered: window.dock.newWindow(menu.item)
      }

      MenuRow {
        visible: menu.inView
        text: Commons.I18n.t("dock.minimize", "Minimize")
        onTriggered: window.dock.minimize(menu.item)
      }

      MenuRow {
        visible: menu.hasEntry
        text: menu.item && menu.item.pinned ? Commons.I18n.t("dock.removeFromDock") : Commons.I18n.t("dock.keepInDock")
        onTriggered: window.dock.setPinned(menu.item.key, !menu.item.pinned)
      }

      MenuRow {
        visible: menu.running
        text: Commons.I18n.t("dock.quit")
        onTriggered: window.dock.quit(menu.item)
      }
    }
  }

  component MenuRow: Rectangle {
    id: row

    property string text: ""
    property bool checked: false
    signal triggered()

    width: parent ? parent.width : 0
    height: visible ? Style.spacing.popupRowHeight : 0
    radius: Style.cornerRadius
    color: rowMouse.containsMouse ? Style.hoverFill : "transparent"

    Text {
      anchors.verticalCenter: parent.verticalCenter
      anchors.left: parent.left
      anchors.leftMargin: Style.spacing.controlPaddingX
      textFormat: Text.PlainText
      text: row.text
      color: Commons.Color.popups.text
      font.family: Style.font.family
      font.pixelSize: Style.font.body
    }

    Text {
      visible: row.checked
      anchors.verticalCenter: parent.verticalCenter
      anchors.right: parent.right
      anchors.rightMargin: Style.spacing.controlPaddingX
      textFormat: Text.PlainText
      text: "✓"
      color: Commons.Color.accent
      font.family: Style.font.family
      font.pixelSize: Style.font.body
    }

    MouseArea {
      id: rowMouse
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onClicked: {
        row.triggered()
        window.closeMenu()
      }
    }
  }
}
