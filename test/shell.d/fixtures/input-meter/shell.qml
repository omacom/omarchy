import QtQuick
import Quickshell
import "audio"

ShellRoot {
  id: root
  property int step: 0

  // Stands in for a PwNode on a pro-audio profile: AUX0 and AUX1.
  QtObject {
    id: auxNode
    property string name: "stub-node"
    property var audio: QtObject {
      property var channels: [4096, 4097]
      property real volume: 1
    }
  }

  InputMeter { id: meter; node: auxNode; active: true }

  function finish(message) {
    console.log(message)
    Qt.quit()
  }

  Timer {
    interval: 100
    repeat: true
    running: true
    onTriggered: {
      root.step++
      if (root.step === 20) {
        if (!(meter.peak > 0)) return root.finish("INPUT_METER_TEST_FAIL: the AUX source was never metered")
        // Off and on again in one turn, before the old script has exited.
        meter.active = false
        meter.active = true
      } else if (root.step === 40) {
        root.finish(meter.peak > 0 ? "INPUT_METER_TEST_PASS" : "INPUT_METER_TEST_FAIL: the meter stayed at zero after a quick stop and start")
      }
    }
  }
}
