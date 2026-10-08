import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Ui
import qs.Commons
import qs.Commons as Commons
import "LayoutModel.js" as Model

ColumnLayout {
  id: root
  property var displays: []
  property var workspaces: []
  property var extraIds: []
  property var transfer: null
  property string error: ""
  property int newId: 11
  readonly property var ids: Model.workspaceIds(workspaces, extraIds)
  signal assignmentsChanged(var assignments)
  spacing: Style.space(12)

  function reset() { transfer = null; error = ""; extraIds = [] }
  function requestAssignment(id, monitor) {
    if (!monitor) return
    error = ""
    try {
      var existing = Model.owner(workspaces, id)
      if (existing && existing !== monitor) transfer = {id: id, from: existing, to: monitor}
      else assignmentsChanged(Model.assignWorkspace(workspaces, id, monitor, false))
    } catch (e) { error = e.message }
  }
  function confirmTransfer() {
    if (!transfer) return
    try {
      assignmentsChanged(Model.assignWorkspace(workspaces, transfer.id, transfer.to, true))
      transfer = null
    } catch (e) { error = e.message }
  }

  Text {
    Layout.fillWidth: true
    text: "One monitor per workspace. Moving an assigned workspace requires confirmation."
    wrapMode: Text.WordWrap
    color: Commons.Color.popups.text
    font.family: Style.font.family
    font.pixelSize: Style.font.caption
  }
  RowLayout {
    Layout.fillWidth: true
    spacing: Style.space(8)
    Repeater {
      model: root.displays
      BorderSurface {
        required property var modelData
        Layout.fillWidth: true
        Layout.preferredWidth: 1
        implicitHeight: summary.implicitHeight + Style.space(20)
        color: Style.hoverFillFor(Commons.Color.popups.text, Commons.Color.accent)
        radius: Style.cornerRadius
        Column {
          id: summary
          anchors.fill: parent
          anchors.margins: Style.space(10)
          spacing: Style.space(5)
          Text {
            width: parent.width
            textFormat: Text.PlainText
            text: modelData.name
            elide: Text.ElideRight
            color: Commons.Color.popups.text
            font.family: Style.font.family
            font.pixelSize: Style.font.body
            font.bold: true
          }
          Text {
            width: parent.width
            textFormat: Text.PlainText
            text: root.workspaces.filter(function(w) { return w.monitor === modelData.name }).map(function(w) { return w.id }).join(" · ") || "No assigned workspaces"
            wrapMode: Text.WordWrap
            color: Commons.Color.popups.text
            font.family: Style.font.family
            font.pixelSize: Style.font.caption
          }
        }
      }
    }
  }
  ScrollView {
    id: workspaceScroll
    Layout.fillWidth: true
    Layout.fillHeight: true
    clip: true
    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
    Column {
      width: workspaceScroll.availableWidth
      spacing: Style.space(6)
      Repeater {
        model: root.ids
        RowLayout {
          required property int modelData
          width: parent.width
          enabled: !root.transfer
          spacing: Style.space(12)
          Text {
            Layout.preferredWidth: Style.space(125)
            textFormat: Text.PlainText
            text: "Workspace " + modelData
            color: Commons.Color.popups.text
            font.family: Style.font.family
            font.pixelSize: Style.font.body
          }
          Dropdown {
            objectName: "workspace-owner-" + modelData
            Layout.fillWidth: true
            showLabel: false
            options: [{value: "", label: "Choose monitor…"}].concat(root.displays.map(function(d) { return {value: d.name, label: d.label || d.name} }))
            value: Model.owner(root.workspaces, modelData)
            onChanged: function(value) { root.requestAssignment(modelData, value) }
          }
        }
      }
    }
  }
  BorderSurface {
    Layout.fillWidth: true
    visible: !!root.transfer
    implicitHeight: transferColumn.implicitHeight + Style.space(20)
    radius: Style.cornerRadius
    color: Style.selectedFillFor(Commons.Color.popups.text, Commons.Color.accent)
    Column {
      id: transferColumn
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.top: parent.top
      anchors.margins: Style.space(10)
      spacing: Style.space(8)
      Text {
        width: parent.width
        textFormat: Text.PlainText
        text: root.transfer ? "Move workspace " + root.transfer.id + " from " + root.transfer.from + " to " + root.transfer.to + "?" : ""
        wrapMode: Text.WordWrap
        color: Commons.Color.popups.text
        font.family: Style.font.family
        font.pixelSize: Style.font.body
      }
      Row {
        spacing: Style.space(8)
        Button { objectName: "confirm-workspace-transfer"; text: "Move workspace"; bordered: true; focusable: true; onClicked: root.confirmTransfer() }
        Button { text: "Cancel"; bordered: true; focusable: true; onClicked: root.transfer = null }
      }
    }
  }
  RowLayout {
    enabled: !root.transfer
    NumberField {
      label: "Additional workspace"
      from: 1; to: 99
      value: root.newId
      onModified: function(value) { root.newId = value }
    }
    Button {
      text: "Add"
      bordered: true
      focusable: true
      onClicked: {
        if (root.ids.indexOf(root.newId) >= 0) root.error = "Workspace " + root.newId + " is already listed"
        else { root.extraIds = root.extraIds.concat([root.newId]); root.error = "" }
      }
    }
  }
  Text {
    visible: root.error !== ""
    Layout.fillWidth: true
    textFormat: Text.PlainText
    text: root.error
    wrapMode: Text.WordWrap
    color: Commons.Color.urgent
    font.family: Style.font.family
    font.pixelSize: Style.font.caption
  }
}
