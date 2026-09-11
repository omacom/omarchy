import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import Quickshell
import Quickshell.Hyprland
import qs.Commons
import qs.Ui

Item {
  id: root
  property var shell: null
  property var manifest: null
  property bool opened: false
  property bool detailsExpanded: false
  readonly property alias review: review

  function open(payloadJson) {
    var payload = {}
    try { payload = JSON.parse(payloadJson || "{}") || {} } catch (e) {}
    opened = true
    detailsExpanded = false
    if (!review.load(String(payload.id || ""), String(payload.stage || "")) && review.busy)
      review.error = "Wait for the current action to finish before reviewing another plugin."
  }
  function close() {
    if (review.stage && !review.busy) {
      Quickshell.execDetached(["omarchy-plugin-stage", "discard", review.stage])
      review.stage = ""
    }
    opened = false
  }
  function dismiss() {
    if (shell && typeof shell.hide === "function") shell.hide("omarchy.plugin-review")
    else close()
  }

  Review { id: review; onCompleted: root.dismiss() }

  KeyboardPanel {
    id: panel
    objectName: "plugin-review-window"
    anchorItem: null
    bar: null
    centerOnScreen: true
    owner: QtObject { function close() { root.dismiss() } }
    screen: Quickshell.screens.find(screen => screen.name === Hyprland.focusedMonitor?.name) || Quickshell.screens[0] || null
    open: root.opened
    focusTarget: content
    contentWidth: fittedContentWidth(Style.space(540))
    contentHeight: cappedContentHeight(Math.min(Style.space(620), contentLayout.implicitHeight + padding * 2 + Border.top(borderSpec) + Border.bottom(borderSpec)))

    FocusScope {
      id: content
      anchors.fill: parent
      Keys.onEscapePressed: root.dismiss()

      ColumnLayout {
        id: contentLayout
        anchors.fill: parent
        spacing: Style.spacing.panelGap

        RowLayout {
          Layout.fillWidth: true
          Label { text: "Plugin permissions"; font.pixelSize: Style.font.heading; font.bold: true; Layout.fillWidth: true }
          Button {
            objectName: "review-close"
            text: "Close"; focusable: true
            implicitHeight: Math.max(40, Style.spacing.controlHeight)
            onClicked: root.dismiss()
          }
        }

        ColumnLayout {
          Layout.fillWidth: true
          spacing: Style.spacing.labelGap
          RowLayout {
            Layout.fillWidth: true
            Label { text: review.revision ? review.revision.name : review.pluginId; font.pixelSize: Style.font.title; font.bold: true; Layout.fillWidth: true }
            Disclosure {
              label: "Details"
              expanded: root.detailsExpanded
              onToggled: root.detailsExpanded = !root.detailsExpanded
            }
          }
          Label {
            visible: root.detailsExpanded
            Layout.fillWidth: true
            wrapMode: Text.WrapAnywhere
            text: review.revision ? review.pluginId + " · " + review.revision.version + "\n" + review.revision.revision : ""
            font.pixelSize: Style.font.bodySmall
            color: Color.muted
          }
        }

        PanelSeparator { foreground: Color.popups.text; Layout.fillWidth: true }

        Controls.ScrollView {
          id: scroll
          objectName: "review-scroll"
          Layout.fillWidth: true
          Layout.fillHeight: true
          Layout.preferredHeight: permissions.implicitHeight
          clip: true
          contentWidth: availableWidth
          Controls.ScrollBar.horizontal.policy: Controls.ScrollBar.AlwaysOff
          Controls.ScrollBar.vertical.policy: contentHeight > availableHeight ? Controls.ScrollBar.AlwaysOn : Controls.ScrollBar.AlwaysOff

          Column {
            id: permissions
            width: scroll.availableWidth
            spacing: Style.spacing.rowGap
            enabled: !!review.revision && !review.busy

            Permission {
              width: parent.width
              visible: !!review.revision && review.revision.requests.network
              label: review.requestLabel("network", "Internet and local network")
              description: "Any destination, port and protocol, including local services. Send, receive and listen. No URL or request restrictions."
              fixed: review.isRequired("network")
              enabled: fixed || review.atomicEditable("network")
              checked: review.network
              onClicked: review.toggleAtomic("network")
            }
            Permission {
              width: parent.width
              visible: !!review.revision && review.revision.requests.networkProxy
              objectName: "review-network-proxy"
              label: review.requestLabel("networkProxy", "Public Internet connections")
              description: "Any public destination and TCP port, including bidirectional tunnels. Local/private destinations blocked. No site, URL or body restrictions."
              fixed: review.isRequired("networkProxy")
              enabled: fixed || review.atomicEditable("networkProxy")
              checked: review.networkProxy
              onClicked: review.toggleAtomic("networkProxy")
            }
            Permission {
              width: parent.width
              visible: !!review.revision && review.revision.requests.notifications
              label: review.requestLabel("notifications", "Send notifications")
              objectName: "review-notifications"
              description: "Show text notifications. No images or action buttons."
              fixed: review.isRequired("notifications")
              enabled: fixed || review.atomicEditable("notifications")
              checked: review.notifications
              onClicked: review.toggleAtomic("notifications")
            }
            Permission {
              width: parent.width
              visible: !!review.revision && review.revision.requests.audioPlayback
              objectName: "review-audio-playback"
              label: review.requestLabel("audioPlayback", "Play audio")
              description: "Default output only. No recording or player control."
              fixed: review.isRequired("audioPlayback")
              enabled: fixed || review.atomicEditable("audioPlayback")
              checked: review.audioPlayback
              onClicked: review.toggleAtomic("audioPlayback")
            }
            Permission {
              width: parent.width
              visible: !!review.revision && review.revision.requests.microphone
              objectName: "review-microphone"
              label: review.requestLabel("microphone", "Record microphone")
              description: "Default input, including a virtual input if selected."
              fixed: review.isRequired("microphone")
              enabled: fixed || review.atomicEditable("microphone")
              checked: review.microphone
              onClicked: review.toggleAtomic("microphone")
            }
            Permission {
              width: parent.width
              visible: !!review.revision && review.revision.requests.audioCapture
              objectName: "review-audio-capture"
              label: review.requestLabel("audioCapture", "Record system audio")
              description: "Default output, including other apps' audio."
              fixed: review.isRequired("audioCapture")
              enabled: fixed || review.atomicEditable("audioCapture")
              checked: review.audioCapture
              onClicked: review.toggleAtomic("audioCapture")
            }
            Repeater {
              model: review.settingRequests
              delegate: Permission {
                required property var modelData
                width: parent.width
                label: review.requestLabel("settings", (modelData.access === "read" ? "Read" : "Change") + " setting")
                objectName: "review-setting-" + modelData.access + "-" + modelData.key
                description: modelData.key + "\n" + (modelData.access === "read" ? "This plugin's whole value and live updates."
                  : "This plugin's whole value; unrestricted values. No read access.")
                fixed: review.isRequired("settings")
                checked: review.settings[modelData.access].indexOf(modelData.key) !== -1
                onClicked: review.toggleSetting(modelData.access, modelData.key)
              }
            }
            Repeater {
              model: review.httpRequests
              delegate: PermissionBlock {
                id: httpPermission
                required property string modelData
                readonly property var ask: review.revision.requests.http[modelData]
                property bool expanded: false
                width: parent.width
                spacing: Style.spacing.labelGap
                Permission {
                  width: parent.width
                  objectName: "review-http-" + modelData
                  label: "HTTP request" + review.requirementLabel(ask.required)
                  description: ask.scope.method + " " + ask.scope.origin + ask.scope.path
                  borderSpec: Border.none()
                  fixed: ask.required
                  enabled: fixed || !review.isRequired("network")
                  checked: review.http.indexOf(modelData) !== -1
                  onClicked: review.toggleHttp(modelData)
                }
                Disclosure {
                  objectName: "review-http-details-" + modelData
                  width: parent.width
                  label: "Scope"
                  expanded: httpPermission.expanded
                  onToggled: httpPermission.expanded = !httpPermission.expanded
                }
                Label {
                  objectName: "review-http-scope-" + modelData
                  width: parent.width
                  visible: httpPermission.expanded
                  wrapMode: Text.WrapAnywhere
                  text: review.httpDescription(ask.scope) + "\nNo host credentials or automatic redirects."
                  font.pixelSize: Style.font.bodySmall
                  color: Color.muted
                }
                Label {
                  width: parent.width
                  visible: review.networkProxy
                  text: "The selected public proxy is not limited by this HTTP scope."
                  color: Color.urgent
                }
              }
            }
            Permission {
              width: parent.width
              visible: !!review.revision && review.revision.requests.openUrls
              label: review.requestLabel("openUrls", "Open links in your browser")
              objectName: "review-open-urls"
              description: "Any HTTP(S) URL, including local sites, using your browser sessions. Can send data without a click. No domain or path restriction."
              fixed: review.isRequired("openUrls")
              enabled: fixed || review.atomicEditable("openUrls")
              checked: review.openUrls
              onClicked: review.toggleAtomic("openUrls")
            }
            Label {
              visible: review.execRequests.length > 0
              width: parent.width
              text: "Host commands can use your files, accounts and network."
              color: Color.urgent
            }
            Repeater {
              model: review.execRequests
              delegate: PermissionBlock {
                id: execPermission
                required property var modelData
                property bool expanded: false
                width: parent.width
                spacing: Style.spacing.labelGap
                Permission {
                  width: parent.width
                  objectName: "review-exec-" + modelData.name + "-" + modelData.leaf
                  label: "Host command" + review.requirementLabel(modelData.required)
                  description: modelData.executable
                  borderSpec: Border.none()
                  fixed: modelData.required
                  checked: Object.prototype.hasOwnProperty.call(review.exec, modelData.name)
                    && review.exec[modelData.name].indexOf(modelData.leaf) !== -1
                  onClicked: review.toggleExec(modelData.name, modelData.leaf)
                }
                Disclosure {
                  objectName: "review-exec-details-" + modelData.name + "-" + modelData.leaf
                  width: parent.width
                  label: "Command"
                  expanded: execPermission.expanded
                  onToggled: execPermission.expanded = !execPermission.expanded
                }
                Label {
                  width: parent.width
                  visible: execPermission.expanded
                  wrapMode: Text.WrapAnywhere
                  text: modelData.command
                  font.pixelSize: Style.font.bodySmall
                  color: Color.muted
                }
              }
            }
            Permission {
              width: parent.width
              visible: !!review.revision && review.revision.requests.media
              objectName: "review-media"
              label: review.requestLabel("media", "Control media player")
              description: (review.revision?.requests.media?.service || "")
                + "\nRead properties; play, pause, stop, next, previous and seek only."
              fixed: review.isRequired("media")
              enabled: fixed || review.atomicEditable("media")
              checked: review.media
              onClicked: review.toggleAtomic("media")
            }
            Repeater {
              model: review.folderRequests
              PermissionBlock {
                required property var modelData
                width: parent.width
                spacing: Style.spacing.labelGap
                Permission {
                  objectName: "review-folder-" + modelData.name
                  borderSpec: Border.none()
                  width: parent.width
                  label: (modelData.access === "readwrite" ? "Read and change " : "Read ")
                    + (modelData.target === "file" ? "file" : "folder") + review.requirementLabel(modelData.required)
                  description: modelData.access === "readwrite"
                    ? (modelData.target === "file" ? "This file only; replacement requires reapproval."
                      : "All files and subfolders, including creation and deletion.") + " Changes cannot be undone by revoking."
                    : modelData.target === "file" ? "This file only; replacement requires reapproval." : "All files and subfolders."
                  fixed: modelData.required
                  checked: review.folders[modelData.name] === true
                  onClicked: review.setFolder(modelData.name, !checked)
                }
                Label {
                  width: parent.width
                  text: review.revision.paths[modelData.name]
                    + (modelData.path !== review.revision.paths[modelData.name] ? "\nDeclared: " + modelData.path : "")
                  wrapMode: Text.WrapAnywhere
                  color: Color.muted
                }
              }
            }
            Permission {
              visible: !!review.revision && review.revision.requests.storage
              objectName: "review-storage"
              width: parent.width
              label: review.requestLabel("storage", "Save plugin data")
              description: "Persistent private home (/home/plugin). No disk quota. Data is kept after revoking."
              fixed: review.isRequired("storage")
              enabled: fixed || review.atomicEditable("storage")
              checked: review.storage
              onClicked: review.toggleAtomic("storage")
            }
            Label {
              visible: !!review.revision && !review.revision.requests.network && !review.revision.requests.notifications && review.settingRequests.length === 0 && !review.revision.requests.openUrls
                && !review.revision.requests.networkProxy
                && !review.revision.requests.audioPlayback && !review.revision.requests.microphone && !review.revision.requests.audioCapture
                && !review.revision.requests.media && !review.revision.requests.storage && !review.revision.requests.desktopGeometry && review.folderRequests.length === 0 && review.httpRequests.length === 0 && review.execRequests.length === 0
              text: "This plugin requests no permissions."
              color: Color.muted; width: parent.width
            }
            Permission {
              visible: !!review.revision && review.revision.requests.desktopGeometry
              objectName: "review-desktop-geometry"
              width: parent.width
              label: review.requestLabel("desktopGeometry", "Read window and screen layout")
              description: "All window, workspace and screen geometry. No titles, contents or control."
              fixed: review.isRequired("desktopGeometry")
              enabled: fixed || review.atomicEditable("desktopGeometry")
              checked: review.desktopGeometry
              onClicked: review.toggleAtomic("desktopGeometry")
            }
          }
        }

        Label {
          Layout.fillWidth: true
          text: review.error || (review.busy ? review.progressText : review.notice)
          color: review.error ? Color.urgent : Color.muted
          font.pixelSize: Style.font.bodySmall
          maximumLineCount: 4
          elide: Text.ElideRight
          visible: text !== ""
        }
        Label {
          visible: !!review.pluginId && !review.stage
          Layout.fillWidth: true
          text: "Deny & Remove permanently deletes this plugin, its saved plugin data and permission history."
          color: Color.muted
          font.pixelSize: Style.font.bodySmall
        }
        Flow {
          Layout.fillWidth: true
          spacing: Style.spacing.controlGap
          Button {
            text: "Deny & Remove"; focusable: true; enabled: !review.busy && !!review.pluginId
            opacity: enabled ? 1 : 0.4
            objectName: "review-remove"
            implicitHeight: Math.max(40, Style.spacing.controlHeight)
            onClicked: review.remove()
          }
          Button {
            text: review.current && review.current.enabled ? "Enabled" : "Enable"
            objectName: "review-approve"
            selected: true; focusable: true; enabled: !review.busy && review.requiredAccepted && !(review.current && review.current.enabled)
            opacity: enabled ? 1 : 0.4
            implicitHeight: Math.max(40, Style.spacing.controlHeight)
            onClicked: review.enable()
          }
        }
      }
    }
  }

  component Permission: Item {
    id: permission
    property string label: ""
    property string description: ""
    property bool checked: false
    property bool fixed: false
    property var borderSpec: null
    signal clicked()
    implicitHeight: content.item ? content.item.implicitHeight : 0
    implicitWidth: Style.space(240)

    Loader {
      id: content
      width: parent.width
      sourceComponent: permission.fixed ? fixedRow : optionalRow
    }
    Component {
      id: optionalRow
      Toggle {
        objectName: "permission-toggle"
        label: permission.label
        description: permission.description
        checked: permission.checked
        borderSpec: permission.borderSpec || _borderSpec
        onClicked: permission.clicked()
      }
    }
    Component {
      id: fixedRow
      BorderSurface {
        id: fixedSurface
        objectName: "permission-required"
        color: "transparent"
        borderSpec: permission.borderSpec || Border.controlSpec("normal", Color.foreground, Color.accent)
        implicitHeight: Math.max(54, textColumn.implicitHeight + Style.spacing.huge)
        Accessible.role: Accessible.StaticText
        Accessible.name: permission.label
        Accessible.description: permission.description

        Column {
          id: textColumn
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.verticalCenter: parent.verticalCenter
          anchors.leftMargin: fixedSurface.borderLeft + Style.spacing.rowPaddingX
          anchors.rightMargin: fixedSurface.borderRight + Style.spacing.rowPaddingX
          spacing: Style.spacing.xs
          Label {
            width: parent.width
            text: permission.label
            color: Color.foreground
            font.pixelSize: Style.font.subtitle
            font.bold: true
          }
          Label {
            width: parent.width
            visible: permission.description !== ""
            text: permission.description
            color: Qt.darker(Color.foreground, 1.5)
            font.pixelSize: Style.font.caption
          }
        }
      }
    }
  }

  component PermissionBlock: BorderSurface {
    id: block
    default property alias content: body.data
    property alias spacing: body.spacing
    padding: Style.spacing.rowGap
    borderSpec: Border.controlSpec("normal", Color.popups.text, Color.accent)
    color: "transparent"
    implicitHeight: body.implicitHeight + contentTopInset + contentBottomInset
    property Column layout: Column {
      id: body
      parent: block
      x: block.contentLeftInset
      y: block.contentTopInset
      width: block.width - block.contentLeftInset - block.contentRightInset
    }
  }

  component Disclosure: Item {
    id: disclosure
    property string label: ""
    property bool expanded: false
    signal toggled()
    implicitWidth: disclosureText.implicitWidth + Style.spacing.rowPaddingX * 2
    implicitHeight: Math.max(40, Style.spacing.controlHeight)
    activeFocusOnTab: true
    Accessible.role: Accessible.Button
    Accessible.name: label
    Accessible.onPressAction: toggled()
    Keys.onReturnPressed: toggled()
    Keys.onEnterPressed: toggled()
    Keys.onSpacePressed: toggled()
    Label {
      id: disclosureText
      anchors.left: parent.left
      anchors.leftMargin: Style.spacing.rowPaddingX
      anchors.verticalCenter: parent.verticalCenter
      text: (disclosure.expanded ? "⌄ " : "› ") + disclosure.label
      color: disclosure.activeFocus || disclosureMouse.containsMouse ? Color.accent : Color.muted
      font.pixelSize: Style.font.bodySmall
    }
    MouseArea {
      id: disclosureMouse
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onClicked: disclosure.toggled()
    }
  }

  component Label: Text {
    textFormat: Text.PlainText
    color: Color.popups.text
    font.family: Style.font.family
    font.pixelSize: Style.font.body
    wrapMode: Text.WordWrap
  }
}
