import QtQuick
import QtQuick.Controls as QQC
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Commons as Commons
import qs.Ui

Panel {
  id: root
  moduleName: "omarchy.shortcuts"
  ipcTarget: "omarchy.shortcuts"
  manageIpc: false

  property var allShortcuts: []
  property var pinnedList: []
  property string filterText: ""
  property string statusMessage: ""

  readonly property var filteredPinnedList: {
    var query = root.filterText.trim().toLowerCase()
    if (!query) return root.pinnedList
    return root.pinnedList.filter(function(item) {
      return item.key.toLowerCase().indexOf(query) !== -1 ||
             item.action.toLowerCase().indexOf(query) !== -1
    })
  }

  readonly property var filteredAllList: {
    var query = root.filterText.trim().toLowerCase()
    if (!query) return root.allShortcuts
    return root.allShortcuts.filter(function(item) {
      return item.key.toLowerCase().indexOf(query) !== -1 ||
             item.action.toLowerCase().indexOf(query) !== -1
    })
  }

  function isPinned(key, action) {
    for (var i = 0; i < pinnedList.length; i++) {
      if (pinnedList[i].key === key && pinnedList[i].action === action) return true
    }
    return false
  }

  function togglePin(key, action) {
    var current = pinnedList.slice(0)
    var foundIdx = -1
    for (var i = 0; i < current.length; i++) {
      if (current[i].key === key && current[i].action === action) {
        foundIdx = i
        break
      }
    }

    if (foundIdx !== -1) {
      current.splice(foundIdx, 1)
      savePinned(current)
      root.statusMessage = ""
    } else {
      if (current.length >= 10) {
        root.statusMessage = "Limit of 10 shortcuts reached. Unpin one to add another."
        statusClearTimer.restart()
        return
      }
      current.push({ key: key, action: action })
      savePinned(current)
      root.statusMessage = ""
    }
  }

  function savePinned(newList) {
    root.pinnedList = newList.slice(0, 10)
    var jsonStr = JSON.stringify(root.pinnedList, null, 2)
    var cmd = "cat << 'EOF' > ~/.config/omarchy/pinned-shortcuts.json\n" + jsonStr + "\nEOF"
    Quickshell.execDetached(["bash", "-c", cmd])
  }

  function loadKeybindings() {
    loadKeybindingsProc.running = true
  }

  function loadPinned() {
    loadPinnedProc.running = true
  }

  Process {
    id: loadKeybindingsProc
    command: ["omarchy-menu-keybindings", "--print"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        var lines = (text || "").split("\n")
        var list = []
        var seen = {}
        for (var i = 0; i < lines.length; i++) {
          var line = lines[i]
          var idx = line.indexOf("→")
          if (idx !== -1) {
            var k = line.substring(0, idx).trim()
            var a = line.substring(idx + 1).trim()
            if (k && a && !seen[k + "|" + a]) {
              seen[k + "|" + a] = true
              list.push({ key: k, action: a })
            }
          }
        }
        root.allShortcuts = list
      }
    }
  }

  Process {
    id: loadPinnedProc
    command: ["bash", "-c", "cat ~/.config/omarchy/pinned-shortcuts.json 2>/dev/null || echo '[]'"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        try {
          var parsed = JSON.parse(text.trim() || "[]")
          if (Array.isArray(parsed) && parsed.length > 0) {
            root.pinnedList = parsed.slice(0, 10)
          } else {
            var defaults = [
              { key: "SUPER + RETURN", action: "Terminal" },
              { key: "SUPER + SPACE", action: "Omarchy menu" },
              { key: "SUPER SHIFT + S", action: "Screenshot" },
              { key: "SUPER + T", action: "Toggle window floating/tiling" }
            ]
            root.savePinned(defaults)
          }
        } catch (e) {
          root.pinnedList = []
        }
      }
    }
  }

  Timer {
    id: statusClearTimer
    interval: 3500
    running: false
    repeat: false
    onTriggered: root.statusMessage = ""
  }

  Component.onCompleted: {
    loadKeybindings()
    loadPinned()
  }

  onOpenedChanged: {
    if (opened) {
      if (allShortcuts.length === 0) loadKeybindings()
      loadPinned()
      root.statusMessage = ""
    }
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "󰌌"
    active: root.opened
    tooltipText: "Shortcuts (" + root.pinnedList.length + "/10 pinned)"
    onPressed: function(buttonCode) {
      root.toggle()
    }
  }

  KeyboardPanel {
    id: panel
    anchorItem: button
    owner: root
    bar: root.bar
    open: root.opened
    contentWidth: panel.fittedContentWidth(Style.space(480))
    contentHeight: panel.fittedContentHeight(Style.space(560), Style.space(640))

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      blocked: searchInput.activeFocus

      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }

      Column {
        anchors.fill: parent
        spacing: Style.space(10)

        // --- Header ---
        Row {
          width: parent.width
          spacing: Style.space(8)

          Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "󰌌"
            font.family: Style.font.family
            font.pixelSize: Style.font.title
            color: Commons.Color.accent
          }

          Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: Style.space(2)

            Text {
              text: "Keyboard Shortcuts"
              font.family: Style.font.family
              font.pixelSize: Style.font.body
              font.bold: true
              color: Commons.Color.foreground
            }

            Text {
              text: root.pinnedList.length + " of 10 shortcuts pinned for learning"
              font.family: Style.font.family
              font.pixelSize: Style.font.caption
              color: root.pinnedList.length >= 10 ? Commons.Color.urgent : Qt.darker(Commons.Color.foreground, 1.4)
            }
          }
        }

        // --- Status / limit warning ---
        Rectangle {
          visible: root.statusMessage !== ""
          width: parent.width
          height: visible ? Style.space(26) : 0
          radius: Style.cornerRadius
          color: Qt.rgba(Commons.Color.urgent.r, Commons.Color.urgent.g, Commons.Color.urgent.b, 0.15)
          border.color: Commons.Color.urgent
          border.width: 1

          Text {
            anchors.centerIn: parent
            text: root.statusMessage
            font.family: Style.font.family
            font.pixelSize: Style.font.caption
            font.bold: true
            color: Commons.Color.urgent
          }
        }

        // --- Search field ---
        TextField {
          id: searchInput
          width: parent.width
          placeholderText: "Search by key or action... (e.g. terminal, copy, super)"
          onTextChanged: root.filterText = text
        }

        // --- Scrollable list ---
        Flickable {
          id: scrollArea
          width: parent.width
          height: panel.contentHeight - searchInput.height - Style.space(85)
          contentWidth: width
          contentHeight: scrollCol.implicitHeight
          clip: true
          boundsBehavior: Flickable.StopAtBounds
          flickableDirection: Flickable.VerticalFlick
          QQC.ScrollBar.vertical: QQC.ScrollBar { policy: QQC.ScrollBar.AsNeeded }

          Column {
            id: scrollCol
            width: scrollArea.width - Style.space(8)
            spacing: Style.space(10)

            // ===== SECTION: PINNED SHORTCUTS =====
            Column {
              width: parent.width
              spacing: Style.space(6)

              PanelSectionHeader {
                text: "📌 PINNED (" + root.pinnedList.length + "/10) — ACTIVE LEARNING"
              }

              // Tip when none pinned
              Rectangle {
                visible: root.pinnedList.length === 0
                width: parent.width
                height: Style.space(34)
                radius: Style.cornerRadius
                color: Qt.rgba(Commons.Color.foreground.r, Commons.Color.foreground.g, Commons.Color.foreground.b, 0.05)

                Text {
                  anchors.centerIn: parent
                  text: "Click 📌 on any shortcut below to pin it here (max. 10)."
                  font.family: Style.font.family
                  font.pixelSize: Style.font.caption
                  color: Qt.darker(Commons.Color.foreground, 1.4)
                }
              }

              Repeater {
                model: root.filteredPinnedList

                Rectangle {
                  required property var modelData
                  required property int index
                  width: scrollCol.width
                  height: Style.space(32)
                  radius: Style.cornerRadius
                  color: Qt.rgba(Commons.Color.accent.r, Commons.Color.accent.g, Commons.Color.accent.b, 0.12)
                  border.color: Commons.Color.accent
                  border.width: 1

                  Row {
                    anchors.fill: parent
                    anchors.leftMargin: Style.space(8)
                    anchors.rightMargin: Style.space(8)
                    spacing: Style.space(10)

                    // Key badge
                    Rectangle {
                      anchors.verticalCenter: parent.verticalCenter
                      height: Style.space(22)
                      width: pinnedKeyText.implicitWidth + Style.space(12)
                      radius: Math.max(2, Style.cornerRadius * 0.5)
                      color: Commons.Color.popups.background
                      border.color: Commons.Color.accent
                      border.width: 1

                      Text {
                        id: pinnedKeyText
                        anchors.centerIn: parent
                        text: modelData.key
                        font.family: Style.font.family
                        font.pixelSize: Style.font.caption
                        font.bold: true
                        color: Commons.Color.accent
                      }
                    }

                    // Action description
                    Text {
                      anchors.verticalCenter: parent.verticalCenter
                      width: parent.width - pinnedKeyText.implicitWidth - Style.space(70)
                      text: modelData.action
                      font.family: Style.font.family
                      font.pixelSize: Style.font.body
                      color: Commons.Color.foreground
                      elide: Text.ElideRight
                    }

                    // Unpin button
                    MouseArea {
                      anchors.verticalCenter: parent.verticalCenter
                      width: Style.space(28)
                      height: Style.space(28)
                      cursorShape: Qt.PointingHandCursor
                      hoverEnabled: true

                      Text {
                        anchors.centerIn: parent
                        text: "📌"
                        font.pixelSize: Style.font.body
                        opacity: parent.containsMouse ? 0.6 : 1.0
                      }

                      onClicked: root.togglePin(modelData.key, modelData.action)
                    }
                  }
                }
              }
            }

            PanelSeparator {}

            // ===== SECTION: ALL SHORTCUTS =====
            Column {
              width: parent.width
              spacing: Style.space(6)

              PanelSectionHeader {
                text: "ALL SHORTCUTS" + (root.filterText ? " (" + root.filteredAllList.length + " found)" : "")
              }

              Repeater {
                model: root.filteredAllList

                Rectangle {
                  id: allRow
                  required property var modelData
                  required property int index
                  readonly property bool itemPinned: root.isPinned(modelData.key, modelData.action)

                  width: scrollCol.width
                  height: Style.space(30)
                  radius: Style.cornerRadius
                  color: rowMouse.containsMouse
                    ? Qt.rgba(Commons.Color.foreground.r, Commons.Color.foreground.g, Commons.Color.foreground.b, 0.08)
                    : "transparent"

                  MouseArea {
                    id: rowMouse
                    anchors.fill: parent
                    hoverEnabled: true
                  }

                  Row {
                    anchors.fill: parent
                    anchors.leftMargin: Style.space(6)
                    anchors.rightMargin: Style.space(6)
                    spacing: Style.space(10)

                    // Key badge
                    Rectangle {
                      anchors.verticalCenter: parent.verticalCenter
                      height: Style.space(20)
                      width: allKeyText.implicitWidth + Style.space(10)
                      radius: Math.max(2, Style.cornerRadius * 0.5)
                      color: Qt.rgba(Commons.Color.foreground.r, Commons.Color.foreground.g, Commons.Color.foreground.b, 0.08)
                      border.color: itemPinned ? Commons.Color.accent : Commons.Color.popups.border
                      border.width: 1

                      Text {
                        id: allKeyText
                        anchors.centerIn: parent
                        text: modelData.key
                        font.family: Style.font.family
                        font.pixelSize: Style.font.caption
                        font.bold: true
                        color: itemPinned ? Commons.Color.accent : Commons.Color.foreground
                      }
                    }

                    // Action description
                    Text {
                      anchors.verticalCenter: parent.verticalCenter
                      width: parent.width - allKeyText.implicitWidth - Style.space(70)
                      text: modelData.action
                      font.family: Style.font.family
                      font.pixelSize: Style.font.body
                      color: Commons.Color.foreground
                      elide: Text.ElideRight
                    }

                    // Pin / Unpin Button
                    MouseArea {
                      anchors.verticalCenter: parent.verticalCenter
                      width: Style.space(28)
                      height: Style.space(28)
                      cursorShape: Qt.PointingHandCursor
                      hoverEnabled: true

                      Text {
                        anchors.centerIn: parent
                        text: itemPinned ? "📌" : "󰤱"
                        font.family: Style.font.family
                        font.pixelSize: Style.font.body
                        color: itemPinned ? Commons.Color.accent : (parent.containsMouse ? Commons.Color.foreground : Qt.darker(Commons.Color.foreground, 1.8))
                      }

                      onClicked: root.togglePin(modelData.key, modelData.action)
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
