import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import qs.Commons
import qs.Commons as Commons
import qs.Ui
import "DockModel.js" as DockModel

// One screen's dock. Mapped only while this screen is on a workspace that has
// one, so a session with the tiled dock turned off holds no live layer surface
// and dmabuf swapchain on its tiled workspaces.
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
  readonly property bool floating: !!dock && dock.isFloating(workspaceId)
  // Whether the workspace has a window on it. One minimized to the dock waits
  // on a workspace of its own, so it does not count.
  readonly property bool occupied: {
    var toplevels = Hyprland.toplevels.values
    for (var i = 0; i < toplevels.length; i++) {
      if (toplevels[i].workspace && toplevels[i].workspace.id === workspaceId) return true
    }
    return false
  }
  // Whether the dock comes out over windows: tiles run to the screen edges,
  // and so does a maximized window. A floating workspace's windows go where
  // they are put, mostly clear of it.
  readonly property bool overWindows: fullscreenMode === 1 || (!floating && occupied)
  readonly property bool shown: !!dock && (floating || (dock.tiling && !!workspace)) && fullscreenMode < 2
  // A hidden dock waits off screen until the pointer reaches its edge, and
  // stays while the pointer, a menu, or a drag still needs it. As it comes, the
  // dock stays out on an empty workspace, where it is the way to start
  // something, and hides once the workspace has a window. It can also be set to
  // stay out always or to hide always. A maximized window hides it either way,
  // so it can still be called up.
  readonly property bool autohide: !!dock && (dock.visibility === "hidden" || fullscreenMode === 1 || (dock.visibility === "first-app" && occupied))
  property bool revealed: false
  readonly property bool menuOpen: menuItem !== null || settingsMenu
  readonly property bool tucked: autohide && !(revealed || menuOpen || dragging || movingDock || holdOpen || insertIndex >= 0)
  readonly property bool contentShown: shown && !tucked

  readonly property int gap: Style.spacing.xs
  readonly property int iconSize: Math.round(36 * Style.fontScale)
  // Each app has a square slot with its icon in the middle, and the slots run
  // straight to the edge of the dock.
  readonly property int iconInset: Style.spacing.md
  readonly property int slotSize: iconSize + iconInset * 2
  // An app that is starting pulses down to this.
  readonly property real pulseOpacity: 0.7
  // Room inward of the dock for its menus: the tallest, the apps button's,
  // has five rows.
  readonly property int popupRoom: Style.spacing.popupRowHeight * 5 + Style.spacing.sm * 2 + Style.normalBorderWidth * 2 + gap * 2
  // A submenu opens beside the menu, which a vertical dock needs the width for.
  // It is as wide as the widest choice any of the submenus holds, so none is
  // clipped by the window, and the window does not resize as one opens.
  readonly property int submenuRoom: Math.max(Style.space(140), Math.ceil(submenu.widestOf(false))) + Style.spacing.sm * 2 + Style.normalBorderWidth * 2 + gap
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
  // The apps button dragged toward another screen edge moves the dock there,
  // to any edge but the bar's.
  property bool movingDock: false
  // A dock that has just moved stays out a moment, auto-hide or not, so it is
  // seen to have arrived rather than vanishing as it lands.
  property bool holdOpen: false

  function holdOpenBriefly() {
    window.holdOpen = true
    holdTimer.restart()
  }

  // A move asked for here: by the drag or the Position menu. The saved
  // position lands a moment later, so the dock is held open from the request
  // and again from its arrival. A position that arrives unasked, as the saved
  // one does at startup, holds nothing open.
  property bool moveRequested: false

  function moveTo(edge) {
    window.moveRequested = true
    window.holdOpenBriefly()
    Util.execDetached("omarchy-dock position " + edge)
  }

  onPositionChanged: {
    if (!window.moveRequested) return
    window.moveRequested = false
    window.holdOpenBriefly()
  }

  Timer {
    id: holdTimer
    interval: 1000
    onTriggered: {
      window.holdOpen = false
      if (window.autohide) hideTimer.restart()
    }
  }

  // The edge the pointer is nearest while the dock is dragged, shown by the
  // outline that previews the move.
  function trackMove(point) {
    if (!window.dock) return
    window.dock.moveScreen = window.screen
    window.dock.moveLength = window.vertical ? body.height : body.width
    window.dock.moveThickness = window.slotSize
    window.dock.moveEdge = DockModel.nearestEdge(point.x, point.y, window.screen.width, window.screen.height, window.barEdge)
  }

  function endMove() {
    window.movingDock = false
    if (!window.dock) return
    window.dock.moveEdge = ""
    window.dock.moveScreen = null
  }
  // The bar's edge, which the dock keeps off. A hidden bar holds none.
  readonly property string barEdge: dock && dock.shell && dock.shell.bar && !dock.shell.bar.barHidden ? String(dock.shell.bar.position || "top") : ""

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

  // The slot a point along the dock falls before, counting from the first app,
  // which comes after the apps button.
  function slotIndexAt(point) {
    var along = window.vertical ? point.y : point.x
    var first = window.slotSize
    var count = window.dock ? window.dock.itemModel.count : 0
    return Math.max(0, Math.min(count, Math.round((along - first) / window.slotSize)))
  }
  property var menuItem: null
  property Item menuSlot: null
  // The apps button's menu: where the dock sits, the layout, and when the dock
  // is out. Each opens its choices in a submenu beside it, on hover as a menu
  // bar's do, or on a click.
  property bool settingsMenu: false
  property string openSubmenu: ""
  // Whether the submenu opens on the near side of the menu, for the rows'
  // marks to point that way.
  readonly property bool submenuBefore: submenu.x < menu.x
  property string pendingSubmenu: ""

  // The first submenu opens as the pointer arrives. With one open, the way to
  // its choices can cross another row, so a row has to hold the pointer a
  // moment before it takes over; one only passed over changes nothing.
  function hoverSubmenu(name) {
    if (name === window.openSubmenu) {
      submenuTimer.stop()
    } else if (window.openSubmenu === "") {
      window.openSubmenu = name
    } else {
      window.pendingSubmenu = name
      submenuTimer.restart()
    }
  }

  Timer {
    id: submenuTimer
    interval: 200
    onTriggered: {
      var row = window.pendingSubmenu === "position" ? positionRow : window.pendingSubmenu === "layout" ? layoutRow : visibilityRow
      if (row.hovered) window.openSubmenu = window.pendingSubmenu
    }
  }

  onWorkspaceIdChanged: if (dock) dock.readMode(workspaceId)
  onShownChanged: {
    if (shown) return
    closeMenu()
    endMove()
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
    window.openSubmenu = ""
    window.settingsMenu = true
    window.menuSlot = slot
  }

  // The layout picked here goes to the workspace the dock is on and becomes
  // the default every workspace uses, as under Appearance > Workspace Layout.
  // Other workspaces with windows on them keep the layout they have. The
  // layout commands act on the focused workspace, so a choice on another
  // screen's dock focuses that screen first. The default is saved only when
  // it changes, as saving it reloads Hyprland, and not at all for a workspace
  // that cannot take a layout, such as a named one.
  function setLayout(mode) {
    var command = "omarchy-hyprland-workspace-layout-toggle " + mode
      + " && if [[ $(omarchy-hyprland-workspace-layout-default) != \"" + mode + "\" ]]; then omarchy-hyprland-workspace-layout-default " + mode + "; fi"
    if (window.monitor && !window.monitor.focused)
      command = "hyprctl dispatch " + Util.shellQuote("hl.dsp.focus({ monitor = \"" + window.monitor.name + "\" })") + " >/dev/null && { " + command + "; }"
    Util.execDetached(command)
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
    submenuTimer.stop()
    window.openSubmenu = ""
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

  // A submenu sits beside the menu, away from the dock, with its first row
  // level with the row that opened it, as far as the room inward of the dock
  // allows. It overlaps the menu by a border, as macOS's do, so the two share
  // one edge rather than standing a sliver apart.
  function submenuX(popup) {
    var after = menu.x + menu.width - Style.normalBorderWidth
    var before = menu.x - popup.width + Style.normalBorderWidth
    if (window.position === "left") return after
    if (window.position === "right") return before
    if (Commons.I18n.rightToLeft) return before >= window.gap ? before : after
    return after + popup.width <= window.width - window.gap ? after : before
  }

  function submenuY(row, popup) {
    if (!row) return 0
    var top = menu.y + menuColumn.y + row.y - popup.contentTopInset
    var low = window.position === "top" ? body.y + body.height + window.gap : window.gap
    var high = window.position === "bottom" ? body.y - window.gap - popup.height : window.height - popup.height - window.gap
    return Math.max(low, Math.min(high, top))
  }

  function popupY(slot, popup) {
    if (!slot) return 0
    var center = slot.mapToItem(window.contentItem, 0, slot.height / 2).y
    if (window.position === "top") return body.y + body.height + window.gap
    if (window.position === "bottom") return body.y - window.gap - popup.height
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

  implicitWidth: window.vertical ? window.gap + window.slotSize + window.popupRoom + window.submenuRoom : 0
  implicitHeight: window.vertical ? 0 : window.gap + window.slotSize + window.popupRoom

  mask: Region {
    item: window.contentShown ? body : null

    Region { item: window.shown && window.autohide ? edgeTrigger : null }
    Region { item: menu.visible ? menu : null }
    Region { item: submenu.visible ? submenu : null }
  }

  onAutohideChanged: window.revealed = false

  Timer {
    id: hideTimer
    // Long enough to cross a gap between the edge and the icons, no longer.
    interval: 150
    onTriggered: {
      if (!bodyHover.hovered && !edgeHover.hovered && !window.menuOpen && !window.dragging && !window.movingDock && !window.holdOpen) window.revealed = false
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

  // The dock slides out over windows, where bare icons land on their content
  // and borders. A mist of the theme's background stands behind them, easing
  // out to nothing just past the icons and toward both ends, with no outline.
  // It does only what is needed: over windows it is close to solid through
  // the icons, so nothing beneath tangles with them; over the wallpaper, where
  // that would be a slab, it is a shade at half strength. Which one comes from
  // what the dock already knows, so it costs nothing to decide. It stays put
  // and clears as the dock tucks away.
  Canvas {
    id: mist

    // How far past the dock's ends it runs and how far inward. It dissolves
    // toward each end over a longer stretch than it overruns, starting under
    // the last icons, so it ends softly without standing clear of the stack.
    readonly property real reach: window.slotSize * 0.75
    readonly property real dissolve: window.slotSize * 1.75
    readonly property real depth: window.gap + window.slotSize * 1.9
    // The share of the depth, from the screen edge, the icons stand in.
    readonly property real ground: (window.gap + window.slotSize * 0.8) / depth
    readonly property bool dense: window.overWindows
    property color tint: Commons.Color.background

    visible: window.shown && opacity > 0
    opacity: 1 - body.tuck / (window.slotSize + window.gap)
    x: window.vertical ? (window.position === "left" ? 0 : window.width - width) : body.x - reach
    y: window.vertical ? body.y - reach : (window.position === "top" ? 0 : window.height - height)
    width: window.vertical ? depth : body.width + reach * 2
    height: window.vertical ? body.height + reach * 2 : depth

    renderStrategy: Canvas.Cooperative
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
    onTintChanged: requestPaint()
    onDenseChanged: requestPaint()
    onVisibleChanged: if (visible) requestPaint()
    Connections {
      target: window
      function onPositionChanged() { mist.requestPaint() }
    }

    // One gradient across the depth, then both ends dissolved out of it, each
    // along an eased curve in many stops: a few straight segments would show
    // as bands, and strips painted side by side as stripes.
    onPaint: {
      var ctx = getContext("2d")
      if (!ctx || width <= 0 || height <= 0) return
      ctx.reset()
      var rgb = "rgba(" + Math.round(mist.tint.r * 255) + "," + Math.round(mist.tint.g * 255) + "," + Math.round(mist.tint.b * 255) + ","
      function ease(t) {
        t = Math.max(0, Math.min(1, t))
        return t * t * t * (t * (t * 6 - 15) + 10)
      }
      var stops = 24
      var near = window.position === "left" || window.position === "top"

      var across = window.vertical
        ? ctx.createLinearGradient(near ? 0 : width, 0, near ? width : 0, 0)
        : ctx.createLinearGradient(0, near ? 0 : height, 0, near ? height : 0)
      for (var i = 0; i <= stops; i++) {
        var t = i / stops
        var cover = mist.dense ? 0.9 * (1 - ease((t - mist.ground) / (1 - mist.ground))) : 0.5 * (1 - ease(t))
        across.addColorStop(t, rgb + cover.toFixed(4) + ")")
      }
      ctx.fillStyle = across
      ctx.fillRect(0, 0, width, height)

      ctx.globalCompositeOperation = "destination-out"
      var length = window.vertical ? height : width
      for (var side = 0; side < 2; side++) {
        var from = side === 0 ? 0 : length
        var to = side === 0 ? mist.dissolve : length - mist.dissolve
        var fade = window.vertical ? ctx.createLinearGradient(0, from, 0, to) : ctx.createLinearGradient(from, 0, to, 0)
        for (var j = 0; j <= stops; j++) {
          var u = j / stops
          fade.addColorStop(u, "rgba(0,0,0," + (1 - ease(u)).toFixed(4) + ")")
        }
        ctx.fillStyle = fade
        var low = Math.min(from, to)
        if (window.vertical) ctx.fillRect(0, low, width, mist.dissolve)
        else ctx.fillRect(low, 0, mist.dissolve, height)
      }
    }
  }

  Item {
    id: body

    // Dimmed while the dock is being dragged to another edge.
    opacity: window.movingDock ? 0.45 : 1
    Behavior on opacity { NumberAnimation { duration: Style.duration(120); easing.type: Easing.OutCubic } }

    // The strip keeps its order in every language, like the bar: drags and
    // drops reckon slots along x from the first app. Only the menu mirrors.
    LayoutMirroring.enabled: false
    LayoutMirroring.childrenInherit: true

    width: slots.implicitWidth
    height: slots.implicitHeight
    // How far the dock is tucked past its edge. Auto-hide slides it, but only
    // while the dock is on screen: a dock that was not shown appears where it
    // belongs at once. Between a tiled workspace and a floating one with the
    // dock always out, it is on screen throughout, so it slides.
    property real tuck: window.tucked ? window.slotSize + window.gap : 0

    // Tucking away is quicker than coming back, though not so quick that the
    // dock seems to vanish rather than slide off. A gentler curve than
    // Style.easeOut, which crosses the short slide in a frame or two.
    Behavior on tuck {
      id: tuckMotion
      enabled: window.shown
      NumberAnimation {
        duration: Style.duration(tuckMotion.targetValue > 0 ? 156 : 180)
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
      anchors.centerIn: parent
      columns: window.vertical ? 1 : appRepeater.count + 1

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
    property point pressPoint
    property bool dragged: false

    mouse.cursorShape: window.movingDock ? Qt.ClosedHandCursor : Qt.PointingHandCursor

    // Where the pointer is on the screen, which the dock's edge is chosen by.
    function screenPoint(event) {
      var at = window.origin()
      var point = appsSlot.mapToItem(window.contentItem, event.x, event.y)
      return Qt.point(at.x + point.x, at.y + point.y)
    }

    // Only the left button drags; another pressed meanwhile is no part of it.
    // A drag dropped away from the button is followed by no click to clear
    // its mark, so any press outside a drag starts clean.
    mouse.onPressed: function(event) {
      if (!window.movingDock) appsSlot.dragged = false
      if (event.button === Qt.LeftButton) appsSlot.pressPoint = Qt.point(event.x, event.y)
    }

    // Past a short way from where it was pressed, the press is a move of the
    // whole dock rather than a click. From then on the dock dims and an
    // outline shows the edge it would land on.
    mouse.onPositionChanged: function(event) {
      if (!(appsSlot.mouse.pressedButtons & Qt.LeftButton)) return
      if (!window.movingDock) {
        if (Math.hypot(event.x - appsSlot.pressPoint.x, event.y - appsSlot.pressPoint.y) < Style.space(6)) return
        window.closeMenu()
        appsSlot.dragged = true
        window.movingDock = true
      }
      window.trackMove(appsSlot.screenPoint(event))
    }

    mouse.onReleased: function(event) {
      if (!window.movingDock || event.button !== Qt.LeftButton) return
      window.trackMove(appsSlot.screenPoint(event))
      var edge = window.dock ? window.dock.moveEdge : ""
      window.endMove()
      if (edge && edge !== window.position) window.moveTo(edge)
      else if (window.autohide) hideTimer.restart()
    }

    mouse.onCanceled: {
      window.endMove()
      if (window.autohide) hideTimer.restart()
    }

    Behavior on displayedShift {
      enabled: window.animateShifts
      NumberAnimation { duration: Style.duration(150); easing.type: Easing.Bezier; easing.bezierCurve: Style.easeOut }
    }

    transform: Translate {
      x: window.vertical ? 0 : appsSlot.displayedShift
      y: window.vertical ? appsSlot.displayedShift : 0
    }

    mouse.onClicked: function(event) {
      // A drag ends in a release over the button, which is not a click on it.
      if (appsSlot.dragged) {
        appsSlot.dragged = false
        return
      }
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
      if (event.button === Qt.MiddleButton) window.dock.launch(appSlot.modelData)
      else window.dock.activate(appSlot.modelData)
    }

    // Apps are drawn in full, running or not, and one that is starting pulses.
    AppIcon {
      x: window.iconInset
      y: window.iconInset
      width: window.iconSize
      height: window.iconSize
      source: window.dock && appSlot.modelData ? window.dock.iconFor(appSlot.modelData) : ""
      opacity: appSlot.launching ? appSlot.pulse : 1
      transform: Translate {
        x: window.vertical ? 0 : appSlot.displayedShift
        y: window.vertical ? appSlot.displayedShift : 0
      }
      scale: appSlot.lifted || appSlot.hovered ? 1.15 : 1
      transformOrigin: window.popOrigin

      Behavior on scale { NumberAnimation { duration: Style.duration(120); easing.type: Easing.OutCubic } }
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
    id: menu

    readonly property var item: window.menuItem
    readonly property bool hasEntry: !!item && !!window.dock && !!window.dock.entryFor(item)
    readonly property bool running: !!item && item.windows.length > 0

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

      PopupMenuRow {
        id: positionRow
        visible: window.settingsMenu
        text: Commons.I18n.t("dock.position")
        submenu: true
        submenuBefore: window.submenuBefore
        highlighted: window.openSubmenu === "position"
        onHoveredChanged: if (hovered) window.hoverSubmenu("position")
        onTriggered: window.openSubmenu = "position"
      }

      PopupMenuRow {
        id: layoutRow
        visible: window.settingsMenu
        text: Commons.I18n.t("dock.layout")
        submenu: true
        submenuBefore: window.submenuBefore
        highlighted: window.openSubmenu === "layout"
        onHoveredChanged: if (hovered) window.hoverSubmenu("layout")
        onTriggered: window.openSubmenu = "layout"
      }

      PopupMenuRow {
        id: visibilityRow
        visible: window.settingsMenu
        text: Commons.I18n.t("dock.visibility")
        submenu: true
        submenuBefore: window.submenuBefore
        highlighted: window.openSubmenu === "visibility"
        onHoveredChanged: if (hovered) window.hoverSubmenu("visibility")
        onTriggered: window.openSubmenu = "visibility"
      }

      PopupMenuRow {
        visible: menu.hasEntry && menu.running
        text: Commons.I18n.t("dock.newWindow")
        onTriggered: {
          window.dock.launch(menu.item)
          window.closeMenu()
        }
      }

      PopupMenuRow {
        visible: menu.hasEntry
        text: menu.item && menu.item.pinned ? Commons.I18n.t("dock.removeFromDock") : Commons.I18n.t("dock.keepInDock")
        onTriggered: {
          window.dock.setPinned(menu.item.key, !menu.item.pinned)
          window.closeMenu()
        }
      }

      PopupMenuRow {
        visible: menu.running
        text: Commons.I18n.t("dock.quit")
        onTriggered: {
          window.dock.quit(menu.item)
          window.closeMenu()
        }
      }
    }
  }

  BorderSurface {
    id: submenu

    // Wide enough for its longest choice with its tick, which a translation
    // can make longer than any in English: of the choices showing, or of every
    // submenu's.
    function widestOf(showing) {
      var width = 0
      for (var i = 0; i < submenuColumn.children.length; i++) {
        var choice = submenuColumn.children[i]
        if ((choice.visible || !showing) && choice.contentWidth > width) width = choice.contentWidth
      }
      return width
    }
    readonly property Item row: window.openSubmenu === "position" ? positionRow
      : window.openSubmenu === "layout" ? layoutRow
      : window.openSubmenu === "visibility" ? visibilityRow
      : null

    visible: menu.visible && window.settingsMenu && !!row
    width: Math.max(Style.space(140), Math.ceil(widestOf(true))) + padding * 2
    height: submenuColumn.implicitHeight + padding * 2
    x: window.submenuX(submenu)
    y: window.submenuY(row, submenu)
    radius: Style.cornerRadius
    color: Commons.Color.popups.background
    borderSpec: Border.surfaceSpec("popups", "border", Commons.Color.popups.border, Style.normalBorderWidth)
    padding: Style.spacing.sm

    Column {
      id: submenuColumn
      x: submenu.contentLeftInset
      y: submenu.contentTopInset
      width: submenu.width - submenu.contentLeftInset - submenu.contentRightInset

      Repeater {
        model: [["top", Commons.I18n.t("dock.positionTop")], ["bottom", Commons.I18n.t("dock.positionBottom")], ["left", Commons.I18n.t("dock.positionLeft")], ["right", Commons.I18n.t("dock.positionRight")]]

        // Each row acts, then closes the menu: the actions read its item.
        delegate: PopupMenuRow {
          required property var modelData

          // The bar's edge is no place for the dock, so it isn't offered.
          visible: window.openSubmenu === "position" && modelData[0] !== window.barEdge
          text: modelData[1]
          checked: window.position === modelData[0]
          onTriggered: {
            if (modelData[0] !== window.position) window.moveTo(modelData[0])
            window.closeMenu()
          }
        }
      }

      Repeater {
        model: [["dwindle", Commons.I18n.t("dock.layoutTiling")], ["scrolling", Commons.I18n.t("dock.layoutScrolling")], ["floating", Commons.I18n.t("dock.layoutFloating")]]

        delegate: PopupMenuRow {
          required property var modelData

          visible: window.openSubmenu === "layout"
          text: modelData[1]
          // The layout of the workspace being looked at, which picking one
          // switches along with the default.
          checked: !!window.dock && (window.dock.modes[window.workspaceId] || "dwindle") === modelData[0]
          onTriggered: {
            window.setLayout(modelData[0])
            window.closeMenu()
          }
        }
      }

      Repeater {
        model: [["always", Commons.I18n.t("dock.visibilityAlways")], ["first-app", Commons.I18n.t("dock.visibilityFirstApp")], ["hidden", Commons.I18n.t("dock.visibilityHidden")]]

        delegate: PopupMenuRow {
          required property var modelData

          visible: window.openSubmenu === "visibility"
          text: modelData[1]
          checked: !!window.dock && window.dock.visibility === modelData[0]
          onTriggered: {
            Util.execDetached("omarchy-dock visibility " + modelData[0])
            window.closeMenu()
          }
        }
      }
    }
  }
}
