import QtQuick
import Quickshell
import "ascii-paint/PaintModel.js" as PaintModel

ShellRoot {
  id: root

  property var canvas: PaintModel.createCanvas(2, 2)

  function click(button, buttons, x, y, tool) {
    var intent = PaintModel.pointerIntent(button, buttons, tool)
    if (intent === "ignore") return intent
    PaintModel.applyStamp(root.canvas, {
      tool: tool,
      intent: intent,
      col: Math.floor(x / 10),
      row: Math.floor(y / 20),
      lx: x - Math.floor(x / 10) * 10,
      ly: y - Math.floor(y / 20) * 20,
      cellW: 10,
      cellH: 20,
      shadeLevel: 2
    })
    return intent
  }

  Component.onCompleted: {
    var intent = root.click(1, 1, 1, 1, "block")
    if (intent !== "paint") {
      console.log("RESULT fail left click intent was " + intent)
      Qt.quit()
      return
    }
    if (PaintModel.glyphAt(root.canvas, 0, 0) !== "\u2598") {
      console.log("RESULT fail left click did not paint a block quadrant")
      Qt.quit()
      return
    }
    intent = root.click(2, 2, 5, 1, "block")
    if (intent !== "erase") {
      console.log("RESULT fail right click intent was " + intent)
      Qt.quit()
      return
    }
    if (PaintModel.glyphAt(root.canvas, 0, 0) === "\u2598") {
      console.log("RESULT fail right click did not erase")
      Qt.quit()
      return
    }
    console.log("RESULT pass")
    Qt.quit()
  }
}
