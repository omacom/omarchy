import QtQuick
import "Model.js" as Model

// Stands in for Quickshell's SystemClock, which schedules its next tick from
// local wall time. In the hour repeated when daylight saving ends, that target
// resolves to the first pass through the hour, so the delay comes out negative,
// QTimer rearms at 1 ms with a warning, and the log floods for the whole hour.
// Epoch milliseconds never repeat, so every delay here stays within one step.
//
// A Timer counts monotonic time, which stands still through a suspend, so a
// tick armed before sleep lands up to a whole step late after the wake, and a
// clock step (NTP, a timezone change) is not seen until then either. sync()
// reads the wall clock now and re-aims the next tick at the real boundary;
// omarchy-system-wake calls it, through the clock's refresh, on every wake.
Timer {
  id: root

  // Milliseconds between ticks: 1000 to show seconds, 60000 for minutes.
  property int step: 60000
  property date date: new Date()

  function arm() {
    interval = Model.msUntilNextTick(Date.now(), step)
    restart()
  }

  function sync() {
    date = new Date()
    arm()
  }

  onStepChanged: arm()
  onTriggered: sync()
  Component.onCompleted: arm()
}
