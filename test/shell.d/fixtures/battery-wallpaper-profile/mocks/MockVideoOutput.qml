import QtQuick

Item {
  property int fillMode: 0
  property QtObject videoSink: QtObject {
    signal videoFrameChanged()
  }
  function clearOutput() {}
}
