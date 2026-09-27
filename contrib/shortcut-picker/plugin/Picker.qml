import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Commons
import qs.Ui
import "Native" as Native

// A selection window only: no app discovery, host API, or action execution.
Item {
  id: root
  property bool opened: false
  property string prompt: "Keybindings"
  property bool preparing: false
  property var client: null
  property int selectedIndex: 0
  property int requestedWidth: 800
  property int requestedHeight: 500
  property alias filterText: query.text
  readonly property int rowsHeight: results.count * rowHeight
    + results.detailCount * Style.space(24) + results.sectionCount * headingHeight
  readonly property int rowHeight: Style.space(50)
  readonly property int headingHeight: Style.space(34)

  function open(payloadJson) {
    var payload = typeof payloadJson === "string" ? JSON.parse(payloadJson) : payloadJson
    if (client) finish(null)
    prompt = payload.prompt || "Keybindings"
    requestedWidth = payload.width || 800
    requestedHeight = payload.maxHeight || 500
    preparing = true
    query.text = ""
    results.reset(payload.options || [])
    preparing = false
    resetCursor()
    opened = true
    pointerGate.reset()
    Qt.callLater(function() { query.forceActiveFocus() })
  }

  function finish(value) {
    opened = false
    var replyTo = client
    client = null
    if (replyTo) replyTo.reply({status:value === null ? "cancelled" : "selected", value:value})
  }
  function close() { finish(null) }
  function ping() { return "ok" }
  function state() {
    return JSON.stringify({opened:opened, prompt:prompt, query:filterText, labels:results.labels(),
      backend:"native",
      transport:{path:requests.path, active:requests.active}})
  }
  function setFilter(value) { query.text = value }
  function rebuild() {
    if (preparing) return
    results.filter(query.text)
    resetCursor()
  }
  function resetCursor() {
    selectedIndex = 0
    list.positionViewAtBeginning()
    pointerGate.reset()
  }
  function select(delta) {
    if (!results.count) return
    selectedIndex = (selectedIndex + delta + results.count) % results.count
    pointerGate.reset()
    list.positionViewAtIndex(selectedIndex, ListView.Contain)
  }
  function activateIndex(index) {
    if (index >= 0 && index < results.count) finish(results.value(index))
  }

  Native.SearchModel { id: results }
  PointerMoveGate { id: pointerGate; referenceItem: card }

  // A local connection delivers results without spawning a writer or polling
  // files. The user's private runtime directory isolates desktop sessions.
  SocketServer {
    id: requests
    readonly property string runtime: Quickshell.env("XDG_RUNTIME_DIR")
    readonly property string display: (Quickshell.env("WAYLAND_DISPLAY") || "default")
      .split("/").pop().replace(/[^A-Za-z0-9_.-]/g, "_")
    path: runtime ? runtime + "/omarchy-shortcuts-" + display + ".sock" : ""
    active: path !== ""
    handler: Socket {
      id: peer
      property bool received: false
      function reply(message) {
        write(JSON.stringify(message) + "\n")
        flush()
        if (message.status !== "ready") connected = false
      }
      onConnectionStateChanged: {
        if (!connected && root.client === peer) { root.client = null; root.opened = false }
      }
      Component.onDestruction: {
        if (root.client === peer) { root.client = null; root.opened = false }
      }
      parser: SplitParser {
        onRead: function(data) {
          if (peer.received) return
          peer.received = true
          try {
            var payload = JSON.parse(data)
            if (payload.version !== 1 || !Array.isArray(payload.options)
                || !payload.options.length || !payload.options.every(function(row) { return typeof row === "string" })
                || ["Keybindings", "Tmux keybindings", "Herdr keybindings"].indexOf(payload.prompt) < 0)
              throw new Error("Unsupported shortcut request")
            root.open(payload)
            root.client = peer
            peer.reply({status:"ready", version:1})
          } catch (error) {
            peer.reply({status:"error"})
          }
        }
      }
    }
  }

  PanelWindow {
    id: panel
    visible: root.opened
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "omarchy-shortcuts"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    readonly property int rowsCap: Math.max(40, Math.min(Style.space(root.requestedHeight),
      height - Style.gapsOut * 2 - Style.space(100)))

    Rectangle { anchors.fill: parent; color: Color.menu.scrim }
    MouseArea { anchors.fill: parent; onClicked: root.close() }

    BorderSurface {
      id: card
      anchors.horizontalCenter: parent.horizontalCenter
      y: Math.max(Style.gapsOut, (panel.height - panel.rowsCap - Style.space(100)) / 2)
      width: Math.min(Style.space(root.requestedWidth), panel.width - Style.gapsOut * 2)
      height: body.implicitHeight + contentTopInset + contentBottomInset
      padding: Style.spacing.panelPadding
      radius: Style.cornerRadius
      color: Color.menu.background
      borderSpec: Border.surfaceSpec("menu", "border", Color.menu.border, Math.max(1, Style.space(2)))
      MouseArea { anchors.fill: parent } // Keep blank card space from dismissing.

      Column {
        id: body
        x: card.contentLeftInset
        y: card.contentTopInset
        width: card.width - card.contentLeftInset - card.contentRightInset
        spacing: Style.spacing.md
        TextInput {
          id: query
          width: parent.width
          height: Style.space(40)
          color: Color.menu.text
          font.family: Style.font.menuFamily
          font.pixelSize: Style.font.title
          verticalAlignment: TextInput.AlignVCenter
          clip: true
          selectByMouse: true
          onTextChanged: root.rebuild()
          Text {
            anchors.fill: parent
            verticalAlignment: Text.AlignVCenter
            visible: !query.text
            text: root.prompt + "…"
            color: Color.menu.text
            opacity: 0.6
            font: query.font
          }
          Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Escape) {
              if (text) text = ""; else root.close()
            } else if (event.key === Qt.Key_Up) root.select(-1)
            else if (event.key === Qt.Key_Down) root.select(1)
            else if (event.key === Qt.Key_PageUp) root.select(-Math.min(6, results.count))
            else if (event.key === Qt.Key_PageDown) root.select(Math.min(6, results.count))
            else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) root.activateIndex(root.selectedIndex)
            else if (Util.editsFilter(event, text)) text = Util.editedFilter(event, text)
            else return
            event.accepted = true
          }
        }
        ListView {
          id: list
          width: parent.width
          height: Math.min(root.rowsHeight, panel.rowsCap)
          clip: true
          model: results
          reuseItems: true
          // Filtering changes most rows; avoid preparing hidden delegates.
          cacheBuffer: 0
          currentIndex: results.count ? root.selectedIndex : -1
          highlightMoveDuration: 0
          highlightResizeDuration: 0
          highlight: BorderSurface {
            color: Color.menu.selectedBackground
            borderSpec: Border.surfaceSpec("menu", "selected-border", Color.menu.selectedBorder, 0)
            radius: Style.cornerRadius
          }
          boundsBehavior: Flickable.StopAtBounds
          section.property: "section"
          section.delegate: Text {
            required property string section
            width: list.width
            height: section ? root.headingHeight : 0
            text: section
            color: Color.menu.text
            opacity: 0.65
            font.family: Style.font.menuFamily
            font.pixelSize: Style.font.bodySmall
            verticalAlignment: Text.AlignVCenter
            leftPadding: Style.spacing.rowPaddingX
          }
          delegate: Item {
            id: row
            required property int index
            required property string label
            required property string detail
            // The model formats these roles lazily when a delegate requests them.
            required property string labelHtml
            required property string detailHtml
            width: list.width
            height: root.rowHeight + (detail ? Style.space(24) : 0)
            Column {
              anchors.verticalCenter: parent.verticalCenter
              x: Style.spacing.rowPaddingX
              width: parent.width - x * 2
              Text {
                width: parent.width
                text: row.labelHtml || row.label
                textFormat: row.labelHtml ? Text.StyledText : Text.PlainText
                color: row.ListView.isCurrentItem ? Color.menu.selectedText : Color.menu.text
                font.family: Style.font.menuFamily
                font.pixelSize: Style.font.heading
                elide: Text.ElideRight
              }
              Text {
                visible: !!row.detail
                width: parent.width
                text: row.detailHtml || row.detail
                textFormat: row.detailHtml ? Text.StyledText : Text.PlainText
                color: Color.menu.text
                opacity: 0.65
                font.family: Style.font.menuFamily
                font.pixelSize: Style.font.caption
                elide: Text.ElideRight
              }
            }
            MouseArea {
              anchors.fill: parent
              hoverEnabled: true
              onPositionChanged: function(mouse) {
                if (pointerGate.moved(this, mouse)) root.selectedIndex = row.index
              }
              onClicked: root.activateIndex(row.index)
            }
          }
        }
        Text {
          visible: !results.count
          text: "No matching shortcuts"
          color: Color.menu.text
          opacity: 0.6
          font.family: Style.font.menuFamily
          font.pixelSize: Style.font.body
        }
      }
    }
  }
}
