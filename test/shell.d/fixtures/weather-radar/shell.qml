import QtQuick
import Quickshell
import "weather" as Weather

ShellRoot {
  id: test
  property int stage: 0
  property int attempts: 0
  property string selected: ""

  function check(ok, message) {
    if (!ok) {
      console.log("RESULT fail " + message)
      Qt.quit()
    }
  }

  Weather.Radar {
    id: radar
    width: 448
    coordinates: ({ latitude: 35.5, longitude: -106.7, key: "35.50,-106.70" })
    active: true
  }

  Timer {
    interval: 100
    repeat: true
    running: true
    onTriggered: {
      test.attempts++
      if (test.attempts > 100) {
        test.check(false, "radar scenario timed out at " + test.stage)
        return
      }
      if (test.stage === 0 && radar.ready(0) && radar.ready(1)) {
        radar.selectFrame(0)
        test.selected = radar.frames[radar.frameIndex].stamp
        radar.acceptResponse("scans", "", 503)
        radar.acceptResponse("scans", '{"scans":[]}', 200)
        test.check(radar.frames[radar.frameIndex].stamp === test.selected && radar.implicitHeight > 0, "failed refresh preserves the visible frame")
        radar.acceptResponse("scans", '{"scans":[{"ts":"2026-10-23T00:00Z"},{"ts":"2026-10-23T00:05Z"},{"ts":"2026-10-23T00:10Z"}]}', 200)
        test.stage++
      } else if (test.stage === 1 && test.attempts > 5) {
        test.check(radar.frames[radar.frameIndex].stamp === test.selected && radar.ready(radar.frameIndex), "a failed new tile preserves the last good frame")
        radar.frameIndex = 2
        radar.checkReady()
        test.check(radar.frameIndex === 2, "a paused selection survives while its images are unavailable")
        radar.frameIndex = 0
        radar.active = false
        test.stage++
      } else if (test.stage === 2 && !radar.resident) {
        test.check(radar.tiles.length === 0 && radar.frames.length > 0, "close releases tile objects and retains scan metadata")
        radar.active = true
        test.stage++
      } else if (test.stage === 3 && radar.ready(radar.frameIndex)) {
        test.check(radar.frames[radar.frameIndex].stamp === test.selected, "reopen preserves selection")
        radar.coordinates = { latitude: 51.5, longitude: -0.12, key: "51.50,-0.12" }
        test.stage++
      } else if (test.stage === 4 && radar.stationCache[radar.coordinateKey] === null) {
        test.check(radar.frames.length === 0, "location changes remove the previous city's scans")
        radar.active = false
        test.stage++
      } else if (test.stage === 5 && !radar.resident) {
        radar.active = true
        test.stage++
      } else if (test.stage === 6) {
        test.check(radar.stationCache[radar.coordinateKey] === null && !radar.request, "unsupported station stays cached on reopen")
        console.log("RESULT pass")
        Qt.quit()
      }
    }
  }
}
