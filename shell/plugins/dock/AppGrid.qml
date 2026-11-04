import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Commons as Commons
import qs.Ui

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
  // Apps installed or removed while the grid is closed are picked up when it
  // next opens.
  property bool appsStale: false

  // The search line is a TextInput; keep it showing what the filter holds when
  // the grid clears or resets the filter itself.
  onFilterTextChanged: if (filterInput.text !== root.filterText) filterInput.text = root.filterText

  readonly property int iconSize: Math.round(56 * Style.fontScale)
  // A name wraps to two lines at most; a cell always has room for both so the
  // icons of a row line up whatever their names are.
  readonly property int labelHeight: Math.ceil(labelMetrics.height) * 2
  readonly property int labelGap: Style.spacing.md
  // The gap between neighbouring tiles, and the air above and below a tile's
  // content. The selected tile hugs its own icon and name, so it is padded
  // evenly on every side whether the name takes one line or two.
  readonly property int cellGutter: Style.spacing.sm
  readonly property int tilePaddingY: Style.spacing.xl
  readonly property int cellWidth: Math.round(iconSize * 2.2)
  readonly property int cellHeight: cellGutter * 2 + tilePaddingY * 2 + iconSize + labelGap + labelHeight
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
  // Like the menu, the grid ends mid-row: the next row peeks in below the last
  // whole one, cut through its icons and faded by the scrim, which tells the
  // eye there is more below the fold. A screen too short for that just cuts a row where it ends.
  readonly property int rowPeek: cellGutter + tilePaddingY + Math.round(iconSize * 0.75)
  readonly property int cardHeight: Math.min(panel.height - screenMargin * 2, inset * 2 + headerHeight + headerSpacing + visibleRows * cellHeight + rowPeek)

  function open() {
    root.selectedIndex = 0
    pointerGate.reset()
    if (root.appLibrary) root.appLibrary.refreshIcons()
    // The cells from last time are reused when nothing changed, so the grid
    // opens with its icons already drawn.
    if (root.appsStale || root.filterText !== "" || root.apps.length === 0) {
      root.filterText = ""
      root.rebuild(true)
    } else {
      grid.positionViewAtBeginning()
    }
    root.opened = true
    root.focusSearch()
  }

  function focusSearch() {
    Qt.callLater(function() { filterInput.forceActiveFocus() })
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
    root.focusSearch()
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

  // Fills the grid from the library. A new search starts from the top; an app
  // list that changed under an open grid keeps the user where they were.
  function rebuild(fromTop) {
    root.appsStale = false
    var rows = root.appLibrary ? root.appLibrary.sortedEntries(root.filterText) : []
    root.apps = rows.map(function(row) { return row.entry })
    root.selectedIndex = Math.max(0, Math.min(root.selectedIndex, root.apps.length - 1))
    if (fromTop) {
      grid.positionViewAtBeginning()
    } else {
      // The view settles on its new size first, then keeps the selection in sight.
      Qt.callLater(function() {
        grid.returnToBounds()
        root.revealIndex(root.selectedIndex)
      })
    }
  }

  // Contain alone parks the selected row flush with the viewport edge, hiding
  // its neighbour entirely and losing the fold. Keep the next hidden row
  // peeking past the selection in the direction of travel, as the menu does.
  function revealIndex(index) {
    if (index < 0 || index >= root.apps.length) return
    grid.positionViewAtIndex(index, GridView.Contain)

    var item = grid.itemAtIndex(index)
    if (!item) return

    var row = Math.floor(index / root.columns)
    var lastRow = Math.floor((root.apps.length - 1) / root.columns)
    if (row < lastRow) {
      var maxY = Math.max(grid.originY, grid.originY + grid.contentHeight - grid.height)
      var overhang = item.y + item.height + root.rowPeek - (grid.contentY + grid.height)
      if (overhang > 0) grid.contentY = Math.min(grid.contentY + overhang, maxY)
    }
    if (row > 0) {
      var underhang = grid.contentY - (item.y - root.rowPeek)
      if (underhang > 0) grid.contentY = Math.max(grid.contentY - underhang, grid.originY)
    }
  }

  function setFilter(text) {
    root.filterText = text
    root.selectedIndex = 0
    root.menuEntry = null
    pointerGate.reset()
    root.rebuild(true)
  }

  // Moves the keyboard selection. The grid scrolls under a pointer that has
  // not moved, so the gate is reset to keep that from reselecting a cell.
  function selectIndex(index) {
    if (root.apps.length === 0) return
    root.selectedIndex = Math.max(0, Math.min(root.apps.length - 1, index))
    pointerGate.reset()
    root.revealIndex(root.selectedIndex)
  }

  function select(delta) {
    root.selectIndex(root.selectedIndex + delta)
  }

  // Up and Down stop at the top and bottom rows rather than jumping to the
  // first or last app. A move that would leave the grid goes as far as it can:
  // below a short last row, to its last app; above, to the first row in the
  // same column.
  function selectRows(rows) {
    var count = root.apps.length
    if (count === 0) return
    var row = Math.floor(root.selectedIndex / root.columns)
    var target = root.selectedIndex + rows * root.columns
    if (target < 0) {
      if (row === 0) return
      target = root.selectedIndex % root.columns
    } else if (target > count - 1) {
      if (row >= Math.floor((count - 1) / root.columns)) return
      target = count - 1
    }
    root.selectIndex(target)
  }

  function selectFromPointer(index, item, mouse) {
    if (root.dragging || !pointerGate.moved(item, mouse)) return
    root.selectedIndex = index
  }

  readonly property int pageRows: Math.max(1, root.visibleRows - 1)

  function launch(index) {
    var entry = root.apps[index]
    if (!entry || !root.appLibrary) return
    root.close()
    if (root.dock) root.dock.launchEntry(entry)
    else root.appLibrary.launch(entry.id, root.appLibrary.entryName(entry))
  }

  FontMetrics {
    id: labelMetrics
    font.family: Style.font.menuFamily
    font.pixelSize: Style.font.body
  }

  PointerMoveGate {
    id: pointerGate
    referenceItem: card
  }

  Connections {
    target: root.appLibrary
    function onAppsChanged() {
      if (root.opened) root.rebuild(false)
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

      Behavior on opacity {
        id: scrimFade
        NumberAnimation { duration: Style.duration(scrimFade.targetValue > 0 ? 150 : 100); easing.type: Easing.OutCubic }
      }
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

      Behavior on opacity {
        id: cardFade
        NumberAnimation { duration: Style.duration(cardFade.targetValue > 0 ? 150 : 100); easing.type: Easing.OutCubic }
      }

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

        // Focus is on filterInput, which forwards every key here first. What
        // is left unaccepted is typed into the search line.
        Keys.onPressed: function(event) {
          if (root.uninstallEntry) {
            // Swallow the rest too, or it would type into the search line behind the dialog.
            uninstallConfirm.handleKey(event)
            event.accepted = true
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
            root.selectRows(-1)
          } else if (event.key === Qt.Key_Down) {
            root.selectRows(1)
          } else if (event.key === Qt.Key_PageUp) {
            root.selectRows(-root.pageRows)
          } else if (event.key === Qt.Key_PageDown) {
            root.selectRows(root.pageRows)
          } else if (event.key === Qt.Key_Home) {
            root.selectIndex(0)
          } else if (event.key === Qt.Key_End) {
            root.selectIndex(root.apps.length - 1)
          } else if (event.key === Qt.Key_Tab) {
            root.select(1)
          } else if (event.key === Qt.Key_Backtab) {
            root.select(-1)
          } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            root.launch(root.selectedIndex)
          } else if (event.text === " " && !root.filterText) {
            // A search never starts with a space; it would hide the hint
            // and match nothing new.
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
            id: searchGlyph
            anchors.left: parent.left
            anchors.leftMargin: Style.spacing.controlPaddingX
            anchors.verticalCenter: parent.verticalCenter
            textFormat: Text.PlainText
            text: "󰍉"
            color: Commons.Color.menu.text
            opacity: 0.58
            font.family: Style.font.family
            font.pixelSize: Style.font.heading
          }

          // A TextInput, not a Text fed by key events: input methods (fcitx5
          // composing Japanese, Chinese or Korean) only reach text-input items.
          FilterInput {
            id: filterInput
            anchors.left: searchGlyph.right
            anchors.leftMargin: Style.spacing.md
            anchors.right: parent.right
            anchors.rightMargin: Style.spacing.controlPaddingX
            anchors.verticalCenter: parent.verticalCenter
            keyHandler: keyCatcher
            // Input-method commits bypass key handling, so the dialog has to refuse them here.
            readOnly: !!root.uninstallEntry
            color: Commons.Color.menu.text
            font.family: Style.font.menuFamily
            font.pixelSize: Style.font.heading
            onTextChanged: if (text !== root.filterText) root.setFilter(text)
          }

          Text {
            anchors.fill: filterInput
            verticalAlignment: Text.AlignVCenter
            visible: !root.filterText && !filterInput.preeditText
            textFormat: Text.PlainText
            text: Commons.I18n.t("dock.searchApps")
            color: Commons.Color.menu.text
            opacity: 0.58
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

            // The menu's wheel: pixels for a touchpad, a row a notch for a mouse.
            WheelHandler {
              target: null
              onWheel: function(event) {
                var delta = event.pixelDelta.y || event.angleDelta.y / 120 * root.cellHeight
                var bottom = grid.originY + Math.max(0, grid.contentHeight - grid.height)
                grid.contentY = Math.max(grid.originY, Math.min(bottom, grid.contentY - delta))
                event.accepted = true
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

              // The selection is a tile around the icon and the name. It ends
              // where the name does, so a one-line name is padded the same
              // below as the icon is above, not out to the edge of the cell.
              Rectangle {
                id: tile
                x: root.cellGutter
                y: root.cellGutter
                width: cell.width - root.cellGutter * 2
                height: root.tilePaddingY * 2 + root.iconSize + root.labelGap + Math.ceil(label.contentHeight)
                radius: Style.cornerRadius
                color: cell.selected ? Commons.Color.menu.selectedBackground : "transparent"
              }

              Image {
                id: icon
                anchors.horizontalCenter: parent.horizontalCenter
                y: tile.y + root.tilePaddingY
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
                // The icon gives a little under the press, then comes back.
                scale: cellMouse.pressed && !cell.moved ? 0.92 : 1
                Behavior on scale {
                  id: pressScale
                  NumberAnimation { duration: Style.duration(pressScale.targetValue < 1 ? 80 : 140); easing.type: Easing.OutCubic }
                }
              }

              Text {
                id: label
                anchors.top: icon.bottom
                anchors.topMargin: root.labelGap
                anchors.horizontalCenter: parent.horizontalCenter
                width: tile.width - Style.spacing.md * 2
                textFormat: Text.PlainText
                text: root.appLibrary ? root.appLibrary.entryName(cell.modelData) : ""
                color: cell.selected ? Commons.Color.menu.selectedText : Commons.Color.menu.text
                font.family: Style.font.menuFamily
                font.pixelSize: Style.font.body
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignTop
                // Breaks between words when it can, and inside a long one when
                // it must, so an unbroken name never runs past its tile.
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                maximumLineCount: 2
                elide: Text.ElideRight
              }

              MouseArea {
                id: cellMouse
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
                // Hover selects only when the pointer itself moves. Cells that
                // scroll or rebuild under a resting pointer would otherwise
                // pull the selection away from the keyboard.
                onPositionChanged: function(event) {
                  if (!(pressedButtons & Qt.LeftButton)) {
                    root.selectFromPointer(cell.index, cellMouse, event)
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
                    root.selectedIndex = cell.index
                    root.openMenu(cell.modelData, cell.mapToItem(panel.contentItem, event.x, event.y))
                    return
                  }
                  root.menuEntry = null
                  root.launch(cell.index)
                }
              }
            }
          }

          // Scroll scrims, as in the menu. The clipped row marks the fold at
          // rest; these keep both edges honest once the grid has been scrolled
          // and rows hide above as well as below. Strength tracks the distance
          // still hidden past each edge rather than a clock, so a jump lands
          // with the fade already applied.
          Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: Math.min(Style.space(28), parent.height / 2)
            visible: opacity > 0
            opacity: grid.contentHeight > grid.height
              ? Math.max(0, Math.min(1, (grid.contentY - grid.originY) / height))
              : 0
            gradient: Gradient {
              GradientStop { position: 0; color: Commons.Color.menu.background }
              GradientStop { position: 1; color: Util.alpha(Commons.Color.menu.background, 0) }
            }
          }

          Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: Math.min(Style.space(28), parent.height / 2)
            visible: opacity > 0
            opacity: grid.contentHeight > grid.height
              ? Math.max(0, Math.min(1, (grid.originY + grid.contentHeight - grid.height - grid.contentY) / height))
              : 0
            gradient: Gradient {
              GradientStop { position: 0; color: Util.alpha(Commons.Color.menu.background, 0) }
              GradientStop { position: 1; color: Commons.Color.menu.background }
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
