import QtQuick

// A command returning does not mean its image decoded or its reveal finished.
// Keep intentional observation delays, but wait for asynchronous handoffs with
// a bounded deadline instead of assuming they finish between two timer ticks.
Timer {
  required property var steps
  property int step: 0
  property double stepStarted: Date.now()
  interval: 16
  repeat: true
  running: true

  onTriggered: {
    if (step >= steps.length) {
      stop()
      return
    }
    var current = steps[step]
    var elapsed = Date.now() - stepStarted
    if (elapsed < (current.delay || 0)) return
    if (current.until && !current.until()) {
      if (elapsed < (current.timeout || 3000)) return
      console.log("RESULT fail timed out waiting for " + current.waitFor)
      stop()
      Qt.quit()
      return
    }
    current.run()
    stepStarted = Date.now()
    step += 1
  }
}
