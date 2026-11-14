import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

// Ui/WheelScroll in a grid shaped like the dock's Apps grid. Touchpad steps
// are fed through touchpad(), as onWheel does with the exact angleDelta.
ShellRoot {
  id: root

  property var steps: []
  property int at: 0

  readonly property string resultPath: Quickshell.env("OMARCHY_QML_TEST_RESULT")

  function finish(ok, message) {
    result.setText(JSON.stringify({ ok: ok, message: message || "" }))
    quitter.start()
  }

  FileView {
    id: result
    path: root.resultPath
  }

  Timer {
    id: quitter
    interval: 50
    onTriggered: Qt.quit()
  }

  function reset() {
    scroll.stopCoasting()
    scroll.samples = []
    scroll.endsReported = false
    Style.reduceMotion = false
    Style.touchpadScrollFactor = 0.4
    grid.contentY = grid.originY
  }

  // A quick swipe: six 12px steps 16ms apart.
  function swipe(then) {
    var left = 6
    function step() {
      scroll.touchpad(12, Qt.ScrollUpdate)
      if (--left > 0) Qt.callLater(function() { delay.run(16, step) })
      else delay.run(16, then)
    }
    step()
  }

  property var checks: [
    function(next) {
      reset()
      if (Math.abs(scroll.touchpadScale - 7.5) > 1e-9) return finish(false, "touchpad gain at factor 0.4 is " + scroll.touchpadScale + ", not 7.5")
      scroll.touchpad(-10, Qt.ScrollUpdate)
      if (Math.round(grid.contentY - grid.originY) !== 75) return finish(false, "a 10px step moved " + (grid.contentY - grid.originY) + "px, not 75")
      scroll.touchpad(0, Qt.ScrollEnd)
      next()
    },
    function(next) {
      reset()
      scroll.wheelNotch(-120)
      if (Math.round(grid.contentY - grid.originY) !== Math.round(grid.cellHeight)) return finish(false, "a wheel notch moved " + (grid.contentY - grid.originY) + "px, not one row")
      next()
    },
    function(next) {
      reset()
      grid.contentY = grid.originY + 2000
      swipe(function() {
        var lifted = grid.contentY
        scroll.touchpad(0, Qt.ScrollEnd)
        // The view stops its own motion when the lift reaches it.
        grid.cancelFlick()
        if (!scroll.coasting) return finish(false, "a quick swipe did not coast")
        delay.run(150, function() {
          if (!(grid.contentY < lifted - 10)) return finish(false, "the coast did not keep moving: " + lifted + " -> " + grid.contentY)
          scroll.stopCoasting()
          next()
        })
      })
    },
    function(next) {
      reset()
      grid.contentY = grid.originY + 2000
      Style.reduceMotion = true
      swipe(function() {
        scroll.touchpad(0, Qt.ScrollEnd)
        if (scroll.coasting) return finish(false, "coasted with reduced motion")
        next()
      })
    },
    function(next) {
      reset()
      grid.contentY = grid.originY + 2000
      scroll.touchpad(0, Qt.ScrollEnd)
      swipe(function() {
        delay.run(150, function() {
          if (scroll.coasting) return finish(false, "a pause mid-swipe started a coast once lifts were reported")
          scroll.touchpad(0, Qt.ScrollEnd)
          next()
        })
      })
    },
    function(next) {
      reset()
      grid.contentY = grid.originY + 2000
      swipe(function() {
        scroll.touchpad(0, Qt.ScrollEnd)
        delay.run(30, function() {
          grid.contentY = grid.originY + 500
          delay.run(60, function() {
            if (scroll.coasting || grid.contentY !== grid.originY + 500) return finish(false, "moving the grid another way did not stop the coast")
            next()
          })
        })
      })
    },
    function(next) {
      reset()
      for (var i = 0; i < 400; i++) scroll.touchpad(-50, Qt.ScrollUpdate)
      if (grid.contentY !== scroll.bottom()) return finish(false, "scrolling past the end left contentY at " + grid.contentY)
      scroll.touchpad(0, Qt.ScrollEnd)
      next()
    }
  ]

  function run(i) {
    if (i >= root.checks.length) return finish(true)
    root.checks[i](function() { Qt.callLater(function() { root.run(i + 1) }) })
  }

  QtObject {
    id: delay
    function run(ms, fn) {
      var t = Qt.createQmlObject('import QtQuick; Timer { }', root)
      t.interval = ms
      t.triggered.connect(function() { t.destroy(); fn() })
      t.start()
    }
  }

  Item {
    width: 600
    height: 400

    GridView {
      id: grid
      anchors.fill: parent
      model: 300
      cellWidth: 100
      cellHeight: 120
      boundsBehavior: Flickable.StopAtBounds
      WheelScroll { id: scroll; view: grid; lineHeight: grid.cellHeight / Qt.styleHints.wheelScrollLines }
      delegate: Item {
        width: 100
        height: 120
        MouseArea { anchors.fill: parent; hoverEnabled: true }
      }
    }
  }

  Component.onCompleted: Qt.callLater(function() { root.run(0) })
}
