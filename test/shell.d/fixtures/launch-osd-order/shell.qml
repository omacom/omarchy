import QtQuick
import Quickshell
import Quickshell.Io
import "services"

// Closes the launch OSD the moment it opens, while the stubbed
// `omarchy-shell osd show` is still running. The test then checks that the
// close reached omarchy-shell after the show.
ShellRoot {
  id: root

  AppLibrary { id: appLibrary }

  FileView {
    id: resultFile
    path: Quickshell.env("OMARCHY_QML_TEST_RESULT")
    atomicWrites: true
  }

  Timer {
    id: waitForOpen
    interval: 20
    repeat: true
    onTriggered: {
      if (!appLibrary.launchOsdOpen) return
      stop()
      appLibrary.closeLaunchFeedback(appLibrary.launchSerial)
      settle.start()
    }
  }

  Timer {
    id: settle
    interval: 1500
    onTriggered: resultFile.setText(JSON.stringify({ ok: true }))
  }

  // Let the toplevel list finish loading first: a count that grows after the
  // launch reads as the app's window appearing.
  Timer {
    running: true
    interval: 1000
    onTriggered: {
      appLibrary.beginLaunchFeedback("Test")
      waitForOpen.start()
    }
  }
}
