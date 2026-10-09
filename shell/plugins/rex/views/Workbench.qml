import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Commons
import qs.Ui

// The main editing surface: the pattern on top, the test text below.
Item {
  id: root

  property color foreground
  property color background
  property color accent
  readonly property color dim: Qt.darker(foreground, 1.5)

  property string pattern: ""
  property string testText: ""

  signal patternEdited(string value)
  signal testTextEdited(string value)

  function focusPattern() { patternField.forceActiveFocus() }

  ColumnLayout {
    anchors.fill: parent
    anchors.margins: Style.spacing.panelPadding
    spacing: Style.spacing.panelGap

    Text {
      text: "Regular expression"
      color: root.dim
      font.family: Style.font.family
      font.pixelSize: Style.font.caption
    }

    TextField {
      id: patternField
      Layout.fillWidth: true
      foreground: root.foreground
      accent: root.accent
      font.pixelSize: Style.font.title
      placeholderText: "Type a pattern"
      text: root.pattern
      onTextEdited: root.patternEdited(text)
    }

    Text {
      text: "Test text"
      color: root.dim
      font.family: Style.font.family
      font.pixelSize: Style.font.caption
    }

    Rectangle {
      Layout.fillWidth: true
      Layout.fillHeight: true
      color: Util.alpha(root.foreground, 0.03)
      border.width: 1
      border.color: Util.alpha(root.foreground, 0.08)
      radius: Style.cornerRadius

      Flickable {
        id: flick
        anchors.fill: parent
        anchors.margins: Style.spacing.lg
        contentWidth: width
        contentHeight: editor.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        ScrollBar.vertical: ScrollBar {}

        TextEdit {
          id: editor
          width: flick.width
          wrapMode: TextEdit.WrapAnywhere
          color: root.foreground
          selectionColor: Util.alpha(root.accent, 0.35)
          selectedTextColor: root.foreground
          font.family: Style.font.family
          font.pixelSize: Style.font.subtitle
          textFormat: TextEdit.PlainText
          selectByMouse: true
          persistentSelection: true
          text: root.testText
          onTextChanged: if (text !== root.testText) root.testTextEdited(text)
          onCursorRectangleChanged: {
            if (cursorRectangle.y < flick.contentY) flick.contentY = cursorRectangle.y
            else if (cursorRectangle.y + cursorRectangle.height > flick.contentY + flick.height)
              flick.contentY = cursorRectangle.y + cursorRectangle.height - flick.height
          }
        }
      }
    }
  }
}
