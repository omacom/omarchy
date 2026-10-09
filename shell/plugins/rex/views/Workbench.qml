import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
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

  function focusPattern() { patternField.focusEditor() }

  function localPath(url) {
    return decodeURIComponent(String(url).replace(/^file:\/\//, ""))
  }

  function sizeText(chars) {
    if (chars < 1024) return chars + " characters"
    if (chars < 1048576) return (chars / 1024).toFixed(0) + "K characters"
    return (chars / 1048576).toFixed(1) + "M characters"
  }

  FileDialog {
    id: fileDialog
    title: "Open a text to search"
    onAccepted: root.app.openFile(root.localPath(selectedFile))
  }

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
            text: modelData.id
            tooltipText: modelData.label + ": " + modelData.description
            bordered: true
            selected: root.app.flags.indexOf(modelData.id) >= 0
            onClicked: root.app.toggleFlag(modelData.id)
          }
        }

        Button {
          text: root.app.all ? "all" : "first"
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
        textFormat: Text.PlainText
        color: root.app.result.ok === false ? Commons.Color.urgent : root.dim
        font.family: Style.font.family
        font.pixelSize: Style.font.caption
      }
    }

    // ---- pattern ----
    PatternEditor {
      id: patternField
      Layout.fillWidth: true
      foreground: root.foreground
      accent: root.accent
      text: root.app.pattern
      tokens: root.app.patternTokens
      errors: root.app.parsed.errors
      groupColors: root.app.groupColors
      kindColors: root.app.kindColors
      highlight: root.app.patternHighlight
      multiline: root.app.flags.indexOf("x") >= 0
      onEdited: function(value) { root.app.pattern = value }
      onCursorPositionChanged: root.app.patternCursor = cursorPosition
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

      ColumnLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: Style.spacing.lg

        // ---- the text's source ----
        RowLayout {
          Layout.fillWidth: true
          spacing: Style.spacing.md

          Text {
            Layout.fillWidth: true
            text: root.app.textFile !== ""
              ? root.app.textFile + " · " + root.sizeText(root.app.testText.length) + (root.app.largeText ? " · read-only" : "")
              : (root.app.largeText ? root.sizeText(root.app.testText.length) + " · read-only" : "Test text")
            color: root.dim
            elide: Text.ElideMiddle
            font.family: Style.font.family
            font.pixelSize: Style.font.caption
            textFormat: Text.PlainText
          }

          Text {
            visible: root.app.textFileError !== ""
            text: root.app.textFileError
            textFormat: Text.PlainText
            color: Commons.Color.urgent
            font.family: Style.font.family
            font.pixelSize: Style.font.caption
          }

          Button {
            text: "Open file…"
            tooltipText: "Search a file; large files open read-only. You can also drop a file here."
            bordered: true
            onClicked: fileDialog.open()
          }

          Button {
            visible: root.app.textFile !== "" || root.app.largeText
            iconText: "󰅖"
            tooltipText: "Close the text"
            onClicked: root.app.closeFile()
          }
        }

        Item {
          Layout.fillWidth: true
          Layout.fillHeight: true

          TestEditor {
            id: editor
            anchors.fill: parent
            visible: !root.app.largeText
            foreground: root.foreground
            accent: root.accent
            text: root.app.largeText ? "" : root.app.testText
            matches: root.app.largeText ? [] : root.app.result.matches
            stride: root.app.result.stride
            count: root.app.largeText ? 0 : root.app.result.count
            groupColors: root.app.groupColors
            selectedMatch: root.app.selectedMatch
            onEdited: function(value) { root.app.setTypedText(value) }
          }

          Loader {
            id: largeLoader
            anchors.fill: parent
            active: root.app.largeText
            sourceComponent: LargeTextView {
              foreground: root.foreground
              accent: root.accent
              text: root.app.testText
              matches: root.app.result.matches
              stride: root.app.result.stride
              count: root.app.result.count
              groupColors: root.app.groupColors
              selectedMatch: root.app.selectedMatch
            }
          }

          DropArea {
            anchors.fill: parent
            onDropped: function(drop) {
              if (drop.hasUrls && drop.urls.length) root.app.openFile(root.localPath(drop.urls[0]))
            }
          }
        }

        ToolPanel {
          Layout.fillWidth: true
          // A layout fills by default; the editor gets whatever is left.
          Layout.fillHeight: false
          Layout.preferredHeight: root.app.tool === "" ? implicitHeight : root.height * 0.38
          Layout.maximumHeight: Layout.preferredHeight
          app: root.app
        }
      }

      ColumnLayout {
        Layout.preferredWidth: Math.max(Style.space(320), root.width * 0.34)
        Layout.fillWidth: false
        Layout.fillHeight: true
        spacing: Style.spacing.lg

        ButtonGroup {
          options: [
            { value: "matches", label: "Matches" },
            { value: "explain", label: "Explain" },
            { value: "optimize", label: root.app.findings.length ? "Optimize (" + root.app.findings.length + ")" : "Optimize" },
            { value: "tests", label: root.app.tests.length ? "Tests " + root.app.testsPassed + "/" + root.app.tests.length : "Tests" },
          ]
          value: root.app.sideTab
          onChanged: function(value) { root.app.sideTab = value }
        }

          MatchList {
            id: matchList
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: root.app.sideTab === "matches"
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
              if (root.app.largeText) largeLoader.item.selectMatch(index)
              else editor.selectMatch(index)
            }
          }

        TestsPanel {
          Layout.fillWidth: true
          Layout.fillHeight: true
          visible: root.app.sideTab === "tests"
          app: root.app
        }

        OptimizePanel {
          Layout.fillWidth: true
          Layout.fillHeight: true
          visible: root.app.sideTab === "optimize"
          app: root.app
        }

        ExplainPanel {
          Layout.fillWidth: true
          Layout.fillHeight: true
          visible: root.app.sideTab === "explain"
          foreground: root.foreground
          accent: root.accent
          rows: root.app.explainRows
          groupColors: root.app.groupColors
          kindColors: root.app.kindColors
          cursor: root.app.patternCursor
          onHovered: function(start, end) { root.app.patternHighlight = start < 0 ? [] : [start, end] }
          onPicked: function(start, end) { patternField.select(start, end) }
        }
      }
    }
  }
}
