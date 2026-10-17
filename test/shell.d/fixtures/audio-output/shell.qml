import QtQuick
import Quickshell

ShellRoot {
  id: root
  property var output
  property int step: 0
  property int waits: 0

  Item { id: host }

  function check(condition, message) {
    if (!condition) throw new Error(message)
  }

  Timer {
    interval: 100
    repeat: true
    running: true
    onTriggered: {
      try {
        if (root.step === 0) {
          var component = Qt.createComponent("OutputTest.qml")
          check(component.status === Component.Ready, component.errorString())
          root.output = component.createObject(host, { available: true, target: "test-sink" })
          check(root.output !== null, component.errorString())
        } else if (root.step === 1) {
          check(!output.running, "opening the panel must not play sound")
          output.available = false
          output.start()
          check(!output.running, "closed panel must not start playback")
          output.available = true
          output.target = ""
          output.start()
          check(!output.running, "missing output must not fall back to the default")
          output.target = "test-sink"
          output.start()
        } else if (root.step === 2) {
          check(output.running, "explicit start opens playback")
          output.start()
          output.toggle()
        } else if (root.step === 3) {
          check(!output.running && output.error === "", "Stop ends playback without an error")
          output.start()
        } else if (root.step === 4) {
          check(output.running, "test can restart")
          output.available = false
        } else if (root.step === 5) {
          check(!output.running, "closing panel stops playback")
          output.available = true
        } else if (root.step === 6) {
          check(!output.running, "reopening panel does not restart playback")
          output.start()
          output.available = false
        } else if (root.step === 7) {
          check(!output.running, "closing during startup stops playback")
          output.available = true
          output.start()
        } else if (root.step === 8) {
          check(output.running, "test started before output change")
          output.target = "other-sink"
        } else if (root.step === 9) {
          check(!output.running && output.error === "", "output change stops playback")
          output.start()
        } else if (root.step === 10) {
          check(output.running, "new output can be tested")
          output.target = ""
        } else if (root.step === 11) {
          check(!output.running, "output removal stops playback")
          output.target = "failure"
          output.start()
        } else if (root.step === 12) {
          check(!output.running && output.error !== "", "playback failure is visible")
          output.target = "complete"
          output.start()
        } else if (root.step === 13) {
          check(!output.running && output.error === "", "natural completion clears the running state without an error")
          output.target = "test-sink"
          output.start()
        } else if (root.step === 14) {
          check(output.running && output.error === "", "completed playback can be repeated")
        } else if (root.step === 15) {
          if (output.running && ++root.waits < 120) return
          check(!output.running && output.error === "", "10-second timeout releases stalled playback")
          output.start()
        } else if (root.step === 16) {
          check(output.running, "playback restarted before destruction")
          output.destroy()
        } else {
          console.log("OUTPUT_TEST_PASS")
          Qt.quit()
        }
        root.step++
      } catch (error) {
        console.error("OUTPUT_TEST_FAIL: " + error)
        Qt.quit()
      }
    }
  }
}
