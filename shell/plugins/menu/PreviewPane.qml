import Quickshell.Io
import QtQuick
import qs.Commons

Item {
  id: root

  property var descriptor: ({ kind: "" })
  property var appLibrary: null
  property color foreground: Color.menu.text
  property color background: Color.menu.background
  property string fontFamily: Style.font.menuFamily
  property string textBody: ""
  property int textRevision: 0

  readonly property bool imagePreview: descriptor && descriptor.kind === "image"
  readonly property bool textPreview: descriptor && descriptor.kind === "text"
  readonly property bool appPreview: descriptor && descriptor.kind === "app"

  function scheduleTextPreview() {
    textRevision += 1
    textBody = ""
    textDebounce.restart()
  }

  onDescriptorChanged: scheduleTextPreview()
  Component.onCompleted: scheduleTextPreview()

  Timer {
    id: textDebounce
    interval: 80
    repeat: false
    onTriggered: {
      if (!root.textPreview || !root.descriptor.target) return
      if (textLoader.running) {
        textLoader.running = false
        textDebounce.restart()
        return
      }
      textLoader.revision = root.textRevision
      textLoader.command = ["head", "-c", "12288", "--", root.descriptor.target]
      textLoader.running = true
    }
  }

  Process {
    id: textLoader
    property int revision: -1
    stdout: StdioCollector {
      id: textOutput
      waitForEnd: true
      onStreamFinished: {
        if (textLoader.revision === root.textRevision && root.textPreview)
          root.textBody = text
      }
    }
  }

  Rectangle {
    anchors.left: parent.left
    anchors.top: parent.top
    anchors.bottom: parent.bottom
    width: Style.spacing.hairline
    color: Util.alpha(root.foreground, 0.18)
  }

  Column {
    anchors.fill: parent
    anchors.leftMargin: Style.space(18)
    spacing: Style.space(12)
    clip: true

    Text {
      width: parent.width
      textFormat: Text.PlainText
      text: root.descriptor.resultKind === "agent-session" ? "CONVERSATION"
        : root.descriptor.resultKind === "project" ? "PROJECT"
        : root.descriptor.resultKind === "app" ? "APPLICATION"
        : "FILE"
      color: root.foreground
      opacity: 0.46
      font.family: root.fontFamily
      font.pixelSize: Style.font.caption
      font.letterSpacing: 1
    }

    Rectangle {
      width: parent.width
      height: root.appPreview ? Style.space(142)
        : Math.min(Style.space(210), Math.max(Style.space(110), root.height - Style.space(145)))
      radius: Style.cornerRadius
      color: Util.alpha(root.foreground, 0.045)
      clip: true

      Image {
        anchors.fill: parent
        anchors.margins: Style.space(10)
        visible: root.imagePreview || root.appPreview
        fillMode: Image.PreserveAspectFit
        asynchronous: true
        sourceSize.width: width * Screen.devicePixelRatio
        sourceSize.height: height * Screen.devicePixelRatio
        source: root.appPreview && root.appLibrary
          ? root.appLibrary.iconSource(root.descriptor.appIcon)
          : root.imagePreview ? Util.fileUrl(root.descriptor.target) : ""
      }

      Flickable {
        anchors.fill: parent
        anchors.margins: Style.space(12)
        visible: root.textPreview
        contentWidth: width
        contentHeight: previewText.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        Text {
          id: previewText
          width: parent.width
          textFormat: Text.PlainText
          text: root.textBody || "Loading preview…"
          color: root.foreground
          opacity: root.textBody ? 0.76 : 0.42
          font.family: "monospace"
          font.pixelSize: Style.font.caption
          wrapMode: Text.WrapAnywhere
        }
      }

      Text {
        anchors.centerIn: parent
        visible: !root.imagePreview && !root.textPreview && !root.appPreview
        textFormat: Text.PlainText
        text: root.descriptor.icon || (root.descriptor.resultKind === "project" ? "" : "󰚩")
        color: root.foreground
        opacity: 0.52
        font.family: root.descriptor.iconFont || root.fontFamily
        font.pixelSize: Style.space(54)
      }
    }

    Text {
      width: parent.width
      textFormat: Text.PlainText
      text: root.descriptor.title || ""
      color: root.foreground
      font.family: root.fontFamily
      font.pixelSize: Style.font.heading
      font.weight: Font.Medium
      elide: Text.ElideRight
    }

    Text {
      width: parent.width
      textFormat: Text.PlainText
      text: root.descriptor.subtitle || root.descriptor.target || ""
      color: root.foreground
      opacity: 0.56
      font.family: root.fontFamily
      font.pixelSize: Style.font.bodySmall
      wrapMode: Text.WrapAnywhere
      maximumLineCount: root.appPreview ? 2 : 4
      elide: Text.ElideRight
    }

    Text {
      width: parent.width
      visible: root.appPreview && Boolean(root.descriptor.summary)
      textFormat: Text.PlainText
      text: root.descriptor.summary || ""
      color: root.foreground
      opacity: 0.76
      font.family: root.fontFamily
      font.pixelSize: Style.font.bodySmall
      wrapMode: Text.WordWrap
      maximumLineCount: 3
      elide: Text.ElideRight
    }

    Column {
      width: parent.width
      visible: root.appPreview && root.descriptor.metadata && root.descriptor.metadata.length > 0
      spacing: Style.space(6)

      Repeater {
        model: root.descriptor.metadata || []

        Row {
          required property var modelData
          width: parent.width
          spacing: Style.space(8)

          Text {
            width: Style.space(82)
            textFormat: Text.PlainText
            text: modelData.label || ""
            color: root.foreground
            opacity: 0.42
            font.family: root.fontFamily
            font.pixelSize: Style.font.caption
          }

          Text {
            width: parent.width - Style.space(90)
            textFormat: Text.PlainText
            text: modelData.value || ""
            color: root.foreground
            opacity: 0.72
            font.family: root.fontFamily
            font.pixelSize: Style.font.caption
            elide: Text.ElideRight
          }
        }
      }
    }
  }
}
