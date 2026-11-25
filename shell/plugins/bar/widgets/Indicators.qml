import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui
import "../BarModel.js" as BarModel

BarWidget {
  id: root
  moduleName: "omarchy.indicators"

  readonly property var defaultIndicatorEntries: [ "PasswordlessSudo", "ScreenRecording", "RemoteSession", "Reminder", "NightLight", "Dnd", "StayAwake" ]
  readonly property var indicatorEntries: indicatorEntriesFromSettings(settings)
  property var activeIndicatorIds: []
  property var indicatorActiveStates: ({})
  property bool indicatorAreaHovered: false
  property bool indicatorItemHovered: false
  // The bar surface watches the same span, joined with the section that holds
  // this widget (sectionItem). A collapsed widget is a point, so the zone
  // beside it can sit outside every ancestor that would deliver hover.
  property bool indicatorBarHovered: false
  // The section list this widget is drawn in. Null in the contract fixture,
  // which has no bar around it. The hover zone itself stays the growth side;
  // the section is only added when the bar tests the pointer.
  property Item sectionItem: null
  // Held a moment after the pointer leaves, so crossing between icons, or a
  // frame where the widget moves under a still pointer, doesn't flicker them.
  property bool hoverRevealHeld: false
  readonly property bool alwaysShowIndicators: setting("alwaysShow", false) === true
  // The tray's drawer already hides them until hovered, and an empty widget
  // there would leave no room to hover for a second reveal.
  readonly property bool revealInactiveIndicators: alwaysShowIndicators || inTraySection || hoverRevealHeld
  readonly property real inactiveReach: orientationLoader.item ? orientationLoader.item.inactiveLength : 0
  // In the widget's own coordinates. The fixed edge is 0, the widget's
  // length, or its midpoint, which is the point the section holds still.
  readonly property var indicatorPeekSpan: {
    var length = root.vertical ? root.implicitHeight : root.implicitWidth
    var origin = root.fixedEdge === "start" ? 0 : root.fixedEdge === "center" ? length / 2 : length
    return BarModel.indicatorPeekSpan(root.fixedEdge, origin, length, root.inactiveReach, root.revealInactiveIndicators)
  }
  // The active block sits against the widget's fixed edge, and everything that
  // grows the widget (revealed inactive icons, newly active ones) goes on its
  // far side, so the icons already showing keep their click targets. A
  // centered widget grows both ways and keeps the end-fixed arrangement.
  readonly property bool fixedAtStart: fixedEdge === "start"

  signal refreshRequested()

  ListModel { id: activeIndicatorModel }

  // The inactive indicators in the order they show. Facing the other way, the
  // widget mirrors them along with its blocks, so they read outward from the
  // active block as they do from the other side. Turned around by moves, so no
  // indicator is built again.
  ListModel { id: inactiveIndicatorModel }
  property string inactiveIndicatorJson: ""
  property bool inactiveIndicatorsMirrored: false

  function entryId(entry) {
    if (typeof entry === "string") return entry
    if (Util.isPlainObject(entry)) {
      var id = entry["id"]
      if (id !== undefined && id !== null && String(id) !== "") return String(id)
    }
    return ""
  }

  function entrySettings(entry) {
    if (!Util.isPlainObject(entry)) return {}
    var copy = {}
    for (var key in entry) {
      if (key === "id") continue
      copy[key] = entry[key]
    }
    return copy
  }

  function indicatorEntriesFromSettings(settings) {
    var source = defaultIndicatorEntries
    if (settings.items && typeof settings.items.length === "number" && settings.items.length > 0) source = settings.items
    else if (settings.indicators && typeof settings.indicators.length === "number" && settings.indicators.length > 0) source = settings.indicators

    var result = []
    for (var i = 0; i < source.length; i++) {
      var item = source[i]
      if (typeof item !== "string" && item !== null && typeof item === "object") {
        try {
          item = JSON.parse(JSON.stringify(item))
        } catch (error) {
        }
      }
      var id = entryId(item)
      if (id !== "") result.push(item)
    }
    return result
  }

  function setIndicatorAreaHovered(hovered) {
    indicatorAreaHovered = hovered
    syncHoverReveal()
  }

  function setIndicatorItemHovered(hovered) {
    indicatorItemHovered = hovered
    syncHoverReveal()
  }

  function setIndicatorBarHovered(hovered) {
    if (indicatorBarHovered === hovered) return
    indicatorBarHovered = hovered
    syncHoverReveal()
  }

  // `target` is the bar surface. The span is computed in that item's
  // coordinates so the surface can test the pointer without the local hover
  // zone having to sit over neighbouring widgets.
  function sectionSpanIn(target) {
    var list = sectionItem
    if (!list || !target) return null
    // The centered box moves every sibling by half the added width. Only
    // sections anchored to the widget's own fixed edge have a still side.
    if (list.fixedEdge === "center" || list.fixedEdge !== fixedEdge) return null
    var extent = vertical ? list.height : list.width
    if (!(extent > 0)) return null
    var origin = list.mapToItem(target, 0, 0)
    var start = vertical ? origin.y : origin.x
    if (!isFinite(start)) return null
    return { start: start, end: start + extent }
  }

  function peekSpanIn(target) {
    if (!target) return null
    var length = vertical ? implicitHeight : implicitWidth
    var localOrigin = fixedEdge === "start" ? 0 : fixedEdge === "center" ? length / 2 : length
    var point = mapToItem(target, vertical ? 0 : localOrigin, vertical ? localOrigin : 0)
    var origin = vertical ? point.y : point.x
    var section = sectionSpanIn(target)
    return BarModel.indicatorPeekSpan(
      fixedEdge, origin, length, inactiveReach, revealInactiveIndicators,
      section ? section.start : NaN, section ? section.end : NaN
    )
  }

  function syncHoverReveal() {
    if (indicatorAreaHovered || indicatorItemHovered || indicatorBarHovered) {
      indicatorHideTimer.stop()
      hoverRevealHeld = true
    } else {
      indicatorHideTimer.restart()
    }
  }

  function hasIndicatorId(id) {
    for (var i = 0; i < indicatorEntries.length; i++) {
      if (entryId(indicatorEntries[i]) === id) return true
    }
    return false
  }

  function entryForId(id) {
    for (var i = 0; i < indicatorEntries.length; i++) {
      var entry = indicatorEntries[i]
      if (entryId(entry) === id) return entry
    }

    return { id: id }
  }

  function activeModelIndex(id) {
    for (var i = 0; i < activeIndicatorModel.count; i++) {
      if (activeIndicatorModel.get(i).activeId === id) return i
    }
    return -1
  }

  function copyActiveStates() {
    var states = {}
    for (var id in indicatorActiveStates) {
      if (indicatorActiveStates[id] === true) states[id] = true
    }
    return states
  }

  function orderedActiveIds(states, preferredOrder) {
    var ids = []

    for (var i = 0; i < preferredOrder.length; i++) {
      var id = preferredOrder[i]
      if (ids.indexOf(id) === -1 && hasIndicatorId(id) && states[id] === true) ids.push(id)
    }

    return ids
  }

  function syncActiveIndicatorModel() {
    for (var i = activeIndicatorModel.count - 1; i >= 0; i--) {
      if (activeIndicatorIds.indexOf(activeIndicatorModel.get(i).activeId) === -1)
        activeIndicatorModel.remove(i)
    }

    for (var j = 0; j < activeIndicatorIds.length; j++) {
      var id = activeIndicatorIds[j]
      var index = activeModelIndex(id)
      if (index === -1) activeIndicatorModel.insert(j, { activeId: id })
      else if (index !== j) activeIndicatorModel.move(index, j, 1)
    }
  }

  function setIndicatorActive(entry, active) {
    var id = entryId(entry)
    if (id === "") return

    var states = copyActiveStates()
    if (active) states[id] = true
    else delete states[id]

    indicatorActiveStates = states

    var ids = orderedActiveIds(states, activeIndicatorIds)
    // Newcomers go on the side of the active block away from the fixed edge.
    // The other side would shove everything already showing sideways.
    if (active && ids.indexOf(id) === -1 && hasIndicatorId(id)) {
      if (fixedAtStart) ids.push(id)
      else ids.unshift(id)
    }
    activeIndicatorIds = ids
    syncActiveIndicatorModel()
  }

  function syncActiveIndicatorOrder() {
    activeIndicatorIds = orderedActiveIds(indicatorActiveStates, activeIndicatorIds)
    syncActiveIndicatorModel()
  }

  function syncInactiveIndicatorModel() {
    var json = JSON.stringify(indicatorEntries)
    if (json !== inactiveIndicatorJson) {
      inactiveIndicatorJson = json
      inactiveIndicatorModel.clear()
      inactiveIndicatorsMirrored = false
      for (var i = 0; i < indicatorEntries.length; i++)
        inactiveIndicatorModel.append({ entryJson: JSON.stringify(indicatorEntries[i]) })
    }
    if (inactiveIndicatorsMirrored === fixedAtStart) return
    for (var j = 1; j < inactiveIndicatorModel.count; j++) inactiveIndicatorModel.move(j, 0, 1)
    inactiveIndicatorsMirrored = fixedAtStart
  }

  function refresh() { root.refreshRequested() }

  onIndicatorEntriesChanged: {
    syncActiveIndicatorOrder()
    syncInactiveIndicatorModel()
  }
  onFixedAtStartChanged: syncInactiveIndicatorModel()

  // Only the tree for the current orientation exists (see orientationLoader
  // below); its wrapper keeps the stock sizing expressions, so the root's
  // implicit size still follows the blocks synchronously rather than waiting
  // on a positioner's polish.
  implicitWidth: orientationLoader.item ? orientationLoader.item.implicitWidth : 0
  implicitHeight: orientationLoader.item ? orientationLoader.item.implicitHeight : 0

  ShellIpc {
    target: "omarchy.indicators"

    function refresh(): void {
      root.broadcast("refresh")
    }
  }

  Timer {
    id: indicatorHideTimer
    interval: 120
    onTriggered: if (!root.indicatorAreaHovered && !root.indicatorItemHovered && !root.indicatorBarHovered) root.hoverRevealHeld = false
  }

  Component.onCompleted: {
    syncInactiveIndicatorModel()
    root.refreshRequested()
  }

  // Where the hidden icons would show: hovering there reveals them, and the
  // rest of the bar leaves them hidden. Hidden, they take no room, so the zone
  // reaches past the widget on the side they grow toward (both sides when the
  // widget is centered). Revealed, a start or end edge keeps half that reach
  // past the widget: the centered box slides half its growth back the other
  // way, and a zone that stopped at the widget's edge would lose the pointer
  // that opened it. Placed under orientationLoader so the icons stay on top
  // and keep their hover, pointing-hand cursor, and tooltips; the bar surface
  // tests the same span across the widget and its section.
  Item {
    id: hiddenBlockZone
    objectName: "hiddenBlockZone"

    readonly property var span: root.indicatorPeekSpan
    readonly property real spanStart: span ? span.start : 0
    readonly property real spanEnd: span ? span.end : 0

    x: root.vertical ? 0 : spanStart
    y: root.vertical ? spanStart : 0
    width: root.vertical ? root.implicitWidth : Math.max(0, spanEnd - spanStart)
    height: root.vertical ? Math.max(0, spanEnd - spanStart) : root.implicitHeight
    visible: !!span

    HoverHandler {
      onHoveredChanged: root.setIndicatorAreaHovered(hovered)
    }
  }

  // Instantiating both orientation trees and toggling `visible` doubled every
  // indicator per bar (and every process an indicator spawns, once per
  // monitor). Load only the tree that matches the bar orientation instead.
  Loader {
    id: orientationLoader
    sourceComponent: root.vertical ? verticalIndicatorsTree : horizontalIndicatorsTree
  }

  // The two blocks are placed by hand rather than by a Row or Column: a
  // Column cannot reverse its order, and the inactive area has to go on
  // whichever side is away from the fixed edge.
  Component {
    id: horizontalIndicatorsTree

    Item {
      readonly property real inactiveLength: inactiveHorizontalBlock.implicitWidth

      implicitWidth: activeHorizontalBlock.implicitWidth + inactiveHorizontalArea.implicitWidth
      implicitHeight: Math.max(activeHorizontalBlock.implicitHeight, inactiveHorizontalArea.implicitHeight)
      width: implicitWidth
      height: implicitHeight

      Item {
        id: inactiveHorizontalArea

        x: root.fixedAtStart ? activeHorizontalBlock.width : 0
        implicitWidth: root.revealInactiveIndicators ? inactiveHorizontalBlock.implicitWidth : 0
        implicitHeight: Math.max(inactiveHorizontalBlock.implicitHeight, root.barSize)
        width: implicitWidth
        height: implicitHeight
        clip: true

        IndicatorBlock {
          id: inactiveHorizontalBlock
          anchors.verticalCenter: parent.verticalCenter
          indicatorsModule: root
          indicatorModel: inactiveIndicatorModel
          indicatorBlock: "inactive"
          horizontal: true
          reportActiveState: !root.vertical
        }
      }

      ActiveIndicatorBlock {
        id: activeHorizontalBlock
        x: root.fixedAtStart ? 0 : inactiveHorizontalArea.width
        indicatorsModule: root
        indicatorModel: activeIndicatorModel
        horizontal: true
        reportActiveState: !root.vertical
      }
    }
  }

  Component {
    id: verticalIndicatorsTree

    Item {
      readonly property real inactiveLength: inactiveVerticalBlock.implicitHeight

      implicitWidth: Math.max(activeVerticalBlock.implicitWidth, inactiveVerticalArea.implicitWidth)
      implicitHeight: activeVerticalBlock.implicitHeight + inactiveVerticalArea.implicitHeight
      width: implicitWidth
      height: implicitHeight

      Item {
        id: inactiveVerticalArea

        y: root.fixedAtStart ? activeVerticalBlock.height : 0
        implicitWidth: Math.max(inactiveVerticalBlock.implicitWidth, root.barSize)
        implicitHeight: root.revealInactiveIndicators ? inactiveVerticalBlock.implicitHeight : 0
        width: implicitWidth
        height: implicitHeight
        clip: true

        IndicatorBlock {
          id: inactiveVerticalBlock
          anchors.horizontalCenter: parent.horizontalCenter
          indicatorsModule: root
          indicatorModel: inactiveIndicatorModel
          indicatorBlock: "inactive"
          horizontal: false
          reportActiveState: root.vertical
        }
      }

      ActiveIndicatorBlock {
        id: activeVerticalBlock
        y: root.fixedAtStart ? 0 : inactiveVerticalArea.height
        indicatorsModule: root
        indicatorModel: activeIndicatorModel
        horizontal: false
        reportActiveState: root.vertical
      }
    }
  }

  component ActiveIndicatorBlock: Item {
    id: activeIndicatorBlockRoot

    property var indicatorModel: null
    property var indicatorsModule: null
    property bool horizontal: true
    property bool reportActiveState: false

    implicitWidth: blockLoader.item ? blockLoader.item.implicitWidth : 0
    implicitHeight: blockLoader.item ? blockLoader.item.implicitHeight : 0
    width: implicitWidth
    height: implicitHeight

    Loader {
      id: blockLoader

      anchors.centerIn: parent
      sourceComponent: activeIndicatorBlockRoot.horizontal ? horizontalActiveIndicatorBlock : verticalActiveIndicatorBlock
    }

    Component {
      id: horizontalActiveIndicatorBlock

      Row {
        spacing: 0

        Repeater {
          model: activeIndicatorBlockRoot.indicatorModel

          IndicatorLoader {
            required property string activeId
            indicatorsModule: activeIndicatorBlockRoot.indicatorsModule
            entry: activeIndicatorBlockRoot.indicatorsModule.entryForId(activeId)
            indicatorBlock: "active"
            reportActiveState: activeIndicatorBlockRoot.reportActiveState
          }
        }
      }
    }

    Component {
      id: verticalActiveIndicatorBlock

      Column {
        spacing: 0

        Repeater {
          model: activeIndicatorBlockRoot.indicatorModel

          IndicatorLoader {
            required property string activeId
            indicatorsModule: activeIndicatorBlockRoot.indicatorsModule
            entry: activeIndicatorBlockRoot.indicatorsModule.entryForId(activeId)
            indicatorBlock: "active"
            reportActiveState: activeIndicatorBlockRoot.reportActiveState
          }
        }
      }
    }
  }

  component IndicatorBlock: Item {
    id: indicatorBlockRoot

    property var indicatorModel: null
    property var indicatorsModule: null
    property string indicatorBlock: "active"
    property bool horizontal: true
    property bool reportActiveState: false

    implicitWidth: blockLoader.item ? blockLoader.item.implicitWidth : 0
    implicitHeight: blockLoader.item ? blockLoader.item.implicitHeight : 0
    width: implicitWidth
    height: implicitHeight

    Loader {
      id: blockLoader

      anchors.centerIn: parent
      sourceComponent: indicatorBlockRoot.horizontal ? horizontalIndicatorBlock : verticalIndicatorBlock
    }

    Component {
      id: horizontalIndicatorBlock

      Row {
        spacing: 0

        Repeater {
          model: indicatorBlockRoot.indicatorModel

          IndicatorLoader {
            required property string entryJson
            indicatorsModule: indicatorBlockRoot.indicatorsModule
            entry: JSON.parse(entryJson)
            indicatorBlock: indicatorBlockRoot.indicatorBlock
            reportActiveState: indicatorBlockRoot.reportActiveState
          }
        }
      }
    }

    Component {
      id: verticalIndicatorBlock

      Column {
        spacing: 0

        Repeater {
          model: indicatorBlockRoot.indicatorModel

          IndicatorLoader {
            required property string entryJson
            indicatorsModule: indicatorBlockRoot.indicatorsModule
            entry: JSON.parse(entryJson)
            indicatorBlock: indicatorBlockRoot.indicatorBlock
            reportActiveState: indicatorBlockRoot.reportActiveState
          }
        }
      }
    }
  }

  component IndicatorLoader: Item {
    id: indicatorSlot

    required property var entry
    property var indicatorsModule: null
    required property string indicatorBlock
    property bool reportActiveState: false
    property bool activeStateObserved: false
    readonly property string indicatorId: root.entryId(entry)
    readonly property var indicatorSettings: root.entrySettings(entry)
    readonly property var barRef: root.bar

    implicitWidth: indicatorSource.item && indicatorSource.item.visible ? indicatorSource.item.implicitWidth : 0
    implicitHeight: indicatorSource.item && indicatorSource.item.visible ? indicatorSource.item.implicitHeight : 0
    width: implicitWidth
    height: implicitHeight
    onEntryChanged: {
      activeStateObserved = false
      injectProps()
      syncActiveState()
    }
    onIndicatorBlockChanged: injectProps()
    onIndicatorSettingsChanged: injectProps()
    onIndicatorsModuleChanged: {
      injectProps()
      syncActiveState()
    }
    onReportActiveStateChanged: syncActiveState()
    onBarRefChanged: injectProps()

    Loader {
      id: indicatorSource

      anchors.fill: parent
      source: /^[A-Za-z0-9_-]+$/.test(indicatorSlot.indicatorId)
        ? Qt.resolvedUrl("../indicators/" + indicatorSlot.indicatorId + ".qml")
        : ""
      onLoaded: {
        indicatorSlot.injectProps()
        indicatorSlot.syncActiveState()
      }
      onStatusChanged: if (status === Loader.Error) console.warn("Indicator loader error", indicatorSlot.indicatorId, source)
    }

    Connections {
      target: indicatorSource.item
      ignoreUnknownSignals: true
      function onActiveChanged() { indicatorSlot.syncActiveState() }
    }

    function injectProps() {
      var target = indicatorSource.item
      if (!target) return
      if ("bar" in target) target.bar = root.bar
      if ("moduleName" in target) target.moduleName = indicatorId
      if ("settings" in target) target.settings = indicatorSettings
      if ("indicatorBlock" in target) target.indicatorBlock = indicatorBlock
      if ("indicatorHost" in target) target.indicatorHost = root
      if ("activeOverride" in target) target.activeOverride = indicatorBlock === "active" ? true : null
    }

    function syncActiveState() {
      if (!reportActiveState || !indicatorsModule || !indicatorsModule.setIndicatorActive) return

      var active = !!indicatorSource.item && indicatorSource.item.active === true
      if (indicatorBlock === "active") {
        if (active) activeStateObserved = true
        else if (!activeStateObserved) return
      }

      indicatorsModule.setIndicatorActive(entry, active)
    }
  }
}
