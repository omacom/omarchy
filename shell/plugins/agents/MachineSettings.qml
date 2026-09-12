import QtQuick
import QtQuick.Controls
import qs.Commons
import qs.Ui

Item {
  id: root
  required property var usage
  property color foreground: Color.foreground
  property string fontFamily: Style.font.family
  property string selectedId: ""
  property string mode: ""
  property string editingId: ""
  readonly property bool editing: mode === "add" || mode === "rename"
  readonly property var machines: usage.remoteMachines
  readonly property int selectedIndex: {
    for (var i = 0; i < machines.length; i++) if (machines[i].id === selectedId) return i
    return machines.length ? 0 : -1
  }
  readonly property var selected: selectedIndex >= 0 ? machines[selectedIndex] : null
  signal backRequested()
  signal focusRequested()
  implicitHeight: content.implicitHeight

  onMachinesChanged: {
    if ((mode === "rename" || mode === "remove")
        && !machines.some(function(machine) { return machine.id === root.editingId })) {
      mode = ""
      root.focusRequested()
    }
    if (!machines.some(function(machine) { return machine.id === root.selectedId }))
      selectedId = machines.length ? machines[Math.min(Math.max(selectedIndex, 0), machines.length - 1)].id : ""
  }

  function move(direction) {
    if (mode !== "" || !machines.length) return
    var index = Math.max(0, Math.min(machines.length - 1, selectedIndex + direction))
    selectedId = machines[index].id
    machineList.positionViewAtIndex(index, ListView.Contain)
  }

  function edit(action) {
    if (usage.machineBusy || action === "rename" && !selected) return
    editingId = action === "rename" ? selected.id : ""
    mode = action
    targetField.text = ""
    labelField.text = action === "rename" ? selected.label : ""
    Qt.callLater(function() { (action === "add" ? targetField : labelField).forceActiveFocus() })
  }

  function back() {
    if (mode !== "") {
      mode = ""
      root.focusRequested()
    } else backRequested()
  }

  function submit() {
    if (usage.machineBusy) return
    if (mode === "add") usage.manageMachine(["add", targetField.text, "--label", labelField.text || targetField.text])
    else if (mode === "rename" && editingId) usage.manageMachine(["rename", editingId, "--label", labelField.text])
    else if (mode === "remove" && editingId) usage.manageMachine(["remove", editingId])
  }

  function removeSelected() {
    if (!selected || usage.machineBusy) return
    editingId = selected.id
    mode = "remove"
    root.focusRequested()
  }

  Keys.onEscapePressed: function(event) { root.back(); event.accepted = true }
  Connections {
    target: root.usage
    function onMachineCommandFinished(success) {
      if (success) { root.mode = ""; root.focusRequested() }
      else if (root.editing) Qt.callLater(function() {
        (root.mode === "add" ? targetField : labelField).forceActiveFocus()
      })
    }
  }

  Column {
    id: content
    width: parent.width
    spacing: Style.space(12)

    PanelSectionHeader { text: "REMOTE COMPUTERS"; foreground: root.foreground; fontFamily: root.fontFamily }

    Text {
      textFormat: Text.PlainText
      width: parent.width
      text: "Existing SSH access · connected user only\nNo software is installed on remote computers.\nUse independently created sessions, not copied or synced session directories."
      color: root.foreground
      font.family: root.fontFamily
      font.pixelSize: Style.font.caption
      wrapMode: Text.WordWrap
    }

    ListView {
      id: machineList
      width: parent.width
      height: Style.space(180)
      clip: true
      model: root.machines.length
      spacing: Style.space(4)
      currentIndex: root.selectedIndex
      onCurrentIndexChanged: if (currentIndex >= 0) positionViewAtIndex(currentIndex, ListView.Contain)
      delegate: Button {
        required property int index
        width: machineList.width
        text: root.machines[index].label + " · " + (root.machines[index].status || "pending")
        foreground: root.foreground
        fontFamily: root.fontFamily
        fontSize: Style.font.bodySmall
        hasCursor: index === root.selectedIndex
        selected: index === root.selectedIndex
        leftAlign: true
        enabled: root.mode === "" && !root.usage.machineBusy
        onClicked: root.selectedId = root.machines[index].id
      }
      Text {
        textFormat: Text.PlainText
        visible: root.machines.length === 0
        text: "No remote computers yet. Press n to add one."
        width: parent.width
        wrapMode: Text.WordWrap
        color: root.foreground
        font.family: root.fontFamily
        font.pixelSize: Style.font.caption
      }
    }

    Text {
      textFormat: Text.PlainText
      width: parent.width
      text: root.selected ? (root.selected.user || "Unknown user") + " · " + (root.selected.platform || "") + "\n" + root.selected.target + "\n" + (root.selected.error || (root.selected.issues || []).join("; ")) : ""
      color: root.foreground
      font.family: root.fontFamily
      font.pixelSize: Style.font.caption
      wrapMode: Text.WrapAnywhere
    }

    Flow {
      width: parent.width
      spacing: Style.space(8)
      Button { text: "Add [n]"; enabled: !root.usage.machineBusy; foreground: root.foreground; onClicked: root.edit("add") }
      Button { text: "Rename [e]"; foreground: root.foreground; enabled: !!root.selected && !root.usage.machineBusy; onClicked: root.edit("rename") }
      Button { text: "Remove [x]"; foreground: root.foreground; enabled: !!root.selected && !root.usage.machineBusy; onClicked: root.removeSelected() }
    }

    Column {
      visible: root.editing
      width: parent.width
      spacing: Style.space(6)
      TextField {
        id: targetField
        visible: root.mode === "add"
        width: parent.width
        placeholderText: "SSH alias or user@host"
        font.family: root.fontFamily
        selectByMouse: true
        KeyNavigation.tab: labelField
        onAccepted: labelField.forceActiveFocus()
      }
      TextField {
        id: labelField
        width: parent.width
        placeholderText: "Computer name"
        font.family: root.fontFamily
        selectByMouse: true
        KeyNavigation.tab: saveButton
        KeyNavigation.backtab: root.mode === "add" ? targetField : saveButton
        onAccepted: root.submit()
      }
      Button {
        id: saveButton
        text: root.usage.machineBusy ? "Connecting…" : "Save [Enter]"
        focusable: true
        foreground: root.foreground
        enabled: !root.usage.machineBusy
        KeyNavigation.tab: root.mode === "add" ? targetField : labelField
        onClicked: root.submit()
      }
    }

    Text {
      textFormat: Text.PlainText
      visible: root.mode === "remove"
      width: parent.width
      text: "Remove " + (root.selected ? root.selected.label : "") + " and its contribution?\nEnter confirms · Escape cancels"
      wrapMode: Text.WordWrap
      color: root.foreground
      font.family: root.fontFamily
      font.pixelSize: Style.font.bodySmall
    }

    Text {
      textFormat: Text.PlainText
      width: parent.width
      text: root.usage.machineError || (root.usage.machineBusy ? "Working…" : "j/k select · n add · e rename · x remove · Esc back")
      color: root.usage.machineError ? Color.urgent : root.foreground
      font.family: root.fontFamily
      font.pixelSize: Style.font.caption
      wrapMode: Text.WrapAnywhere
    }
  }
}
