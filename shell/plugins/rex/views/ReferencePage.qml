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
        text: Commons.I18n.t("rex.reference")
        textFormat: Text.PlainText
        color: root.foreground
        font.family: Style.font.family
        font.pixelSize: Style.font.heading
        font.bold: true
      }

      Text {
        text: root.app.flavorInfo.name
        textFormat: Text.PlainText
        color: root.dim
        font.family: Style.font.family
        font.pixelSize: Style.font.caption
      }

      TextField {
        id: search
        Layout.fillWidth: true
        placeholderText: Commons.I18n.t("rex.searchReference")
      }

      Button {
        text: root.onlySupported ? Commons.I18n.t("rex.onlyFlavor").arg(root.app.flavorInfo.short) : Commons.I18n.t("rex.everything")
        tooltipText: (root.onlySupported ? Commons.I18n.t("rex.showingSupported") : Commons.I18n.t("rex.showingEverything")).arg(root.app.flavorInfo.name)
        bordered: true
        selected: root.onlySupported
        onClicked: root.onlySupported = !root.onlySupported
      }
    }

    Text {
      Layout.fillWidth: true
      text: root.app.flavorInfo.description + (root.app.flavorInfo.replace ? "  " + Commons.I18n.t("rex.replacementSyntax").arg(Replace.SYNTAXES[root.app.flavorInfo.replace]) : "")
      textFormat: Text.PlainText
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
        textFormat: Text.PlainText
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
            // The meaning fills the last hole: it can hold a %-hole itself.
            text: row.modelData.supported ? row.modelData.meaning : Commons.I18n.t("rex.notInFlavor").arg(root.app.flavorInfo.name).arg(row.modelData.meaning)
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
