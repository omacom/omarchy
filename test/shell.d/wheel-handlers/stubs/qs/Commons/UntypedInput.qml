pragma Singleton
import QtQuick

QtObject {
  property bool active: false
  property bool known: false
  property bool muted: false
  property real volume: 0
  function setVolume(value) { volume = value }
  function setMuted(value) { muted = value }
}
