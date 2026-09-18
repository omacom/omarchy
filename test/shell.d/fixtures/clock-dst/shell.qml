import QtQuick
import Quickshell
import "Model.js" as Model

ShellRoot {
  id: root
  property bool failed: false

  function check(condition, message) {
    if (!condition) {
      failed = true
      console.log("RESULT fail " + message)
    }
  }

  Timer {
    interval: 1
    running: true
    onTriggered: {
      var weeks = Model.monthGrid(2026, 8, 1, "")
      var days = []
      for (var w = 0; w < weeks.length; w++) {
        for (var d = 0; d < weeks[w].days.length; d++) days.push(weeks[w].days[d])
      }
      root.check(days.length === 42, "September grid has six complete weeks")

      var expected = []
      var cursor = new Date(Date.UTC(2026, 7, 31))
      for (var i = 0; i < 42; i++) {
        expected.push({
          key: cursor.getUTCFullYear() + "-" +
            (cursor.getUTCMonth() + 1).toString().padStart(2, "0") + "-" +
            cursor.getUTCDate().toString().padStart(2, "0"),
          weekday: cursor.getUTCDay()
        })
        cursor.setUTCDate(cursor.getUTCDate() + 1)
      }

      for (var j = 0; j < days.length; j++) {
        root.check(days[j].key === expected[j].key, "calendar dates stay consecutive at cell " + j)
        root.check(days[j].weekday === expected[j].weekday, "calendar weekdays stay aligned at cell " + j)
      }
      root.check(days[6].key === "2026-09-06", "DST transition day is present once")
      root.check(days[6].weekday === 0, "DST transition day remains Sunday")

      var next = Model.stepMonth(2026, 8, 1)
      root.check(next.year === 2026 && next.month === 9, "month stepping crosses September correctly")

      if (root.failed) {
        Qt.quit()
        return
      }
      console.log("RESULT pass")
      Qt.quit()
    }
  }
}
