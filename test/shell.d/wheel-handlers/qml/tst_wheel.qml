import QtQuick
import QtTest
import Quickshell.Services.Pipewire
import qs.Ui as Ui
import "clock" as Clock
import "media" as Media
import "widgets" as Widgets

// The shell's own wheel handlers, with synthetic wheel events: a notch that a
// high-resolution wheel or touchpad splits into several events is one step.
Item {
  id: root
  width: 700
  height: 900

  property var sliderMoves: []
  property var mediaActions: []

  QtObject {
    id: mediaService
    readonly property var activePlayer: ({ trackTitle: "Track", trackArtist: "Artist", isPlaying: true })
    readonly property var sourcePlayers: []
    function runAction(action, quiet) { root.mediaActions.push(action) }
  }

  QtObject {
    id: bar
    readonly property bool vertical: false
    readonly property bool foregroundAnimationEnabled: false
    readonly property color foreground: "#ffffff"
    readonly property color barForeground: "#ffffff"
    readonly property string fontFamily: "sans-serif"
    readonly property var shell: ({ firstPartyServiceFor: function(id) { return mediaService } })
    function showTooltip(item, text) {}
    function hideTooltip(item) {}
  }

  Ui.PanelSlider {
    id: slider
    width: 200
    value: 0.5
    onMoved: function(value) { root.sliderMoves.push(value) }
  }

  Widgets.Microphone {
    id: microphone
    y: 100
  }

  Media.BarWidget {
    id: media
    y: 200
    bar: bar
  }

  Clock.Panel {
    id: calendar
    y: 300
  }

  // The month grid is the item carrying the calendar's WheelHandler.
  function wheelItem(item) {
    for (var i = 0; i < item.data.length; i++)
      if (String(item.data[i]).indexOf("QQuickWheelHandler") === 0) return item
    for (var j = 0; j < item.children.length; j++) {
      var found = wheelItem(item.children[j])
      if (found) return found
    }
    return null
  }

  TestCase {
    name: "WheelHandlers"
    when: windowShown

    // Four fifths of a notch, then the event that completes it.
    function splitNotch(item, direction, afterPartial) {
      for (var i = 0; i < 4; i++) mouseWheel(item, item.width / 2, item.height / 2, 0, direction * 24)
      afterPartial()
      mouseWheel(item, item.width / 2, item.height / 2, 0, direction * 24)
    }

    function test_slider_moves_one_step_per_split_notch() {
      root.sliderMoves = []
      splitNotch(slider, 1, function() {
        compare(root.sliderMoves.length, 0, "a partial notch does not move the slider")
      })
      compare(root.sliderMoves.length, 1, "the completed notch moves it once")
      fuzzyCompare(root.sliderMoves[0], 0.55, 0.0001, "by one step")
    }

    function test_microphone_volume_moves_one_step_per_split_notch() {
      var audio = Pipewire.defaultAudioSource.audio
      audio.volume = 0.5
      splitNotch(microphone, -1, function() {
        fuzzyCompare(audio.volume, 0.5, 0.0001, "a partial notch leaves the volume alone")
      })
      fuzzyCompare(audio.volume, 0.45, 0.0001, "the completed notch lowers it one step")
    }

    function test_media_skips_one_track_per_split_notch() {
      root.mediaActions = []
      splitNotch(media, -1, function() {
        compare(root.mediaActions.length, 0, "a partial notch skips nothing")
      })
      compare(root.mediaActions, ["next"], "the completed notch skips one track")
    }

    function test_calendar_moves_one_month_per_split_notch() {
      var grid = root.wheelItem(calendar)
      verify(grid, "the calendar has a wheel handler")
      calendar.viewYear = 2026
      calendar.viewMonth = 0
      splitNotch(grid, -1, function() {
        compare(calendar.viewMonth, 0, "a partial notch stays on the month")
      })
      compare(calendar.viewMonth, 1, "the completed notch moves one month")
      compare(calendar.viewYear, 2026)
    }
  }
}
