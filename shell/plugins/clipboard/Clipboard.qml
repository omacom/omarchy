import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import qs.Commons
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

  property string historyPath: Quickshell.env("HOME") + "/.local/state/omarchy/clipboard-history.json"
  property string captureScript: root.omarchyPath + "/shell/plugins/clipboard/capture.sh"
  // Where capture.sh keeps copies too large to hold in history.
  property string textDir: (Quickshell.env("XDG_STATE_HOME") || Quickshell.env("HOME") + "/.local/state") + "/omarchy/clipboard-text"
  // False until history has loaded, and for good if it could not be read: a save
  // before then would write a partial history over the real one.
  property bool historyWritable: false
  // The last copy was too large to keep. Cleared by the next copy that is kept.
  property bool lastCopySkipped: false
  property string historyNotice: ""
  property bool watchersStarted: false
  property var capturesDuringLoad: []
  property bool saveRequested: false
  // Set by "Delete entire clipboard history": the next save also removes the
  // recovery backups, so no copy of the cleared history stays on disk.
  property bool clearBackupsRequested: false
  readonly property string saveFailedNotice: "Clipboard history could not be saved · previous data kept"
  property bool reloadRequested: true
  // Shares the [menu] surface tokens — themes that style the menu also
  // style the clipboard. Selected-row colors composed in the
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
  property int cardWidth: Math.min(Style.space(875), panel.width - Style.gapsOut * 2)
  property int cardHeight: Math.min(Style.space(600), panel.height - Style.gapsOut * 2)
  property int rowHeight: Math.max(Style.space(50), Style.font.body + Style.font.caption + Style.spacing.rowPaddingX * 2)
  property int historyLimit: 500

  function open(payloadJson) {
    root.opened = true
    root.filterText = ""
    root.selectedIndex = 0
    root.cursorActive = true
    root.disarmPointer()
    root.rebuildDisplay()
    Qt.callLater(function() { keyCatcher.forceActiveFocus() })
  }

  function close() {
    root.cancelClearHistory()
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
    var loaded = ClipboardHistory.parseHistory(raw, root.historyLimit)
    root.history = loaded || []
    root.historyWritable = loaded !== null
    if (loaded === null) {
      root.historyNotice = "Clipboard history unavailable · existing data kept"
      console.warn("clipboard: migrated history could not be parsed, not saving over it")
    }
    if (root.opened) root.rebuildDisplay()
  }

  function saveHistory() {
    if (!root.historyWritable) return
    root.saveRequested = true
    root.pumpStorage()
  }

  function pumpStorage() {
    if (loadProc.running || saveProc.running) return
    if (root.saveRequested && root.historyWritable) {
      root.saveRequested = false
      saveProc.snapshot = JSON.stringify(root.history.slice(0, root.historyLimit))
      saveProc.clearBackups = root.clearBackupsRequested
      root.clearBackupsRequested = false
      saveProc.stdinEnabled = true
      saveProc.running = true
    } else if (root.reloadRequested) {
      root.reloadRequested = false
      root.historyWritable = false
      loadProc.running = true
    }
  }

  function pruneText() {
    if (!root.historyWritable) return
    // Protect both pending captures and the last successfully saved history.
    Quickshell.execDetached(["bash", root.omarchyPath + "/shell/plugins/clipboard/prune-text.sh", root.textDir, root.historyPath]
      .concat(ClipboardHistory.largeTextNames(root.history))
      .concat(ClipboardHistory.largeTextNames(root.capturesDuringLoad)))
  }

  function addClipboardEntry(entry) {
    var normalized = ClipboardHistory.normalizeEntry(entry)
    if (!normalized) return
    if (!root.historyWritable) {
      if (loadProc.running)
        root.capturesDuringLoad = ClipboardHistory.addEntry(root.capturesDuringLoad, normalized, root.historyLimit)
      return
    }

    root.history = ClipboardHistory.addEntry(root.history, normalized, root.historyLimit)
    root.lastCopySkipped = false
    root.saveHistory()
    if (root.opened) root.rebuildDisplay()
  }

  function addClipboardJson(line) {
    var result = ClipboardHistory.captureResult(line)
    if (result.kind === "skipped") root.lastCopySkipped = true
    else if (result.kind === "entry") root.addClipboardEntry(result.entry)
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
    if (!root.historyWritable) return
    root.history = ClipboardHistory.clearHistory()
    root.historyNotice = ""
    root.clearBackupsRequested = true
    root.saveHistory()
    root.selectedIndex = 0
    root.cursorActive = false
    root.disarmPointer()
    root.clearConfirmOpen = false
    root.rebuildDisplay()
    Qt.callLater(function() { keyCatcher.forceActiveFocus() })
  }

  function removeDisplayIndex(index) {
    if (!root.historyWritable) return
    if (index < 0 || index >= displayModel.count) return

    var row = displayModel.get(index)
    root.history = ClipboardHistory.removeEntryAt(root.history, row.historyIndex)
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
    var rows = ClipboardHistory.displayRows(root.history, root.filterText, 50)

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
    if (!row || !root.historyWritable) return
    root.opened = false
    if (row.entryType === "image" || row.entryType === "largetext") {
      Quickshell.execDetached([root.omarchyPath + "/bin/omarchy-clipboard-paste-file", row.mime, row.path])
    } else if (row.fullText) {
      root.runEntryAction(row, [root.omarchyPath + "/bin/omarchy-clipboard-paste-text", "--shift-insert", "--stdin"])
    }
  }

  function copySelected(row) {
    if (!row || !root.historyWritable) return
    root.opened = false
    if (row.entryType === "image" || row.entryType === "largetext") {
      Quickshell.execDetached([root.omarchyPath + "/bin/omarchy-clipboard-paste-file", "--copy-only", row.mime, row.path])
    } else if (row.fullText) {
      root.runEntryAction(row, [root.omarchyPath + "/bin/omarchy-clipboard-paste-text", "--copy-only", "--stdin"])
    }
  }

  function openSelected(row) {
    // A large copy has no Open yet; the file itself is in clipboard-text.
    if (!row || !root.historyWritable || row.entryType === "largetext") return
    root.opened = false
    root.runEntryAction(row, [root.omarchyPath + "/bin/omarchy-clipboard-open", "--stdin"])
  }

  function runEntryAction(row, command) {
    var entry = root.history[row.historyIndex]
    if (!entry) return
    var action = entryActionComponent.createObject(root, {
      command: command,
      entryJson: JSON.stringify(entry)
    })
    action.running = true
  }

  Component {
    id: entryActionComponent
    Process {
      id: action
      property string entryJson: ""
      stdinEnabled: true
      onStarted: {
        action.write(action.entryJson)
        action.stdinEnabled = false
        action.entryJson = ""
      }
      onExited: action.destroy()
    }
  }

  Component.onCompleted: root.pumpStorage()

  ListModel { id: displayModel }

  PointerMoveGate {
    id: pointerGate
    referenceItem: card
  }

  // Watch outside edits without asking FileView to read or write the file.
  // The storage processes serialize all writes, including migration commits.
  FileView {
    id: historyFile
    path: root.historyPath
    preload: false
    printErrors: false
    watchChanges: true
    onFileChanged: historyReloadTimer.restart()
  }

  Timer {
    id: historyReloadTimer
    interval: 200
    onTriggered: {
      root.reloadRequested = true
      root.pumpStorage()
    }
  }

  // A copy evicted during its first minute is still protected by the capture
  // grace period. Revisit it even if the user never copies anything else.
  Timer {
    interval: 60000
    repeat: true
    running: root.historyWritable
    onTriggered: root.pruneText()
  }

  Process {
    id: saveProc
    property string snapshot: ""
    property bool clearBackups: false
    command: ["bash", root.omarchyPath + "/shell/plugins/clipboard/save-history.sh", root.historyPath, String(ClipboardHistory.historyFileLimit)]
      .concat(saveProc.clearBackups ? ["--clear-backups"] : [])
    stderr: StdioCollector { id: saveWarnings; waitForEnd: true }
    onStarted: {
      saveProc.write(saveProc.snapshot)
      saveProc.stdinEnabled = false
      saveProc.snapshot = ""
    }
    onExited: function(exitCode) {
      if (exitCode === 0) {
        if (root.historyNotice === root.saveFailedNotice) root.historyNotice = ""
        if (saveWarnings.text.indexOf("could not remove recovery backup") >= 0)
          root.historyNotice = "History cleared · some recovery backups could not be removed"
        root.pruneText()
      } else {
        if (saveProc.clearBackups) root.clearBackupsRequested = true
        root.historyNotice = root.saveFailedNotice
        console.warn("clipboard: history save failed: " + saveWarnings.text.trim())
        // Preserve the unsaved in-memory entries; an own-file notification
        // from an earlier write must not reload an older snapshot over them.
        root.reloadRequested = false
        historyReloadTimer.stop()
      }
      Qt.callLater(root.pumpStorage)
    }
  }

  // Watchers start only once history has loaded, so no copy can be saved over a
  // history that has not been read yet.
  Process {
    id: loadProc
    command: ["bash", root.omarchyPath + "/shell/plugins/clipboard/load-history.sh", root.historyPath, String(ClipboardHistory.historyFileLimit)]
    stdout: StdioCollector { id: loadOutput; waitForEnd: true }
    stderr: StdioCollector { id: loadWarnings; waitForEnd: true }
    onExited: function(exitCode) {
      if (loadWarnings.text) console.warn(loadWarnings.text.trim())
      if (exitCode === 0) {
        root.loadHistory(loadOutput.text)
        if (loadWarnings.text.indexOf("history set aside") >= 0)
          root.historyNotice = "Previous clipboard history set aside · backup kept"
        else if (loadWarnings.text.indexOf("some entries kept only") >= 0)
          root.historyNotice = "Some older entries kept in recovery backup"
        if (root.historyWritable) {
          var pending = root.capturesDuringLoad
          root.capturesDuringLoad = []
          for (var i = pending.length - 1; i >= 0; i--) root.addClipboardEntry(pending[i])
          if (!root.watchersStarted) initProc.running = true
          else if (!textWatchProc.running || !imageWatchProc.running) watchRestartTimer.restart()
          root.pruneText()
        }
      } else {
        root.historyNotice = "Clipboard history unavailable · existing data kept"
        console.warn("clipboard: history could not be read (load-history.sh exited " + exitCode + "), not saving over it")
      }
      if (!root.historyWritable) {
        textWatchProc.running = false
        imageWatchProc.running = false
      }
      Qt.callLater(root.pumpStorage)
    }
  }

  // Reap watchers left behind by a previous shell instance, then start our
  // own. The pdeathsig on the watchers makes the kernel kill them whenever
  // the shell exits, however it exits, so no further lifecycle management.
  Process {
    id: initProc
    command: ["pkill", "-f", "wl-paste .*--watch .*/shell/plugins/clipboard/capture\\.sh"]
    onExited: {
      root.watchersStarted = true
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
      if (root.historyWritable) {
        if (!textWatchProc.running) textWatchProc.running = true
        if (!imageWatchProc.running) imageWatchProc.running = true
      }
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
        focus: true

        Keys.priority: Keys.BeforeItem
        Keys.onPressed: function(event) {
          if (root.clearConfirmOpen) {
            if (clearConfirm.handleKey(event)) event.accepted = true
            return
          }

          if (event.key === Qt.Key_Escape) {
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
            else if (root.cursorActive && (event.modifiers & Qt.ShiftModifier)) root.copyIndex(root.selectedIndex)
            else if (root.cursorActive) root.activateIndex(root.selectedIndex)
            else if (displayModel.count > 0) root.cursorActive = true
            event.accepted = true
          } else if (event.text && event.text.length === 1 && event.text.charCodeAt(0) >= 32 && event.text.charCodeAt(0) !== 127) {
            root.setFilter(root.filterText + event.text)
            event.accepted = true
          }
        }

        ConfirmDialog {
          id: clearConfirm

          anchors.fill: parent
          opened: root.clearConfirmOpen
          z: 10
          message: "Delete entire clipboard history?"
          confirmText: "Delete"
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
            text: root.filterText || "Search clipboard…"
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

                // Where the copy would have appeared, a quiet note that it was not kept.
                // Its height comes from font metrics rather than from laying the text out,
                // so the layout can never feed back into the note's own size.
                header: Item {
                  width: resultList.width
                  height: root.lastCopySkipped || root.historyNotice ? skippedMetrics.height + Style.space(8) : 0

                  FontMetrics {
                    id: skippedMetrics
                    font.family: root.fontFamily
                    font.pixelSize: Style.font.caption
                  }

                  Text {
                    textFormat: Text.PlainText
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: Style.space(12)
                    anchors.verticalCenter: parent.verticalCenter
                    visible: root.lastCopySkipped || root.historyNotice.length > 0
                    text: root.historyNotice || "Last copy not saved · too large or too slow"
                    color: root.foreground
                    opacity: 0.5
                    font.family: root.fontFamily
                    font.pixelSize: Style.font.caption
                    elide: Text.ElideRight
                  }
                }

                delegate: Rectangle {
                  id: row
                  required property int index
                  required property string entryType
                  required property string previewText
                  required property string fullText
                  required property string previewImage

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

                    Image {
                      visible: parent.parent.previewImage.length > 0
                      width: visible ? parent.height : 0
                      height: parent.height
                      source: parent.parent.previewImage
                      fillMode: Image.PreserveAspectFit
                      asynchronous: true
                      smooth: true
                    }

                    Text {
                      textFormat: Text.PlainText
                      width: parent.width - (parent.parent.previewImage.length > 0 ? parent.height + parent.spacing : 0)
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
                textFormat: Text.PlainText
                visible: parent.activeRow && !parent.activeRow.previewImage
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

              Image {
                visible: parent.activeRow && parent.activeRow.previewImage
                anchors.fill: parent
                anchors.leftMargin: root.contentMargin
                anchors.rightMargin: 0
                anchors.topMargin: 0
                anchors.bottomMargin: 0
                source: parent.activeRow ? parent.activeRow.previewImage : ""
                fillMode: Image.PreserveAspectFit
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
              text: root.history.length === 0 ? "Clipboard is empty" : "No matches for “" + root.filterText + "”"
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
