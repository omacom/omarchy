import QtQuick
import QtQuick.Controls as Controls
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Commons as Commons

// Layer-shell popup attached to a bar widget icon, designed for
// click-driven AND keyboard-driven panels (e.g. SUPER+CTRL+W summon).
//
// Built on PanelWindow with a brief WlrKeyboardFocus.Exclusive prime followed
// by OnDemand rather than PopupWindow (xdg-popup). The prime acquires focus
// both when the surface maps and when it reopens while still mapped for its
// fade-out. xdg-popups don't get that — they only receive keys after a
// click/hover routes focus through their parent surface — so keyboard-summoned
// popups fell flat without it.
//
// Exclusive would also grant map-time focus, but it makes Hyprland route
// *every* pointer event to the exclusive surface no matter which output
// the cursor is over, which leaves clicks on any other monitor unable to
// reach the dismissal surfaces below.
//
// API is a subset of Common.PopupCard: anchorItem, owner, bar, open,
// padding, margin, contentWidth/Height, centerOnBar, default contentItem.
// Missing on purpose (for now): triggerMode ("hover"), containsMouse.
//
// Positioning: full-screen layer-shell with the card placed inside at
// `cardOrigin`. We use the bar strip's thickness for the perpendicular
// axis (away-from-bar) because mapToItem on the anchor returns
// bar-content-relative coords with internal layout offsets baked in
// (e.g. ~13px from the bar's vertical centering of its widget row). The
// parallel axis (along-the-bar) uses the anchor's content x/y since the
// bar window spans the full screen on that axis.
//
// Outside-click dismissal: an overlay MouseArea catches clicks, with the
// QsWindow.mask subtracting the bar strip so clicks on the bar still
// reach the bar widgets (activePopout coordinator hands off to another
// popup if the user clicks a different bar icon).
//
// ExclusionMode.Auto (not Ignore): Ignore stretches the overlay over other
// surfaces' exclusive zones, so a layer-shell on-screen keyboard at the
// bottom is covered by dismissArea. The first OSK tap then closes the
// panel (wifi passphrase, bluetooth PIN, …) instead of typing. Auto keeps
// the reserved OSK/bar bands clickable. Keyboard focus still primes
// Exclusive then settles on OnDemand so Hyprland does not keep routing
// every pointer event here.
PanelWindow {
  id: root

  required property Item anchorItem
  required property QtObject bar
  property var owner: null
  property int margin: Style.gapsOut
  property int padding: Style.spacing.popupPadding
  property int contentWidth: Style.space(280)
  property int contentHeight: Style.space(200)
  // Panels with an existing full-card ScrollView/Flickable must keep their
  // constrained viewport so their keyboard cursor can scroll it normally.
  property bool scrollOverflow: false
  property Item scrollCursorItem: null
  function ensureItemVisible(item) {
    scrollCursorItem = item
    contentViewport.revealItem(item)
  }

  // The card's height on screen. Content that arrives after the panel is up
  // (a Wi-Fi scan, Bluetooth devices turning up) grows the card toward it
  // rather than snapping it taller, cropping the new rows as it goes. Just
  // after opening it snaps, while freshly built content first measures itself.
  property real drawnHeight: contentHeight
  property bool heightLive: false
  Behavior on drawnHeight {
    enabled: root.heightLive && root.morph >= 1
    NumberAnimation {
      duration: Style.duration(200)
      easing.type: Easing.Bezier
      easing.bezierCurve: Style.easeOut
    }
  }

  Timer {
    id: heightSettle
    interval: 60
    onTriggered: root.heightLive = root.open
  }
  property var borderSpec: Border.surfaceSpec("popups", "border", Commons.Color.popups.border, Math.max(1, Style.space(2)))
  property bool centerOnBar: false
  property bool open: false
  property int gap: Style.gapsOut  // distance between bar edge and panel
  property bool popoutSwitching: false
  property bool popoutSwitchClosing: false
  property bool focusPrimed: false

  // Item that should take keyboard focus once the panel maps. Typically a
  // PanelKeyCatcher inside the panel content. Layer-shell grants focus to the
  // surface during the Exclusive prime, but Qt still needs an active-focus
  // target inside the surface for Keys.onPressed handlers to fire. Schedule
  // the focus through Qt.callLater so it runs after the surface is fully
  // mapped and child items have completed layout.
  property Item focusTarget: null

  default property alias contentItem: contentHolder.children

  // Lazy content. A panel that sets `content` to a Component gets it built
  // the first time the panel opens instead of at shell startup, which is
  // where most of a bar's memory and load time went: every panel's tree was
  // built on every monitor whether or not it was ever opened. The content
  // stays loaded after that first open, so reopening is instant and any
  // state the content holds (scroll position, an edit in progress) survives
  // a close. Root-level panel code reaches into it through `loadedContent`,
  // which is null until then, so anything that must run while the panel is
  // closed (timers, data, IPC) belongs outside the content. Panels that
  // declare children directly keep the old eager behaviour.
  property Component content: null
  property bool contentRequested: false
  readonly property Item loadedContent: contentLoader.item
  readonly property real loadedContentHeight: contentLoader.item ? contentLoader.item.implicitHeight : 0

  // Build the content without opening the panel, for callers that need to
  // reach it first.
  function ensureContent() {
    if (content) contentRequested = true
    return contentLoader.item
  }

  readonly property var coordinatorKey: owner || root
  readonly property var anchorWindow: anchorItem ? anchorItem.QsWindow.window : null
  readonly property string barPos: bar ? bar.position : "top"

  function close() {
    if (owner && "close" in owner) owner.close()
    else root.open = false
  }

  function beginFocusPrime() {
    if (open && backingWindowVisible) focusPrimeTimer.restart()
  }

  // --- screen + lifetime ---------------------------------------------------

  screen: anchorWindow ? anchorWindow.screen : null
  visible: open || card.opacity > 0 || popoutSwitching
  color: "transparent"
  exclusionMode: ExclusionMode.Auto

  WlrLayershell.namespace: "omarchy-keyboard-panel"
  WlrLayershell.layer: WlrLayer.Overlay
  // Keyboard focus follows `open` (NOT `visible`). The window remains
  // mapped during the fade-out so the opacity animation has something to
  // animate, but keyboard/click ownership must release the moment the
  // logical close fires — otherwise the user is locked out until it ends.
  //
  // Prime with Exclusive on every open, then settle on OnDemand. Hyprland
  // focuses OnDemand when a surface first maps, but not when an already-mapped
  // fade-out surface changes from None back to OnDemand. Exclusive also takes
  // focus when the previously focused application has constrained the pointer.
  // The brief prime covers both cases; OnDemand then releases compositor-wide
  // pointer hit-testing so clicks can reach the dismissal windows below.
  WlrLayershell.keyboardFocus: open
    ? (focusPrimed ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.Exclusive)
    : WlrKeyboardFocus.None

  onBackingWindowVisibleChanged: beginFocusPrime()

  // Full-screen layer-shell. The visible card is positioned inside via
  // `cardOrigin`. The `mask` below makes the bar area click-through (so
  // the user can click another bar icon while the panel is open and the
  // activePopout coordinator swaps to that popup); everywhere else, the
  // overlay catches the click and dismisses via the MouseArea below.
  anchors {
    top: true
    bottom: true
    left: true
    right: true
  }

  // Clickable region is the whole screen. Clicks in the bar strip are
  // forwarded to registered bar buttons so switching between panel icons
  // works in one click even when the overlay surface is above the bar.
  readonly property real _barStripSize: bar ? barThickness + gap : 0
  mask: Region {
    width: root.screenW
    height: root.screenH
  }

  // Track every layout change between the bar's contentItem and the
  // anchor item. `transform` updates whenever any item in that chain
  // moves/resizes, which is what makes the position binding below
  // actually reactive — mapToItem on its own is a one-shot.
  TransformWatcher {
    id: anchorWatcher
    a: anchorWindow ? anchorWindow.contentItem : null
    b: anchorItem
  }

  // Anchor item's position within the bar's content surface. For a
  // full-width top bar, the content x maps directly to screen x; the y
  // returned here has the bar's internal padding baked in (e.g. ~13px
  // from vertical centering of the widget row), which is why `cardOrigin`
  // below uses `barThickness` for the perpendicular axis instead of this y.
  readonly property point anchorScreenPos: {
    anchorWatcher.transform  // reactive dependency
    if (!anchorItem || !anchorWindow) return Qt.point(0, 0)
    return anchorItem.mapToItem(anchorWindow.contentItem, 0, 0)
  }
  readonly property real anchorW: anchorItem ? anchorItem.width : 0
  readonly property real anchorH: anchorItem ? anchorItem.height : 0
  readonly property real screenW: screen ? screen.width : 0
  readonly property real screenH: screen ? screen.height : 0
  // Whether the overlay surface is inset around reserved bands (Auto mode
  // mapped while the bar or an OSK holds an exclusive zone) or still covers
  // the full screen (Ignore mode, Auto before the first map, or Auto with
  // nothing reserved, e.g. a hidden bar). Width/height report 100x100 before
  // the first map, so only trust them once the backing window is visible.
  readonly property bool insetOverlay: backingWindowVisible
    && (Math.abs(width - screenW) > 1 || Math.abs(height - screenH) > 1)
  // Screen-space origin of this surface. A PanelWindow root exposes no x/y
  // position (reading them yields undefined and poisons the card origin to
  // NaN, parking every panel at the top-left), so derive it from the bar edge
  // the inset surface starts after instead: a top/left bar pushes the surface
  // past its edge, while bottom/right bars and fullscreen windows start at
  // the output origin. A hidden bar reserves nothing, so an OSK alone insets
  // only the far edge.
  readonly property bool barReserved: insetOverlay && !(bar && bar.barHidden)
  readonly property real originX: (barPos === "left" && barReserved) ? barThickness : 0
  readonly property real originY: (barPos === "top" && barReserved) ? barThickness : 0
  // ExclusionMode.Auto with all four anchors sets exclusiveZone 0: the
  // compositor insets this overlay around the bar/OSK reserved bands.
  // Prefer the surface size once mapped so a tall panel cannot extend
  // into those bands; fall back to screen size while fullscreen.
  readonly property real availableCardWidth: {
    var surface = root.insetOverlay ? width : screenW
    if (surface <= 0) return 0
    // An inset surface already excludes the bar band; a fullscreen window
    // still spans it, so keep the bar out of the card budget there.
    var barReserve = (barPos === "left" || barPos === "right") && !root.insetOverlay ? barThickness + gap : 0
    return Math.max(120, surface - barReserve - margin * 2)
  }
  readonly property real availableCardHeight: {
    var surface = root.insetOverlay ? height : screenH
    if (surface <= 0) return 0
    var barReserve = (barPos === "top" || barPos === "bottom") && !root.insetOverlay ? barThickness + gap : 0
    return Math.max(120, surface - barReserve - margin * 2)
  }
  readonly property real verticalContentInset: padding * 2 + Border.top(borderSpec) + Border.bottom(borderSpec)

  function fittedContentWidth(width, cap) {
    var desired = Math.max(1, Number(width) || 1)
    var maxWidth = root.availableCardWidth > 0 ? root.availableCardWidth : desired
    if (cap !== undefined && Number(cap) > 0) maxWidth = Math.min(maxWidth, Number(cap))
    return Math.round(Math.min(desired, maxWidth))
  }

  function fittedContentHeight(implicitHeight, cap) {
    var desired = Math.max(root.verticalContentInset, (Number(implicitHeight) || 0) + root.verticalContentInset)
    var maxHeight = root.availableCardHeight > 0 ? root.availableCardHeight : desired
    if (cap !== undefined && Number(cap) > 0) maxHeight = Math.min(maxHeight, Number(cap))
    return Math.round(Math.min(desired, maxHeight))
  }

  function cappedContentHeight(height) {
    var desired = Math.max(root.padding * 2, Number(height) || root.padding * 2)
    var maxHeight = root.availableCardHeight > 0 ? root.availableCardHeight : desired
    return Math.round(Math.min(desired, maxHeight))
  }

  // Desired top-left of the card in screen coordinates. For the
  // perpendicular axis (away-from-bar) we anchor to the bar strip's edge
  // directly — not the anchor item's y/x — because mapToItem(barContent)
  // returns coordinates in the bar's content space, which can be offset
  // from the strip's screen-anchored corner by internal layout (centering
  // wrappers, padding). The bar window spans its whole screen, so its
  // dimensions say nothing about the strip; the painted strip hugs the
  // bar's anchored screen edge at the bar's thickness for this screen
  // (notch floor included), so `barThickness` gives the strip's inner edge
  // regardless of how the bar's internal widgets are positioned. For the
  // parallel axis (along the bar) the anchor item's reported position is
  // still consistent with the bar content origin, so it's accurate for
  // centering the card under the icon.
  readonly property real barThickness: !bar ? 0
    : (typeof bar.barSizeFor === "function" && screen ? bar.barSizeFor(screen.name) : bar.barSize)
  // Bar window dimensions, only for mapping overlay coordinates into
  // bar-window content coordinates in barPoint() below.
  readonly property real barW: anchorWindow ? anchorWindow.width : screenW
  readonly property real barH: anchorWindow ? anchorWindow.height : 0
  readonly property point cardOrigin: {
    if (!anchorItem || !bar) return Qt.point(margin, margin)
    var x = 0, y = 0
    if (centerOnBar && (barPos === "top" || barPos === "bottom")) {
      x = screenW / 2 - contentWidth / 2
      y = barPos === "bottom" ? screenH - barThickness - drawnHeight - gap : barThickness + gap
    } else if (centerOnBar) {
      x = barPos === "left" ? barThickness + gap : screenW - barThickness - contentWidth - gap
      y = screenH / 2 - drawnHeight / 2
    } else if (barPos === "bottom") {
      x = anchorScreenPos.x + anchorW / 2 - contentWidth / 2
      y = screenH - barThickness - drawnHeight - gap
    } else if (barPos === "left") {
      x = barThickness + gap
      y = anchorScreenPos.y + anchorH / 2 - drawnHeight / 2
    } else if (barPos === "right") {
      x = screenW - barThickness - contentWidth - gap
      y = anchorScreenPos.y + anchorH / 2 - drawnHeight / 2
    } else { // "top" (default)
      x = anchorScreenPos.x + anchorW / 2 - contentWidth / 2
      y = barThickness + gap
    }
    x = Math.max(margin, Math.min(x, screenW - contentWidth - margin))
    y = Math.max(margin, Math.min(y, screenH - drawnHeight - margin))
    // Screen-space origin is relative to the output. The inset Auto surface
    // starts past the bar edge (see originX/originY); a fullscreen window
    // shares the output origin so the translation is a no-op there.
    var localX = x - root.originX
    var localY = y - root.originY
    var surfaceW = root.insetOverlay ? width : screenW
    var surfaceH = root.insetOverlay ? height : screenH
    localX = Math.max(margin, Math.min(localX, surfaceW - contentWidth - margin))
    localY = Math.max(margin, Math.min(localY, surfaceH - drawnHeight - margin))
    return Qt.point(Math.round(localX), Math.round(localY))
  }

  // Where the card grows from, in its own coordinates: the point on its
  // bar-facing edge nearest the icon it hangs from.
  readonly property point growOrigin: {
    var x = Math.max(0, Math.min(anchorScreenPos.x + anchorW / 2 - cardOrigin.x, contentWidth))
    var y = Math.max(0, Math.min(anchorScreenPos.y + anchorH / 2 - cardOrigin.y, drawnHeight))
    if (barPos === "bottom") return Qt.point(x, drawnHeight)
    if (barPos === "left") return Qt.point(0, y)
    if (barPos === "right") return Qt.point(contentWidth, y)
    return Qt.point(x, 0)
  }


  // --- popout coordination (same-bar single-popout model) -----------------

  // Coordinate on `open`, not `visible`. `visible` lags into the fade-out
  // animation, which made ownership transfer to a sibling popup race.
  onOpenChanged: {
    heightLive = false
    if (open) {
      heightSettle.restart()
      if (content) contentRequested = true
      focusPrimed = false
      beginFocusPrime()
      if (focusTarget) Qt.callLater(function() {
        if (root.open && root.focusTarget) root.focusTarget.forceActiveFocus()
      })
    } else {
      focusPrimeTimer.stop()
      focusPrimed = false
    }
    if (!bar) return
    if (open) {
      popoutSwitchClosing = false
      popoutSwitching = bar.activePopout && bar.activePopout !== coordinatorKey
      if (popoutSwitching) morphFromLastCard()
      bar.requestPopout(coordinatorKey)
      publishCard()
      if (popoutSwitching) popoutSwitchTimer.restart()
    } else {
      popoutSwitchClosing = !!(owner && owner.popoutSwitchClosing)
      popoutSwitching = false
      if (bar.activePopout === coordinatorKey) bar.releasePopout(coordinatorKey)
      if (popoutSwitchClosing) closeSwitchTimer.restart()
    }
  }

  Timer {
    id: focusPrimeTimer
    // Leave enough time for multiple Qt/Wayland commit cycles after the
    // backing window becomes visible while keeping the compositor-wide
    // Exclusive phase imperceptibly short. This interval is covered by the
    // immediate hide/re-summon acceptance case.
    interval: 75
    onTriggered: if (root.open) root.focusPrimed = true
  }

  Timer {
    id: popoutSwitchTimer
    // Outlasts the morph, so the card stays shown until it has landed.
    interval: 250
    onTriggered: root.popoutSwitching = false
  }

  // --- switching between panels --------------------------------------------

  // One card, not two: a panel taking over from another in the same section of
  // the bar starts its card where the last one stood, at its size, and morphs
  // it into its own place while the new content fades in. Each panel tells the
  // bar where its card is, at the height it's drawn, so a switch while it's
  // still growing starts from what's on screen. Across sections the new panel
  // opens fresh.
  readonly property rect cardTarget: Qt.rect(cardOrigin.x, cardOrigin.y, contentWidth, drawnHeight)
  onCardTargetChanged: publishCard()

  function publishCard() {
    if (!open || !bar || !screen || typeof bar.notePopoutCard !== "function") return
    bar.notePopoutCard({ screen: screen.name, x: cardTarget.x, y: cardTarget.y,
                         width: cardTarget.width, height: cardTarget.height })
  }

  // Already true as `open` flips, before onOpenChanged marks the switch, so
  // the card never starts growing in on top of the morph. Only a takeover in
  // the same section morphs; across sections the card grows in as usual.
  readonly property bool takingOver: !!bar && !!bar.activePopout && bar.activePopout !== coordinatorKey
    && typeof bar.popoutCardFor === "function" && !!bar.popoutCardFor(coordinatorKey)

  property rect morphFrom: Qt.rect(0, 0, 0, 0)
  property real morph: 1

  function morphFromLastCard() {
    var last = bar && typeof bar.popoutCardFor === "function" ? bar.popoutCardFor(coordinatorKey) : null
    if (!last || !screen || last.screen !== screen.name) return
    morphFrom = Qt.rect(last.x, last.y, last.width, last.height)
    morphRun.restart()
  }

  NumberAnimation {
    id: morphRun
    target: root; property: "morph"; from: 0; to: 1
    duration: Style.duration(220)
    easing.type: Easing.Bezier
    easing.bezierCurve: Style.easeOut
  }

  function morphed(from, to) {
    return morph >= 1 ? to : from + (to - from) * morph
  }

  Timer {
    id: closeSwitchTimer
    interval: 1
    onTriggered: root.popoutSwitchClosing = false
  }

  // --- outside-click dismissal --------------------------------------------

  // Catches clicks anywhere in the clickable region (i.e. everywhere on
  // screen except the bar strip, which is masked out). The card has its
  // own MouseArea below so clicks on it don't bubble up here. Disabled
  // during the fade-out so the dying overlay doesn't swallow clicks that
  // were meant for the apps behind it.
  MouseArea {
    id: dismissArea
    anchors.fill: parent
    enabled: root.open
    acceptedButtons: Qt.AllButtons
    hoverEnabled: true
    property bool hoveringBar: false
    cursorShape: hoveringBar ? Qt.PointingHandCursor : Qt.ArrowCursor

    // Mouse coordinates are window-local. The inset overlay starts past the
    // bar edge (see originX/originY), so translate to screen coordinates
    // before testing against screen-space bar geometry; a fullscreen window
    // shares the output origin and the translation is a no-op there.
    function inBarRegion(px, py) {
      var sy = py + root.originY
      var sx = px + root.originX
      if (root.barPos === "bottom") return sy >= root.screenH - root._barStripSize
      if (root.barPos === "left") return sx <= root._barStripSize
      if (root.barPos === "right") return sx >= root.screenW - root._barStripSize
      return sy <= root._barStripSize
    }

    function barPoint(px, py) {
      var sx = px + root.originX
      var sy = py + root.originY
      if (root.barPos === "bottom") return Qt.point(sx, sy - (root.screenH - root.barH))
      if (root.barPos === "right") return Qt.point(sx - (root.screenW - root.barW), sy)
      return Qt.point(sx, sy)
    }

    function pressTargetAt(px, py) {
      if (!root.anchorWindow || !root.anchorWindow.contentItem || !root.bar || !root.bar.clickTargets) return null
      var p = barPoint(px, py)
      var targets = root.bar.clickTargets
      for (var i = targets.length - 1; i >= 0; i--) {
        var target = targets[i]
        if (!target || !target.triggerPress || target.visible === false || target.opacity === 0 || !target.mapToItem) continue
        if (root.bar.targetBelongsToWindow && !root.bar.targetBelongsToWindow(target, root.anchorWindow)) continue
        if (Util.itemContainsPoint(target, root.anchorWindow.contentItem, p.x, p.y)) return target
      }
      return null
    }

    function forwardBarClick(px, py, button) {
      if (button !== Qt.LeftButton && button !== Qt.RightButton && button !== Qt.MiddleButton) return false
      var target = pressTargetAt(px, py)
      if (!target) return false
      target.triggerPress(button)
      return true
    }

    // This overlay takes presses on the bar strip too, so the bar button under
    // the pointer never sees itself held; it's told, for its press feedback,
    // the way the bar's own press handler tells it.
    property var heldTarget: null
    function hold(target, button) {
      if (heldTarget && heldTarget !== target && "heldButtons" in heldTarget) heldTarget.heldButtons = Qt.NoButton
      heldTarget = target && "heldButtons" in target ? target : null
      if (heldTarget) heldTarget.heldButtons = button
    }

    // Every button still down, so a second button pressed or let go mid-hold
    // leaves the first one's feedback alone.
    onPressed: function(mouse) {
      hold(root.focusPrimed && inBarRegion(mouse.x, mouse.y) ? pressTargetAt(mouse.x, mouse.y) : null, mouse.buttons)
    }
    onReleased: function(mouse) { hold(mouse.buttons ? heldTarget : null, mouse.buttons) }
    onCanceled: hold(null)
    onEnabledChanged: if (!enabled) hold(null)

    onPositionChanged: function(mouse) { hoveringBar = inBarRegion(mouse.x, mouse.y) }
    onExited: hoveringBar = false
    onClicked: function(mouse) {
      // While Exclusive is priming, Hyprland may route a click from another
      // output here with translated coordinates. Never interpret that as a
      // click on this output's bar.
      if (root.focusPrimed && inBarRegion(mouse.x, mouse.y) && forwardBarClick(mouse.x, mouse.y, mouse.button)) return
      root.close()
    }
  }

  // The panel surface only spans the anchor's screen, and the compositor
  // hit-tests pointer input per output, so `dismissArea` above can never see
  // a click on another monitor. Give every other output a transparent twin
  // whose only job is to catch that click. They exist only while the panel is
  // logically open (not during the fade-out, matching `dismissArea.enabled`).
  //
  // Keyboard focus is None: these must catch the pointer without taking focus
  // from the panel when the cursor merely crosses onto their output.
  Variants {
    model: root.open ? Quickshell.screens : []

    delegate: Component {
      PanelWindow {
        required property var modelData

        screen: modelData
        // Compare by output name: the anchor screen must be known before any
        // twin maps, or a twin would cover the panel's own output.
        visible: root.open && !!root.screen && modelData.name !== root.screen.name
        color: "transparent"
        exclusionMode: ExclusionMode.Auto

        WlrLayershell.namespace: "omarchy-keyboard-panel-dismiss"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        anchors {
          top: true
          bottom: true
          left: true
          right: true
        }

        MouseArea {
          anchors.fill: parent
          acceptedButtons: Qt.AllButtons
          onPressed: root.close()
        }
      }
    }
  }

  // --- card ----------------------------------------------------------------

  BorderSurface {
    id: card
    x: root.morphed(root.morphFrom.x, root.cardOrigin.x)
    y: root.morphed(root.morphFrom.y, root.cardOrigin.y)
    width: root.morphed(root.morphFrom.width, root.contentWidth)
    height: root.morphed(root.morphFrom.height, root.drawnHeight)
    // While it morphs or grows, the content keeps its own size and the card
    // crops it.
    clip: root.morph < 1 || root.drawnHeight < root.contentHeight - 0.5
    color: Commons.Color.popups.background
    borderSpec: root.borderSpec
    padding: root.padding
    radius: Style.cornerRadius

    // The card fades in as it grows out of the bar from just under full size,
    // toward the icon it hangs from, and goes in two thirds of the time. On a
    // switch within a section of the bar it doesn't: the card morphs over from
    // the last one.
    property real shown: root.open || root.popoutSwitching ? 1 : 0
    Behavior on shown {
      id: showing
      // The card giving way on a switch still fades out, briefly over the one
      // taking its place, so there's no empty frame while that one maps.
      enabled: !root.takingOver && !(root.popoutSwitching && root.morph < 1)
      NumberAnimation {
        duration: Style.duration(showing.targetValue > 0 ? 180 : 120)
        easing.type: Easing.Bezier
        easing.bezierCurve: Style.easeOut
      }
    }
    opacity: shown
    transform: Scale {
      origin.x: root.growOrigin.x
      origin.y: root.growOrigin.y
      xScale: 0.97 + 0.03 * card.shown
      yScale: 0.97 + 0.03 * card.shown
    }

    // Swallow clicks on the card so they don't bubble to the dismissal
    // MouseArea behind us.
    MouseArea {
      anchors.fill: parent
      acceptedButtons: Qt.AllButtons
    }

    Flickable {
      id: contentViewport
      objectName: "keyboard-panel-content-viewport"
      anchors.top: parent.top
      anchors.left: parent.left
      width: root.contentWidth - card.contentLeftInset - card.contentRightInset
      height: root.contentHeight - card.contentTopInset - card.contentBottomInset
      contentWidth: width
      contentHeight: contentHolder.height
      clip: true
      boundsBehavior: Flickable.StopAtBounds
      flickableDirection: Flickable.VerticalFlick
      interactive: contentHeight > height
      Controls.ScrollBar.vertical: Controls.ScrollBar { policy: Controls.ScrollBar.AsNeeded }
      function revealItem(item) {
        if (!interactive) {
          contentY = 0
          return
        }
        // A panel's key catcher spans the entire form. Only reveal controls
        // that fit inside the viewport, not that enclosing focus scope.
        if (!item || item.height > height) return
        var ancestor = item
        while (ancestor && ancestor !== contentHolder) ancestor = ancestor.parent
        if (!ancestor) return
        var point = item.mapToItem(contentHolder, 0, 0)
        if (point.y < contentY) contentY = point.y
        else if (point.y + item.height > contentY + height)
          contentY = point.y + item.height - height
        contentY = Math.max(0, Math.min(contentY, contentHeight - height))
      }
      function revealFocusedItem() {
        var window = contentHolder.Window.window
        var item = window ? window.activeFocusItem : null
        if (!item || item.height > height) item = root.scrollCursorItem
        revealItem(item)
      }
      onHeightChanged: Qt.callLater(revealFocusedItem)
      onContentHeightChanged: Qt.callLater(revealFocusedItem)
      Connections {
        target: contentHolder.Window.window
        function onActiveFocusItemChanged() { Qt.callLater(contentViewport.revealFocusedItem) }
      }
      // Right-to-left languages read the card mirrored; the card itself
      // stays where the bar puts it.
      LayoutMirroring.enabled: Commons.I18n.rightToLeft
      LayoutMirroring.childrenInherit: true
      anchors.topMargin: card.contentTopInset
      anchors.leftMargin: card.contentLeftInset
      // Fades in with the morph, done by the time the card has mostly landed.
      opacity: Math.min(1, root.morph * 1.6)

      Item {
        id: contentHolder
        width: contentViewport.width
        // Keep the full form/list layout intact when the OSK reduces the card.
        // The viewport scrolls instead of putting lower controls off-surface.
        height: root.scrollOverflow ? Math.max(contentViewport.height, root.loadedContentHeight) : contentViewport.height

        Loader {
          id: contentLoader
          anchors.fill: parent
          focus: true
          active: !!root.content && (root.open || root.contentRequested)
          sourceComponent: root.content
        }
      }

    }
  }
}
