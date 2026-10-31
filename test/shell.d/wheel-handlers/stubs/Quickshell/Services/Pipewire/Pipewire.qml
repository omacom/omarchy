pragma Singleton
import QtQuick

QtObject {
  property var nodes: null
  property QtObject defaultAudioSource: QtObject {
    property QtObject audio: QtObject {
      property real volume: 0.5
      property bool muted: false
    }
  }
}
