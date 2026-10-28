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
  property string selected: ""
  property string reference: ""
  property var pending: null
  property int now: Math.floor(Date.now() / 1000)
  property string error: ""
  property bool dirty: false
  readonly property var display: displays.filter(function(d) { return d.name === root.selected })[0] || null
  readonly property bool busy: action.running
  readonly property var pages: ["layout", "displays"]
  readonly property var pageLabels: [Commons.I18n.t("displaySettings.arrangement"), Commons.I18n.t("displaySettings.displays")]
  readonly property int secondsLeft: pending ? Math.max(0, pending.expires - now) : 0
  signal closeRequested()
  Keys.onEscapePressed: function(event) {
    closeRequested()
    event.accepted = true
  }
  spacing: Style.space(14)

  function refresh() { if (!state.running) state.running = true }
  function reset() { dirty = false; error = ""; refresh() }
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
      verb === "preview" ? JSON.stringify(Model.request(displays)) : String(pending.token)]
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
            if (!root.displays.some(function(d) { return d.name === root.selected })) root.select(root.displays.length ? root.displays[0].name : "")
          }
        } catch (e) { root.error = Commons.I18n.t("displaySettings.readFailed") }
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
      else { if (!root.error) root.error = Commons.I18n.t("displaySettings.changeFailed"); root.refresh() }
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
      textFormat: Text.PlainText
      text: Commons.I18n.t("displaySettings.title")
      color: Commons.Color.popups.text
      font.family: Style.font.family
      font.pixelSize: Style.font.title
      font.bold: true
    }
    Button { text: Commons.I18n.t("displaySettings.close"); focusable: true; bordered: true; onClicked: root.closeRequested() }
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
      Text { Layout.fillWidth: true; wrapMode: Text.WordWrap; textFormat: Text.PlainText; text: Commons.I18n.t("displaySettings.dragHint"); color: Commons.Color.popups.text; font.family: Style.font.family; font.pixelSize: Style.font.caption }
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
          label: Commons.I18n.t("displaySettings.selectedDisplay")
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
          label: Commons.I18n.t("displaySettings.placeBeside")
          value: root.reference
          options: root.displays.filter(function(d) { return d.name !== root.selected }).map(function(d) { return {value: d.name, label: d.name} })
          onChanged: function(value) { root.reference = value }
        }
        Repeater {
          model: [
            { side: "left", label: Commons.I18n.t("displaySettings.placeLeft") },
            { side: "right", label: Commons.I18n.t("displaySettings.placeRight") },
            { side: "above", label: Commons.I18n.t("displaySettings.placeAbove") },
            { side: "below", label: Commons.I18n.t("displaySettings.placeBelow") }
          ]
          Button {
            required property var modelData
            text: modelData.label
            bordered: true
            focusable: true
            onClicked: { root.displays = Model.place(root.displays, root.selected, root.reference, modelData.side); root.changed() }
          }
        }
      }
    }
    ColumnLayout {
      spacing: Style.space(18)
      Dropdown {
        Layout.fillWidth: true
        label: Commons.I18n.t("monitor.display")
        value: root.selected
        options: root.displays.map(function(d) { return {value: d.name, label: d.label} })
        onChanged: function(value) { root.select(value) }
      }
      Dropdown {
        Layout.fillWidth: true
        label: Commons.I18n.t("displaySettings.resolution")
        value: root.display ? root.display.mode.split("@")[0] : ""
        options: root.display ? Model.resolutions(root.display) : []
        onChanged: function(value) { root.change("mode", Model.modeForResolution(root.display, value)) }
      }
      Dropdown {
        Layout.fillWidth: true
        label: Commons.I18n.t("displaySettings.refreshRate")
        value: root.display ? root.display.mode.split("@")[1] : ""
        options: root.display ? Model.rates(root.display, root.display.mode.split("@")[0]).map(function(rate) { return {value: rate, label: Commons.I18n.t("displaySettings.refreshRateValue").arg(rate)} }) : []
        onChanged: function(value) { root.change("mode", root.display.mode.split("@")[0] + "@" + value) }
      }
      Dropdown {
        Layout.fillWidth: true
        label: Commons.I18n.t("displaySettings.orientation")
        value: root.display ? String(root.display.transform) : "0"
        options: [
          {value: "0", label: Commons.I18n.t("displaySettings.landscape")},
          {value: "1", label: Commons.I18n.t("displaySettings.portrait90")},
          {value: "2", label: Commons.I18n.t("displaySettings.landscape180")},
          {value: "3", label: Commons.I18n.t("displaySettings.portrait270")}
        ]
        onChanged: function(value) { root.change("transform", Number(value)) }
      }
      Item { Layout.fillHeight: true }
    }
  }
  PanelSeparator { Layout.fillWidth: true; foreground: Commons.Color.popups.text }
  Text {
    Layout.fillWidth: true
    textFormat: Text.PlainText
    text: root.error || (root.pending ? Commons.I18n.tn("displaySettings.keepCountdown", root.secondsLeft).arg(Commons.I18n.formatNumber(root.secondsLeft))
      : root.dirty ? Commons.I18n.t("displaySettings.unsaved") : Commons.I18n.t("displaySettings.unchanged"))
    wrapMode: Text.WordWrap
    color: root.error ? Commons.Color.urgent : Commons.Color.popups.text
    font.family: Style.font.family
    font.pixelSize: Style.font.body
  }
  Row {
    spacing: Style.space(10)
    Button {
      objectName: "preview-display-settings"
      text: root.pending ? Commons.I18n.t("displaySettings.keep") : Commons.I18n.t("displaySettings.preview")
      bordered: true
      focusable: true
      enabled: !root.busy && (root.pending || (root.dirty && root.error === ""))
      onClicked: root.run(root.pending ? "keep" : "preview")
    }
    Button {
      text: root.pending ? Commons.I18n.t("displaySettings.revert") : Commons.I18n.t("displaySettings.reset")
      bordered: true
      focusable: true
      enabled: !root.busy
      onClicked: root.pending ? root.run("revert") : root.reset()
    }
  }
}
