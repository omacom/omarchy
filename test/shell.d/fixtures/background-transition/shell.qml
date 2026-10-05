import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Window

ShellRoot {
  id: test
  readonly property string directory: Quickshell.env("VARIANT_RENDER_DIR")
  readonly property string images: directory + "/images/"
  property int step: 0
  property int ticks: 0
  property bool grabbing: false

  function fail(message) {
    console.error("FAIL rendered transition: " + message)
    Qt.quit()
  }

  function capture(name, next) {
    grabbing = true
    if (!background.grabToImage(function(result) {
      if (!result.saveToFile(directory + "/" + name + ".png")) {
        test.fail("could not save " + name)
        return
      }
      test.grabbing = false
      next()
    })) test.fail("could not grab " + name)
  }

  Window {
    width: 270
    height: 160
    visible: true
    color: "black"

    BackgroundUnderTest {
      id: background
      anchors.fill: parent
    }
  }

  Process {
    id: release
    command: ["touch", test.directory + "/release"]
  }

  Timer {
    interval: 50
    repeat: true
    running: true
    onTriggered: {
      test.ticks++
      if (test.ticks > 400) { test.fail("timed out at step " + test.step); return }
      if (test.grabbing) return
      var panels = background.testPanels.instances
      if (panels.length !== 2) return
      var wide = panels[0]
      var portrait = panels[1]
      if (test.step === 0) {
        background.setBackground(test.images + "old.png", true)
        test.step = 1
      } else if (test.step === 1 && wide.testBase.ready && portrait.testBase.ready &&
                 /wide.png$/.test(wide.displayedPath) && /portrait.png$/.test(portrait.displayedPath)) {
        test.capture("initial", function() {
          background.transitionBackground("", test.images + "new.png", test.images + "new.png", false, false)
          test.step = 2
        })
      } else if (test.step === 2 && wide.maskReady && portrait.maskReady &&
                 wide.testIncoming.status === Image.Ready && portrait.testIncoming.status === Image.Ready) {
        background.testPause()
        // Reload the live bases with a different image. Frozen outgoing pixels
        // must remain each output's old variant, proving an actual capture.
        var known = Object.assign({}, background.nativeSizes)
        known[test.images + "decoy.png"] = {width: 100, height: 100}
        background.nativeSizes = known
        background.displayedCandidates = [{path: test.images + "decoy.png", width: 100, height: 100}]
        test.step = 3
      } else if (test.step === 3 && wide.testBase.ready && portrait.testBase.ready &&
                 /decoy.png$/.test(wide.displayedPath) && /decoy.png$/.test(portrait.displayedPath)) {
        test.capture("captured", function() {
          background.revealProgress = 0.5
          test.step = 31
        })
      } else if (test.step === 31) {
        test.capture("reveal", function() {
          background.testFinish()
          test.step = 4
        })
      } else if (test.step === 4 && wide.testBase.ready && !portrait.testBase.ready) {
        if (!background.finishingTransition || !background.incomingBackground) {
          test.fail("incoming frame released while portrait is still loading")
          return
        }
        test.capture("held", function() {
          release.running = true
          test.step = 5
        })
      } else if (test.step === 5 && wide.testBase.ready && portrait.testBase.ready && !background.incomingBackground) {
        if (background.finishingTransition || background.oldBackground || background.preparedBackground) {
          test.fail("transition frames were not released")
          return
        }
        test.capture("finished", function() {
          console.log("PASS rendered transition")
          Qt.quit()
        })
      }
    }
  }
}
