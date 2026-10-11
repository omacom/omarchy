import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Commons
import qs.Commons as Commons
import qs.Ui

// What to do with the matches: substitute a replacement, list a template
// for each match, or split the text on them. Each uses the selected
// flavor's own rules.
ColumnLayout {
  id: root

  property var app

  readonly property color foreground: app.foreground
  readonly property color accent: app.accent
  readonly property color dim: Qt.darker(foreground, 1.5)

  spacing: Style.spacing.md

  RowLayout {
    Layout.fillWidth: true
    spacing: Style.spacing.lg

    ButtonGroup {
      options: [
        { value: "substitute", label: "Substitute" },
        { value: "list", label: "List" },
        { value: "split", label: "Split" },
      ]
      value: root.app.tool
      onChanged: function(value) { root.app.tool = root.app.tool === value ? "" : value }
    }

    Text {
      Layout.fillWidth: true
      visible: root.app.tool !== ""
      text: root.app.tool === "split" ? root.app.splitNote : root.app.replaceSyntaxNote
      color: root.dim
      elide: Text.ElideRight
      font.family: Style.font.family
      font.pixelSize: Style.font.caption
      textFormat: Text.PlainText
    }

    Button {
      visible: root.app.tool !== ""
      iconText: "󰅖"
      tooltipText: "Close the tool"
      onClicked: root.app.tool = ""
    }
  }

  TextField {
    Layout.fillWidth: true
    visible: root.app.tool === "substitute" || root.app.tool === "list"
    placeholderText: root.app.tool === "list" ? "Template for each match, such as $1\\n" : "Replacement"
    text: root.app.tool === "list" ? root.app.listTemplate : root.app.replacement
    onTextEdited: {
      if (root.app.tool === "list") root.app.listTemplate = text
      else root.app.replacement = text
    }
  }

  Text {
    Layout.fillWidth: true
    visible: text !== "" && root.app.tool !== "split"
    text: root.app.replaceProblem
    color: Commons.Color.urgent
    wrapMode: Text.Wrap
    font.family: Style.font.family
    font.pixelSize: Style.font.caption
    textFormat: Text.PlainText
  }

  OutputText {
    Layout.fillWidth: true
    Layout.fillHeight: true
    visible: root.app.tool === "substitute" || root.app.tool === "list"
    foreground: root.foreground
    accent: root.accent
    text: root.app.tool === "list" ? root.app.listOutput : root.app.substitution.text
    spans: root.app.tool === "list" ? [] : root.app.substitution.spans
    placeholder: root.app.tool === "list" ? "Nothing listed" : ""
  }

  ListView {
    id: pieces
    Layout.fillWidth: true
    Layout.fillHeight: true
    visible: root.app.tool === "split"
    clip: true
    model: root.app.splitPieces
    spacing: Style.spacing.xs
    boundsBehavior: Flickable.StopAtBounds
    ScrollBar.vertical: ScrollBar {}

    delegate: RowLayout {
      required property int index
      required property var modelData
      width: pieces.width - Style.spacing.lg
      spacing: Style.spacing.md

      Text {
        Layout.preferredWidth: Style.space(44)
        text: String(modelData.index) + (modelData.group ? " $" + modelData.group : "")
        textFormat: Text.PlainText
        color: modelData.group ? root.accent : root.dim
        horizontalAlignment: Text.AlignRight
        font.family: Style.font.family
        font.pixelSize: Style.font.caption
      }

      Text {
        Layout.fillWidth: true
        text: modelData.text === null ? "undefined" : JSON.stringify(modelData.text)
        color: modelData.text === null ? root.dim : root.foreground
        font.italic: modelData.text === null
        elide: Text.ElideRight
        font.family: Style.font.family
        font.pixelSize: Style.font.bodySmall
        textFormat: Text.PlainText
      }
    }
  }
}
