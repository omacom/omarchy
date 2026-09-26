import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Controls as QQC
import qs.Commons
import qs.Ui
import "PaintModel.js" as PaintModel

Item {
  id: root

  property string omarchyPath: Quickshell.env("OMARCHY_PATH")
  property var shell: null
  property var manifest: null

  property bool opened: false
  property var canvas: null
  property var history: null
  property string canvasText: ""
  property string filePath: ""
  property string preview: ""
  property bool dirty: false
  property bool writing: false
  property bool painting: false
  property bool ignoreCanvas: false
  property bool canvasReady: false
  property bool canUndo: false
  property bool canRedo: false
  readonly property bool hasUnsavedChanges: dirty && canUndo
  property int boardRev: 0
  property string tool: "block"
  property string lastPaintTool: "block"
  property string lineStyle: "single"
  property int shadeLevel: 3
  property int zoom: 1
  property int strokeC0: 0
  property int strokeR0: 0
  property int strokeC1: 0
  property int strokeR1: 0
  property var strokeBase: null
  property string lastStamp: ""
  property string strokeIntent: "paint"
  property bool typing: false
  property var textBase: null
  property int textCol: 0
  property int textRow: 0
  property int textOrigin: 0
  property string textBuffer: ""
  property string confirmAction: ""
  property var pendingPayload: ({})

  property color background: Color.menu.background
  property color foreground: Color.menu.text
  property color border: Color.menu.border
  property var borderSpec: Border.surfaceSpec("menu", "border", border, Math.max(1, Style.space(2)))
  property color scrim: Color.menu.scrim
  property color selectedBackground: Color.menu.selectedBackground
  property color selectedText: Color.menu.selectedText
  readonly property int cornerRadius: Style.cornerRadius
  property string fontFamily: Style.font.family
  property int contentMargin: Style.spacing.panelPadding
  property int cardWidth: Math.min(Style.space(1100), panel.width - Style.gapsOut * 2)
  property int cardHeight: Math.min(Style.space(760), panel.height - Style.gapsOut * 2)
  property int cellPixel: Math.max(10, Math.round(Style.font.body * root.zoom * 1.35))
  readonly property real cellW: {
    var size = artMetrics.font.pixelSize
    var measured = size > 0 ? artMetrics.advanceWidth("M") : 0
    return Math.max(1, measured || Math.round(root.cellPixel * 0.6))
  }
  readonly property real cellH: {
    var size = artMetrics.font.pixelSize
    var measured = size > 0 ? artMetrics.height : 0
    return Math.max(1, measured || root.cellPixel)
  }
  readonly property real artWidth: {
    var _ = root.boardRev
    return (canvas ? canvas.cols : 0) * cellW
  }
  readonly property real artHeight: {
    var _ = root.boardRev
    return (canvas ? canvas.rows : 0) * cellH
  }
  readonly property string statusText: {
    var size = (canvas ? canvas.cols : 0) + "\u00d7" + (canvas ? canvas.rows : 0)
    var name = filePath.length ? filePath : "unsaved"
    return size + "  " + name + (dirty ? "  \u2022 modified" : "")
  }

  function open(payloadJson) {
    var payload = {}
    try { payload = JSON.parse(payloadJson || "{}") || {} } catch (e) {}
    if (root.opened && root.hasUnsavedChanges) {
      root.pendingPayload = payload
      root.confirmAction = "open"
      confirmDialog.message = "Discard unsaved paint?"
      confirmDialog.opened = true
      return
    }
    root.loadPayload(payload)
    root.opened = true
    Qt.callLater(function() { if (root.opened) keyCatcher.forceActiveFocus() })
  }

  function close() {
    root.opened = false
    confirmDialog.opened = false
  }

  function dismiss() {
    root.opened = false
    confirmDialog.opened = false
    if (root.shell && typeof root.shell.hide === "function")
      root.shell.hide((root.manifest && root.manifest.id) || "omarchy.ascii-paint")
  }

  function requestClose() {
    if (root.hasUnsavedChanges) {
      root.confirmAction = "close"
      confirmDialog.message = "Discard unsaved paint?"
      confirmDialog.opened = true
      return
    }
    root.dismiss()
  }

  function loadPayload(payload) {
    root.preview = payload && payload.preview ? String(payload.preview) : ""
    root.filePath = payload && payload.path ? String(payload.path) : ""
    root.tool = "block"
    root.lastPaintTool = "block"
    root.dirty = false
    root.painting = false
    root.typing = false
    root.textBase = null
    root.textBuffer = ""
    root.canvasReady = false
    if (!root.filePath) {
      root.applyCanvas(PaintModel.createCanvas(80, 24), false)
      return
    }
    root.writing = false
    artFile.path = ""
    Qt.callLater(function() {
      artFile.path = root.filePath
      artFile.reload()
    })
  }

  function applyCanvas(next, isDirty) {
    root.canvas = next
    root.history = PaintModel.createHistory()
    PaintModel.checkpoint(root.history, root.canvas)
    root.dirty = !!isDirty
    root.canvasReady = true
    root.syncHistoryButtons()
    root.refresh()
  }

  function applyFile(text) {
    if (text && String(text).length) {
      root.applyCanvas(PaintModel.parse(text), false)
      return
    }
    if (!root.filePath) root.applyCanvas(PaintModel.createCanvas(80, 24), false)
  }

  function strokeKind() {
    if (root.tool === "rect") return "rect"
    if (root.tool === "line") return "line"
    return ""
  }

  function strokeStyle() {
    return root.lineStyle === "double" ? "double" : "single"
  }

  readonly property bool shadePaletteVisible: tool === "shade" || tool === "fill"
  readonly property bool linePaletteVisible: tool === "line" || tool === "rect"

  function swallowCanvasClick() {
    root.ignoreCanvas = true
    Qt.callLater(function() { root.ignoreCanvas = false })
  }

  function finishOpenEdit() {
    if (root.typing) root.commitText()
    if (!root.painting) return
    if (root.strokeBase) root.strokeBase = null
    else root.checkpoint()
    root.painting = false
  }

  function afterChromeClick() {
    root.finishOpenEdit()
    root.swallowCanvasClick()
  }

  function pointerOnChrome(item, x, y) {
    if (!chrome || !item) return false
    var p = item.mapToItem(chrome, x, y)
    return p.x >= 0 && p.y >= 0 && p.x < chrome.width && p.y < chrome.height
  }

  function shownCanvas() {
    if (root.painting && root.strokeBase && root.strokeKind() !== "")
      return PaintModel.withStroke(root.strokeBase, root.strokeKind(), root.strokeC0, root.strokeR0, root.strokeC1, root.strokeR1, root.strokeStyle())
    return root.canvas
  }

  function refresh() {
    if (!root.canvas) return
    root.boardRev += 1
    root.canvasText = PaintModel.render(root.shownCanvas())
    if (gridCanvas) gridCanvas.requestPaint()
  }

  function setTool(name) {
    root.commitText()
    root.painting = false
    root.strokeBase = null
    root.tool = name
    if (name === "block" || name === "braille" || name === "shade")
      root.lastPaintTool = name
  }

  onZoomChanged: if (root.canvas) root.refresh()

  function checkpoint() {
    if (root.history && root.canvas) PaintModel.checkpoint(root.history, root.canvas)
    root.syncHistoryButtons()
  }

  function syncHistoryButtons() {
    root.canUndo = PaintModel.canUndo(root.history)
    root.canRedo = PaintModel.canRedo(root.history)
  }

  function markDirty() {
    root.dirty = true
    root.refresh()
  }

  function undoPaint() {
    if (root.typing) {
      root.cancelText()
      return
    }
    if (!PaintModel.canUndo(root.history)) return
    root.painting = false
    root.strokeBase = null
    root.swallowCanvasClick()
    root.canvas = PaintModel.undo(root.history)
    root.dirty = true
    root.refresh()
    Qt.callLater(function() { root.syncHistoryButtons() })
  }

  function redoPaint() {
    if (root.typing) root.commitText()
    if (!PaintModel.canRedo(root.history)) return
    root.painting = false
    root.strokeBase = null
    root.swallowCanvasClick()
    root.canvas = PaintModel.redo(root.history)
    root.dirty = true
    root.refresh()
    Qt.callLater(function() { root.syncHistoryButtons() })
  }

  function resizeCanvas(cols, rows) {
    if (!root.canvas) return
    if (cols === root.canvas.cols && rows === root.canvas.rows) return
    root.canvas = PaintModel.resize(root.canvas, cols, rows)
    root.checkpoint()
    root.markDirty()
  }

  function growCanvas(side, delta) {
    root.afterChromeClick()
    if (!root.canvas) return
    var step = delta > 0 ? 1 : -1
    var top = side === "top" ? step : 0
    var right = side === "right" ? step : 0
    var bottom = side === "bottom" ? step : 0
    var left = side === "left" ? step : 0
    if (step > 0) root.canvas = PaintModel.pad(root.canvas, top, right, bottom, left)
    else root.canvas = PaintModel.crop(root.canvas, -top, -right, -bottom, -left)
    root.checkpoint()
    root.markDirty()
  }

  function fillReplacement() {
    return { kind: "shade", level: root.shadeLevel }
  }

  function hitFromMouse(mouse) {
    return {
      col: Math.floor(mouse.x / root.cellW),
      row: Math.floor(mouse.y / root.cellH),
      lx: mouse.x - Math.floor(mouse.x / root.cellW) * root.cellW,
      ly: mouse.y - Math.floor(mouse.y / root.cellH) * root.cellH
    }
  }

  function inCanvas(hit) {
    return root.canvas && hit.col >= 0 && hit.row >= 0 && hit.col < root.canvas.cols && hit.row < root.canvas.rows
  }

  function halfKey(hit) {
    var x = root.cellW > 0 ? hit.lx / root.cellW : 0
    var y = root.cellH > 0 ? hit.ly / root.cellH : 0
    if (Math.abs(y - 0.5) >= Math.abs(x - 0.5)) return y < 0.5 ? "t" : "b"
    return x < 0.5 ? "l" : "r"
  }

  function stampKey(hit) {
    if (root.tool === "block") return hit.col + ":" + hit.row + ":q" + PaintModel.quadrantAt(hit.lx, hit.ly, root.cellW, root.cellH)
    if (root.tool === "eraser") return hit.col + ":" + hit.row + ":e" + root.halfKey(hit)
    if (root.tool === "braille") {
      var dot = PaintModel.brailleDotAt(hit.lx, hit.ly, root.cellW, root.cellH)
      return hit.col + ":" + hit.row + ":b" + dot.dx + dot.dy
    }
    return hit.col + ":" + hit.row + ":" + root.tool
  }

  function paintHit(hit, intent) {
    if (!root.inCanvas(hit)) return
    PaintModel.applyStamp(root.canvas, {
      tool: root.tool,
      intent: intent,
      col: hit.col,
      row: hit.row,
      lx: hit.lx,
      ly: hit.ly,
      cellW: root.cellW,
      cellH: root.cellH,
      shadeLevel: root.shadeLevel
    })
    root.markDirty()
  }

  function beginText(hit) {
    if (!root.canvasReady || !root.inCanvas(hit)) return
    root.commitText()
    root.textBase = PaintModel.cloneCanvas(root.canvas)
    root.typing = true
    root.textRow = hit.row
    root.textCol = hit.col
    root.textOrigin = hit.col
    root.textBuffer = ""
    keyCatcher.forceActiveFocus()
    root.refresh()
  }

  function commitText() {
    if (!root.typing) return
    root.typing = false
    root.textBase = null
    if (root.textBuffer.length) root.checkpoint()
    root.textBuffer = ""
    root.refresh()
  }

  function cancelText() {
    if (!root.typing) return
    if (root.textBase) root.canvas = root.textBase
    root.typing = false
    root.textBase = null
    root.textBuffer = ""
    root.refresh()
  }

  function typeChar(ch) {
    if (!root.typing || !ch || ch === "\n" || ch === "\r") return
    if (ch.charCodeAt(0) < 32) return
    var hit = { col: root.textCol, row: root.textRow, lx: 0, ly: 0 }
    if (!root.inCanvas(hit)) return
    PaintModel.setLiteral(root.canvas, root.textCol, root.textRow, ch)
    root.textBuffer += ch
    root.textCol += 1
    root.dirty = true
    root.refresh()
  }

  function typeBackspace() {
    if (!root.typing || root.textCol <= root.textOrigin) return
    root.textCol -= 1
    root.textBuffer = root.textBuffer.slice(0, -1)
    var ch = root.textBase ? PaintModel.glyphAt(root.textBase, root.textCol, root.textRow) : " "
    PaintModel.setLiteral(root.canvas, root.textCol, root.textRow, ch)
    root.dirty = true
    root.refresh()
  }

  function beginStroke(hit, intent) {
    if (!root.canvasReady || !root.canvas) return
    if (!root.inCanvas(hit)) return
    root.painting = true
    root.strokeIntent = intent
    root.strokeC0 = hit.col
    root.strokeR0 = hit.row
    root.strokeC1 = hit.col
    root.strokeR1 = hit.row
    root.lastStamp = ""
    if (root.strokeKind() !== "" && intent === "paint") {
      root.strokeBase = PaintModel.cloneCanvas(root.canvas)
      root.refresh()
      return
    }
    root.strokeBase = null
    root.lastStamp = root.stampKey(hit)
    root.paintHit(hit, intent)
  }

  function dragStroke(hit) {
    if (!root.painting || !root.inCanvas(hit)) return
    if (root.strokeBase && root.strokeKind() !== "" && root.strokeIntent === "paint") {
      root.strokeC1 = hit.col
      root.strokeR1 = hit.row
      root.refresh()
      return
    }
    var key = root.stampKey(hit)
    if (key === root.lastStamp) return
    root.lastStamp = key
    root.paintHit(hit, root.strokeIntent)
  }

  function endStroke(hit) {
    if (!root.painting) return
    root.painting = false
    if (root.strokeBase && root.strokeKind() !== "" && root.strokeIntent === "paint") {
      var c1 = root.inCanvas(hit) ? hit.col : root.strokeC1
      var r1 = root.inCanvas(hit) ? hit.row : root.strokeR1
      root.canvas = PaintModel.withStroke(root.strokeBase, root.strokeKind(), root.strokeC0, root.strokeR0, c1, r1, root.strokeStyle())
      root.strokeBase = null
      root.markDirty()
      root.checkpoint()
      return
    }
    root.strokeBase = null
    root.checkpoint()
  }

  function runPreview() {
    if (root.preview === "screensaver")
      Quickshell.execDetached([root.omarchyPath + "/bin/omarchy-launch-screensaver", "force"])
    else if (root.preview === "about")
      Quickshell.execDetached([root.omarchyPath + "/bin/omarchy-launch-about"])
  }

  function save() {
    root.afterChromeClick()
    if (!root.filePath) {
      root.saveAs()
      return
    }
    root.saveTo(root.filePath)
  }

  function saveTo(path) {
    root.filePath = path
    root.writing = true
    mkdirProc.command = [
      "bash", "-c",
      "mkdir -p \"$(dirname -- \"$1\")\"; if [[ -f $1 ]]; then cp -f \"$1\" \"$2\"; fi; touch \"$1\"",
      "omarchy-ascii-paint-save",
      path,
      PaintModel.backupPath(path)
    ]
    mkdirProc.running = true
  }

  function finishWrite() {
    artFile.path = root.filePath
    artFile.setText(PaintModel.serialize(root.canvas))
    root.dirty = false
    root.history = PaintModel.createHistory()
    PaintModel.checkpoint(root.history, root.canvas)
    root.syncHistoryButtons()
    writeGuard.restart()
  }

  function chooseFile(saveMode) {
    chooserSave = saveMode
    var args = [root.omarchyPath + "/bin/omarchy-file-select", "--title", saveMode ? "Save Unicode art" : "Open Unicode art", "--extensions", "txt"]
    if (saveMode) args.splice(2, 0, "--save")
    chooserProc.command = args
    chooserProc.running = true
  }

  function openFile() { root.afterChromeClick(); root.chooseFile(false) }
  function saveAs() { root.afterChromeClick(); root.chooseFile(true) }

  property bool chooserSave: false

  FontMetrics {
    id: artMetrics
    font.family: root.fontFamily
    font.pixelSize: root.cellPixel
  }

  FileView {
    id: artFile
    watchChanges: false
    atomicWrites: true
    printErrors: false
    onLoaded: {
      if (root.writing) return
      root.applyFile(text())
    }
    onLoadFailed: {
      if (root.writing) return
      if (!root.canvasReady) root.applyCanvas(PaintModel.createCanvas(80, 24), false)
    }
  }

  Timer {
    id: writeGuard
    interval: 250
    repeat: false
    onTriggered: {
      root.writing = false
      root.runPreview()
    }
  }

  Process {
    id: mkdirProc
    onExited: function(exitCode) {
      if (exitCode === 0) root.finishWrite()
      else root.writing = false
    }
  }

  Process {
    id: chooserProc
    stdout: StdioCollector {
      id: chooserOut
      waitForEnd: true
    }
    onExited: function(exitCode) {
      if (exitCode !== 0) return
      var path = String(chooserOut.text || "").trim().split("\n")[0]
      if (!path) return
      if (root.chooserSave) root.saveTo(path)
      else {
        root.filePath = path
        root.writing = false
        artFile.path = ""
        Qt.callLater(function() {
          artFile.path = path
          artFile.reload()
        })
      }
    }
  }

  PanelWindow {
    id: panel
    visible: root.opened
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    WlrLayershell.namespace: "omarchy-ascii-paint"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    exclusionMode: ExclusionMode.Ignore

    Rectangle {
      anchors.fill: parent
      color: root.scrim
    }

    MouseArea {
      anchors.fill: parent
      onClicked: root.requestClose()
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
          if (confirmDialog.handleKey(event)) {
            event.accepted = true
            return
          }
          var ctrl = (event.modifiers & Qt.ControlModifier)
          if (root.typing) {
            if (event.key === Qt.Key_Escape) {
              root.cancelText()
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
              root.commitText()
            } else if (event.key === Qt.Key_Backspace) {
              root.typeBackspace()
            } else if (ctrl && event.key === Qt.Key_S) {
              root.commitText()
              root.save()
            } else if (ctrl && event.key === Qt.Key_Z) {
              if (event.modifiers & Qt.ShiftModifier) root.redoPaint()
              else root.undoPaint()
            } else if (event.text && event.text.length && event.text.charCodeAt(0) >= 32) {
              root.typeChar(event.text)
            }
            event.accepted = true
            return
          }
          if (event.key === Qt.Key_Escape) {
            root.requestClose()
            event.accepted = true
          } else if (ctrl && event.key === Qt.Key_S) {
            root.save()
            event.accepted = true
          } else if (ctrl && event.key === Qt.Key_Z && (event.modifiers & Qt.ShiftModifier)) {
            root.redoPaint()
            event.accepted = true
          } else if (ctrl && event.key === Qt.Key_Z) {
            root.undoPaint()
            event.accepted = true
          } else if (event.key === Qt.Key_B) {
            root.setTool("block")
            event.accepted = true
          } else if (event.key === Qt.Key_I) {
            root.setTool("braille")
            event.accepted = true
          } else if (event.key === Qt.Key_S && !ctrl) {
            root.setTool("shade")
            event.accepted = true
          } else if (event.key === Qt.Key_L) {
            root.setTool("line")
            event.accepted = true
          } else if (event.key === Qt.Key_D) {
            root.lineStyle = "double"
            if (root.tool !== "line" && root.tool !== "rect") root.setTool("line")
            event.accepted = true
          } else if (event.key === Qt.Key_R) {
            root.setTool("rect")
            event.accepted = true
          } else if (event.key === Qt.Key_F) {
            root.setTool("fill")
            event.accepted = true
          } else if (event.key === Qt.Key_E) {
            root.setTool("eraser")
            event.accepted = true
          } else if (event.key === Qt.Key_T) {
            root.setTool("text")
            event.accepted = true
          } else if (!ctrl && event.key >= Qt.Key_1 && event.key <= Qt.Key_4) {
            if (root.tool === "line" || root.tool === "rect") {
              if (event.key === Qt.Key_1) root.lineStyle = "single"
              else if (event.key === Qt.Key_2) root.lineStyle = "double"
            } else {
              root.shadeLevel = event.key - Qt.Key_0
            }
            event.accepted = true
          } else if (event.text === "+" || event.text === "=") {
            root.zoom = Math.min(3, root.zoom + 1)
            event.accepted = true
          } else if (event.text === "-" || event.text === "_") {
            root.zoom = Math.max(1, root.zoom - 1)
            event.accepted = true
          }
        }

        Item {
          id: chrome
          z: 2
          anchors.top: parent.top
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.topMargin: card.contentTopInset
          anchors.rightMargin: card.contentRightInset
          anchors.leftMargin: card.contentLeftInset
          height: chromeColumn.implicitHeight

          MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            preventStealing: true
            onPressed: function(mouse) {
              root.afterChromeClick()
              mouse.accepted = true
            }
          }

          TapHandler {
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            gesturePolicy: TapHandler.DragThreshold
            onPressedChanged: if (pressed) root.afterChromeClick()
          }

          Column {
            id: chromeColumn
            width: parent.width
            spacing: Style.spacing.md

          Row {
            id: titleRow
            width: parent.width
            spacing: Style.spacing.md

            Text {
              id: titleLabel
              text: "Paint"
              color: root.foreground
              font.family: root.fontFamily
              font.pixelSize: Style.font.heading
              anchors.verticalCenter: parent.verticalCenter
            }

            Item {
              width: Math.max(1, parent.width - titleLabel.width - fileButtons.width - Style.spacing.md * 2)
              height: 1
            }

            Row {
              id: fileButtons
              spacing: Style.spacing.md

              Button {
                text: "Undo"
                iconText: "\uf0e2"
                tooltipText: "Undo (Ctrl+Z)"
                foreground: root.foreground
                accent: Color.accent
                bordered: true
                enabled: root.canUndo
                onClicked: root.undoPaint()
              }
              Button {
                text: "Redo"
                iconText: "\uf01e"
                tooltipText: "Redo (Ctrl+Shift+Z)"
                foreground: root.foreground
                accent: Color.accent
                bordered: true
                enabled: root.canRedo
                onClicked: root.redoPaint()
              }
              Button {
                text: "Open"
                iconText: "\uf07c"
                tooltipText: "Open a text file"
                foreground: root.foreground
                accent: Color.accent
                bordered: true
                onClicked: root.openFile()
              }
              Button {
                text: "Save"
                iconText: "\uf0c7"
                tooltipText: "Save (Ctrl+S)"
                foreground: root.foreground
                accent: Color.accent
                bordered: true
                enabled: root.dirty
                onClicked: root.save()
              }
              Button {
                text: "Save As"
                iconText: "\uf0c5"
                tooltipText: "Save As"
                foreground: root.foreground
                accent: Color.accent
                bordered: true
                onClicked: root.saveAs()
              }
            }
          }

          Column {
            id: toolChrome
            width: parent.width
            spacing: Style.spacing.sm

            PanelSectionHeader {
              text: "Tools"
              foreground: root.foreground
              fontFamily: root.fontFamily
            }

            ButtonGroup {
              foreground: root.foreground
              accent: Color.accent
              value: root.tool
              options: [
                { value: "block", label: "Block (B)", icon: "\u2588", tooltip: "Paint block quadrants" },
                { value: "braille", label: "Braille (I)", icon: "\u28ff", tooltip: "Paint braille dots" },
                { value: "shade", label: "Shade (S)", icon: "\u2592", tooltip: "Paint a shade" },
                { value: "line", label: "Line (L)", icon: "\u2500", tooltip: "Draw a line" },
                { value: "rect", label: "Rect (R)", icon: "\u25a1", tooltip: "Draw a rectangle" },
                { value: "fill", label: "Fill (F)", icon: "\u25a4", tooltip: "Flood fill" },
                { value: "text", label: "Text (T)", icon: "A", tooltip: "Type a single line" },
                { value: "eraser", label: "Erase (E)", icon: "\u232b", tooltip: "Erase a half-block" }
              ]
              onChanged: function(value) { root.setTool(value) }
            }

            Row {
              spacing: Style.spacing.lg

              Column {
                visible: root.shadePaletteVisible || root.linePaletteVisible
                spacing: Style.spacing.sm

                PanelSectionHeader {
                  text: "Palette"
                  foreground: root.foreground
                  fontFamily: root.fontFamily
                }

                ButtonGroup {
                  visible: root.shadePaletteVisible
                  foreground: root.foreground
                  accent: Color.accent
                  fontSize: Style.font.title
                  value: String(root.shadeLevel)
                  options: [
                    { value: "1", label: "1", icon: "\u2591", tooltip: "Light shade (1)" },
                    { value: "2", label: "2", icon: "\u2592", tooltip: "Medium shade (2)" },
                    { value: "3", label: "3", icon: "\u2593", tooltip: "Heavy shade (3)" },
                    { value: "4", label: "4", icon: "\u2588", tooltip: "Solid (4)" }
                  ]
                  onChanged: function(value) {
                    root.afterChromeClick()
                    root.shadeLevel = Number(value)
                  }
                }

                ButtonGroup {
                  visible: root.linePaletteVisible
                  foreground: root.foreground
                  accent: Color.accent
                  value: root.lineStyle
                  options: [
                    { value: "single", label: "Single", icon: "\u2500", tooltip: "Single line" },
                    { value: "double", label: "Double", icon: "\u2550", tooltip: "Double line (D)" }
                  ]
                  onChanged: function(value) {
                    root.afterChromeClick()
                    root.lineStyle = value
                  }
                }
              }

              Column {
                spacing: Style.spacing.sm

                PanelSectionHeader {
                  text: "Zoom"
                  foreground: root.foreground
                  fontFamily: root.fontFamily
                }

                ButtonGroup {
                  foreground: root.foreground
                  accent: Color.accent
                  value: String(root.zoom)
                  options: [
                    { value: "1", label: "1\u00d7", tooltip: "Zoom 1\u00d7" },
                    { value: "2", label: "2\u00d7", tooltip: "Zoom 2\u00d7" },
                    { value: "3", label: "3\u00d7", tooltip: "Zoom 3\u00d7" }
                  ]
                  onChanged: function(value) {
                    root.afterChromeClick()
                    root.zoom = Number(value)
                  }
                }
              }
            }

            PanelSectionHeader {
              text: "Canvas"
              foreground: root.foreground
              fontFamily: root.fontFamily
            }

            Row {
              spacing: Style.spacing.lg

              Repeater {
                model: [
                  { side: "top", label: "Top" },
                  { side: "bottom", label: "Bottom" },
                  { side: "left", label: "Left" },
                  { side: "right", label: "Right" }
                ]

                Row {
                  required property var modelData
                  spacing: Style.spacing.sm

                  Text {
                    text: modelData.label
                    color: root.foreground
                    font.family: root.fontFamily
                    font.pixelSize: Style.font.body
                    anchors.verticalCenter: parent.verticalCenter
                  }
                  Button {
                    text: "+"
                    tooltipText: "Add to " + modelData.label.toLowerCase()
                    foreground: root.foreground
                    accent: Color.accent
                    bordered: true
                    onClicked: root.growCanvas(modelData.side, 1)
                  }
                  Button {
                    text: "\u2212"
                    tooltipText: "Remove from " + modelData.label.toLowerCase()
                    foreground: root.foreground
                    accent: Color.accent
                    bordered: true
                    enabled: {
                      var _ = root.boardRev
                      if (!root.canvas) return false
                      if (modelData.side === "top" || modelData.side === "bottom") return root.canvas.rows > 1
                      return root.canvas.cols > 1
                    }
                    onClicked: root.growCanvas(modelData.side, -1)
                  }
                }
              }

              Text {
                text: {
                  var _ = root.boardRev
                  return (root.canvas ? root.canvas.cols : 0) + " \u00d7 " + (root.canvas ? root.canvas.rows : 0)
                }
                color: root.foreground
                font.family: root.fontFamily
                font.pixelSize: Style.font.heading
                anchors.verticalCenter: parent.verticalCenter
              }
            }
          }
          }
        }

        Item {
            id: canvasHost
            z: 0
            anchors.top: chrome.bottom
            anchors.topMargin: Style.spacing.md
            anchors.bottom: statusLine.top
            anchors.bottomMargin: Style.spacing.md
            anchors.left: parent.left
            anchors.leftMargin: card.contentLeftInset
            anchors.right: parent.right
            anchors.rightMargin: card.contentRightInset
            readonly property bool vOverflow: artBoard.height + Style.space(16) > height
            readonly property bool hOverflow: artBoard.width + Style.space(16) > width

            Flickable {
              id: artFlick
              anchors.left: parent.left
              anchors.top: parent.top
              anchors.right: parent.right
              anchors.rightMargin: canvasHost.vOverflow ? 10 : 0
              anchors.bottom: parent.bottom
              anchors.bottomMargin: canvasHost.hOverflow ? 10 : 0
              clip: true
              contentWidth: Math.max(width, artBoard.width + Style.space(16))
              contentHeight: Math.max(height, artBoard.height + Style.space(16))
              boundsBehavior: Flickable.StopAtBounds
              QQC.ScrollBar.vertical: QQC.ScrollBar {
                parent: canvasHost
                anchors.top: artFlick.top
                anchors.bottom: artFlick.bottom
                anchors.left: artFlick.right
                width: 10
                visible: canvasHost.vOverflow
                policy: QQC.ScrollBar.AsNeeded
                interactive: true
              }
              QQC.ScrollBar.horizontal: QQC.ScrollBar {
                parent: canvasHost
                anchors.left: artFlick.left
                anchors.right: artFlick.right
                anchors.top: artFlick.bottom
                height: 10
                visible: canvasHost.hOverflow
                policy: QQC.ScrollBar.AsNeeded
                interactive: true
              }

              Item {
                id: artBoard
                x: Style.space(8)
                y: Style.space(8)
                width: root.artWidth
                height: root.artHeight

                Rectangle {
                  anchors.fill: parent
                  color: Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.04)
                  border.color: root.selectedText
                  border.width: Math.max(1, Style.normalBorderWidth)
                }

              Text {
                id: artText
                anchors.fill: parent
                text: root.canvasText
                color: root.foreground
                font.family: root.fontFamily
                font.pixelSize: root.cellPixel
                font.kerning: false
                wrapMode: Text.NoWrap
                lineHeightMode: Text.FixedHeight
                lineHeight: root.cellH
              }

              Canvas {
                id: gridCanvas
                anchors.fill: parent
                visible: root.zoom >= 2
                onPaint: {
                  var ctx = getContext("2d")
                  ctx.clearRect(0, 0, width, height)
                  ctx.strokeStyle = "rgba(255, 255, 255, 0.08)"
                  ctx.lineWidth = 1
                  var x
                  var y
                  for (x = 0; x <= width; x += root.cellW) {
                    ctx.beginPath()
                    ctx.moveTo(x + 0.5, 0)
                    ctx.lineTo(x + 0.5, height)
                    ctx.stroke()
                  }
                  for (y = 0; y <= height; y += root.cellH) {
                    ctx.beginPath()
                    ctx.moveTo(0, y + 0.5)
                    ctx.lineTo(width, y + 0.5)
                    ctx.stroke()
                  }
                }
              }

              Rectangle {
                visible: root.preview === "about"
                width: 54 * root.cellW
                height: 26 * root.cellH
                color: "transparent"
                border.color: root.selectedText
                border.width: 1
                opacity: 0.45
              }

              Rectangle {
                visible: root.typing
                x: root.textCol * root.cellW
                y: root.textRow * root.cellH
                width: root.cellW
                height: root.cellH
                color: "transparent"
                border.color: root.selectedText
                border.width: Math.max(1, Style.normalBorderWidth)
              }

              MouseArea {
                id: artMouse
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                preventStealing: pressed
                cursorShape: Qt.CrossCursor
                property real pressX: 0
                property real pressY: 0
                property bool dragging: false
                readonly property int clickSlop: Style.space(16)
                onPressed: function(mouse) {
                  if (root.ignoreCanvas || root.pointerOnChrome(artMouse, mouse.x, mouse.y)) {
                    mouse.accepted = true
                    return
                  }
                  var intent = PaintModel.pointerIntent(mouse.button, mouse.buttons, root.tool)
                  if (intent === "ignore") return
                  keyCatcher.forceActiveFocus()
                  artMouse.pressX = mouse.x
                  artMouse.pressY = mouse.y
                  artMouse.dragging = false
                  var hit = root.hitFromMouse(mouse)
                  if (root.tool === "text" && intent === "paint") {
                    root.beginText(hit)
                    return
                  }
                  if (root.typing) root.commitText()
                  root.beginStroke(hit, intent)
                }
                onPositionChanged: function(mouse) {
                  if (!artMouse.pressed || !root.painting) return
                  if (!artMouse.dragging) {
                    var dx = mouse.x - artMouse.pressX
                    var dy = mouse.y - artMouse.pressY
                    if (dx * dx + dy * dy <= artMouse.clickSlop * artMouse.clickSlop) return
                    artMouse.dragging = true
                  }
                  root.dragStroke(root.hitFromMouse(mouse))
                }
                onReleased: function(mouse) {
                  root.endStroke(root.hitFromMouse(mouse))
                }
                onCanceled: {
                  if (root.painting && !root.strokeBase) root.checkpoint()
                  root.painting = false
                  root.strokeBase = null
                  artMouse.dragging = false
                }
                onWheel: function(wheel) {
                  if (root.tool === "shade" || root.lastPaintTool === "shade") {
                    var delta = wheel.angleDelta.y > 0 ? 1 : -1
                    root.shadeLevel = Math.max(1, Math.min(4, root.shadeLevel + delta))
                    wheel.accepted = true
                  }
                }
              }
              }
            }
          }

        Text {
            id: statusLine
            z: 2
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottomMargin: card.contentBottomInset
            anchors.leftMargin: card.contentLeftInset
            anchors.rightMargin: card.contentRightInset
            text: root.statusText
            color: root.foreground
            opacity: 0.7
            font.family: root.fontFamily
            font.pixelSize: Style.font.bodySmall
            elide: Text.ElideMiddle
          }
      }

      ConfirmDialog {
        id: confirmDialog
        anchors.fill: parent
        message: "Discard unsaved paint?"
        cancelText: "Keep (K)"
        confirmText: "Discard (D)"
        cancelKey: Qt.Key_K
        confirmKey: Qt.Key_D
        background: root.background
        foreground: root.foreground
        scrim: Util.alpha(root.background, 0.72)
        selectedBackground: root.selectedBackground
        selectedText: root.selectedText
        fontFamily: root.fontFamily
        cornerRadius: root.cornerRadius
        onCanceled: confirmDialog.opened = false
        onConfirmed: {
          confirmDialog.opened = false
          root.dirty = false
          if (root.confirmAction === "open") root.loadPayload(root.pendingPayload)
          else root.dismiss()
        }
      }
    }
  }

  Component.onCompleted: {
    if (!root.canvas) root.applyCanvas(PaintModel.createCanvas(80, 24), false)
  }
}
