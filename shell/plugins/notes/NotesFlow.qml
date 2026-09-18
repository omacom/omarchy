import Quickshell
import Quickshell.Wayland
import QtQuick
import qs.Commons
import qs.Ui
import Quickshell.Io

Item {
  id: root

  property string omarchyPath: Quickshell.env("OMARCHY_PATH") || "/usr"
  property var shell: null
  property var manifest: null

  property bool opened: false
  property string fontFamily: Style.font.menuFamily

  property color background: Color.menu.background
  property color foreground: Color.menu.text
  property color border: Color.menu.border
  property var borderSpec: Border.surfaceSpec("menu", "border", border, Math.max(1, Style.space(2)))
  property color scrim: Color.menu.scrim
  readonly property int cornerRadius: Style.cornerRadius
  property int contentMargin: Style.spacing.panelPadding
  
  property int cardWidth: Math.min(Style.space(450), panel.width - Style.gapsOut * 2)
  property int cardHeight: Math.min(Math.max(noteTextEdit.implicitHeight + contentMargin * 2, Style.space(250)), panel.height - Style.gapsOut * 4)

  Process {
    id: readNoteProc
    command: ["omarchy-notes", "--read"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        noteTextEdit.text = text
      }
    }
  }

  function open(payloadJson) {
    var payload = ({})
    try { payload = JSON.parse(payloadJson || "{}") } catch (e) { payload = ({}) }
    if (payload.fontFamily) root.fontFamily = payload.fontFamily

    root.opened = true
    readNoteProc.running = true
    Qt.callLater(function() { noteTextEdit.forceActiveFocus() })
  }

  function close() {
    root.opened = false
  }

  function dismiss() {
    root.opened = false
    if (root.shell && typeof root.shell.hide === "function")
      root.shell.hide((root.manifest && root.manifest.id) || "omarchy.notes")
  }

  function toggle() {
    if (root.opened) root.dismiss()
    else root.open("{}")
  }

  function submit() {
    var args = ["omarchy-notes", noteTextEdit.text]
    Quickshell.execDetached(args)
    root.dismiss()
  }

  PanelWindow {
    id: panel
    visible: root.opened
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    WlrLayershell.namespace: "omarchy-notes"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    exclusionMode: ExclusionMode.Ignore

    Rectangle {
      anchors.fill: parent
      color: root.scrim
    }

    MouseArea {
      anchors.fill: parent
      onClicked: root.submit()
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
        anchors.fill: parent
        anchors.topMargin: card.contentTopInset
        anchors.rightMargin: card.contentRightInset
        anchors.bottomMargin: card.contentBottomInset
        anchors.leftMargin: card.contentLeftInset

        Flickable {
          anchors.fill: parent
          contentWidth: width
          contentHeight: noteTextEdit.implicitHeight
          clip: true
          boundsBehavior: Flickable.StopAtBounds

          TextEdit {
            id: noteTextEdit
            width: parent.width
            color: root.foreground
            font.family: root.fontFamily
            font.pixelSize: Style.font.heading
            wrapMode: TextEdit.Wrap
            selectByMouse: true

            Keys.priority: Keys.BeforeItem
            Keys.onPressed: function(event) {
              if (event.key === Qt.Key_Escape) {
                root.submit()
                event.accepted = true
              }
            }
          }
        }
      }
    }
  }
}
