import QtQuick
import Quickshell
import Quickshell.Services.UPower
import "mocks"
import "battery" as Battery
import "background" as Wallpaper

ShellRoot {
  id: test
  property bool failed: false
  property int step: 0
  property int lastPlays: 0
  property int lastPauses: 0

  Battery.Service { id: battery }
  Wallpaper.Background {
    id: wallpaper
    shell: QtObject {
      property var services: ({})
      function firstPartyServiceFor(id) {
        return id === "omarchy.battery" ? battery : null
      }
    }
  }

  function check(ok, message) {
    if (!ok) {
      failed = true
      console.log("RESULT fail " + message)
    }
  }

  function checkPlayback(paused, message) {
    check(battery.powerSaverOnBattery === paused, message + ": battery policy")
    check(wallpaper.powerSaverActive === paused, message + ": wallpaper policy")
    var media = wallpaper.testMedia
    check(media !== null && media.video && media.current !== null, message + ": video loaded")
    if (!media || !media.current) return
    check(media.playbackEnabled === !paused, message + ": media binding")
    check(media.current.playbackEnabled === !paused, message + ": video binding")
    var player = media.current.testPlayer
    check(player.playing === !paused, message + ": player state")
  }

  // Separate event-loop turns let native-property notifications and Loader /
  // Binding changes settle, rather than manually invoking production handlers.
  Timer {
    interval: 50
    repeat: true
    running: true
    onTriggered: {
      switch (test.step++) {
      case 0:
        wallpaper.setBackground("/fixture/wallpaper.mp4", true)
        break
      case 1:
        test.checkPlayback(false, "balanced on AC plays")
        UPowerMock.onBattery = true
        break
      case 2:
        test.checkPlayback(false, "balanced on battery still plays")
        test.lastPauses = wallpaper.testMedia.current.testPlayer.pauses
        PowerProfilesMock.profile = PowerProfile.PowerSaver
        break
      case 3:
        test.checkPlayback(true, "native saver change on battery pauses")
        test.check(wallpaper.testMedia.current.testPlayer.pauses > test.lastPauses, "profile change invokes pause")
        test.lastPlays = wallpaper.testMedia.current.testPlayer.plays
        PowerProfilesMock.profile = PowerProfile.Performance
        break
      case 4:
        test.checkPlayback(false, "native performance change resumes")
        test.check(wallpaper.testMedia.current.testPlayer.plays > test.lastPlays, "profile change invokes play")
        PowerProfilesMock.profile = PowerProfile.PowerSaver
        break
      case 5:
        test.checkPlayback(true, "return to saver pauses again")
        test.lastPlays = wallpaper.testMedia.current.testPlayer.plays
        UPowerMock.onBattery = false
        break
      case 6:
        test.checkPlayback(false, "AC resumes while saver stays active")
        test.check(wallpaper.testMedia.current.testPlayer.plays > test.lastPlays, "AC transition invokes play")
        test.lastPauses = wallpaper.testMedia.current.testPlayer.pauses
        UPowerMock.onBattery = true
        break
      case 7:
        test.checkPlayback(true, "battery pauses while saver stays active")
        test.check(wallpaper.testMedia.current.testPlayer.pauses > test.lastPauses, "battery transition invokes pause")
        UPowerMock.onBattery = false
        break
      case 8:
        test.checkPlayback(false, "second AC transition resumes")
        PowerProfilesMock.profile = PowerProfile.Balanced
        break
      case 9:
        test.checkPlayback(false, "balanced profile on AC remains playing")
        if (!test.failed) console.log("RESULT pass")
        Qt.quit()
      }
    }
  }
}
