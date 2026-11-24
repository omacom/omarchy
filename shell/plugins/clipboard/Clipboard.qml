import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Controls as Controls
import qs.Commons
import qs.Commons as Commons
import qs.Ui
import "ClipboardHistory.js" as ClipboardHistory

Item {
  id: root

  property string omarchyPath: Quickshell.env("OMARCHY_PATH")
  readonly property string configHome: Quickshell.env("XDG_CONFIG_HOME") || (Quickshell.env("HOME") + "/.config")

  property bool opened: false
  property string filterText: ""
  property int selectedIndex: 0
  property bool cursorActive: false
  property bool clearConfirmOpen: false
  property var history: []

  property string historyPath: Quickshell.env("HOME") + "/.local/state/omarchy/clipboard-history.json"
  property string settingsPath: root.configHome + "/omarchy/clipboard.json"
  property string captureScript: root.omarchyPath + "/shell/plugins/clipboard/capture.sh"
  property string copyArgScript: root.omarchyPath + "/shell/plugins/clipboard/copy-arg.sh"

  property var settings: ClipboardHistory.defaultSettings()
  property bool settingsReady: false
  property int filterIndex: 0
  readonly property string activeFilter: ClipboardHistory.filterKinds[Math.max(0, Math.min(root.filterIndex, ClipboardHistory.filterKinds.length - 1))]

  property bool actionsOpen: false
  property int actionLevel: 0
  property int actionIndex: 0
  property var actionItems: []

  property bool renameOpen: false
  property bool editOpen: false
  property int dialogIndex: -1
  property string dialogValue: ""

  readonly property bool hasTesseract: true
  readonly property bool hasZbar: true
  property var ocrQueue: []
  property string ocrPath: ""
  property string pendingOcrCopyPath: ""
  property string qrPath: ""

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
  property color selectedBorder: Commons.Color.menu.selectedBorder
  property var selectedBorderSpec: Border.surfaceSpec("menu", "selected-border", selectedBorder, 0)
  readonly property real rowReservedBorderLeft: Border.left(selectedBorderSpec)
  readonly property real rowReservedBorderRight: Border.right(selectedBorderSpec)
  readonly property int cornerRadius: Style.cornerRadius
  property string fontFamily: Style.font.menuFamily
  property int contentMargin: Style.spacing.panelPadding
  property int headerHeight: Math.max(Style.space(34), Style.font.title + Style.spacing.controlPaddingY * 2)
  property int footerHeight: Style.space(24)
  property int contentSpacing: Style.spacing.md
  property int cardWidth: Math.min(Style.space(875), panel.width - Style.gapsOut * 2)
  property int cardHeight: Math.min(Style.space(660), panel.height - Style.gapsOut * 2)
  property int baseRowHeight: Math.max(Style.space(50), Style.font.body + Style.spacing.rowPaddingX * 2)
  property int detailRowHeight: Math.max(Style.space(58), Style.font.body + Style.font.caption + Style.spacing.rowPaddingX * 2)

  onFilterTextChanged: if (searchInput && searchInput.text !== filterText) searchInput.text = filterText

  function open(payloadJson) {
    root.opened = true
    root.filterText = ""
    root.filterIndex = 0
    root.selectedIndex = 0
    root.cursorActive = true
    root.closeActions()
    root.disarmPointer()
    root.rebuildDisplay()
    Qt.callLater(function() { searchInput.forceActiveFocus() })
  }

  function close() {
    root.cancelClearHistory()
    root.closeActions()
    root.renameOpen = false
    root.editOpen = false
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

  function applySettings(raw) {
    root.settings = ClipboardHistory.parseSettings(raw)
    root.settingsReady = true
    if (historyFile.loaded) root.applyHistory(historyFile.text())
  }

  function applyHistory(raw) {
    var parsed = ClipboardHistory.parseHistory(raw)
    var next = ClipboardHistory.pruneHistory(parsed, root.settings, Date.now())
    root.history = next
    if (next.length !== parsed.length) root.saveHistory()
    root.rebuildDisplay()
  }

  function saveHistory() {
    historyFile.setText(JSON.stringify(root.history, null, 2) + "\n")
  }

  // Keep a copy before an explicit destructive action so a mis-click cannot
  // wipe the whole history. The file is plain JSON, so recovery is `cp` back.
  function backupHistory() {
    if (root.history.length === 0) return
    Quickshell.execDetached(["cp", "-f", "--", root.historyPath, root.historyPath + ".bak"])
  }

  function commitHistory(next, keepHistoryIndex) {
    if (!Array.isArray(next)) return
    var removed = ClipboardHistory.removedImagePaths(root.history, next)
    root.history = next
    root.saveHistory()
    for (var i = 0; i < removed.length; i++) {
      Quickshell.execDetached(["rm", "-f", "--", removed[i]])
    }
    root.rebuildDisplay(keepHistoryIndex)
  }

  function addClipboardEntry(entry) {
    var normalized = ClipboardHistory.normalizeEntry(entry)
    if (!normalized) return

    var toplevel = ToplevelManager.activeToplevel
    var appId = toplevel ? String(toplevel.appId || "") : ""
    if (ClipboardHistory.isAppDisabled(root.settings, normalized.sourceApp)) return
    if (ClipboardHistory.isAppDisabled(root.settings, appId)) return

    if (!normalized.capturedAtMs) normalized.capturedAtMs = Date.now()
    if (!normalized.sourceApp && appId) normalized.sourceApp = appId
    if (!normalized.sourceTitle && toplevel && toplevel.title) normalized.sourceTitle = String(toplevel.title)

    root.commitHistory(ClipboardHistory.addEntry(root.history, normalized, root.settings, Date.now()))
    if (normalized.type === "image" && root.settings.textRecognition) root.enqueueOcr(normalized.path, false)
  }

  function addClipboardJson(line) {
    root.addClipboardEntry(ClipboardHistory.parseEntryJson(line))
  }

  function currentRow() {
    if (displayModel.count === 0) return null
    if (root.selectedIndex < 0 || root.selectedIndex >= displayModel.count) return null
    return displayModel.get(root.selectedIndex)
  }

  function currentEntry() {
    var row = root.currentRow()
    return row ? root.history[row.historyIndex] : null
  }

  function requestClearHistory() {
    if (root.history.length === 0) return
    clearConfirm.selectedIndex = 1
    root.clearConfirmOpen = true
  }

  function cancelClearHistory() {
    root.clearConfirmOpen = false
    root.disarmPointer()
    Qt.callLater(function() { searchInput.forceActiveFocus() })
  }

  function confirmClearHistory() {
    root.clearConfirmOpen = false
    root.backupHistory()
    root.commitHistory(ClipboardHistory.clearHistory())
    root.selectedIndex = 0
    root.cursorActive = false
    root.disarmPointer()
    Qt.callLater(function() { searchInput.forceActiveFocus() })
  }

  function removeDisplayIndex(index) {
    if (index < 0 || index >= displayModel.count) return

    var row = displayModel.get(index)
    root.commitHistory(ClipboardHistory.removeEntryAt(root.history, row.historyIndex))
    if (displayModel.count === 0) root.cursorActive = false
    root.disarmPointer()
  }

  function togglePin() {
    var row = root.currentRow()
    if (!row) return
    var next = ClipboardHistory.setPinned(root.history, row.historyIndex, !row.pinned)
    if (next) root.commitHistory(next, row.historyIndex)
  }

  function deleteRecent(minutes) {
    var cutoff = Date.now() - Number(minutes) * 60000
    root.backupHistory()
    root.commitHistory(ClipboardHistory.removeSince(root.history, cutoff))
    root.closeActions()
  }

  function rebuildDisplay(keepHistoryIndex) {
    var rows = ClipboardHistory.displayRows(root.history, root.filterText, root.activeFilter, 50,
      Commons.I18n.t, Commons.I18n.tn, Commons.I18n.formatNumber, Date.now())

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
        pinned: row.pinned,
        meta: row.meta,
        sourceApp: row.sourceApp,
        timeLabel: row.timeLabel,
        colorR: row.colorR,
        colorG: row.colorG,
        colorB: row.colorB,
        colorA: row.colorA,
        colorHex: row.colorHex,
        colorRgb: row.colorRgb,
        colorHsl: row.colorHsl,
        url: row.url,
        email: row.email,
        hasOcr: row.hasOcr,
        historyIndex: row.historyIndex
      })
    }

    if (keepHistoryIndex !== undefined && keepHistoryIndex !== null) {
      for (var j = 0; j < displayModel.count; j++) {
        if (displayModel.get(j).historyIndex === keepHistoryIndex) {
          root.selectedIndex = j
          break
        }
      }
    }
    if (displayModel.count === 0) root.selectedIndex = 0
    else if (root.selectedIndex >= displayModel.count) root.selectedIndex = displayModel.count - 1
    else if (root.selectedIndex < 0) root.selectedIndex = 0

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

  function cycleFilter() {
    root.filterIndex = (root.filterIndex + 1) % ClipboardHistory.filterKinds.length
    root.setFilter(root.filterText)
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
    if (root.settings.primaryAction === "copy") root.copySelected(row)
    else root.applySelected(row)
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
    if (row.entryType === "link" && row.url) {
      root.opened = false
      Quickshell.execDetached([root.omarchyPath + "/bin/omarchy-launch-browser", row.url])
      return
    }
    if (row.entryType === "email" && row.email) {
      root.opened = false
      Quickshell.execDetached(["xdg-open", "mailto:" + row.email])
      return
    }
    if (row.entryType === "file" && row.path) {
      root.opened = false
      Quickshell.execDetached(["xdg-open", row.path])
      return
    }
    if (row.entryType === "color") return
    root.opened = false
    Quickshell.execDetached([root.omarchyPath + "/bin/omarchy-clipboard-open", "--history-index", String(row.historyIndex)])
  }

  function copyText(text) {
    var value = String(text || "")
    if (value.length === 0) return
    Quickshell.execDetached([root.copyArgScript, value])
  }

  function openActions() {
    var row = root.currentRow()
    if (!row) return
    root.actionLevel = 0
    root.actionItems = root.actionListFor(row)
    root.actionIndex = 0
    root.actionsOpen = true
  }

  function closeActions() {
    root.actionsOpen = false
    root.actionLevel = 0
    root.actionItems = []
    root.actionIndex = 0
  }

  function actionListFor(row) {
    var t = Commons.I18n.t
    var actions = []
    if (!row) return actions
    actions.push({ id: "paste", label: t("clipboard.paste"), hint: "↵" })
    actions.push({ id: "copy", label: t("clipboard.copy"), hint: "Ctrl+↵" })
    if (row.entryType === "link" || row.entryType === "email" || row.entryType === "file" || row.entryType === "image") {
      actions.push({
        id: "open",
        label: row.entryType === "email" ? t("clipboard.composeEmail") : t("clipboard.open"), // i18n: ignore
        hint: "Ctrl+O" // i18n: ignore
      })
    }
    if (row.entryType === "image") {
      if (root.hasTesseract) actions.push({ id: "ocr", label: t("clipboard.copyTextFromImage"), hint: "" })
      if (root.hasZbar) actions.push({ id: "qr", label: t("clipboard.copyTextFromQr"), hint: "" })
    }
    if (row.entryType === "color") {
      actions.push({ id: "copyHex", label: t("clipboard.copyHex"), hint: "" })
      actions.push({ id: "copyRgb", label: t("clipboard.copyRgb"), hint: "" })
      actions.push({ id: "copyHsl", label: t("clipboard.copyHsl"), hint: "" })
    }
    if (row.entryType !== "image") actions.push({ id: "edit", label: t("clipboard.edit"), hint: "" })
    actions.push({ id: "rename", label: t("clipboard.rename"), hint: "Ctrl+E" })
    actions.push({
      id: row.pinned ? "unpin" : "pin",
      label: row.pinned ? t("clipboard.unpin") : t("clipboard.pin"),
      hint: "Ctrl+." // i18n: ignore
    })
    actions.push({ id: "delete", label: t("clipboard.deleteEntry"), hint: "Del" })
    actions.push({ id: "deleteRecent", label: t("clipboard.deleteRecent"), hint: "" })
    actions.push({ id: "deleteAll", label: t("clipboard.deleteAll"), hint: "Shift+Del" })
    actions.push({ id: "settings", label: t("clipboard.settings"), hint: "" })
    return actions
  }

  function openDeleteRecent() {
    var t = Commons.I18n.t
    root.actionLevel = 1
    root.actionIndex = 0
    root.actionItems = [
      { id: "recent5", label: t("clipboard.last5Minutes"), minutes: 5 },
      { id: "recent15", label: t("clipboard.last15Minutes"), minutes: 15 },
      { id: "recent30", label: t("clipboard.last30Minutes"), minutes: 30 },
      { id: "recent60", label: t("clipboard.lastHour"), minutes: 60 },
      { id: "recent1440", label: t("clipboard.last24Hours"), minutes: 1440 }
    ]
  }

  function runCurrentAction() {
    if (!root.actionsOpen) return
    var action = root.actionItems[root.actionIndex]
    if (!action) return
    if (root.actionLevel === 1) {
      root.deleteRecent(action.minutes)
      return
    }

    var row = root.currentRow()
    if (!row) return

    if (action.id === "paste") {
      root.closeActions()
      root.applySelected(row)
    } else if (action.id === "copy") {
      root.closeActions()
      root.copySelected(row)
    } else if (action.id === "open") {
      root.closeActions()
      root.openSelected(row)
    } else if (action.id === "ocr") {
      root.copyTextFromImage()
    } else if (action.id === "qr") {
      root.copyQrFromImage()
    } else if (action.id === "copyHex") {
      root.copyText(row.colorHex)
      root.close()
    } else if (action.id === "copyRgb") {
      root.copyText(row.colorRgb)
      root.close()
    } else if (action.id === "copyHsl") {
      root.copyText(row.colorHsl)
      root.close()
    } else if (action.id === "edit") {
      root.closeActions()
      root.openEdit()
    } else if (action.id === "rename") {
      root.closeActions()
      root.openRename()
    } else if (action.id === "pin" || action.id === "unpin") {
      root.togglePin()
      root.actionItems = root.actionListFor(root.currentRow())
      root.actionIndex = Math.min(root.actionIndex, root.actionItems.length - 1)
    } else if (action.id === "delete") {
      var index = row.historyIndex
      root.closeActions()
      root.commitHistory(ClipboardHistory.removeEntryAt(root.history, index))
    } else if (action.id === "deleteRecent") {
      root.openDeleteRecent()
    } else if (action.id === "deleteAll") {
      root.closeActions()
      root.requestClearHistory()
    } else if (action.id === "settings") {
      root.openSettings()
    }
  }

  function openRename() {
    var row = root.currentRow()
    if (!row) return
    var entry = root.history[row.historyIndex]
    root.dialogIndex = row.historyIndex
    root.dialogValue = String(entry && entry.title || "")
    root.renameOpen = true
    Qt.callLater(function() {
      renameField.text = root.dialogValue
      renameField.forceActiveFocus()
      renameField.selectAll()
    })
  }

  function saveRename() {
    var next = ClipboardHistory.updateEntry(root.history, root.dialogIndex, { title: String(root.dialogValue || "").trim() })
    if (next) root.commitHistory(next, root.dialogIndex)
    root.renameOpen = false
    Qt.callLater(function() { searchInput.forceActiveFocus() })
  }

  function closeRename() {
    root.renameOpen = false
    Qt.callLater(function() { searchInput.forceActiveFocus() })
  }

  function openEdit() {
    var row = root.currentRow()
    if (!row) return
    var entry = root.history[row.historyIndex]
    if (!entry || entry.type !== "text") return
    root.dialogIndex = row.historyIndex
    root.dialogValue = String(entry.text || "")
    root.editOpen = true
    Qt.callLater(function() {
      editField.text = root.dialogValue
      editField.forceActiveFocus()
      editField.selectAll()
    })
  }

  function saveEdit() {
    var next = ClipboardHistory.updateEntry(root.history, root.dialogIndex, { text: String(root.dialogValue || "") })
    if (next) root.commitHistory(next, root.dialogIndex)
    root.editOpen = false
    Qt.callLater(function() { searchInput.forceActiveFocus() })
  }

  function closeEdit() {
    root.editOpen = false
    Qt.callLater(function() { searchInput.forceActiveFocus() })
  }

  function openSettings() {
    root.close()
    if (!root.settingsReady) settingsFile.setText(ClipboardHistory.settingsJson())
    settingsOpenTimer.restart()
  }

  function copyTextFromImage() {
    var row = root.currentRow()
    if (!row || row.entryType !== "image") return
    var entry = root.history[row.historyIndex]
    if (!entry) return
    var ocr = String(entry.ocr || "").trim()
    if (ocr.length > 0) {
      root.copyText(ocr)
      root.close()
      return
    }
    if (!root.hasTesseract) return
    root.pendingOcrCopyPath = entry.path
    root.enqueueOcr(entry.path, true)
    root.closeActions()
    root.close()
  }

  function copyQrFromImage() {
    var row = root.currentRow()
    if (!row || row.entryType !== "image") return
    if (!root.hasZbar) return
    root.qrPath = row.path
    root.closeActions()
    root.close()
    qrProc.command = ["timeout", "10s", "zbarimg", "-q", "--raw", "-Sdisable", "-Sqrcode.enable", root.qrPath]
    qrProc.running = true
  }

  function enqueueOcr(path, force) {
    if (!path || !root.hasTesseract) return
    if (!force && !root.settings.textRecognition) return
    if (root.ocrPath === path || root.ocrQueue.indexOf(path) >= 0) return
    var queue = root.ocrQueue.slice()
    queue.push(path)
    root.ocrQueue = queue
    root.runOcr()
  }

  function runOcr() {
    if (ocrProc.running || root.ocrQueue.length === 0 || !root.hasTesseract) return
    var queue = root.ocrQueue.slice()
    root.ocrPath = queue.shift()
    root.ocrQueue = queue
    var langs = Quickshell.env("OMARCHY_OCR_LANGS") || "eng"
    ocrProc.command = ["timeout", "20s", "tesseract", root.ocrPath, "stdout", "--oem", "1", "--psm", "3", "-l", langs, "--dpi", "300", "-c", "preserve_interword_spaces=1"]
    ocrProc.running = true
  }

  function finishOcr(path, text, ok) {
    var value = String(text || "").trim()
    var entryIndex = -1
    for (var i = 0; i < root.history.length; i++) {
      var entry = root.history[i]
      if (entry.type === "image" && entry.path === path) {
        entryIndex = i
        break
      }
    }
    if (entryIndex >= 0 && (ok || !root.history[entryIndex].ocrTried)) {
      var patch = ok && value.length > 0
        ? { ocr: value.slice(0, 20000), ocrTried: true }
        : { ocrTried: true }
      var next = ClipboardHistory.updateEntry(root.history, entryIndex, patch)
      if (next) root.commitHistory(next)
    }

    if (root.pendingOcrCopyPath === path) {
      root.pendingOcrCopyPath = ""
      if (ok && value.length > 0) root.copyText(value)
    }
    root.ocrPath = ""
    Qt.callLater(function() { root.runOcr() })
  }

  function footerHints() {
    var t = Commons.I18n.t
    if (root.actionsOpen) return t("clipboard.hintsActions")
    return t("clipboard.hints")
  }

  Component.onCompleted: {
    initProc.running = true
  }

  ListModel { id: displayModel }

  PointerMoveGate {
    id: pointerGate
    referenceItem: card
  }

  FileView {
    id: settingsFile
    path: root.settingsPath
    watchChanges: true
    atomicWrites: true
    printErrors: false
    onLoaded: root.applySettings(text())
    onLoadFailed: {
      root.settingsReady = false
      root.settings = ClipboardHistory.defaultSettings()
    }
    onFileChanged: reload()
  }

  FileView {
    id: historyFile
    path: root.historyPath
    watchChanges: true
    atomicWrites: true
    printErrors: false
    onLoaded: root.applyHistory(text())
    onLoadFailed: root.applyHistory("[]")
    onFileChanged: reload()
  }

  Timer {
    id: settingsOpenTimer
    interval: 200
    repeat: false
    onTriggered: Quickshell.execDetached(["omarchy-launch-editor", root.settingsPath])
  }

  // History can contain secrets; FileView's atomic writes create 0644 files.
  // `saved` fires after the atomic rename, so the chmod sticks.
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

  Process {
    id: ocrProc
    stdout: StdioCollector {
      id: ocrOut
      waitForEnd: true
    }
    stderr: StdioCollector { waitForEnd: true }
    onExited: function(exitCode) { root.finishOcr(root.ocrPath, ocrOut.text, exitCode === 0) }
  }

  Process {
    id: qrProc
    stdout: StdioCollector {
      id: qrOut
      waitForEnd: true
    }
    stderr: StdioCollector { waitForEnd: true }
    onExited: function(exitCode) {
      if (exitCode === 0) root.copyText(String(qrOut.text || "").trim())
      root.qrPath = ""
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
        z: root.clearConfirmOpen ? 20 : 0

        Keys.priority: Keys.BeforeItem
        Keys.onPressed: function(event) {
          if (root.renameOpen || root.editOpen) return

          if (root.clearConfirmOpen) {
            if (clearConfirm.handleKey(event)) event.accepted = true
            return
          }

          if (root.actionsOpen) {
            if (event.key === Qt.Key_Escape) {
              if (root.actionLevel > 0) root.openActions()
              else root.closeActions()
              event.accepted = true
            } else if (event.key === Qt.Key_Up) {
              root.actionIndex = (root.actionIndex - 1 + root.actionItems.length) % Math.max(1, root.actionItems.length)
              event.accepted = true
            } else if (event.key === Qt.Key_Down) {
              root.actionIndex = (root.actionIndex + 1) % Math.max(1, root.actionItems.length)
              event.accepted = true
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
              root.runCurrentAction()
              event.accepted = true
            } else if (event.key === Qt.Key_K && (event.modifiers & Qt.ControlModifier)) {
              root.closeActions()
              event.accepted = true
            }
            // The action panel owns every key; keep the search field behind it
            // from collecting stray text.
            event.accepted = true
            return
          }

          var ctrl = (event.modifiers & Qt.ControlModifier) !== 0

          if (ctrl && event.key === Qt.Key_K) {
            root.openActions()
            event.accepted = true
          } else if (ctrl && event.key === Qt.Key_P) {
            root.cycleFilter()
            event.accepted = true
          } else if (ctrl && (event.key === Qt.Key_Period || event.text === ".")) {
            root.togglePin()
            event.accepted = true
          } else if (ctrl && event.key === Qt.Key_E) {
            root.openRename()
            event.accepted = true
          } else if (ctrl && event.key === Qt.Key_O) {
            var row = root.currentRow()
            if (row) root.openSelected(row)
            event.accepted = true
          } else if (event.key === Qt.Key_Escape) {
            if (root.filterText) root.setFilter("")
            else root.close()
            event.accepted = true
          } else if (Util.editsFilter(event, root.filterText)) {
            root.setFilter(Util.editedFilter(event, root.filterText))
            event.accepted = true
          } else if (event.key === Qt.Key_Delete) {
            if (event.modifiers & Qt.ShiftModifier) root.requestClearHistory()
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
            else if (root.cursorActive && ((event.modifiers & Qt.ShiftModifier) || (event.modifiers & Qt.ControlModifier))) root.copyIndex(root.selectedIndex)
            else if (root.cursorActive) root.activateIndex(root.selectedIndex)
            else if (displayModel.count > 0) root.cursorActive = true
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
      }

      Column {
        anchors.fill: parent
        anchors.topMargin: card.contentTopInset
        anchors.rightMargin: card.contentRightInset
        anchors.bottomMargin: card.contentBottomInset
        anchors.leftMargin: card.contentLeftInset
        spacing: root.contentSpacing

        Item {
          width: parent.width
          height: root.headerHeight

          FilterInput {
            id: searchInput
            anchors.left: parent.left
            anchors.right: filterChip.left
            anchors.rightMargin: Style.space(10)
            anchors.verticalCenter: parent.verticalCenter
            keyHandler: keyCatcher
            color: root.foreground
            font.family: root.fontFamily
            font.pixelSize: Style.font.heading
            readOnly: root.actionsOpen || root.clearConfirmOpen || root.renameOpen || root.editOpen
            onTextChanged: if (text !== root.filterText) root.setFilter(text)
          }

          Text {
            textFormat: Text.PlainText
            anchors.fill: searchInput
            verticalAlignment: Text.AlignVCenter
            visible: !root.filterText && !searchInput.preeditText
            text: Commons.I18n.t("clipboard.search")
            color: root.foreground
            opacity: 0.58
            font.family: root.fontFamily
            font.pixelSize: Style.font.heading
            elide: Text.ElideRight
          }

          Button {
            id: filterChip
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: ClipboardHistory.kindLabel(root.activeFilter, Commons.I18n.t)
            foreground: root.foreground
            background: "transparent"
            bordered: true
            fontSize: Style.font.bodySmall
            onClicked: root.cycleFilter()
          }
        }

        Item {
          width: parent.width
          height: parent.height - root.headerHeight - root.footerHeight - 2 * root.contentSpacing

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
                spacing: Style.spacing.xs
                boundsBehavior: Flickable.StopAtBounds

                delegate: BorderSurface {
                  id: row
                  required property int index
                  required property string entryType
                  required property string previewText
                  required property string fullText
                  required property string previewImage
                  required property bool pinned
                  required property string meta
                  required property real colorR
                  required property real colorG
                  required property real colorB
                  required property real colorA

                  readonly property bool hasCursor: root.cursorActive && index === root.selectedIndex

                  width: ListView.view.width
                  height: row.meta.length > 0 ? root.detailRowHeight : root.baseRowHeight
                  radius: root.cornerRadius
                  color: hasCursor ? root.selectedBackground : "transparent"
                  borderSpec: hasCursor ? root.selectedBorderSpec : Border.none()

                  Item {
                    anchors.fill: parent
                    anchors.leftMargin: root.rowReservedBorderLeft + Style.space(10)
                    anchors.rightMargin: root.rowReservedBorderRight + Style.space(10)
                    anchors.topMargin: Style.space(7)
                    anchors.bottomMargin: Style.space(7)

                    Row {
                      id: lead
                      anchors.left: parent.left
                      anchors.verticalCenter: parent.verticalCenter
                      spacing: Style.space(8)

                      Text {
                        visible: row.pinned
                        text: "󰐃"
                        color: row.hasCursor ? root.selectedText : root.foreground
                        opacity: 0.85
                        font.family: root.fontFamily
                        font.pixelSize: Style.font.body
                      }

                      SizedImage {
                        visible: row.previewImage.length > 0
                        width: visible ? Style.space(40) : 0
                        height: visible ? Style.space(40) : 0
                        url: row.previewImage
                        crop: true
                        asynchronous: true
                        smooth: true
                      }

                      Rectangle {
                        visible: row.entryType === "color"
                        width: visible ? Style.space(40) : 0
                        height: visible ? Style.space(40) : 0
                        radius: Math.min(root.cornerRadius, Style.space(8))
                        color: Qt.rgba(row.colorR / 255, row.colorG / 255, row.colorB / 255, row.colorA)
                        border.width: Style.normalBorderWidth
                        border.color: Util.alpha(root.foreground, 0.35)
                      }
                    }

                    Column {
                      anchors.left: lead.right
                      anchors.leftMargin: lead.width > 0 ? Style.space(10) : 0
                      anchors.right: parent.right
                      anchors.verticalCenter: parent.verticalCenter
                      spacing: Style.space(2)

                      Text {
                        textFormat: Text.PlainText
                        width: parent.width
                        text: row.previewText
                        color: row.hasCursor ? root.selectedText : root.foreground
                        font.family: root.fontFamily
                        font.pixelSize: Style.font.heading
                        font.weight: Font.Medium
                        elide: Text.ElideRight
                        wrapMode: Text.NoWrap
                      }

                      Text {
                        textFormat: Text.PlainText
                        visible: row.meta.length > 0
                        width: parent.width
                        text: row.meta
                        color: row.hasCursor ? root.selectedText : root.foreground
                        opacity: 0.52
                        font.family: root.fontFamily
                        font.pixelSize: Style.font.bodySmall
                        elide: Text.ElideRight
                        wrapMode: Text.NoWrap
                      }
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
                visible: displayModel.count > 0
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: Style.normalBorderWidth
                color: Util.alpha(root.foreground, 0.2)
              }

              Text {
                textFormat: Text.PlainText
                visible: parent.activeRow && !parent.activeRow.previewImage && parent.activeRow.entryType !== "color"
                anchors.fill: parent
                anchors.leftMargin: root.contentMargin
                anchors.rightMargin: 0
                anchors.topMargin: 0
                anchors.bottomMargin: 0
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
                anchors.bottomMargin: 0
                url: parent.activeRow ? parent.activeRow.previewImage : ""
                verticalAlignment: Image.AlignTop
                asynchronous: true
                smooth: true
              }

              Column {
                visible: parent.activeRow && parent.activeRow.entryType === "color"
                anchors.fill: parent
                anchors.leftMargin: root.contentMargin
                anchors.rightMargin: 0
                anchors.topMargin: 0
                anchors.bottomMargin: 0
                spacing: Style.space(10)

                Rectangle {
                  width: Style.space(72)
                  height: Style.space(72)
                  radius: Style.space(8)
                  color: parent.parent.activeRow
                    ? Qt.rgba(parent.parent.activeRow.colorR / 255, parent.parent.activeRow.colorG / 255, parent.parent.activeRow.colorB / 255, parent.parent.activeRow.colorA)
                    : "transparent"
                  border.width: Style.normalBorderWidth
                  border.color: Util.alpha(root.foreground, 0.35)
                }

                Text {
                  textFormat: Text.PlainText
                  width: parent.width
                  text: parent.parent.activeRow ? parent.parent.activeRow.colorHex : ""
                  color: root.foreground
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.title
                }

                Text {
                  textFormat: Text.PlainText
                  width: parent.width
                  text: parent.parent.activeRow ? parent.parent.activeRow.colorRgb : ""
                  color: root.foreground
                  opacity: 0.75
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.body
                }

                Text {
                  textFormat: Text.PlainText
                  width: parent.width
                  text: parent.parent.activeRow ? parent.parent.activeRow.colorHsl : ""
                  color: root.foreground
                  opacity: 0.75
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.body
                }
              }
            }
          }

          Column {
            anchors.centerIn: parent
            width: parent.width - 2 * root.contentMargin
            spacing: Style.space(8)
            visible: displayModel.count === 0

            Text {
              text: "󰅌"
              color: root.selectedText
              opacity: 0.8
              font.family: root.fontFamily
              font.pixelSize: Style.font.displayLarge
              horizontalAlignment: Text.AlignHCenter
              anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
              textFormat: Text.PlainText
              text: root.history.length === 0 ? Commons.I18n.t("clipboard.empty") : Commons.I18n.t("common.noMatchesFor").arg(root.filterText)
              color: root.foreground
              opacity: 0.7
              font.family: root.fontFamily
              font.pixelSize: Style.font.title
              horizontalAlignment: Text.AlignHCenter
              width: parent.width
              elide: Text.ElideRight
            }
          }
        }

        Text {
          textFormat: Text.PlainText
          width: parent.width
          height: root.footerHeight
          text: root.footerHints()
          color: root.foreground
          opacity: 0.58
          font.family: root.fontFamily
          font.pixelSize: Style.font.bodySmall
          verticalAlignment: Text.AlignVCenter
        }
      }

      BorderSurface {
        id: actionPanel
        visible: root.actionsOpen
        z: 6
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.topMargin: card.contentTopInset
        anchors.rightMargin: card.contentRightInset
        anchors.bottomMargin: card.contentBottomInset
        width: Math.min(Style.space(330), parent.width * 0.55)
        color: root.background
        borderSpec: Border.flat(Util.alpha(root.border, 0.7), Style.normalBorderWidth)
        radius: root.cornerRadius
        padding: Style.space(10)

        Column {
          anchors.fill: parent
          anchors.topMargin: actionPanel.contentTopInset
          anchors.rightMargin: actionPanel.contentRightInset
          anchors.bottomMargin: actionPanel.contentBottomInset
          anchors.leftMargin: actionPanel.contentLeftInset
          spacing: Style.space(6)

          Text {
            textFormat: Text.PlainText
            width: parent.width
            text: root.actionLevel === 1 ? Commons.I18n.t("clipboard.deleteRecent") : Commons.I18n.t("clipboard.actions")
            color: root.foreground
            opacity: 0.65
            font.family: root.fontFamily
            font.pixelSize: Style.font.caption
          }

          ListView {
            id: actionList
            width: parent.width
            height: parent.height - Style.space(24)
            model: root.actionItems
            spacing: 2
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            delegate: BorderSurface {
              id: actionRow
              required property int index
              required property var modelData

              readonly property bool selected: index === root.actionIndex

              width: ListView.view.width
              height: Style.space(32)
              radius: root.cornerRadius
              color: selected ? root.selectedBackground : "transparent"
              borderSpec: selected ? root.selectedBorderSpec : Border.none()

              Text {
                textFormat: Text.PlainText
                anchors.left: parent.left
                anchors.leftMargin: root.rowReservedBorderLeft + Style.space(8)
                anchors.right: hintText.left
                anchors.rightMargin: Style.space(8)
                anchors.verticalCenter: parent.verticalCenter
                text: actionRow.modelData.label
                color: actionRow.selected ? root.selectedText : root.foreground
                font.family: root.fontFamily
                font.pixelSize: Style.font.body
                elide: Text.ElideRight
              }

              Text {
                id: hintText
                textFormat: Text.PlainText
                anchors.right: parent.right
                anchors.rightMargin: root.rowReservedBorderRight + Style.space(8)
                anchors.verticalCenter: parent.verticalCenter
                text: String(actionRow.modelData.hint || "")
                color: root.foreground
                opacity: 0.52
                font.family: root.fontFamily
                font.pixelSize: Style.font.bodySmall
              }

              MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: root.actionIndex = actionRow.index
                onClicked: {
                  root.actionIndex = actionRow.index
                  root.runCurrentAction()
                }
              }
            }
          }
        }
      }

      Item {
        id: renameOverlay
        anchors.fill: parent
        visible: root.renameOpen
        z: 30

        Rectangle {
          anchors.fill: parent
          color: root.scrim
        }

        MouseArea {
          anchors.fill: parent
          onClicked: root.closeRename()
        }

        BorderSurface {
          id: renameCard
          width: Math.min(parent.width - 2 * root.contentMargin, Style.space(520))
          height: renameCard.contentTopInset + renameCard.contentBottomInset + renameColumn.implicitHeight + Style.space(18)
          anchors.centerIn: parent
          color: root.background
          borderSpec: Border.flat(Util.alpha(root.border, 0.8), Style.normalBorderWidth)
          radius: root.cornerRadius
          padding: Style.space(16)

          MouseArea { anchors.fill: parent; onClicked: {} }

          Column {
            id: renameColumn
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: renameCard.contentTopInset
            anchors.leftMargin: renameCard.contentLeftInset
            anchors.rightMargin: renameCard.contentRightInset
            spacing: Style.space(10)

            Text {
              textFormat: Text.PlainText
              width: parent.width
              text: Commons.I18n.t("clipboard.rename")
              color: root.foreground
              font.family: root.fontFamily
              font.pixelSize: Style.font.title
            }

            TextField {
              id: renameField
              width: parent.width
              text: root.dialogValue
              foreground: root.foreground
              font.family: root.fontFamily
              onTextEdited: root.dialogValue = text
              onAccepted: root.saveRename()
              Keys.onEscapePressed: root.closeRename()
            }

            Text {
              textFormat: Text.PlainText
              width: parent.width
              text: Commons.I18n.t("clipboard.renameHint")
              color: root.foreground
              opacity: 0.52
              font.family: root.fontFamily
              font.pixelSize: Style.font.bodySmall
            }
          }
        }
      }

      Item {
        id: editOverlay
        anchors.fill: parent
        visible: root.editOpen
        z: 30

        Rectangle {
          anchors.fill: parent
          color: root.scrim
        }

        MouseArea {
          anchors.fill: parent
          onClicked: root.closeEdit()
        }

        BorderSurface {
          id: editCard
          width: Math.min(parent.width - 2 * root.contentMargin, Style.space(620))
          height: Math.min(parent.height - 2 * root.contentMargin, Style.space(430))
          anchors.centerIn: parent
          color: root.background
          borderSpec: Border.flat(Util.alpha(root.border, 0.8), Style.normalBorderWidth)
          radius: root.cornerRadius
          padding: Style.space(16)

          MouseArea { anchors.fill: parent; onClicked: {} }

          Column {
            anchors.fill: parent
            anchors.topMargin: editCard.contentTopInset
            anchors.rightMargin: editCard.contentRightInset
            anchors.bottomMargin: editCard.contentBottomInset
            anchors.leftMargin: editCard.contentLeftInset
            spacing: Style.space(8)

            Text {
              textFormat: Text.PlainText
              width: parent.width
              text: Commons.I18n.t("clipboard.edit")
              color: root.foreground
              font.family: root.fontFamily
              font.pixelSize: Style.font.title
            }

            Controls.ScrollView {
              width: parent.width
              height: parent.height - Style.space(44)

              Controls.TextArea {
                id: editField
                text: root.dialogValue
                wrapMode: TextEdit.Wrap
                textFormat: TextEdit.PlainText
                selectByMouse: true
                color: root.foreground
                selectionColor: Util.alpha(root.foreground, 0.25)
                selectedTextColor: root.foreground
                font.family: root.fontFamily
                font.pixelSize: Style.font.body
                background: Rectangle {
                  color: "transparent"
                  border.width: Style.normalBorderWidth
                  border.color: Util.alpha(root.foreground, 0.28)
                  radius: root.cornerRadius
                }
                onTextChanged: root.dialogValue = text
                Keys.onEscapePressed: root.closeEdit()
                Keys.onPressed: function(event) {
                  if ((event.key === Qt.Key_Return || event.key === Qt.Key_Enter) && (event.modifiers & Qt.ControlModifier)) {
                    root.saveEdit()
                    event.accepted = true
                  }
                }
              }
            }

            Text {
              textFormat: Text.PlainText
              width: parent.width
              text: Commons.I18n.t("clipboard.editHint")
              color: root.foreground
              opacity: 0.52
              font.family: root.fontFamily
              font.pixelSize: Style.font.bodySmall
            }
          }
        }
      }
    }
  }
}
