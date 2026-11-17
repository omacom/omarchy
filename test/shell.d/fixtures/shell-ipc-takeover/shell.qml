import QtQuick
import Quickshell
import "Commons" as Commons

// Two real ShellIpc handlers for one target, as two bars each build one: only
// the first answers, and the second takes over once the first is gone.
ShellRoot {
  id: test
  property bool failed: false
  readonly property string target: "omarchy.takeover-test"

  function check(ok, message) {
    if (!ok) {
      failed = true
      console.log("RESULT fail " + message)
    }
  }

  function answer() {
    var result = Commons.IpcRegistry.call(test.target, "ping", [])
    return result.ran ? result.output : "(none)"
  }

  Loader {
    id: leaderLoader
    sourceComponent: Component {
      Commons.ShellIpc {
        target: test.target
        function ping(): string { return "leader" }
      }
    }
  }

  Loader {
    id: standbyLoader
    active: false
    sourceComponent: Component {
      Commons.ShellIpc {
        target: test.target
        function ping(): string { return "standby" }
      }
    }
  }

  property int step: 0
  readonly property var steps: [
    function() { standbyLoader.active = true },
    function() {
      test.check(leaderLoader.item.enabled, "the first handler for a target is enabled")
      test.check(!standbyLoader.item.enabled, "a second handler for the same target stays disabled")
      test.check(test.answer() === "leader", "a call reaches the first handler")
      leaderLoader.active = false
    },
    function() {
      test.check(standbyLoader.item.enabled, "the second handler takes over when the first goes")
      test.check(test.answer() === "standby", "a call reaches the handler that took over")
      console.log(test.failed ? "RESULT done" : "RESULT pass")
      Qt.quit()
    }
  ]

  Timer {
    interval: 200
    repeat: true
    running: true
    onTriggered: {
      test.steps[test.step]()
      test.step++
      if (test.step >= test.steps.length) stop()
    }
  }
}
