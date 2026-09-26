import QtQuick
import QtTest
import Quickshell
import qs.Commons
import qs.paint
import "paint/PaintModel.js" as PaintModel

// Drives the real painter overlay with Qt pointer and key events: the same
// press, drag, wheel, and key delivery a focused window receives.
ShellRoot {
  AsciiPaint { id: painter }

  TestCase {
    id: driver
    name: "AsciiPaintInput"
    when: false

    property string dir: Quickshell.env("PAINT_TEST_DIR")
    property var artItem: null

    function fail(message) {
      console.log("RESULT fail " + message)
      painter.close()
      Qt.quit()
      throw new Error(message)
    }

    function check(condition, message) {
      if (!condition) fail(message)
    }

    function find(item, pred) {
      var seen = {}
      var stack = [item]
      var steps = 0
      var next
      var i
      while (stack.length && steps < 4000) {
        next = stack.pop()
        steps++
        if (!next || seen[String(next)]) continue
        seen[String(next)] = true
        if (pred(next)) return next
        if (next.contentItem) stack.push(next.contentItem)
        if (next.children) {
          for (i = 0; i < next.children.length; i++) stack.push(next.children[i])
        }
        if (next.resources) {
          for (i = 0; i < next.resources.length; i++) stack.push(next.resources[i])
        }
      }
      return null
    }

    function art() {
      if (artItem) return artItem
      artItem = find(painter, function(item) { return item.cursorShape === Qt.CrossCursor })
      return artItem
    }

    function button(label) {
      return find(painter, function(item) {
        return item.text === label && item.clicked !== undefined
      })
    }

    function edgeButton(side, label) {
      var caption = find(painter, function(item) {
        return item.text === side && item.clicked === undefined
      })
      check(caption && caption.parent, "canvas row for " + side + " is missing")
      var kids = caption.parent.children || []
      var i
      for (i = 0; i < kids.length; i++) {
        if (kids[i].text === label && kids[i].clicked !== undefined) return kids[i]
      }
      return null
    }

    function glyph(col, row) {
      return PaintModel.glyphAt(painter.canvas, col, row)
    }

    function point(col, row, fx, fy) {
      return {
        x: col * painter.cellW + painter.cellW * fx,
        y: row * painter.cellH + painter.cellH * fy
      }
    }

    function clickCell(col, row, fx, fy, button) {
      var at = point(col, row, fx, fy)
      mouseClick(art(), at.x, at.y, button === undefined ? Qt.LeftButton : button)
      wait(30)
    }

    function dragCell(c0, r0, c1, r1) {
      var from = point(c0, r0, 0.5, 0.5)
      var to = point(c1, r1, 0.5, 0.5)
      mouseDrag(art(), from.x, from.y, to.x - from.x, to.y - from.y, Qt.LeftButton)
      wait(30)
    }

    function openPayload(payload) {
      artItem = null
      painter.open(JSON.stringify(payload || {}))
      var spins = 0
      while ((!painter.canvasReady || painter.cellW < 2 || !art()) && spins < 40) {
        wait(25)
        spins++
      }
      check(painter.opened && painter.canvasReady && art(), "painter did not open a canvas opened=" + painter.opened + " ready=" + painter.canvasReady + " cellW=" + painter.cellW + " art=" + !!art())
    }

    function discard() {
      painter.typing = false
      painter.painting = false
      painter.dirty = false
    }

    function run() {
      var blank = dir + "/blank.txt"
      var seeded = dir + "/seeded.txt"
      var opened = dir + "/opened.txt"
      var savedAs = dir + "/saved-as.txt"

      openPayload({})
      check(painter.canvas.cols === 80 && painter.canvas.rows === 24, "a blank open is 80 by 24")
      check(painter.tool === "block" && !painter.dirty, "a blank open starts on the block tool, clean")
      check(!button("Undo").enabled && !button("Redo").enabled && !button("Save").enabled, "undo, redo, and save start disabled")
      mouseClick(button("Undo"), button("Undo").width / 2, button("Undo").height / 2)
      wait(20)
      check(!painter.canUndo, "a disabled undo click does not invent history")
      console.log("RESULT ok blank canvas and disabled history")

      clickCell(0, 0, 0.2, 0.2)
      check(glyph(0, 0) === "\u2598", "upper-left click paints the upper-left quadrant")
      clickCell(0, 0, 0.2, 0.2)
      check(glyph(0, 0) === "\u2598", "a second click on the same quadrant does not erase it")
      clickCell(0, 0, 0.8, 0.8)
      check(glyph(0, 0) === "\u259a", "the opposite quadrant joins the first instead of replacing it")
      clickCell(1, 0, 0.2, 0.2, Qt.RightButton)
      check(glyph(1, 0) === " ", "a right click on an empty cell stays empty")
      clickCell(0, 0, 0.2, 0.2, Qt.RightButton)
      check(glyph(0, 0) !== "\u259a", "a right click erases the half under the pointer")
      clickCell(3, 0, 0.5, 0.5, Qt.MiddleButton)
      check(glyph(3, 0) === " ", "a middle click is ignored")
      var outside = painter.canvas.cols * painter.cellW + 8
      var before = glyph(0, 1)
      mouseClick(art(), outside, painter.cellH * 0.5, Qt.LeftButton)
      wait(20)
      check(glyph(0, 1) === before && painter.canvas.cols === 80, "a click past the canvas does not paint or resize")
      mouseDrag(art(), painter.cellW * 4.2, painter.cellH * 0.2, 4, 2, Qt.LeftButton)
      wait(20)
      check(glyph(5, 0) === " ", "a wiggle inside the click slop does not drag into the next cell")
      console.log("RESULT ok block clicks, erase, and ignored pointers")

      dragCell(6, 1, 9, 1)
      check(glyph(6, 1) !== " " && glyph(9, 1) !== " ", "a drag past the click slop paints the cells it crosses")
      console.log("RESULT ok block drag")

      keyClick(Qt.Key_L)
      wait(20)
      check(painter.tool === "line" && painter.linePaletteVisible, "L selects the line tool")
      clickCell(0, 3, 0.5, 0.5)
      check(glyph(0, 3) === "\u253c", "a line click with no drag is a crossing")
      keyClick(Qt.Key_D)
      wait(20)
      check(painter.lineStyle === "double", "D switches line style to double")
      dragCell(1, 3, 4, 3)
      check(glyph(1, 3) === "\u2550" || glyph(2, 3) === "\u2550", "a double-line drag commits a horizontal double stroke")
      keyClick(Qt.Key_1)
      wait(20)
      check(painter.lineStyle === "single", "1 returns a line to single style")
      keyClick(Qt.Key_R)
      wait(20)
      check(painter.tool === "rect", "R selects the rectangle tool")
      dragCell(0, 5, 3, 7)
      check(glyph(0, 5) === "\u250c" && glyph(3, 7) === "\u2518", "a rectangle drag commits the two opposite corners")
      console.log("RESULT ok lines and rectangles")

      keyClick(Qt.Key_S)
      wait(20)
      check(painter.tool === "shade" && painter.shadePaletteVisible, "S selects the shade tool")
      keyClick(Qt.Key_2)
      wait(20)
      check(painter.shadeLevel === 2, "2 selects the medium shade")
      clickCell(0, 9, 0.5, 0.5)
      check(glyph(0, 9) === "\u2592", "a shade click paints the selected level")
      var level = painter.shadeLevel
      mouseWheel(art(), painter.cellW, painter.cellH * 9, 0, 120)
      wait(20)
      check(painter.shadeLevel !== level, "the wheel changes the shade level")
      mouseWheel(art(), painter.cellW, painter.cellH * 9, 0, 120)
      mouseWheel(art(), painter.cellW, painter.cellH * 9, 0, 120)
      mouseWheel(art(), painter.cellW, painter.cellH * 9, 0, 120)
      wait(20)
      check(painter.shadeLevel === 4, "the shade level stops at solid")
      keyClick(Qt.Key_B)
      wait(20)
      level = painter.shadeLevel
      mouseWheel(art(), painter.cellW, painter.cellH, 0, -120)
      wait(20)
      check(painter.tool === "block" && painter.shadeLevel === level, "the wheel does nothing while the block tool is active")
      console.log("RESULT ok shade keys and wheel")

      discard()
      openPayload({ path: seeded })
      check(painter.canvas.cols === 2 && painter.canvas.rows === 2, "an existing file opens at its own size")
      check(glyph(0, 0) === "a" && glyph(1, 1) === "d", "the opened file keeps its letters")
      keyClick(Qt.Key_F)
      wait(20)
      keyClick(Qt.Key_1)
      wait(20)
      clickCell(0, 0, 0.5, 0.5)
      check(glyph(0, 0) === "\u2591" && glyph(1, 1) === "d", "fill replaces the connected cell and stops at a different one")
      console.log("RESULT ok flood fill")

      discard()
      openPayload({})
      keyClick(Qt.Key_T)
      wait(20)
      check(painter.tool === "text", "T selects the text tool")
      clickCell(2, 2, 0.5, 0.5)
      check(painter.typing, "a text click starts a caret")
      keyClick("Z")
      wait(20)
      check(glyph(2, 2) === "Z" || glyph(2, 2) === "z", "typing stamps the character into the caret cell")
      keyClick(Qt.Key_Backspace)
      wait(20)
      check(glyph(2, 2) === " ", "backspace restores the cell from before the run")
      keyClick("Q")
      wait(20)
      keyClick(Qt.Key_Escape)
      wait(20)
      check(!painter.typing && glyph(2, 2) === " ", "escape cancels the text run")
      clickCell(2, 2, 0.5, 0.5)
      keyClick("Q")
      keyClick(Qt.Key_Return)
      wait(20)
      check(!painter.typing && (glyph(2, 2) === "Q" || glyph(2, 2) === "q"), "enter commits the text run")
      clickCell(80, 2, 0.5, 0.5)
      check(!painter.typing, "a text click past the canvas does not open a caret")
      console.log("RESULT ok text entry")

      var committed = glyph(2, 2)
      keyClick(Qt.Key_Z, Qt.ControlModifier)
      wait(30)
      check(glyph(2, 2) === " ", "ctrl+z undoes the committed text")
      keyClick(Qt.Key_Z, Qt.ControlModifier | Qt.ShiftModifier)
      wait(30)
      check(glyph(2, 2) === committed, "ctrl+shift+z redoes it")
      mouseClick(button("Undo"), button("Undo").width / 2, button("Undo").height / 2)
      wait(30)
      check(glyph(2, 2) === " ", "the undo button undoes the same edit")
      mouseClick(button("Redo"), button("Redo").width / 2, button("Redo").height / 2)
      wait(30)
      check(glyph(2, 2) === committed, "the redo button restores it")
      console.log("RESULT ok undo and redo")

      keyClick("+")
      wait(20)
      check(painter.zoom === 2, "+ zooms in")
      keyClick("+")
      keyClick("+")
      wait(20)
      check(painter.zoom === 3, "zoom stops at 3")
      mouseClick(button("1\u00d7"), button("1\u00d7").width / 2, button("1\u00d7").height / 2)
      wait(30)
      check(painter.zoom === 1, "the 1x button zooms back out")
      keyClick("-")
      wait(20)
      check(painter.zoom === 1, "zoom does not go below 1")
      console.log("RESULT ok zoom")

      discard()
      openPayload({ path: seeded })
      var topPlus = edgeButton("Top", "+")
      var topMinus = edgeButton("Top", "\u2212")
      mouseClick(topPlus, topPlus.width / 2, topPlus.height / 2)
      wait(30)
      check(painter.canvas.rows === 3 && glyph(0, 1) === "a" && glyph(0, 2) === "c", "top plus inserts an empty row and keeps the old cells rows=" + painter.canvas.rows + " below=" + glyph(0, 1))
      mouseClick(topMinus, topMinus.width / 2, topMinus.height / 2)
      wait(30)
      check(painter.canvas.rows === 2, "top minus removes that row")
      mouseClick(topMinus, topMinus.width / 2, topMinus.height / 2)
      wait(30)
      mouseClick(topMinus, topMinus.width / 2, topMinus.height / 2)
      wait(30)
      check(painter.canvas.rows === 1, "a canvas will not shrink below one row")
      console.log("RESULT ok canvas edges")

      discard()
      openPayload({ path: blank, preview: "screensaver" })
      clickCell(0, 0, 0.2, 0.2)
      var painted = glyph(0, 0)
      keyClick(Qt.Key_S, Qt.ControlModifier)
      var spins = 0
      while (painter.dirty && spins < 40) {
        wait(25)
        spins++
      }
      check(!painter.dirty, "ctrl+s clears the dirty flag")
      check(painter.filePath === blank, "save keeps the open path")
      console.log("RESULT ok save " + painted)
      wait(400)

      openPayload({})
      keyClick(Qt.Key_L)
      wait(20)
      clickCell(1, 1, 0.5, 0.5)
      check(painter.hasUnsavedChanges, "a new stroke is unsaved")
      keyClick(Qt.Key_Escape)
      wait(40)
      check(painter.opened && painter.tool === "line", "escape with unsaved paint asks instead of closing, and does not change tools")
      keyClick(Qt.Key_B)
      wait(20)
      check(painter.tool === "line", "tool keys do nothing while the discard dialog is up")
      keyClick(Qt.Key_K)
      wait(30)
      check(painter.opened && glyph(1, 1) !== " ", "keep leaves the paint in place")
      keyClick(Qt.Key_Escape)
      wait(30)
      keyClick(Qt.Key_D)
      wait(30)
      check(!painter.opened, "discard closes the painter")
      console.log("RESULT ok discard dialog")

      openPayload({})
      mouseClick(button("Open"), button("Open").width / 2, button("Open").height / 2)
      spins = 0
      while ((painter.filePath !== opened || glyph(0, 0) !== "o") && spins < 40) {
        wait(25)
        spins++
      }
      check(painter.filePath === opened && glyph(0, 0) === "o", "open loads the file the chooser returned")
      mouseClick(button("Save As"), button("Save As").width / 2, button("Save As").height / 2)
      spins = 0
      while (painter.filePath !== savedAs && spins < 40) {
        wait(25)
        spins++
      }
      check(painter.filePath === savedAs, "save as writes the chooser's path")
      wait(500)
      console.log("RESULT ok open and save as")

      keyClick(Qt.Key_Escape)
      wait(30)
      check(!painter.opened, "escape on a clean canvas closes")
      console.log("RESULT pass")
      Qt.quit()
    }

    Component.onCompleted: Qt.callLater(run)
  }
}
