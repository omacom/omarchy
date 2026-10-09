import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Commons
import qs.Commons as Commons
import qs.Ui
import "../lib/Flavors.js" as Flavors
import "../lib/Store.js" as Store

// Saved patterns, each with its flavor, flags, test text, replacement and
// tests, and the patterns used recently.
Item {
  id: root

  property var app

  readonly property color foreground: app.foreground
  readonly property color accent: app.accent
  readonly property color dim: Qt.darker(foreground, 1.5)

  readonly property var saved: Store.search(app.library, search.text)
  property string confirmDelete: ""

  function age(time) {
    var minutes = Math.floor((Date.now() - time) / 60000)
    if (minutes < 1) return "just now"
    if (minutes < 60) return minutes + " min ago"
    if (minutes < 1440) return Math.floor(minutes / 60) + " h ago"
    return Math.floor(minutes / 1440) + " d ago"
  }

  ColumnLayout {
    anchors.fill: parent
    anchors.margins: Style.spacing.panelPadding
    spacing: Style.spacing.lg

    RowLayout {
      Layout.fillWidth: true
      spacing: Style.spacing.lg

      Text {
        text: "Library"
        color: root.foreground
        font.family: Style.font.family
        font.pixelSize: Style.font.heading
        font.bold: true
      }

      TextField {
        id: search
        Layout.fillWidth: true
        placeholderText: "Search saved patterns"
      }
    }

    // ---- saving the workbench ----
    RowLayout {
      Layout.fillWidth: true
      spacing: Style.spacing.md

      TextField {
        id: saveName
        Layout.fillWidth: true
        placeholderText: "Name for the workbench's pattern"
        onAccepted: saveButton.save()
      }

      Button {
        id: saveButton
        text: "Save"
        tooltipText: "Save the pattern with its flavor, flags, test text, replacement and tests. A name already in use is replaced."
        bordered: true
        enabled: root.app.pattern !== ""
        function save() {
          if (!enabled) return
          root.app.saveToLibrary(saveName.text)
          saveName.text = ""
        }
        onClicked: save()
      }
    }

    RowLayout {
      Layout.fillWidth: true
      Layout.fillHeight: true
      spacing: Style.spacing.panelGap

      // ---- saved ----
      ListView {
        id: savedList
        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true
        model: root.saved
        spacing: Style.spacing.sm
        boundsBehavior: Flickable.StopAtBounds
        ScrollBar.vertical: ScrollBar {}

        delegate: Rectangle {
          id: card
          required property var modelData
          width: savedList.width - Style.spacing.lg
          height: content.implicitHeight + Style.spacing.md * 2
          radius: Style.cornerRadius
          color: mouse.containsMouse ? Util.alpha(root.foreground, 0.06) : Util.alpha(root.foreground, 0.03)

          MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
            onClicked: root.app.openSaved(card.modelData)
          }

          RowLayout {
            id: content
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: Style.spacing.md
            spacing: Style.spacing.md

            ColumnLayout {
              Layout.fillWidth: true
              spacing: Style.spacing.xxs

              Text {
                Layout.fillWidth: true
                text: card.modelData.name
                color: root.foreground
                elide: Text.ElideRight
                font.family: Style.font.family
                font.pixelSize: Style.font.body
                font.bold: true
                textFormat: Text.PlainText
              }

              Text {
                Layout.fillWidth: true
                text: card.modelData.pattern
                color: root.accent
                elide: Text.ElideRight
                font.family: Style.font.family
                font.pixelSize: Style.font.bodySmall
                textFormat: Text.PlainText
              }

              Text {
                Layout.fillWidth: true
                text: Flavors.byId(card.modelData.flavor).name + (card.modelData.flags.length ? " · " + card.modelData.flags.join("") : "")
                  + (card.modelData.tests.length ? " · " + card.modelData.tests.length + " tests" : "")
                  + " · " + root.age(card.modelData.updated)
                color: root.dim
                elide: Text.ElideRight
                font.family: Style.font.family
                font.pixelSize: Style.font.caption
              }
            }

            Button {
              text: root.confirmDelete === card.modelData.id ? "Delete?" : ""
              iconText: root.confirmDelete === card.modelData.id ? "" : "󰆴"
              tooltipText: "Delete from the library"
              bordered: root.confirmDelete === card.modelData.id
              onClicked: {
                if (root.confirmDelete === card.modelData.id) {
                  root.app.removeFromLibrary(card.modelData.id)
                  root.confirmDelete = ""
                } else {
                  root.confirmDelete = card.modelData.id
                }
              }
            }
          }
        }

        Text {
          anchors.centerIn: parent
          width: parent.width - Style.spacing.xxl * 2
          horizontalAlignment: Text.AlignHCenter
          visible: root.saved.length === 0
          text: root.app.library.length ? "Nothing saved matches" : "Saved patterns appear here, with everything needed to pick them up again."
          color: root.dim
          wrapMode: Text.Wrap
          font.family: Style.font.family
          font.pixelSize: Style.font.body
        }
      }

      // ---- recent ----
      ColumnLayout {
        Layout.preferredWidth: Math.max(Style.space(260), root.width * 0.3)
        Layout.fillWidth: false
        Layout.fillHeight: true
        spacing: Style.spacing.md

        Text {
          text: "Recent"
          color: root.accent
          font.family: Style.font.family
          font.pixelSize: Style.font.subtitle
          font.bold: true
        }

        ListView {
          id: recent
          Layout.fillWidth: true
          Layout.fillHeight: true
          clip: true
          model: root.app.history
          spacing: Style.spacing.xxs
          boundsBehavior: Flickable.StopAtBounds
          ScrollBar.vertical: ScrollBar {}

          delegate: Rectangle {
            id: item
            required property var modelData
            width: recent.width - Style.spacing.lg
            height: line.implicitHeight + Style.spacing.sm * 2
            radius: Style.cornerRadius
            color: recentMouse.containsMouse ? Util.alpha(root.foreground, 0.06) : "transparent"

            MouseArea {
              id: recentMouse
              anchors.fill: parent
              hoverEnabled: true
              onClicked: {
                root.app.setFlavor(item.modelData.flavor)
                root.app.flags = Flavors.validFlags(item.modelData.flavor, item.modelData.flags)
                root.app.pattern = item.modelData.pattern
                root.app.showPage("workbench")
              }
            }

            Text {
              id: line
              anchors.left: parent.left
              anchors.right: parent.right
              anchors.verticalCenter: parent.verticalCenter
              anchors.margins: Style.spacing.sm
              text: item.modelData.pattern
              color: root.foreground
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
}
