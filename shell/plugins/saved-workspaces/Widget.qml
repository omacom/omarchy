import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import qs.Commons
import qs.Commons as Commons
import qs.Ui

Panel {
  id: root
  moduleName: "omarchy.saved-workspaces"
  manageIpc: false


  property var saved: ({ items: [], active: ({}) })
  readonly property var entries: saved.items || []
  readonly property int currentWorkspace: Hyprland.focusedMonitor && Hyprland.focusedMonitor.activeWorkspace ? Number(Hyprland.focusedMonitor.activeWorkspace.id) : -1
  readonly property string activeId: {
    var entry = saved.opened ? saved.opened[String(currentWorkspace)] : null
    if (!entry) return saved.active && Number(saved.active.workspace) === currentWorkspace ? String(saved.active.id || "") : ""
    if (entry.session !== Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE")) return ""
    var addresses = entry.windows || []
    var windows = Hyprland.toplevels.values
    for (var i = 0; i < windows.length; i++) {
      var window = windows[i]
      var address = String(window.address || "")
      if (address.indexOf("0x") !== 0) address = "0x" + address
      if (window.workspace && Number(window.workspace.id) === currentWorkspace && addresses.indexOf(address) >= 0) return entry.id
    }
    return addresses.length === 0 ? entry.id : ""
  }
  property bool editingName: false
  property string renameId: ""
  property string deletingId: ""
  property int selectedIndex: -1
  property string action: ""
  property string feedback: ""
  property bool failed: false
  readonly property bool busy: operation.running || actionReply.pending
  readonly property color foreground: Commons.Color.popups.text

  implicitWidth: icon.implicitWidth
  implicitHeight: icon.implicitHeight

  function open() {
    stateFile.reload()
    feedback = ""
    deletingId = ""
    editingName = false
    renameId = ""
    selectedIndex = -1
    root.controller.show()
  }

  function close() {
    root.controller.hide()
    editingName = false
    deletingId = ""
  }

  function beginSave() {
    if (busy) return
    renameId = ""
    editingName = true
    feedback = ""
    Qt.callLater(function() {
      if (!root.editingName || !panel.loadedContent) return
      panel.loadedContent.nameEditor.text = ""
      panel.loadedContent.nameEditor.forceActiveFocus()
      panel.loadedContent.revealEditor()
    })
  }

  function beginRename(entry) {
    if (busy) return
    editingName = true
    renameId = entry.id
    feedback = ""
    Qt.callLater(function() {
      if (!root.editingName || !panel.loadedContent) return
      panel.loadedContent.nameEditor.text = entry.name
      panel.loadedContent.nameEditor.forceActiveFocus()
      panel.loadedContent.nameEditor.selectAll()
      panel.loadedContent.revealEditor()
    })
  }

  function perform(command, value, extra) {
    if (busy) return
    action = command
    failed = false
    feedback = ""
    operation.command = ["omarchy-saved-workspaces", command, String(value)]
    if (extra !== undefined) operation.command = operation.command.concat([String(extra)])
    // Release the panel's keyboard grab before newly opened apps take focus.
    if (command === "restore") root.close()
    operation.didStart = false
    actionReply.begin()
    operation.running = true
  }

  function saveName() {
    if (!panel.loadedContent) return
    if (renameId !== "") perform("rename", renameId, panel.loadedContent.nameEditor.text)
    else perform("save", panel.loadedContent.nameEditor.text)
  }

  function moveSelection(delta) {
    if (!entries.length) return
    deletingId = ""
    selectedIndex = selectedIndex < 0 ? (delta > 0 ? 0 : entries.length - 1) : (selectedIndex + delta + entries.length) % entries.length
    if (panel.loadedContent) panel.loadedContent.revealSelection(selectedIndex)
  }

  function selectedEntry() {
    return selectedIndex >= 0 && selectedIndex < entries.length ? entries[selectedIndex] : null
  }

  function textAction(text, modifiers) {
    if (busy || editingName || (modifiers & (Qt.AltModifier | Qt.MetaModifier))) return
    var key = text.toLowerCase()
    if (deletingId !== "") {
      if (key === "y") perform("delete", deletingId)
      else if (key === "n") deletingId = ""
      return
    }
    var entry = selectedEntry()
    if (key === "n") beginSave()
    else if (entry && key === "r") beginRename(entry)
    else if (entry && key === "u") perform("update", entry.id)
  }

  FileView {
    id: stateFile
    path: (Quickshell.env("XDG_STATE_HOME") || (Quickshell.env("HOME") + "/.local/state")) + "/omarchy/saved-workspaces/workspaces.json"
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: {
      try {
        var next = JSON.parse(text())
        if (next.version === 1 && Array.isArray(next.items) && next.items.length <= 100) root.saved = next
      } catch (error) { }
      root.selectedIndex = Math.max(-1, Math.min(root.selectedIndex, root.entries.length - 1))
    }
  }

  Process {
    id: operation
    property bool didStart: false
    onStarted: didStart = true
    onRunningChanged: {
      // FailedToStart emits runningChanged without either completion signal.
      if (!running && !didStart && actionReply.pending) {
        actionReply.receive("")
        actionReply.exited(-1)
      }
    }
    stdout: StdioCollector {
      onStreamFinished: actionReply.receive(text)
    }
    onExited: function(exitCode) { actionReply.exited(exitCode) }
  }

  ActionReply {
    id: actionReply
    onCompleted: function(result) {
      stateFile.reload()
      if (!result.ok) {
        root.failed = true
        root.feedback = String(result.error || Commons.I18n.t("scenes.failure"))
        if (root.action === "restore") root.controller.show()
        else if (panel.loadedContent) Qt.callLater(function() {
          if (panel.loadedContent) panel.loadedContent.revealFeedback()
        })
        return
      }
      if (root.action === "restore") {
        root.close()
        if (result.otherWorkspace > 0) Util.execArgv(["omarchy-notification-send", Commons.I18n.t("scenes.title"), Commons.I18n.t("scenes.otherWindows").arg(Commons.I18n.formatNumber(result.otherWorkspace))])
        return
      }
      root.feedback = root.action === "delete" ? Commons.I18n.t("scenes.deleted") : root.action === "update" ? Commons.I18n.t("scenes.updated") : root.action === "rename" ? Commons.I18n.t("scenes.renamed") : Commons.I18n.t("scenes.saved")
      root.editingName = false
      root.renameId = ""
      root.deletingId = ""
      if (panel.loadedContent) {
        panel.loadedContent.nameEditor.text = ""
        panel.loadedContent.forceActiveFocus()
      }
    }
  }

  BarIconButton {
    id: icon
    anchors.fill: parent
    bar: root.bar
    text: "\uf0db"
    tooltipText: Commons.I18n.t("scenes.title")
    active: root.opened || root.activeId !== ""
    slotSize: Style.bar.statusSlot
    onPressed: function(button) {
      if (button === Qt.LeftButton) root.opened ? root.close() : root.open()
    }
  }

  component LinkButton: Button {
    color: "transparent"
    borderSpec: Border.none()
    foreground: hot || active ? Commons.Color.accent : root.foreground
  }

  component Label: Text {
    textFormat: Text.PlainText
    color: root.foreground
    font.family: Style.font.family
    font.pixelSize: Style.font.body
  }

  KeyboardPanel {
    id: panel
    anchorItem: icon
    owner: root
    bar: root.bar
    open: root.opened
    centerOnBar: false
    focusTarget: panel.loadedContent
    contentWidth: panel.fittedContentWidth(Style.space(280))
    contentHeight: panel.fittedContentHeight(panel.loadedContentHeight, Style.space(460))

    content: PanelKeyCatcher {
      id: catcher
      property alias nameEditor: nameEditor
      implicitHeight: column.implicitHeight
      anchors.fill: parent
      blocked: root.editingName
      onMoveRequested: function(dx, dy) { if (dy) root.moveSelection(dy) }
      onActivateRequested: if (!root.busy && root.deletingId === "" && root.selectedIndex >= 0 && root.entries.length) root.perform("restore", root.entries[root.selectedIndex].id)
      onCloseRequested: root.deletingId !== "" ? root.deletingId = "" : root.close()
      onDeleteRequested: {
        var entry = root.selectedEntry()
        if (!root.busy && entry) root.deletingId = entry.id
      }
      onTextKey: function(text, modifiers) { root.textAction(text, modifiers) }
      onTabRequested: function(direction) { root.switchPanel(direction) }
      function revealRegion(top, height) {
        var bottom = top + height
        var maxY = Math.max(0, scroll.contentHeight - scroll.height)
        if (top < scroll.contentY) scroll.contentY = Math.max(0, Math.min(maxY, top))
        else if (bottom > scroll.contentY + scroll.height) scroll.contentY = Math.max(0, Math.min(maxY, Math.min(top, bottom - scroll.height)))
      }

      function revealSelection(index) {
        var item = savedRows.itemAt(index)
        if (!item) return
        listColumn.forceLayout()
        column.forceLayout()
        revealRegion(item.y + listColumn.y, item.height)
      }

      function revealEditor() {
        if (!root.editingName) return
        listColumn.forceLayout()
        editorActions.forceLayout()
        editorSection.forceLayout()
        column.forceLayout()
        revealRegion(editorSection.y, editorSection.height)
      }

      function revealFeedback() {
        if (!feedbackLabel.visible) return
        listColumn.forceLayout()
        editorActions.forceLayout()
        editorSection.forceLayout()
        column.forceLayout()
        revealRegion(feedbackLabel.y, feedbackLabel.height)
      }

      Flickable {
        id: scroll
        anchors.fill: parent
        clip: true
        contentWidth: width
        contentHeight: column.implicitHeight
        boundsBehavior: Flickable.StopAtBounds
        interactive: contentHeight > height
        function clampContentY() {
          var maxY = Math.max(0, contentHeight - height)
          if (contentY > maxY) contentY = maxY
        }
        onContentHeightChanged: clampContentY()
        onHeightChanged: clampContentY()

        Column {
          id: column
          width: scroll.width
          spacing: Style.space(8)

          Row {
            width: parent.width
            spacing: Style.space(8)
            Label {
              id: heading
              height: saveButton.height
              verticalAlignment: Text.AlignVCenter
              text: Commons.I18n.t("scenes.title")
              font.bold: true
              font.pixelSize: Style.font.caption
              opacity: .75
              HoverHandler { id: headingHover }
              PanelToolTip {
                id: headingTip
                visible: headingHover.hovered
                text: Commons.I18n.t("scenes.explanation")
                background: BorderSurface {
                  color: headingTip.panelBackground
                  borderSpec: headingTip.panelBorderSpec
                  radius: 0
                }
              }
            }
            Item {
              width: Math.max(0, parent.width - heading.width - saveButton.width - 2 * parent.spacing)
              height: 1
            }
            LinkButton {
              id: saveButton
              text: Commons.I18n.t("scenes.save")
              iconText: "+"
              fontSize: Style.font.caption
              height: Style.space(28)
              enabled: !root.busy
              tooltipText: Commons.I18n.t("scenes.save.current") + " (N)"
              onClicked: root.beginSave()
            }
          }

          Label {
            visible: root.entries.length === 0
            width: parent.width
            text: Commons.I18n.t("scenes.empty")
            opacity: .6
            wrapMode: Text.Wrap
          }

          Column {
            id: listColumn
            width: parent.width
            spacing: Style.space(2)

            Repeater {
              id: savedRows
              model: root.entries
              delegate: Column {
                id: savedRow
                required property var modelData
                required property int index
                readonly property bool isActive: root.activeId === modelData.id
                width: listColumn.width
                spacing: Style.space(4)

                Item {
                  width: parent.width
                  height: Style.space(34)
                  HoverHandler { id: rowHover }
                  readonly property bool showActions: rowHover.hovered || root.selectedIndex === savedRow.index
                  LinkButton {
                    id: openButton
                    width: parent.width
                    height: parent.height
                    leftAlign: true
                    active: savedRow.isActive
                    enabled: !root.busy
                    hasCursor: root.selectedIndex === savedRow.index && root.opened
                    text: ""
                    onClicked: root.perform("restore", savedRow.modelData.id)
                    onHovered: function(hovered) { root.selectedIndex = hovered ? savedRow.index : -1 }
                    Label {
                      anchors.left: parent.left
                      anchors.leftMargin: Style.space(8)
                      anchors.right: parent.right
                      anchors.rightMargin: actions.visible ? actions.width + Style.space(12) : Style.space(8)
                      anchors.verticalCenter: parent.verticalCenter
                      color: openButton.hot || savedRow.isActive ? Commons.Color.accent : root.foreground
                      text: savedRow.modelData.name
                      elide: Text.ElideRight
                    }
                  }
                  Row {
                    id: actions
                    anchors.right: parent.right
                    anchors.rightMargin: Style.space(4)
                    anchors.verticalCenter: parent.verticalCenter
                    visible: parent.showActions
                    spacing: Style.space(2)
                    LinkButton {
                      width: Style.space(26); height: Style.space(28)
                      iconText: "\uf040"
                      horizontalPadding: 0
                      tooltipText: Commons.I18n.t("scenes.rename") + " (R)"
                      enabled: !root.busy
                      onClicked: root.beginRename(savedRow.modelData)
                    }
                    LinkButton {
                      width: Style.space(26); height: Style.space(28)
                      iconText: "\uf021"
                      horizontalPadding: 0
                      tooltipText: Commons.I18n.t("scenes.update.hint") + " (U)"
                      enabled: !root.busy
                      onClicked: root.perform("update", savedRow.modelData.id)
                    }
                    LinkButton {
                      width: Style.space(26); height: Style.space(28)
                      iconText: "\uf1f8"
                      horizontalPadding: 0
                      tooltipText: Commons.I18n.t("scenes.delete") + " (Delete)"
                      enabled: !root.busy
                      onClicked: root.deletingId = savedRow.modelData.id
                    }
                  }
                }

                Row {
                  visible: root.deletingId === savedRow.modelData.id
                  x: Style.space(8)
                  width: parent.width - x
                  spacing: Style.space(8)
                  Label {
                    text: Commons.I18n.t("scenes.confirm.delete")
                    color: "#E5C736"
                    font.pixelSize: Style.font.caption
                    height: Style.space(28)
                    verticalAlignment: Text.AlignVCenter
                  }
                  LinkButton { text: Commons.I18n.t("scenes.yes"); fontSize: Style.font.caption; height: Style.space(28); enabled: !root.busy; tooltipText: "Y"; onClicked: root.perform("delete", savedRow.modelData.id) }
                  LinkButton { text: Commons.I18n.t("scenes.no"); fontSize: Style.font.caption; height: Style.space(28); tooltipText: "N / Esc"; onClicked: root.deletingId = "" }
                }
              }
            }
          }

          PanelSeparator { visible: root.editingName }

          Column {
            id: editorSection
            visible: root.editingName
            width: parent.width
            spacing: Style.space(6)
            TextField {
              id: nameEditor
              width: parent.width
              maximumLength: 80
              placeholderText: Commons.I18n.t("scenes.name")
              enabled: !root.busy
              onAccepted: root.saveName()
              Keys.onEscapePressed: function(event) {
                root.editingName = false
                catcher.forceActiveFocus()
                event.accepted = true
              }
            }
            Row {
              id: editorActions
              spacing: Style.space(6)
              Button { text: (root.renameId !== "" ? Commons.I18n.t("scenes.rename") : Commons.I18n.t("scenes.save")); enabled: !root.busy && nameEditor.text.trim() !== ""; onClicked: root.saveName() }
              Button { text: Commons.I18n.t("scenes.cancel"); enabled: !root.busy; onClicked: { root.editingName = false; catcher.forceActiveFocus() } }
            }
          }

          Label {
            id: feedbackLabel
            visible: root.busy || root.feedback !== ""
            x: Style.space(8)
            width: parent.width - x
            wrapMode: Text.Wrap
            font.pixelSize: Style.font.caption
            opacity: root.failed ? 1 : .6
            text: root.busy ? (root.action === "restore" ? Commons.I18n.t("scenes.restoring") : Commons.I18n.t("scenes.saving")) : root.feedback
          }
        }
      }
    }
  }
}
