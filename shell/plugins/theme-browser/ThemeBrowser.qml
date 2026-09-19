import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import qs.Commons
import qs.Ui
import "ThemeCatalog.js" as ThemeCatalog

// A wall of theme previews with the selected one written out beside it. The
// catalog, the previews and the install are all omarchy-theme-* commands; this
// only draws them.
Item {
  id: root

  property string omarchyPath: Quickshell.env("OMARCHY_PATH")
  property var shell: null
  property var manifest: null

  property bool opened: false
  property var filters: ThemeCatalog.emptyFilters()
  property int selectedIndex: 0
  // A still pointer gets hover events whenever tiles move under it, and each
  // would steal the selection from the arrow keys. Only real movement claims
  // it; -1 means the next event only records where the pointer is.
  property real lastPointerX: -1
  property real lastPointerY: -1
  property bool loading: false
  property string loadError: ""

  // A refresh that redraws the same grid looks like a key that did nothing, so
  // the footer says what it is doing and then what came of it.
  property bool refreshing: false
  property string statusMessage: ""
  property string generatedAt: ""
  property string catalogWarning: ""

  property var themes: []
  property var filtered: []
  property var installedNames: []
  // Mutated in place as tiles arrive one line at a time; bindings depend on the
  // revision counter instead.
  property var previewPaths: ({})
  property int previewRevision: 0

  // The [menu] surface tokens, so the browser looks like the desktop it is
  // about to change.
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
  property int contentSpacing: Style.spacing.lg
  property int paneGap: Style.spacing.huge * 2
  property int cardWidth: Math.min(panel.width - Style.gapsOut * 2,
    Math.max(Style.space(820), Math.round(panel.width * 0.82)))
  property int cardHeight: Math.min(panel.height - Style.gapsOut * 2,
    Math.max(Style.space(520), Math.round(panel.height * 0.82)))
  // The pane grows with the card so its preview stays larger than a tile.
  property int detailWidth: Math.round(Math.max(Style.space(260), Math.min(Style.space(520), cardWidth * 0.24)))
  property int headerHeight: Math.max(Style.space(30), Style.font.heading + Style.spacing.controlPaddingY * 2)
  property int detailLabelWidth: Math.round(detailWidth * 0.34)

  // Tiles keep the previews' 16:9 with a title and artist under them. They aim
  // at 280px and take whatever count divides the width: two at the narrowest,
  // six at most so a wide monitor gets bigger previews rather than more of
  // them.
  property int gridWidth: cardWidth - contentMargin * 2 - detailWidth - paneGap
  property int columns: Math.max(2, Math.min(6, Math.round(gridWidth / Style.space(280))))
  property int cellWidth: Math.floor(gridWidth / columns)
  // Explicit label heights, so the cell height is arithmetic rather than a
  // guess at a Text's implicit height; guessing low clips the artist's name.
  property int tileTitleHeight: Style.font.body + Style.spacing.sm
  property int tileArtistHeight: Style.font.bodySmall + Style.spacing.xs
  property int tileLabelHeight: tileTitleHeight + tileArtistHeight + Style.spacing.sm * 3
  // Rows need real space under the label text or the next row's preview reads
  // as belonging to it; columns are already separated by the card edges.
  property int tileGapX: Style.spacing.xs
  property int tileGapY: Style.spacing.lg
  property int cellHeight: Math.round((cellWidth - tileGapX * 2 - Style.spacing.sm * 2) * 9 / 16)
    + tileLabelHeight + tileGapY * 2

  readonly property var shortcutHints: [
    { keys: "Type", action: "to search" },
    { keys: "Alt+1\u20135", action: "toggle filters" },
    { keys: "\u2191\u2009\u2193\u2009\u2190\u2009\u2192", action: "move" },
    { keys: "Enter", action: "install" },
    { keys: "Ctrl+O", action: "open theme page" },
    { keys: "Ctrl+R", action: "refresh catalog" },
    { keys: "Esc", action: "close" }
  ]

  readonly property var current: selectedIndex >= 0 && selectedIndex < filtered.length
    ? filtered[selectedIndex] : null

  function pointerMovedTo(x, y) {
    var moved = root.lastPointerX >= 0 && (x !== root.lastPointerX || y !== root.lastPointerY)
    root.lastPointerX = x
    root.lastPointerY = y
    return moved
  }

  function open(payloadJson) {
    var payload = {}
    try {
      payload = JSON.parse(String(payloadJson || "{}")) || {}
    } catch (e) {
      payload = {}
    }

    root.opened = true
    root.filters = ThemeCatalog.filtersFromPayload(payload)
    root.selectedIndex = 0
    root.lastPointerX = -1
    root.lastPointerY = -1
    root.loadError = ""
    root.refresh(payload.refresh === true)
    Qt.callLater(function() { keyCatcher.forceActiveFocus() })
  }

  function close() {
    root.opened = false
  }

  function dismiss() {
    root.opened = false
    if (root.shell && typeof root.shell.hide === "function")
      root.shell.hide((root.manifest && root.manifest.id) || "omarchy.theme-browser")
  }

  function toggle() {
    if (root.opened) root.dismiss()
    else root.open("{}")
  }

  function refresh(force) {
    root.loading = true
    installedProc.running = true

    if (force === true) {
      root.refreshing = true
      root.catalogWarning = ""
      root.statusMessage = "Refreshing catalog\u2026"
      statusTimer.stop()
    }

    // The full catalog: it carries the description, licence and dates the
    // detail pane shows, and it is read from a local cache.
    catalogProc.command = [root.omarchyPath + "/bin/omarchy-theme-catalog", "--full"]
    if (force === true) catalogProc.command = catalogProc.command.concat(["--refresh"])
    catalogProc.running = true
  }

  function loadCatalog(raw) {
    var previous = root.generatedAt

    root.themes = ThemeCatalog.parseCatalog(raw)
    root.generatedAt = ThemeCatalog.generatedAt(raw)
    root.loading = false

    if (root.themes.length === 0) {
      root.loadError = "The theme catalog could not be read."
      root.reportRefresh(previous)
      return
    }

    root.loadError = ""
    root.reportRefresh(previous)
    root.rebuild()
    root.scrollToSelection()
    root.requestTiles()
  }

  // omarchy-theme-catalog serves the cached copy when it cannot reach the
  // registry and says so on stderr rather than failing, so success is not an
  // exit code here: the build stamp says whether anything newer arrived.
  readonly property string cacheFallbackMessage: "Could not reach the catalog \u00b7 showing the cached copy"

  function fellBackToCache() {
    return root.catalogWarning.indexOf("could not refresh") !== -1
  }

  function reportRefresh(previous) {
    if (!root.refreshing) return

    root.refreshing = false

    if (root.fellBackToCache()) {
      root.statusMessage = root.cacheFallbackMessage
    } else if (root.loadError) {
      root.statusMessage = root.loadError
    } else if (previous && root.generatedAt === previous) {
      root.statusMessage = "Catalog is already up to date"
    } else {
      root.statusMessage = "Catalog updated"
    }

    statusTimer.restart()
  }

  Timer {
    id: statusTimer
    interval: 4000
    onTriggered: root.statusMessage = ""
  }

  function rebuild() {
    var previous = root.current ? root.current.name : ""
    var before = root.selectedIndex
    root.filtered = ThemeCatalog.filterThemes(root.themes, root.filters, root.installedNames)

    // Keep the selection on the same theme when it survived the filter change.
    var index = 0
    for (var i = 0; i < root.filtered.length; i++) {
      if (root.filtered[i].name === previous) {
        index = i
        break
      }
    }
    root.selectedIndex = root.filtered.length > 0 ? index : 0

    // The catalog and the installed list arrive separately; a rebuild from the
    // second must not scroll the grid out from under the reader.
    if (root.selectedIndex !== before) root.scrollToSelection()
  }

  function scrollToSelection() {
    Qt.callLater(function() {
      if (root.filtered.length > 0) grid.positionViewAtIndex(root.selectedIndex, GridView.Contain)
    })
  }

  // Tiles are asked for in one batch and land as they arrive; the large preview
  // is only fetched for the theme being read.
  function requestTiles() {
    var names = []
    for (var i = 0; i < root.themes.length; i++) names.push(root.themes[i].name)
    if (names.length === 0) return
    tileProc.command = [root.omarchyPath + "/bin/omarchy-theme-catalog", "--previews", "--size", "480"].concat(names)
    tileProc.running = true
  }

  function requestPreview(name) {
    if (!name || root.previewPaths["full:" + name]) return
    previewProc.command = [root.omarchyPath + "/bin/omarchy-theme-catalog", "--previews", "--size", "1200", name]
    previewProc.running = true
  }

  function notePreview(line, prefix) {
    var parts = String(line || "").split("\t")
    if (parts.length < 2 || !parts[0]) return
    root.previewPaths[prefix + parts[0]] = "file://" + parts[1]
    root.previewRevision++
  }

  function tileFor(name) {
    if (root.previewRevision < 0) return ""
    return root.previewPaths["tile:" + name] || ""
  }

  function previewFor(name) {
    if (root.previewRevision < 0) return ""
    return root.previewPaths["full:" + name] || root.previewPaths["tile:" + name] || ""
  }

  // Label/value pairs with the empty ones dropped.
  function detailRows(theme) {
    var rows = []

    function add(label, value) {
      if (value) rows.push({ label: label, value: String(value) })
    }

    add("Mode", [theme.mode, theme.hue].filter(function(v) { return v }).join(" · "))
    add("Licence", theme.license)
    add("Layout", theme.generation)
    add("Stars", theme.stars > 0 ? String(theme.stars) : "")
    add("Listed", theme.addedAt)
    add("Backgrounds", theme.backgroundCount > 0
      ? theme.backgroundCount + " · " + ThemeCatalog.humanBytes(theme.backgroundBytes)
        + (theme.hasVideo ? " · video" : "")
      : "")
    add("Not installed", theme.ignoredOnInstall.join(" "))
    return rows
  }

  function isInstalled(name) {
    return root.installedNames.indexOf(name) !== -1
  }

  function setSearch(next) {
    var filters = {}
    for (var key in root.filters) filters[key] = root.filters[key]
    filters.search = next
    root.filters = filters
    root.rebuild()
  }

  function applyToggle(key) {
    root.filters = ThemeCatalog.toggleFilter(root.filters, key)
    root.rebuild()
  }

  function clearFilters() {
    root.filters = ThemeCatalog.emptyFilters()
    root.rebuild()
  }

  function move(delta, wrap) {
    if (root.filtered.length === 0) return
    root.selectedIndex = ThemeCatalog.movedIndex(root.selectedIndex, root.filtered.length, delta, wrap)
    grid.positionViewAtIndex(root.selectedIndex, GridView.Contain)
    root.lastPointerX = -1
    root.lastPointerY = -1
  }

  function visibleRows() {
    return Math.max(1, Math.floor(grid.height / root.cellHeight))
  }

  function install() {
    if (!root.current) return
    var name = root.current.name
    root.dismiss()
    Quickshell.execDetached([root.omarchyPath + "/bin/omarchy-launch-floating-terminal-with-presentation",
      "omarchy-theme-install " + name])
  }

  function openThemePage() {
    if (!root.current) return
    Quickshell.execDetached([root.omarchyPath + "/bin/omarchy-launch-browser",
      "https://themes.omarchy.org/themes/" + root.current.name])
  }

  onCurrentChanged: if (root.current) root.requestPreview(root.current.name)

  Process {
    id: catalogProc
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.loadCatalog(text)
    }
    // stdout finishes first, so the report goes out on the build stamp and the
    // specific reason replaces it once the warning lands.
    stderr: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        root.catalogWarning = String(text || "")
        if (root.statusMessage !== "" && root.fellBackToCache()) {
          root.statusMessage = root.cacheFallbackMessage
          statusTimer.restart()
        }
      }
    }
  }

  Process {
    id: installedProc
    command: [root.omarchyPath + "/bin/omarchy-theme-pinned", "--names"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        var names = String(text || "").trim()
        root.installedNames = names ? names.split("\n") : []
        if (root.themes.length > 0) root.rebuild()
      }
    }
  }

  Process {
    id: tileProc
    stdout: SplitParser {
      onRead: function(line) { root.notePreview(line, "tile:") }
    }
  }

  Process {
    id: previewProc
    stdout: SplitParser {
      onRead: function(line) { root.notePreview(line, "full:") }
    }
  }

  PanelWindow {
    id: panel
    visible: root.opened
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    WlrLayershell.namespace: "omarchy-theme-browser"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    exclusionMode: ExclusionMode.Ignore

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
          // Plain keys type into the search; Alt is what the toggles get.
          if (event.modifiers & Qt.AltModifier) {
            var slot = event.key - Qt.Key_1
            if (slot >= 0 && slot < ThemeCatalog.TOGGLES.length) root.applyToggle(ThemeCatalog.TOGGLES[slot].key)
            else return
          } else if (event.key === Qt.Key_Escape) {
            if (root.filters.search) root.setSearch("")
            else if (ThemeCatalog.activeCount(root.filters) > 0) root.clearFilters()
            else root.dismiss()
          } else if (Util.editsFilter(event, root.filters.search)) {
            root.setSearch(Util.editedFilter(event, root.filters.search))
          } else if (event.key === Qt.Key_Left) {
            root.move(-1, true)
          } else if (event.key === Qt.Key_Right) {
            root.move(1, true)
          } else if (event.key === Qt.Key_Up) {
            root.move(-root.columns, false)
          } else if (event.key === Qt.Key_Down) {
            root.move(root.columns, false)
          } else if (event.key === Qt.Key_PageUp) {
            root.move(-root.columns * root.visibleRows(), false)
          } else if (event.key === Qt.Key_PageDown) {
            root.move(root.columns * root.visibleRows(), false)
          } else if (event.key === Qt.Key_Home) {
            root.move(-root.filtered.length, false)
          } else if (event.key === Qt.Key_End) {
            root.move(root.filtered.length, false)
          } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            root.install()
          } else if (event.key === Qt.Key_O && (event.modifiers & Qt.ControlModifier)) {
            root.openThemePage()
          } else if (event.key === Qt.Key_R && (event.modifiers & Qt.ControlModifier)) {
            root.refresh(true)
          } else if (event.text && event.text.length === 1 && event.text.charCodeAt(0) >= 32 && event.text.charCodeAt(0) !== 127) {
            root.setSearch(root.filters.search + event.text)
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
        spacing: root.contentSpacing

        // ------------------------------------------------------------ header
        Item {
          width: parent.width
          height: root.headerHeight

          Text {
            id: searchText
            textFormat: Text.PlainText
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: Math.min(implicitWidth, parent.width - scopeRow.width - Style.spacing.lg)
            text: root.filters.search || "Search themes…"
            color: root.foreground
            opacity: root.filters.search ? 1 : 0.55
            font.family: root.fontFamily
            font.pixelSize: Style.font.heading
            elide: Text.ElideRight
          }

          Row {
            id: scopeRow
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: Style.spacing.sm

            Repeater {
              model: ThemeCatalog.TOGGLES

              Rectangle {
                id: chip
                required property int index
                required property var modelData

                readonly property bool active: root.filters[modelData.key] === true

                radius: root.cornerRadius
                color: active ? root.selectedBackground : "transparent"
                border.width: active ? 0 : 1
                border.color: Util.alpha(root.foreground, 0.18)
                height: Style.font.bodySmall + Style.spacing.sm * 2
                width: chipLabel.implicitWidth + Style.spacing.controlPaddingX * 2

                Text {
                  id: chipLabel
                  textFormat: Text.PlainText
                  anchors.centerIn: parent
                  text: chip.modelData.label
                  color: chip.active ? root.selectedText : root.foreground
                  opacity: chip.active ? 1 : 0.55
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.bodySmall
                }

                MouseArea {
                  anchors.fill: parent
                  cursorShape: Qt.PointingHandCursor
                  onClicked: root.applyToggle(chip.modelData.key)
                }
              }
            }
          }
        }

        // ------------------------------------------------- grid + detail pane
        Item {
          width: parent.width
          height: parent.height - root.headerHeight - footer.height - root.contentSpacing * 2

          Item {
            id: gridHolder
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: root.gridWidth

            GridView {
              id: grid
              anchors.fill: parent
              model: root.filtered
              clip: true
              cellWidth: root.cellWidth
              cellHeight: root.cellHeight
              boundsBehavior: Flickable.StopAtBounds
              visible: root.filtered.length > 0

              delegate: Item {
                required property int index
                required property var modelData

                readonly property bool hasCursor: index === root.selectedIndex

                width: root.cellWidth
                height: root.cellHeight

                Rectangle {
                  anchors.fill: parent
                  anchors.leftMargin: root.tileGapX
                  anchors.rightMargin: root.tileGapX
                  anchors.topMargin: root.tileGapY
                  anchors.bottomMargin: root.tileGapY
                  radius: root.cornerRadius
                  color: parent.hasCursor ? root.selectedBackground : "transparent"
                  border.width: parent.hasCursor ? Math.max(1, Style.space(2)) : 0
                  border.color: root.selectedText

                  Column {
                    anchors.fill: parent
                    anchors.margins: Style.spacing.sm
                    spacing: Style.spacing.sm

                    Rectangle {
                      width: parent.width
                      height: Math.round(width * 9 / 16)
                      radius: Math.max(2, root.cornerRadius - 2)
                      clip: true
                      // The theme's own background until its preview lands.
                      color: modelData.background || root.background

                      Image {
                        anchors.fill: parent
                        source: root.tileFor(modelData.name)
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        cache: false
                        sourceSize.width: root.cellWidth * 2
                        visible: status === Image.Ready
                      }

                      Rectangle {
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: Style.spacing.sm
                        visible: root.isInstalled(modelData.name)
                        radius: height / 2
                        height: Style.font.bodySmall + Style.spacing.xs * 2
                        width: installedLabel.implicitWidth + Style.spacing.md * 2
                        color: root.background
                        opacity: 0.85

                        Text {
                          id: installedLabel
                          textFormat: Text.PlainText
                          anchors.centerIn: parent
                          text: "Installed"
                          color: root.foreground
                          font.family: root.fontFamily
                          font.pixelSize: Style.font.bodySmall
                        }
                      }
                    }

                    Row {
                      width: parent.width
                      height: root.tileTitleHeight
                      spacing: Style.spacing.sm

                      Rectangle {
                        width: Style.space(3)
                        height: Style.font.body
                        radius: width / 2
                        anchors.verticalCenter: parent.verticalCenter
                        color: modelData.accent || root.foreground
                      }

                      Text {
                        textFormat: Text.PlainText
                        width: parent.width - Style.space(3) - Style.spacing.sm
                        height: parent.height
                        verticalAlignment: Text.AlignVCenter
                        text: modelData.title
                        color: root.foreground
                        font.family: root.fontFamily
                        font.pixelSize: Style.font.body
                        elide: Text.ElideRight
                      }
                    }

                    Text {
                      textFormat: Text.PlainText
                      width: parent.width
                      height: root.tileArtistHeight
                      verticalAlignment: Text.AlignVCenter
                      text: modelData.artist
                      color: root.foreground
                      opacity: 0.5
                      font.family: root.fontFamily
                      font.pixelSize: Style.font.bodySmall
                      elide: Text.ElideRight
                    }
                  }
                }

                MouseArea {
                  anchors.fill: parent
                  hoverEnabled: true
                  cursorShape: Qt.PointingHandCursor
                  onPositionChanged: function(mouse) {
                    var global = mapToGlobal(mouse.x, mouse.y)
                    if (root.pointerMovedTo(global.x, global.y)) root.selectedIndex = index
                  }
                  onClicked: {
                    root.selectedIndex = index
                    root.install()
                  }
                }
              }
            }

            Column {
              anchors.centerIn: parent
              spacing: Style.spacing.lg
              visible: root.filtered.length === 0

              Text {
                textFormat: Text.PlainText
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: root.loading ? "Loading the catalog…"
                  : root.loadError ? root.loadError
                  : "Nothing matches those filters."
                color: root.foreground
                opacity: 0.7
                font.family: root.fontFamily
                font.pixelSize: Style.font.title
              }
            }
          }

          // ----------------------------------------------------- detail pane
          Flickable {
            anchors.right: parent.right
            anchors.top: parent.top
            // Level with the first row's previews, which sit a row gutter and a
            // card inset below the top of the grid.
            anchors.topMargin: root.tileGapY + Style.spacing.sm
            anchors.bottom: parent.bottom
            width: root.detailWidth
            contentWidth: width
            contentHeight: detail.height
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            visible: root.current !== null

            Column {
              id: detail
              width: parent.width
              spacing: Style.spacing.md

              Rectangle {
                width: parent.width
                height: Math.round(width * 9 / 16)
                radius: Math.max(2, root.cornerRadius - 2)
                clip: true
                color: root.current ? (root.current.background || root.background) : root.background

                Image {
                  anchors.fill: parent
                  source: root.current ? root.previewFor(root.current.name) : ""
                  fillMode: Image.PreserveAspectCrop
                  asynchronous: true
                  cache: false
                  sourceSize.width: root.detailWidth * 2
                  visible: status === Image.Ready
                }
              }

              Row {
                width: parent.width
                spacing: Style.spacing.sm

                Text {
                  id: detailTitle
                  textFormat: Text.PlainText
                  width: Math.min(implicitWidth, parent.width - detailArtist.width - parent.spacing)
                  text: root.current ? root.current.title : ""
                  color: root.foreground
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.heading
                  elide: Text.ElideRight
                }

                Text {
                  id: detailArtist
                  textFormat: Text.PlainText
                  anchors.baseline: detailTitle.baseline
                  visible: text !== ""
                  text: root.current && root.current.artist ? "By " + root.current.artist : ""
                  color: root.foreground
                  opacity: 0.6
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.body
                }
              }

              Text {
                textFormat: Text.PlainText
                width: parent.width
                visible: text !== ""
                wrapMode: Text.WordWrap
                maximumLineCount: 3
                elide: Text.ElideRight
                text: root.current ? root.current.description : ""
                color: root.foreground
                opacity: 0.75
                font.family: root.fontFamily
                font.pixelSize: Style.font.body
              }

              Row {
                width: parent.width
                spacing: Style.spacing.xs
                visible: root.current !== null && root.current.palette.length > 0

                Repeater {
                  model: root.current ? root.current.palette : []

                  Rectangle {
                    required property string modelData

                    width: Math.floor((detail.width - Style.spacing.xs * 8) / 9)
                    height: Style.space(20)
                    radius: Math.max(2, root.cornerRadius - 2)
                    color: modelData
                    border.width: 1
                    border.color: Util.alpha(root.foreground, 0.2)
                  }
                }
              }

              DetailTable {
                Repeater {
                  model: root.current ? root.detailRows(root.current) : []

                  DetailRow {
                    required property var modelData
                    required property int index

                    label: modelData.label
                    value: modelData.value
                    divided: index > 0
                  }
                }
              }
            }
          }
        }

        // ------------------------------------------------------------ footer
        Item {
          id: footer
          width: parent.width
          height: Math.max(counter.height, hints.height) + Style.spacing.md
          clip: true

          Text {
            id: counter
            textFormat: Text.PlainText
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.topMargin: Style.spacing.md
            text: root.statusMessage
              || root.filtered.length + (root.filtered.length === 1 ? " theme" : " themes")
            color: root.statusMessage ? root.selectedText : root.foreground
            opacity: root.statusMessage ? 0.9 : 0.45
            font.family: root.fontFamily
            font.pixelSize: Style.font.bodySmall
          }

          // A Row, not a Flow: binding a Flow's width to its implicitWidth
          // collapses it to one hint per line. The footer clips instead.
          Row {
            id: hints
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: Style.spacing.md
            spacing: Style.spacing.xl

            Repeater {
              model: root.shortcutHints

              Row {
                required property var modelData

                spacing: Style.spacing.sm

                Text {
                  textFormat: Text.PlainText
                  text: modelData.keys
                  color: root.selectedText
                  opacity: 0.85
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.bodySmall
                }

                Text {
                  textFormat: Text.PlainText
                  text: modelData.action
                  color: root.foreground
                  opacity: 0.45
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.bodySmall
                }
              }
            }
          }
        }
      }
    }
  }

  // The catalog's facts as a bordered table: hairlines between rows, the label
  // dimmed on the left, the value on the right. A row with no label is a plain
  // line of text, which is what the notes are.
  component DetailTable: Rectangle {
    default property alias rows: tableRows.data

    width: parent ? parent.width : 0
    height: tableRows.height
    radius: Math.max(2, root.cornerRadius - 2)
    color: Util.alpha(root.foreground, 0.03)
    border.width: 1
    border.color: Util.alpha(root.foreground, 0.12)

    Column {
      id: tableRows
      width: parent.width
    }
  }

  component DetailRow: Item {
    id: row

    property string label: ""
    property string value: ""
    property bool divided: true

    width: parent ? parent.width : 0
    height: Math.max(rowLabel.implicitHeight, rowValue.implicitHeight) + Style.spacing.sm * 2

    Rectangle {
      visible: row.divided
      width: parent.width
      height: 1
      color: Util.alpha(root.foreground, 0.08)
    }

    Text {
      id: rowLabel
      textFormat: Text.PlainText
      anchors.left: parent.left
      anchors.leftMargin: Style.spacing.md
      anchors.verticalCenter: parent.verticalCenter
      width: row.label ? root.detailLabelWidth : 0
      text: row.label
      color: root.foreground
      opacity: 0.5
      font.family: root.fontFamily
      font.pixelSize: Style.font.bodySmall
      elide: Text.ElideRight
    }

    Text {
      id: rowValue
      textFormat: Text.PlainText
      anchors.left: rowLabel.right
      anchors.right: parent.right
      anchors.leftMargin: row.label ? Style.spacing.md : 0
      anchors.rightMargin: Style.spacing.md
      anchors.verticalCenter: parent.verticalCenter
      horizontalAlignment: row.label ? Text.AlignRight : Text.AlignLeft
      text: row.value
      color: root.foreground
      opacity: 0.9
      font.family: root.fontFamily
      font.pixelSize: Style.font.bodySmall
      wrapMode: Text.WrapAtWordBoundaryOrAnywhere
      maximumLineCount: 3
      elide: Text.ElideRight
    }
  }
}
