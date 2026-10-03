import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import qs.Commons
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
  property var filteredEmojis: []

  // Shares the [menu] surface tokens — themes that style the menu also
  // style emojis. Selected-cell colors composed in the
  // singleton so consumers drop them straight into Rectangle bindings.
  property color background: Color.menu.background
  property color foreground: Color.menu.text
  property color border: Color.menu.border
  property var borderSpec: Border.surfaceSpec("menu", "border", border, Math.max(1, Style.space(2)))
  property color scrim: Color.menu.scrim
  property color selectedBackground: Color.menu.selectedBackground
  property color selectedText: Color.menu.selectedText
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

  // { emoji: useCount } — the most used fill the first rows when not filtering.
  property var usage: ({})
  property int topRows: 4
  // The card is measured only once visible; rebuild so the top rows fit.
  onColumnsChanged: if (opened) rebuildDisplay()

  function open(payloadJson) {
    root.opened = true
    root.filterText = ""
    root.selectedIndex = 0
    root.cursorActive = true
    // Read on every open so hand edits to the usage file show up.
    usageFile.reload()
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

  // The reload on open finishes after the first rebuild; refresh once it lands.
  function loadUsage(raw) {
    root.usage = EmojiSearch.parseUsage(raw)
    if (root.opened) root.rebuildDisplay()
  }

  function rebuildDisplay() {
    var out = EmojiSearch.filterEmojis(root.emojis, root.filterText, 1000)
    root.filteredEmojis = out

    displayModel.clear()
    var frequent = root.filterText ? [] : EmojiSearch.mostUsed(root.emojis, root.usage, root.columns * root.topRows)
    if (frequent.length > 0) {
      root.appendHeading("Frequent")
      root.appendEmojis(frequent)
      root.appendHeading("All")
    }
    root.appendEmojis(out.map(function(item) { return item.e }))

    if (selectedIndex >= displayModel.count) selectedIndex = displayModel.count - 1
    selectedIndex = Math.max(0, skipHeadings(selectedIndex, 1))
    cursorActive = displayModel.count > 0

    Qt.callLater(function() {
      if (displayModel.count > 0) resultGrid.positionViewAtIndex(root.selectedIndex, GridView.Contain)
    })
  }

  // A heading fills a whole grid row; only its first cell draws the text.
  function appendHeading(text) {
    for (var i = 0; i < root.columns; i++) displayModel.append({ emoji: "", heading: i === 0 ? text : "" })
  }

  function appendEmojis(list) {
    for (var i = 0; i < list.length; i++) displayModel.append({ emoji: list[i], heading: "" })
  }

  // Walks past heading cells; -1 when that runs off the grid.
  function skipHeadings(index, step) {
    while (index >= 0 && index < displayModel.count && !displayModel.get(index).emoji) index += step
    return index < displayModel.count ? index : -1
  }

  function moveTo(index, step) {
    if (displayModel.count === 0) return
    index = Math.max(0, Math.min(displayModel.count - 1, index))
    // Overshooting the top lands on the heading; settle on the first emoji.
    var next = skipHeadings(index, step)
    index = next >= 0 ? next : skipHeadings(index, 1)
    cursorActive = true
    selectedIndex = index
    // Near the top, reveal the heading above the first row.
    resultGrid.positionViewAtIndex(index < columns * 2 ? 0 : index, GridView.Contain)
  }

  function select(delta) {
    if (!cursorActive) return moveTo(delta < 0 ? displayModel.count - 1 : 0, delta)
    // Wrap around: stepping left off the first emoji lands on the last one.
    var next = skipHeadings((selectedIndex + delta + displayModel.count) % displayModel.count, delta)
    moveTo(next < 0 ? displayModel.count - 1 : next, delta)
  }

  function selectRow(delta) {
    if (!cursorActive) moveTo(delta < 0 ? displayModel.count - 1 : 0, delta)
    else moveTo(selectedIndex + delta * columns, delta * columns)
  }

  function selectPage(delta) {
    var visibleRows = Math.max(1, Math.floor(resultGrid.height / cellHeight))
    if (!cursorActive) moveTo(delta < 0 ? displayModel.count - 1 : 0, delta)
    else moveTo(selectedIndex + delta * columns * visibleRows, delta * columns)
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
    root.usage[emoji] = (root.usage[emoji] || 0) + 1
    usageFile.setText(JSON.stringify(root.usage) + "\n")
    root.dismiss()
    Quickshell.execDetached([root.omarchyPath + "/bin/omarchy-menu-emoji-insert", emoji])
  }

  ListModel { id: displayModel }

  FileView {
    id: usageFile
    path: Quickshell.env("HOME") + "/.local/state/omarchy/emoji-usage.json"
    atomicWrites: true
    printErrors: false
    onLoaded: root.loadUsage(text())
    onLoadFailed: root.loadUsage("")
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
          if (event.key === Qt.Key_Escape) {
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

              width: root.cellWidth
              height: root.cellHeight
              radius: root.cornerRadius
              color: hasCursor ? root.selectedBackground : "transparent"

              Text {
                textFormat: Text.PlainText
                text: parent.emoji
                font.family: root.fontFamily
                font.pixelSize: Style.font.display
                anchors.centerIn: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
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
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onContainsMouseChanged: if (containsMouse) {
                  root.cursorActive = true
                  root.selectedIndex = index
                }
                onClicked: {
                  root.cursorActive = true
                  root.selectedIndex = index
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
    }
  }
}
