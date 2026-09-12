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
  property real detailMaximumHeight: 0
  property real confirmationMaximumHeight: 0
  property bool measurementPending: false
  signal backRequested()
  signal focusRequested()
  signal revealRequested(var item)
  implicitHeight: content.implicitHeight

  onMachinesChanged: {
    if ((mode === "rename" || mode === "remove")
        && !machines.some(function(machine) { return machine.id === root.editingId })) {
      mode = ""
      root.focusRequested()
    }
    if (!machines.some(function(machine) { return machine.id === root.selectedId }))
      selectedId = machines.length ? machines[Math.min(Math.max(selectedIndex, 0), machines.length - 1)].id : ""
    scheduleMeasurements()
    revealSelected()
  }

  onWidthChanged: scheduleMeasurements()
  Component.onCompleted: scheduleMeasurements()

  function revealSelected() {
    // A ListView can reset its viewport after replacing a numeric model even
    // when currentIndex remains unchanged. Wait for delegates to be rebuilt,
    // then contain the surviving selection in the new layout.
    Qt.callLater(function() {
      if (root.selectedIndex < 0) return
      machineList.forceLayout()
      var selectedItem = machineList.itemAtIndex(root.selectedIndex)
      if (selectedItem) root.revealRequested(selectedItem)
    })
  }

  function move(direction) {
    if (mode !== "" || !machines.length) return
    var index = Math.max(0, Math.min(machines.length - 1, selectedIndex + direction))
    selectedId = machines[index].id
    revealSelected()
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

  function detailText(machine) {
    if (!machine) return ""
    return (machine.user || "Unknown user") + " · " + (machine.platform || "") + "\n"
      + (machine.target || "") + "\n" + (machine.error || (machine.issues || []).join("; "))
  }

  function removeText(machine) {
    return "Remove " + (machine ? machine.label : "")
      + " and its contribution?\nEnter confirms · Escape cancels"
  }

  function scheduleMeasurements() {
    if (measurementPending) return
    measurementPending = true
    Qt.callLater(function() {
      root.measurementPending = false
      root.updateMeasurements()
    })
  }

  function maximumImplicitHeight(repeater) {
    var maximum = 0
    for (var i = 0; i < repeater.count; i++) {
      var item = repeater.itemAt(i)
      if (item) maximum = Math.max(maximum, item.implicitHeight)
    }
    return maximum
  }

  function updateMeasurements() {
    // Keep measurement dependencies out of the positioned content's height
    // bindings. Reading completed delegates here avoids a binding cycle while
    // still reserving the largest wrapped text in the current machine model.
    detailMaximumHeight = maximumImplicitHeight(detailMeasurements)
    confirmationMaximumHeight = maximumImplicitHeight(confirmationMeasurements)
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
      height: root.machines.length > 0 ? contentHeight : emptyMachineText.implicitHeight
      clip: false
      interactive: false
      model: root.machines.length
      spacing: Style.space(4)
      currentIndex: root.selectedIndex
      onCurrentIndexChanged: root.revealSelected()
      delegate: Button {
        required property int index
        readonly property var machine: index >= 0 && index < root.machines.length ? root.machines[index] : null
        width: machineList.width
        text: machine ? machine.label + " · " + (machine.status || "pending") : ""
        foreground: root.foreground
        fontFamily: root.fontFamily
        fontSize: Style.font.bodySmall
        hasCursor: index === root.selectedIndex
        selected: index === root.selectedIndex
        leftAlign: true
        enabled: !!machine && root.mode === "" && !root.usage.machineBusy
        onClicked: if (machine) root.selectedId = machine.id
      }
      Text {
        id: emptyMachineText
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

    Item {
      id: detailArea
      width: parent.width
      height: root.detailMaximumHeight

      Text {
        id: selectedDetail
        textFormat: Text.PlainText
        width: parent.width
        text: root.detailText(root.selected)
        color: root.foreground
        font.family: root.fontFamily
        font.pixelSize: Style.font.caption
        wrapMode: Text.WrapAnywhere
      }

    }

    Flow {
      width: parent.width
      spacing: Style.space(8)
      Button { text: "Add [n]"; enabled: !root.usage.machineBusy; foreground: root.foreground; onClicked: root.edit("add") }
      Button { text: "Rename [e]"; foreground: root.foreground; enabled: !!root.selected && !root.usage.machineBusy; onClicked: root.edit("rename") }
      Button { text: "Remove [x]"; foreground: root.foreground; enabled: !!root.selected && !root.usage.machineBusy; onClicked: root.removeSelected() }
    }

    Item {
      id: modeArea
      width: parent.width
      readonly property real maximumEditorHeight: targetField.implicitHeight + labelField.implicitHeight
        + saveButton.implicitHeight + editor.spacing * 2
      readonly property real maximumConfirmationHeight: root.confirmationMaximumHeight
      height: Math.max(maximumEditorHeight, removeConfirmation.implicitHeight, maximumConfirmationHeight)

      Column {
        id: editor
        visible: true
        opacity: root.editing ? 1 : 0
        enabled: root.editing
        width: parent.width
        spacing: Style.space(6)
        TextField {
          id: targetField
          visible: true
          opacity: root.mode === "add" ? 1 : 0
          enabled: root.mode === "add"
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
        id: removeConfirmation
        textFormat: Text.PlainText
        visible: true
        opacity: root.mode === "remove" ? 1 : 0
        enabled: root.mode === "remove"
        width: parent.width
        text: root.removeText(root.selected)
        wrapMode: Text.WordWrap
        color: root.foreground
        font.family: root.fontFamily
        font.pixelSize: Style.font.bodySmall
      }

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

  // Text measurement lives outside the positioned content to avoid making a
  // reserved area's height depend on descendants of that same area.
  Item {
    width: root.width
    height: 0
    opacity: 0
    enabled: false

    Repeater {
      id: detailMeasurements
      model: root.machines.length
      Text {
        required property int index
        readonly property var machine: index >= 0 && index < root.machines.length ? root.machines[index] : null
        textFormat: Text.PlainText
        width: root.width
        text: root.detailText(machine)
        font: selectedDetail.font
        wrapMode: selectedDetail.wrapMode
        onImplicitHeightChanged: root.scheduleMeasurements()
        Component.onCompleted: root.scheduleMeasurements()
      }
    }

    Repeater {
      id: confirmationMeasurements
      model: root.machines.length
      Text {
        required property int index
        readonly property var machine: index >= 0 && index < root.machines.length ? root.machines[index] : null
        textFormat: Text.PlainText
        width: root.width
        text: root.removeText(machine)
        font: removeConfirmation.font
        wrapMode: removeConfirmation.wrapMode
        onImplicitHeightChanged: root.scheduleMeasurements()
        Component.onCompleted: root.scheduleMeasurements()
      }
    }
  }
}
