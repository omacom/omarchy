import QtQuick
import QtQuick.Controls as Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Commons
import qs.Ui

Item {
  id: root

  property bool dismissed: false
  property bool refreshPending: false
  property var cancelQueue: []
  property string cancellingId: ""
  property string cancelErrorId: ""

  readonly property bool opened: !dismissed && jobs.count > 0
  readonly property string host: Quickshell.env("OMARCHY_PATH") + "/bin/omarchy-chromium-ytdlp-host"
  readonly property int pad: Style.space(16)
  readonly property int rowHeight: Style.space(64)

  function open(payloadJson) {
    dismissed = false
    refresh()
  }

  function close() {
    dismissed = true
  }

  function refresh() {
    if (listProc.running) {
      refreshPending = true
    } else {
      listProc.running = true
    }
  }

  function applyDownloads(downloads) {
    // Update rows in place: polling must not destroy a pressed cancel button
    // or reset the scroll position when another download reports progress.
    const ids = downloads.map(job => job.id)

    for (let i = jobs.count - 1; i >= 0; --i) {
      if (ids.indexOf(jobs.get(i).jobId) === -1) {
        jobs.remove(i)
      }
    }

    for (let j = 0; j < downloads.length; ++j) {
      const job = downloads[j]
      const row = {
        jobId: job.id,
        title: job.title || job.url,
        url: job.url,
        progress: job.progress,
        status: job.status,
        cancelling: cancellingId === job.id || cancelQueue.indexOf(job.id) !== -1
      }

      if (j < jobs.count && jobs.get(j).jobId === job.id) {
        jobs.set(j, row)
      } else {
        jobs.insert(j, row)
      }
    }
  }

  function cancelDownload(id) {
    if (cancellingId === id || cancelQueue.indexOf(id) !== -1) {
      return
    }

    cancelErrorId = ""
    cancelQueue = cancelQueue.concat([id])

    for (let i = 0; i < jobs.count; ++i) {
      if (jobs.get(i).jobId === id) {
        jobs.setProperty(i, "cancelling", true)
      }
    }

    cancelNext()
  }

  function cancelNext() {
    if (cancelProc.running || cancelQueue.length === 0) {
      return
    }

    cancellingId = cancelQueue[0]
    cancelQueue = cancelQueue.slice(1)
    cancelProc.command = [host, "--cancel", cancellingId]
    cancelProc.running = true
  }

  ListModel {
    id: jobs
  }

  Process {
    id: listProc

    command: [root.host, "--list"]

    stdout: StdioCollector {
      onStreamFinished: {
        try {
          root.applyDownloads(JSON.parse(text))
        } catch (e) {
          // Keep the last snapshot until a subsequent refresh succeeds.
        }
      }
    }

    onExited: {
      if (root.refreshPending) {
        root.refreshPending = false
        Qt.callLater(root.refresh)
      }
    }
  }

  Process {
    id: cancelProc

    onExited: function(exitCode) {
      if (exitCode !== 0) {
        root.cancelErrorId = root.cancellingId
      }

      root.cancellingId = ""
      root.refresh()
      Qt.callLater(root.cancelNext)
    }
  }

  Timer {
    interval: 500
    running: jobs.count > 0
    repeat: true
    onTriggered: root.refresh()
  }

  // keepLoaded also restores ongoing downloads after a shell restart.
  Component.onCompleted: refresh()

  IpcHandler {
    target: "downloads"

    function state(): string {
      const result = []

      for (let i = 0; i < jobs.count; ++i) {
        result.push(jobs.get(i))
      }

      return JSON.stringify(result)
    }
  }

  PanelWindow {
    id: panel

    visible: root.opened

    anchors {
      top: true
      bottom: true
      left: true
      right: true
    }

    color: "transparent"
    WlrLayershell.namespace: "omarchy-downloads"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    exclusionMode: ExclusionMode.Ignore

    mask: Region {
      item: card
    }

    BorderSurface {
      id: card

      width: Math.min(Style.space(460), panel.width - root.pad * 2)
      height: card.borderTop + root.pad + heading.height + Style.space(12)
        + list.height + root.pad + card.borderBottom

      anchors.horizontalCenter: parent.horizontalCenter
      anchors.bottom: parent.bottom
      anchors.bottomMargin: Style.space(67)

      color: Util.alpha(Color.background, 0.97)
      borderSpec: Border.surfaceSpec(
        "popups",
        "border",
        Color.popups.border,
        Math.max(1, Style.space(2))
      )
      radius: Style.cornerRadius

      Text {
        id: heading

        x: card.borderLeft + root.pad
        y: card.borderTop + root.pad
        width: card.width - card.borderLeft - card.borderRight - root.pad * 2

        text: "󰇚  Video downloads (" + jobs.count + ")"
        textFormat: Text.PlainText
        font.family: Style.font.family
        font.pixelSize: Style.font.title
        font.bold: true
        color: Color.popups.text
      }

      ListView {
        id: list

        x: heading.x
        y: heading.y + heading.height + Style.space(12)
        width: heading.width
        height: Math.max(0, Math.min(
          jobs.count * root.rowHeight - Style.space(16),
          Math.max(root.rowHeight, panel.height - Style.space(190)),
          root.rowHeight * 4
        ))

        clip: true
        model: jobs
        boundsBehavior: Flickable.StopAtBounds

        Controls.ScrollBar.vertical: Controls.ScrollBar {
          policy: Controls.ScrollBar.AsNeeded
        }

        delegate: Item {
          id: row

          required property string jobId
          required property string title
          required property string url
          required property string status
          required property real progress
          required property bool cancelling

          width: list.width
          height: root.rowHeight

          Column {
            width: parent.width - cancel.width - Style.space(20)
            spacing: Style.space(5)

            Text {
              width: parent.width
              text: row.title
              textFormat: Text.PlainText
              font.family: Style.font.family
              font.pixelSize: Style.font.body
              font.bold: true
              color: Color.popups.text
              elide: Text.ElideRight
              maximumLineCount: 1
            }

            Text {
              width: parent.width
              text: {
                if (row.cancelling) {
                  return "Cancelling…"
                }

                if (root.cancelErrorId === row.jobId) {
                  return "Couldn't cancel, please try again"
                }

                if (row.status === "Downloading") {
                  return row.status + " · " + row.progress + "%"
                }

                return row.status
              }

              textFormat: Text.PlainText
              font.family: Style.font.family
              font.pixelSize: Style.font.bodySmall
              color: Util.alpha(Color.popups.text, 0.7)
              elide: Text.ElideRight
            }

            Rectangle {
              width: parent.width
              height: Style.space(6)
              color: Util.alpha(Color.popups.text, 0.25)

              Rectangle {
                width: parent.width * Math.max(0, Math.min(100, row.progress)) / 100
                height: parent.height
                color: Color.accent
              }
            }
          }

          Button {
            id: cancel

            anchors.right: parent.right
            anchors.rightMargin: Style.space(8)
            anchors.top: parent.top
            anchors.topMargin: Style.space(5)

            text: "Cancel"
            tooltipText: "Cancel " + row.title + "\n" + row.url
            foreground: Color.popups.text
            fontSize: Style.font.bodySmall
            bordered: true
            focusable: true
            enabled: !row.cancelling
            opacity: enabled ? 1 : 0.5

            onClicked: root.cancelDownload(row.jobId)
          }
        }
      }
    }
  }
}
