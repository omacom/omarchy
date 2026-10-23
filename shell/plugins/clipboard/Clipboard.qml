import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import qs.Commons
import qs.Commons as Commons
import qs.Ui
import "ClipboardHistory.js" as ClipboardHistory

Item {
  id: root

  property string omarchyPath: Quickshell.env("OMARCHY_PATH")
  property bool opened: false
  property string filterText: ""
  property int selectedIndex: 0
  property bool cursorActive: false
  property bool clearConfirmOpen: false
  property var history: []
  // Pinboards are named tabs of pinned entries; "" is the history tab.
  property var pinboards: []
  property string currentPinboard: ""
  property string kindFilter: "all"
  // The pin picker names a board to pin the selected entry to, or the new
  // name of the current board when renaming.
  property bool pinPickerOpen: false
  property bool pinPickerRenames: false
  property string pinPickerText: ""
  property int pinPickerIndex: 0
  property bool deletePinboardConfirmOpen: false
  property int quickPasteIndex: -1
  readonly property bool dialogOpen: root.clearConfirmOpen || root.deletePinboardConfirmOpen

  property string historyPath: Quickshell.env("HOME") + "/.local/state/omarchy/clipboard-history.json"
  property string pinboardsPath: Quickshell.env("HOME") + "/.local/state/omarchy/clipboard-pinboards.json"
  property string captureScript: root.omarchyPath + "/shell/plugins/clipboard/capture.sh"
  // Shares the [menu] surface tokens — themes that style the menu also
  // style the clipboard. Selected-row colors composed in the
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
  property int cardWidth: Math.min(Style.space(875), panel.width - Style.gapsOut * 2)
  property int cardHeight: Math.min(Style.space(600), panel.height - Style.gapsOut * 2)
  property int rowHeight: Math.max(Style.space(50), Style.font.body + Style.font.caption + Style.spacing.rowPaddingX * 2)
  property int chipHeight: Style.font.body + Style.spacing.controlPaddingY * 2
  property int historyLimit: 500

  function open(payloadJson) {
    root.opened = true
    root.filterText = ""
    root.selectedIndex = 0
    root.cursorActive = true
    root.pinPickerOpen = false
    root.deletePinboardConfirmOpen = false
    root.quickPasteIndex = -1
    if (root.pinboards.indexOf(root.currentPinboard) < 0) root.currentPinboard = ""
    root.disarmPointer()
    root.rebuildDisplay()
    Qt.callLater(function() { keyCatcher.forceActiveFocus() })
  }

  function close() {
    root.cancelClearHistory()
    root.pinPickerOpen = false
    root.deletePinboardConfirmOpen = false
    root.opened = false
  }

  function toggle() {
    if (root.opened) root.close()
    else root.open("{}")
  }

  function normalizeEntry(value) {
    return ClipboardHistory.normalizeEntry(value)
  }

  function entryKey(entry) {
    return ClipboardHistory.entryKey(entry)
  }

  function loadHistory(raw) {
    root.history = ClipboardHistory.parseHistory(raw)
    root.pinboards = ClipboardHistory.pinboardList(root.pinboards, root.history)
    if (root.opened) root.rebuildDisplay()
  }

  function loadPinboards(raw) {
    root.pinboards = ClipboardHistory.pinboardList(ClipboardHistory.parsePinboards(raw), root.history)
    if (root.opened) root.rebuildDisplay()
  }

  function savePinboards() {
    pinboardsFile.setText(JSON.stringify(root.pinboards, null, 2) + "\n")
  }

  function saveHistory() {
    // addEntry already trims unpinned entries to the limit. Slicing here would
    // cut pins that sit past it, and shift the indexes the paste helpers read.
    historyFile.setText(JSON.stringify(root.history, null, 2) + "\n")
  }

  function addClipboardEntry(entry) {
    var normalized = ClipboardHistory.normalizeEntry(entry)
    if (!normalized) return

    // The focused window is where the copy came from; a re-copy keeps the app
    // the entry first came from.
    var active = ToplevelManager.activeToplevel
    if (active && active.appId) normalized.app = String(active.appId)
    normalized.copiedAt = Date.now()

    root.history = ClipboardHistory.addEntry(root.history, normalized, root.historyLimit)
    root.saveHistory()
    if (root.opened) root.rebuildDisplay()
  }

  function addClipboardJson(line) {
    root.addClipboardEntry(ClipboardHistory.parseEntryJson(line))
  }

  function requestClearHistory() {
    if (root.history.length === 0) return
    clearConfirm.selectedIndex = 1
    root.clearConfirmOpen = true
  }

  function cancelClearHistory() {
    root.clearConfirmOpen = false
    root.disarmPointer()
    Qt.callLater(function() { keyCatcher.forceActiveFocus() })
  }

  function confirmClearHistory() {
    root.history = ClipboardHistory.clearHistory(root.history)
    root.saveHistory()
    root.selectedIndex = 0
    root.cursorActive = false
    root.disarmPointer()
    root.clearConfirmOpen = false
    root.rebuildDisplay()
    Qt.callLater(function() { keyCatcher.forceActiveFocus() })
  }

  function removeDisplayIndex(index) {
    if (index < 0 || index >= displayModel.count) return

    var row = displayModel.get(index)
    if (root.currentPinboard) root.history = ClipboardHistory.unpinEntryAt(root.history, row.historyIndex)
    else root.history = ClipboardHistory.removeEntryAt(root.history, row.historyIndex)
    root.saveHistory()

    if (displayModel.count <= 1) {
      root.selectedIndex = 0
      root.cursorActive = false
    } else if (root.selectedIndex >= displayModel.count - 1) {
      root.selectedIndex = displayModel.count - 2
    }

    root.disarmPointer()
    root.rebuildDisplay()
  }

  function rebuildDisplay() {
    // A pending quick paste names a row position, which a rebuilt list
    // (a new copy, another filter) gives to another entry.
    root.quickPasteIndex = -1
    var rows = ClipboardHistory.displayRows(root.history, root.filterText, 50, Commons.I18n.t, Commons.I18n.tn, Commons.I18n.formatNumber, { pinboard: root.currentPinboard, kind: root.kindFilter })

    displayModel.clear()
    for (var i = 0; i < rows.length; i++) {
      var row = rows[i]
      displayModel.append({
        entryType: row.entryType,
        fullText: row.fullText,
        previewText: row.previewText,
        previewImage: row.previewImage ? Util.fileUrl(row.previewImage) : "",
        path: row.path,
        mime: row.mime,
        kind: row.kind,
        pinboard: row.pinboard,
        app: row.app,
        copiedAt: row.copiedAt,
        textLength: row.textLength,
        historyIndex: row.index
      })
    }

    if (displayModel.count === 0) selectedIndex = 0
    else if (selectedIndex >= displayModel.count) selectedIndex = displayModel.count - 1
    else if (selectedIndex < 0) selectedIndex = 0

    Qt.callLater(function() {
      if (displayModel.count > 0) resultList.positionViewAtIndex(root.selectedIndex, ListView.Contain)
    })
  }

  // Preview text is composed imperatively, so rebuild it when the
  // language (and with it the string catalog) changes under an open panel.
  Connections {
    target: Commons.I18n
    function onStringsChanged() { if (root.opened) root.rebuildDisplay() }
  }

  function select(delta) {
    if (displayModel.count === 0) return
    root.disarmPointer()
    if (!cursorActive) {
      cursorActive = true
      selectedIndex = delta < 0 ? displayModel.count - 1 : 0
    } else {
      selectedIndex = (selectedIndex + delta + displayModel.count) % displayModel.count
    }
    resultList.positionViewAtIndex(selectedIndex, ListView.Contain)
  }

  function selectAbsolute(index) {
    if (displayModel.count === 0) return
    root.disarmPointer()
    root.cursorActive = true
    root.selectedIndex = Math.max(0, Math.min(index, displayModel.count - 1))
    resultList.positionViewAtIndex(root.selectedIndex, ListView.Contain)
  }

  function setFilter(nextFilter) {
    root.filterText = nextFilter
    root.selectedIndex = 0
    root.cursorActive = true
    root.disarmPointer()
    root.rebuildDisplay()
  }

  function showTab(pinboard) {
    root.currentPinboard = pinboard
    root.selectedIndex = 0
    root.cursorActive = true
    root.disarmPointer()
    root.rebuildDisplay()
  }

  // History is the first tab, then each pinboard in order.
  function switchTab(delta) {
    var tabs = [""].concat(root.pinboards)
    var index = Math.max(0, tabs.indexOf(root.currentPinboard))
    root.showTab(tabs[(index + delta + tabs.length) % tabs.length])
  }

  function setKind(kind) {
    root.kindFilter = kind
    root.selectedIndex = 0
    root.cursorActive = true
    root.disarmPointer()
    root.rebuildDisplay()
  }

  // Boards the picker offers for the typed text: matching boards first, then
  // a row that creates a board named after the text when none has that name.
  function pinPickerRows() {
    var needle = root.pinPickerText.trim().toLowerCase()
    var rows = []
    if (!root.pinPickerRenames) {
      for (var i = 0; i < root.pinboards.length; i++) {
        if (!needle || root.pinboards[i].toLowerCase().indexOf(needle) >= 0) rows.push({ name: root.pinboards[i], create: false })
      }
    }
    var typed = ClipboardHistory.pinboardName(root.pinPickerText)
    if (typed && root.pinboards.indexOf(typed) < 0) rows.push({ name: typed, create: true })
    return rows
  }

  function openPinPicker(renames) {
    if (renames ? !root.currentPinboard : (!root.cursorActive || displayModel.count === 0)) return
    root.pinPickerRenames = renames
    root.pinPickerText = renames ? root.currentPinboard : ""
    root.pinPickerIndex = 0
    root.pinPickerOpen = true
  }

  function closePinPicker() {
    root.pinPickerOpen = false
    root.disarmPointer()
    Qt.callLater(function() { keyCatcher.forceActiveFocus() })
  }

  function choosePinPickerRow(index) {
    var rows = root.pinPickerRows()
    if (index < 0 || index >= rows.length) return
    var name = rows[index].name
    if (root.pinPickerRenames) root.renameCurrentPinboard(name)
    else root.pinSelectedTo(name)
    root.closePinPicker()
  }

  // Names are bounded before they are compared, as the history file stores
  // them, so a long name cannot slip past the duplicate check and merge boards.
  function pinSelectedTo(value) {
    var name = ClipboardHistory.pinboardName(value)
    if (!name || !root.cursorActive || root.selectedIndex < 0 || root.selectedIndex >= displayModel.count) return
    var row = displayModel.get(root.selectedIndex)
    root.history = ClipboardHistory.pinEntryAt(root.history, row.historyIndex, name)
    if (root.pinboards.indexOf(name) < 0) {
      root.pinboards = root.pinboards.concat([name])
      root.savePinboards()
    }
    root.saveHistory()
    root.rebuildDisplay()
  }

  function renameCurrentPinboard(value) {
    var name = ClipboardHistory.pinboardName(value)
    var from = root.currentPinboard
    if (!from || !name || name === from || root.pinboards.indexOf(name) >= 0) return
    root.history = ClipboardHistory.renamePinboard(root.history, from, name)
    root.pinboards = root.pinboards.map(function(board) { return board === from ? name : board })
    root.currentPinboard = name
    root.saveHistory()
    root.savePinboards()
    root.rebuildDisplay()
  }

  function requestDeletePinboard() {
    if (!root.currentPinboard) return
    deletePinboardConfirm.selectedIndex = 1
    root.deletePinboardConfirmOpen = true
  }

  function cancelDeletePinboard() {
    root.deletePinboardConfirmOpen = false
    root.disarmPointer()
    Qt.callLater(function() { keyCatcher.forceActiveFocus() })
  }

  function confirmDeletePinboard() {
    var board = root.currentPinboard
    root.history = ClipboardHistory.removePinboard(root.history, board)
    root.pinboards = root.pinboards.filter(function(name) { return name !== board })
    root.saveHistory()
    root.savePinboards()
    root.deletePinboardConfirmOpen = false
    root.showTab("")
    Qt.callLater(function() { keyCatcher.forceActiveFocus() })
  }

  function handlePinPickerKey(event) {
    var rows = root.pinPickerRows()
    if (event.key === Qt.Key_Escape) {
      root.closePinPicker()
    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
      root.choosePinPickerRow(root.pinPickerIndex)
    } else if (event.key === Qt.Key_Up) {
      if (rows.length > 0) root.pinPickerIndex = (root.pinPickerIndex - 1 + rows.length) % rows.length
    } else if (event.key === Qt.Key_Down || event.key === Qt.Key_Tab) {
      if (rows.length > 0) root.pinPickerIndex = (root.pinPickerIndex + 1) % rows.length
    } else if (Util.editsFilter(event, root.pinPickerText)) {
      root.pinPickerText = Util.editedFilter(event, root.pinPickerText)
      root.pinPickerIndex = 0
    } else if (event.text && event.text.length === 1 && event.text.charCodeAt(0) >= 32 && event.text.charCodeAt(0) !== 127 && !(event.modifiers & Qt.ControlModifier)) {
      root.pinPickerText = root.pinPickerText + event.text
      root.pinPickerIndex = 0
    } else {
      return false
    }
    return true
  }

  // Name of the app an entry was copied from, from its desktop entry when one
  // claims the window's app id.
  function appName(appId) {
    if (!appId) return ""
    var entry = DesktopEntries.heuristicLookup(appId)
    return entry && entry.name ? String(entry.name) : String(appId)
  }

  function copiedAtText(ms) {
    if (!ms) return ""
    var date = new Date(ms)
    var locale = Qt.locale(Commons.I18n.formatLocale)
    var time = date.toLocaleTimeString(locale, Locale.ShortFormat)
    if (date.toDateString() === new Date().toDateString()) return Commons.I18n.t("clipboard.today").arg(time)
    return date.toLocaleString(locale, Locale.ShortFormat)
  }

  function detailsText(row) {
    if (!row) return ""
    var parts = []
    if (row.pinboard && !root.currentPinboard) parts.push("\uDB81\uDC03 " + row.pinboard)
    if (row.app) parts.push(root.appName(row.app))
    if (row.copiedAt) parts.push(root.copiedAtText(row.copiedAt))
    if (row.textLength > 0) parts.push(ClipboardHistory.characterCount(row.textLength, Commons.I18n.tn, Commons.I18n.formatNumber))
    return parts.join("  ·  ")
  }

  // Ctrl+number selects the row, and the paste waits for Ctrl to come up:
  // pasting sends Shift+Insert, which a held Ctrl turns into Ctrl+Shift+Insert.
  function queueQuickPaste(index) {
    if (index < 0 || index >= displayModel.count) return
    root.selectAbsolute(index)
    root.quickPasteIndex = index
  }

  // Which of the keys 1–9 on the number row was pressed, or -1. AZERTY and
  // other layouts put symbols there unshifted (Ctrl+2 arrives as Ctrl+é), so
  // fall back to the key's position: XKB keycodes 10–18 are that row.
  function digitRowIndex(event) {
    if (event.key >= Qt.Key_1 && event.key <= Qt.Key_9) return event.key - Qt.Key_1
    if (event.nativeScanCode >= 10 && event.nativeScanCode <= 18) return event.nativeScanCode - 10
    return -1
  }

  function disarmPointer() {
    pointerGate.reset()
  }

  function selectFromPointer(index, item, mouse) {
    if (!pointerGate.moved(item, mouse)) return
    root.cursorActive = true
    root.selectedIndex = index
  }

  function activateIndex(index) {
    if (index < 0 || index >= displayModel.count) return
    var row = displayModel.get(index)
    root.applySelected(row)
  }

  function copyIndex(index) {
    if (index < 0 || index >= displayModel.count) return
    var row = displayModel.get(index)
    root.copySelected(row)
  }

  function openIndex(index) {
    if (index < 0 || index >= displayModel.count) return
    var row = displayModel.get(index)
    root.openSelected(row)
  }

  function applySelected(row) {
    if (!row) return
    root.opened = false
    if (row.entryType === "image") {
      Quickshell.execDetached([root.omarchyPath + "/bin/omarchy-clipboard-paste-file", row.mime, row.path])
    } else if (row.fullText) {
      Quickshell.execDetached([root.omarchyPath + "/bin/omarchy-clipboard-paste-text", "--shift-insert", "--history-index", String(row.historyIndex)])
    }
  }

  function copySelected(row) {
    if (!row) return
    root.opened = false
    if (row.entryType === "image") {
      Quickshell.execDetached([root.omarchyPath + "/bin/omarchy-clipboard-paste-file", "--copy-only", row.mime, row.path])
    } else if (row.fullText) {
      Quickshell.execDetached([root.omarchyPath + "/bin/omarchy-clipboard-paste-text", "--copy-only", "--history-index", String(row.historyIndex)])
    }
  }

  function openSelected(row) {
    if (!row) return
    root.opened = false
    Quickshell.execDetached([root.omarchyPath + "/bin/omarchy-clipboard-open", "--history-index", String(row.historyIndex)])
  }

  Component.onCompleted: initProc.running = true

  ListModel { id: displayModel }

  PointerMoveGate {
    id: pointerGate
    referenceItem: card
  }

  FileView {
    id: historyFile
    path: root.historyPath
    watchChanges: true
    atomicWrites: true
    printErrors: false
    onLoaded: root.loadHistory(text())
    onLoadFailed: root.loadHistory("[]")
    onFileChanged: reload()
  }

  FileView {
    id: pinboardsFile
    path: root.pinboardsPath
    watchChanges: true
    atomicWrites: true
    printErrors: false
    onLoaded: root.loadPinboards(text())
    onLoadFailed: root.loadPinboards("[]")
    onFileChanged: reload()
  }

  // Reap watchers left behind by a previous shell instance, then start our
  // own. The pdeathsig on the watchers makes the kernel kill them whenever
  // the shell exits, however it exits, so no further lifecycle management.
  Process {
    id: initProc
    command: ["pkill", "-f", "wl-paste .*--watch .*/shell/plugins/clipboard/capture\\.sh"]
    onExited: {
      currentProc.running = true
      textWatchProc.running = true
      imageWatchProc.running = true
    }
  }

  Process {
    id: currentProc
    command: [root.captureScript]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.addClipboardJson(text)
    }
  }

  Process {
    id: textWatchProc
    command: ["setpriv", "--pdeathsig", "TERM", "wl-paste", "--type", "text", "--watch", root.captureScript, "text"]
    onExited: watchRestartTimer.restart()
    stdout: SplitParser {
      onRead: function(data) { root.addClipboardJson(data) }
    }
  }

  Process {
    id: imageWatchProc
    command: ["setpriv", "--pdeathsig", "TERM", "wl-paste", "--type", "image/png", "--watch", root.captureScript, "image/png"]
    onExited: watchRestartTimer.restart()
    stdout: SplitParser {
      onRead: function(data) { root.addClipboardJson(data) }
    }
  }

  // A watcher that dies takes clipboard history with it, silently: copying still
  // works, the picker still opens, and the old entries are all still there, so
  // nothing recorded until the next shell reload. Bring it back instead.
  Timer {
    id: watchRestartTimer
    interval: 1000
    repeat: false
    onTriggered: {
      if (!textWatchProc.running) textWatchProc.running = true
      if (!imageWatchProc.running) imageWatchProc.running = true
    }
  }

  OverlayWindow {
    id: panel
    shown: root.opened
    WlrLayershell.namespace: "omarchy-clipboard"

    Rectangle {
      anchors.fill: parent
      color: root.scrim
    }

    MouseArea {
      anchors.fill: parent
      onClicked: root.close()
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
        z: root.dialogOpen || root.pinPickerOpen ? 20 : 0
        focus: true

        Keys.priority: Keys.BeforeItem
        Keys.onReleased: function(event) {
          if (event.key === Qt.Key_Control && root.quickPasteIndex >= 0) {
            var index = root.quickPasteIndex
            root.quickPasteIndex = -1
            root.activateIndex(index)
            event.accepted = true
          }
        }
        Keys.onPressed: function(event) {
          if (root.clearConfirmOpen) {
            if (clearConfirm.handleKey(event)) event.accepted = true
            return
          }
          if (root.deletePinboardConfirmOpen) {
            if (deletePinboardConfirm.handleKey(event)) event.accepted = true
            return
          }
          if (root.pinPickerOpen) {
            if (root.handlePinPickerKey(event)) event.accepted = true
            return
          }

          var control = (event.modifiers & Qt.ControlModifier) !== 0

          if (event.key === Qt.Key_Escape) {
            if (root.filterText) root.setFilter("")
            else root.close()
            event.accepted = true
          } else if (Util.editsFilter(event, root.filterText)) {
            root.setFilter(Util.editedFilter(event, root.filterText))
            event.accepted = true
          } else if (control && root.digitRowIndex(event) >= 0) {
            root.queueQuickPaste(root.digitRowIndex(event))
            event.accepted = true
          } else if (control && event.key === Qt.Key_P) {
            root.openPinPicker(false)
            event.accepted = true
          } else if (control && event.key === Qt.Key_T) {
            root.setKind(ClipboardHistory.nextKind(root.kindFilter, (event.modifiers & Qt.ShiftModifier) ? -1 : 1))
            event.accepted = true
          } else if (event.key === Qt.Key_F2) {
            root.openPinPicker(true)
            event.accepted = true
          } else if (event.key === Qt.Key_Tab || event.key === Qt.Key_Backtab) {
            root.switchTab(event.key === Qt.Key_Backtab ? -1 : 1)
            event.accepted = true
          } else if (!control && (Util.readingKey(event) === Qt.Key_Left || Util.readingKey(event) === Qt.Key_Right)) {
            root.switchTab(Util.readingKey(event) === Qt.Key_Left ? -1 : 1)
            event.accepted = true
          } else if (event.key === Qt.Key_Delete) {
            if ((event.modifiers & Qt.ShiftModifier) && root.currentPinboard) root.requestDeletePinboard()
            else if (event.modifiers & Qt.ShiftModifier) root.requestClearHistory()
            else root.removeDisplayIndex(root.selectedIndex)
            event.accepted = true
          } else if (event.key === Qt.Key_Up) {
            root.select(-1)
            event.accepted = true
          } else if (event.key === Qt.Key_Down) {
            root.select(1)
            event.accepted = true
          } else if (event.key === Qt.Key_PageUp) {
            root.select(-6)
            event.accepted = true
          } else if (event.key === Qt.Key_PageDown) {
            root.select(6)
            event.accepted = true
          } else if (event.key === Qt.Key_Home) {
            root.selectAbsolute(0)
            event.accepted = true
          } else if (event.key === Qt.Key_End) {
            root.selectAbsolute(displayModel.count - 1)
            event.accepted = true
          } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            if (root.cursorActive && (event.modifiers & Qt.AltModifier)) root.openIndex(root.selectedIndex)
            else if (root.cursorActive && (event.modifiers & Qt.ShiftModifier)) root.copyIndex(root.selectedIndex)
            else if (root.cursorActive) root.activateIndex(root.selectedIndex)
            else if (displayModel.count > 0) root.cursorActive = true
            event.accepted = true
          } else if (!control && event.text && event.text.length === 1 && event.text.charCodeAt(0) >= 32 && event.text.charCodeAt(0) !== 127) {
            root.setFilter(root.filterText + event.text)
            event.accepted = true
          }
        }

        ConfirmDialog {
          id: clearConfirm

          anchors.fill: parent
          opened: root.clearConfirmOpen
          z: 10
          message: Commons.I18n.t("clipboard.deleteHistory")
          confirmText: Commons.I18n.t("common.delete")
          background: root.background
          foreground: root.foreground
          scrim: root.scrim
          selectedBackground: root.selectedBackground
          selectedText: root.selectedText
          fontFamily: root.fontFamily
          cornerRadius: root.cornerRadius
          onCanceled: root.cancelClearHistory()
          onConfirmed: root.confirmClearHistory()
        }

        ConfirmDialog {
          id: deletePinboardConfirm

          anchors.fill: parent
          opened: root.deletePinboardConfirmOpen
          z: 10
          message: Commons.I18n.t("clipboard.deletePinboard").arg(root.currentPinboard)
          confirmText: Commons.I18n.t("common.delete")
          background: root.background
          foreground: root.foreground
          scrim: root.scrim
          selectedBackground: root.selectedBackground
          selectedText: root.selectedText
          fontFamily: root.fontFamily
          cornerRadius: root.cornerRadius
          onCanceled: root.cancelDeletePinboard()
          onConfirmed: root.confirmDeletePinboard()
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

          Row {
            id: kindChips
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: Style.space(4)

            Repeater {
              model: ClipboardHistory.kindOptions(Commons.I18n.t)

              Chip {
                required property var modelData
                label: modelData.label
                active: root.kindFilter === modelData.value
                onClicked: root.setKind(modelData.value)
              }
            }
          }

          Text {
            textFormat: Text.PlainText
            anchors.left: parent.left
            anchors.right: kindChips.left
            anchors.rightMargin: root.contentSpacing
            anchors.verticalCenter: parent.verticalCenter
            text: root.filterText || Commons.I18n.t("clipboard.search")
            color: root.foreground
            opacity: root.filterText ? 1 : 0.58
            font.family: root.fontFamily
            font.pixelSize: Style.font.heading
            elide: Text.ElideRight
          }
        }

        Flickable {
          id: tabBar
          width: parent.width
          height: root.chipHeight
          contentWidth: tabRow.width
          clip: true
          boundsBehavior: Flickable.StopAtBounds
          interactive: contentWidth > width

          Row {
            id: tabRow
            spacing: Style.space(4)

            Chip {
              label: Commons.I18n.t("clipboard.history")
              active: root.currentPinboard === ""
              onClicked: root.showTab("")
            }

            Repeater {
              model: root.pinboards

              Chip {
                required property string modelData
                label: "\uDB81\uDC03 " + modelData
                active: root.currentPinboard === modelData
                onClicked: root.showTab(modelData)
              }
            }
          }
        }

        Item {
          width: parent.width
          height: parent.height - root.headerHeight - root.chipHeight - hintsText.height - root.contentSpacing * 3

          Row {
            anchors.fill: parent
            spacing: 0

            Item {
              width: parent.width / 2
              height: parent.height
              clip: true

              ListView {
                id: resultList
                anchors.fill: parent
                anchors.rightMargin: root.contentMargin
                model: displayModel
                clip: true
                spacing: Style.space(4)
                boundsBehavior: Flickable.StopAtBounds

                delegate: Rectangle {
                  id: row
                  required property int index
                  required property string entryType
                  required property string previewText
                  required property string fullText
                  required property string previewImage
                  required property string pinboard

                  readonly property bool hasCursor: root.cursorActive && index === root.selectedIndex

                  width: ListView.view.width
                  height: root.rowHeight
                  radius: root.cornerRadius
                  color: hasCursor ? root.selectedBackground : "transparent"

                  Row {
                    anchors.fill: parent
                    anchors.leftMargin: Style.space(12)
                    anchors.rightMargin: Style.space(12)
                    anchors.topMargin: Style.space(8)
                    anchors.bottomMargin: Style.space(8)
                    spacing: Style.space(10)

                    SizedImage {
                      visible: parent.parent.previewImage.length > 0
                      width: visible ? parent.height : 0
                      height: parent.height
                      url: parent.parent.previewImage
                      asynchronous: true
                      smooth: true
                    }

                    Text {
                      textFormat: Text.PlainText
                      width: parent.width - (parent.parent.previewImage.length > 0 ? parent.height + parent.spacing : 0) - rowBadge.width - parent.spacing
                      height: parent.height
                      text: parent.parent.previewText
                      color: parent.parent.hasCursor ? root.selectedText : root.foreground
                      font.family: root.fontFamily
                      font.pixelSize: Style.font.title
                      opacity: parent.parent.entryType === "image" || parent.parent.entryType === "file" ? 0.72 : 1.0
                      elide: Text.ElideRight
                      wrapMode: Text.NoWrap
                      verticalAlignment: Text.AlignVCenter
                    }

                    // Ctrl+number pastes the first nine rows; a pin marks
                    // pinned entries in history.
                    Text {
                      id: rowBadge
                      textFormat: Text.PlainText
                      width: Style.space(36)
                      height: parent.height
                      text: (row.pinboard && !root.currentPinboard ? "\uDB81\uDC03" : "") + (row.index < 9 ? " " + (row.index + 1) : "")
                      color: row.hasCursor ? root.selectedText : root.foreground
                      opacity: 0.5
                      font.family: root.fontFamily
                      font.pixelSize: Style.font.body
                      horizontalAlignment: Text.AlignRight
                      verticalAlignment: Text.AlignVCenter
                    }
                  }

                  MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onPositionChanged: function(mouse) {
                      root.selectFromPointer(row.index, row, mouse)
                    }
                    onClicked: {
                      root.cursorActive = true
                      root.selectedIndex = row.index
                      root.activateIndex(row.index)
                    }
                  }
                }
              }
            }

            Item {
              width: parent.width / 2
              height: parent.height
              clip: true

              property var activeRow: displayModel.count > 0 && root.selectedIndex >= 0 && root.selectedIndex < displayModel.count ? displayModel.get(root.selectedIndex) : null

              Rectangle {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: Style.normalBorderWidth
                color: Util.alpha(root.border, 0.28)
              }

              Text {
                id: detailsText
                textFormat: Text.PlainText
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.leftMargin: root.contentMargin
                text: root.detailsText(parent.activeRow)
                color: root.foreground
                opacity: 0.58
                font.family: root.fontFamily
                font.pixelSize: Style.font.body
                elide: Text.ElideRight
              }

              Text {
                textFormat: Text.PlainText
                visible: parent.activeRow && !parent.activeRow.previewImage
                anchors.fill: parent
                anchors.leftMargin: root.contentMargin
                anchors.rightMargin: 0
                anchors.topMargin: 0
                anchors.bottomMargin: detailsText.height + root.contentSpacing
                text: parent.activeRow ? parent.activeRow.fullText : ""
                color: root.foreground
                font.family: root.fontFamily
                font.pixelSize: Style.font.title
                wrapMode: Text.WrapAnywhere
                elide: Text.ElideRight
                verticalAlignment: Text.AlignTop
              }

              SizedImage {
                visible: parent.activeRow && parent.activeRow.previewImage
                anchors.fill: parent
                anchors.leftMargin: root.contentMargin
                anchors.rightMargin: 0
                anchors.topMargin: 0
                anchors.bottomMargin: detailsText.height + root.contentSpacing
                url: parent.activeRow ? parent.activeRow.previewImage : ""
                verticalAlignment: Image.AlignTop
                asynchronous: true
                smooth: true
              }
            }
          }

          Column {
            anchors.centerIn: parent
            spacing: Style.space(8)
            visible: displayModel.count === 0

            Text {
              text: "󰅌"
              color: root.selectedText
              opacity: 0.8
              font.family: root.fontFamily
              font.pixelSize: Style.font.displayLarge
              horizontalAlignment: Text.AlignHCenter
              width: parent.width
            }

            Text {
              textFormat: Text.PlainText
              text: root.filterText ? Commons.I18n.t("common.noMatchesFor").arg(root.filterText) : (root.currentPinboard ? Commons.I18n.t("clipboard.pinboardEmpty") : Commons.I18n.t("clipboard.empty"))
              color: root.foreground
              opacity: 0.7
              font.family: root.fontFamily
              font.pixelSize: Style.font.title
              horizontalAlignment: Text.AlignHCenter
              width: parent.width
            }
          }
        }

        Text {
          id: hintsText
          textFormat: Text.PlainText
          width: parent.width
          text: root.currentPinboard ? Commons.I18n.t("clipboard.pinboardHints") : Commons.I18n.t("clipboard.hints")
          color: root.foreground
          opacity: 0.45
          font.family: root.fontFamily
          font.pixelSize: Style.font.caption
          elide: Text.ElideRight
          horizontalAlignment: Text.AlignHCenter
        }
      }

      // Names the pinboard to pin the selected entry to: pick a board or type
      // a new name. F2 reuses it to rename the current board.
      Item {
        anchors.fill: parent
        visible: root.pinPickerOpen
        z: 15

        Rectangle {
          anchors.fill: parent
          radius: root.cornerRadius
          color: root.scrim
        }

        MouseArea { anchors.fill: parent; onClicked: root.closePinPicker() }

        BorderSurface {
          id: pinPicker
          readonly property var rows: root.pinPickerOpen ? root.pinPickerRows() : []
          width: Math.min(Style.space(420), parent.width - root.contentMargin * 2)
          height: pinPickerColumn.implicitHeight + pinPicker.contentTopInset + pinPicker.contentBottomInset
          anchors.centerIn: parent
          radius: root.cornerRadius
          color: root.background
          borderSpec: root.borderSpec
          padding: root.contentMargin

          MouseArea { anchors.fill: parent; onClicked: {} }

          Column {
            id: pinPickerColumn
            anchors.fill: parent
            anchors.topMargin: pinPicker.contentTopInset
            anchors.rightMargin: pinPicker.contentRightInset
            anchors.bottomMargin: pinPicker.contentBottomInset
            anchors.leftMargin: pinPicker.contentLeftInset
            spacing: Style.space(6)

            Text {
              id: pinPickerTitle
              textFormat: Text.PlainText
              width: parent.width
              text: root.pinPickerRenames ? Commons.I18n.t("clipboard.renamePinboard") : Commons.I18n.t("clipboard.pinTo")
              color: root.foreground
              opacity: 0.58
              font.family: root.fontFamily
              font.pixelSize: Style.font.body
            }

            Text {
              id: pinPickerName
              textFormat: Text.PlainText
              width: parent.width
              text: root.pinPickerText || Commons.I18n.t("clipboard.pinboardName")
              color: root.foreground
              opacity: root.pinPickerText ? 1 : 0.58
              font.family: root.fontFamily
              font.pixelSize: Style.font.heading
              elide: Text.ElideRight
            }

            // Many boards scroll inside the card rather than run off it, and the
            // keyboard cursor stays in view.
            ListView {
              id: pinPickerList
              width: parent.width
              height: Math.min(contentHeight, pinPicker.parent.height - root.contentMargin * 2
                - pinPicker.contentTopInset - pinPicker.contentBottomInset
                - pinPickerTitle.height - pinPickerName.height - pinPickerColumn.spacing * 2)
              clip: true
              spacing: pinPickerColumn.spacing
              boundsBehavior: Flickable.StopAtBounds
              model: pinPicker.rows
              currentIndex: root.pinPickerIndex
              highlightFollowsCurrentItem: false
              onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)

              delegate: Rectangle {
                id: pinRow
                required property var modelData
                required property int index
                readonly property bool hasCursor: index === root.pinPickerIndex
                width: pinPickerList.width
                height: root.chipHeight + Style.space(8)
                radius: root.cornerRadius
                color: hasCursor ? root.selectedBackground : "transparent"

                Text {
                  textFormat: Text.PlainText
                  anchors.fill: parent
                  anchors.leftMargin: Style.space(10)
                  anchors.rightMargin: Style.space(10)
                  text: pinRow.modelData.create ? Commons.I18n.t("clipboard.newPinboard").arg(pinRow.modelData.name) : "\uDB81\uDC03 " + pinRow.modelData.name
                  color: pinRow.hasCursor ? root.selectedText : root.foreground
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.title
                  elide: Text.ElideRight
                  verticalAlignment: Text.AlignVCenter
                }

                MouseArea {
                  anchors.fill: parent
                  cursorShape: Qt.PointingHandCursor
                  onClicked: root.choosePinPickerRow(pinRow.index)
                }
              }
            }
          }
        }
      }
    }
  }

  // A tab or type filter: a rounded label that lights up when selected.
  component Chip: Rectangle {
    id: chip
    property string label: ""
    property bool active: false
    signal clicked()

    width: chipText.implicitWidth + Style.space(20)
    height: root.chipHeight
    radius: root.cornerRadius
    color: active ? root.selectedBackground : (chipMouse.containsMouse ? Util.alpha(root.foreground, 0.06) : "transparent")
    border.width: active ? 0 : Style.normalBorderWidth
    border.color: Util.alpha(root.border, 0.28)

    Text {
      id: chipText
      textFormat: Text.PlainText
      anchors.centerIn: parent
      text: chip.label
      color: chip.active ? root.selectedText : root.foreground
      opacity: chip.active ? 1 : 0.72
      font.family: root.fontFamily
      font.pixelSize: Style.font.body
    }

    MouseArea {
      id: chipMouse
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onClicked: chip.clicked()
    }
  }
}
