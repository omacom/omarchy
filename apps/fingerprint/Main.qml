import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
  id: win
  required property var backend
  required property var appearance
  readonly property var v: backend.view
  readonly property var colors: appearance.colors
  readonly property color bg: colors.background || "#1c2028"
  readonly property color fg: colors.foreground || "#e7e9ef"
  readonly property color panel: colors.lighter_background || Qt.tint(bg, Qt.alpha(fg, 0.06))
  readonly property color accent: colors.accent || "#8bb2ec"
  readonly property color secondary: Qt.tint(bg, Qt.alpha(fg, 0.82))
  readonly property color edge: Qt.tint(bg, Qt.alpha(fg, 0.24))
  readonly property color onAccent: accent.hslLightness > 0.52 ? "#14151a" : "#ffffff"
  function t(key) { return appearance.strings[key] || key }

  property bool closePending: false
  onClosing: function(event) {
    if (v.page === "working") {
      event.accepted = false
      closePending = true
    }
  }
  onVChanged: {
    if (closePending && v.page !== "working") {
      closePending = false
      Qt.callLater(win.close)
    }
  }

  width: 484
  height: 590
  minimumWidth: 350
  minimumHeight: 360
  visible: true
  title: t("fingerprintApp.appTitle")
  color: bg
  palette.window: bg
  palette.windowText: fg
  palette.text: fg
  palette.base: panel
  palette.highlight: accent
  palette.highlightedText: onAccent

  component Heading: Label {
    textFormat: Text.PlainText
    Layout.fillWidth: true
    font.pixelSize: 28
    font.weight: Font.DemiBold
    color: win.fg
    wrapMode: Text.Wrap
    Accessible.role: Accessible.Heading
  }
  component Note: Label {
    textFormat: Text.PlainText
    Layout.fillWidth: true
    font.pixelSize: 14
    color: win.secondary
    wrapMode: Text.Wrap
  }
  component Section: Label {
    Layout.fillWidth: true
    Layout.topMargin: 10
    font.pixelSize: 15
    font.weight: Font.DemiBold
    color: win.fg
  }
  component Action: Button {
    id: button
    property bool primary: false
    property bool danger: false
    implicitHeight: 38
    leftPadding: 13
    rightPadding: 13
    opacity: enabled ? 1 : 0.55
    hoverEnabled: true
    contentItem: Text {
      text: button.text
      color: button.primary ? win.onAccent : button.danger ? (win.colors.red || "#c25464") : win.fg
      font.pixelSize: 14
      font.weight: Font.Medium
      verticalAlignment: Text.AlignVCenter
      horizontalAlignment: Text.AlignHCenter
    }
    background: Rectangle {
      radius: 7
      color: button.primary ? win.accent : button.hovered || button.down ? Qt.tint(win.panel, Qt.alpha(win.fg, 0.12)) : win.panel
      border.color: button.visualFocus ? win.fg : button.primary ? win.accent : win.edge
      border.width: button.visualFocus ? 2 : 1
    }
  }
  component PrintIcon: Fingerprint {
    foreground: win.fg
    paper: win.bg
    ink: win.accent
    compact: true
    Layout.preferredWidth: 42
    Layout.preferredHeight: 42
  }
  component Setting: RowLayout {
    id: row
    required property string label
    required property string description
    required property bool active
    required property bool available
    property bool managed: false
    signal toggle()
    spacing: 15
    Layout.fillWidth: true
    ColumnLayout {
      Layout.fillWidth: true
      spacing: 3
      Label { Layout.fillWidth: true; text: row.label; color: win.fg; font.pixelSize: 15; wrapMode: Text.Wrap }
      Note { text: row.description; font.pixelSize: 13 }
    }
    Switch {
      id: control
      objectName: row.label
      Accessible.name: row.label
      visible: !row.managed
      enabled: row.available
      checked: row.active
      checkable: false
      onClicked: row.toggle()
      indicator: Rectangle {
        implicitWidth: 42
        implicitHeight: 24
        radius: height / 2
        y: (control.height - height) / 2
        color: control.checked ? win.accent : win.panel
        border.width: control.visualFocus ? 2 : 1
        border.color: control.visualFocus ? win.fg : win.edge
        Rectangle {
          x: control.checked !== control.mirrored ? parent.width - width - 4 : 4
          anchors.verticalCenter: parent.verticalCenter
          width: 16; height: 16; radius: 8
          color: control.checked ? win.onAccent : win.secondary
        }
      }
    }
  }

  ScrollView {
    id: scroll
    LayoutMirroring.enabled: win.appearance.rightToLeft
    LayoutMirroring.childrenInherit: true
    anchors.fill: parent
    contentWidth: availableWidth
    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
    Loader {
      id: body
      width: scroll.availableWidth
      x: 0
      sourceComponent: {
        switch (win.v.page) {
        case "home": case "unavailable": return home
        case "scan": case "matched": case "added": return scanning
        case "edit": return editing
        case "confirm": return confirming
        default: return message
        }
      }
    }
  }
  component Page: ColumnLayout {
    spacing: 12
    // The loader owns the width. The spacer supplies the scrollable bottom inset.
    property int inset: Math.min(28, Math.round(width * 0.06))
    Item { Layout.preferredHeight: 10; Layout.fillWidth: true }
  }

  Component {
    id: home
    Page {
      id: hp
      readonly property bool ready: win.v.page === "home"
      RowLayout {
        Layout.fillWidth: true
        Layout.leftMargin: hp.inset; Layout.rightMargin: hp.inset
        spacing: 12
        PrintIcon {}
        ColumnLayout {
          spacing: 2
          Heading { text: hp.ready ? win.t(win.v.apple ? "fingerprintApp.touchId" : "fingerprintApp.fingerprints") : win.t("fingerprintApp.setupReader") }
          Note { visible: hp.ready; text: win.v.apple ? win.t("fingerprintApp.builtIn") : win.v.model }
        }
      }
      ColumnLayout {
        Layout.fillWidth: true
        Layout.leftMargin: hp.inset; Layout.rightMargin: hp.inset
        spacing: 10
        ComboBox {
          Layout.fillWidth: true
          visible: win.v.models.length > 1
          model: win.v.models
          currentIndex: win.v.selected
          Accessible.name: win.t("fingerprintApp.fingerprints")
          onActivated: index => win.backend.selectDevice(index)
        }
        Note { visible: text.length > 0; text: win.v.notice }
        Action { visible: !hp.ready; primary: true; text: win.t("fingerprintApp.retry"); onClicked: win.backend.refresh() }
        Section { visible: hp.ready; text: win.t("fingerprintApp.saved") }
        Repeater {
          model: win.v.prints
          delegate: Rectangle {
            id: saved
            required property var modelData
            Layout.fillWidth: true
            implicitHeight: 52
            color: win.panel
            radius: 8
            RowLayout {
              anchors.fill: parent
              anchors.leftMargin: 12; anchors.rightMargin: 8
              spacing: 8
              Label {
                textFormat: Text.PlainText
                text: saved.modelData.label; color: win.fg
                font.pixelSize: 15; Layout.fillWidth: true; elide: Text.ElideRight
              }
              Action {
                text: "✎"; implicitWidth: 36; leftPadding: 0; rightPadding: 0
                Accessible.name: win.t("fingerprintApp.editNamed").arg(saved.modelData.label)
                ToolTip.text: Accessible.name; ToolTip.visible: hovered
                onClicked: win.backend.edit(saved.modelData.slot)
              }
              Action {
                text: win.t("fingerprintApp.verify"); Accessible.name: win.t("fingerprintApp.verifyNamed").arg(saved.modelData.label)
                onClicked: win.backend.verify(saved.modelData.slot)
              }
            }
          }
        }
        Note { visible: hp.ready && !win.v.prints.length; text: win.t("fingerprintApp.empty") }
        Action { visible: hp.ready && !win.v.full; enabled: win.v.canEnroll; text: win.t("fingerprintApp.add"); primary: true; onClicked: win.backend.enroll() }
        Note { visible: hp.ready && win.v.full; text: win.t("fingerprintApp.full").arg(win.v.capacity) + " " + win.t("fingerprintApp.replace") }
        Note { visible: hp.ready && !win.v.full && !win.v.canEnroll; text: win.t("fingerprintApp.unlockNeedsShell") }
        Section { visible: hp.ready || win.v.sudoState === "enabled"; text: win.t("fingerprintApp.authentication") }
        Setting {
          visible: hp.ready && win.v.prints.length > 0
          label: win.t("fingerprintApp.useUnlock"); description: win.t(win.v.lockSupported ? "fingerprintApp.password" : "fingerprintApp.unlockNeedsShell")
          active: win.v.unlockOn; available: win.v.lockSupported
          onToggle: win.backend.toggleUnlock()
        }
        Rectangle { visible: hp.ready && win.v.prints.length > 0; Layout.fillWidth: true; implicitHeight: 1; color: win.edge }
        Setting {
          visible: hp.ready || win.v.sudoState === "enabled"
          label: win.t("fingerprintApp.useSudo")
          description: win.t(managed ? "fingerprintApp.sudoCustom" : !active && !win.v.prints.length ? "fingerprintApp.sudoEnroll" : "fingerprintApp.sudoScope")
          active: win.v.sudoState === "enabled"; managed: win.v.sudoState === "custom"
          available: active || win.v.prints.length > 0
          onToggle: win.backend.toggleSudo()
        }
        Action { visible: !hp.ready || win.v.consent; text: win.t("fingerprintApp.prepare"); onClicked: win.backend.prepare() }
        Action { Layout.alignment: Qt.AlignRight; text: win.t("fingerprintApp.done"); onClicked: win.close() }
      }
      Item { Layout.preferredHeight: 8 }
    }
  }

  component NameEditor: ColumnLayout {
    id: editor
    property bool added: false
    Layout.fillWidth: true
    Note { text: win.t("fingerprintApp.name") }
    TextField {
      id: nameInput
      Layout.fillWidth: true
      text: win.v.label
      maximumLength: 64
      readOnly: !win.v.canRename
      Accessible.name: win.t("fingerprintApp.name")
      Component.onCompleted: { forceActiveFocus(); selectAll() }
      onAccepted: win.backend.saveName(text)
    }
    RowLayout {
      Layout.alignment: Qt.AlignRight
      Action { visible: !editor.added; text: win.t("fingerprintApp.cancel"); onClicked: win.backend.refresh() }
      Action { primary: true; text: win.t(editor.added ? "fingerprintApp.done" : "fingerprintApp.save"); onClicked: win.backend.saveName(nameInput.text) }
    }
  }
  Component {
    id: scanning
    Page {
      id: sp
      readonly property bool complete: win.v.page === "added" || win.v.page === "matched"
      ColumnLayout {
        Layout.fillWidth: true; Layout.leftMargin: sp.inset; Layout.rightMargin: sp.inset
        spacing: 10
        Heading { horizontalAlignment: Text.AlignHCenter; text: win.t(win.v.mode === "Enroll" ? "fingerprintApp.enrollTitle" : "fingerprintApp.verifyTitle") }
        Note { horizontalAlignment: Text.AlignHCenter; text: win.v.label }
        Fingerprint {
          Layout.alignment: Qt.AlignHCenter; Layout.preferredWidth: 175; Layout.preferredHeight: 175
          ink: sp.complete ? (win.colors.green || win.accent) : win.accent
          foreground: win.fg; paper: win.bg
          complete: sp.complete; contact: win.v.contact; samples: win.v.samples
        }
        Heading {
          font.pixelSize: 22; horizontalAlignment: Text.AlignHCenter
          text: sp.complete ? win.t(win.v.page === "added" ? "fingerprintApp.added" : "fingerprintApp.matched") : win.v.prompt
          onTextChanged: function(value) { Accessible.announce(value, Accessible.Polite) }
        }
        Note {
          visible: !sp.complete && text.length > 0; horizontalAlignment: Text.AlignHCenter
          text: win.v.samples ? win.t("fingerprintApp.scans").arg(win.v.samples) : win.v.mode === "Enroll" && !win.v.swipe ? win.t("fingerprintApp.angle") : ""
        }
        Loader { Layout.fillWidth: true; active: win.v.page === "added"; sourceComponent: NameEditor { added: true } }
        Action {
          visible: win.v.page !== "added"; Layout.alignment: Qt.AlignHCenter
          primary: sp.complete; text: win.t(sp.complete ? "fingerprintApp.backToSaved" : "fingerprintApp.cancel"); onClicked: win.backend.refresh()
        }
      }
      Item { Layout.preferredHeight: 8 }
    }
  }
  Component {
    id: editing
    Page {
      id: ep
      ColumnLayout {
        Layout.fillWidth: true; Layout.leftMargin: ep.inset; Layout.rightMargin: ep.inset
        spacing: 18
        Heading { text: win.t("fingerprintApp.edit") }
        NameEditor {}
        Action { text: win.t("fingerprintApp.remove"); danger: true; onClicked: win.backend.confirmRemove() }
      }
    }
  }
  Component {
    id: confirming
    Page {
      id: cp
      ColumnLayout {
        Layout.fillWidth: true; Layout.leftMargin: cp.inset; Layout.rightMargin: cp.inset
        spacing: 16
        Heading { text: win.t("fingerprintApp.confirmRemove").arg(win.v.label) }
        Note { text: win.t("fingerprintApp.removeBody") }
        RowLayout {
          Layout.alignment: Qt.AlignRight
          Action { text: win.t("fingerprintApp.cancel"); Component.onCompleted: forceActiveFocus(); onClicked: win.backend.refresh() }
          Action { danger: true; text: win.t("fingerprintApp.removeConfirm"); onClicked: win.backend.remove() }
        }
      }
    }
  }
  Component {
    id: message
    Page {
      id: mp
      ColumnLayout {
        Layout.fillWidth: true; Layout.leftMargin: mp.inset; Layout.rightMargin: mp.inset
        spacing: 16
        Heading { text: win.v.page === "loading" ? win.t("fingerprintApp.appTitle") : win.v.page === "removing" ? win.t("fingerprintApp.removing") : win.v.title }
        Note { text: win.v.page === "loading" ? win.t("fingerprintApp.reading") : win.v.notice }
        Note { visible: win.closePending; text: win.t("fingerprintApp.finishBeforeClosing") }
        Action { visible: win.v.page === "failed" && win.v.mode === "Verify"; text: win.t("fingerprintApp.retryVerify"); primary: true; onClicked: win.backend.retry() }
        Action { visible: win.v.page === "failed"; text: win.t("fingerprintApp.backToSaved"); onClicked: win.backend.refresh() }
      }
    }
  }
}
