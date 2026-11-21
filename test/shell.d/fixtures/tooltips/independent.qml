import QtQuick
import QtQuick.Controls
import Quickshell

// Same attached API as the standalone Control Panel's close button. No Ui
// imports and no RespectSystemStyle pragma supplied by the consumer.
ShellRoot {
  FloatingWindow {
    implicitWidth: 240
    implicitHeight: 120
    Button {
      id: closeButton
      text: "×"
      ToolTip.visible: hovered
      ToolTip.text: "Cerrar"
    }
  }
  Timer {
    interval: 200
    running: true
    onTriggered: {
      const styled = closeButton.ToolTip.toolTip.maximumWidth !== undefined
      const expected = Quickshell.env("TOOLTIP_EXPECT_STYLE") === "1"
      console.log("Independent close tooltip styled=" + styled + " expected=" + expected)
      console.log(styled === expected ? "RESULT pass" : "RESULT fail")
      Qt.quit()
    }
  }
}
