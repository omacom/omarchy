import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Commons as Commons
import qs.Ui
import "DockModel.js" as DockModel

// Every app on one grid. Type to narrow it, arrows to move, Enter to launch.
Item {
  id: root

  property var appLibrary: null
  property var dock: null

  property bool opened: false
  // While an app is dragged out toward the dock, the grid steps aside so the
  // dock shows through, and the app's icon follows the pointer. The grid keeps
  // the pointer for as long as the button is held, and tells the dock where it
  // is.
  property bool dragging: false
  property var dragEntry: null
  property point dragPoint
  // The app waiting on the user to confirm uninstalling it.
  property var uninstallEntry: null
  // The app whose menu is open, and where it opened.
  property var menuEntry: null
  property point menuPoint
  property string filterText: ""
  property int selectedIndex: 0
  property var apps: []
  // The ring glides only to a neighbouring cell; opening, filtering, wrapping
  // to another row, the pointer and longer jumps snap it into place.
  property bool ringSnap: true
  // Where the pointer last was, so hovering selects only when the pointer
  // itself moved, never when the grid scrolls under a pointer at rest.
  property var lastPointer: null

  // The accent marks the selection, unless the theme's accent is too faint
  // against the card to see.
  readonly property color ringColor: {
    var c = DockModel.selectionRingColor(Commons.Color.accent, Commons.Color.menu.text, Commons.Color.menu.background, 0.9)
    return Qt.rgba(c.r, c.g, c.b, c.a)
  }

  readonly property int iconSize: Math.round(56 * Style.fontScale)
  readonly property int labelHeight: Math.ceil(labelMetrics.height) * 2
  readonly property int cellGutter: Style.spacing.sm
  readonly property int cellPadding: Style.spacing.lg
  readonly property int cellWidth: Math.round(iconSize * 2.2)
  readonly property int cellHeight: cellPadding * 2 + iconSize + Style.spacing.md + labelHeight
  readonly property int maxColumns: 7
  readonly property int visibleRows: 4
  readonly property int borderWidth: Math.max(1, Style.space(2))
  readonly property int contentMargin: Style.spacing.panelPadding
  readonly property int inset: contentMargin + borderWidth
  readonly property int headerHeight: Math.max(Style.space(36), Style.font.heading + Style.spacing.controlPaddingY * 2)
  readonly property int headerSpacing: Style.spacing.xl
  readonly property int screenMargin: Style.space(40)

  // The card fits whole columns, and the grid sits centered in it so any
  // leftover width splits evenly on both sides.
  readonly property int cardWidth: Math.min(panel.width - screenMargin * 2, maxColumns * cellWidth + inset * 2)
  readonly property int columns: Math.max(1, Math.floor((cardWidth - inset * 2) / cellWidth))
  readonly property int gridWidth: columns * cellWidth
  readonly property int cardHeight: Math.min(panel.height - screenMargin * 2, inset * 2 + headerHeight + headerSpacing + visibleRows * cellHeight)

  function open() {
    root.lastPointer = null
    root.moveTo(0, "reset")
    if (root.appLibrary) root.appLibrary.refreshIcons()
    // The cells from last time are reused when nothing changed, so the grid
    // opens with its icons already drawn.
    if (root.appsStale || root.filterText !== "" || root.apps.length === 0) {
      root.filterText = ""
      root.rebuild()
    } else {
      grid.positionViewAtBeginning()
    }
    root.opened = true
    Qt.callLater(function() { keyCatcher.forceActiveFocus() })
  }

  function close() {
    if (root.dragging && root.dock) root.dock.endExternalDrag()
    root.opened = false
    root.uninstallEntry = null
    root.dragging = false
    root.dragEntry = null
    root.menuEntry = null
  }

  function dragTo(entry, point) {
    if (!root.dragging) {
      root.menuEntry = null
      root.dragEntry = entry
      root.dragging = true
    }
    root.dragPoint = point
    if (root.dock) root.dock.moveExternalDrag(panel.screen, point.x, point.y)
  }

  function dropDrag() {
    var entry = root.dragEntry
    if (entry && root.dock) root.dock.dropExternalDrag(panel.screen, root.dragPoint.x, root.dragPoint.y, String(entry.id || ""))
    root.close()
  }

  function requestUninstall(entry) {
    if (!entry) return
    root.menuEntry = null
    uninstallConfirm.selectedIndex = 1
    root.uninstallEntry = entry
  }

  function cancelUninstall() {
    root.uninstallEntry = null
    Qt.callLater(function() { keyCatcher.forceActiveFocus() })
  }

  function confirmUninstall() {
    var entry = root.uninstallEntry
    root.uninstallEntry = null
    root.close()
    if (entry && root.appLibrary) root.appLibrary.remove(entry.id, root.appLibrary.entryName(entry))
  }

  function openMenu(entry, point) {
    root.menuEntry = entry
    root.menuPoint = point
  }

  function toggle() {
    if (root.opened) root.close()
    else root.open()
  }

  function rebuild() {
    root.appsStale = false
    var rows = root.appLibrary ? root.appLibrary.sortedEntries(root.filterText) : []
    root.apps = rows.map(function(row) { return row.entry })
    root.moveTo(root.selectedIndex, "reset")
    grid.positionViewAtBeginning()
  }

  function setFilter(text) {
    root.filterText = text
    root.moveTo(0, "reset")
    root.rebuild()
  }

  function select(delta) {
    if (root.apps.length === 0) return
    root.moveTo(root.selectedIndex + delta, "key")
    grid.positionViewAtIndex(root.selectedIndex, GridView.Contain)
  }

  // Every selection change comes through here. kind is "key", "pointer" or
  // "reset"; only a key press to a neighbouring cell lets the ring glide.
  function moveTo(index, kind) {
    var target = Math.max(0, Math.min(root.apps.length - 1, index))
    root.ringSnap = kind !== "key" || !DockModel.isGridStep(root.selectedIndex, target, root.columns)
    root.selectedIndex = target
    if (root.ringSnap) Qt.callLater(function() { root.ringSnap = false })
  }

  // Hover selects only when the pointer moved a pixel from where it last
  // counted; slower movement adds up until it does. The first report after
  // opening just notes where it is, and the uninstall prompt and the app menu
  // hold the selection on the app they name.
  function hoverAt(index, point) {
    var last = root.lastPointer
    if (last && !DockModel.pointerMoved(last, point)) return
    root.lastPointer = point
    if (!last || root.dragging || root.uninstallEntry || root.menuEntry) return
    if (index !== root.selectedIndex) root.moveTo(index, "pointer")
  }

  function launch(index) {
    var entry = root.apps[index]
    if (!entry || !root.appLibrary) return
    root.close()
    if (root.dock) root.dock.launchEntry(entry)
    else root.appLibrary.launch(entry.id, root.appLibrary.entryName(entry))
  }

  // A new column count (another screen, a resized card) moves every cell, so
  // the ring follows without a glide.
  onColumnsChanged: {
    root.ringSnap = true
    Qt.callLater(function() { root.ringSnap = false })
  }

  FontMetrics {
    id: labelMetrics
    font.family: Style.font.menuFamily
    font.pixelSize: Style.font.body
  }

  // Apps installed or removed while the grid is closed are picked up when it
  // next opens.
  property bool appsStale: false

  Connections {
    target: root.appLibrary
    function onAppsChanged() {
      if (root.opened) root.rebuild()
      else root.appsStale = true
    }
  }

  OverlayWindow {
    id: panel
    shown: root.opened
    WlrLayershell.namespace: "omarchy-dock-apps"
    Rectangle {
      anchors.fill: parent
      color: Commons.Color.menu.scrim
      opacity: root.dragging ? 0 : 1

      Behavior on opacity { NumberAnimation { duration: 150 } }
    }

    MouseArea {
      anchors.fill: parent
      acceptedButtons: Qt.LeftButton | Qt.RightButton
      onClicked: {
        if (root.menuEntry) root.menuEntry = null
        else root.close()
      }
    }

    BorderSurface {
      id: card
      width: root.cardWidth
      height: root.cardHeight
      anchors.centerIn: parent
      radius: Style.cornerRadius
      color: Commons.Color.menu.background
      borderSpec: Border.surfaceSpec("menu", "border", Commons.Color.menu.border, root.borderWidth)
      padding: root.contentMargin
      opacity: root.dragging ? 0 : 1

      Behavior on opacity { NumberAnimation { duration: 150 } }

      MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: root.menuEntry = null
      }

      ConfirmDialog {
        id: uninstallConfirm

        anchors.fill: parent
        opened: !!root.uninstallEntry
        z: 10
        message: Commons.I18n.t("common.uninstallConfirm").arg(root.uninstallEntry && root.appLibrary ? root.appLibrary.entryName(root.uninstallEntry) : "")
        confirmText: Commons.I18n.t("common.uninstall")
        background: Commons.Color.menu.background
        foreground: Commons.Color.menu.text
        scrim: Commons.Color.menu.scrim
        selectedBackground: Commons.Color.menu.selectedBackground
        selectedText: Commons.Color.menu.selectedText
        fontFamily: Style.font.menuFamily
        cornerRadius: Style.cornerRadius
        onCanceled: root.cancelUninstall()
        onConfirmed: root.confirmUninstall()
      }

      Item {
        id: keyCatcher
        anchors.fill: parent
        focus: true

        Keys.priority: Keys.BeforeItem
        Keys.onPressed: function(event) {
          if (root.uninstallEntry) {
            if (uninstallConfirm.handleKey(event)) event.accepted = true
            return
          }
          if (event.key === Qt.Key_Delete) {
            root.requestUninstall(root.apps[root.selectedIndex])
          } else if (event.key === Qt.Key_Escape) {
            if (root.menuEntry) root.menuEntry = null
            else if (root.filterText) root.setFilter("")
            else root.close()
          } else if (Util.editsFilter(event, root.filterText)) {
            root.setFilter(Util.editedFilter(event, root.filterText))
          } else if (Util.readingKey(event) === Qt.Key_Left) {
            root.select(-1)
          } else if (Util.readingKey(event) === Qt.Key_Right) {
            root.select(1)
          } else if (event.key === Qt.Key_Up) {
            root.select(-root.columns)
          } else if (event.key === Qt.Key_Down) {
            root.select(root.columns)
          } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            root.launch(root.selectedIndex)
          } else if (event.text && event.text.length === 1 && event.text.charCodeAt(0) >= 32 && event.text.charCodeAt(0) !== 127) {
            root.setFilter(root.filterText + event.text)
          } else {
            return
          }
          event.accepted = true
        }
      }

      Column {
        width: root.gridWidth
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.topMargin: card.contentTopInset
        anchors.bottomMargin: card.contentBottomInset
        spacing: root.headerSpacing

        Rectangle {
          x: root.cellGutter
          width: parent.width - root.cellGutter * 2
          height: root.headerHeight
          radius: Style.cornerRadius
          color: Util.alpha(Commons.Color.menu.text, 0.06)

          Text {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: Style.spacing.controlPaddingX
            anchors.rightMargin: Style.spacing.controlPaddingX
            anchors.verticalCenter: parent.verticalCenter
            textFormat: Text.PlainText
            text: root.filterText || Commons.I18n.t("dock.searchApps")
            color: Commons.Color.menu.text
            opacity: root.filterText ? 1 : 0.58
            font.family: Style.font.menuFamily
            font.pixelSize: Style.font.heading
            elide: Text.ElideRight
          }
        }

        Item {
          width: parent.width
          height: parent.height - root.headerHeight - parent.spacing

          GridView {
            id: grid
            anchors.fill: parent
            model: root.apps
            clip: true
            cellWidth: root.cellWidth
            cellHeight: root.cellHeight
            boundsBehavior: Flickable.StopAtBounds

            // The selection ring frames the whole cell. It lives in the grid's
            // content, so it scrolls with the apps.
            Rectangle {
              id: ring
              // Declared here, but parented to the content explicitly: a plain
              // child of a GridView stays put while the apps scroll.
              parent: grid.contentItem
              readonly property var origin: DockModel.gridCellOrigin(root.selectedIndex, root.columns, root.cellWidth, root.cellHeight, root.cellGutter, grid.effectiveLayoutDirection === Qt.RightToLeft)
              x: origin.x
              y: origin.y
              z: 1
              width: root.cellWidth - root.cellGutter * 2
              height: root.cellHeight - root.cellGutter * 2
              visible: root.apps.length > 0
              color: "transparent"
              radius: Style.cornerRadius
              border.color: root.ringColor
              border.width: root.borderWidth

              Behavior on x {
                enabled: !root.ringSnap
                NumberAnimation { duration: Style.duration(140); easing.type: Easing.OutCubic }
              }
              Behavior on y {
                enabled: !root.ringSnap
                NumberAnimation { duration: Style.duration(140); easing.type: Easing.OutCubic }
              }
            }

            delegate: Item {
              id: cell

              required property int index
              required property var modelData
              readonly property bool selected: index === root.selectedIndex
              property point pressPoint
              // A press that wanders is a drag in the making, not a click.
              property bool moved: false

              width: root.cellWidth
              height: root.cellHeight

              Image {
                id: icon
                anchors.horizontalCenter: parent.horizontalCenter
                y: root.cellPadding
                width: root.iconSize
                height: root.iconSize
                sourceSize: Qt.size(root.iconSize * 2, root.iconSize * 2)
                source: root.appLibrary ? root.appLibrary.iconSource(cell.modelData.icon) : ""
                fillMode: Image.PreserveAspectFit
                // Loaded with the cell, from Qt's image cache after the first
                // open, so icons do not pop in after the grid has appeared.
                asynchronous: false
                smooth: true
                mipmap: true
                // The selected app's icon lifts a little, as the dock's do on hover.
                scale: cell.selected ? 1.08 : 1

                Behavior on scale { NumberAnimation { duration: Style.duration(120); easing.type: Easing.OutCubic } }
              }

              Text {
                id: label
                anchors.top: icon.bottom
                anchors.topMargin: Style.spacing.md
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - (root.cellGutter + Style.spacing.md) * 2
                textFormat: Text.PlainText
                text: root.appLibrary ? root.appLibrary.entryName(cell.modelData) : ""
                color: Commons.Color.menu.text
                font.family: Style.font.menuFamily
                font.pixelSize: Style.font.body
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignTop
                wrapMode: Text.Wrap
                maximumLineCount: 2
                elide: Text.ElideRight
              }

              MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                // The grid would otherwise take a dragging press for a scroll.
                preventStealing: true
                onPressed: function(event) {
                  cell.moved = false
                  cell.pressPoint = Qt.point(event.x, event.y)
                }
                onPositionChanged: function(event) {
                  if (!(pressedButtons & Qt.LeftButton)) {
                    root.hoverAt(cell.index, cell.mapToItem(panel.contentItem, event.x, event.y))
                    return
                  }
                  if (!cell.moved && Math.hypot(event.x - cell.pressPoint.x, event.y - cell.pressPoint.y) > Style.space(4)) cell.moved = true
                  if (cell.moved) root.dragTo(cell.modelData, cell.mapToItem(panel.contentItem, event.x, event.y))
                }
                onReleased: function(event) {
                  if (root.dragging && event.button === Qt.LeftButton) root.dropDrag()
                }
                onCanceled: if (root.dragging) root.close()
                onClicked: function(event) {
                  if (cell.moved) return
                  if (event.button === Qt.RightButton) {
                    root.moveTo(cell.index, "pointer")
                    root.openMenu(cell.modelData, cell.mapToItem(panel.contentItem, event.x, event.y))
                    return
                  }
                  root.menuEntry = null
                  root.launch(cell.index)
                }
              }
            }
          }

          Text {
            anchors.centerIn: parent
            visible: root.apps.length === 0
            textFormat: Text.PlainText
            text: Commons.I18n.t("dock.noAppsMatch").arg(root.filterText)
            color: Commons.Color.menu.text
            opacity: 0.7
            font.family: Style.font.menuFamily
            font.pixelSize: Style.font.title
          }
        }
      }
    }
    // The dragged app's icon, under the pointer.
    Image {
      visible: root.dragging && !!root.dragEntry
      x: root.dragPoint.x - width / 2
      y: root.dragPoint.y - height / 2
      width: root.iconSize
      height: root.iconSize
      sourceSize: Qt.size(root.iconSize * 2, root.iconSize * 2)
      source: root.dragEntry && root.appLibrary ? root.appLibrary.iconSource(root.dragEntry.icon) : ""
      fillMode: Image.PreserveAspectFit
      smooth: true
      mipmap: true
    }

    // Right-click on an app: open it, or keep it in the dock or take it out.
    BorderSurface {
      id: menu

      readonly property var entry: root.menuEntry
      readonly property bool pinned: !!entry && !!root.dock && root.dock.isPinned(String(entry.id || ""))

      visible: !!entry && !root.dragging
      width: Math.max(Style.space(160), menuColumn.implicitWidth) + padding * 2
      height: menuColumn.implicitHeight + padding * 2
      // Opens along the reading direction from the pointer.
      x: LayoutMirroring.enabled
        ? Math.max(Style.gapsOut, root.menuPoint.x - width)
        : Math.min(root.menuPoint.x, panel.width - width - Style.gapsOut)
      y: Math.min(root.menuPoint.y, panel.height - height - Style.gapsOut)
      radius: Style.cornerRadius
      color: Commons.Color.popups.background
      borderSpec: Border.surfaceSpec("popups", "border", Commons.Color.popups.border, Style.normalBorderWidth)
      padding: Style.spacing.sm

      Column {
        id: menuColumn
        x: menu.contentLeftInset
        y: menu.contentTopInset
        width: menu.width - menu.contentLeftInset - menu.contentRightInset

        MenuRow {
          text: Commons.I18n.t("dock.open")
          onTriggered: {
            var entry = menu.entry
            root.close()
            if (entry && root.dock) root.dock.launchEntry(entry)
            else if (entry && root.appLibrary) root.appLibrary.launch(entry.id, root.appLibrary.entryName(entry))
          }
        }

        MenuRow {
          visible: !!root.dock
          text: menu.pinned ? Commons.I18n.t("dock.removeFromDock") : Commons.I18n.t("dock.keepInDock")
          onTriggered: {
            if (root.dock && menu.entry) root.dock.setPinned(String(menu.entry.id || ""), !menu.pinned)
            root.menuEntry = null
          }
        }

        MenuRow {
          text: Commons.I18n.t("dock.uninstall")
          onTriggered: root.requestUninstall(menu.entry)
        }
      }
    }
  }

  component MenuRow: Rectangle {
    id: row

    property string text: ""
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

    MouseArea {
      id: rowMouse
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onClicked: row.triggered()
    }
  }
}
