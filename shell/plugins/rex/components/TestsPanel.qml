import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Commons
import qs.Commons as Commons
import qs.Ui
import "../lib/Tests.js" as Tests

// The pattern's unit tests: texts it must or must not match, or must
// capture from. They run on the real engine whenever anything changes, and
// the optimizer only offers rewrites that still pass them.
ColumnLayout {
  id: root

  property var app

  readonly property color foreground: app.foreground
  readonly property color accent: app.accent
  readonly property color dim: Qt.darker(foreground, 1.5)

  property string draftExpect: "match"

  spacing: Style.spacing.md

  function add() {
    if (draftText.text === "" && draftExpect !== "nomatch") return
    root.app.addTest({ text: draftText.text, expect: draftExpect, group: draftGroup.text, value: draftValue.text })
    draftText.text = ""
    draftValue.text = ""
  }

  // ---- adding a test ----
  TextField {
    id: draftText
    Layout.fillWidth: true
    placeholderText: "A text to test"
    onAccepted: root.add()
  }

  RowLayout {
    Layout.fillWidth: true
    spacing: Style.spacing.md

    Dropdown {
      Layout.preferredWidth: Style.space(170)
      showLabel: false
      value: root.draftExpect
      options: Tests.KINDS
      onChanged: function(value) { root.draftExpect = value }
    }

    TextField {
      id: draftGroup
      Layout.preferredWidth: Style.space(60)
      visible: root.draftExpect === "group"
      placeholderText: "1"
      text: "1"
    }

    TextField {
      id: draftValue
      Layout.fillWidth: true
      visible: root.draftExpect === "group"
      placeholderText: "the text it captures"
      onAccepted: root.add()
    }

    Item { Layout.fillWidth: true; visible: root.draftExpect !== "group" }

    Button {
      text: "Add test"
      bordered: true
      onClicked: root.add()
    }
  }

  Text {
    Layout.fillWidth: true
    visible: root.app.tests.length > 0
    text: root.app.testsPassed + " of " + root.app.tests.length + " pass"
    color: root.app.testsPassed === root.app.tests.length ? root.accent : Commons.Color.urgent
    font.family: Style.font.family
    font.pixelSize: Style.font.caption
  }

  // ---- the tests ----
  ListView {
    id: list
    Layout.fillWidth: true
    Layout.fillHeight: true
    clip: true
    model: root.app.tests
    spacing: Style.spacing.sm
    boundsBehavior: Flickable.StopAtBounds
    ScrollBar.vertical: ScrollBar {}

    delegate: Rectangle {
      id: row
      required property int index
      required property var modelData
      readonly property var outcome: root.app.testResults[index]

      width: list.width - Style.spacing.lg
      height: content.implicitHeight + Style.spacing.md * 2
      radius: Style.cornerRadius
      color: Util.alpha(root.foreground, 0.03)
      border.width: 1
      border.color: !outcome ? Util.alpha(root.foreground, 0.08) : Util.alpha(outcome.pass ? root.accent : Commons.Color.urgent, 0.45)

      RowLayout {
        id: content
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: Style.spacing.md
        spacing: Style.spacing.md

        Text {
          text: !row.outcome ? "…" : (row.outcome.pass ? "✓" : "✗")
          color: !row.outcome ? root.dim : (row.outcome.pass ? root.accent : Commons.Color.urgent)
          font.family: Style.font.family
          font.pixelSize: Style.font.body
          font.bold: true
        }

        ColumnLayout {
          Layout.fillWidth: true
          spacing: 0

          Text {
            Layout.fillWidth: true
            text: JSON.stringify(row.modelData.text) + " " + Tests.describe(row.modelData)
            color: root.foreground
            elide: Text.ElideRight
            font.family: Style.font.family
            font.pixelSize: Style.font.bodySmall
            textFormat: Text.PlainText
          }

          Text {
            Layout.fillWidth: true
            visible: !!row.outcome
            text: row.outcome ? row.outcome.detail : ""
            color: root.dim
            elide: Text.ElideRight
            font.family: Style.font.family
            font.pixelSize: Style.font.caption
            textFormat: Text.PlainText
          }
        }

        Button {
          iconText: "󰏫"
          tooltipText: "Put this text in the workbench"
          onClicked: root.app.setTypedText(row.modelData.text)
        }

        Button {
          iconText: "󰆴"
          tooltipText: "Remove the test"
          onClicked: root.app.removeTest(row.index)
        }
      }
    }
  }

  Text {
    Layout.fillWidth: true
    visible: root.app.tests.length === 0
    text: "Tests pin down what the pattern must do: texts it has to match, has to reject, or has to capture from. They run on every change, and the optimizer only offers rewrites that still pass them."
    color: root.dim
    wrapMode: Text.Wrap
    font.family: Style.font.family
    font.pixelSize: Style.font.caption
  }
}
