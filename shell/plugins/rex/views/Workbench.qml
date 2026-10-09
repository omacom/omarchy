import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Commons
import qs.Commons as Commons
import qs.Ui
import "../components"

// The main editing surface: flavor and flags, the pattern, the test text
// with its matches painted in, and the list of matches.
Item {
  id: root

  // The Rex root item, which owns the session and the engine.
  property var app

  readonly property color foreground: app.foreground
  readonly property color accent: app.accent
  readonly property color dim: Qt.darker(foreground, 1.5)

  function focusPattern() { patternField.forceActiveFocus() }

  ColumnLayout {
    anchors.fill: parent
    anchors.margins: Style.spacing.panelPadding
    spacing: Style.spacing.lg

    // ---- flavor, flags, status ----
    RowLayout {
      Layout.fillWidth: true
      spacing: Style.spacing.lg

      Dropdown {
        Layout.preferredWidth: Style.space(220)
        Layout.alignment: Qt.AlignTop
        showLabel: false
        value: root.app.flavor
        options: root.app.flavorOptions
        onChanged: function(value) { root.app.setFlavor(value) }
      }

      // Flags wrap onto more rows when the window is narrow.
      Flow {
        Layout.fillWidth: true
        spacing: Style.spacing.md

        Repeater {
          model: root.app.flavorInfo.flags

          Button {
            required property var modelData
            text: modelData.label
            tooltipText: modelData.description
            bordered: true
            selected: root.app.flags.indexOf(modelData.id) >= 0
            onClicked: root.app.toggleFlag(modelData.id)
          }
        }

        Button {
          text: root.app.all ? "All matches" : "First match"
          tooltipText: "Find every match, or stop at the first"
          bordered: true
          selected: root.app.all
          onClicked: root.app.all = !root.app.all
        }
      }

      Text {
        Layout.alignment: Qt.AlignTop | Qt.AlignRight
        Layout.topMargin: Style.spacing.md
        text: root.app.statusText
        color: root.app.result.ok === false ? Commons.Color.urgent : root.dim
        font.family: Style.font.family
        font.pixelSize: Style.font.caption
      }
    }

    // ---- pattern ----
    TextField {
      id: patternField
      Layout.fillWidth: true
      font.pixelSize: Style.font.title
      placeholderText: "Type a regular expression"
      text: root.app.pattern
      onTextEdited: root.app.pattern = text
    }

    Text {
      Layout.fillWidth: true
      visible: text !== ""
      text: root.app.problemText
      color: Commons.Color.urgent
      wrapMode: Text.Wrap
      font.family: Style.font.family
      font.pixelSize: Style.font.caption
      textFormat: Text.PlainText
    }

    // ---- text and matches ----
    RowLayout {
      Layout.fillWidth: true
      Layout.fillHeight: true
      spacing: Style.spacing.panelGap

      TestEditor {
        id: editor
        Layout.fillWidth: true
        Layout.fillHeight: true
        foreground: root.foreground
        accent: root.accent
        text: root.app.testText
        matches: root.app.result.matches
        stride: root.app.result.stride
        count: root.app.result.count
        groupColors: root.app.groupColors
        selectedMatch: root.app.selectedMatch
        onEdited: function(value) { root.app.testText = value }
      }

      MatchList {
        id: matchList
        Layout.preferredWidth: Math.max(Style.space(300), root.width * 0.32)
        Layout.fillHeight: true
        foreground: root.foreground
        accent: root.accent
        text: root.app.testText
        matches: root.app.result.matches
        stride: root.app.result.stride
        count: root.app.result.count
        groupNames: root.app.groupNames
        groupColors: root.app.groupColors
        selectedMatch: root.app.selectedMatch
        onPicked: function(index) {
          root.app.selectedMatch = index
          editor.selectMatch(index)
        }
      }
    }
  }
}
