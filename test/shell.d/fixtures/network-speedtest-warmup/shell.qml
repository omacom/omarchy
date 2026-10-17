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
  function finish() {
    if (!test.failed) console.log("RESULT pass")
    Qt.quit()
  }

  SpeedTest.Panel {
    id: panel
    // The stub helper reports its first sample 5.5s after launch. The checks
    // count from that sample, so a slow start cannot fail them.
    onDownloadValueChanged: {
      if (downloadValue !== 42 || deadline.sampled) return
      deadline.sampled = true
      deadline.stop()
      measuring.start()
      closed.start()
    }
  }

  Component.onCompleted: panel.open('{"connection": "Test"}')

  Timer {
    id: measuring
    interval: 2500
    onTriggered: test.check(panel.phase === "down", "the download window stays open after its first sample")
  }
  Timer {
    id: closed
    interval: 7500
    onTriggered: {
      test.check(panel.phase === "up" && panel.downloadValue === 42, "the download window closes five seconds after its first sample")
      test.finish()
    }
  }
  Timer {
    id: deadline
    property bool sampled: false
    interval: 15000
    running: true
    onTriggered: {
      test.check(false, "a slow warm-up still measures the download")
      test.finish()
    }
  }
}
