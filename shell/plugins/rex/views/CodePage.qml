import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Ui
import "../lib/Flavors.js" as Flavors
import "../lib/Codegen.js" as Codegen

// The workbench's pattern as code: testing, finding every match, replacing
// and splitting, in the language of the flavor, with the pattern quoted so
// it arrives intact.
Item {
  id: root

  property var app

  readonly property color foreground: app.foreground
  readonly property color accent: app.accent
  readonly property color dim: Qt.darker(foreground, 1.5)

  property string target: app.flavor
  readonly property var targetFlags: Flavors.validFlags(target, app.flags)
  readonly property var snippets: Codegen.snippets(target, app.pattern, targetFlags, app.replacement)
  property int copied: -1

  Timer { id: copiedTimer; interval: 1500; onTriggered: root.copied = -1 }

  ColumnLayout {
    anchors.fill: parent
    anchors.margins: Style.spacing.panelPadding
    spacing: Style.spacing.lg

    RowLayout {
      Layout.fillWidth: true
      spacing: Style.spacing.lg

      Text {
        text: "Code"
        color: root.foreground
        font.family: Style.font.family
        font.pixelSize: Style.font.heading
        font.bold: true
      }

      Text {
        Layout.fillWidth: true
        text: Flavors.byId(root.target).language
        color: root.dim
        elide: Text.ElideRight
        font.family: Style.font.family
        font.pixelSize: Style.font.caption
      }

      Dropdown {
        Layout.preferredWidth: Style.space(220)
        showLabel: false
        value: root.target
        options: Flavors.FLAVORS.map(function(f) { return { value: f.id, label: f.name } })
        onChanged: function(value) { root.target = value }
      }
    }

    Text {
      Layout.fillWidth: true
      visible: root.target !== root.app.flavor
      text: "The workbench uses " + root.app.flavorInfo.name + "; " + Flavors.byId(root.target).name + " may read the pattern differently. Compare flavors shows how."
      color: root.dim
      wrapMode: Text.Wrap
      font.family: Style.font.family
      font.pixelSize: Style.font.caption
    }

    Text {
      visible: root.app.pattern === ""
      text: "Type a pattern on the workbench first."
      color: root.dim
      font.family: Style.font.family
      font.pixelSize: Style.font.body
    }

    ListView {
      id: list
      Layout.fillWidth: true
      Layout.fillHeight: true
      visible: root.app.pattern !== ""
      clip: true
      model: root.snippets
      spacing: Style.spacing.lg
      boundsBehavior: Flickable.StopAtBounds
      ScrollBar.vertical: ScrollBar {}

      delegate: Rectangle {
        id: card
        required property int index
        required property var modelData
        width: list.width - Style.spacing.lg
        height: content.implicitHeight + Style.spacing.lg * 2
        radius: Style.cornerRadius
        color: Util.alpha(root.foreground, 0.03)
        border.width: 1
        border.color: Util.alpha(root.foreground, 0.08)

        ColumnLayout {
          id: content
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.top: parent.top
          anchors.margins: Style.spacing.lg
          spacing: Style.spacing.md

          RowLayout {
            Layout.fillWidth: true
            spacing: Style.spacing.md

            Text {
              Layout.fillWidth: true
              text: card.modelData.title
              color: root.foreground
              font.family: Style.font.family
              font.pixelSize: Style.font.body
              font.bold: true
            }

            Text {
              text: card.modelData.language
              color: root.dim
              font.family: Style.font.family
              font.pixelSize: Style.font.caption
            }

            Button {
              text: root.copied === card.index ? "Copied" : "Copy"
              bordered: true
              onClicked: {
                Quickshell.execDetached(["wl-copy", "--", card.modelData.code])
                root.copied = card.index
                copiedTimer.restart()
              }
            }
          }

          TextEdit {
            Layout.fillWidth: true
            readOnly: true
            selectByMouse: true
            wrapMode: TextEdit.WrapAnywhere
            textFormat: TextEdit.PlainText
            color: root.foreground
            selectionColor: Util.alpha(root.foreground, 0.25)
            font.family: Style.font.family
            font.pixelSize: Style.font.bodySmall
            text: card.modelData.code
          }
        }
      }
    }
  }
}
