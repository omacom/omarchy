import QtQuick
import QtTest
import Quickshell
import Quickshell.Io
import qs.Commons as Commons
import "weather" as Weather

ShellRoot {
  id: test
  readonly property bool keyboard: Quickshell.env("WEATHER_TEST_MODE") === "keyboard"
  readonly property bool snapshot: Quickshell.env("WEATHER_TEST_MODE") === "snapshot"
  property int stage: 0
  property int attempts: 0
  property int switches: 0

  function check(ok, message) {
    if (!ok) {
      console.log("RESULT fail " + message)
      Qt.quit()
      return false
    }
    console.log("CHECK pass " + message)
    return true
  }

  function find(item, property) {
    if (property in item) return item
    for (var i = 0; i < item.children.length; i++) {
      var found = find(item.children[i], property)
      if (found) return found
    }
    return null
  }

  QtObject {
    id: bar
    property color barForeground: foreground
    property color foreground: Commons.Color.popups.text
    property string fontFamily: Commons.Style.fontFamily
    function switchPanelFrom(owner, direction) { test.switches += direction; return true }
  }

  FloatingWindow {
    visible: true
    implicitWidth: 500
    implicitHeight: 850
    title: "weather behavior test"

    Item {
      anchors.fill: parent
      TestCase { id: keys; when: false }
      Weather.Panel {
        id: weather
        anchors.fill: parent
        bar: bar
        Component.onCompleted: controller.show()
      }
    }
  }

  Connections {
    target: weather
    function onReportChanged() {
      if (!test.snapshot || !weather.report || test.stage !== 0) return
      test.stage = 5
      weather.configuredLocationState = { name: "Seattle", latitude: null, longitude: null }
      Qt.callLater(function() {
        if (!test.check(weather.reportQuery === "Denver", "completed wttr response keeps Denver after the location changes to Seattle")) return
        if (!test.check(weather.resolvedCoordinates === null, "old Denver response cannot resolve the new Seattle location")) return
        console.log("RESULT pass")
        Qt.quit()
      })
    }
  }

  Timer {
    interval: 100
    repeat: true
    running: true
    onTriggered: {
      test.attempts++
      var radar = test.find(weather, "stationCache")
      var catcher = test.find(weather, "locationField")
      if (test.attempts > 70) {
        test.check(false, "weather scenario timed out at " + test.stage + "; query=" + weather.locationQuery + "; reportQuery=" + weather.reportQuery + "; coordinates=" + JSON.stringify(weather.resolvedCoordinates) + "; daily=" + !!weather.dailyForecastReport + "; radar=" + !!(radar && radar.ready(1)))
        return
      }
      if (!test.snapshot && test.stage === 0 && weather.report) {
        if (!test.check(weather.resolvedCoordinates !== null, "wttr resolves coordinates for " + weather.locationQuery)) return
        if (!test.keyboard && !test.check(weather.reportQuery === weather.locationQuery, "wttr report retains the request query")) return
        test.stage = 1
      } else if (test.stage === 1 && weather.dailyForecastReport && radar && radar.ready(0) && radar.ready(1)) {
        if (!test.check(weather.forecastDays.length === 3 && radar.visible, "resolved location loads Open-Meteo forecast and radar frames")) return
        if (!test.keyboard) {
          if (weather.locationQuery !== "") {
            weather.configuredLocationState = { name: "", latitude: null, longitude: null }
            weather.detectedLocationState = { name: "", latitude: null, longitude: null }
            test.stage = 2
          } else {
            console.log("RESULT pass")
            Qt.quit()
          }
          return
        }
        catcher.forceActiveFocus()
        if (!test.check(catcher.activeFocus, "PanelKeyCatcher owns keyboard focus")) return
        radar.playing = false
        radar.selectFrame(1)
        keys.keyClick(Qt.Key_Left)
        if (!test.check(radar.frameIndex === 0 && !radar.playing, "Left through PanelKeyCatcher scrubs to previous radar frame")) return
        keys.keyClick(Qt.Key_Right)
        if (!test.check(radar.frameIndex === 1 && !radar.playing, "Right through PanelKeyCatcher scrubs to next radar frame")) return
        keys.keyClick(Qt.Key_Space)
        if (!test.check(radar.playing, "Space through PanelKeyCatcher starts radar playback")) return
        keys.keyClick(Qt.Key_Space)
        if (!test.check(!radar.playing, "Space through PanelKeyCatcher pauses radar playback")) return
        keys.keyClick(Qt.Key_Tab)
        if (!test.check(test.switches === 1, "Tab still switches the weather panel")) return
        keys.keyClick(Qt.Key_Return)
        if (!test.check(weather.editingLocation && !radar.playing, "Return edits the location without starting radar")) return
        test.stage = 3
      } else if (test.stage === 2 && weather.reportQuery === "") {
        test.stage = 0
      } else if (test.stage === 3 && weather.locationInput().activeFocus) {
        var field = weather.locationInput()
        field.text = "Denver"
        field.cursorPosition = 6
        keys.keyClick(Qt.Key_Left)
        keys.keyClick(Qt.Key_Space)
        if (!test.check(field.text === "Denve r" && field.cursorPosition === 6 && !radar.playing && radar.frameIndex === 1, "location editor receives Space and arrows without controlling radar")) return
        keys.keyClick(Qt.Key_Escape)
        if (!test.check(!weather.editingLocation && weather.opened, "Escape cancels location editing first")) return
        test.stage = 4
      } else if (test.stage === 4 && catcher.activeFocus) {
        keys.keyClick(Qt.Key_Escape)
        if (!test.check(!weather.opened, "Escape closes weather outside the editor")) return
        console.log("RESULT pass")
        Qt.quit()
      }
    }
  }
}
