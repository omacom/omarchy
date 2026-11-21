import QtQuick
import Quickshell
import Quickshell.Io
import "services"

// Shows the launch OSD and closes it in the same turn, while the stubbed
// `omarchy-shell osd show` is still running. Nothing runs in between, so window
// changes on the desktop cannot cancel the launch first. The test then checks
// that the close reached omarchy-shell after the show.
ShellRoot {
  id: root

  AppLibrary { id: appLibrary }

  FileView {
    id: resultFile
    path: Quickshell.env("OMARCHY_QML_TEST_RESULT")
    atomicWrites: true
  }

  Timer {
    id: settle
    interval: 1500
    onTriggered: resultFile.setText(JSON.stringify({ ok: true }))
  }

  Component.onCompleted: {
    appLibrary.beginLaunchFeedback("Test")
    appLibrary.showLaunchOsd()
    appLibrary.closeLaunchFeedback(appLibrary.launchSerial)
    settle.start()
  }
}
