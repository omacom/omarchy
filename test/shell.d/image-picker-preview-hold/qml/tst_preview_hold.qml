import QtQuick
import QtTest
import "../../../../shell/plugins/image-picker"

// The picker keeps its decoded previews while open and for a grace period
// after closing, then lets them go.
Item {
  id: root

  PreviewHold {
    id: hold
    grace: 200
  }

  SignalSpy {
    id: changes
    target: hold
    signalName: "heldChanged"
  }

  TestCase {
    name: "PreviewHold"

    function init() {
      hold.active = false
      tryCompare(hold, "held", false, 1000)
    }

    function test_nothing_is_held_before_the_first_open() {
      compare(hold.held, false)
    }

    function test_previews_are_held_while_open() {
      hold.active = true
      compare(hold.held, true)
      wait(400)
      compare(hold.held, true, "an open picker never releases")
    }

    function test_previews_are_released_after_the_grace_period() {
      hold.active = true
      hold.active = false
      compare(hold.held, true, "a quick reopen still finds them")
      tryCompare(hold, "held", false, 1000)
    }

    function test_reopening_within_the_grace_period_keeps_them() {
      hold.active = true
      hold.active = false
      wait(100)
      hold.active = true
      wait(300)
      compare(hold.held, true, "the release was cancelled")
    }

    // Each change of held reloads or unloads every preview.
    function test_extending_the_grace_period_never_lets_go() {
      hold.active = true
      hold.active = false
      changes.clear()
      hold.warm()
      wait(100)
      hold.warm()
      hold.active = true
      hold.active = false
      compare(changes.count, 0, "held stayed on throughout")
      tryCompare(hold, "held", false, 1000)
      compare(changes.count, 1, "and went off once, at the end")
    }

    function test_a_preload_during_the_grace_period_extends_it() {
      hold.active = true
      hold.active = false
      wait(150)
      hold.warm()
      wait(100)
      compare(hold.held, true, "still held past the close's own deadline")
      tryCompare(hold, "held", false, 1000)
    }

    function test_a_preload_holds_them_for_the_open_that_follows() {
      hold.warm()
      compare(hold.held, true)
      tryCompare(hold, "held", false, 1000)
    }
  }
}
