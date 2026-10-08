import QtQuick
import Quickshell.Io
import qs.Ui
import qs.Commons
import "LayoutModel.js" as Layout

Column {
  id: root
  property var displays: []
  property var workspaces: []
  property int selected: 0
  property var pending: null
  property int now: Math.floor(Date.now() / 1000)
  property string error: ""
  property bool dirty: false
  readonly property var display: displays[selected] || null
  readonly property bool busy: action.running
  readonly property var extent: Layout.bounds(displays)
  signal closeRequested()
  Keys.onEscapePressed: function(event) { root.closeRequested(); event.accepted = true }
  spacing: Style.space(10)

  function refresh() { if (!state.running) state.running = true }
  function change(key, value) {
    if (!display || pending || busy) return
    var copy = JSON.parse(JSON.stringify(displays))
    copy[selected][key] = value
    displays = copy
    dirty = true
    error = ""
  }
  function run(verb) {
    if (busy) return
    error = ""
    action.verb = verb
    action.command = ["omarchy-monitor-layout", verb,
      verb === "preview" ? JSON.stringify(Layout.request(displays, workspaces)) : String(pending.token)]
    action.running = true
  }
  function workspaceText() {
    return display ? workspaces.filter(function(w) { return w.monitor === display.name }).map(function(w) { return w.id }).join(" ") : ""
  }

  Component.onCompleted: refresh()

  Process {
    id: state
    command: ["omarchy-monitor-layout", "state"]
    stdout: StdioCollector {
      onStreamFinished: {
        try {
          var data = JSON.parse(text)
          root.pending = data.pending
          if (!root.dirty || data.pending) {
            root.displays = Layout.fromMonitors(data.monitors)
            root.workspaces = data.assignments.filter(function(w) { return root.displays.some(function(d) { return d.name === w.monitor }) })
            if (root.selected >= root.displays.length) root.selected = 0
          }
        } catch (e) { root.error = "Could not read display state" }
      }
    }
  }
  Process {
    id: action
    property string verb: ""
    stdout: StdioCollector {
      onStreamFinished: {
        if (action.verb === "preview" && text.trim()) {
          try { root.pending = JSON.parse(text) } catch (e) { root.error = String(text).trim() }
        }
      }
    }
    stderr: StdioCollector { onStreamFinished: if (text.trim()) root.error = text.trim() }
    onExited: function(code) {
      if (code === 0) { root.dirty = false; root.refresh() }
      else if (!root.error) root.error = "Display change failed"
    }
  }
  Timer {
    interval: 1000
    repeat: true
    running: root.visible
    onTriggered: {
      root.now = Math.floor(Date.now() / 1000)
      if (root.pending && root.now >= root.pending.expires) { root.dirty = false; root.refresh() }
    }
  }

  PanelSectionHeader { text: "DISPLAY LAYOUT" }
  Text {
    width: parent.width
    text: "Drag displays to arrange. Select one to configure."
    wrapMode: Text.WordWrap
    color: Color.popups.text
    font.family: Style.font.family
    font.pixelSize: Style.font.caption
  }
  BorderSurface {
    id: canvas
    width: parent.width
    height: Style.space(165)
    color: Color.popups.background
    borderSpec: Border.localOrSurfaceSpec("popups", "border", Color.popups.border, Color.popups.border, Style.normalBorderWidth)
    radius: Style.cornerRadius
    clip: true
    // Freeze geometry during a drag so changing bounds does not move the
    // coordinate origin underneath the pointer.
    property bool dragging: false
    property var dragExtent: null
    readonly property var view: dragging ? dragExtent : root.extent
    readonly property real ratio: Math.min((width - 32) / Math.max(1, view.width), (height - 32) / Math.max(1, view.height))
    readonly property real offsetX: (width - view.width * ratio) / 2
    readonly property real offsetY: (height - view.height * ratio) / 2

    Repeater {
      model: root.displays
      Rectangle {
        id: tile
        required property var modelData
        required property int index
        readonly property var logicalSize: Layout.size(modelData)
        x: canvas.offsetX + (modelData.x - canvas.view.x) * canvas.ratio
        y: canvas.offsetY + (modelData.y - canvas.view.y) * canvas.ratio
        width: logicalSize.width * canvas.ratio
        height: logicalSize.height * canvas.ratio
        color: index === root.selected ? Style.selectedFillFor(Color.popups.text, Color.accent) : Style.hoverFillFor(Color.popups.text, Color.accent)
        border.color: index === root.selected ? Color.accent : Color.popups.text
        border.width: 1
        radius: Style.cornerRadius
        Text {
          textFormat: Text.PlainText
          anchors.centerIn: parent
          width: parent.width - 6
          text: tile.modelData.name
          elide: Text.ElideRight
          horizontalAlignment: Text.AlignHCenter
          color: Color.popups.text
          font.family: Style.font.family
          font.pixelSize: Style.font.caption
        }
        MouseArea {
          anchors.fill: parent
          enabled: !root.pending && !root.busy
          cursorShape: Qt.SizeAllCursor
          property point start
          property point origin
          onPressed: function(mouse) {
            root.selected = tile.index
            start = mapToItem(canvas, mouse.x, mouse.y)
            origin = Qt.point(tile.modelData.x, tile.modelData.y)
            canvas.dragExtent = root.extent
            canvas.dragging = true
          }
          onPositionChanged: function(mouse) {
            if (!pressed) return
            var p = mapToItem(canvas, mouse.x, mouse.y)
            root.change("x", Math.round((origin.x + (p.x - start.x) / canvas.ratio) / 10) * 10)
            root.change("y", Math.round((origin.y + (p.y - start.y) / canvas.ratio) / 10) * 10)
          }
          onReleased: canvas.dragging = false
          onCanceled: canvas.dragging = false
        }
      }
    }
  }

  Column {
    width: parent.width
    spacing: Style.space(8)
    enabled: !root.pending && !root.busy
    Dropdown {
      id: monitorChoice
      width: parent.width
      label: "Display"
      options: root.displays.map(function(d) { return d.name })
      value: root.display ? root.display.name : ""
      onChanged: function(value) { root.selected = root.displays.findIndex(function(d) { return d.name === value }) }
    }
    Dropdown {
      id: modeChoice
      width: parent.width
      label: "Resolution / refresh rate"
      options: root.display ? root.display.modes.map(function(m) { return {value: m, label: m.replace("@", " · ") + " Hz"} }) : []
      value: root.display ? root.display.mode : ""
      onChanged: function(value) { root.change("mode", value) }
    }
    Dropdown {
      id: rotationChoice
      width: parent.width
      label: "Orientation"
      options: [{value: "0", label: "Landscape"}, {value: "1", label: "Portrait · 90°"}, {value: "2", label: "Landscape · 180°"}, {value: "3", label: "Portrait · 270°"}]
      value: root.display ? String(root.display.transform) : "0"
      onChanged: function(value) { root.change("transform", Number(value)) }
    }
    Row {
      width: parent.width
      spacing: Style.space(10)
      NumberField {
        id: xField
        label: "X position"
        fieldWidth: (parent.width - parent.spacing) / 2
        from: -32768; to: 32768
        value: root.display ? root.display.x : 0
        onModified: function(value) { root.change("x", value) }
      }
      NumberField {
        id: yField
        label: "Y position"
        fieldWidth: (parent.width - parent.spacing) / 2
        from: -32768; to: 32768
        value: root.display ? root.display.y : 0
        onModified: function(value) { root.change("y", value) }
      }
    }
    Text { text: "Workspaces · numbers separated by spaces"; color: Color.popups.text; font.family: Style.font.family; font.pixelSize: Style.font.caption }
    TextField {
      id: workspaceField
      width: parent.width
      text: root.workspaceText()
      placeholderText: "1 2 3"
      onEditingFinished: {
        try {
          root.workspaces = Layout.assignments(text, root.display.name, root.workspaces)
          root.dirty = true
          root.error = ""
        } catch (e) { root.error = e.message }
      }
    }
  }

  Text {
    width: parent.width
    visible: root.error !== "" || !!root.pending
    textFormat: Text.PlainText
    text: root.error || (root.pending ? "Keep this layout? Reverts in " + Math.max(0, root.pending.expires - root.now) + "s" : "")
    wrapMode: Text.WordWrap
    color: Color.popups.text
    font.family: Style.font.family
    font.pixelSize: Style.font.caption
  }
  Row {
    width: parent.width
    spacing: Style.space(8)
    Button {
      text: root.pending ? "Keep" : "Preview"
      bordered: true
      focusable: true
      enabled: !root.busy && (root.pending || (root.dirty && root.error === ""))
      onClicked: root.run(root.pending ? "keep" : "preview")
    }
    Button {
      text: root.pending ? "Revert" : "Reset"
      bordered: true
      focusable: true
      enabled: !root.busy
      onClicked: {
        if (root.pending) root.run("revert")
        else { root.dirty = false; root.error = ""; root.refresh() }
      }
    }
  }
}
