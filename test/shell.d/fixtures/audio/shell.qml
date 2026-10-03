import QtQuick
import Quickshell

ShellRoot {
  id: root
  property var microphone
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
          var component = Qt.createComponent("MicrophoneTest.qml")
          check(component.status === Component.Ready, component.errorString())
          root.microphone = component.createObject(host, { available: true, target: "test-source" })
          check(root.microphone !== null, component.errorString())
        } else if (root.step === 1) {
          check(!microphone.running, "opening the panel must not capture")
          microphone.available = false
          microphone.start()
          check(!microphone.running, "closed panel must not start capture")
          microphone.available = true
          microphone.target = ""
          microphone.start()
          check(!microphone.running, "missing source must not fall back to the default")
          microphone.target = "test-source"
          microphone.start()
        } else if (root.step === 2) {
          check(microphone.running, "explicit start opens capture")
          microphone.start()
          microphone.toggle()
        } else if (root.step === 3) {
          check(!microphone.running && microphone.error === "", "Stop ends capture without an error")
          microphone.start()
        } else if (root.step === 4) {
          check(microphone.running, "test can restart")
          microphone.available = false
        } else if (root.step === 5) {
          check(!microphone.running, "closing panel stops capture")
          microphone.available = true
        } else if (root.step === 6) {
          check(!microphone.running, "reopening panel does not restart capture")
          microphone.start()
          microphone.available = false
        } else if (root.step === 7) {
          check(!microphone.running, "closing during startup stops capture")
          microphone.available = true
          microphone.start()
        } else if (root.step === 8) {
          check(microphone.running, "test started before source change")
          microphone.target = ""
        } else if (root.step === 9) {
          check(microphone.running, "profile transition does not stop capture")
          microphone.target = "test-source"
        } else if (root.step === 10) {
          check(microphone.running, "same source survives the profile transition")
          microphone.target = "other-source"
        } else if (root.step === 11) {
          check(!microphone.running && microphone.error === "", "source change stops capture")
          microphone.start()
        } else if (root.step === 12) {
          check(microphone.running, "new source can be tested")
          microphone.target = ""
        } else if (root.step === 13) {
          if (microphone.running && ++root.waits < 15) return
          check(!microphone.running, "source removal stops capture")
          root.waits = 0
          microphone.target = "failure"
          microphone.start()
        } else if (root.step === 14) {
          check(!microphone.running && microphone.error !== "", "capture failure is visible")
          microphone.target = "test-source"
          microphone.start()
        } else if (root.step === 15) {
          check(microphone.running && microphone.error === "", "failure can be retried")
        } else if (root.step === 16) {
          if (microphone.running && ++root.waits < 320) return
          check(!microphone.running && microphone.error === "", "30-second timeout releases capture")
          microphone.start()
        } else if (root.step === 17) {
          check(microphone.running, "capture restarted before destruction")
          microphone.destroy()
        } else {
          console.log("MICROPHONE_TEST_PASS")
          Qt.quit()
        }
        root.step++
      } catch (error) {
        console.error("MICROPHONE_TEST_FAIL: " + error)
        Qt.quit()
      }
    }
  }
}
