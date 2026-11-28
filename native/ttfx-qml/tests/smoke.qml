import QtQuick
import QtQuick.Window
import Omarchy.Ttfx

// The scene smoke.cpp drives: a one-time decrypt, and an unknown effect that
// must not start.
Window {
  width: 1400
  height: 600
  visible: true
  color: "#1a1b26"

  TtfxLogo {
    objectName: "logo"
    anchors.centerIn: parent
    width: 1300
    height: 330
    effect: "decrypt"
    mode: TtfxLogo.OneTime
    color: "#7aa2f7"
    background: "#1a1b26"
    // Faster than the boot contract's 2 to keep the test short; it also
    // exercises several draws per frame.
    stepsPerTick: 8
  }

  // A layout can hand the item a negative size before the window has one.
  TtfxLogo {
    width: -80
    height: -20
  }

  TtfxLogo {
    objectName: "unknown"
    effect: "no-such-effect"
    visible: false
  }
}
