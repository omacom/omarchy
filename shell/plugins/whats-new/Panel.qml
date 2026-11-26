import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Commons
import qs.Commons as Commons
import qs.Ui

// What's new in this release, one feature at a time, floating on the same
// heavy scrim as the Wi-Fi QR and speed test overlays. Each page names the
// feature, says what it does, shows its hotkey, and can open it; the last page
// points at the full release post.
//
// Standalone panel plugin, summoned by omarchy-update-whats-new from the update
// icon, the menu or a terminal. The payload may name a release,
// {"release": "4.5"}; without one omarchy-update-whats-new-notes picks the
// installed release. Closing the tour (Esc, a click outside, or the last
// page's button) marks the notes seen, which takes the update icon's reminder
// away. Trying a feature closes it without that, so the icon stays to come
// back to.
Item {
  id: root

  property var shell: null
  property var manifest: null

  property bool opened: false
  property var notes: null
  property string error: ""
  property int index: 0
  // Which way the last page turn went, for the slide in: 1 forward, -1 back.
  property int direction: 1

  readonly property var items: notes && notes.items ? notes.items : []
  readonly property int pageCount: notes ? items.length + 1 : 0
  readonly property bool onLastPage: index >= items.length
  readonly property var item: !onLastPage ? items[index] : null
  readonly property string release: notes ? String(notes.release || "") : ""

  // The scrim is a fixed near-black regardless of theme, so text on it needs
  // a fixed light palette, not the themed foreground.
  readonly property color onScrim: "white"
  readonly property color onScrimDim: Qt.rgba(1, 1, 1, 0.55)
  readonly property color onScrimFaint: Qt.rgba(1, 1, 1, 0.22)
  readonly property color onScrimUrgent: "#ff6b6b"
  readonly property string fontFamily: Style.font.family

  function open(payloadJson) {
    var payload = {}
    try { payload = JSON.parse(payloadJson || "{}") || {} } catch (e) {}
    var requested = payload.release !== undefined ? String(payload.release) : ""
    root.notes = null
    root.index = 0
    root.error = ""
    notesProc.command = ["omarchy-update-whats-new-notes"].concat(requested !== "" ? [requested] : [])
    notesProc.running = true
    root.opened = true
    // The window is instantiated hidden, so the content's `focus: true` is
    // evaluated before the surface is mapped and Escape would land nowhere.
    // Re-acquire after mapping.
    Qt.callLater(function() {
      if (root.opened) keyCatcher.forceActiveFocus()
    })
  }

  function close() {
    root.opened = false
  }

  function hide() {
    if (root.shell && typeof root.shell.hide === "function")
      root.shell.hide((root.manifest && root.manifest.id) || "omarchy.whats-new")
    else close()
  }

  // Closing the tour is having seen it.
  function finish() {
    if (root.notes && root.notes.pending) {
      Util.execArgv(["omarchy-update-whats-new-seen", root.release])
      root.notes.pending = false
    }
    hide()
  }

  function go(next) {
    if (root.pageCount === 0) return
    var target = Math.max(0, Math.min(root.pageCount - 1, next))
    if (target === root.index) return
    root.direction = target > root.index ? 1 : -1
    root.index = target
    pageIn.restart()
  }

  function tryItem() {
    if (!root.item || !root.item.try) return
    var action = String(root.item.try.action || "")
    // Out of the way first: the overlay holds the keyboard above everything
    // the action could open.
    hide()
    if (action !== "") Util.execDetached(action)
  }

  function openPost() {
    var post = root.notes ? String(root.notes.post || "") : ""
    finish()
    if (post !== "") Util.execArgv(["omarchy-launch-webapp", post])
  }

  function activate() {
    if (root.onLastPage) {
      if (root.notes && root.notes.post) openPost()
      else finish()
    } else if (root.item.try) tryItem()
    else go(root.index + 1)
  }

  Process {
    id: notesProc
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        var parsed = null
        try { parsed = JSON.parse(String(text || "")) } catch (e) {}
        if (parsed && Array.isArray(parsed.items)) root.notes = parsed
      }
    }
    onExited: function(exitCode) {
      if (exitCode !== 0 && !root.notes) root.error = I18n.t("whatsNew.unavailable")
    }
  }

  OverlayWindow {
    shown: root.opened
    WlrLayershell.namespace: "omarchy-whats-new"

    Rectangle {
      anchors.fill: parent
      color: Qt.rgba(0, 0, 0, 0.78)

      MouseArea {
        anchors.fill: parent
        onClicked: root.finish()
      }
    }

    Item {
      id: keyCatcher
      anchors.fill: parent
      focus: true

      Keys.onEscapePressed: root.finish()
      Keys.onReturnPressed: root.activate()
      Keys.onEnterPressed: root.activate()
      Keys.onSpacePressed: root.go(root.index + 1)
      Keys.onPressed: function(event) {
        var key = Util.readingKey(event, true)
        if (key === Qt.Key_Right || key === Qt.Key_Tab) root.go(root.index + 1)
        else if (key === Qt.Key_Left || key === Qt.Key_Backtab) root.go(root.index - 1)
        else if (key === Qt.Key_Home) root.go(0)
        else if (key === Qt.Key_End) root.go(root.pageCount - 1)
        else return
        event.accepted = true
      }

      Item {
        anchors.centerIn: parent
        width: content.implicitWidth
        height: content.implicitHeight
        // Narrow or heavily scaled outputs: shrink the whole tour rather than
        // clipping it at the screen edge.
        scale: Math.min(1,
          (keyCatcher.width - Style.space(32)) / Math.max(1, width),
          (keyCatcher.height - Style.space(32)) / Math.max(1, height))

        // Swallow clicks so only the scrim outside the content dismisses.
        MouseArea { anchors.fill: parent; onClicked: {} }

        ColumnLayout {
          id: content
          anchors.fill: parent
          spacing: Style.space(20)

          Text {
            textFormat: Text.PlainText
            text: I18n.t("whatsNew.heading").arg(root.release).toUpperCase()
            visible: root.release !== ""
            color: root.onScrimDim
            font.family: root.fontFamily
            font.pixelSize: Style.font.caption
            font.bold: true
            font.letterSpacing: 2
            Layout.alignment: Qt.AlignHCenter
          }

          // One page. Its own column, so a page turn slides and fades it as a
          // whole while the heading and the dots stay put.
          Item {
            id: pageFrame
            Layout.preferredWidth: Style.space(520)
            // Room for most pages, so the dots below stay put as the pages
            // turn; a longer page pushes them down rather than under it.
            Layout.preferredHeight: Math.max(Style.space(300), page.implicitHeight)
            visible: root.notes !== null

            ColumnLayout {
              id: page
              width: parent.width
              anchors.verticalCenter: parent.verticalCenter
              spacing: Style.space(12)

              Text {
                textFormat: Text.PlainText
                text: root.item ? String(root.item.icon || "") : "\u{f05e0}"
                color: Commons.Color.accent
                font.family: root.fontFamily
                font.pixelSize: Style.space(44)
                Layout.alignment: Qt.AlignHCenter
              }

              Text {
                textFormat: Text.PlainText
                text: root.item ? root.item.title : I18n.t("whatsNew.doneTitle")
                color: root.onScrim
                font.family: root.fontFamily
                font.pixelSize: Style.font.display
                font.bold: true
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
              }

              Text {
                textFormat: Text.PlainText
                visible: !!(root.item && root.item.changed)
                text: I18n.t("whatsNew.changed").toUpperCase()
                color: Commons.Color.accent
                font.family: root.fontFamily
                font.pixelSize: Style.font.caption
                font.bold: true
                font.letterSpacing: 1.5
                Layout.alignment: Qt.AlignHCenter
              }

              Text {
                textFormat: Text.PlainText
                text: root.item ? root.item.body : I18n.t("whatsNew.doneBody").arg(root.release)
                color: root.onScrimDim
                font.family: root.fontFamily
                font.pixelSize: Style.font.title
                lineHeight: 1.25
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
              }

              // The feature's hotkey, one keycap per key.
              Row {
                visible: keycaps.count > 0
                spacing: Style.space(6)
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: Style.space(4)

                Repeater {
                  id: keycaps
                  model: root.item && root.item.keys ? String(root.item.keys).split(" + ") : []

                  Rectangle {
                    required property string modelData
                    width: Math.max(height, keyLabel.implicitWidth + Style.space(16))
                    height: keyLabel.implicitHeight + Style.space(8)
                    radius: Style.cornerRadius
                    color: Qt.rgba(1, 1, 1, 0.08)
                    border.width: 1
                    border.color: root.onScrimFaint

                    Text {
                      id: keyLabel
                      anchors.centerIn: parent
                      textFormat: Text.PlainText
                      text: parent.modelData
                      color: root.onScrim
                      font.family: root.fontFamily
                      font.pixelSize: Style.font.bodySmall
                      font.bold: true
                    }
                  }
                }
              }

              Button {
                readonly property string label: root.item
                  ? (root.item.try ? String(root.item.try.label || "") : "")
                  : (root.notes && root.notes.post ? I18n.t("whatsNew.readPost") : "")
                visible: label !== ""
                text: label
                bordered: true
                foreground: root.onScrim
                fontFamily: root.fontFamily
                fontSize: Style.font.body
                horizontalPadding: Style.space(16)
                verticalPadding: Style.space(6)
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: Style.space(8)
                onClicked: root.activate()
              }
            }

            // Slides in from the side the reader is heading to, so a page
            // turn reads as moving through the release rather than a swap.
            ParallelAnimation {
              id: pageIn
              NumberAnimation {
                target: page; property: "x"
                from: Style.space(24) * root.direction * (I18n.rightToLeft ? -1 : 1); to: 0
                duration: Style.duration(200)
                easing.type: Easing.Bezier; easing.bezierCurve: Style.easeOut
              }
              NumberAnimation {
                target: page; property: "opacity"
                from: 0; to: 1
                duration: Style.duration(200)
                easing.type: Easing.OutCubic
              }
            }
          }

          Text {
            textFormat: Text.PlainText
            visible: root.error !== ""
            text: root.error
            color: root.onScrimUrgent
            font.family: root.fontFamily
            font.pixelSize: Style.font.bodySmall
            Layout.alignment: Qt.AlignHCenter
          }

          // Where you are in the tour; any dot jumps to its page.
          Row {
            visible: root.pageCount > 1
            spacing: Style.space(4)
            Layout.alignment: Qt.AlignHCenter

            Repeater {
              model: root.pageCount

              Item {
                required property int index
                width: Style.space(14)
                height: Style.space(14)

                Rectangle {
                  anchors.centerIn: parent
                  width: index === root.index ? Style.space(8) : Style.space(6)
                  height: width
                  radius: width / 2
                  color: index === root.index ? root.onScrim : root.onScrimFaint
                }

                MouseArea {
                  anchors.fill: parent
                  cursorShape: Qt.PointingHandCursor
                  onClicked: root.go(index)
                }
              }
            }
          }

          Text {
            textFormat: Text.PlainText
            visible: root.notes !== null
            text: I18n.t("whatsNew.keysHint")
            color: root.onScrimDim
            opacity: 0.8
            font.family: root.fontFamily
            font.pixelSize: Style.font.caption
            Layout.alignment: Qt.AlignHCenter
          }
        }
      }
    }
  }
}
