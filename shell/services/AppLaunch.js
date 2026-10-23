// Launch-OSD decisions. The OSD is opened from a timer callback and closed
// from another, and those two can pass each other: a timeout Qt already
// posted still runs after Timer.stop(), and the show IPC can be handled
// after the close IPC. Both leave a duration-0 "Launching …" banner up
// with nothing left to dismiss it — the usual case is activating an app
// that already has a window.

function toplevelMatches(appId, desktopId, startupClass) {
  var id = String(appId || "")
  if (!id) return false
  var cls = String(startupClass || "")
  if (cls && id === cls) return true
  var desktop = String(desktopId || "")
  return desktop.length > 0 && id === desktop
}

function appHasWindow(toplevels, desktopId, startupClass) {
  var values = toplevels || []
  for (var i = 0; i < values.length; i++) {
    var toplevel = values[i]
    var appId = toplevel && toplevel.appId !== undefined ? toplevel.appId : toplevel
    if (toplevelMatches(appId, desktopId, startupClass)) return true
  }
  return false
}

// "ignore": this callback belongs to a launch that already finished.
// "finish": a window showed up, focus moved, or the app was already open.
// "show": still waiting on a cold start.
function launchDelayAction(timeoutRunning, toplevelCount, baselineCount, activeUnchanged, appAlreadyOpen) {
  if (!timeoutRunning) return "ignore"
  if (toplevelCount > baselineCount || !activeUnchanged || appAlreadyOpen) return "finish"
  return "show"
}

if (typeof module !== "undefined") {
  module.exports = {
    toplevelMatches: toplevelMatches,
    appHasWindow: appHasWindow,
    launchDelayAction: launchDelayAction
  }
}
