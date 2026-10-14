import QtQuick

// Decides when the picker keeps its decoded previews. Each card's preview is a
// full-card bitmap, several megabytes, and a dozen are decoded at a time.
// They are held while the picker is open and for `grace` after it closes, so
// a quick reopen shows at once, then released instead of being held for the
// life of the shell.
Item {
  id: root

  property bool active: false
  property int grace: 60000
  // Set apart from the timer: restarting a running Timer stops it first, and
  // a held that blinked off would unload every preview just to reload it.
  property bool lingering: false
  readonly property bool held: active || lingering

  // Hold the previews for a grace period without opening, as a preload does.
  function warm() {
    if (!active) linger()
  }

  function linger() {
    lingering = true
    graceTimer.restart()
  }

  onActiveChanged: {
    if (active) {
      graceTimer.stop()
      lingering = false
    } else {
      linger()
    }
  }

  Timer {
    id: graceTimer
    interval: root.grace
    onTriggered: root.lingering = false
  }
}
