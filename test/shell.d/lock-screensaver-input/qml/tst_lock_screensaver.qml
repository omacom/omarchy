import QtQuick
import QtTest
import "../../../../shell/plugins/lock"

// The screensaver behind the lock gives way to the password prompt only on a
// released key, and only while it shows.
Item {
  id: root
  width: 800
  height: 450

  property int backgrounds: 0

  Component {
    id: background
    Item {
      Component.onCompleted: root.backgrounds++
      Component.onDestruction: root.backgrounds--
    }
  }

  ScreensaverView {
    id: view
    anchors.fill: parent
  }

  SignalSpy { id: dismissed; target: view; signalName: "dismissed" }
  SignalSpy { id: failed; target: view; signalName: "loadFailed" }

  TestCase {
    name: "LockScreensaver"
    when: windowShown

    function init() {
      view.source = ""
      view.backgroundComponent = null
      view.active = false
      view.active = true
      dismissed.clear()
      failed.clear()
      tryCompare(view, "activeFocus", true)
    }

    // A held wake key would otherwise repeat into the password field.
    function test_wakeKeyWaitsForRelease() {
      keyPress(Qt.Key_A)
      compare(dismissed.count, 0)
      keyRelease(Qt.Key_A)
      compare(dismissed.count, 1)
    }

    function test_tabCannotMoveFocusBehindTheArtwork() {
      keyPress(Qt.Key_Tab)
      compare(view.activeFocus, true)
      keyRelease(Qt.Key_Tab)
      compare(dismissed.count, 1)
    }

    function test_mouseDoesNotDismiss() {
      mouseClick(view, 100, 100)
      mouseMove(view, 300, 200)
      compare(dismissed.count, 0)
    }

    function test_inactiveDoesNotDismiss() {
      view.active = false
      keyClick(Qt.Key_Space)
      compare(dismissed.count, 0)
    }

    function test_brokenArtworkFallsBack() {
      ignoreWarning(/.*missing-artwork\.qml.*/)
      view.source = Qt.resolvedUrl("missing-artwork.qml")
      tryCompare(failed, "count", 1)
    }

    // The wallpaper only loads while the artwork shows and no custom artwork replaces it.
    function test_backgroundLoadsOnlyWhileShowing() {
      view.backgroundComponent = background
      tryCompare(root, "backgrounds", 1)
      view.active = false
      tryCompare(root, "backgrounds", 0)
      view.active = true
      tryCompare(root, "backgrounds", 1)
      ignoreWarning(/.*missing-artwork\.qml.*/)
      view.source = Qt.resolvedUrl("missing-artwork.qml")
      tryCompare(root, "backgrounds", 0)
    }
  }
}
