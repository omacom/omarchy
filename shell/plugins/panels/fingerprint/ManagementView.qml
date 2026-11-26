import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import qs.Commons
import qs.Commons as Commons
import qs.Ui
import "EnrollmentModel.js" as Model

FocusScope {
  id: view
  property string initialReader: ""
  signal closeRequested()
  signal addRequested(string reader, string finger)
  readonly property bool authorizing: ctl.authorizing
  // Enrollment and management share the same dark layer over the desktop.
  readonly property color ink: Qt.rgba(1, 1, 1, 0.86)
  readonly property color muted: Qt.rgba(1, 1, 1, 0.64)
  // Even a light theme draws this panel over a mostly black scrim.
  readonly property color visibleAccent: Util.luminance(Commons.Color.accent) >= 0.2 ? Commons.Color.accent : ink
  property string selected: ""
  property bool confirming: false
  property bool renaming: false
  readonly property bool verifying: ctl.action === "verify" || ctl.mismatch
  readonly property bool home: !entry && !verifying
  readonly property var entry: ctl.state.prints.find(p => p.slot === selected)
  readonly property bool hasPrints: ctl.state.prints.length > 0

  function label(entry) {
    return entry.name || Commons.I18n.t("fingerprint.numbered").arg(Commons.I18n.formatNumber(entry.number))
  }
  function reveal(item) {
    const flick = scroll.contentItem
    let ancestor = item
    while (ancestor && ancestor !== flick.contentItem) ancestor = ancestor.parent
    if (!ancestor || !item.visible) return
    const y = item.mapToItem(flick.contentItem, 0, 0).y
    const target = item.height > flick.height || y < flick.contentY ? y
                 : Math.max(flick.contentY, y + item.height - flick.height)
    flick.contentY = Math.max(0, Math.min(flick.contentHeight - flick.height, target))
  }
  function revealFocus() {
    if (view.Window.window && scroll.activeFocus) reveal(view.Window.window.activeFocusItem)
  }
  onSelectedChanged: if (scroll.contentItem) scroll.contentItem.contentY = 0

  function back() {
    if (ctl.mismatch) ctl.clearMismatch()
    else if (confirming) confirming = false
    else if (renaming) renaming = false
    else selected = ""
    forceActiveFocus()
    ctl.notice = ""
  }

  component Action: Button {
    onActiveFocusChanged: if (activeFocus) view.reveal(this)
    opacity: enabled ? 1 : 0.55
    focusable: true
    foreground: view.ink
    accent: view.ink
    borderSpec: activeFocus ? Border.flat(view.ink, 1) : bordered ? Border.flat(Qt.rgba(1, 1, 1, 0.25), 1) : Border.none()
    color: hot || activeFocus ? Qt.rgba(1, 1, 1, 0.07) : "transparent"
    Layout.alignment: Qt.AlignHCenter
    Accessible.role: Accessible.Button
    Accessible.name: text
    Accessible.onPressAction: if (enabled) clicked()
  }
  component Setting: Controls.CheckBox {
    id: setting
    // A match or administrator approval can fail. Only the refreshed backend
    // state changes the native checkbox, including for accessibility actions.
    nextCheckState: () => checkState
    indicator: null
    required property string label
    property string description: ""
    Layout.fillWidth: true
    implicitHeight: Math.max(Style.space(36), contentItem.implicitHeight + 2 * verticalPadding)
    horizontalPadding: Style.space(12)
    verticalPadding: Style.space(6)
    focusPolicy: Qt.StrongFocus
    opacity: enabled ? 1 : 0.55
    onActiveFocusChanged: if (activeFocus) view.reveal(this)
    Keys.onReturnPressed: if (enabled) clicked()
    Keys.onEnterPressed: if (enabled) clicked()
    Accessible.role: Accessible.CheckBox
    Accessible.name: label
    Accessible.description: description
    Accessible.checkable: true
    Accessible.checked: checked
    Accessible.onToggleAction: if (enabled) clicked()

    background: Rectangle {
      color: setting.hovered || setting.activeFocus ? Qt.rgba(1, 1, 1, 0.07) : "transparent"
      border.width: setting.activeFocus ? 1 : 0
      border.color: view.muted
    }
    HoverHandler { cursorShape: Qt.PointingHandCursor }
    contentItem: RowLayout {
      spacing: Style.space(12)
      ColumnLayout {
        Layout.fillWidth: true
        spacing: Style.space(3)
        Line {
          text: setting.label
          horizontalAlignment: Text.AlignLeft
          color: view.ink
        }
        Line {
          visible: setting.description !== ""
          text: setting.description
          horizontalAlignment: Text.AlignLeft
          color: view.muted
          font.pixelSize: Style.font.body
        }
      }
      Line {
        Layout.fillWidth: false
        text: setting.checked ? Commons.I18n.t("fingerprint.on") : Commons.I18n.t("fingerprint.off")
        color: setting.checked ? view.ink : view.muted
      }
      ToggleSwitch {
        interactive: false
        opacity: checked ? 1 : 0.48
        foreground: view.ink
        accent: view.visibleAccent
        checkedKnobColor: view.visibleAccent
        checked: setting.checked
        trackHeight: Style.space(16)
      }
    }
  }
  component Line: Text {
    Layout.fillWidth: true
    textFormat: Text.PlainText
    wrapMode: Text.Wrap
    horizontalAlignment: Text.AlignHCenter
    color: view.muted
    font.family: Style.font.family
    font.pixelSize: Style.font.body
  }

  focus: true
  Keys.onEscapePressed: {
    if (ctl.action === "verify") ctl.cancelVerify()
    else if (ctl.mismatch) back()
    else if (ctl.busy || selected === "") closeRequested()
    else back()
  }

  Management {
    id: ctl
    reader: view.initialReader
    onRenamed: { view.renaming = false; view.forceActiveFocus() }
    onRefreshed: {
      if (!view.entry) {
        view.selected = ""
        view.confirming = false
        editor.text = ""
      }
      if (!view.entry || !state.canRename) view.renaming = false
    }
  }

  Item {
    id: stage
    anchors.centerIn: parent
    width: Math.min(parent.width - Style.space(32), Style.space(396))
    readonly property real topGap: view.verifying ? Style.space(28) : Style.space(10)
    readonly property real bottomGap: view.verifying ? 0 : Style.space(12)
    readonly property real availableHeight: Math.max(0, parent.height - Style.space(24))
    // Pin the settings when a whole fingerprint row still fits above them.
    readonly property real fixedHomeHeight: Style.space(40) + header.spacing + heading.implicitHeight + topGap + bottomGap
        + homeActions.implicitHeight + footer.spacing + retryActions.implicitHeight
        + (status.visible ? status.implicitHeight + footer.spacing : 0)
    readonly property bool scrollSettings: view.home && availableHeight < fixedHomeHeight + Style.space(38)
    height: Math.min(availableHeight, header.height + topGap + content.implicitHeight + bottomGap + footer.implicitHeight)

    Column {
      id: header
      width: parent.width
      spacing: Style.space(12)

      FingerprintArt {
        anchors.horizontalCenter: parent.horizontalCenter
        // Reserve the instruction and exit action first on short screens.
        readonly property real available: stage.availableHeight - footer.implicitHeight - stage.topGap
        readonly property real controlsHeight: heading.implicitHeight + header.spacing + content.implicitHeight + stage.bottomGap
        width: Math.max(0, Math.min(implicitWidth, parent.width, view.verifying ? available : Math.max(Style.space(40), available - controlsHeight)))
        height: width
        tone: view.visibleAccent
        // These are saved prints. The ridges light on an actual match.
        filled: !view.verifying && !!view.entry && ctl.matched && ctl.verifyFinger === view.selected && ctl.notice !== "" ? 1 : 0
      }

      Line {
        id: heading
        width: parent.width
        visible: !view.verifying
        text: view.entry ? view.label(view.entry) : Commons.I18n.t("fingerprint.saved")
        font.pixelSize: Style.font.heading
      }
    }

    Controls.ScrollView {
      id: scroll
      onHeightChanged: Qt.callLater(view.revealFocus)
      onWidthChanged: Qt.callLater(view.revealFocus)
      anchors { top: header.bottom; left: parent.left; right: parent.right; bottom: footer.top }
      anchors.topMargin: stage.topGap
      anchors.bottomMargin: stage.bottomGap
      readonly property bool overflows: contentHeight > height + 1
      leftPadding: overflows && mirrored ? Style.space(8) : 0
      rightPadding: overflows && !mirrored ? Style.space(8) : 0
      Controls.ScrollBar.horizontal.policy: Controls.ScrollBar.AlwaysOff
      Controls.ScrollBar.vertical: Controls.ScrollBar {
        parent: scroll
        anchors { top: parent.top; bottom: parent.bottom; right: parent.right }
        visible: scroll.overflows
        policy: scroll.overflows ? Controls.ScrollBar.AlwaysOn : Controls.ScrollBar.AlwaysOff
        active: scroll.overflows
        implicitWidth: Style.space(4)
        minimumSize: Math.min(1, Style.space(14) / Math.max(1, height))
        padding: 0
        contentItem: Rectangle { color: view.muted; radius: width / 2 }
        background: null
      }
      contentWidth: availableWidth
      clip: true
      ColumnLayout {
        id: content
        width: scroll.availableWidth
        spacing: Style.space(10)

        ColumnLayout {
          visible: view.home
          Layout.fillWidth: true
          spacing: Style.space(2)
          Repeater {
            model: ctl.state.readers.length > 1 || !ctl.state.reader ? ctl.state.readers : []
            Action {
              required property var modelData
              Layout.fillWidth: true
              text: modelData.name
              selected: modelData.token === ctl.state.reader
              enabled: !ctl.busy
              onClicked: { ctl.notice = ""; ctl.refresh(modelData.token) }
            }
          }
          Repeater {
            model: ctl.state.prints
            Action {
              required property var modelData
              Layout.fillWidth: true
              text: view.label(modelData)
              leftAlign: true
              enabled: !ctl.busy
              Text {
                anchors { right: parent.right; rightMargin: Style.space(12); verticalCenter: parent.verticalCenter }
                textFormat: Text.PlainText
                text: view.LayoutMirroring.enabled ? "‹" : "›"
                color: view.muted
                font.family: Style.font.family
                font.pixelSize: Style.font.heading
                Accessible.ignored: true
              }
              // Leave the trailing chevron clear when a long name elides.
              horizontalPadding: Style.space(40)
              leftPadding: Style.space(12)
              onClicked: {
                view.selected = modelData.slot
                editor.text = modelData.name
                ctl.notice = ""
                view.forceActiveFocus()
              }
            }
          }

        }

        LayoutItemProxy {
          target: homeActions
          visible: stage.scrollSettings
          Layout.fillWidth: true
        }

        ColumnLayout {
          visible: !!view.entry && !view.confirming && !view.verifying
          Layout.alignment: Qt.AlignHCenter
          Layout.fillWidth: true
          enabled: !ctl.busy
          ColumnLayout {
            visible: view.renaming
            Layout.fillWidth: true
            TextField {
              id: editor
              Layout.fillWidth: true
              foreground: view.ink
              accent: view.ink
              onActiveFocusChanged: if (activeFocus) view.reveal(this)
              maximumLength: 64
              placeholderText: Commons.I18n.t("fingerprint.name")
              Accessible.name: placeholderText
              onAccepted: save.clicked()
            }
            Action {
              id: save
              bordered: true
              text: Commons.I18n.t("fingerprint.saveName")
              onClicked: ctl.run("rename", [ctl.helper, "rename", ctl.state.reader, view.selected, editor.text])
            }
          }
          GridLayout {
            Layout.fillWidth: false
            visible: !view.renaming
            Layout.alignment: Qt.AlignHCenter
            columnSpacing: Style.space(4)
            rowSpacing: Style.space(2)
            columns: rename.visible && verify.implicitWidth + rename.implicitWidth + columnSpacing <= stage.width ? 2 : 1
            Action {
              id: verify
              bordered: true
              text: Commons.I18n.t("fingerprint.verifySaved")
              onClicked: ctl.verify(view.selected)
            }
            Action {
              id: rename
              visible: !!ctl.state.canRename
              bordered: true
              text: Commons.I18n.t("fingerprint.rename")
              onClicked: {
                ctl.notice = ""
                editor.text = view.entry.name
                view.renaming = true
                editor.forceActiveFocus()
                editor.selectAll()
              }
            }
            Action {
              Layout.columnSpan: parent.columns
              Layout.topMargin: Style.space(6)
              foreground: "#ffc2bb"
              bordered: true
              text: Commons.I18n.t("fingerprint.removeSaved")
              onClicked: { ctl.notice = ""; view.confirming = true }
            }
          }
        }

        Line {
          visible: !!view.entry && view.confirming
          text: view.entry ? Commons.I18n.t("fingerprint.confirmRemove").arg(view.label(view.entry)) : ""
        }
        Action {
          visible: view.confirming
          foreground: "#ff6b6b"
          bordered: true
          enabled: !ctl.busy
          text: Commons.I18n.t("fingerprint.removeSaved")
          onClicked: ctl.run("remove", [ctl.helper, "remove", ctl.state.reader, view.selected])
        }
      }
    }

    ColumnLayout {
      id: homeActions
      spacing: Style.space(2)
      Layout.fillWidth: true
      Action {
        Layout.fillWidth: true
        leftAlign: true
        readonly property bool full: ctl.state.capacity > 0 && ctl.state.prints.length >= ctl.state.capacity
        iconText: full ? "" : "+"
        text: full ? Commons.I18n.t("fingerprint.readerFull") : Commons.I18n.t("fingerprint.add")
        enabled: !ctl.busy && ctl.state.reader !== "" && !full
        onClicked: view.addRequested(ctl.state.reader, Model.suggestFinger(ctl.state.prints.map(p => p.slot)))
      }
      Rectangle {
        Layout.fillWidth: true
        Layout.topMargin: Style.space(7)
        Layout.bottomMargin: Style.space(4)
        implicitHeight: 1
        color: Qt.rgba(1, 1, 1, 0.16)
      }
      Setting {
        label: Commons.I18n.t("fingerprint.unlockSetting")
        checked: ctl.state.lock
        enabled: !ctl.busy && (checked || view.hasPrints)
        onClicked: ctl.changeLock(!checked)
      }
      Setting {
        label: Commons.I18n.t("fingerprint.sudoSetting")
        description: ctl.state.sudo === "custom" ? Commons.I18n.t("fingerprint.customSudo") : Commons.I18n.t("fingerprint.sudoScope")
        checked: ctl.state.sudo === "on"
        enabled: !ctl.busy && ctl.state.sudo !== "custom" && (checked || view.hasPrints)
        onClicked: ctl.changeSudo(!checked)
      }
    }

    ColumnLayout {
      id: footer
      anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
      spacing: Style.space(10)
      LayoutItemProxy {
        target: homeActions
        visible: view.home && !stage.scrollSettings
        Layout.fillWidth: true
      }

      Line {
        id: status
        visible: ctl.notice !== ""
        font.pixelSize: view.verifying ? Style.font.heading : Style.font.body
        readonly property var requestedPrint: view.verifying && ctl.state.prints.find(p => p.slot === ctl.verifyFinger)
        color: ctl.mismatch ? "#ff9999" : view.muted
        text: ctl.mismatch && requestedPrint ? Commons.I18n.t("fingerprint.namedNoMatch").arg(view.label(requestedPrint))
              : requestedPrint && ctl.verification && ctl.verification.slot === "any" ? Commons.I18n.t("fingerprint.useSaved").arg(view.label(requestedPrint)).arg(ctl.notice) : ctl.notice
      }
      RowLayout {
        id: retryActions
        Layout.alignment: Qt.AlignHCenter
        Action {
          visible: ctl.mismatch
          bordered: true
          text: Commons.I18n.t("fingerprint.tryAgain")
          enabled: !ctl.busy
          onClicked: ctl.verify(ctl.verification.slot, ctl.verification.next)
        }
        Action {
          bordered: true
          text: ctl.action === "verify" ? Commons.I18n.t("common.cancel")
                : view.entry || ctl.mismatch ? Commons.I18n.t("fingerprint.back") : Commons.I18n.t("fingerprint.close")
          enabled: !ctl.busy || ctl.action === "verify"
          onClicked: {
            if (ctl.action === "verify") ctl.cancelVerify()
            else if (view.entry || ctl.mismatch) view.back()
            else view.closeRequested()
          }
        }
      }
    }
  }
}
