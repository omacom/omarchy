import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Commons as Commons
import qs.Ui
import "Model.js" as Model

Panel {
  id: root
  moduleName: "omarchy.dropbox"
  ipcTarget: "omarchy.dropbox"
  manageIpc: false

  // Items inside the panel's lazily built content, null until it first
  // opens. Code inside the content reaches its own ids directly.
  readonly property Item panelFlick: panel.loadedContent ? panel.loadedContent.panelFlick : null
  readonly property Item hero: panel.loadedContent ? panel.loadedContent.hero : null
  readonly property Item fileColumn: panel.loadedContent ? panel.loadedContent.fileColumn : null

  property string omarchyPath: Quickshell.env("OMARCHY_PATH")
  property string focusSection: "login"
  property int fileIndex: 0
  property bool cursorActive: false
  property int phraseIndex: 0

  readonly property var activePhrases: [
    Commons.I18n.t("dropbox.phrase1"),
    Commons.I18n.t("dropbox.phrase2"),
    Commons.I18n.t("dropbox.phrase3"),
    Commons.I18n.t("dropbox.phrase4"),
    Commons.I18n.t("dropbox.phrase5"),
    Commons.I18n.t("dropbox.phrase6"),
    Commons.I18n.t("dropbox.phrase7"),
    Commons.I18n.t("dropbox.phrase8"),
    Commons.I18n.t("dropbox.phrase9"),
    Commons.I18n.t("dropbox.phrase10")
  ]
  readonly property string heroPhraseText: activePhrases[phraseIndex % activePhrases.length]
  readonly property color foreground: bar ? bar.foreground : Commons.Color.foreground
  readonly property color urgent: bar ? bar.urgent : Commons.Color.urgent
  readonly property color dim: Qt.darker(foreground, 1.55)
  readonly property string fontFamily: bar ? bar.fontFamily : Style.font.family
  readonly property color iconColor: dropbox.authenticated && dropbox.active ? foreground : dim
  readonly property string toggleHint: dropbox.active ? Commons.I18n.t("dropbox.pauseSyncing") : Commons.I18n.t("dropbox.resumeSyncing")
  readonly property color barIconColor: dropbox.authenticated && dropbox.active ? barForeground : Qt.darker(barForeground, 1.55)
  // Only claim the header cursor when the switch is actually on screen —
  // "header" stays navigable, but an absent CLI leaves nothing to highlight.
  readonly property bool headerHasCursor: cursorActive && focusSection === "header" && dropbox.installed

  function ensureCursor() {
    if (!dropbox.authenticated) {
      focusSection = "login"
      fileIndex = 0
      return
    }
    if (dropbox.files.length === 0) {
      focusSection = "header"
      fileIndex = 0
      return
    }
    if (focusSection !== "files" && focusSection !== "header") focusSection = "files"
    if (fileIndex >= dropbox.files.length) fileIndex = Math.max(0, dropbox.files.length - 1)
    if (fileIndex < 0) fileIndex = 0
  }

  function moveCursor(dx, dy) {
    cursorActive = true
    ensureCursor()
    if (dy === 0) return
    if (focusSection === "header") {
      if (dy > 0 && dropbox.files.length > 0) {
        focusSection = "files"
        fileIndex = 0
        scrollCursorIntoView()
      }
      return
    }
    if (focusSection === "files") {
      if (dy < 0 && fileIndex === 0) {
        setHeaderCursor()
        return
      }
      fileIndex = Math.max(0, Math.min(dropbox.files.length - 1, fileIndex + dy))
      scrollCursorIntoView()
    }
  }

  function setHeaderCursor() {
    cursorActive = true
    focusSection = "header"
    if (panelFlick) panelFlick.contentY = 0
  }

  function toggleRunning() {
    if (dropbox.installed && !dropbox.busy) dropbox.toggleRunning()
  }

  function activateCursor() {
    ensureCursor()
    if (focusSection === "login") dropbox.login()
    else if (focusSection === "header") toggleRunning()
    else if (focusSection === "files") dropbox.openFile(selectedFile())
  }

  function selectedFile() {
    if (dropbox.files.length === 0) return null
    return dropbox.files[Math.max(0, Math.min(fileIndex, dropbox.files.length - 1))]
  }

  function setFileCursor(index) {
    cursorActive = true
    focusSection = "files"
    fileIndex = index
    scrollCursorIntoView()
  }

  function scrollItemIntoView(item) {
    if (!panelFlick || !item) return
    Qt.callLater(function() {
      if (!item) return
      var margin = Style.space(6)
      var point = item.mapToItem(panelFlick.contentItem, 0, 0)
      var top = point.y
      var bottom = top + item.height
      var viewTop = panelFlick.contentY
      var viewBottom = viewTop + panelFlick.height
      var maxY = Math.max(0, panelFlick.contentHeight - panelFlick.height)
      if (top < viewTop + margin) panelFlick.contentY = Math.max(0, top - margin)
      else if (bottom > viewBottom - margin) panelFlick.contentY = Math.min(maxY, bottom + margin - panelFlick.height)
    })
  }

  function scrollCursorIntoView() {
    if (focusSection === "files" && fileColumn && fileIndex >= 0 && fileIndex < fileColumn.children.length) {
      scrollItemIntoView(fileColumn.children[fileIndex])
    }
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  onOpenedChanged: if (opened) {
    cursorActive = false
    if (panelFlick) panelFlick.contentY = 0
    dropbox.refresh()
    Qt.callLater(function() { if (panel.loadedContent) panel.loadedContent.forceActiveFocus() })
  }
  onFileIndexChanged: scrollCursorIntoView()

  Service {
    id: dropbox
    settings: root.settings
    omarchyPath: root.omarchyPath
  }

  Connections {
    target: dropbox
    function onAuthenticatedChanged() { root.ensureCursor() }
    function onFilesChanged() { root.ensureCursor() }
  }

  ShellIpc {
    target: root.ipcTarget
    function open(): void { root.open() }
    function close(): void { root.close() }
    function show(): void { root.open() }
    function hide(): void { root.close() }
    function toggle(): void { root.toggle() }
    function refresh(): string { dropbox.refresh(); return "ok" }
    function login(): string { dropbox.login(); return "ok" }
    function status(): string { return dropbox.statusText }
  }

  BarIconButton {
    id: button
    accessibleName: I18n.t("dropbox.title")
    anchors.fill: parent
    bar: root.bar
    iconComponent: Component {
      Item {
        DropboxIcon {
          x: (parent.width - width) / 2
          y: (parent.height - height) / 2
          iconSize: button.iconSize / aspectRatio
          artworkScale: 1
          color: root.barIconColor
          opacity: dropbox.active ? 1.0 : 0.6
        }
      }
    }
    onPressed: function(buttonCode) {
      if (buttonCode === Qt.RightButton) dropbox.refresh()
      else if (buttonCode === Qt.MiddleButton) dropbox.login()
      else root.toggle()
    }
  }

  KeyboardPanel {
    id: panel
    accessibleName: I18n.t("dropbox.title")
    anchorItem: button
    owner: root
    bar: root.bar
    open: root.opened
    focusTarget: panel.loadedContent
    contentWidth: panel.fittedContentWidth(Style.space(380))
    contentHeight: panel.fittedContentHeight(panel.loadedContentHeight, Style.space(560))

    content: PanelKeyCatcher {
      id: keyCatcher
      property alias panelFlick: panelFlick
      property alias hero: hero
      property alias fileColumn: fileColumn
      implicitHeight: column.implicitHeight
      anchors.fill: parent
      onMoveRequested: function(dx, dy) {
        if (!root.cursorActive) { root.cursorActive = true; return }
        root.moveCursor(dx, dy)
      }
      onActivateRequested: if (root.cursorActive) root.activateCursor()
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }
      onTextKey: function(t) {
        if (t === "r" || t === "R") dropbox.refresh()
        else if (t === "l" || t === "L") dropbox.login()
        else if (t === "p" || t === "P") root.toggleRunning()
      }

      Flickable {
        id: panelFlick
        anchors.fill: parent
        contentWidth: width
        contentHeight: column.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.VerticalFlick
        interactive: contentHeight > height
        ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

        Column {
          id: column
          width: panelFlick.width
          spacing: Style.space(12)

          Item {
            id: header
            visible: dropbox.authenticated
            width: parent.width
            implicitHeight: hero.implicitHeight
            // Exposed for the hero's trailingControl, whose `root` resolves to
            // PanelHero (not this Panel) — reach panel state via `header`.
            readonly property bool ringVisible: root.headerHasCursor
            function focusHero() { root.setHeaderCursor() }

            PanelHero {
              id: hero
              width: parent.width
              title: Commons.I18n.t("dropbox.title")
              meta: dropbox.active ? root.heroPhraseText : Commons.I18n.t("dropbox.syncingPaused")
              foreground: root.foreground
              fontFamily: root.fontFamily
              iconOpacity: dropbox.active ? 1.0 : 0.5
              // Status only — the switch owns toggling, mouse and keyboard alike.
              iconComponent: Component {
                DropboxIcon {
                  iconSize: Style.font.display
                  color: root.iconColor
                }
              }

              // Compact on/off switch on the trailing edge of the hero, and the
              // header's only cursor target. The service already flips `active`
              // optimistically, so the knob throws the instant you click it.
              trailingControl: Component {
                ToggleSwitch {
                  id: powerSwitch
                  accessibleName: I18n.t("dropbox.title")
                  visible: dropbox.installed
                  checked: dropbox.active
                  busy: dropbox.busy
                  hasCursor: header.ringVisible
                  foreground: hero.foreground
                  onHovered: function(on) { if (on) header.focusHero() }
                  onToggled: root.toggleRunning()

                  PanelToolTip {
                    visible: powerSwitch.containsMouse
                    text: root.toggleHint
                    fontFamily: hero.fontFamily
                  }
                }
              }
            }
          }

          Text {
            textFormat: Text.PlainText
            visible: dropbox.actionStatus !== "" || dropbox.lastError !== ""
            width: parent.width
            text: dropbox.actionStatus !== "" ? dropbox.actionStatus : dropbox.lastError
            color: dropbox.lastError !== "" && dropbox.actionStatus === "" ? root.urgent : root.dim
            font.family: root.fontFamily
            font.pixelSize: Style.font.bodySmall
            wrapMode: Text.WordWrap
          }

          LoginButton {
            visible: !dropbox.authenticated
            width: parent.width
          }

          Column {
            visible: dropbox.authenticated
            width: parent.width
            spacing: Style.spacing.labelGap

            Column {
              width: parent.width
              spacing: Style.spacing.labelGap
              InfoPair { label: Commons.I18n.t("dropbox.stored"); value: Model.usageText(dropbox.usedBytes, dropbox.quotaBytes, dropbox.quotaKnown, Commons.I18n.t, Commons.I18n.formatNumber) }
            }
          }

          PanelSeparator {
            visible: dropbox.authenticated
            foreground: root.foreground
          }

          Column {
            visible: dropbox.authenticated
            width: parent.width
            spacing: Style.space(10)

            PanelSectionHeader {
              text: Commons.I18n.t("dropbox.recentFiles")
              foreground: root.foreground
              fontFamily: root.fontFamily
            }

            Text {
              visible: dropbox.files.length === 0
              width: parent.width
              text: Commons.I18n.t("dropbox.noFiles")
              textFormat: Text.PlainText
              color: root.dim
              font.family: root.fontFamily
              font.pixelSize: Style.font.body
              horizontalAlignment: Text.AlignHCenter
            }

            Column {
              id: fileColumn
              visible: dropbox.files.length > 0
              width: parent.width
              spacing: Style.space(6)

              Repeater {
                model: dropbox.files
                FileRow {
                  required property var modelData
                  required property int index
                  width: fileColumn.width
                  file: modelData
                  rowIndex: index
                }
              }
            }
          }
        }
      }
    }
  }

  Timer {
    id: phraseTimer
    interval: 2800
    running: root.opened && dropbox.authenticated && dropbox.active
    repeat: true
    onTriggered: phraseSwap.restart()
  }

  SequentialAnimation {
    id: phraseSwap
    PropertyAnimation {
      target: hero; property: "metaOpacity"
      to: 0.0; duration: Style.duration(180); easing.type: Easing.OutQuad
    }
    ScriptAction {
      script: root.phraseIndex = (root.phraseIndex + 1) % root.activePhrases.length
    }
    PropertyAnimation {
      target: hero; property: "metaOpacity"
      to: 1.0; duration: Style.duration(260); easing.type: Easing.InQuad
    }
  }

  component LoginButton: CursorSurface {
    id: loginButton

    accessibleName: dropbox.installed ? I18n.t("dropbox.login") : ""
    Accessible.onPressAction: loginButton.activate()
    hasCursor: root.cursorActive && root.focusSection === "login"
    foreground: root.foreground

    implicitHeight: loginRow.implicitHeight + Style.spacing.rowPaddingX

    function activate() {
      if (dropbox.installed && !dropbox.busy) dropbox.login()
    }

    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: dropbox.installed && !dropbox.busy ? Qt.PointingHandCursor : Qt.ArrowCursor
      enabled: dropbox.installed && !dropbox.busy
      onEntered: {
        root.cursorActive = true
        root.focusSection = "login"
      }
      onClicked: loginButton.activate()
    }

    RowLayout {
      id: loginRow
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      anchors.leftMargin: Style.space(10)
      anchors.rightMargin: Style.space(10)
      spacing: Style.space(8)

      Text {
        text: ""
        color: root.foreground
        font.family: root.fontFamily
        font.pixelSize: Style.font.heading
        Layout.alignment: Qt.AlignVCenter
      }

      ColumnLayout {
        Layout.fillWidth: true
        spacing: Style.space(1)

        Text {
          textFormat: Text.PlainText
          Layout.fillWidth: true
          text: dropbox.installed ? Commons.I18n.t("dropbox.login") : Commons.I18n.t("dropbox.notInstalled")
          color: root.foreground
          font.family: root.fontFamily
          font.pixelSize: Style.font.body
          elide: Text.ElideRight
        }

        Text {
          textFormat: Text.PlainText
          Layout.fillWidth: true
          text: dropbox.installed ? Commons.I18n.t("dropbox.loginHelp") : Commons.I18n.t("dropbox.installHelp")
          color: root.dim
          font.family: root.fontFamily
          font.pixelSize: Style.font.caption
          elide: Text.ElideRight
        }
      }

      PanelActionButton {
        accessibleName: I18n.t("accessibility.logInToDropbox")
        iconText: "󰌋"
        foreground: root.foreground
        fontFamily: root.fontFamily
        enabled: dropbox.installed && !dropbox.busy
        Layout.alignment: Qt.AlignVCenter
        onClicked: dropbox.login()
      }
    }
  }

  component FileRow: CursorSurface {
    id: fileRow
    property var file: null
    property int rowIndex: 0
    readonly property string fileName: file ? String(file.name || Commons.I18n.t("dropbox.untitled")) : Commons.I18n.t("dropbox.untitled")

    accessibleName: file ? fileName : ""
    Accessible.onPressAction: fileRow.activate()
    hasCursor: root.cursorActive && root.focusSection === "files" && root.fileIndex === rowIndex
    foreground: root.foreground

    implicitHeight: fileContent.implicitHeight + Style.spacing.rowPaddingX

    function activate() {
      if (file) dropbox.openFile(file)
    }

    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onEntered: root.setFileCursor(fileRow.rowIndex)
      onClicked: fileRow.activate()
    }

    RowLayout {
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      anchors.leftMargin: Style.space(10)
      anchors.rightMargin: Style.space(10)
      spacing: Style.space(8)

      Text {
        textFormat: Text.PlainText
        text: Model.fileGlyph(fileRow.fileName)
        color: root.foreground
        font.family: root.fontFamily
        font.pixelSize: Style.font.icon
        Layout.alignment: Qt.AlignVCenter
      }

      ColumnLayout {
        id: fileContent
        Layout.fillWidth: true
        spacing: Style.space(1)

        Text {
          textFormat: Text.PlainText
          Layout.fillWidth: true
          text: fileRow.fileName
          color: root.foreground
          font.family: root.fontFamily
          font.pixelSize: Style.font.body
          elide: Text.ElideRight
        }

        Text {
          textFormat: Text.PlainText
          Layout.fillWidth: true
          text: Model.fileMeta(fileRow.file, undefined, Commons.I18n.t, Commons.I18n.formatNumber)
          color: root.dim
          font.family: root.fontFamily
          font.pixelSize: Style.font.caption
          elide: Text.ElideRight
        }
      }
    }
  }

  component InfoPair: Row {
    property string label: ""
    property string value: ""

    width: parent.width
    spacing: Style.space(8)

    InfoLabel { text: label }
    Item { width: Math.max(0, parent.width - parent.children[0].implicitWidth - parent.children[2].implicitWidth - parent.spacing * 2); height: 1 }
    InfoValue { text: value }
  }

  component InfoLabel: Text {
    textFormat: Text.PlainText
    color: root.foreground
    opacity: 0.6
    font.family: root.fontFamily
    font.pixelSize: Style.font.bodySmall
  }

  component InfoValue: Text {
    textFormat: Text.PlainText
    color: root.foreground
    font.family: root.fontFamily
    font.pixelSize: Style.font.bodySmall
    elide: Text.ElideRight
  }
}
