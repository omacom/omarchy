import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Ui
import qs.Commons
import qs.Commons as Commons
import "Model.js" as Model

// Reach: one keyboard and mouse across your machines. The panel draws the row
// of machines like the Display panel draws displays: drag a machine to move
// it, add your other Circle machines at either end, take one out. The row is
// written with `reach arrange`, and Reach hands it to every other machine.
Panel {
  id: root
  moduleName: "omarchy.reach"
  ipcTarget: "omarchy.reach"
  manageIpc: false

  property bool available: false
  property bool running: false
  property string me: ""
  property var screens: []
  property var peers: []
  property var connected: []
  property bool circleUp: false
  property string actionStatus: ""
  property int _desired: -1

  // Cursor model shared by keyboard and mouse. Sections, top to bottom:
  //   "header" - the on/off switch.
  //   "map"    - the row; h/l picks a machine, ctrl+h/l moves it, x takes it out.
  //   "add"    - the machines not in the row; h/l adds the picked one on that side.
  property string focusSection: "header"
  property int mapIndex: 0
  property int addIndex: 0
  property bool cursorActive: false

  readonly property bool active: _desired === -1 ? running : _desired === 1
  readonly property bool busy: controlProc.running
  readonly property var tiles: Model.tiles(screens, me, peers, connected)
  readonly property int nearby: Model.nearbyCount(peers, me)
  readonly property var addList: Model.addable(screens, me, peers)
  readonly property bool arranged: tiles.length > 1
  readonly property bool arranging: available && active
  readonly property color foreground: bar ? bar.foreground : Commons.Color.foreground
  readonly property color dim: Qt.darker(foreground, 1.55)
  readonly property string fontFamily: bar ? bar.fontFamily : Style.font.family
  readonly property string glyph: String.fromCodePoint(0xF037D)

  // Like Continuity: the icon only shows once Circle is up and one of your
  // machines is close by, or a row is already set. Until then it's hidden, and
  // nothing runs: Reach writes its state to a file this panel watches.
  visible: opened || (available && circleUp && (nearby > 0 || arranged))

  readonly property string heroMeta: {
    if (!available) return Commons.I18n.t("reach.notInstalled")
    if (!active) return Commons.I18n.t("reach.offMeta")
    if (!arranged && nearby > 0) return Commons.I18n.tn("reach.nearbyMeta", nearby).arg(Commons.I18n.formatNumber(nearby))
    if (!arranged) return Commons.I18n.t("reach.notArrangedMeta")
    return Commons.I18n.tn("reach.inRow", tiles.length).arg(Commons.I18n.formatNumber(tiles.length))
  }

  function sections() {
    var list = ["header"]
    if (arranging) list.push("map")
    if (arranging && addList.length > 0) list.push("add")
    return list
  }

  function clampCursor() {
    var list = sections()
    if (list.indexOf(focusSection) === -1) focusSection = "header"
    mapIndex = Math.max(0, Math.min(mapIndex, tiles.length - 1))
    addIndex = Math.max(0, Math.min(addIndex, addList.length - 1))
  }

  function selectedTile() {
    return focusSection === "map" && mapIndex < tiles.length ? tiles[mapIndex] : null
  }

  function selectTile(name) {
    for (var i = 0; i < tiles.length; i++) {
      if (tiles[i].name === name) {
        cursorActive = true
        focusSection = "map"
        mapIndex = i
        return
      }
    }
  }

  function moveCursor(dy) {
    clampCursor()
    if (focusSection === "add") {
      var next = addIndex + dy
      if (next < 0) focusSection = "map"
      else addIndex = Math.min(addList.length - 1, next)
      return
    }
    var list = sections()
    var i = list.indexOf(focusSection)
    var target = list[Math.max(0, Math.min(list.length - 1, i + dy))]
    if (target === "add") addIndex = 0
    if (target === "map" && focusSection === "header") {
      for (var j = 0; j < tiles.length; j++) if (tiles[j].self) mapIndex = j
    }
    focusSection = target
  }

  function moveCursorH(dx) {
    clampCursor()
    if (focusSection === "map") mapIndex = Math.max(0, Math.min(tiles.length - 1, mapIndex + dx))
    else if (focusSection === "add" && addList.length > 0) place(addList[addIndex].name, dx < 0 ? "left" : "right")
  }

  function activateCursor() {
    clampCursor()
    if (focusSection === "header") toggleReach()
    else if (focusSection === "add" && addList.length > 0) place(addList[addIndex].name, "right")
  }

  // ---- state ----

  // Re-read Reach's state file, and ask systemd whether Reach is running:
  // the file stays behind when it's turned off.
  function refresh() {
    statusFile.reload()
    if (!activeProc.running) activeProc.running = true
  }

  function applyStatus(raw) {
    var s = Model.parseStatus(raw)
    available = s.ok
    if (!s.ok) return
    // Reach wrote it, so it's running unless systemd says otherwise on open.
    if (!opened) running = true
    me = s.me
    circleUp = s.circleUp
    if (JSON.stringify(s.screens) !== JSON.stringify(screens)) screens = s.screens
    if (JSON.stringify(s.connected) !== JSON.stringify(connected)) connected = s.connected
    if (JSON.stringify(s.peers) !== JSON.stringify(peers)) peers = s.peers
    clampCursor()
  }

  // ---- actions ----

  function toggleReach() {
    if (!available || busy) return
    var on = !active
    run(["systemctl", "--user", on ? "enable" : "disable", "--now", "reach.service"], on ? 1 : 0)
  }

  function arrange(row) {
    if (!arranging || busy || JSON.stringify(row) === JSON.stringify(screens)) return
    // Draw the new row right away; the refresh after the command confirms it.
    screens = row
    run(["reach", "arrange"].concat(row), -1)
  }

  function place(name, side) { arrange(Model.place(screens, me, name, side)) }
  function remove(name) { arrange(Model.remove(screens, me, name)) }
  function moveTo(name, index) { arrange(Model.moveTo(screens, me, name, index)) }

  function nudgeSelected(dx) {
    var tile = selectedTile()
    if (!tile) return
    arrange(Model.nudge(screens, me, tile.name, dx))
    // Keep the cursor on the machine that moved.
    Qt.callLater(function() { root.selectTile(tile.name) })
  }

  function removeSelected() {
    var tile = selectedTile()
    if (tile && !tile.self) remove(tile.name)
  }

  function run(command, desired) {
    _desired = desired
    controlProc.command = command
    controlProc.running = true
  }

  function showStatus(message) {
    actionStatus = message
    actionStatusTimer.restart()
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  onOpenedChanged: if (opened) {
    cursorActive = false
    focusSection = "header"
    refresh()
    Qt.callLater(function() { if (panel.loadedContent) panel.loadedContent.forceActiveFocus() })
  }

  ShellIpc {
    target: root.ipcTarget
    function open(): void { root.open() }
    function close(): void { root.close() }
    function show(): void { root.open() }
    function hide(): void { root.close() }
    function toggle(): void { root.toggle() }
    function refresh(): string { root.refresh(); return "ok" }
    // `omarchy-shell omarchy.reach place laptop left`, `... unplace laptop`.
    function place(name: string, side: string): string {
      if (side !== "left" && side !== "right") return "side must be left or right"
      if (!root.arranging) { root.refresh(); return "try again" }
      root.place(name, side)
      return "ok"
    }
    function unplace(name: string): string {
      if (!root.arranging) { root.refresh(); return "try again" }
      root.remove(name)
      return "ok"
    }
  }

  Timer {
    id: actionStatusTimer
    interval: 2600
    onTriggered: root.actionStatus = ""
  }

  // Reach keeps this current (the row, who's connected, which Circle machines
  // are close by), and a FileView fires for any change in its directory too,
  // so it sees the file appear whenever Reach starts.
  FileView {
    id: statusFile
    path: Quickshell.env("XDG_RUNTIME_DIR") + "/reach.json"
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: root.applyStatus(text())
    onLoadFailed: root.available = false
  }

  Process {
    id: activeProc
    command: ["systemctl", "--user", "is-active", "reach.service"]
    stdout: StdioCollector { id: activeOut; waitForEnd: true }
    onExited: {
      root.running = activeOut.text.trim() === "active"
      if (root._desired !== -1 && root.running === (root._desired === 1)) root._desired = -1
    }
  }

  Process {
    id: controlProc
    stderr: StdioCollector { id: controlErr; waitForEnd: true }
    onExited: function(exitCode) {
      if (exitCode !== 0) {
        root._desired = -1
        var message = String(controlErr.text || "").replace(/\s+/g, " ").trim()
        root.showStatus(message !== "" ? message : Commons.I18n.t("reach.commandFailed"))
      }
      root.refresh()
    }
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.glyph
    opacity: root.available && !root.active ? 0.55 : 1
    onPressed: function(buttonCode) {
      if (buttonCode === Qt.RightButton) root.toggleReach()
      else root.toggle()
    }
  }

  KeyboardPanel {
    id: panel
    anchorItem: button
    owner: root
    bar: root.bar
    open: root.opened
    focusTarget: panel.loadedContent
    contentWidth: panel.fittedContentWidth(Style.space(400))
    contentHeight: panel.fittedContentHeight(panel.loadedContentHeight, Style.space(640))

    content: PanelKeyCatcher {
      implicitHeight: column.implicitHeight
      anchors.fill: parent
      reorderableSideways: root.cursorActive && root.focusSection === "map"
      onReorderSidewaysRequested: function(dx) { root.nudgeSelected(dx) }
      onMoveRequested: function(dx, dy) {
        if (!root.cursorActive) { root.cursorActive = true; root.clampCursor(); return }
        if (dy !== 0) root.moveCursor(dy)
        else if (dx !== 0) root.moveCursorH(dx)
      }
      onActivateRequested: if (root.cursorActive) root.activateCursor()
      onDeleteRequested: if (root.cursorActive) root.removeSelected()
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }
      onTextKey: function(t) {
        if (t === "t") root.toggleReach()
        else if (t === "r") root.refresh()
      }

      Column {
        id: column
        width: parent.width
        spacing: Style.space(14)

        PanelHero {
          id: hero
          width: parent.width
          title: Commons.I18n.t("reach.title")
          meta: root.heroMeta
          foreground: root.foreground
          fontFamily: root.fontFamily
          iconOpacity: root.arranging ? 1.0 : 0.5
          iconComponent: Component {
            Text {
              textFormat: Text.PlainText
              text: root.glyph
              color: hero.foreground
              font.family: hero.fontFamily
              font.pixelSize: Style.font.display
            }
          }
          trailingControl: Component {
            ToggleSwitch {
              id: powerSwitch
              visible: root.available
              checked: root.active
              busy: root.busy
              hasCursor: root.cursorActive && root.focusSection === "header"
              foreground: hero.foreground
              onHovered: function(on) { if (on) { root.cursorActive = true; root.focusSection = "header" } }
              onToggled: root.toggleReach()

              PanelToolTip {
                visible: powerSwitch.containsMouse
                text: root.active ? Commons.I18n.t("reach.turnOff") : Commons.I18n.t("reach.turnOn")
                fontFamily: hero.fontFamily
              }
            }
          }
        }

        Text {
          textFormat: Text.PlainText
          visible: text !== ""
          width: parent.width
          text: root.actionStatus
          color: root.bar ? root.bar.urgent : Commons.Color.urgent
          font.family: root.fontFamily
          font.pixelSize: Style.font.bodySmall
          wrapMode: Text.WordWrap
        }

        Text {
          textFormat: Text.PlainText
          visible: !root.arranging
          width: parent.width
          topPadding: Style.space(6)
          bottomPadding: Style.space(6)
          text: root.available ? Commons.I18n.t("reach.offMessage") : Commons.I18n.t("reach.installMessage")
          color: root.dim
          font.family: root.fontFamily
          font.pixelSize: Style.font.body
          horizontalAlignment: Text.AlignHCenter
          wrapMode: Text.WordWrap
        }

        // ---------- The row ----------
        Column {
          visible: root.arranging
          width: parent.width
          spacing: Style.space(8)

          PanelSeparator { foreground: root.foreground }

          PanelSectionHeader {
            text: Commons.I18n.t("reach.arrangement")
            foreground: root.foreground
            fontFamily: root.fontFamily
          }

          RowMap {
            id: rowMap
            width: parent.width
            hasCursor: root.cursorActive && root.focusSection === "map"
          }

          Text {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            textFormat: Text.PlainText
            text: root.arranged ? Commons.I18n.t("reach.arrangeHint") : Commons.I18n.t("reach.startHint")
            color: root.dim
            font.family: root.fontFamily
            font.pixelSize: Style.font.caption
          }
        }

        // ---------- Machines to add ----------
        Column {
          visible: root.arranging
          width: parent.width
          spacing: Style.space(6)

          PanelSeparator { foreground: root.foreground }

          PanelSectionHeader {
            text: Commons.I18n.t("reach.addMachines")
            foreground: root.foreground
            fontFamily: root.fontFamily
          }

          Text {
            textFormat: Text.PlainText
            visible: root.addList.length === 0
            width: parent.width
            topPadding: Style.space(4)
            text: root.peers.length === 0 ? Commons.I18n.t("reach.noCircle") : Commons.I18n.t("reach.allPlaced")
            color: root.dim
            font.family: root.fontFamily
            font.pixelSize: Style.font.body
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
          }

          Repeater {
            model: root.addList
            AddRow {
              required property var modelData
              required property int index
              width: parent.width
              peer: modelData
              rowIndex: index
            }
          }
        }
      }
    }
  }

  // The machines in a row, this one in the accent. Drag one sideways to move
  // it; click one to pick it for the keyboard.
  component RowMap: Item {
    id: map
    property bool hasCursor: false

    readonly property real gap: Style.space(10)
    readonly property int count: root.tiles.length
    readonly property real tileWidth: Math.min(Style.space(120), (width - gap * (count - 1)) / Math.max(1, count))
    readonly property real tileHeight: Math.round(tileWidth * 0.62)
    readonly property real rowWidth: tileWidth * count + gap * (count - 1)
    readonly property real offsetX: (width - rowWidth) / 2

    function centerOf(i) { return offsetX + i * (tileWidth + gap) + tileWidth / 2 }

    implicitHeight: tileHeight + Style.space(16)

    Repeater {
      model: root.tiles

      Rectangle {
        id: tile
        required property var modelData
        required property int index

        readonly property bool picked: map.hasCursor && root.mapIndex === index
        property real dragX: 0
        property real pressX: 0
        readonly property bool dragging: dragX !== 0

        x: map.offsetX + index * (map.tileWidth + map.gap) + dragX
        y: Style.space(8)
        width: map.tileWidth
        height: map.tileHeight
        z: dragging ? 1 : 0
        radius: Style.cornerRadius > 0 ? Style.space(4) : 0
        color: modelData.self
          ? Style.selectedFillFor(root.foreground, Commons.Color.accent)
          : Style.hoverFillFor(root.foreground, Commons.Color.accent)
        border.width: picked ? 2 : 1
        border.color: picked || modelData.self ? Commons.Color.accent : Qt.darker(root.foreground, 1.6)
        opacity: modelData.online === false ? 0.6 : 1

        Behavior on x { enabled: !tile.dragging; NumberAnimation { duration: Style.duration(140); easing.type: Easing.OutCubic } }

        // The fill is translucent; back it with the panel's surface.
        Rectangle {
          anchors.fill: parent
          z: -1
          radius: parent.radius
          color: Commons.Color.popups.background
        }

        Column {
          anchors.centerIn: parent
          width: parent.width - Style.space(10)
          spacing: Style.space(2)

          Text {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            textFormat: Text.PlainText
            text: tile.modelData.name
            color: root.foreground
            font.family: root.fontFamily
            font.pixelSize: Style.font.caption
            font.bold: tile.modelData.self
            elide: Text.ElideRight
          }

          Text {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            textFormat: Text.PlainText
            text: tile.modelData.self ? Commons.I18n.t("reach.thisMachine")
              : tile.modelData.online === false ? Commons.I18n.t("reach.offline")
              : !tile.modelData.connected ? Commons.I18n.t("reach.notConnected") : ""
            visible: text !== ""
            color: root.dim
            font.family: root.fontFamily
            font.pixelSize: Style.font.caption
            elide: Text.ElideRight
          }
        }

        // Take a machine out from its tile. This one always stays.
        PanelActionButton {
          visible: !tile.modelData.self && (tileMouse.containsMouse || hot || tile.picked)
          property bool hot: false
          anchors.top: parent.top
          anchors.right: parent.right
          anchors.margins: Style.space(2)
          size: Style.space(18)
          fontSize: Style.font.caption
          iconText: "×"
          tooltipText: Commons.I18n.t("reach.remove")
          foreground: root.foreground
          hoverColor: root.bar ? root.bar.urgent : Commons.Color.urgent
          fontFamily: root.fontFamily
          enabled: !root.busy
          onHovered: function(on) { hot = on }
          onClicked: root.remove(tile.modelData.name)
        }

        MouseArea {
          id: tileMouse
          readonly property bool canDrag: map.count > 1 && !root.busy
          anchors.fill: parent
          z: -1
          hoverEnabled: true
          cursorShape: !canDrag ? Qt.ArrowCursor : (pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor)
          preventStealing: true
          onEntered: root.selectTile(tile.modelData.name)
          onPressed: function(mouse) { tile.pressX = mapToItem(map, mouse.x, mouse.y).x }
          onPositionChanged: function(mouse) {
            if (!canDrag || !pressed) return
            tile.dragX = mapToItem(map, mouse.x, mouse.y).x - tile.pressX
          }
          onReleased: {
            var moved = Math.abs(tile.dragX) > 3
            var center = tile.x + tile.width / 2
            tile.dragX = 0
            if (!moved) return
            var centers = []
            for (var i = 0; i < map.count; i++) centers.push(map.centerOf(i))
            root.moveTo(tile.modelData.name, Model.dropIndex(centers, tile.index, center))
          }
          onCanceled: tile.dragX = 0
        }
      }
    }
  }

  component AddRow: CursorSurface {
    id: addRow
    property var peer: null
    property int rowIndex: 0

    hasCursor: root.cursorActive && root.focusSection === "add" && root.addIndex === rowIndex
    foreground: root.foreground
    implicitHeight: addContent.implicitHeight + Style.spacing.rowPaddingX

    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      onEntered: {
        root.cursorActive = true
        root.focusSection = "add"
        root.addIndex = addRow.rowIndex
      }
    }

    RowLayout {
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      anchors.leftMargin: Style.space(10)
      anchors.rightMargin: Style.space(6)
      spacing: Style.space(10)

      Rectangle {
        Layout.alignment: Qt.AlignVCenter
        implicitWidth: Style.space(8)
        implicitHeight: implicitWidth
        radius: width / 2
        color: addRow.peer && addRow.peer.online ? root.foreground : "transparent"
        border.color: addRow.peer && addRow.peer.online ? root.foreground : root.dim
        border.width: 1
      }

      ColumnLayout {
        id: addContent
        Layout.fillWidth: true
        spacing: Style.space(1)
        opacity: addRow.peer && addRow.peer.online ? 1.0 : 0.55

        Text {
          textFormat: Text.PlainText
          Layout.fillWidth: true
          text: addRow.peer ? addRow.peer.name : ""
          color: root.foreground
          font.family: root.fontFamily
          font.pixelSize: Style.font.body
          elide: Text.ElideRight
        }

        Text {
          textFormat: Text.PlainText
          Layout.fillWidth: true
          text: !addRow.peer ? ""
            : addRow.peer.nearby ? Commons.I18n.t("reach.closeBy")
            : addRow.peer.online ? Commons.I18n.t("reach.online") : Commons.I18n.t("reach.offline")
          color: root.dim
          font.family: root.fontFamily
          font.pixelSize: Style.font.caption
          elide: Text.ElideRight
        }
      }

      PanelActionButton {
        iconText: "←"
        tooltipText: Commons.I18n.t("reach.addLeft")
        foreground: root.foreground
        fontFamily: root.fontFamily
        enabled: !root.busy
        onClicked: root.place(addRow.peer.name, "left")
      }

      PanelActionButton {
        iconText: "→"
        tooltipText: Commons.I18n.t("reach.addRight")
        foreground: root.foreground
        fontFamily: root.fontFamily
        enabled: !root.busy
        onClicked: root.place(addRow.peer.name, "right")
      }
    }
  }
}
