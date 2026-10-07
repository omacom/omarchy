import QtQuick
import Quickshell
import qs.Commons
import "background" as BackgroundPlugin

ShellRoot {
  id: shell
  function firstPartyServiceFor(id) { return id === "omarchy.background" ? background : null }
  BackgroundPlugin.Background { id: background }

  // APPLY_THEME_FUNCTION

  Timer {
    interval: 600
    running: true
    onTriggered: {
      var oldColors = Qt.btoa('accent = "#ff0000"\nbackground = "#000000"\nforeground = "#ffffff"\n')
      var newColors = Qt.btoa('accent = "#123456"\nbackground = "#000000"\nforeground = "#ffffff"\n')
      background.transitionBackgroundWithTheme("", "/missing-still.png", "/missing-still.png", oldColors, "")
      shell.applyTheme(newColors, "")
    }
  }
  Timer {
    interval: 1300
    running: true
    onTriggered: {
      if (Qt.colorEqual(Color.accent, "#123456")) {
        console.log("RESULT pass")
      } else {
        console.log("RESULT fail previous colors returned: " + Color.accent)
      }
      Qt.quit()
    }
  }
}
