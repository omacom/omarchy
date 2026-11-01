import QtQuick
import "Model.js" as Model

// Stands in for Quickshell's SystemClock, which schedules its next tick from
// local wall time. In the hour repeated when daylight saving ends, that target
// resolves to the first pass through the hour, so the delay comes out negative,
// QTimer rearms at 1 ms with a warning, and the log floods for the whole hour.
// Epoch milliseconds never repeat, so every delay here stays within one step.
Timer {
  id: root

  // Milliseconds between ticks: 1000 to show seconds, 60000 for minutes.
  property int step: 60000
  property date date: new Date()

  function arm() {
    interval = Model.msUntilNextTick(Date.now(), step)
    restart()
  }

  onStepChanged: arm()
  onTriggered: {
    date = new Date()
    arm()
  }
  Component.onCompleted: arm()
}
