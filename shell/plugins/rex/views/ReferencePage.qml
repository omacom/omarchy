import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Commons
import qs.Commons as Commons
import qs.Ui
import "../lib/Reference.js" as Reference
import "../lib/Replace.js" as Replace

// Every construct the flavor knows, with what it means and an example that
// opens on the workbench.
Item {
  id: root

  property var app

  readonly property color foreground: app.foreground
  readonly property color accent: app.accent
  readonly property color dim: Qt.darker(foreground, 1.5)

  property bool onlySupported: true
  readonly property var entries: Reference.search(Reference.forFlavor(app.flavor), search.text)
    .filter(function(e) { return !root.onlySupported || e.supported })

  function tryEntry(entry) {
    app.pattern = entry.pattern
    app.setTypedText(entry.text)
    app.showPage("workbench")
  }

  ColumnLayout {
    anchors.fill: parent
    anchors.margins: Style.spacing.panelPadding
    spacing: Style.spacing.lg

    RowLayout {
      Layout.fillWidth: true
      spacing: Style.spacing.lg

      Text {
        text: "Reference"
        color: root.foreground
        font.family: Style.font.family
        font.pixelSize: Style.font.heading
        font.bold: true
      }

      Text {
        text: root.app.flavorInfo.name
        color: root.dim
        font.family: Style.font.family
        font.pixelSize: Style.font.caption
      }

      TextField {
        id: search
        Layout.fillWidth: true
        placeholderText: "Search: lookbehind, \\b, unicode…"
      }

      Button {
        text: root.onlySupported ? "Only " + root.app.flavorInfo.short : "Everything"
        tooltipText: root.onlySupported ? "Showing what " + root.app.flavorInfo.name + " supports. Click to show the rest too." : "Showing every construct. Click to keep to what " + root.app.flavorInfo.name + " supports."
        bordered: true
        selected: root.onlySupported
        onClicked: root.onlySupported = !root.onlySupported
      }
    }

    Text {
      Layout.fillWidth: true
      text: root.app.flavorInfo.description + (root.app.flavorInfo.replace ? "  Replacements: " + Replace.SYNTAXES[root.app.flavorInfo.replace] + "." : "")
      color: root.dim
      wrapMode: Text.Wrap
      font.family: Style.font.family
      font.pixelSize: Style.font.caption
    }

    ListView {
      id: list
      Layout.fillWidth: true
      Layout.fillHeight: true
      clip: true
      model: root.entries
      spacing: Style.spacing.xs
      boundsBehavior: Flickable.StopAtBounds
      ScrollBar.vertical: ScrollBar {}
      section.property: "category"
      section.delegate: Text {
        required property string section
        topPadding: Style.spacing.lg
        bottomPadding: Style.spacing.sm
        text: section
        color: root.accent
        font.family: Style.font.family
        font.pixelSize: Style.font.subtitle
        font.bold: true
      }

      delegate: Rectangle {
        id: row
        required property var modelData
        width: list.width - Style.spacing.lg
        height: content.implicitHeight + Style.spacing.md * 2
        radius: Style.cornerRadius
        color: mouse.containsMouse ? Util.alpha(root.foreground, 0.05) : "transparent"
        opacity: modelData.supported ? 1 : 0.55

        MouseArea {
          id: mouse
          anchors.fill: parent
          hoverEnabled: true
          onClicked: root.tryEntry(row.modelData)
        }

        RowLayout {
          id: content
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.verticalCenter: parent.verticalCenter
          anchors.margins: Style.spacing.md
          spacing: Style.spacing.lg

          Text {
            Layout.preferredWidth: Math.min(Style.space(170), list.width * 0.22)
            text: row.modelData.syntax
            wrapMode: Text.WrapAnywhere
            color: root.accent
            font.family: Style.font.family
            font.pixelSize: Style.font.body
            textFormat: Text.PlainText
          }

          Text {
            Layout.fillWidth: true
            text: row.modelData.meaning + (row.modelData.supported ? "" : " — not in " + root.app.flavorInfo.name)
            color: root.foreground
            wrapMode: Text.Wrap
            font.family: Style.font.family
            font.pixelSize: Style.font.bodySmall
            textFormat: Text.PlainText
          }

          Text {
            Layout.preferredWidth: list.width * 0.3
            text: row.modelData.pattern + "  on  " + JSON.stringify(row.modelData.text)
            color: root.dim
            elide: Text.ElideRight
            font.family: Style.font.family
            font.pixelSize: Style.font.caption
            textFormat: Text.PlainText
          }
        }
      }
    }
  }
}
