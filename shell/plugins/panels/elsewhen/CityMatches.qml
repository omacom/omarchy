import QtQuick
import qs.Commons
import qs.Ui

// The matches for a CitySearch; hosts that overlay results place this themselves.
Column {
  id: list

  required property var citySearch

  spacing: Style.space(2)

  Repeater {
    model: list.citySearch.matches

    CursorSurface {
      id: match
      required property var modelData
      required property int index

      width: parent.width
      implicitHeight: Style.spacing.popupRowHeight
      foreground: list.citySearch.foreground
      hasCursor: list.citySearch.selectedIndex === index

      // The region is what tells Portland, Oregon from Portland, Maine; it
      // gives way first when the line is tight.
      Row {
        anchors.left: parent.left
        anchors.leftMargin: Style.spacing.xl
        anchors.right: matchZone.left
        anchors.rightMargin: Style.spacing.lg
        anchors.verticalCenter: parent.verticalCenter
        spacing: Style.spacing.md
        clip: true

        // Capped at its unelided width: an eliding Text's own implicitWidth
        // shrinks with it, which would make the cap circular.
        TextMetrics {
          id: matchNameMetrics
          font: matchName.font
          text: match.modelData.label
        }

        Text {
          id: matchName
          width: Math.min(Math.ceil(matchNameMetrics.advanceWidth) + 1, parent.width)
          textFormat: Text.PlainText
          text: match.modelData.label
          color: list.citySearch.foreground
          font.family: list.citySearch.fontFamily
          font.pixelSize: list.citySearch.fontSize
          elide: Text.ElideRight
        }

        Caption {
          anchors.baseline: matchName.baseline
          width: Math.max(0, parent.width - matchName.width - parent.spacing)
          text: match.modelData.region || ""
          visible: text !== ""
          color: list.citySearch.fainter
          elide: Text.ElideRight
        }
      }

      // Two cities in one zone differ by name, two zones with one name by
      // offset. A place's region already says where it is, so its zone stays off.
      Row {
        id: matchZone
        anchors.right: parent.right
        anchors.rightMargin: Style.spacing.xl
        anchors.verticalCenter: parent.verticalCenter
        spacing: Style.spacing.md

        Caption {
          text: match.modelData.value
          visible: !match.modelData.region
          color: list.citySearch.fainter
        }

        Caption {
          text: list.citySearch.offsetLabel(match.modelData.value)
          visible: text !== ""
        }
      }

      // Only movement moves the selection, so a resting pointer cannot
      // steal it from the arrow keys as the list rebuilds.
      MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onPositionChanged: list.citySearch.selectedIndex = match.index
        onClicked: list.citySearch.pick(match.modelData)
      }
    }
  }

  Caption {
    visible: list.citySearch.matches.length === 0
    width: parent.width
    horizontalAlignment: Text.AlignHCenter
    topPadding: Style.spacing.md
    text: list.citySearch.loading ? list.citySearch.loadingText
      : list.citySearch.searching ? I18n.t("elsewhen.searchingPlaces") : I18n.t("common.noMatches")
    color: list.citySearch.fainter
  }

  component Caption: Text {
    textFormat: Text.PlainText
    color: list.citySearch.dim
    font.family: list.citySearch.fontFamily
    font.pixelSize: Style.font.caption
  }
}
