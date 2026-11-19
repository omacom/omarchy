import QtQuick

// Scrolls a Flickable the full distance of every mouse wheel notch.
//
// Flickable restarts its wheel animation on each event and drops whatever the
// previous event still had to travel. A high-resolution wheel sends one notch
// as several small events a few milliseconds apart, so most of every notch is
// lost; an ordinary wheel loses the same way when spun quickly. This adds the
// distance up instead and hands it to the Flickable's own flick, so scroll
// bars, bounds and `moving` behave as they always did.
//
//   ListView { id: list }
//   WheelScroll { flickable: list }
//
// It lies behind the content, where the wheel arrives after everything inside
// has declined it and before the Flickable itself. Something inside that takes
// the wheel (a slider, say) still gets it first. Touchpad gestures, and a wheel
// at the end of the content, pass through to Flickable untouched.
MouseArea {
  id: root

  required property Flickable flickable
  // How far one notch (120 units) scrolls. Flickable's own default.
  property real step: Application.styleHints.wheelScrollLines * 24

  property real _goal: 0
  property real _carry: 0
  property bool _gliding: false

  parent: flickable ? flickable.contentItem : null
  x: flickable ? flickable.contentX : 0
  y: flickable ? flickable.contentY : 0
  width: flickable ? flickable.width : 0
  height: flickable ? flickable.height : 0
  z: -1
  acceptedButtons: Qt.NoButton

  Connections {
    target: root.flickable
    function onMovementEnded() { root._gliding = false }
  }

  onWheel: function(wheel) {
    var flickable = root.flickable
    var delta = -wheel.angleDelta.y / 120 * root.step
    wheel.accepted = false
    // A touchpad gesture carries a scroll phase and Flickable follows it
    // finger for finger. A wheel has none, whatever pixelDelta says: Hyprland
    // puts a fixed 15 there on some wheel events and nothing on the rest.
    if (!flickable || !flickable.interactive || delta === 0 || wheel.phase !== Qt.NoScrollPhase) return
    if (flickable.flickableDirection === Flickable.HorizontalFlick) return

    var top = flickable.originY - flickable.topMargin
    var bottom = Math.max(top, flickable.originY + flickable.contentHeight + flickable.bottomMargin - flickable.height)
    // What earlier events still have to travel, unless the wheel turned back.
    var owed = root._gliding ? root._goal - flickable.contentY : root._carry
    if (owed * delta < 0) owed = 0
    var wanted = flickable.contentY + owed + delta
    var goal = Math.max(top, Math.min(bottom, wanted))
    var left = Math.abs(goal - flickable.contentY)
    root._carry = 0

    if (left < 1) {
      // Too little to move yet: keep it for the next event. Unless that is
      // the end of the content, where an outer Flickable gets the wheel.
      if (goal !== wanted) return
      root._carry = goal - flickable.contentY
      wheel.accepted = true
      return
    }

    // Glide the last notch and jump whatever lies beyond it, so a long spin
    // follows the wheel instead of coasting after it has stopped.
    var direction = goal > flickable.contentY ? 1 : -1
    var reach = flickable.maximumFlickVelocity * flickable.maximumFlickVelocity / (2 * flickable.flickDeceleration)
    var glide = Math.min(left, root.step, reach)
    if (left - glide >= 1) flickable.contentY = goal - direction * glide
    flickable.flick(0, -direction * Math.sqrt(2 * flickable.flickDeceleration * glide))
    root._goal = goal
    root._gliding = true
    wheel.accepted = true
  }
}
