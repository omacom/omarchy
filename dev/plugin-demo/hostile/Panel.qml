import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

Item {
  id: root
  property var shell
  property var manifest
  property string omarchyPath
  property bool opened: false
  property string result: "One harmless printf argument is approved. This button requests a different, unapproved argument."
  function open(payloadJson) { opened = true }
  function close() { opened = false }
  function dismiss() { shell.hide("demo.ward-hostile") }

  Process {
    id: attempt
    command: ["/bootstrap", "--json", "--exec", "demo", "Unapproved demo operation\n"]
    stdout: StdioCollector {
      onStreamFinished: {
        try {
          const response = JSON.parse(text)
          root.result = response.version === 1 && response.status === "denied"
            ? "Denied by Ward. The host command was not started."
            : "Unexpected result: " + text
        } catch (e) { root.result = "No valid result. This is not evidence of a policy denial." }
      }
    }
  }

  KeyboardPanel {
    anchorItem: null
    bar: null
    owner: QtObject { function close() { root.dismiss() } }
    screen: Quickshell.screens[0] || null
    open: root.opened
    contentWidth: fittedContentWidth(Style.space(440))
    contentHeight: cappedContentHeight(Style.space(280))
    focusTarget: content
    FocusScope {
      id: content
      anchors.fill: parent
      Keys.onEscapePressed: root.dismiss()
      ColumnLayout {
        anchors.fill: parent
        spacing: Style.spacing.panelGap
        Text { textFormat: Text.PlainText; text: "Hostile Demo"; color: Color.foreground; font.family: Style.font.family; font.pixelSize: Style.font.heading; font.bold: true }
        Text { textFormat: Text.PlainText; text: root.result; wrapMode: Text.WordWrap; color: Color.foreground; font.family: Style.font.family; font.pixelSize: Style.font.body; Layout.fillWidth: true; Layout.fillHeight: true }
        Button { text: "Malicious Execution"; objectName: "malicious-execution"; foreground: Color.popups.text; selected: true; focusable: true; implicitHeight: 44; enabled: !attempt.running; onClicked: { root.result = "Requesting unapproved host execution…"; attempt.running = true } }
      }
    }
  }
}
