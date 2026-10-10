import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import qs.Commons
import qs.Commons as Commons
import qs.Ui
import "EmojiSearch.js" as EmojiSearch

Item {
  id: root

  property string omarchyPath: Quickshell.env("OMARCHY_PATH")
  property var shell: null
  property var manifest: null

  property bool opened: false
  property string filterText: ""
  property int selectedIndex: 0
  property bool cursorActive: false
  property var emojis: []

  // Shares the [menu] surface tokens — themes that style the menu also
  // style emojis. Selected-cell colors composed in the
  // singleton so consumers drop them straight into Rectangle bindings.
  property color background: Commons.Color.menu.background
  property color foreground: Commons.Color.menu.text
  property color border: Commons.Color.menu.border
  property var borderSpec: Border.surfaceSpec("menu", "border", border, Math.max(1, Style.space(2)))
  property color scrim: Commons.Color.menu.scrim
  property color selectedBackground: Commons.Color.menu.selectedBackground
  property color selectedText: Commons.Color.menu.selectedText
  readonly property int cornerRadius: Style.cornerRadius
  property string fontFamily: Style.font.menuFamily
  property int contentMargin: Style.spacing.panelPadding
  property int headerHeight: Math.max(Style.space(34), Style.font.title + Style.spacing.controlPaddingY * 2)
  property int contentSpacing: Style.spacing.md
  property int cardWidth: Math.min(Style.space(400), panel.width - Style.gapsOut * 2)
  property int cardHeight: Math.min(Style.space(500), panel.height - Style.gapsOut * 2)

  property int cellWidth: Math.max(Style.space(44), Style.font.display + Style.spacing.md)
  property int cellHeight: Math.max(Style.space(44), Style.font.display + Style.spacing.md)
  property int columns: Math.floor((cardWidth - contentMargin * 2) / cellWidth)
  // The card is measured only once visible; rebuild so the top rows fit.
  onColumnsChanged: if (opened) rebuildDisplay()

  // [emoji, …] — the pinned list, in file order, shown above everything else.
  property var favorites: []
  // The grid as EmojiSearch.buildCells laid it out — what the cursor moves over.
  property var cells: []
  // The file is read asynchronously, so a pin can arrive before the list it belongs
  // to has been read: saving then would replace the user's favorites with whatever
  // is in memory. Nothing is written until a read reports back, and a file we could
  // not read or parse is never replaced — only a missing one (a first run) is.
  property bool favoritesReady: false
  property int favoritesLoadError: FileViewError.Success
  property bool favoritesWritable: false
  // Every local change moves the list past any read that was asked for before it,
  // so a read that a pin overtook can be told apart from one that has not been.
  property int favoritesRevision: 0
  property int favoritesReadRevision: -1
  readonly property bool favoritesSavable: root.favoritesReady && root.favoritesWritable

  // Click-and-hold on a pinned cell moves it. The grid is left alone for the
  // whole gesture, so the cell the pointer grabbed stays alive until the drop.
  property bool dragging: false
  property string dragEmoji: ""
  property int dragTo: -1
  property real dragX: 0
  property real dragY: 0
  property var dragOrigin: ({ x: 0, y: 0 })
  property bool dragMoved: false
  // A drag ends with a release, and Qt follows that with a click.
  property bool suppressClick: false

  function open(payloadJson) {
    root.opened = true
    root.filterText = ""
    root.selectedIndex = 0
    root.cursorActive = true
    // Read on open as well as on change: an edit made before the picker opened is
    // picked up here, and one made while it is open is picked up by the watcher.
    root.readFavorites()
    root.rebuildDisplay()
    Qt.callLater(function() { keyCatcher.forceActiveFocus() })
  }

  function close() {
    root.opened = false
  }

  function dismiss() {
    root.opened = false
    if (root.shell && typeof root.shell.hide === "function")
      root.shell.hide((root.manifest && root.manifest.id) || "omarchy.emojis")
  }

  function toggle() {
    if (root.opened) root.dismiss()
    else root.open("{}")
  }

  function loadEmojis(raw) {
    root.emojis = EmojiSearch.parseEmojis(raw)
    if (root.opened) root.rebuildDisplay()
  }

  // Every read goes through here: the read on open, and the read the watcher asks
  // for when the file changes.
  function readFavorites() {
    root.favoritesReadRevision = root.favoritesRevision
    favoritesFile.reload()
  }

  // A read is applied only while it is still the newest thing to have happened to
  // the list. A pin or a drag made since it was asked for is newer, and it is the
  // one the user made: its list stays in memory, and its write is already on disk.
  function readIsCurrent() {
    return root.favoritesReadRevision === root.favoritesRevision
  }

  // The read finishes after the rebuild; refresh once it lands.
  function loadFavorites(raw) {
    if (!root.readIsCurrent()) return
    root.favoritesLoadError = FileViewError.Success
    root.favoritesReady = true
    root.favoritesWritable = EmojiSearch.favoritesAreValid(raw)
    root.favorites = EmojiSearch.parseFavorites(raw)
    if (root.opened) root.rebuildDisplay()
  }

  // A missing file is a first run, so it may be written; a file that exists but
  // could not be read is not ours to replace.
  function favoritesLoadFailed(error) {
    if (!root.readIsCurrent()) return
    root.favoritesLoadError = error
    root.favoritesReady = true
    root.favoritesWritable = error === FileViewError.FileNotFound
    root.favorites = []
    if (root.opened) root.rebuildDisplay()
  }

  function rebuildDisplay() {
    root.cells = EmojiSearch.buildCells(root.emojis, root.favorites, root.filterText, 1000, columns)

    displayModel.clear()
    for (var i = 0; i < root.cells.length; i++) displayModel.append(root.cells[i])

    // The cursor may only stand on an emoji cell, so a rebuild that changes the
    // sections re-seats it instead of clamping it onto a heading.
    if (selectedIndex >= displayModel.count) selectedIndex = displayModel.count - 1
    selectedIndex = Math.max(0, EmojiSearch.stepTarget(root.cells, selectedIndex, 1))
    cursorActive = displayModel.count > 0

    Qt.callLater(function() {
      // Near the top, reveal the heading above the first row rather than
      // scrolling the section heading out of the card.
      if (displayModel.count > 0)
        resultGrid.positionViewAtIndex(root.selectedIndex < columns * 2 ? 0 : root.selectedIndex, GridView.Contain)
    })
  }

  function moveTo(index) {
    if (index < 0 || index >= displayModel.count) return
    cursorActive = true
    selectedIndex = index
    // Near the top, reveal the heading above the first row.
    resultGrid.positionViewAtIndex(index < columns * 2 ? 0 : index, GridView.Contain)
  }

  // The first emoji in the direction asked for, for when the cursor is not on a
  // cell yet.
  function seatCursor(backwards) {
    var index = EmojiSearch.stepTarget(root.cells, backwards ? displayModel.count - 1 : 0, backwards ? -1 : 1)
    return index >= 0 ? index : 0
  }

  function select(delta) {
    if (displayModel.count === 0) return
    if (!cursorActive) return moveTo(root.seatCursor(delta < 0))
    // Wrap around: stepping left off the first emoji lands on the last one.
    var wrapped = (selectedIndex + delta + displayModel.count) % displayModel.count
    var next = EmojiSearch.stepTarget(root.cells, wrapped, delta)
    moveTo(next >= 0 ? next : root.seatCursor(delta < 0))
  }

  // Row and page movement resolve inside a row band, so a heading row, a padded
  // row end and a short pinned row cannot send the cursor sideways: a column with
  // no favorite above it lands on the nearest favorite instead.
  function selectRow(delta) {
    if (displayModel.count === 0) return
    if (!cursorActive) return moveTo(root.seatCursor(delta < 0))
    var target = EmojiSearch.rowTarget(root.cells, columns, selectedIndex, delta)
    if (target >= 0) moveTo(target)
  }

  function selectPage(delta) {
    if (displayModel.count === 0) return
    if (!cursorActive) return moveTo(root.seatCursor(delta < 0))
    var visibleRows = Math.max(1, Math.floor(resultGrid.height / cellHeight))
    // A page the grid cannot fit clamps to its end rather than going nowhere.
    var target = EmojiSearch.pageTarget(root.cells, columns, selectedIndex, delta * visibleRows)
    if (target >= 0) moveTo(target)
  }

  function setFilter(nextFilter) {
    root.filterText = nextFilter
    root.selectedIndex = 0
    root.cursorActive = true
    root.rebuildDisplay()
  }

  function activateIndex(index) {
    if (index < 0 || index >= displayModel.count) return
    var row = displayModel.get(index)
    root.applySelected(row.emoji)
  }

  function applySelected(emoji) {
    if (!emoji) return
    root.dismiss()
    Quickshell.execDetached([root.omarchyPath + "/bin/omarchy-menu-emoji-insert", emoji])
  }

  // Pinning is never a plain click, because a click in this picker inserts:
  // Ctrl+F or a right-click toggles instead.
  function toggleFavorite(index) {
    if (!root.favoritesSavable) return
    if (index < 0 || index >= displayModel.count) return
    var emoji = displayModel.get(index).emoji
    if (!emoji) return
    root.favorites = EmojiSearch.toggleFavorite(root.favorites, emoji)
    root.saveFavorites()
    root.rebuildDisplay()
    // The cell moves between sections; put the cursor back on it.
    root.selectEmoji(emoji)
  }

  function saveFavorites() {
    if (!root.favoritesSavable) {
      console.warn("emoji favorites save skipped: the list cannot be read or replaced")
      return false
    }
    // The list has moved past any read in flight, so that read is the older one.
    root.favoritesRevision++
    favoritesFile.setText(JSON.stringify(root.favorites) + "\n")
    return true
  }

  function selectEmoji(emoji) {
    for (var i = 0; i < displayModel.count; i++) {
      if (displayModel.get(i).emoji === emoji) return moveTo(i)
    }
  }

  function beginDrag(index, emoji, rootX, rootY) {
    root.dragging = true
    root.dragEmoji = emoji
    root.dragTo = index
    root.dragMoved = false
    root.dragX = rootX
    root.dragY = rootY
    root.dragOrigin = { x: rootX, y: rootY }
  }

  function updateDrag(rootX, rootY) {
    if (!root.dragging) return
    root.dragX = rootX
    root.dragY = rootY
    if (!root.dragMoved && (Math.abs(rootX - root.dragOrigin.x) > 6 || Math.abs(rootY - root.dragOrigin.y) > 6))
      root.dragMoved = true
    // Only pinned cells are drop targets, so a drag past the section keeps the
    // last one it was over.
    var point = resultGrid.mapFromItem(root, rootX, rootY)
    var target = resultGrid.indexAt(point.x, point.y)
    if (target < 0 || target >= displayModel.count) return
    var cell = displayModel.get(target)
    if (cell.emoji && root.favorites.indexOf(cell.emoji) >= 0) root.dragTo = target
  }

  function endDrag() {
    var emoji = root.dragEmoji
    var moved = root.dragMoved
    var target = root.dragTo
    root.dragging = false
    root.dragEmoji = ""
    root.dragTo = -1
    // A drag that never left its cell was a click, and a click inserts.
    root.suppressClick = moved
    if (!moved || target < 0 || target >= displayModel.count) return
    if (!root.favoritesSavable) return
    root.favorites = EmojiSearch.moveFavorite(root.favorites, emoji, displayModel.get(target).emoji)
    root.saveFavorites()
    root.rebuildDisplay()
    root.selectEmoji(emoji)
  }

  ListModel { id: displayModel }

  // Read once when the plugin starts, again on each open, and again whenever the
  // file changes, so an edit — made by hand, or by a seed script — is picked up
  // without restarting anything.
  FileView {
    id: favoritesFile
    path: Quickshell.env("HOME") + "/.local/state/omarchy/emoji-favorites.json"
    atomicWrites: true
    printErrors: false
    watchChanges: true
    onLoaded: root.loadFavorites(text())
    onLoadFailed: function(error) { root.favoritesLoadFailed(error) }
    onFileChanged: root.readFavorites()
  }

  FileView {
    path: root.omarchyPath + "/shell/plugins/emojis/emojis.json"
    onLoaded: root.loadEmojis(text())
  }
  OverlayWindow {
    id: panel
    shown: root.opened
    WlrLayershell.namespace: "omarchy-emojis"

    Rectangle {
      anchors.fill: parent
      color: root.scrim
    }

    MouseArea {
      anchors.fill: parent
      onClicked: root.dismiss()
    }

    BorderSurface {
      id: card
      width: root.cardWidth
      height: root.cardHeight
      radius: root.cornerRadius
      anchors.centerIn: parent
      color: root.background
      borderSpec: root.borderSpec
      padding: root.contentMargin

      MouseArea { anchors.fill: parent; onClicked: {} }

      Item {
        id: keyCatcher
        anchors.fill: parent
        focus: true

        Keys.priority: Keys.BeforeItem
        Keys.onPressed: function(event) {
          if (event.key === Qt.Key_F && (event.modifiers & Qt.ControlModifier)) {
            root.toggleFavorite(root.selectedIndex)
            event.accepted = true
          } else if (event.key === Qt.Key_Escape) {
            if (root.filterText) root.setFilter("")
            else root.dismiss()
            event.accepted = true
          } else if (Util.editsFilter(event, root.filterText)) {
            root.setFilter(Util.editedFilter(event, root.filterText))
            event.accepted = true
          } else if (event.key === Qt.Key_Left) {
            root.select(-1)
            event.accepted = true
          } else if (event.key === Qt.Key_Right) {
            root.select(1)
            event.accepted = true
          } else if (event.key === Qt.Key_Up) {
            root.selectRow(-1)
            event.accepted = true
          } else if (event.key === Qt.Key_Down) {
            root.selectRow(1)
            event.accepted = true
          } else if (event.key === Qt.Key_PageUp) {
            root.selectPage(-1)
            event.accepted = true
          } else if (event.key === Qt.Key_PageDown) {
            root.selectPage(1)
            event.accepted = true
          } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            if (root.cursorActive) root.activateIndex(root.selectedIndex)
            else if (displayModel.count > 0) root.cursorActive = true
            event.accepted = true
          } else if (event.text && event.text.length === 1 && event.text.charCodeAt(0) >= 32 && event.text.charCodeAt(0) !== 127) {
            root.setFilter(root.filterText + event.text)
            event.accepted = true
          }
        }
      }

      Column {
        anchors.fill: parent
        anchors.topMargin: card.contentTopInset
        anchors.rightMargin: card.contentRightInset
        anchors.bottomMargin: card.contentBottomInset
        anchors.leftMargin: card.contentLeftInset
        spacing: root.contentSpacing

        Rectangle {
          width: parent.width
          height: root.headerHeight
          radius: root.cornerRadius
          color: "transparent"

          Text {
            textFormat: Text.PlainText
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: root.filterText || "Search emojis…"
            color: root.foreground
            opacity: root.filterText ? 1 : 0.58
            font.family: root.fontFamily
            font.pixelSize: Style.font.heading
            elide: Text.ElideRight
          }
        }

        Item {
          width: parent.width
          height: parent.height - root.headerHeight - root.contentSpacing

          GridView {
            id: resultGrid
            anchors.fill: parent
            model: displayModel
            clip: true
            cellWidth: root.cellWidth
            cellHeight: root.cellHeight
            boundsBehavior: Flickable.StopAtBounds

            delegate: Rectangle {
              required property int index
              required property string emoji
              required property string heading

              readonly property bool hasCursor: root.cursorActive && index === root.selectedIndex && emoji !== ""
              readonly property bool isFavorite: emoji !== "" && root.favorites.indexOf(emoji) >= 0
              readonly property bool isDragTarget: root.dragging && index === root.dragTo && emoji !== ""

              width: root.cellWidth
              height: root.cellHeight
              radius: root.cornerRadius
              color: hasCursor ? root.selectedBackground : "transparent"
              opacity: root.dragging && emoji !== "" && emoji === root.dragEmoji ? 0.35 : 1

              Text {
                textFormat: Text.PlainText
                text: parent.emoji
                font.family: root.fontFamily
                font.pixelSize: Style.font.display
                anchors.centerIn: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
              }

              // Nerd Font star (U+F005). The menu font is the same family the
              // empty state draws its nerd glyph with, so the fallback covers it.
              Text {
                textFormat: Text.PlainText
                visible: parent.isFavorite
                text: "\uf005"
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.topMargin: Style.spacing.sm
                anchors.rightMargin: Style.spacing.sm
                color: root.foreground
                opacity: 0.55
                font.family: root.fontFamily
                font.pixelSize: Style.font.caption
              }

              Rectangle {
                anchors.fill: parent
                visible: parent.isDragTarget
                radius: root.cornerRadius
                color: "transparent"
                border.width: Math.max(1, Style.space(1))
                border.color: root.foreground
                opacity: 0.45
              }

              Text {
                textFormat: Text.PlainText
                visible: parent.heading !== ""
                text: parent.heading
                width: resultGrid.width
                anchors.bottom: parent.bottom
                anchors.bottomMargin: Style.spacing.sm
                leftPadding: Style.spacing.md
                color: root.foreground
                opacity: 0.58
                font.family: root.fontFamily
                font.pixelSize: Style.font.title
              }

              MouseArea {
                id: mouseArea
                anchors.fill: parent
                enabled: parent.emoji !== ""
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                hoverEnabled: true
                // A drag over a pinned cell is a reorder, not a scroll.
                preventStealing: parent.isFavorite
                cursorShape: parent.isFavorite ? (pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor) : Qt.PointingHandCursor

                onContainsMouseChanged: if (containsMouse) {
                  root.cursorActive = true
                  root.selectedIndex = index
                }

                onPressed: function(mouse) {
                  root.cursorActive = true
                  root.selectedIndex = index
                  // A drag's trailing click never arrives when the drop rebuilt the
                  // model, so the flag has to be cleared by the press that follows
                  // it rather than by a click that is not delivered.
                  root.suppressClick = false
                  if (mouse.button !== Qt.LeftButton || !parent.isFavorite) return
                  var point = mapToItem(root, mouse.x, mouse.y)
                  root.beginDrag(index, parent.emoji, point.x, point.y)
                }

                onPositionChanged: function(mouse) {
                  if (!root.dragging) return
                  var point = mapToItem(root, mouse.x, mouse.y)
                  root.updateDrag(point.x, point.y)
                }

                onReleased: if (root.dragging) root.endDrag()

                onClicked: function(mouse) {
                  root.cursorActive = true
                  root.selectedIndex = index
                  if (root.suppressClick) {
                    root.suppressClick = false
                    return
                  }
                  if (mouse.button === Qt.RightButton || (mouse.modifiers & Qt.ControlModifier)) {
                    root.toggleFavorite(index)
                    return
                  }
                  root.activateIndex(index)
                }
              }
            }
          }

          Column {
            anchors.centerIn: parent
            spacing: Style.space(8)
            visible: displayModel.count === 0

            Text {
              text: "󰈉"
              color: root.selectedText
              opacity: 0.8
              font.family: root.fontFamily
              font.pixelSize: Style.font.displayLarge
              horizontalAlignment: Text.AlignHCenter
              width: parent.width
            }

            Text {
              textFormat: Text.PlainText
              text: "No matches for “" + root.filterText + "”"
              color: root.foreground
              opacity: 0.7
              font.family: root.fontFamily
              font.pixelSize: Style.font.title
              horizontalAlignment: Text.AlignHCenter
              width: parent.width
            }
          }
        }
      }

      // Follows the pointer while a pinned cell is being dragged.
      Rectangle {
        visible: root.dragging
        width: root.cellWidth
        height: root.cellHeight
        radius: root.cornerRadius
        color: root.selectedBackground
        opacity: 0.9
        x: card.mapFromItem(root, root.dragX, root.dragY).x - width / 2
        y: card.mapFromItem(root, root.dragX, root.dragY).y - height / 2

        Text {
          textFormat: Text.PlainText
          text: root.dragEmoji
          anchors.centerIn: parent
          font.family: root.fontFamily
          font.pixelSize: Style.font.display
        }
      }
    }
  }
}
