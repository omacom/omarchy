import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import qs.Commons
import qs.Commons as Commons
import qs.Ui

Item {
  id: root

  property string omarchyPath: Quickshell.env("OMARCHY_PATH")
  property var shell: null
  property var manifest: null

  property bool opened: false
  property var groups: []
  // The chip the user has selected, and the group whose notes are on screen.
  // They differ only while a switch is waiting to be committed.
  property int currentIndex: 0
  property int renderedIndex: -1
  property bool linkHovered: false
  property bool loading: false
  property string statusText: ""

  readonly property var renderedGroup: renderedIndex >= 0 && renderedIndex < groups.length ? groups[renderedIndex] : []

  property color background: Commons.Color.menu.background
  property color foreground: Commons.Color.menu.text
  property color border: Commons.Color.menu.border
  property var borderSpec: Border.surfaceSpec("menu", "border", border, Math.max(1, Style.space(2)))
  property color scrim: Commons.Color.menu.scrim
  property color selectedBackground: Commons.Color.menu.selectedBackground
  property color selectedText: Commons.Color.menu.selectedText
  readonly property int cornerRadius: Style.cornerRadius
  property string fontFamily: Style.font.menuFamily
  property int contentMargin: Style.spacing.panelPadding
  property int headerHeight: Math.max(Style.space(34), Style.font.title + Style.spacing.controlPaddingY * 2)
  property int contentSpacing: Style.spacing.md
  property int cardWidth: Math.min(Style.space(980), panel.width - Style.gapsOut * 2)
  property int cardHeight: Math.min(Style.space(760), panel.height - Style.gapsOut * 2)
  readonly property int lineStep: Math.max(18, Style.font.body + Style.space(2))

  // Laying out a version's notes is the expensive part, and holding an arrow
  // key would otherwise lay out every version it passes. The chip follows the
  // key at once; the notes follow once the selection has settled.
  Timer {
    id: renderTimer
    interval: 120
    onTriggered: root.renderSelected()
  }

  function open(payloadJson) {
    root.opened = true
    root.groups = []
    root.currentIndex = 0
    root.renderedIndex = -1
    root.loading = true
    root.statusText = ""
    fetchProc.running = true
    Qt.callLater(function() { keyCatcher.forceActiveFocus() })
  }

  function close() {
    renderTimer.stop()
    root.opened = false
  }

  function dismiss() {
    root.close()
    if (root.shell && typeof root.shell.hide === "function")
      root.shell.hide((root.manifest && root.manifest.id) || "omarchy.changelog")
  }

  function toggle() {
    if (root.opened) root.dismiss()
    else root.open("{}")
  }

  function selectVersion(index) {
    if (index < 0 || index >= root.groups.length) return
    root.currentIndex = index
    versionScroller.positionViewAtIndex(index, ListView.Contain)
    renderTimer.restart()
  }

  function switchVersion(delta) {
    if (root.groups.length === 0) return
    root.selectVersion((root.currentIndex + delta + root.groups.length) % root.groups.length)
  }

  function renderSelected() {
    if (root.renderedIndex === root.currentIndex) return
    root.linkHovered = false
    root.renderedIndex = root.currentIndex
    contentFlick.contentY = 0
  }

  function versionLabel(group) {
    var first = group && group.length ? group[0] : null
    return first ? "v" + first.major + "." + first.minor : ""
  }

  function formatDate(value) {
    if (!value) return ""
    var date = new Date(value)
    if (isNaN(date.getTime())) return String(value)
    return date.toLocaleDateString()
  }

  function releaseMarkdown(release) {
    var date = root.formatDate(release.date)
    var heading = "## " + (release.tag || "") + (date ? " — " + date : "")
    return heading + "\n\n" + String(release.body || "")
  }

  function scrollBy(delta) {
    var maxScroll = Math.max(0, contentFlick.contentHeight - contentFlick.height)
    contentFlick.contentY = Math.max(0, Math.min(maxScroll, contentFlick.contentY + delta))
  }

  function finishFetch(text) {
    root.loading = false
    var parsed = null
    try {
      parsed = JSON.parse(text || "")
    } catch (e) {
      parsed = null
    }
    if (!Array.isArray(parsed) || parsed.length === 0) {
      root.statusText = "Could not load the Omarchy changelog."
      return
    }
    root.statusText = ""
    root.groups = parsed
    root.currentIndex = 0
    root.renderSelected()
    versionScroller.positionViewAtBeginning()
  }

  Process {
    id: fetchProc
    command: [root.omarchyPath + "/bin/omarchy-changelog", "--data"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.finishFetch(text)
    }
    onExited: function(code) {
      if (code !== 0 && root.loading) {
        root.loading = false
        root.statusText = "Could not load the Omarchy changelog."
      }
    }
  }

  OverlayWindow {
    id: panel
    shown: root.opened
    WlrLayershell.namespace: "omarchy-changelog"

    Rectangle {
      anchors.fill: parent
      color: root.scrim
    }

    MouseArea {
      anchors.fill: parent
      onClicked: root.dismiss()
    }

    BorderSurface {
      id: card
      width: root.cardWidth
      height: root.cardHeight
      radius: root.cornerRadius
      anchors.centerIn: parent
      color: root.background
      borderSpec: root.borderSpec
      padding: root.contentMargin

      MouseArea { anchors.fill: parent; onClicked: {} }

      Item {
        id: keyCatcher
        anchors.fill: parent
        focus: true

        Keys.priority: Keys.BeforeItem
        Keys.onPressed: function(event) {
          var key = Util.readingKey(event)
          var handled = true

          if (event.key === Qt.Key_Escape || event.text === "q")
            root.dismiss()
          else if (key === Qt.Key_Left || event.text === "h")
            root.switchVersion(-1)
          else if (key === Qt.Key_Right || event.text === "l")
            root.switchVersion(1)
          else if (event.text === "j" || event.key === Qt.Key_Down)
            root.scrollBy(root.lineStep)
          else if (event.text === "k" || event.key === Qt.Key_Up)
            root.scrollBy(-root.lineStep)
          else if (event.text === "d")
            root.scrollBy(contentFlick.height / 2)
          else if (event.text === "u")
            root.scrollBy(-contentFlick.height / 2)
          else if (event.text === " " || event.key === Qt.Key_PageDown)
            root.scrollBy(contentFlick.height)
          else if (event.text === "b" || event.key === Qt.Key_PageUp)
            root.scrollBy(-contentFlick.height)
          else if (event.text === "g" || event.key === Qt.Key_Home)
            contentFlick.contentY = 0
          else if (event.text === "G" || event.key === Qt.Key_End)
            root.scrollBy(contentFlick.contentHeight)
          else
            handled = false

          event.accepted = handled
        }
      }

      Column {
        anchors.fill: parent
        anchors.topMargin: card.contentTopInset
        anchors.rightMargin: card.contentRightInset
        anchors.bottomMargin: card.contentBottomInset
        anchors.leftMargin: card.contentLeftInset
        spacing: root.contentSpacing

        Item {
          width: parent.width
          height: root.headerHeight

          Text {
            id: titleLabel
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            textFormat: Text.PlainText
            text: "Changelog"
            color: root.foreground
            font.family: root.fontFamily
            font.pixelSize: Style.font.title
            font.bold: true
          }

          Text {
            id: countLabel
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            textFormat: Text.PlainText
            text: root.loading ? "Loading…" : (root.groups.length > 0 ? root.groups.length + " versions" : "")
            color: root.foreground
            font.family: root.fontFamily
            font.pixelSize: Style.font.caption
            opacity: 0.7
          }

          ListView {
            id: versionScroller
            anchors.left: titleLabel.right
            anchors.right: countLabel.left
            anchors.leftMargin: root.contentSpacing
            anchors.rightMargin: root.contentSpacing
            anchors.verticalCenter: parent.verticalCenter
            height: Math.min(parent.height, Style.space(30))
            orientation: ListView.Horizontal
            spacing: Style.space(6)
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            model: root.groups

            delegate: Rectangle {
              required property int index
              required property var modelData

              readonly property bool selected: index === root.currentIndex

              width: chipLabel.implicitWidth + Style.space(16)
              height: ListView.view.height
              radius: Style.cornerRadius
              color: selected ? root.selectedBackground : Qt.rgba(root.border.r, root.border.g, root.border.b, 0.25)

              Text {
                id: chipLabel
                anchors.centerIn: parent
                textFormat: Text.PlainText
                text: root.versionLabel(modelData)
                color: parent.selected ? root.selectedText : root.foreground
                font.family: root.fontFamily
                font.pixelSize: Style.font.caption
              }

              MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.selectVersion(index)
              }
            }
          }
        }

        Item {
          width: parent.width
          height: parent.height - root.headerHeight - root.contentSpacing

          Text {
            anchors.centerIn: parent
            visible: root.loading || root.statusText !== ""
            textFormat: Text.PlainText
            text: root.loading ? "Loading changelog…" : root.statusText
            color: root.foreground
            font.family: root.fontFamily
            font.pixelSize: Style.font.body
          }

          Flickable {
            id: contentFlick
            anchors.fill: parent
            visible: !root.loading && root.statusText === ""
            contentWidth: width
            contentHeight: notes.height + Style.space(12)
            flickableDirection: Flickable.VerticalFlick
            boundsBehavior: Flickable.StopAtBounds
            clip: true

            MouseArea {
              width: contentFlick.width
              height: Math.max(contentFlick.height, contentFlick.contentHeight)
              hoverEnabled: true
              acceptedButtons: Qt.NoButton
              cursorShape: root.linkHovered ? Qt.PointingHandCursor : Qt.ArrowCursor
            }

            // One Text per release, rebuilt whenever the version changes: the
            // Repeater drops the old delegates when it gets a new array, so no
            // long-lived Text has a large document swapped and reflowed in
            // place under the render thread, and each document stays small.
            Column {
              id: notes
              width: contentFlick.width
              spacing: root.contentSpacing
              visible: root.renderedGroup.length > 0

              Text {
                width: parent.width
                textFormat: Text.PlainText
                text: "Omarchy " + root.versionLabel(root.renderedGroup)
                color: root.foreground
                font.family: root.fontFamily
                font.pixelSize: Style.font.display
                font.bold: true
              }

              Repeater {
                model: root.renderedGroup

                Column {
                  required property int index
                  required property var modelData

                  width: notes.width
                  spacing: root.contentSpacing

                  Rectangle {
                    visible: index > 0
                    width: parent.width
                    height: 1
                    color: root.border
                    opacity: 0.6
                  }

                  Text {
                    width: parent.width
                    textFormat: Text.MarkdownText
                    text: root.releaseMarkdown(modelData)
                    color: root.foreground
                    font.family: root.fontFamily
                    font.pixelSize: Style.font.body
                    wrapMode: Text.Wrap
                    linkColor: root.selectedBackground
                    onLinkHovered: function(link) {
                      root.linkHovered = link !== ""
                    }
                    onLinkActivated: function(url) {
                      if (/^https?:\/\//i.test(url))
                        Qt.openUrlExternally(url)
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
