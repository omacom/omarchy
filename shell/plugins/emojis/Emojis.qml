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
  readonly property string stateDir: (Quickshell.env("XDG_STATE_HOME") || Quickshell.env("HOME") + "/.local/state") + "/omarchy"
  property var shell: null
  property var manifest: null

  property bool opened: false
  property string filterText: ""
  property var emojis: []
  property var lookup: ({})
  property var prefs: ({ recent: [], favorites: [], tone: 0 })
  property bool prefsLoaded: false
  property var rows: []
  property var sections: []
  property int curRow: -1
  property int curCol: 0
  property int wantCol: 0
  property string activeSection: ""
  property bool caretOn: true

  readonly property string currentEmoji: curRow >= 0 && curRow < rows.length ? (rows[curRow].cells[curCol] || "") : ""
  readonly property var currentItem: currentEmoji ? (lookup[currentEmoji] || null) : null
  readonly property bool currentIsFavorite: !!currentEmoji && prefs.favorites.indexOf(currentEmoji) >= 0

  // Favorites and Recent only get a tab once they have something in them.
  readonly property var tabs: [
    { id: EmojiSearch.FAVORITES_ID, icon: "\u{F04CE}", show: prefs.favorites.length > 0 },
    { id: EmojiSearch.RECENT_ID, icon: "\u{F0150}", show: prefs.recent.length > 0 }
  ].filter(function(tab) { return tab.show }).concat(EmojiSearch.GROUPS)
  // Default yellow, then Fitzpatrick 1-2 through 6.
  readonly property var toneColors: ["#FFC83D", "#F7DECE", "#F3D2A2", "#D5AB88", "#AF7E57", "#7C533E"]

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
  property color mutedText: Util.alpha(foreground, 0.55)
  property color hairline: Util.alpha(foreground, 0.12)
  readonly property int cornerRadius: Style.cornerRadius
  property string fontFamily: Style.font.menuFamily
  property int contentMargin: Style.spacing.panelPadding
  property int headerHeight: Math.max(Style.space(34), Style.font.title + Style.spacing.controlPaddingY * 2)

  // Emoji fonts ship bitmaps at fixed sizes; 40px and 48px are native sizes
  // of the common ones, so the grid and the preview stay sharp.
  readonly property int columns: 8
  property int cellSize: Style.space(56)
  property int emojiSize: Style.space(40)
  property int previewSize: Style.space(48)
  property int tabHeight: Style.space(36)
  property int sectionHeight: Style.space(26)
  property int footerHeight: Style.space(66)
  property int scrollGutter: Style.space(10)
  property int cardWidth: Math.min(columns * cellSize + scrollGutter + contentMargin * 2 + card.borderLeft + card.borderRight,
    panel.width - Style.gapsOut * 2)
  property int cardHeight: Math.min(Style.space(640), panel.height - Style.gapsOut * 2)

  function open(payloadJson) {
    root.opened = true
    root.filterText = ""
    root.rebuild(true)
    gate.reset()
    root.caretOn = true
    Qt.callLater(function() {
      list.positionViewAtBeginning()
      keyCatcher.forceActiveFocus()
    })
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

  // ------------------------------------------------------------- rows

  // One literal call per key, so the catalog check sees every key in use.
  function sectionTitle(id, count) {
    switch (id) {
    case EmojiSearch.RESULTS_ID: return Commons.I18n.tn("emojis.results", count).arg(Commons.I18n.formatNumber(count))
    case EmojiSearch.FAVORITES_ID: return Commons.I18n.t("emojis.favorites")
    case EmojiSearch.RECENT_ID: return Commons.I18n.t("emojis.recent")
    case "smileys": return Commons.I18n.t("emojis.group.smileys")
    case "people": return Commons.I18n.t("emojis.group.people")
    case "nature": return Commons.I18n.t("emojis.group.nature")
    case "food": return Commons.I18n.t("emojis.group.food")
    case "travel": return Commons.I18n.t("emojis.group.travel")
    case "activities": return Commons.I18n.t("emojis.group.activities")
    case "objects": return Commons.I18n.t("emojis.group.objects")
    case "symbols": return Commons.I18n.t("emojis.group.symbols")
    case "flags": return Commons.I18n.t("emojis.group.flags")
    }
    return id
  }

  function sectionFor(id) {
    for (var i = 0; i < root.sections.length; i++)
      if (root.sections[i].id === id) return root.sections[i]
    return null
  }

  function rebuild(resetCursor) {
    var built = EmojiSearch.buildRows(root.emojis, root.prefs, root.filterText, root.columns, root.prefs.tone, root.sectionTitle)
    root.rows = built.rows
    root.sections = built.sections
    rowsModel.clear()
    for (var i = 0; i < built.rows.length; i++) rowsModel.append({ sec: built.rows[i].section, row: i })

    if (resetCursor || root.curRow < 0 || root.curRow >= root.rows.length) {
      root.curRow = root.rows.length ? 0 : -1
      root.curCol = 0
      root.wantCol = 0
    } else {
      root.curCol = Math.min(root.curCol, root.rows[root.curRow].cells.length - 1)
    }
    root.activeSection = root.rows.length ? root.rows[Math.max(0, root.curRow)].group : ""
  }

  // Rebuilds after a favorite or skin-tone change without jumping: the top
  // visible row and the cursor are found again by section and offset.
  function rebuildKeepingView() {
    function locate(row) {
      if (row < 0 || row >= root.rows.length) return null
      var sec = root.sectionFor(root.rows[row].group)
      return sec ? { group: sec.id, offset: row - sec.firstRow } : null
    }
    function resolve(spot) {
      var sec = spot ? root.sectionFor(spot.group) : null
      if (!sec) return -1
      var row = sec.firstRow + spot.offset
      while (row > sec.firstRow && (row >= root.rows.length || root.rows[row].group !== sec.id)) row--
      return row
    }

    var topRow = list.indexAt(list.width / 2, list.contentY + root.sectionHeight + 1)
    var topItem = topRow >= 0 ? list.itemAtIndex(topRow) : null
    var anchor = locate(topRow)
    var delta = topItem ? topItem.y - list.contentY : 0
    var cursor = locate(root.curRow)
    var col = root.curCol

    root.rebuild(false)

    var cursorRow = resolve(cursor)
    root.curRow = cursorRow >= 0 ? cursorRow : (root.rows.length ? 0 : -1)
    root.curCol = cursorRow >= 0 ? Math.min(col, root.rows[cursorRow].cells.length - 1) : 0

    var anchorRow = resolve(anchor)
    if (anchorRow < 0) return
    Qt.callLater(function() {
      list.positionViewAtIndex(anchorRow, ListView.Beginning)
      var item = list.itemAtIndex(anchorRow)
      if (item) list.contentY = item.y - delta
      gate.reset()
    })
  }

  // Preview text and section titles are composed imperatively, so rebuild
  // when the language (and with it the string catalog) changes.
  Connections {
    target: Commons.I18n
    function onStringsChanged() { if (root.opened) root.rebuildKeepingView() }
  }

  // ------------------------------------------------------------- cursor

  function setCursor(row, col) {
    root.curRow = row
    root.curCol = col
    root.wantCol = col
  }

  function moveTo(row, col) {
    if (row < 0 || row >= root.rows.length) return
    root.curRow = row
    root.curCol = Math.max(0, Math.min(col, root.rows[row].cells.length - 1))
    root.activeSection = root.rows[row].group
    root.ensureVisible(row)
  }

  // The pinned section label covers the top of the view, so rows scrolled
  // up into view are kept below it.
  function ensureVisible(row) {
    list.positionViewAtIndex(row, ListView.Contain)
    var item = list.itemAtIndex(row)
    if (item && item.y < list.contentY + root.sectionHeight)
      list.contentY = item.y - root.sectionHeight
    gate.reset()
  }

  function moveCol(delta) {
    if (root.curRow < 0) return
    var col = root.curCol + delta
    if (col >= 0 && col < root.rows[root.curRow].cells.length) root.moveTo(root.curRow, col)
    else if (delta > 0 && root.curRow + 1 < root.rows.length) root.moveTo(root.curRow + 1, 0)
    else if (delta < 0 && root.curRow > 0) root.moveTo(root.curRow - 1, root.columns)
    root.wantCol = root.curCol
  }

  function moveRow(delta) {
    if (root.curRow < 0) return
    root.moveTo(Math.max(0, Math.min(root.rows.length - 1, root.curRow + delta)), root.wantCol)
  }

  function jumpToSection(id) {
    if (root.filterText) {
      root.filterText = ""
      root.rebuild(true)
    }
    var sec = root.sectionFor(id)
    if (!sec) return
    root.setCursor(sec.firstRow, 0)
    root.activeSection = sec.id
    Qt.callLater(function() {
      list.positionViewAtIndex(sec.firstRow, ListView.Beginning)
      root.activeSection = sec.id
      gate.reset()
    })
  }

  function cycleSection(delta) {
    if (!root.sections.length) return
    var at = 0
    for (var i = 0; i < root.sections.length; i++)
      if (root.sections[i].id === root.activeSection) at = i
    root.jumpToSection(root.sections[(at + delta + root.sections.length) % root.sections.length].id)
  }

  function updateActiveFromScroll() {
    if (!root.rows.length || root.filterText) return
    if (list.atYEnd && root.sections.length) {
      root.activeSection = root.sections[root.sections.length - 1].id
      return
    }
    var y = list.contentY + root.sectionHeight + 2
    var row = list.indexAt(list.width / 2, y)
    if (row < 0) row = list.indexAt(list.width / 2, y + root.sectionHeight)
    if (row >= 0 && row < root.rows.length) root.activeSection = root.rows[row].group
  }

  // ------------------------------------------------------------- actions

  function savePrefs(next) {
    root.prefs = next
    prefsFile.setText(EmojiSearch.serializePrefs(next))
  }

  function activate(emoji, copyOnly) {
    if (!emoji) return
    root.savePrefs(EmojiSearch.withRecent(root.prefs, emoji))
    root.dismiss()
    if (copyOnly) Quickshell.execDetached(["wl-copy", "--type", "text/plain", emoji])
    else Quickshell.execDetached([root.omarchyPath + "/bin/omarchy-menu-emoji-insert", emoji])
  }

  function toggleFavorite(emoji) {
    if (!emoji) return
    root.savePrefs(EmojiSearch.withFavoriteToggled(root.prefs, emoji))
    if (!root.filterText) root.rebuildKeepingView()
  }

  function setTone(tone) {
    if (tone === root.prefs.tone) return
    root.savePrefs(EmojiSearch.withTone(root.prefs, tone))
    root.rebuildKeepingView()
  }

  function setFilter(nextFilter) {
    root.filterText = nextFilter
    root.caretOn = true
    root.rebuild(true)
    Qt.callLater(function() { list.positionViewAtBeginning() })
  }

  // ------------------------------------------------------------- data

  ListModel { id: rowsModel }

  FileView {
    path: root.omarchyPath + "/shell/plugins/emojis/emojis.json"
    onLoaded: {
      root.emojis = EmojiSearch.parseEmojis(text())
      root.lookup = EmojiSearch.buildLookup(root.emojis)
      if (root.opened) root.rebuild(true)
    }
  }

  // Favorites, recents and the skin tone.
  Process { command: ["mkdir", "-p", root.stateDir]; running: true }

  FileView {
    id: prefsFile
    path: root.stateDir + "/emojis.json"
    printErrors: false
    atomicWrites: true
    onLoaded: {
      if (root.prefsLoaded) return
      root.prefsLoaded = true
      root.prefs = EmojiSearch.parsePrefs(text())
      if (root.opened) root.rebuild(true)
    }
    onLoadFailed: root.prefsLoaded = true
  }

  PointerMoveGate {
    id: gate
    referenceItem: card
  }

  Timer {
    interval: 530
    repeat: true
    running: root.opened
    onTriggered: root.caretOn = !root.caretOn
  }

  // ------------------------------------------------------------- view

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
          var ctrl = (event.modifiers & Qt.ControlModifier) !== 0
          var shift = (event.modifiers & Qt.ShiftModifier) !== 0
          if (event.key === Qt.Key_Escape) {
            if (root.filterText) root.setFilter("")
            else root.dismiss()
          } else if (Util.editsFilter(event, root.filterText)) {
            root.setFilter(Util.editedFilter(event, root.filterText))
          } else if (ctrl && event.key === Qt.Key_F) {
            root.toggleFavorite(root.currentEmoji)
          } else if (ctrl && event.key === Qt.Key_T) {
            root.setTone((root.prefs.tone + 1) % root.toneColors.length)
          } else if (event.key === Qt.Key_Tab) {
            root.cycleSection(1)
          } else if (event.key === Qt.Key_Backtab) {
            root.cycleSection(-1)
          } else if (Util.readingKey(event) === Qt.Key_Left) {
            root.moveCol(-1)
          } else if (Util.readingKey(event) === Qt.Key_Right) {
            root.moveCol(1)
          } else if (event.key === Qt.Key_Up) {
            root.moveRow(-1)
          } else if (event.key === Qt.Key_Down) {
            root.moveRow(1)
          } else if (event.key === Qt.Key_PageUp || event.key === Qt.Key_PageDown) {
            var page = Math.max(1, Math.floor(list.height / root.cellSize) - 1)
            root.moveRow(event.key === Qt.Key_PageUp ? -page : page)
          } else if (event.key === Qt.Key_Home && ctrl) {
            root.moveTo(0, 0)
          } else if (event.key === Qt.Key_End && ctrl) {
            root.moveTo(root.rows.length - 1, root.columns)
          } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            root.activate(root.currentEmoji, shift)
          } else if (!ctrl && event.text && event.text.length === 1 && event.text.charCodeAt(0) >= 32 && event.text.charCodeAt(0) !== 127) {
            root.setFilter(root.filterText + event.text)
          } else {
            return
          }
          event.accepted = true
        }
      }

      Column {
        anchors.fill: parent
        anchors.topMargin: card.contentTopInset
        anchors.rightMargin: card.contentRightInset
        anchors.bottomMargin: card.contentBottomInset
        anchors.leftMargin: card.contentLeftInset

        // Search
        Item {
          width: parent.width
          height: root.headerHeight

          Text {
            id: searchIcon
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: "\u{F0349}"
            color: root.filterText ? root.selectedText : root.mutedText
            font.family: root.fontFamily
            font.pixelSize: Style.font.iconLarge
          }

          Text {
            id: queryText
            textFormat: Text.PlainText
            anchors.left: searchIcon.right
            anchors.leftMargin: Style.spacing.lg
            anchors.right: clearHint.left
            anchors.rightMargin: Style.spacing.lg
            anchors.verticalCenter: parent.verticalCenter
            text: root.filterText || Commons.I18n.t("emojis.search")
            color: root.foreground
            opacity: root.filterText ? 1 : 0.58
            font.family: root.fontFamily
            font.pixelSize: Style.font.heading
            elide: Text.ElideLeft
          }

          Rectangle {
            x: queryText.x + (root.filterText ? Math.min(queryText.contentWidth, queryText.width) : 0)
            anchors.verticalCenter: parent.verticalCenter
            width: Math.max(1, Style.space(2))
            height: Style.font.heading + Style.space(4)
            color: root.selectedText
            visible: root.opened && root.caretOn
          }

          Text {
            id: clearHint
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: root.filterText ? Commons.I18n.t("emojis.clearSearch") : ""
            color: root.mutedText
            font.family: root.fontFamily
            font.pixelSize: Style.font.caption
          }
        }

        // Category tabs
        Row {
          width: parent.width
          height: root.tabHeight

          Repeater {
            model: root.tabs

            delegate: Item {
              id: tab
              required property var modelData
              readonly property bool active: !root.filterText && root.activeSection === modelData.id

              width: parent.width / root.tabs.length
              height: root.tabHeight

              Rectangle {
                anchors.fill: parent
                anchors.margins: Style.space(2)
                radius: root.cornerRadius
                color: tabMouse.containsMouse ? root.selectedBackground : "transparent"
              }

              Text {
                anchors.centerIn: parent
                text: tab.modelData.icon
                color: tab.active ? root.selectedText : root.foreground
                opacity: tab.active ? 1 : (root.filterText ? 0.3 : 0.6)
                font.family: root.fontFamily
                font.pixelSize: Style.font.iconLarge
              }

              Rectangle {
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width * 0.55
                height: Math.max(1, Style.space(2))
                radius: height / 2
                color: root.selectedText
                visible: tab.active
              }

              MouseArea {
                id: tabMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.jumpToSection(tab.modelData.id)
              }
            }
          }
        }

        Rectangle { width: parent.width; height: 1; color: root.hairline }

        // Grid
        Item {
          width: parent.width
          height: parent.height - root.headerHeight - root.tabHeight - root.footerHeight - 2

          ListView {
            id: list
            anchors.fill: parent
            anchors.topMargin: Style.spacing.sm
            anchors.bottomMargin: Style.spacing.sm
            model: rowsModel
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            onContentYChanged: root.updateActiveFromScroll()

            section.property: "sec"
            section.criteria: ViewSection.FullString
            section.labelPositioning: ViewSection.InlineLabels | ViewSection.CurrentLabelAtStart
            section.delegate: Rectangle {
              required property string section
              width: list.width
              height: root.sectionHeight
              color: root.background

              Text {
                textFormat: Text.PlainText
                anchors.left: parent.left
                anchors.leftMargin: Style.spacing.md
                anchors.verticalCenter: parent.verticalCenter
                text: parent.section.toUpperCase()
                color: root.mutedText
                font.family: root.fontFamily
                font.pixelSize: Style.font.caption
                font.letterSpacing: Style.space(1)
              }
            }

            delegate: Item {
              id: rowItem
              required property int row
              readonly property var rowData: root.rows[row] || ({ cells: [], group: "" })

              width: list.width
              height: root.cellSize

              Row {
                Repeater {
                  model: rowItem.rowData.cells

                  delegate: Item {
                    id: cell
                    required property string modelData
                    required property int index
                    readonly property bool hasCursor: root.curRow === rowItem.row && root.curCol === index
                    readonly property bool favorite: root.prefs.favorites.indexOf(modelData) >= 0

                    width: root.cellSize
                    height: root.cellSize

                    Rectangle {
                      anchors.fill: parent
                      anchors.margins: Style.space(2)
                      radius: root.cornerRadius
                      color: cell.hasCursor ? root.selectedBackground : "transparent"
                      border.width: cell.hasCursor ? Math.max(1, Style.space(1)) : 0
                      border.color: Util.alpha(root.selectedText, 0.7)
                    }

                    Text {
                      anchors.centerIn: parent
                      textFormat: Text.PlainText
                      text: cell.modelData
                      font.family: root.fontFamily
                      font.pixelSize: root.emojiSize
                    }

                    Text {
                      visible: cell.favorite && rowItem.rowData.group !== EmojiSearch.FAVORITES_ID
                      anchors.top: parent.top
                      anchors.right: parent.right
                      anchors.margins: Style.space(3)
                      text: "\u{F04CE}"
                      color: root.selectedText
                      font.family: root.fontFamily
                      font.pixelSize: Style.font.caption
                    }

                    MouseArea {
                      anchors.fill: parent
                      hoverEnabled: true
                      acceptedButtons: Qt.LeftButton | Qt.RightButton
                      cursorShape: Qt.PointingHandCursor
                      onPositionChanged: function(mouse) {
                        if (gate.moved(cell, mouse)) root.setCursor(rowItem.row, cell.index)
                      }
                      onClicked: function(mouse) {
                        root.setCursor(rowItem.row, cell.index)
                        if (mouse.button === Qt.RightButton) root.toggleFavorite(cell.modelData)
                        else root.activate(cell.modelData, (mouse.modifiers & Qt.ShiftModifier) !== 0)
                      }
                    }
                  }
                }
              }
            }
          }

          Rectangle {
            visible: list.contentHeight > list.height
            anchors.right: parent.right
            y: list.y + list.visibleArea.yPosition * list.height
            width: Math.max(2, Style.space(3))
            height: Math.max(Style.space(24), list.visibleArea.heightRatio * list.height)
            radius: width / 2
            color: Util.alpha(root.foreground, 0.25)
          }

          Column {
            anchors.centerIn: parent
            spacing: Style.space(8)
            visible: !!root.filterText && root.rows.length === 0

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
              text: Commons.I18n.t("emojis.noMatches").arg(root.filterText)
              color: root.foreground
              opacity: 0.7
              font.family: root.fontFamily
              font.pixelSize: Style.font.title
              horizontalAlignment: Text.AlignHCenter
            }
          }
        }

        Rectangle { width: parent.width; height: 1; color: root.hairline }

        // Preview + skin tone
        Item {
          width: parent.width
          height: root.footerHeight

          Text {
            id: previewGlyph
            anchors.left: parent.left
            anchors.leftMargin: Style.spacing.sm
            anchors.verticalCenter: parent.verticalCenter
            width: root.previewSize
            horizontalAlignment: Text.AlignHCenter
            textFormat: Text.PlainText
            text: root.currentEmoji
            font.family: root.fontFamily
            font.pixelSize: root.previewSize
          }

          Column {
            anchors.left: previewGlyph.right
            anchors.leftMargin: Style.spacing.xxl
            anchors.right: toneRow.left
            anchors.rightMargin: Style.spacing.xxl
            anchors.verticalCenter: parent.verticalCenter
            spacing: Style.spacing.xs

            // Unicode names are English; there is no translated set to use.
            Text {
              width: parent.width
              textFormat: Text.PlainText
              text: (root.currentItem && root.currentItem.n
                ? root.currentItem.n.charAt(0).toUpperCase() + root.currentItem.n.slice(1)
                : Commons.I18n.t("emojis.pick")) + (root.currentIsFavorite ? "  \u{F04CE}" : "")
              color: root.foreground
              font.family: root.fontFamily
              font.pixelSize: Style.font.title
              elide: Text.ElideRight
            }

            Text {
              width: parent.width
              textFormat: Text.PlainText
              text: Commons.I18n.t("emojis.hints")
              color: root.mutedText
              font.family: root.fontFamily
              font.pixelSize: Style.font.caption
              elide: Text.ElideRight
            }
          }

          Row {
            id: toneRow
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: Style.spacing.sm

            Repeater {
              model: root.toneColors

              delegate: Rectangle {
                id: swatch
                required property color modelData
                required property int index
                readonly property bool chosen: root.prefs.tone === index

                width: Style.space(14)
                height: width
                radius: width / 2
                color: modelData
                border.width: chosen ? Math.max(2, Style.space(2)) : Math.max(1, Style.space(1))
                border.color: chosen ? root.selectedText : Util.alpha(root.foreground, 0.25)
                scale: chosen ? 1.15 : 1

                MouseArea {
                  anchors.fill: parent
                  anchors.margins: -Style.space(3)
                  cursorShape: Qt.PointingHandCursor
                  onClicked: root.setTone(swatch.index)
                }
              }
            }
          }
        }
      }
    }
  }
}
