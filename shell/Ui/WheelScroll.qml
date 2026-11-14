import QtQuick
import qs.Commons

// Wheel and touchpad scrolling for a list or grid. Put it inside the view:
//   WheelScroll { view: grid; lineHeight: root.cellHeight / Qt.styleHints.wheelScrollLines }
//
// Flickable's own wheel handling turns every event into a short flick, so a
// full touchpad swipe moves a view about a row and it stops dead on lift.
//
// Touchpad: Qt on Wayland rounds each touchpad step to whole pixels in
// pixelDelta (mostly 0, 1 or 2) and keeps the exact amount in angleDelta, at
// 12 units per pixel, so the exact value is used. Hyprland has already scaled
// it by input:touchpad:scroll_factor (Style.touchpadScrollFactor); that is
// divided back out and a gain applied, so the view follows the fingers. A
// quick swipe coasts after the fingers lift, unless motion is reduced.
// Mouse wheel: a notch moves wheelScrollLines lines of lineHeight.
WheelHandler {
  id: handler

  required property Flickable view
  // One wheel line, in pixels.
  property real lineHeight: 40
  // Touchpad pixels per pixel Hyprland reports. Gain 3 over the unscaled
  // touchpad: one slow full-height swipe on a laptop touchpad moves about
  // 1900px.
  property real touchpadScale: 3 / Math.max(0.05, Style.touchpadScrollFactor)

  // Recent touchpad moves as { t: ms, px: pixels }, for the release speed.
  property var samples: []
  // Once a ScrollEnd has arrived the lift is always reported, so the timer
  // below is never needed; without this, fingers resting mid-swipe would
  // start a coast.
  property bool endsReported: false
  // For setups that never send ScrollEnd: the lift is assumed when no
  // touchpad event follows within this time.
  property Timer releaseTimer: Timer { interval: 70; onTriggered: handler.release() }

  // Coasting speed in pixels per second, decaying like a browser fling.
  // It runs here, frame by frame, rather than through Flickable.flick(): the
  // view stops its own motion when the lift reaches it, which cancels a
  // flick started for that same lift.
  property real coastVelocity: 0
  readonly property bool coasting: coaster.running
  // The contentY this handler last set, to notice another mover (keyboard
  // selection, a new filter) and stop coasting.
  property real coastY: 0
  property FrameAnimation coaster: FrameAnimation {
    onTriggered: handler.coastStep(frameTime)
  }

  target: null
  acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad

  function bottom() {
    return handler.view.originY + Math.max(0, handler.view.contentHeight - handler.view.height)
  }

  function scrollBy(pixels) {
    var v = handler.view
    v.contentY = Math.max(v.originY, Math.min(handler.bottom(), v.contentY - pixels))
  }

  // Pixels per second over the last 80ms of movement, measured back from the
  // last move rather than the lift, which can arrive a little later. Fingers
  // that rested (no move in the 100ms before the lift) give 0.
  function velocity(now) {
    var n = handler.samples.length
    if (n < 2) return 0
    var last = handler.samples[n - 1].t
    if (now - last > 100) return 0
    var recent = handler.samples.filter(function(s) { return last - s.t <= 80 })
    if (recent.length < 2) return 0
    var sum = 0
    for (var i = 1; i < recent.length; i++) sum += recent[i].px
    var span = (recent[recent.length - 1].t - recent[0].t) / 1000
    return span > 0 ? sum / span : 0
  }

  function release() {
    handler.releaseTimer.stop()
    var v = handler.velocity(Date.now())
    handler.samples = []
    if (Style.reduceMotion || Math.abs(v) < 300) return
    handler.coastVelocity = v
    handler.coastY = handler.view.contentY
    handler.coaster.start()
  }

  function stopCoasting() {
    handler.coaster.stop()
    handler.coastVelocity = 0
  }

  // seconds: time since the last frame.
  function coastStep(seconds) {
    var v = handler.view
    if (Math.abs(v.contentY - handler.coastY) > 0.5) {
      handler.stopCoasting()
      return
    }
    var dt = Math.min(0.05, Math.max(0, seconds))
    // Time constant 0.33s: the coast covers about a third of a second's worth
    // of the release speed.
    handler.coastVelocity *= Math.exp(-dt / 0.33)
    var before = v.contentY
    handler.scrollBy(handler.coastVelocity * dt)
    handler.coastY = v.contentY
    if (Math.abs(handler.coastVelocity) < 20 || (v.contentY === before && dt > 0)) handler.stopCoasting()
  }

  // delta: exact touchpad pixels as Hyprland reported them.
  function touchpad(delta, phase) {
    handler.stopCoasting()
    var pixels = delta * handler.touchpadScale
    if (pixels !== 0) {
      var now = Date.now()
      handler.scrollBy(pixels)
      handler.samples = handler.samples.filter(function(s) { return now - s.t <= 150 }).concat([{ t: now, px: pixels }])
    }
    if (phase === Qt.ScrollEnd) {
      handler.endsReported = true
      handler.release()
    } else if (!handler.endsReported) {
      handler.releaseTimer.restart()
    }
  }

  // angle: angleDelta.y of a wheel notch (120 per notch).
  function wheelNotch(angle) {
    handler.stopCoasting()
    handler.scrollBy(angle / 120 * handler.lineHeight * Qt.styleHints.wheelScrollLines)
  }

  function isTouchpad(event) {
    return event.phase !== Qt.NoScrollPhase
      || (event.device && event.device.type === PointerDevice.TouchPad)
  }

  onWheel: function(event) {
    if (handler.isTouchpad(event)) {
      var exact = event.angleDelta.y !== 0 ? event.angleDelta.y / 12 : event.pixelDelta.y
      handler.touchpad(exact, event.phase)
    } else {
      handler.wheelNotch(event.angleDelta.y)
    }
    event.accepted = true
  }
}
