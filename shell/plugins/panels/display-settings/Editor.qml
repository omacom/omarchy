import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io
import qs.Ui
import qs.Commons
import qs.Commons as Commons
import "LayoutModel.js" as Model

ColumnLayout {
  id: root
  property string page: "layout"
  property var displays: []
  property var workspaces: []
  property string selected: ""
  property string reference: ""
  property var pending: null
  property int now: Math.floor(Date.now() / 1000)
  property string error: ""
  property bool dirty: false
  readonly property var display: displays.filter(function(d) { return d.name === root.selected })[0] || null
  readonly property bool busy: action.running
  readonly property var pages: ["layout", "displays", "workspaces"]
  readonly property var pageLabels: ["Arrangement", "Displays", "Workspaces"]
  signal closeRequested()
  Keys.onEscapePressed: function(event) {
    if (workspacePage.transfer) workspacePage.transfer = null
    else closeRequested()
    event.accepted = true
  }
  spacing: Style.space(14)

  function refresh() { if (!state.running) state.running = true }
  function reset() { dirty = false; error = ""; workspacePage.reset(); refresh() }
  function changed() { dirty = true; error = "" }
  function change(key, value) {
    if (!display || pending || busy) return
    displays = displays.map(function(d) {
      var copy = Object.assign({}, d)
      if (d.name === root.selected) copy[key] = value
      return copy
    })
    changed()
  }
  function run(verb) {
    if (busy) return
    error = ""
    action.verb = verb
    action.command = ["omarchy-monitor-layout", verb,
      verb === "preview" ? JSON.stringify(Model.request(displays, workspaces)) : String(pending.token)]
    action.running = true
  }
  function select(name) {
    selected = name
    reference = displays.filter(function(d) { return d.name !== name }).map(function(d) { return d.name })[0] || ""
  }

  Process {
    id: state
    command: ["omarchy-monitor-layout", "state"]
    stdout: StdioCollector {
      onStreamFinished: {
        try {
          var data = JSON.parse(text)
          if (root.busy && !data.pending) return
          root.pending = data.pending
          if (!root.dirty || data.pending) {
            root.displays = Model.fromMonitors(data.monitors)
            var assignments = data.pending && data.preview ? data.preview.workspaces : data.assignments
            root.workspaces = assignments
            if (!root.displays.some(function(d) { return d.name === root.selected })) root.select(root.displays.length ? root.displays[0].name : "")
          }
        } catch (e) { root.error = "Could not read display state" }
      }
    }
    stderr: StdioCollector { onStreamFinished: if (text.trim()) root.error = text.trim() }
  }
  Process {
    id: action
    property string verb: ""
    stdout: StdioCollector {
      onStreamFinished: {
        if (action.verb === "preview" && text.trim()) {
          try { root.pending = JSON.parse(text) } catch (e) { root.error = text.trim() }
        }
      }
    }
    stderr: StdioCollector { onStreamFinished: if (text.trim()) root.error = text.trim() }
    onExited: function(code) {
      if (code === 0) { root.dirty = false; root.refresh() }
      else { if (!root.error) root.error = "Display change failed"; root.refresh() }
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

  RowLayout {
    Layout.fillWidth: true
    Text {
      Layout.fillWidth: true
      text: "Display settings"
      color: Commons.Color.popups.text
      font.family: Style.font.family
      font.pixelSize: Style.font.title
      font.bold: true
    }
    Button { text: "Close"; focusable: true; bordered: true; onClicked: root.closeRequested() }
  }
  Row {
    spacing: Style.space(8)
    Repeater {
      model: root.pages
      Button {
        required property string modelData
        required property int index
        objectName: "display-settings-tab-" + modelData
        text: root.pageLabels[index]
        active: root.page === modelData
        bordered: true
        focusable: true
        onClicked: root.page = modelData
      }
    }
  }
  StackLayout {
    Layout.fillWidth: true
    Layout.fillHeight: true
    enabled: !root.pending && !root.busy
    currentIndex: root.pages.indexOf(root.page)
    ColumnLayout {
      spacing: Style.space(12)
      Text { Layout.fillWidth: true; wrapMode: Text.WordWrap; text: "Drag a display. Nearby edges snap together. Changes apply when you choose Preview."; color: Commons.Color.popups.text; font.family: Style.font.family; font.pixelSize: Style.font.caption }
      LayoutCanvas {
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.minimumHeight: Style.space(220)
        displays: root.displays
        selected: root.selected
        onSelectedDisplay: function(name) { root.select(name) }
        onMoveRequested: function(name, x, y) { root.displays = Model.move(root.displays, name, x, y); root.changed() }
      }
      RowLayout {
        Layout.fillWidth: true
        spacing: Style.space(12)
        Dropdown {
          Layout.fillWidth: true
          label: "Selected display"
          value: root.selected
          options: root.displays.map(function(d) { return {value: d.name, label: d.label} })
          onChanged: function(value) { root.select(value) }
        }
        NumberField { label: "X"; from: -32768; to: 32768; value: root.display ? root.display.x : 0; onModified: function(value) { root.change("x", value) } }
        NumberField { label: "Y"; from: -32768; to: 32768; value: root.display ? root.display.y : 0; onModified: function(value) { root.change("y", value) } }
      }
      RowLayout {
        Layout.fillWidth: true
        visible: root.displays.length > 1
        Dropdown {
          Layout.fillWidth: true
          label: "Place beside"
          value: root.reference
          options: root.displays.filter(function(d) { return d.name !== root.selected }).map(function(d) { return {value: d.name, label: d.name} })
          onChanged: function(value) { root.reference = value }
        }
        Repeater {
          model: ["left", "right", "above", "below"]
          Button {
            required property string modelData
            text: modelData.charAt(0).toUpperCase() + modelData.slice(1)
            bordered: true
            focusable: true
            onClicked: { root.displays = Model.place(root.displays, root.selected, root.reference, modelData); root.changed() }
          }
        }
      }
    }
    ColumnLayout {
      spacing: Style.space(18)
      Dropdown {
        Layout.fillWidth: true
        label: "Display"
        value: root.selected
        options: root.displays.map(function(d) { return {value: d.name, label: d.label} })
        onChanged: function(value) { root.select(value) }
      }
      Dropdown {
        Layout.fillWidth: true
        label: "Resolution"
        value: root.display ? root.display.mode.split("@")[0] : ""
        options: root.display ? Model.resolutions(root.display) : []
        onChanged: function(value) { root.change("mode", Model.modeForResolution(root.display, value)) }
      }
      Dropdown {
        Layout.fillWidth: true
        label: "Refresh rate"
        value: root.display ? root.display.mode.split("@")[1] : ""
        options: root.display ? Model.rates(root.display, root.display.mode.split("@")[0]).map(function(rate) { return {value: rate, label: rate + " Hz"} }) : []
        onChanged: function(value) { root.change("mode", root.display.mode.split("@")[0] + "@" + value) }
      }
      Dropdown {
        Layout.fillWidth: true
        label: "Orientation"
        value: root.display ? String(root.display.transform) : "0"
        options: [{value: "0", label: "Landscape"}, {value: "1", label: "Portrait · 90°"}, {value: "2", label: "Landscape · 180°"}, {value: "3", label: "Portrait · 270°"}]
        onChanged: function(value) { root.change("transform", Number(value)) }
      }
      Item { Layout.fillHeight: true }
    }
    WorkspaceAssignments {
      id: workspacePage
      displays: root.displays
      workspaces: root.workspaces
      onAssignmentsChanged: function(assignments) { root.workspaces = assignments; root.changed() }
    }
  }
  PanelSeparator { Layout.fillWidth: true; foreground: Commons.Color.popups.text }
  Text {
    Layout.fillWidth: true
    textFormat: Text.PlainText
    text: root.error || (root.pending ? "Keep these changes? Reverts in " + Math.max(0, root.pending.expires - root.now) + " seconds." : root.dirty ? "Unsaved changes. Preview before keeping." : "Your current configuration is unchanged.")
    wrapMode: Text.WordWrap
    color: root.error ? Commons.Color.urgent : Commons.Color.popups.text
    font.family: Style.font.family
    font.pixelSize: Style.font.body
  }
  Row {
    spacing: Style.space(10)
    Button {
      objectName: "preview-display-settings"
      text: root.pending ? "Keep changes" : "Preview"
      bordered: true
      focusable: true
      enabled: !root.busy && (root.pending || (root.dirty && !workspacePage.transfer && root.error === ""))
      onClicked: root.run(root.pending ? "keep" : "preview")
    }
    Button {
      text: root.pending ? "Revert" : "Reset changes"
      bordered: true
      focusable: true
      enabled: !root.busy
      onClicked: root.pending ? root.run("revert") : root.reset()
    }
  }
}
