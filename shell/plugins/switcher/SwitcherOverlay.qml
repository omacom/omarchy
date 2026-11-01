import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Commons as Commons
import qs.Ui
import "SwitcherModel.js" as SwitcherModel

// The switcher on the focused monitor: a card of live thumbnails, each with
// its app's icon and title above. The surface maps on the first Tab, before the
// card shows, so the keyboard leaves the app at once: an app that saw Alt go
// down and up with nothing between would take it for a tap of Alt and open its
// menu bar.
OverlayWindow {
  id: window

  required property var switcher

  shown: switcher.active
  WlrLayershell.namespace: "omarchy-switcher"

  // The menu's surface tokens, so themes that style the menu style this too.
  readonly property color background: Commons.Color.menu.background
  readonly property color foreground: Commons.Color.menu.text
  readonly property color selectedBackground: Commons.Color.menu.selectedBackground
  readonly property color selectedText: Commons.Color.menu.selectedText
  readonly property color selectedBorder: Commons.Color.accent
  readonly property var borderSpec: Border.surfaceSpec("menu", "border", Commons.Color.menu.border, Math.max(1, Style.space(2)))
  readonly property int cornerRadius: Style.cornerRadius
  readonly property int cardPadding: Style.spacing.panelPadding
  readonly property int itemPadding: Style.spacing.lg
  readonly property int itemGap: Style.spacing.md
  readonly property int iconSize: Math.max(Style.space(16), Style.font.heading)
  readonly property int headerHeight: Math.max(iconSize, Style.font.body * 1.4) + Style.spacing.md
  readonly property bool mirrored: Commons.I18n.rightToLeft

  readonly property var aspects: switcher.entries.map(function(entry) {
    var ipc = entry.toplevel ? entry.toplevel.lastIpcObject : null
    var size = ipc && ipc.size ? ipc.size : null
    return size && size[1] > 0 ? size[0] / size[1] : 16 / 9
  })

  readonly property var laidOut: SwitcherModel.layout(window.aspects, {
    maxWidth: Math.max(1, window.width * 0.9 - window.cardPadding * 2),
    maxHeight: Math.max(1, window.height * 0.85 - window.cardPadding * 2),
    thumbHeight: Math.round(window.height * 0.16),
    minThumbHeight: Style.space(48),
    minAspect: 0.6,
    maxAspect: 2.4,
    gap: window.itemGap,
    padding: window.itemPadding,
    header: window.headerHeight
  })

  onVisibleChanged: if (visible) keys.forceActiveFocus()

  Item {
    id: keys
    anchors.fill: parent
    focus: true

    Keys.onPressed: function(event) {
      var switcher = window.switcher
      // A key that comes without Alt held means Alt was let go and the release
      // never arrived, so the switch ends here the way letting go would have.
      if (!switcher.sticky && event.key !== Qt.Key_Alt && !(event.modifiers & Qt.AltModifier)) {
        if (event.key === Qt.Key_Escape) switcher.cancel()
        else switcher.commit()
        event.accepted = true
        return
      }
      var forward = window.mirrored ? Qt.Key_Left : Qt.Key_Right
      var back = window.mirrored ? Qt.Key_Right : Qt.Key_Left
      if (event.key === forward || event.key === Qt.Key_Tab) {
        switcher.step(1)
      } else if (event.key === back || event.key === Qt.Key_Backtab) {
        switcher.step(-1)
      } else if (event.key === Qt.Key_Down || event.key === Qt.Key_Up) {
        switcher.select(SwitcherModel.rowNeighbor(window.laidOut, switcher.selected, event.key === Qt.Key_Down ? 1 : -1))
      } else if (event.key === Qt.Key_Home) {
        switcher.select(0)
      } else if (event.key === Qt.Key_End) {
        switcher.select(switcher.entries.length - 1)
      } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
        switcher.commit()
      } else if (event.key === Qt.Key_Escape) {
        switcher.cancel()
      } else if (event.key === Qt.Key_Delete) {
        switcher.closeEntry(switcher.selected)
      }
      event.accepted = true
    }

    // Hyprland's switcher.alt shortcut ends the switch when Alt is let go;
    // this catches it too should that binding be missing.
    Keys.onReleased: function(event) {
      if (event.key === Qt.Key_Alt && !window.switcher.sticky) window.switcher.commit()
      event.accepted = true
    }
  }

  // A click beside the card stays put, as on Windows.
  MouseArea {
    anchors.fill: parent
    enabled: window.switcher.revealed
    onClicked: window.switcher.cancel()
  }

  BorderSurface {
    id: card
    visible: window.switcher.revealed
    anchors.centerIn: parent
    width: window.laidOut.width + window.cardPadding * 2
    height: window.laidOut.height + window.cardPadding * 2
    radius: window.cornerRadius
    color: window.background
    borderSpec: window.borderSpec
    padding: window.cardPadding

    // Clicks between thumbnails stay on the card.
    MouseArea { anchors.fill: parent }

    // Rows that do not fit scroll, following the pick, with no motion: the
    // switcher is up for a moment and the keys step fast.
    Flickable {
      id: rows
      x: card.contentLeftInset
      y: card.contentTopInset
      width: window.laidOut.width
      height: window.laidOut.height
      contentWidth: width
      contentHeight: window.laidOut.contentHeight
      boundsBehavior: Flickable.StopAtBounds
      clip: true

      function follow() {
        contentY = SwitcherModel.scrollFor(window.laidOut, window.switcher.selected, contentY)
      }

      Connections {
        target: window.switcher
        function onSelectedChanged() { rows.follow() }
      }

      Connections {
        target: window
        function onLaidOutChanged() { rows.follow() }
      }

      Item {
        id: grid
        width: window.laidOut.width
        height: window.laidOut.contentHeight

        Repeater {
          model: window.switcher.entries

          delegate: Item {
            id: item

            required property var modelData
            required property int index

            readonly property var place: window.laidOut.items[index] || ({ x: 0, y: 0, width: 0, height: 0 })
            readonly property bool selected: index === window.switcher.selected
            readonly property var toplevel: modelData.toplevel
            readonly property real aspect: preview.hasContent && preview.sourceSize.height > 0
              ? preview.sourceSize.width / preview.sourceSize.height
              : window.aspects[index] || 16 / 9

            x: window.mirrored ? grid.width - place.x - place.width : place.x
            y: place.y
            width: place.width
            height: place.height

            Rectangle {
              anchors.fill: parent
              radius: window.cornerRadius
              color: item.selected ? window.selectedBackground : (hover.containsMouse || closeArea.containsMouse ? Style.hoverFill : "transparent")
              border.width: item.selected ? Math.max(1, Style.space(2)) : 0
              border.color: window.selectedBorder
            }

            // The title leaves room for the close button, which shows on hover.
            Row {
              id: header
              anchors.left: parent.left
              anchors.right: closeButton.left
              anchors.top: parent.top
              anchors.leftMargin: window.itemPadding
              anchors.rightMargin: Style.spacing.md
              anchors.topMargin: window.itemPadding
              height: window.headerHeight - Style.spacing.md
              spacing: Style.spacing.md

              Image {
                width: window.iconSize
                height: window.iconSize
                anchors.verticalCenter: parent.verticalCenter
                source: window.switcher.iconFor(item.modelData)
                sourceSize: Qt.size(width, height)
                asynchronous: true
                smooth: true
              }

              Text {
                width: parent.width - window.iconSize - parent.spacing
                anchors.verticalCenter: parent.verticalCenter
                text: item.toplevel ? item.toplevel.title : ""
                textFormat: Text.PlainText
                color: item.selected ? window.selectedText : window.foreground
                font.family: Style.font.menuFamily
                font.pixelSize: Style.font.body
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignLeft
              }
            }

            Item {
              id: thumbArea
              x: window.itemPadding
              y: window.itemPadding + window.headerHeight
              width: parent.width - window.itemPadding * 2
              height: parent.height - window.itemPadding * 2 - window.headerHeight

              ScreencopyView {
                id: preview
                anchors.centerIn: parent
                width: Math.min(parent.width, parent.height * item.aspect)
                height: Math.min(parent.height, parent.width / item.aspect)
                captureSource: item.toplevel ? item.toplevel.wayland : null
                live: true
              }

              // A window with nothing to capture yet shows its app's icon.
              Image {
                anchors.centerIn: parent
                visible: !preview.hasContent
                width: Math.min(parent.width, parent.height) * 0.5
                height: width
                source: window.switcher.iconFor(item.modelData)
                sourceSize: Qt.size(width, height)
                asynchronous: true
                smooth: true
              }
            }

            // Hovering marks a thumbnail without moving the pick, so a pointer
            // resting where the switcher opens never fights the keys.
            MouseArea {
              id: hover
              anchors.fill: parent
              hoverEnabled: true
              onClicked: {
                window.switcher.select(item.index)
                window.switcher.commit()
              }
            }

            Rectangle {
              id: closeButton
              visible: hover.containsMouse || closeArea.containsMouse
              anchors.top: parent.top
              anchors.right: parent.right
              anchors.margins: window.itemPadding - Style.spacing.xs
              width: window.headerHeight - Style.spacing.xs
              height: width
              radius: window.cornerRadius
              color: closeArea.containsMouse ? Commons.Color.urgent : "transparent"

              Text {
                anchors.centerIn: parent
                text: "×"
                textFormat: Text.PlainText
                color: closeArea.containsMouse ? Commons.Color.background : window.foreground
                font.family: Style.font.menuFamily
                font.pixelSize: Style.font.heading
              }

              MouseArea {
                id: closeArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: window.switcher.closeEntry(item.index)
              }
            }
          }
        }
      }
    }
  }
}
