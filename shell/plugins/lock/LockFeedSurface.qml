import QtQuick
import Owe.LockFeed

// Loaded through a Loader from LockView, so a system without the module shows
// no lock video instead of losing the whole lock screen.
LockFeed {
  id: root

  property bool feedEnabled: true
  active: root.feedEnabled
}
