import QtQuick
import QtQuick.Controls as QQC
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Commons as Commons
import qs.Ui

Panel {
  id: root
  moduleName: "omarchy.links"
  ipcTarget: "omarchy.links"
  manageIpc: false

  property var linksList: []
  property string filterText: ""
  property string statusMessage: ""
  property string copiedId: ""
  property bool showAddForm: false

  readonly property var pinnedLinks: {
    return root.linksList.filter(function(item) { return item.pinned === true })
  }

  readonly property int pinnedCount: pinnedLinks.length

  readonly property var filteredPinnedList: {
    var query = root.filterText.trim().toLowerCase()
    if (!query) return root.pinnedLinks
    return root.pinnedLinks.filter(function(item) {
      var d = (item.desc || "").toLowerCase()
      var u = (item.url || "").toLowerCase()
      return d.indexOf(query) !== -1 || u.indexOf(query) !== -1
    })
  }

  readonly property var filteredAllList: {
    var query = root.filterText.trim().toLowerCase()
    if (!query) return root.linksList
    return root.linksList.filter(function(item) {
      var d = (item.desc || "").toLowerCase()
      var u = (item.url || "").toLowerCase()
      return d.indexOf(query) !== -1 || u.indexOf(query) !== -1
    })
  }

  function addLink(url, desc) {
    var cleanUrl = (url || "").trim()
    var cleanDesc = (desc || "").trim()
    if (!cleanUrl) {
      root.statusMessage = "URL cannot be empty"
      statusTimer.restart()
      return
    }
    if (!cleanUrl.match(/^https?:\/\//i)) {
      cleanUrl = "https://" + cleanUrl
    }
    if (!cleanDesc) {
      cleanDesc = cleanUrl.replace(/^https?:\/\/(www\.)?/, "").split("/")[0]
    }

    var newItem = {
      id: String(Date.now()),
      url: cleanUrl,
      desc: cleanDesc,
      created_at: new Date().toISOString(),
      pinned: false
    }

    var updated = [newItem].concat(root.linksList)
    saveLinks(updated)
    urlInput.text = ""
    descInput.text = ""
    root.showAddForm = false
    root.statusMessage = "Link saved"
    statusTimer.restart()
  }

  function deleteLink(id) {
    var updated = root.linksList.filter(function(item) { return item.id !== id })
    saveLinks(updated)
    root.statusMessage = "Link deleted"
    statusTimer.restart()
  }

  function togglePin(id) {
    var isCurrentlyPinned = false
    for (var i = 0; i < root.linksList.length; i++) {
      if (root.linksList[i].id === id && root.linksList[i].pinned) {
        isCurrentlyPinned = true
        break
      }
    }

    if (!isCurrentlyPinned && root.pinnedCount >= 5) {
      root.statusMessage = "Limit of 5 pinned links reached. Unpin one first."
      statusTimer.restart()
      return
    }

    var updated = []
    for (var j = 0; j < root.linksList.length; j++) {
      var it = Object.assign({}, root.linksList[j])
      if (it.id === id) {
        it.pinned = !it.pinned
      }
      updated.push(it)
    }

    saveLinks(updated)
    root.statusMessage = ""
  }

  function copyLink(id, url) {
    var cmd = "printf '%s' " + JSON.stringify(url) + " | wl-copy"
    Quickshell.execDetached(["bash", "-c", cmd])
    root.copiedId = id
    copyTimer.restart()
  }

  function openLink(url) {
    Quickshell.execDetached(["xdg-open", url])
  }

  function pasteClipboard() {
    pasteProc.running = true
  }

  function saveLinks(newList) {
    root.linksList = newList
    var jsonStr = JSON.stringify(newList, null, 2)
    var cmd = "cat << 'EOF' > ~/.config/omarchy/saved-links.json\n" + jsonStr + "\nEOF"
    Quickshell.execDetached(["bash", "-c", cmd])
  }

  function loadLinks() {
    loadLinksProc.running = true
  }

  Process {
    id: pasteProc
    command: ["wl-paste"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        var clip = (text || "").trim()
        if (clip.match(/^https?:\/\//i)) {
          urlInput.text = clip
        }
      }
    }
  }

  Process {
    id: loadLinksProc
    command: ["bash", "-c", "cat ~/.config/omarchy/saved-links.json 2>/dev/null || echo '[]'"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        try {
          var parsed = JSON.parse(text.trim() || "[]")
          if (Array.isArray(parsed) && parsed.length > 0) {
            root.linksList = parsed
          } else {
            var defaults = [
              {
                id: "1",
                url: "https://omarchy.org",
                desc: "Omarchy Documentation",
                created_at: new Date().toISOString(),
                pinned: true
              },
              {
                id: "2",
                url: "https://wiki.hyprland.org",
                desc: "Official Hyprland Wiki",
                created_at: new Date().toISOString(),
                pinned: true
              }
            ]
            root.saveLinks(defaults)
          }
        } catch (e) {
          root.linksList = []
        }
      }
    }
  }

  Timer {
    id: copyTimer
    interval: 2000
    running: false
    repeat: false
    onTriggered: root.copiedId = ""
  }

  Timer {
    id: statusTimer
    interval: 3000
    running: false
    repeat: false
    onTriggered: root.statusMessage = ""
  }

  Component.onCompleted: {
    loadLinks()
  }

  onOpenedChanged: {
    if (opened) {
      loadLinks()
      root.statusMessage = ""
    }
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "󰌹"
    active: root.opened
    tooltipText: "Links (" + root.linksList.length + " total · " + root.pinnedCount + "/5 pinned)"
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
      blocked: searchInput.activeFocus || urlInput.activeFocus || descInput.activeFocus

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
            text: "󰌹"
            font.family: Style.font.family
            font.pixelSize: Style.font.title
            color: Commons.Color.accent
          }

          Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: Style.space(2)
            width: parent.width - Style.space(140)

            Text {
              text: "Quick Links"
              font.family: Style.font.family
              font.pixelSize: Style.font.body
              font.bold: true
              color: Commons.Color.foreground
            }

            Text {
              text: root.linksList.length + " links · " + root.pinnedCount + "/5 pinned"
              font.family: Style.font.family
              font.pixelSize: Style.font.caption
              color: root.pinnedCount >= 5 ? Commons.Color.urgent : Qt.darker(Commons.Color.foreground, 1.4)
            }
          }

          // New link toggle button
          Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            height: Style.space(28)
            width: Style.space(100)
            radius: Style.cornerRadius
            color: root.showAddForm
              ? Commons.Color.accent
              : Qt.rgba(Commons.Color.accent.r, Commons.Color.accent.g, Commons.Color.accent.b, 0.15)
            border.color: Commons.Color.accent
            border.width: 1

            MouseArea {
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor
              onClicked: {
                root.showAddForm = !root.showAddForm
                if (root.showAddForm) {
                  root.pasteClipboard()
                  urlInput.forceActiveFocus()
                }
              }
            }

            Row {
              anchors.centerIn: parent
              spacing: Style.space(4)

              Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.showAddForm ? "󰅃" : "󰐕"
                font.family: Style.font.family
                font.pixelSize: Style.font.body
                color: root.showAddForm ? Commons.Color.popups.background : Commons.Color.accent
              }

              Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.showAddForm ? "Close" : "New"
                font.family: Style.font.family
                font.pixelSize: Style.font.caption
                font.bold: true
                color: root.showAddForm ? Commons.Color.popups.background : Commons.Color.accent
              }
            }
          }
        }

        // --- Status message ---
        Rectangle {
          visible: root.statusMessage !== ""
          width: parent.width
          height: visible ? Style.space(26) : 0
          radius: Style.cornerRadius
          color: Qt.rgba(Commons.Color.accent.r, Commons.Color.accent.g, Commons.Color.accent.b, 0.15)
          border.color: Commons.Color.accent
          border.width: 1

          Text {
            anchors.centerIn: parent
            text: root.statusMessage
            font.family: Style.font.family
            font.pixelSize: Style.font.caption
            font.bold: true
            color: Commons.Color.foreground
          }
        }

        // --- Add Link Form ---
        Rectangle {
          visible: root.showAddForm
          width: parent.width
          height: visible ? addFormCol.implicitHeight + Style.space(16) : 0
          radius: Style.cornerRadius
          color: Qt.rgba(Commons.Color.foreground.r, Commons.Color.foreground.g, Commons.Color.foreground.b, 0.04)
          border.color: Qt.rgba(Commons.Color.accent.r, Commons.Color.accent.g, Commons.Color.accent.b, 0.3)
          border.width: 1

          Column {
            id: addFormCol
            anchors.fill: parent
            anchors.margins: Style.space(8)
            spacing: Style.space(8)

            TextField {
              id: urlInput
              width: parent.width
              placeholderText: "URL (e.g. https://github.com/...)"
            }

            TextField {
              id: descInput
              width: parent.width
              placeholderText: "Short title or description..."
              onAccepted: root.addLink(urlInput.text, descInput.text)
            }

            Row {
              width: parent.width
              spacing: Style.space(8)

              Rectangle {
                height: Style.space(28)
                width: Style.space(100)
                radius: Style.cornerRadius
                color: Commons.Color.accent

                MouseArea {
                  anchors.fill: parent
                  cursorShape: Qt.PointingHandCursor
                  onClicked: root.addLink(urlInput.text, descInput.text)
                }

                Text {
                  anchors.centerIn: parent
                  text: "󰐕 Save"
                  font.family: Style.font.family
                  font.pixelSize: Style.font.caption
                  font.bold: true
                  color: Commons.Color.popups.background
                }
              }

              Rectangle {
                height: Style.space(28)
                width: Style.space(120)
                radius: Style.cornerRadius
                color: Qt.rgba(Commons.Color.foreground.r, Commons.Color.foreground.g, Commons.Color.foreground.b, 0.08)

                MouseArea {
                  anchors.fill: parent
                  cursorShape: Qt.PointingHandCursor
                  onClicked: root.pasteClipboard()
                }

                Text {
                  anchors.centerIn: parent
                  text: "󰅌 Paste clipboard"
                  font.family: Style.font.family
                  font.pixelSize: Style.font.caption
                  color: Commons.Color.foreground
                }
              }
            }
          }
        }

        // --- Search Field ---
        TextField {
          id: searchInput
          width: parent.width
          placeholderText: "Search links by title or URL..."
          onTextChanged: root.filterText = text
        }

        // --- Scrollable List ---
        Flickable {
          id: scrollArea
          width: parent.width
          height: panel.contentHeight - (root.showAddForm ? addFormCol.implicitHeight + Style.space(16) : 0) - searchInput.height - Style.space(85)
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

            // ===== SECTION: PINNED LINKS =====
            Column {
              width: parent.width
              spacing: Style.space(6)

              PanelSectionHeader {
                text: "📌 PINNED (" + root.pinnedCount + "/5) — FAVORITES"
              }

              Rectangle {
                visible: root.pinnedCount === 0
                width: parent.width
                height: Style.space(34)
                radius: Style.cornerRadius
                color: Qt.rgba(Commons.Color.foreground.r, Commons.Color.foreground.g, Commons.Color.foreground.b, 0.04)

                Text {
                  anchors.centerIn: parent
                  text: "Click 📌 on any link below to pin up to 5 favorites."
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
                  readonly property bool wasCopied: root.copiedId === modelData.id

                  width: scrollCol.width
                  height: Style.space(52)
                  radius: Style.cornerRadius
                  color: Qt.rgba(Commons.Color.accent.r, Commons.Color.accent.g, Commons.Color.accent.b, 0.10)
                  border.color: wasCopied ? Commons.Color.accent : Qt.rgba(Commons.Color.accent.r, Commons.Color.accent.g, Commons.Color.accent.b, 0.4)
                  border.width: 1

                  Row {
                    anchors.fill: parent
                    anchors.leftMargin: Style.space(10)
                    anchors.rightMargin: Style.space(10)
                    spacing: Style.space(10)

                    Column {
                      anchors.verticalCenter: parent.verticalCenter
                      width: parent.width - Style.space(130)
                      spacing: Style.space(2)

                      Text {
                        width: parent.width
                        text: modelData.desc || modelData.url
                        font.family: Style.font.family
                        font.pixelSize: Style.font.body
                        font.bold: true
                        color: Commons.Color.foreground
                        elide: Text.ElideRight
                      }

                      Text {
                        width: parent.width
                        text: modelData.url
                        font.family: Style.font.family
                        font.pixelSize: Style.font.caption
                        color: Commons.Color.accent
                        elide: Text.ElideRight
                      }
                    }

                    // Action buttons
                    Row {
                      anchors.verticalCenter: parent.verticalCenter
                      spacing: Style.space(5)

                      // Copy
                      Rectangle {
                        width: Style.space(26)
                        height: Style.space(26)
                        radius: Math.max(2, Style.cornerRadius * 0.5)
                        color: wasCopied
                          ? Commons.Color.accent
                          : (pCopyMouse.containsMouse
                              ? Qt.rgba(Commons.Color.accent.r, Commons.Color.accent.g, Commons.Color.accent.b, 0.25)
                              : Qt.rgba(Commons.Color.foreground.r, Commons.Color.foreground.g, Commons.Color.foreground.b, 0.08))
                        border.color: wasCopied ? Commons.Color.accent : Commons.Color.popups.border
                        border.width: 1

                        MouseArea {
                          id: pCopyMouse
                          anchors.fill: parent
                          cursorShape: Qt.PointingHandCursor
                          hoverEnabled: true
                          onClicked: root.copyLink(modelData.id, modelData.url)
                        }

                        Text {
                          anchors.centerIn: parent
                          text: wasCopied ? "󰄬" : "󰆏"
                          font.family: Style.font.family
                          font.pixelSize: Style.font.caption
                          color: wasCopied ? Commons.Color.popups.background : Commons.Color.foreground
                        }
                      }

                      // Open in browser
                      Rectangle {
                        width: Style.space(26)
                        height: Style.space(26)
                        radius: Math.max(2, Style.cornerRadius * 0.5)
                        color: pOpenMouse.containsMouse
                          ? Qt.rgba(Commons.Color.foreground.r, Commons.Color.foreground.g, Commons.Color.foreground.b, 0.15)
                          : Qt.rgba(Commons.Color.foreground.r, Commons.Color.foreground.g, Commons.Color.foreground.b, 0.08)
                        border.color: Commons.Color.popups.border
                        border.width: 1

                        MouseArea {
                          id: pOpenMouse
                          anchors.fill: parent
                          cursorShape: Qt.PointingHandCursor
                          hoverEnabled: true
                          onClicked: root.openLink(modelData.url)
                        }

                        Text {
                          anchors.centerIn: parent
                          text: "󰖟"
                          font.family: Style.font.family
                          font.pixelSize: Style.font.caption
                          color: Commons.Color.foreground
                        }
                      }

                      // Pin / Unpin
                      Rectangle {
                        width: Style.space(26)
                        height: Style.space(26)
                        radius: Math.max(2, Style.cornerRadius * 0.5)
                        color: Qt.rgba(Commons.Color.accent.r, Commons.Color.accent.g, Commons.Color.accent.b, 0.2)
                        border.color: Commons.Color.accent
                        border.width: 1

                        MouseArea {
                          id: pPinMouse
                          anchors.fill: parent
                          cursorShape: Qt.PointingHandCursor
                          hoverEnabled: true
                          onClicked: root.togglePin(modelData.id)
                        }

                        Text {
                          anchors.centerIn: parent
                          text: "📌"
                          font.pixelSize: Style.font.caption
                        }
                      }

                      // Delete
                      Rectangle {
                        width: Style.space(26)
                        height: Style.space(26)
                        radius: Math.max(2, Style.cornerRadius * 0.5)
                        color: pDelMouse.containsMouse
                          ? Qt.rgba(Commons.Color.urgent.r, Commons.Color.urgent.g, Commons.Color.urgent.b, 0.25)
                          : "transparent"

                        MouseArea {
                          id: pDelMouse
                          anchors.fill: parent
                          cursorShape: Qt.PointingHandCursor
                          hoverEnabled: true
                          onClicked: root.deleteLink(modelData.id)
                        }

                        Text {
                          anchors.centerIn: parent
                          text: "󰆴"
                          font.family: Style.font.family
                          font.pixelSize: Style.font.caption
                          color: pDelMouse.containsMouse ? Commons.Color.urgent : Qt.darker(Commons.Color.foreground, 1.8)
                        }
                      }
                    }
                  }
                }
              }
            }

            PanelSeparator {}

            // ===== SECTION: ALL LINKS =====
            Column {
              width: parent.width
              spacing: Style.space(6)

              PanelSectionHeader {
                text: "ALL LINKS" + (root.filterText ? " (" + root.filteredAllList.length + " found)" : "")
              }

              Repeater {
                model: root.filteredAllList

                Rectangle {
                  required property var modelData
                  required property int index
                  readonly property bool wasCopied: root.copiedId === modelData.id
                  readonly property bool isPinned: modelData.pinned === true

                  width: scrollCol.width
                  height: Style.space(52)
                  radius: Style.cornerRadius
                  color: cardMouse.containsMouse
                    ? Qt.rgba(Commons.Color.foreground.r, Commons.Color.foreground.g, Commons.Color.foreground.b, 0.08)
                    : Qt.rgba(Commons.Color.foreground.r, Commons.Color.foreground.g, Commons.Color.foreground.b, 0.03)
                  border.color: wasCopied ? Commons.Color.accent : Commons.Color.popups.border
                  border.width: 1

                  MouseArea {
                    id: cardMouse
                    anchors.fill: parent
                    hoverEnabled: true
                  }

                  Row {
                    anchors.fill: parent
                    anchors.leftMargin: Style.space(10)
                    anchors.rightMargin: Style.space(10)
                    spacing: Style.space(10)

                    Column {
                      anchors.verticalCenter: parent.verticalCenter
                      width: parent.width - Style.space(130)
                      spacing: Style.space(2)

                      Text {
                        width: parent.width
                        text: modelData.desc || modelData.url
                        font.family: Style.font.family
                        font.pixelSize: Style.font.body
                        font.bold: true
                        color: Commons.Color.foreground
                        elide: Text.ElideRight
                      }

                      Text {
                        width: parent.width
                        text: modelData.url
                        font.family: Style.font.family
                        font.pixelSize: Style.font.caption
                        color: Qt.darker(Commons.Color.foreground, 1.5)
                        elide: Text.ElideRight
                      }
                    }

                    // Action buttons
                    Row {
                      anchors.verticalCenter: parent.verticalCenter
                      spacing: Style.space(5)

                      // Copy
                      Rectangle {
                        width: Style.space(26)
                        height: Style.space(26)
                        radius: Math.max(2, Style.cornerRadius * 0.5)
                        color: wasCopied
                          ? Commons.Color.accent
                          : (copyMouse.containsMouse
                              ? Qt.rgba(Commons.Color.accent.r, Commons.Color.accent.g, Commons.Color.accent.b, 0.2)
                              : Qt.rgba(Commons.Color.foreground.r, Commons.Color.foreground.g, Commons.Color.foreground.b, 0.08))
                        border.color: wasCopied ? Commons.Color.accent : Commons.Color.popups.border
                        border.width: 1

                        MouseArea {
                          id: copyMouse
                          anchors.fill: parent
                          cursorShape: Qt.PointingHandCursor
                          hoverEnabled: true
                          onClicked: root.copyLink(modelData.id, modelData.url)
                        }

                        Text {
                          anchors.centerIn: parent
                          text: wasCopied ? "󰄬" : "󰆏"
                          font.family: Style.font.family
                          font.pixelSize: Style.font.caption
                          color: wasCopied ? Commons.Color.popups.background : Commons.Color.foreground
                        }
                      }

                      // Open browser
                      Rectangle {
                        width: Style.space(26)
                        height: Style.space(26)
                        radius: Math.max(2, Style.cornerRadius * 0.5)
                        color: openMouse.containsMouse
                          ? Qt.rgba(Commons.Color.foreground.r, Commons.Color.foreground.g, Commons.Color.foreground.b, 0.15)
                          : Qt.rgba(Commons.Color.foreground.r, Commons.Color.foreground.g, Commons.Color.foreground.b, 0.08)
                        border.color: Commons.Color.popups.border
                        border.width: 1

                        MouseArea {
                          id: openMouse
                          anchors.fill: parent
                          cursorShape: Qt.PointingHandCursor
                          hoverEnabled: true
                          onClicked: root.openLink(modelData.url)
                        }

                        Text {
                          anchors.centerIn: parent
                          text: "󰖟"
                          font.family: Style.font.family
                          font.pixelSize: Style.font.caption
                          color: Commons.Color.foreground
                        }
                      }

                      // Pin / Unpin
                      Rectangle {
                        width: Style.space(26)
                        height: Style.space(26)
                        radius: Math.max(2, Style.cornerRadius * 0.5)
                        color: isPinned
                          ? Qt.rgba(Commons.Color.accent.r, Commons.Color.accent.g, Commons.Color.accent.b, 0.2)
                          : (pinMouse.containsMouse
                              ? Qt.rgba(Commons.Color.foreground.r, Commons.Color.foreground.g, Commons.Color.foreground.b, 0.15)
                              : "transparent")
                        border.color: isPinned ? Commons.Color.accent : Commons.Color.popups.border
                        border.width: 1

                        MouseArea {
                          id: pinMouse
                          anchors.fill: parent
                          cursorShape: Qt.PointingHandCursor
                          hoverEnabled: true
                          onClicked: root.togglePin(modelData.id)
                        }

                        Text {
                          anchors.centerIn: parent
                          text: isPinned ? "📌" : "󰤱"
                          font.family: Style.font.family
                          font.pixelSize: Style.font.caption
                          color: isPinned ? Commons.Color.accent : (pinMouse.containsMouse ? Commons.Color.foreground : Qt.darker(Commons.Color.foreground, 1.8))
                        }
                      }

                      // Delete
                      Rectangle {
                        width: Style.space(26)
                        height: Style.space(26)
                        radius: Math.max(2, Style.cornerRadius * 0.5)
                        color: delMouse.containsMouse
                          ? Qt.rgba(Commons.Color.urgent.r, Commons.Color.urgent.g, Commons.Color.urgent.b, 0.25)
                          : "transparent"

                        MouseArea {
                          id: delMouse
                          anchors.fill: parent
                          cursorShape: Qt.PointingHandCursor
                          hoverEnabled: true
                          onClicked: root.deleteLink(modelData.id)
                        }

                        Text {
                          anchors.centerIn: parent
                          text: "󰆴"
                          font.family: Style.font.family
                          font.pixelSize: Style.font.caption
                          color: delMouse.containsMouse ? Commons.Color.urgent : Qt.darker(Commons.Color.foreground, 1.8)
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
  }
}
