import QtQuick
import Quickshell
import "speedtest" as SpeedTest

ShellRoot {
  id: test
  property bool failed: false
  function check(ok, message) {
    if (!ok) {
      failed = true
      console.log("RESULT fail " + message + " (phase=" + panel.phase + " down=" + panel.downloadValue + " up=" + panel.uploadValue + ")")
    }
  }

  SpeedTest.Panel { id: panel }

  Component.onCompleted: panel.open('{"connection": "Test"}')

  // The stub helper reports its first sample 5.5s after launch.
  Timer {
    interval: 7500
    running: true
    onTriggered: test.check(panel.phase === "down" && panel.downloadValue === 42, "a slow warm-up still measures the download")
  }
  Timer {
    interval: 12500
    running: true
    onTriggered: {
      test.check(panel.phase === "up" && panel.downloadValue === 42, "the download window closes five seconds after its first sample")
      if (!test.failed) console.log("RESULT pass")
      Qt.quit()
    }
  }
}
