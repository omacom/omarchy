pragma Singleton

import QtQuick

QtObject {
  property bool onBattery: true
  property QtObject displayDevice: QtObject {
    property bool isPresent: true
    property real percentage: 0.8
    property int state: 4
    property real changeRate: 0
    property real timeToFull: 0
  }
}
